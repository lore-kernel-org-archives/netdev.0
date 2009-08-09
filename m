From: Wan ZongShun <mcuos.com@gmail.com>
Subject: [PATCH v3] Add support for w90p910 mac driver
Date: Sun, 09 Aug 2009 21:06:19 +0800
Message-ID: <4A7EC9CB.5060106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:30867 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbZHINGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2009 09:06:24 -0400
Received: by rv-out-0506.google.com with SMTP id f6so778098rvb.1
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2009 06:06:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,

I fixed up my mac driver, which relatives to previous
mac driver actually in the tree.

Thanks a lot for your help!

Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>

---
 drivers/net/arm/w90p910_ether.c |  206 +++++++++++++++++++++------------------
 1 files changed, 112 insertions(+), 94 deletions(-)

diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 616fb79..890716f 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -143,16 +143,17 @@ struct recv_pdesc {
 
 struct tran_pdesc {
 	struct w90p910_txbd desclist[TX_DESC_SIZE];
-	char tran_buf[RX_DESC_SIZE][MAX_TBUFF_SZ];
+	char tran_buf[TX_DESC_SIZE][MAX_TBUFF_SZ];
 };
 
 struct  w90p910_ether {
 	struct recv_pdesc *rdesc;
-	struct recv_pdesc *rdesc_phys;
 	struct tran_pdesc *tdesc;
-	struct tran_pdesc *tdesc_phys;
+	dma_addr_t rdesc_phys;
+	dma_addr_t tdesc_phys;
 	struct net_device_stats stats;
 	struct platform_device *pdev;
+	struct resource *res;
 	struct sk_buff *skb;
 	struct clk *clk;
 	struct clk *rmiiclk;
@@ -169,7 +170,6 @@ struct  w90p910_ether {
 	unsigned int start_tx_ptr;
 	unsigned int start_rx_ptr;
 	unsigned int linkflag;
-	spinlock_t lock;
 };
 
 static void update_linkspeed_register(struct net_device *dev,
@@ -275,59 +275,75 @@ static void w90p910_write_cam(struct net_device *dev,
 	__raw_writel(msw, ether->reg + REG_CAMM_BASE + x * CAM_ENTRY_SIZE);
 }
 
-static void w90p910_init_desc(struct net_device *dev)
+static int w90p910_init_desc(struct net_device *dev)
 {
 	struct w90p910_ether *ether;
-	struct w90p910_txbd  *tdesc, *tdesc_phys;
-	struct w90p910_rxbd  *rdesc, *rdesc_phys;
-	unsigned int i, j;
+	struct w90p910_txbd  *tdesc;
+	struct w90p910_rxbd  *rdesc;
+	struct platform_device *pdev;
+	unsigned int i;
 
 	ether = netdev_priv(dev);
+	pdev = ether->pdev;
 
 	ether->tdesc = (struct tran_pdesc *)
-			dma_alloc_coherent(NULL, sizeof(struct tran_pdesc),
-				(dma_addr_t *) &ether->tdesc_phys, GFP_KERNEL);
+		dma_alloc_coherent(&pdev->dev, sizeof(struct tran_pdesc),
+					&ether->tdesc_phys, GFP_KERNEL);
+
+	if (!ether->tdesc) {
+		dev_err(&pdev->dev, "Failed to allocate memory for tx desc\n");
+		return -ENOMEM;
+	}
 
 	ether->rdesc = (struct recv_pdesc *)
-			dma_alloc_coherent(NULL, sizeof(struct recv_pdesc),
-				(dma_addr_t *) &ether->rdesc_phys, GFP_KERNEL);
+		dma_alloc_coherent(&pdev->dev, sizeof(struct recv_pdesc),
+					&ether->rdesc_phys, GFP_KERNEL);
+
+	if (!ether->rdesc) {
+		dev_err(&pdev->dev, "Failed to allocate memory for rx desc\n");
+		dma_free_coherent(&pdev->dev, sizeof(struct tran_pdesc),
+					ether->tdesc, ether->tdesc_phys);
+		return -ENOMEM;
+	}
 
 	for (i = 0; i < TX_DESC_SIZE; i++) {
-		tdesc = &(ether->tdesc->desclist[i]);
+		unsigned int offset;
 
-		j = ((i + 1) / TX_DESC_SIZE);
+		tdesc = &(ether->tdesc->desclist[i]);
 
-		if (j != 0) {
-			tdesc_phys = &(ether->tdesc_phys->desclist[0]);
-			ether->start_tx_ptr = (unsigned int)tdesc_phys;
-			tdesc->next = (unsigned int)ether->start_tx_ptr;
-		} else {
-			tdesc_phys = &(ether->tdesc_phys->desclist[i+1]);
-			tdesc->next = (unsigned int)tdesc_phys;
-		}
+		if (i == TX_DESC_SIZE - 1)
+			offset = offsetof(struct tran_pdesc, desclist[0]);
+		else
+			offset = offsetof(struct tran_pdesc, desclist[i + 1]);
 
-		tdesc->buffer = (unsigned int)ether->tdesc_phys->tran_buf[i];
+		tdesc->next = ether->tdesc_phys + offset;
+		tdesc->buffer = ether->tdesc_phys +
+			offsetof(struct tran_pdesc, tran_buf[i]);
 		tdesc->sl = 0;
 		tdesc->mode = 0;
 	}
 
+	ether->start_tx_ptr = ether->tdesc_phys;
+
 	for (i = 0; i < RX_DESC_SIZE; i++) {
-		rdesc = &(ether->rdesc->desclist[i]);
+		unsigned int offset;
 
-		j = ((i + 1) / RX_DESC_SIZE);
+		rdesc = &(ether->rdesc->desclist[i]);
 
-		if (j != 0) {
-			rdesc_phys = &(ether->rdesc_phys->desclist[0]);
-			ether->start_rx_ptr = (unsigned int)rdesc_phys;
-			rdesc->next = (unsigned int)ether->start_rx_ptr;
-		} else {
-			rdesc_phys = &(ether->rdesc_phys->desclist[i+1]);
-			rdesc->next = (unsigned int)rdesc_phys;
-		}
+		if (i == RX_DESC_SIZE - 1)
+			offset = offsetof(struct recv_pdesc, desclist[0]);
+		else
+			offset = offsetof(struct recv_pdesc, desclist[i + 1]);
 
+		rdesc->next = ether->rdesc_phys + offset;
 		rdesc->sl = RX_OWEN_DMA;
-		rdesc->buffer = (unsigned int)ether->rdesc_phys->recv_buf[i];
+		rdesc->buffer = ether->rdesc_phys +
+			offsetof(struct recv_pdesc, recv_buf[i]);
 	  }
+
+	ether->start_rx_ptr = ether->rdesc_phys;
+
+	return 0;
 }
 
 static void w90p910_set_fifo_threshold(struct net_device *dev)
@@ -456,8 +472,6 @@ static void w90p910_reset_mac(struct net_device *dev)
 {
 	struct w90p910_ether *ether = netdev_priv(dev);
 
-	spin_lock(&ether->lock);
-
 	w90p910_enable_tx(dev, 0);
 	w90p910_enable_rx(dev, 0);
 	w90p910_set_fifo_threshold(dev);
@@ -486,8 +500,6 @@ static void w90p910_reset_mac(struct net_device *dev)
 
 	if (netif_queue_stopped(dev))
 		netif_wake_queue(dev);
-
-	spin_unlock(&ether->lock);
 }
 
 static void w90p910_mdio_write(struct net_device *dev,
@@ -541,7 +553,7 @@ static int w90p910_mdio_read(struct net_device *dev, int phy_id, int reg)
 	return data;
 }
 
-static int set_mac_address(struct net_device *dev, void *addr)
+static int w90p910_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *address = addr;
 
@@ -557,11 +569,14 @@ static int set_mac_address(struct net_device *dev, void *addr)
 static int w90p910_ether_close(struct net_device *dev)
 {
 	struct w90p910_ether *ether = netdev_priv(dev);
+	struct platform_device *pdev;
 
-	dma_free_writecombine(NULL, sizeof(struct w90p910_rxbd),
-				ether->rdesc, (dma_addr_t)ether->rdesc_phys);
-	dma_free_writecombine(NULL, sizeof(struct w90p910_txbd),
-				ether->tdesc, (dma_addr_t)ether->tdesc_phys);
+	pdev = ether->pdev;
+
+	dma_free_coherent(&pdev->dev, sizeof(struct recv_pdesc),
+					ether->rdesc, ether->rdesc_phys);
+	dma_free_coherent(&pdev->dev, sizeof(struct tran_pdesc),
+					ether->tdesc, ether->tdesc_phys);
 
 	netif_stop_queue(dev);
 
@@ -597,6 +612,7 @@ static int w90p910_send_frame(struct net_device *dev,
 
 	txbd = &ether->tdesc->desclist[ether->cur_tx];
 	buffer = ether->tdesc->tran_buf[ether->cur_tx];
+
 	if (length > 1514) {
 		dev_err(&pdev->dev, "send data %d bytes, check it\n", length);
 		length = 1514;
@@ -612,7 +628,9 @@ static int w90p910_send_frame(struct net_device *dev,
 
 	w90p910_trigger_tx(dev);
 
-	ether->cur_tx = (ether->cur_tx+1) % TX_DESC_SIZE;
+	if (++ether->cur_tx >= TX_DESC_SIZE)
+		ether->cur_tx = 0;
+
 	txbd = &ether->tdesc->desclist[ether->cur_tx];
 
 	dev->trans_start = jiffies;
@@ -632,7 +650,7 @@ static int w90p910_ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb_irq(skb);
 		return 0;
 	}
-	return -1;
+	return -EAGAIN;
 }
 
 static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
@@ -640,27 +658,25 @@ static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
 	struct w90p910_ether *ether;
 	struct w90p910_txbd  *txbd;
 	struct platform_device *pdev;
-	struct tran_pdesc *tran_pdesc;
 	struct net_device *dev;
 	unsigned int cur_entry, entry, status;
 
-	dev = (struct net_device *)dev_id;
+	dev = dev_id;
 	ether = netdev_priv(dev);
 	pdev = ether->pdev;
 
-	spin_lock(&ether->lock);
-
 	w90p910_get_and_clear_int(dev, &status);
 
 	cur_entry = __raw_readl(ether->reg + REG_CTXDSA);
 
-	tran_pdesc = ether->tdesc_phys;
-	entry = (unsigned int)(&tran_pdesc->desclist[ether->finish_tx]);
+	entry = ether->tdesc_phys +
+		offsetof(struct tran_pdesc, desclist[ether->finish_tx]);
 
 	while (entry != cur_entry) {
 		txbd = &ether->tdesc->desclist[ether->finish_tx];
 
-		ether->finish_tx = (ether->finish_tx + 1) % TX_DESC_SIZE;
+		if (++ether->finish_tx >= TX_DESC_SIZE)
+			ether->finish_tx = 0;
 
 		if (txbd->sl & TXDS_TXCP) {
 			ether->stats.tx_packets++;
@@ -675,20 +691,19 @@ static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
 		if (netif_queue_stopped(dev))
 			netif_wake_queue(dev);
 
-		entry = (unsigned int)(&tran_pdesc->desclist[ether->finish_tx]);
+		entry = ether->tdesc_phys +
+			offsetof(struct tran_pdesc, desclist[ether->finish_tx]);
 	}
 
 	if (status & MISTA_EXDEF) {
 		dev_err(&pdev->dev, "emc defer exceed interrupt\n");
 	} else if (status & MISTA_TXBERR) {
-			dev_err(&pdev->dev, "emc bus error interrupt\n");
-			w90p910_reset_mac(dev);
-		} else if (status & MISTA_TDU) {
-				if (netif_queue_stopped(dev))
-					netif_wake_queue(dev);
-			}
-
-	spin_unlock(&ether->lock);
+		dev_err(&pdev->dev, "emc bus error interrupt\n");
+		w90p910_reset_mac(dev);
+	} else if (status & MISTA_TDU) {
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -698,20 +713,20 @@ static void netdev_rx(struct net_device *dev)
 	struct w90p910_ether *ether;
 	struct w90p910_rxbd *rxbd;
 	struct platform_device *pdev;
-	struct recv_pdesc *rdesc_phys;
 	struct sk_buff *skb;
 	unsigned char *data;
 	unsigned int length, status, val, entry;
 
 	ether = netdev_priv(dev);
 	pdev = ether->pdev;
-	rdesc_phys = ether->rdesc_phys;
 
 	rxbd = &ether->rdesc->desclist[ether->cur_rx];
 
 	do {
 		val = __raw_readl(ether->reg + REG_CRXDSA);
-		entry = (unsigned int)&rdesc_phys->desclist[ether->cur_rx];
+
+		entry = ether->rdesc_phys +
+			offsetof(struct recv_pdesc, desclist[ether->cur_rx]);
 
 		if (val == entry)
 			break;
@@ -743,22 +758,23 @@ static void netdev_rx(struct net_device *dev)
 				dev_err(&pdev->dev, "rx runt err\n");
 				ether->stats.rx_length_errors++;
 			} else if (status & RXDS_CRCE) {
-					dev_err(&pdev->dev, "rx crc err\n");
-					ether->stats.rx_crc_errors++;
-				}
-
-			if (status & RXDS_ALIE) {
+				dev_err(&pdev->dev, "rx crc err\n");
+				ether->stats.rx_crc_errors++;
+			} else if (status & RXDS_ALIE) {
 				dev_err(&pdev->dev, "rx aligment err\n");
 				ether->stats.rx_frame_errors++;
 			} else if (status & RXDS_PTLE) {
-					dev_err(&pdev->dev, "rx longer err\n");
-					ether->stats.rx_over_errors++;
-				}
+				dev_err(&pdev->dev, "rx longer err\n");
+				ether->stats.rx_over_errors++;
 			}
+		}
 
 		rxbd->sl = RX_OWEN_DMA;
 		rxbd->reserved = 0x0;
-		ether->cur_rx = (ether->cur_rx+1) % RX_DESC_SIZE;
+
+		if (++ether->cur_rx >= RX_DESC_SIZE)
+			ether->cur_rx = 0;
+
 		rxbd = &ether->rdesc->desclist[ether->cur_rx];
 
 		dev->last_rx = jiffies;
@@ -772,28 +788,23 @@ static irqreturn_t w90p910_rx_interrupt(int irq, void *dev_id)
 	struct platform_device *pdev;
 	unsigned int status;
 
-	dev = (struct net_device *)dev_id;
+	dev = dev_id;
 	ether = netdev_priv(dev);
 	pdev = ether->pdev;
 
-	spin_lock(&ether->lock);
-
 	w90p910_get_and_clear_int(dev, &status);
 
 	if (status & MISTA_RDU) {
 		netdev_rx(dev);
-
 		w90p910_trigger_rx(dev);
 
-		spin_unlock(&ether->lock);
 		return IRQ_HANDLED;
 	} else if (status & MISTA_RXBERR) {
-			dev_err(&pdev->dev, "emc rx bus error\n");
-			w90p910_reset_mac(dev);
-		}
+		dev_err(&pdev->dev, "emc rx bus error\n");
+		w90p910_reset_mac(dev);
+	}
 
 	netdev_rx(dev);
-	spin_unlock(&ether->lock);
 	return IRQ_HANDLED;
 }
 
@@ -826,6 +837,7 @@ static int w90p910_ether_open(struct net_device *dev)
 	if (request_irq(ether->rxirq, w90p910_rx_interrupt,
 						0x0, pdev->name, dev)) {
 		dev_err(&pdev->dev, "register irq rx failed\n");
+		free_irq(ether->txirq, dev);
 		return -EAGAIN;
 	}
 
@@ -908,7 +920,7 @@ static const struct net_device_ops w90p910_ether_netdev_ops = {
 	.ndo_start_xmit		= w90p910_ether_start_xmit,
 	.ndo_get_stats		= w90p910_ether_stats,
 	.ndo_set_multicast_list	= w90p910_ether_set_multicast_list,
-	.ndo_set_mac_address	= set_mac_address,
+	.ndo_set_mac_address	= w90p910_set_mac_address,
 	.ndo_do_ioctl		= w90p910_ether_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
@@ -949,8 +961,6 @@ static int w90p910_ether_setup(struct net_device *dev)
 
 	get_mac_address(dev);
 
-	spin_lock_init(&ether->lock);
-
 	ether->cur_tx = 0x0;
 	ether->cur_rx = 0x0;
 	ether->finish_tx = 0x0;
@@ -972,30 +982,29 @@ static int __devinit w90p910_ether_probe(struct platform_device *pdev)
 {
 	struct w90p910_ether *ether;
 	struct net_device *dev;
-	struct resource *res;
 	int error;
 
 	dev = alloc_etherdev(sizeof(struct w90p910_ether));
 	if (!dev)
 		return -ENOMEM;
 
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res == NULL) {
+	ether = netdev_priv(dev);
+
+	ether->res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (ether->res == NULL) {
 		dev_err(&pdev->dev, "failed to get I/O memory\n");
 		error = -ENXIO;
 		goto failed_free;
 	}
 
-	res = request_mem_region(res->start, resource_size(res), pdev->name);
-	if (res == NULL) {
+	if (!request_mem_region(ether->res->start,
+				resource_size(ether->res), pdev->name)) {
 		dev_err(&pdev->dev, "failed to request I/O memory\n");
 		error = -EBUSY;
 		goto failed_free;
 	}
 
-	ether = netdev_priv(dev);
-
-	ether->reg = ioremap(res->start, resource_size(res));
+	ether->reg = ioremap(ether->res->start, resource_size(ether->res));
 	if (ether->reg == NULL) {
 		dev_err(&pdev->dev, "failed to remap I/O memory\n");
 		error = -ENXIO;
@@ -1056,7 +1065,7 @@ failed_free_txirq:
 failed_free_io:
 	iounmap(ether->reg);
 failed_free_mem:
-	release_mem_region(res->start, resource_size(res));
+	release_mem_region(ether->res->start, resource_size(ether->res));
 failed_free:
 	free_netdev(dev);
 	return error;
@@ -1068,10 +1077,19 @@ static int __devexit w90p910_ether_remove(struct platform_device *pdev)
 	struct w90p910_ether *ether = netdev_priv(dev);
 
 	unregister_netdev(dev);
+
 	clk_put(ether->rmiiclk);
 	clk_put(ether->clk);
+
+	iounmap(ether->reg);
+	release_mem_region(ether->res->start, resource_size(ether->res));
+
+	free_irq(ether->txirq, dev);
+	free_irq(ether->rxirq, dev);
+
 	del_timer_sync(&ether->check_timer);
 	platform_set_drvdata(pdev, NULL);
+
 	free_netdev(dev);
 	return 0;
 }
-- 
1.5.6.3
