From: Wan ZongShun <mcuos.com@gmail.com>
Subject: Re: [PATCH] Add mac driver for w90p910
Date: Thu, 23 Jul 2009 12:52:24 +0800
Message-ID: <4A67EC88.8010001@gmail.com>
References: <4A5F2329.9090901@gmail.com>	<20090720.074554.16551322.davem@davemloft.net>	<5d5443650907201049j19fac3a6k4f2be7599ad240db@mail.gmail.com> <20090720.105217.236487133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soni.trilok@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, eric.y.miao@gmail.com
To: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:41698 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbZGWEwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 00:52:31 -0400
Received: by rv-out-0506.google.com with SMTP id f6so189867rvb.1
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 21:52:31 -0700 (PDT)
In-Reply-To: <20090720.105217.236487133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear sirs,

I have to sent this patch third times and really didn't know why previous two mails
were held by arm-linux-kernel. but it look like sending linux-netdev is successful,
For any inconvenience caused, please forgive.

I fixed up previous mac driver and make a patch relative to it.

thanks for your help.

According to Russell's advice, I fixed up mac driver,
which relatives to previous mac driver patch, and the
evaluation board based on w90p910.

Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>

diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 7b5f315..890716f 100644
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
@@ -274,59 +275,75 @@ static void w90p910_write_cam(struct net_device *dev,
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
-				(dma_addr_t *)&ether->tdesc_phys, GFP_KERNEL);
+		dma_alloc_coherent(&pdev->dev, sizeof(struct tran_pdesc),
+					&ether->tdesc_phys, GFP_KERNEL);
+
+	if (!ether->tdesc) {
+		dev_err(&pdev->dev, "Failed to allocate memory for tx desc\n");
+		return -ENOMEM;
+	}
 
 	ether->rdesc = (struct recv_pdesc *)
-			dma_alloc_coherent(NULL, sizeof(struct recv_pdesc),
-				(dma_addr_t *)&ether->rdesc_phys, GFP_KERNEL);
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
@@ -552,11 +569,14 @@ static int w90p910_set_mac_address(struct net_device *dev, void *addr)
 static int w90p910_ether_close(struct net_device *dev)
 {
 	struct w90p910_ether *ether = netdev_priv(dev);
+	struct platform_device *pdev;
+
+	pdev = ether->pdev;
 
-	dma_free_writecombine(NULL, sizeof(struct w90p910_rxbd),
-				ether->rdesc, (dma_addr_t)ether->rdesc_phys);
-	dma_free_writecombine(NULL, sizeof(struct w90p910_txbd),
-				ether->tdesc, (dma_addr_t)ether->tdesc_phys);
+	dma_free_coherent(&pdev->dev, sizeof(struct recv_pdesc),
+					ether->rdesc, ether->rdesc_phys);
+	dma_free_coherent(&pdev->dev, sizeof(struct tran_pdesc),
+					ether->tdesc, ether->tdesc_phys);
 
 	netif_stop_queue(dev);
 
@@ -592,6 +612,7 @@ static int w90p910_send_frame(struct net_device *dev,
 
 	txbd = &ether->tdesc->desclist[ether->cur_tx];
 	buffer = ether->tdesc->tran_buf[ether->cur_tx];
+
 	if (length > 1514) {
 		dev_err(&pdev->dev, "send data %d bytes, check it\n", length);
 		length = 1514;
@@ -607,7 +628,9 @@ static int w90p910_send_frame(struct net_device *dev,
 
 	w90p910_trigger_tx(dev);
 
-	ether->cur_tx = (ether->cur_tx+1) % TX_DESC_SIZE;
+	if (++ether->cur_tx >= TX_DESC_SIZE)
+		ether->cur_tx = 0;
+
 	txbd = &ether->tdesc->desclist[ether->cur_tx];
 
 	dev->trans_start = jiffies;
@@ -635,7 +658,6 @@ static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
 	struct w90p910_ether *ether;
 	struct w90p910_txbd  *txbd;
 	struct platform_device *pdev;
-	struct tran_pdesc *tran_pdesc;
 	struct net_device *dev;
 	unsigned int cur_entry, entry, status;
 
@@ -647,13 +669,14 @@ static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
 
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
@@ -668,7 +691,8 @@ static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
 		if (netif_queue_stopped(dev))
 			netif_wake_queue(dev);
 
-		entry = (unsigned int)(&tran_pdesc->desclist[ether->finish_tx]);
+		entry = ether->tdesc_phys +
+			offsetof(struct tran_pdesc, desclist[ether->finish_tx]);
 	}
 
 	if (status & MISTA_EXDEF) {
@@ -689,20 +713,20 @@ static void netdev_rx(struct net_device *dev)
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
@@ -747,7 +771,10 @@ static void netdev_rx(struct net_device *dev)
 
 		rxbd->sl = RX_OWEN_DMA;
 		rxbd->reserved = 0x0;
-		ether->cur_rx = (ether->cur_rx+1) % RX_DESC_SIZE;
+
+		if (++ether->cur_rx >= RX_DESC_SIZE)
+			ether->cur_rx = 0;
+
 		rxbd = &ether->rdesc->desclist[ether->cur_rx];
 
 		dev->last_rx = jiffies;
@@ -955,30 +982,29 @@ static int __devinit w90p910_ether_probe(struct platform_device *pdev)
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
@@ -1039,7 +1065,7 @@ failed_free_txirq:
 failed_free_io:
 	iounmap(ether->reg);
 failed_free_mem:
-	release_mem_region(res->start, resource_size(res));
+	release_mem_region(ether->res->start, resource_size(ether->res));
 failed_free:
 	free_netdev(dev);
 	return error;
@@ -1051,12 +1077,19 @@ static int __devexit w90p910_ether_remove(struct platform_device *pdev)
 	struct w90p910_ether *ether = netdev_priv(dev);
 
 	unregister_netdev(dev);
+
 	clk_put(ether->rmiiclk);
 	clk_put(ether->clk);
-	del_timer_sync(&ether->check_timer);
-	platform_set_drvdata(pdev, NULL);
+
+	iounmap(ether->reg);
+	release_mem_region(ether->res->start, resource_size(ether->res));
+
 	free_irq(ether->txirq, dev);
 	free_irq(ether->rxirq, dev);
+
+	del_timer_sync(&ether->check_timer);
+	platform_set_drvdata(pdev, NULL);
+
 	free_netdev(dev);
 	return 0;
 }
-- 
1.5.6.3
 

