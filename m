From: "Haruki Dai-r35557" <Dai.Haruki@freescale.com>
Subject: [PATCH] Gianfar SKB Recycling Support
Date: Wed, 17 May 2006 15:45:14 -0700
Message-ID: <18AEF66AFDF06F4CAAA1D419D000FD33524B79@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>,
	"Haruki Dai-r35557" <Dai.Haruki@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:44771 "EHLO
	az33egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1750883AbWEQWpX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 18:45:23 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id k4HN5CXB001324
	for <netdev@vger.kernel.org>; Wed, 17 May 2006 16:05:13 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id k4HMjJl0024017
	for <netdev@vger.kernel.org>; Wed, 17 May 2006 17:45:20 -0500 (CDT)
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch improves the IP forwarding throughput of
the Freescale TSEC/eTSEC Gianfar driver. By recycling
the Socket buffer and Data buffer, reduce the unnecessary
memory allocation and de-allocation in the forwarding
processing chain.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>

---

 drivers/net/Kconfig           |   10 +
 drivers/net/gianfar.c         |  351 ++++++++++++++++++++++++++++++++++-------
 drivers/net/gianfar.h         |   60 +++++--
 drivers/net/gianfar_ethtool.c |   23 ++-
 4 files changed, 357 insertions(+), 87 deletions(-)

9b63ff0fd0d2cf12425e7211f10b571b8bf3c66e
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index bdaaad8..0fe6e74 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2188,6 +2188,16 @@ config GIANFAR
 config GFAR_NAPI
 	bool "NAPI Support"
 	depends on GIANFAR
+	help
+
+config GFAR_SKBUFF_RECYCLING
+	default y if GIANFAR
+	bool "Socket Buffer Recycling Support"
+	depends on GIANFAR
+	help
+	  This implements a new private socket data buffer recycling algorithm
+	  used for fast IPv4 packet forwarding. Select this if you would like
+	  to improve your latency and throughput performance.
 
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 218d317..c7b34fa 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -7,6 +7,7 @@
  * Based on 8260_io/fcc_enet.c
  *
  * Author: Andy Fleming
+ *         Dai Haruki
  * Maintainer: Kumar Gala
  *
  * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
@@ -110,13 +111,13 @@ #define RECEIVE(x) netif_rx(x)
 #endif
 
 const char gfar_driver_name[] = "Gianfar Ethernet";
-const char gfar_driver_version[] = "1.3";
+const char gfar_driver_version[] = "1.4";
 
 static int gfar_enet_open(struct net_device *dev);
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
-struct sk_buff *gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp);
+inline struct sk_buff *gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp);
 static struct net_device_stats *gfar_get_stats(struct net_device *dev);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
