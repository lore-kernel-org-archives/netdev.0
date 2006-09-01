From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] skge: use NAPI for transmit complete
Date: Fri, 01 Sep 2006 15:53:49 -0700
Message-ID: <20060901225449.528280978@zqx3.pdx.osdl.net>
References: <20060901225346.750571061@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63886 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751113AbWIAW5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:57:34 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-tx-napi.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The skge driver has much better performance if transmit done is handled in
NAPI softirq. Change from doing transmit locking in driver (LLTX) and
use device lock.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- netdev-2.6.orig/drivers/net/skge.c
+++ netdev-2.6/drivers/net/skge.c
@@ -91,7 +91,7 @@ MODULE_DEVICE_TABLE(pci, skge_id_table);
 static int skge_up(struct net_device *dev);
 static int skge_down(struct net_device *dev);
 static void skge_phy_reset(struct skge_port *skge);
-static void skge_tx_clean(struct skge_port *skge);
+static void skge_tx_clean(struct net_device *dev);
 static int xm_phy_write(struct skge_hw *hw, int port, u16 reg, u16 val);
 static int gm_phy_write(struct skge_hw *hw, int port, u16 reg, u16 val);
 static void genesis_get_stats(struct skge_port *skge, u64 *data);
@@ -105,6 +105,7 @@ static const int txqaddr[] = { Q_XA1, Q_
 static const int rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 rxirqmask[] = { IS_R1_F, IS_R2_F };
 static const u32 txirqmask[] = { IS_XA1_F, IS_XA2_F };
+static const u32 irqmask[] = { IS_R1_F|IS_XA1_F, IS_R2_F|IS_XA2_F };
 
 static int skge_get_regs_len(struct net_device *dev)
 {
@@ -2283,7 +2284,7 @@ static int skge_down(struct net_device *
 	skge_led(skge, LED_MODE_OFF);
 
 	netif_poll_disable(dev);
-	skge_tx_clean(skge);
+	skge_tx_clean(dev);
 	skge_rx_clean(skge);
 
 	kfree(skge->rx_ring.start);
@@ -2308,25 +2309,12 @@ static int skge_xmit_frame(struct sk_buf
 	int i;
 	u32 control, len;
 	u64 map;
-	unsigned long flags;
 
 	if (skb_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
 
-	if (!spin_trylock_irqsave(&skge->tx_lock, flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-
-	if (unlikely(skge_avail(&skge->tx_ring) < skb_shinfo(skb)->nr_frags + 1)) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
-
-			printk(KERN_WARNING PFX "%s: ring full when queue awake!\n",
-			       dev->name);
-		}
-		spin_unlock_irqrestore(&skge->tx_lock, flags);
+	if (unlikely(skge_avail(&skge->tx_ring) < skb_shinfo(skb)->nr_frags + 1))
 		return NETDEV_TX_BUSY;
-	}
 
 	e = skge->tx_ring.to_use;
 	td = e->desc;
@@ -2401,8 +2389,6 @@ static int skge_xmit_frame(struct sk_buf
 		netif_stop_queue(dev);
 	}
 
-	spin_unlock_irqrestore(&skge->tx_lock, flags);
-
 	dev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
@@ -2432,18 +2418,18 @@ static void skge_tx_free(struct skge_por
 			printk(KERN_DEBUG PFX "%s: tx done slot %td\n",
 			       skge->netdev->name, e - skge->tx_ring.start);
 
-		dev_kfree_skb_any(e->skb);
+		dev_kfree_skb(e->skb);
 	}
 	e->skb = NULL;
 }
 
 /* Free all buffers in transmit ring */
-static void skge_tx_clean(struct skge_port *skge)
+static void skge_tx_clean(struct net_device *dev)
 {
+	struct skge_port *skge = netdev_priv(dev);
 	struct skge_element *e;
-	unsigned long flags;
 
-	spin_lock_irqsave(&skge->tx_lock, flags);
+	netif_tx_lock_bh(dev);
 	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
 		struct skge_tx_desc *td = e->desc;
 		skge_tx_free(skge, e, td->control);
@@ -2451,8 +2437,8 @@ static void skge_tx_clean(struct skge_po
 	}
 
 	skge->tx_ring.to_clean = e;
-	netif_wake_queue(skge->netdev);
-	spin_unlock_irqrestore(&skge->tx_lock, flags);
+	netif_wake_queue(dev);
+	netif_tx_unlock_bh(dev);
 }
 
 static void skge_tx_timeout(struct net_device *dev)
@@ -2463,7 +2449,7 @@ static void skge_tx_timeout(struct net_d
 		printk(KERN_DEBUG PFX "%s: tx timeout\n", dev->name);
 
 	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_STOP);
-	skge_tx_clean(skge);
+	skge_tx_clean(dev);
 }
 
 static int skge_change_mtu(struct net_device *dev, int new_mtu)
@@ -2679,15 +2665,15 @@ resubmit:
 }
 
 /* Free all buffers in Tx ring which are no longer owned by device */
-static void skge_txirq(struct net_device *dev)
+static void skge_tx_done(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_ring *ring = &skge->tx_ring;
 	struct skge_element *e;
 
-	rmb();
+	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
 
-	spin_lock(&skge->tx_lock);
+	netif_tx_lock(dev);
 	for (e = ring->to_clean; e != ring->to_use; e = e->next) {
 		struct skge_tx_desc *td = e->desc;
 
@@ -2698,11 +2684,10 @@ static void skge_txirq(struct net_device
 	}
 	skge->tx_ring.to_clean = e;
 
-	if (netif_queue_stopped(skge->netdev)
-	    && skge_avail(&skge->tx_ring) > TX_LOW_WATER)
-		netif_wake_queue(skge->netdev);
+	if (skge_avail(&skge->tx_ring) > TX_LOW_WATER)
+		netif_wake_queue(dev);
 
-	spin_unlock(&skge->tx_lock);
+	netif_tx_unlock(dev);
 }
 
 static int skge_poll(struct net_device *dev, int *budget)
@@ -2714,6 +2699,10 @@ static int skge_poll(struct net_device *
 	int to_do = min(dev->quota, *budget);
 	int work_done = 0;
 
+	skge_tx_done(dev);
+
+	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
+
 	for (e = ring->to_clean; prefetch(e->next), work_done < to_do; e = e->next) {
 		struct skge_rx_desc *rd = e->desc;
 		struct sk_buff *skb;
@@ -2744,10 +2733,9 @@ static int skge_poll(struct net_device *
 	if (work_done >=  to_do)
 		return 1; /* not done */
 
-	netif_rx_complete(dev);
-
 	spin_lock_irq(&hw->hw_lock);
-	hw->intr_mask |= rxirqmask[skge->port];
+	__netif_rx_complete(dev);
+	hw->intr_mask |= irqmask[skge->port];
   	skge_write32(hw, B0_IMSK, hw->intr_mask);
 	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
@@ -2906,14 +2894,8 @@ static irqreturn_t skge_intr(int irq, vo
 		schedule_work(&hw->phy_work);
 	}
 
-	if (status & IS_XA1_F) {
-		skge_write8(hw, Q_ADDR(Q_XA1, Q_CSR), CSR_IRQ_CL_F);
-		skge_txirq(hw->dev[0]);
-	}
-
-	if (status & IS_R1_F) {
-		skge_write8(hw, Q_ADDR(Q_R1, Q_CSR), CSR_IRQ_CL_F);
-		hw->intr_mask &= ~IS_R1_F;
+	if (status & (IS_XA1_F|IS_R1_F)) {
+		hw->intr_mask &= ~(IS_XA1_F|IS_R1_F);
 		netif_rx_schedule(hw->dev[0]);
 	}
 
@@ -2932,14 +2914,8 @@ static irqreturn_t skge_intr(int irq, vo
 		skge_mac_intr(hw, 0);
 
 	if (hw->dev[1]) {
-		if (status & IS_XA2_F) {
-			skge_write8(hw, Q_ADDR(Q_XA2, Q_CSR), CSR_IRQ_CL_F);
-			skge_txirq(hw->dev[1]);
-		}
-
-		if (status & IS_R2_F) {
-			skge_write8(hw, Q_ADDR(Q_R2, Q_CSR), CSR_IRQ_CL_F);
-			hw->intr_mask &= ~IS_R2_F;
+		if (status & (IS_XA2_F|IS_R2_F)) {
+			hw->intr_mask &= ~(IS_XA2_F|IS_R2_F);
 			netif_rx_schedule(hw->dev[1]);
 		}
 
@@ -3228,7 +3204,7 @@ static struct net_device *skge_devinit(s
 	dev->poll_controller = skge_netpoll;
 #endif
 	dev->irq = hw->pdev->irq;
-	dev->features = NETIF_F_LLTX;
+
 	if (highmem)
 		dev->features |= NETIF_F_HIGHDMA;
 
@@ -3250,8 +3226,6 @@ static struct net_device *skge_devinit(s
 
 	skge->port = port;
 
-	spin_lock_init(&skge->tx_lock);
-
 	if (hw->chip_id != CHIP_ID_GENESIS) {
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		skge->rx_csum = 1;
--- netdev-2.6.orig/drivers/net/skge.h
+++ netdev-2.6/drivers/net/skge.h
@@ -2417,7 +2417,6 @@ struct skge_port {
 	struct net_device    *netdev;
 	int		     port;
 
-	spinlock_t	     tx_lock;
 	struct skge_ring     tx_ring;
 	struct skge_ring     rx_ring;
 

--


-- 
VGER BF report: H 0.0797428