@@ -128,7 +129,7 @@ static void init_registers(struct net_de
 static int init_phy(struct net_device *dev);
 static int gfar_probe(struct platform_device *pdev);
 static int gfar_remove(struct platform_device *pdev);
-static void free_skb_resources(struct gfar_private *priv);
+static void gfar_free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 #ifdef CONFIG_GFAR_NAPI
@@ -150,6 +151,19 @@ MODULE_AUTHOR("Freescale Semiconductor, 
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
 MODULE_LICENSE("GPL");
 
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+static void gfar_free_recycle_queue(struct gfar_private *priv );
+static inline void gfar_kfree_skb(struct sk_buff *skb,
+				  unsigned long int recyclable);
+static void gfar_reset_skb_handler(void* dummy);
+
+/*
+ *	Local SKB recycling pool (per CPU)
+ */
+DEFINE_PER_CPU(struct gfar_skb_handler, gfar_skb_handler);
+
+#endif
+
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
@@ -193,7 +207,8 @@ static int gfar_probe(struct platform_de
 		priv->interruptTransmit = platform_get_irq_byname(pdev, "tx");
 		priv->interruptReceive = platform_get_irq_byname(pdev, "rx");
 		priv->interruptError = platform_get_irq_byname(pdev, "error");
-		if (priv->interruptTransmit < 0 || priv->interruptReceive < 0 || priv->interruptError < 0)
+		if (priv->interruptTransmit < 0 || priv->interruptReceive < 0 
+		    || priv->interruptError < 0)
 			goto regs_fail;
 	} else {
 		priv->interruptTransmit = platform_get_irq(pdev, 0);
@@ -264,7 +279,6 @@ #endif
 	dev->stop = gfar_close;
 	dev->get_stats = gfar_get_stats;
 	dev->change_mtu = gfar_change_mtu;
-	dev->mtu = 1500;
 	dev->set_multicast_list = gfar_set_multi;
 
 	dev->ethtool_ops = &gfar_ethtool_ops;
@@ -360,6 +374,9 @@ #endif
 		printk("%2.2x%c", dev->dev_addr[idx], idx == 5 ? ' ' : ':');
 	printk("\n");
 
+	/* Setup MTU */
+	gfar_change_mtu(dev, 1500);
+
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks. */
 #ifdef CONFIG_GFAR_NAPI
@@ -370,6 +387,10 @@ #endif
 	printk(KERN_INFO "%s: %d/%d RX/TX BD ring size\n",
 	       dev->name, priv->rx_ring_size, priv->tx_ring_size);
 
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+	printk(KERN_INFO "%s: Socket buffer recycling mode enabled\n", dev->name);
+#endif
+
 	return 0;
 
 register_fail:
@@ -409,7 +430,8 @@ static int init_phy(struct net_device *d
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id,
+		 priv->einfo->phy_id);
 
 	phydev = phy_connect(dev, phy_id, &adjust_link, 0);
 
@@ -533,7 +555,7 @@ void stop_gfar(struct net_device *dev)
  		free_irq(priv->interruptTransmit, dev);
 	}
 
-	free_skb_resources(priv);
+	gfar_free_skb_resources(priv);
 
 	dma_free_coherent(NULL,
 			sizeof(struct txbd8)*priv->tx_ring_size
@@ -542,14 +564,67 @@ void stop_gfar(struct net_device *dev)
 			gfar_read(&regs->tbase0));
 }
 
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+/*
+ * function: gfar_reset_skb_handler
+ *  Resetting skb handler spin lock entry in the driver initialization.
+ *
+ */
+static void gfar_reset_skb_handler(void* dummy) {
+	unsigned long flags = 0;
+	struct gfar_skb_handler* sh = &__get_cpu_var(gfar_skb_handler);
+	spin_lock_init(&sh->lock);
+	spin_lock_irqsave(&sh->lock, flags);
+	sh->recycle_max = GFAR_RECYCLE_MAX;
+	sh->recycle_count = 0;
+	sh->recycle_queue = NULL;
+	spin_unlock_irqrestore(&sh->lock, flags);
+	printk(KERN_INFO"SKB Handler initialized(max=%d)\n",sh->recycle_max);
+}
+
+/*
+ * function: gfar_free_recycle_queue
+ *  Reset SKB handler struction and free existance socket buffer 
+ *  and data buffer in the recycling queue.
+ */
+void gfar_free_recycle_queue( struct gfar_private *priv )
+{
+	unsigned long flags;
+	struct sk_buff *clist = NULL;
+	struct sk_buff *skb;
+	/* Get recycling queue */
+	struct gfar_skb_handler* sh = &__get_cpu_var(gfar_skb_handler);
+	/* just for making sure there is recycle_queue */
+	spin_lock_irqsave(&sh->lock, flags);
+	if ( (sh->recycle_queue) ) {
+		/* pick one from head; most recent one */
+		clist = sh->recycle_queue;
+		sh->recycle_count = 0;
+		sh->recycle_queue = NULL;
+	}
+	spin_unlock_irqrestore(&sh->lock, flags);
+	while (clist) {
+		skb = clist;
+		BUG_TRAP(!atomic_read(&skb->users));
+		dev_kfree_skb_any(skb);
+		clist = clist->next;
+	}
+	
+}
+#endif
+
 /* If there are any tx skbs or rx skbs still around, free them.
  * Then free tx_skbuff and rx_skbuff */
-static void free_skb_resources(struct gfar_private *priv)
+static void gfar_free_skb_resources(struct gfar_private *priv)
 {
 	struct rxbd8 *rxbdp;
 	struct txbd8 *txbdp;
 	int i;
 
+
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+	gfar_free_recycle_queue(priv);
+#endif
 	/* Go through all the buffer descriptors and free their data buffers */
 	txbdp = priv->tx_bd_base;
 
@@ -574,8 +649,8 @@ static void free_skb_resources(struct gf
 		for (i = 0; i < priv->rx_ring_size; i++) {
 			if (priv->rx_skbuff[i]) {
 				dma_unmap_single(NULL, rxbdp->bufPtr,
-						priv->rx_buffer_size,
-						DMA_FROM_DEVICE);
+						 priv->rx_buffer_size,
+						 DMA_FROM_DEVICE);
 
 				dev_kfree_skb_any(priv->rx_skbuff[i]);
 				priv->rx_skbuff[i] = NULL;
@@ -778,17 +853,19 @@ int startup_gfar(struct net_device *dev)
 	phy_start(priv->phydev);
 
 	/* Configure the coalescing support */
+	priv->txic = 0;
 	if (priv->txcoalescing)
-		gfar_write(&regs->txic,
-			   mk_ic_value(priv->txcount, priv->txtime));
-	else
-		gfar_write(&regs->txic, 0);
+		priv->txic = mk_ic_value(priv->txcount, priv->txtime);
 
+	gfar_write(&regs->txic, 0);
+	gfar_write(&regs->txic, priv->txic);
+
+	priv->rxic = 0;
 	if (priv->rxcoalescing)
-		gfar_write(&regs->rxic,
-			   mk_ic_value(priv->rxcount, priv->rxtime));
-	else
-		gfar_write(&regs->rxic, 0);
+		priv->rxic = mk_ic_value(priv->rxcount, priv->rxtime);
+
+	gfar_write(&regs->rxic, 0);
+	gfar_write(&regs->rxic, priv->rxic);
 
 	if (priv->rx_csum_enable)
 		rctrl |= RCTRL_CHECKSUMMING;
@@ -847,7 +924,7 @@ tx_irq_fail:
 	free_irq(priv->interruptError, dev);
 err_irq_fail:
 rx_skb_fail:
-	free_skb_resources(priv);
+	gfar_free_skb_resources(priv);
 tx_skb_fail:
 	dma_free_coherent(NULL,
 			sizeof(struct txbd8)*priv->tx_ring_size
@@ -858,6 +935,7 @@ tx_skb_fail:
 	return err;
 }
 
+
 /* Called when something needs to use the ethernet device */
 /* Returns 0 for success. */
 static int gfar_enet_open(struct net_device *dev)
@@ -983,6 +1061,9 @@ static int gfar_start_xmit(struct sk_buf
 	/* in need of CRC */
 	status |= (TXBD_READY | TXBD_LAST | TXBD_CRC);
 
+	/* Tell the DMA to go go go */
+	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
+
 	dev->trans_start = jiffies;
 
 	txbdp->status = status;
@@ -1005,9 +1086,6 @@ static int gfar_start_xmit(struct sk_buf
 	/* Update the current txbd to the next one */
 	priv->cur_tx = txbdp;
 
-	/* Tell the DMA to go go go */
-	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
-
 	/* Unlock priv */
 	spin_unlock_irqrestore(&priv->txlock, flags);
 
@@ -1134,6 +1212,20 @@ static int gfar_change_mtu(struct net_de
 
 	dev->mtu = new_mtu;
 
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+	priv->skbuff_truesize =	
+		SKB_DATA_ALIGN(tempsize + RXBUF_ALIGNMENT + 
+			       GFAR_SKB_USER_OPT_HEADROOM)
+		+ sizeof(struct sk_buff);
+	printk(KERN_INFO"%s: MTU = %d (frame size=%d,truesize=%lu)\n",
+	       dev->name,dev->mtu,frame_size,
+	       priv->skbuff_truesize );
+#else
+	printk(KERN_INFO"%s: MTU = %d (frame size=%d)\n", dev->name,
+	       dev->mtu, frame_size);
+#endif /*CONFIG_GFAR_SKBUFF_RECYCLING*/
+
+
 	gfar_write(&priv->regs->mrblr, priv->rx_buffer_size);
 	gfar_write(&priv->regs->maxfrm, priv->rx_buffer_size);
 
@@ -1173,18 +1265,13 @@ static void gfar_timeout(struct net_devi
 	netif_schedule(dev);
 }
 
-/* Interrupt Handler for Transmit complete */
-static irqreturn_t gfar_transmit(int irq, void *dev_id, struct pt_regs *regs)
+static inline int gfar_clean_tx_ring(struct net_device *dev)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct gfar_private *priv = netdev_priv(dev);
 	struct txbd8 *bdp;
+	struct gfar_private *priv = netdev_priv(dev);
+	int howmany = 0;
+	struct sk_buff* skb;
 
-	/* Clear IEVENT */
-	gfar_write(&priv->regs->ievent, IEVENT_TX_MASK);
-
-	/* Lock priv */
-	spin_lock(&priv->txlock);
 	bdp = priv->dirty_tx;
 	while ((bdp->status & TXBD_READY) == 0) {
 		/* If dirty_tx and cur_tx are the same, then either the */
@@ -1192,16 +1279,18 @@ static irqreturn_t gfar_transmit(int irq
 		/* obviously).  If it is empty, we are done. */
 		if ((bdp == priv->cur_tx) && (netif_queue_stopped(dev) == 0))
 			break;
-
-		priv->stats.tx_packets++;
-
+		howmany++;
+		
 		/* Deferred means some collisions occurred during transmit, */
 		/* but we eventually sent the packet. */
 		if (bdp->status & TXBD_DEF)
 			priv->stats.collisions++;
-
+		
 		/* Free the sk buffer associated with this TxBD */
-		dev_kfree_skb_irq(priv->tx_skbuff[priv->skb_dirtytx]);
+		skb = priv->tx_skbuff[priv->skb_dirtytx];
+
+		GFAR_KFREE_SKB(skb,priv->skbuff_truesize);
+
 		priv->tx_skbuff[priv->skb_dirtytx] = NULL;
 		priv->skb_dirtytx =
 		    (priv->skb_dirtytx +
@@ -1221,19 +1310,144 @@ static irqreturn_t gfar_transmit(int irq
 			netif_wake_queue(dev);
 	} /* while ((bdp->status & TXBD_READY) == 0) */
 
+	priv->stats.tx_packets += howmany;
+
+	return howmany;
+}
+
+
+/* Interrupt Handler for Transmit complete */
+static irqreturn_t gfar_transmit(int irq, void *dev_id, struct pt_regs *regs) {
+	struct net_device *dev = (struct net_device *) dev_id;
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* Clear IEVENT */
+	gfar_write(&priv->regs->ievent, IEVENT_TX_MASK);
+
+	/* Lock priv */
+	spin_lock(&priv->txlock);
+
+	gfar_clean_tx_ring(dev);
+
 	/* If we are coalescing the interrupts, reset the timer */
-	/* Otherwise, clear it */
-	if (priv->txcoalescing)
-		gfar_write(&priv->regs->txic,
-			   mk_ic_value(priv->txcount, priv->txtime));
-	else
-		gfar_write(&priv->regs->txic, 0);
+	gfar_write(&priv->regs->txic, 0);
+	gfar_write(&priv->regs->txic, priv->txic);
 
 	spin_unlock(&priv->txlock);
-
 	return IRQ_HANDLED;
 }
 
+
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct sk_buff *skb = NULL;
+	unsigned int timeout = SKB_ALLOC_TIMEOUT;
+	unsigned long flags = 0;
+
+	struct gfar_skb_handler* sh = &__get_cpu_var(gfar_skb_handler);
+
+	spin_lock_irqsave(sh->lock, flags);
+	if (sh->recycle_queue) {
+		unsigned int size;
+		int truesize;
+		/* pick one from head; most recent one */
+		skb = sh->recycle_queue;
+		sh->recycle_queue = skb->next;
+		sh->recycle_count--;
+		spin_unlock_irqrestore(sh->lock, flags);
+		
+		/* re-initialization
+		 *  We are not going to touch the buffer size, so
+		 *  skb->truesize can be used as the truesize again
+		 */
+ 		truesize = skb->truesize;
+		
+		size = SKB_DATA_ALIGN(priv->rx_buffer_size + RXBUF_ALIGNMENT +
+				      GFAR_SKB_USER_OPT_HEADROOM);
+		/* clear structure by &truesize */
+		memset(skb, 0, offsetof(struct sk_buff, truesize));
+		atomic_set(&skb->users, 1);
+		/* reserve for optimization. Comply to __dev_alloc_skb() */
+		skb->data = skb->head + GFAR_SKB_USER_OPT_HEADROOM;
+		skb->tail = skb->head + GFAR_SKB_USER_OPT_HEADROOM;
+		skb->end  = skb->head + size;
+		
+		/* shared info clean up */
+		atomic_set(&(skb_shinfo(skb)->dataref), 1);
+		skb_shinfo(skb)->nr_frags  = 0;
+		skb_shinfo(skb)->tso_size = 0;
+		skb_shinfo(skb)->tso_segs = 0;
+		skb_shinfo(skb)->frag_list = NULL;
+		
+	} else {
+		spin_unlock_irqrestore(sh->lock, flags);
+		while ((!skb) && timeout--)
+			skb = dev_alloc_skb(priv->rx_buffer_size + RXBUF_ALIGNMENT);
+		/* We have to allocate the skb, so keep trying till we succeed */
+		if (skb == NULL)
+			return NULL;
+
+		/* Activate this code if you want to know the recycle backlog*/
+		/* printk("newly alloc: count=%d\n",sh->recycle_count); */
+
+	}
+	
+	/* We need the data buffer to be aligned properly.  We will reserve
+	 * as many bytes as needed to align the data properly
+	 */
+	if (RXBUF_ALIGNMENT != 0)
+		skb_reserve(skb,
+		    RXBUF_ALIGNMENT -
+		    (((unsigned) skb->data) & (RXBUF_ALIGNMENT - 1)));
+	
+	skb->dev = dev;
+	
+	bdp->bufPtr = dma_map_single(NULL, skb->data,
+				     priv->rx_buffer_size,
+				     DMA_FROM_DEVICE);
+	
+	bdp->length = 0;
+	
+	/* Mark the buffer empty */
+	bdp->status |= (RXBD_EMPTY | RXBD_INTERRUPT);
+	
+	return skb;
+}
+
+static inline void gfar_kfree_skb(struct sk_buff *skb,
+				  unsigned long int recyclable) {
+	if ((skb->truesize >= recyclable)&&
+	    (!skb->destructor) && (!skb->cloned)) {
+		if (atomic_dec_and_test(&skb->users)) {
+			struct gfar_skb_handler *sh;
+			unsigned long flags = 0;
+			sh = &__get_cpu_var(gfar_skb_handler);
+			spin_lock_irqsave(sh->lock, flags);
+			if (likely(sh->recycle_count < sh->recycle_max)) {
+				sh->recycle_count++;
+				skb->next = sh->recycle_queue;
+				sh->recycle_queue = skb;
+			} else {
+				struct softnet_data *sd;
+				sd = &__get_cpu_var(softnet_data);
+				skb->next = sd->completion_queue;
+				sd->completion_queue = skb;
+				raise_softirq_irqoff(NET_TX_SOFTIRQ);
+			}
+			spin_unlock_irqrestore(sh->lock, flags);
+		}
+	} else {
+		/* skb is not recyclable */
+		dev_kfree_skb_any(skb);
+	}
+}
+
+#else
+/*
+ * normal new skb routine
+ */
 struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 {
 	unsigned int alignamount;
@@ -1259,7 +1473,8 @@ struct sk_buff * gfar_new_skb(struct net
 	skb->dev = dev;
 
 	bdp->bufPtr = dma_map_single(NULL, skb->data,
-			priv->rx_buffer_size, DMA_FROM_DEVICE);
+				     priv->rx_buffer_size,
+				     DMA_FROM_DEVICE);
 
 	bdp->length = 0;
 
@@ -1268,6 +1483,7 @@ struct sk_buff * gfar_new_skb(struct net
 
 	return skb;
 }
+#endif /*CONFIG_GFAR_SKBUFF_RECYCLING*/
 
 static inline void count_errors(unsigned short status, struct gfar_private *priv)
 {
@@ -1324,7 +1540,7 @@ #endif
 #ifdef CONFIG_GFAR_NAPI
 	if (netif_rx_schedule_prep(dev)) {
 		tempval = gfar_read(&priv->regs->imask);
-		tempval &= IMASK_RX_DISABLED;
+		tempval &= IMASK_NAPI_DISABLED;
 		gfar_write(&priv->regs->imask, tempval);
 
 		__netif_rx_schedule(dev);
@@ -1334,21 +1550,18 @@ #ifdef CONFIG_GFAR_NAPI
 				dev->name, gfar_read(&priv->regs->ievent),
 				gfar_read(&priv->regs->imask));
 	}
-#else
+#else /* CONFIG_GFAR_NAPI */
 
 	spin_lock_irqsave(&priv->rxlock, flags);
 	gfar_clean_rx_ring(dev, priv->rx_ring_size);
 
 	/* If we are coalescing interrupts, update the timer */
-	/* Otherwise, clear it */
+	gfar_write(&priv->regs->rxic, 0);
 	if (priv->rxcoalescing)
-		gfar_write(&priv->regs->rxic,
-			   mk_ic_value(priv->rxcount, priv->rxtime));
-	else
-		gfar_write(&priv->regs->rxic, 0);
+		gfar_write(&priv->regs->rxic, priv->rxic);
 
 	spin_unlock_irqrestore(&priv->rxlock, flags);
-#endif
+#endif /* CONFIG_GFAR_NAPI */
 
 	return IRQ_HANDLED;
 }
@@ -1509,8 +1722,11 @@ static int gfar_poll(struct net_device *
 	if (rx_work_limit > dev->quota)
 		rx_work_limit = dev->quota;
 
+
 	howmany = gfar_clean_rx_ring(dev, rx_work_limit);
 
+	gfar_clean_tx_ring(dev);
+
 	dev->quota -= howmany;
 	rx_work_limit -= howmany;
 	*budget -= howmany;
@@ -1521,15 +1737,14 @@ static int gfar_poll(struct net_device *
 		/* Clear the halt bit in RSTAT */
 		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
 
-		gfar_write(&priv->regs->imask, IMASK_DEFAULT);
-
 		/* If we are coalescing interrupts, update the timer */
 		/* Otherwise, clear it */
+		gfar_write(&priv->regs->rxic, 0);
 		if (priv->rxcoalescing)
-			gfar_write(&priv->regs->rxic,
-				   mk_ic_value(priv->rxcount, priv->rxtime));
-		else
-			gfar_write(&priv->regs->rxic, 0);
+			gfar_write(&priv->regs->rxic, priv->rxic);
+
+		gfar_write(&priv->regs->imask, IMASK_DEFAULT);
+
 	}
 
 	/* Return 1 if there's more work to do */
@@ -1542,6 +1757,7 @@ static irqreturn_t gfar_interrupt(int ir
 {
 	struct net_device *dev = dev_id;
 	struct gfar_private *priv = netdev_priv(dev);
+	unsigned long tempval;
 
 	/* Save ievent for future reference */
 	u32 events = gfar_read(&priv->regs->ievent);
@@ -1567,13 +1783,19 @@ static irqreturn_t gfar_interrupt(int ir
 			priv->stats.tx_aborted_errors++;
 		if (events & IEVENT_XFUN) {
 			if (netif_msg_tx_err(priv))
-				printk(KERN_WARNING "%s: tx underrun. dropped packet\n", dev->name);
+				printk(KERN_WARNING
+				       "%s: tx underrun. dropped packet\n",
+				       dev->name);
 			priv->stats.tx_dropped++;
 			priv->extra_stats.tx_underrun++;
 
 			/* Reactivate the Tx Queues */
 			gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
 		}
+		/* Make sure we aren't stopped */
+		tempval = gfar_read(&priv->regs->dmactrl);
+		tempval &= ~(DMACTRL_GRS | DMACTRL_GTS);
+		gfar_write(&priv->regs->dmactrl, tempval);
 	}
 	if (events & IEVENT_BSY) {
 		priv->stats.rx_errors++;
@@ -1600,6 +1822,8 @@ #endif
 	}
 	if (events & IEVENT_EBERR) {
 		priv->extra_stats.eberr++;
+		/* Reactivate the Tx Queues */
+		gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
 		if (netif_msg_rx_err(priv))
 			printk(KERN_DEBUG "%s: EBERR\n", dev->name);
 	}
@@ -1668,8 +1892,9 @@ static void adjust_link(struct net_devic
 			default:
 				if (netif_msg_link(priv))
 					printk(KERN_WARNING
-						"%s: Ack!  Speed (%d) is not 10/100/1000!\n",
-						dev->name, phydev->speed);
+					       "%s: Ack!  Speed (%d) is "
+					       "not 10/100/1000!\n",
+					       dev->name, phydev->speed);
 				break;
 			}
 
@@ -1958,7 +2183,9 @@ static int __init gfar_init(void)
 
 	if (err)
 		gfar_mdio_exit();
-	
+
+	on_each_cpu(gfar_reset_skb_handler, NULL, 0, 1);
+
 	return err;
 }
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 127c98c..31c788a 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -6,6 +6,7 @@
  * Based on 8260_io/fcc_enet.c
  *
  * Author: Andy Fleming
+ *         Dai Haruki
  * Maintainer: Kumar Gala
  *
  * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
@@ -51,7 +52,7 @@ #include <linux/fsl_devices.h>
 #include "gianfar_mii.h"
 
 /* The maximum number of packets to be handled in one call of gfar_poll */
-#define GFAR_DEV_WEIGHT 64
+#define GFAR_DEV_WEIGHT 16
 
 /* Length for FCB */
 #define GMAC_FCB_LEN 8
@@ -62,6 +63,8 @@ #define DEFAULT_PADDING 2
 /* Number of bytes to align the rx bufs to */
 #define RXBUF_ALIGNMENT 64
 
+#define GFAR_SKB_USER_OPT_HEADROOM 16
+
 /* The number of bytes which composes a unit for the purpose of
  * allocating data buffers.  ie-for any given MTU, the data buffer
  * will be the next highest multiple of 512 bytes. */
@@ -73,15 +76,15 @@ #define MAC_ADDR_LEN 6
 #define PHY_INIT_TIMEOUT 100000
 #define GFAR_PHY_CHANGE_TIME 2
 
-#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.2, "
+#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.4, "
 #define DRV_NAME "gfar-enet"
 extern const char gfar_driver_name[];
 extern const char gfar_driver_version[];
 
 /* These need to be powers of 2 for this driver */
 #ifdef CONFIG_GFAR_NAPI
-#define DEFAULT_TX_RING_SIZE	256
-#define DEFAULT_RX_RING_SIZE	256
+#define DEFAULT_TX_RING_SIZE	64
+#define DEFAULT_RX_RING_SIZE	64
 #else
 #define DEFAULT_TX_RING_SIZE    64
 #define DEFAULT_RX_RING_SIZE    64
@@ -101,10 +104,10 @@ #define JUMBO_BUFFER_SIZE 9728
 #define JUMBO_FRAME_SIZE 9600
 
 #define DEFAULT_FIFO_TX_THR 0x100
-#define DEFAULT_FIFO_TX_STARVE 0x40
-#define DEFAULT_FIFO_TX_STARVE_OFF 0x80
+#define DEFAULT_FIFO_TX_STARVE 0x80
+#define DEFAULT_FIFO_TX_STARVE_OFF 0x100
 #define DEFAULT_BD_STASH 1
-#define DEFAULT_STASH_LENGTH	64
+#define DEFAULT_STASH_LENGTH	96
 #define DEFAULT_STASH_INDEX	0
 
 /* The number of Exact Match registers */
@@ -125,12 +128,12 @@ #define GFAR_100_TIME   2560
 #define GFAR_10_TIME    25600
 
 #define DEFAULT_TX_COALESCE 1
-#define DEFAULT_TXCOUNT	16
-#define DEFAULT_TXTIME	4
+#define DEFAULT_TXCOUNT	24
+#define DEFAULT_TXTIME	64
 
 #define DEFAULT_RX_COALESCE 1
-#define DEFAULT_RXCOUNT	16
-#define DEFAULT_RXTIME	4
+#define DEFAULT_RXCOUNT	2
+#define DEFAULT_RXTIME	64
 
 #define TBIPA_VALUE		0x1f
 #define MIIMCFG_INIT_VALUE	0x00000007
@@ -235,6 +238,7 @@ #define IEVENT_DPE		0x00000002
 #define IEVENT_PERR		0x00000001
 #define IEVENT_RX_MASK          (IEVENT_RXB0 | IEVENT_RXF0)
 #define IEVENT_TX_MASK          (IEVENT_TXB | IEVENT_TXF)
+#define IEVENT_RTX_MASK         (IEVENT_RX_MASK | IEVENT_TX_MASK)
 #define IEVENT_ERR_MASK         \
 (IEVENT_RXC | IEVENT_BSY | IEVENT_EBERR | IEVENT_MSRO | \
  IEVENT_BABT | IEVENT_TXC | IEVENT_TXE | IEVENT_LC \
@@ -262,11 +266,11 @@ #define IMASK_FIR		0x00000008
 #define IMASK_FIQ		0x00000004
 #define IMASK_DPE		0x00000002
 #define IMASK_PERR		0x00000001
-#define IMASK_RX_DISABLED ~(IMASK_RXFEN0 | IMASK_BSY)
-#define IMASK_DEFAULT  (IMASK_TXEEN | IMASK_TXFEN | IMASK_TXBEN | \
+#define IMASK_NAPI_DISABLED ~(IMASK_RXFEN0 | IMASK_BSY | IMASK_TXFEN)
+#define IMASK_DEFAULT  (IMASK_TXEEN | IMASK_TXFEN | \
 		IMASK_RXFEN0 | IMASK_BSY | IMASK_EBERR | IMASK_BABR | \
-		IMASK_XFUN | IMASK_RXC | IMASK_BABT | IMASK_DPE \
-		| IMASK_PERR)
+		IMASK_XFUN | IMASK_RXC | IMASK_BABT | \
+		IMASK_DPE | IMASK_PERR)
 
 /* Fifo management */
 #define FIFO_TX_THR_MASK	0x01ff
@@ -691,6 +695,13 @@ struct gfar_private {
 	unsigned char rxcoalescing;
 	unsigned short rxcount;
 	unsigned short rxtime;
+	unsigned long txic;
+	unsigned long rxic;
+	/* Buffer size for Advanced SKB Handling */
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+	unsigned long skbuff_truesize;
+	unsigned long skbuff_buffsize;
+#endif
 
 	struct rxbd8 *rx_bd_base;	/* First Rx buffers */
 	struct rxbd8 *cur_rx;           /* Next free rx ring entry */
@@ -765,4 +776,23 @@ extern void gfar_phy_test(struct mii_bus
 		int enable, u32 regnum, u32 read);
 void gfar_init_sysfs(struct net_device *dev);
 
+
+#ifdef CONFIG_GFAR_SKBUFF_RECYCLING
+#define GFAR_RECYCLE_MAX 64
+struct gfar_skb_handler {
+	spinlock_t		lock;
+	long int                recycle_max;
+	long int                recycle_count; /* should be atomic */
+	struct sk_buff		*recycle_queue;
+};
+
+DECLARE_PER_CPU(struct gfar_skb_handler, gfar_skb_handler);
+
+#define GFAR_KFREE_SKB(skb,size) gfar_kfree_skb( skb, size )
+
+#else /*CONFIG_GFAR_SKBUFF_RECYCLING*/
+/* use dev_kfree_skb_irq directly */
+#define GFAR_KFREE_SKB(skb,arg...) dev_kfree_skb_irq( skb )
+#endif  /*CONFIG_GFAR_SKBUFF_RECYCLING*/
+
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index d69698c..026f07c 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -363,6 +363,10 @@ static int gfar_scoalesce(struct net_dev
 
 	priv->rxtime = gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs);
 	priv->rxcount = cvals->rx_max_coalesced_frames;
+	if (priv->rxcoalescing)
+		priv->rxic = mk_ic_value(priv->rxcount, priv->rxtime);
+	else
+		priv->rxic = 0;
 
 	/* Set up tx coalescing */
 	if ((cvals->tx_coalesce_usecs == 0) ||
@@ -371,6 +375,11 @@ static int gfar_scoalesce(struct net_dev
 	else
 		priv->txcoalescing = 1;
 
+	if (priv->txcoalescing)
+		priv->txic = mk_ic_value(priv->txcount, priv->txtime);
+	else
+		priv->txic = 0;
+	
 	/* Check the bounds of the values */
 	if (cvals->tx_coalesce_usecs > GFAR_MAX_COAL_USECS) {
 		pr_info("Coalescing is limited to %d microseconds\n",
@@ -387,17 +396,11 @@ static int gfar_scoalesce(struct net_dev
 	priv->txtime = gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs);
 	priv->txcount = cvals->tx_max_coalesced_frames;
 
-	if (priv->rxcoalescing)
-		gfar_write(&priv->regs->rxic,
-			   mk_ic_value(priv->rxcount, priv->rxtime));
-	else
-		gfar_write(&priv->regs->rxic, 0);
+	gfar_write(&priv->regs->rxic, 0);
+	gfar_write(&priv->regs->rxic, priv->rxic);
 
-	if (priv->txcoalescing)
-		gfar_write(&priv->regs->txic,
-			   mk_ic_value(priv->txcount, priv->txtime));
-	else
-		gfar_write(&priv->regs->txic, 0);
+	gfar_write(&priv->regs->txic, 0);
+	gfar_write(&priv->regs->txic, priv->txic);
 
 	return 0;
 }
-- 
1.3.1.g7464-dirty
