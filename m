From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/9] ax88796: don't use magic ei_status to acces private data
Date: Mon, 21 Feb 2011 14:03:13 +0100
Message-ID: <1298293400-21570-3-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35846 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807Ab1BUND3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:29 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |   81 +++++++++++++++++++++++++-----------------------
 1 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 6d1d5ca..c49c3b1 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -152,8 +152,8 @@ static void ax_reset_8390(struct net_device *dev)
 
 	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
 
-	ei_status.txing = 0;
-	ei_status.dmaing = 0;
+	ei_local->txing = 0;
+	ei_local->dmaing = 0;
 
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
@@ -176,15 +176,15 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 	void __iomem *nic_base = ei_local->mem;
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
-	if (ei_status.dmaing) {
+	if (ei_local->dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
 			dev->name, __func__,
-			ei_status.dmaing, ei_status.irqlock);
+			ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
 
-	ei_status.dmaing |= 0x01;
+	ei_local->dmaing |= 0x01;
 	ei_outb(E8390_NODMA + E8390_PAGE0 + E8390_START, nic_base + NE_CMD);
 	ei_outb(sizeof(struct e8390_pkt_hdr), nic_base + EN0_RCNTLO);
 	ei_outb(0, nic_base + EN0_RCNTHI);
@@ -192,7 +192,7 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 	ei_outb(ring_page, nic_base + EN0_RSARHI);
 	ei_outb(E8390_RREAD+E8390_START, nic_base + NE_CMD);
 
-	if (ei_status.word16)
+	if (ei_local->word16)
 		readsw(nic_base + NE_DATAPORT, hdr,
 		       sizeof(struct e8390_pkt_hdr) >> 1);
 	else
@@ -200,7 +200,7 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 		       sizeof(struct e8390_pkt_hdr));
 
 	ei_outb(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
-	ei_status.dmaing &= ~0x01;
+	ei_local->dmaing &= ~0x01;
 
 	le16_to_cpus(&hdr->count);
 }
@@ -221,16 +221,16 @@ static void ax_block_input(struct net_device *dev, int count,
 	void __iomem *nic_base = ei_local->mem;
 	char *buf = skb->data;
 
-	if (ei_status.dmaing) {
+	if (ei_local->dmaing) {
 		dev_err(&ax->dev->dev,
 			"%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
 			dev->name, __func__,
-			ei_status.dmaing, ei_status.irqlock);
+			ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
 
-	ei_status.dmaing |= 0x01;
+	ei_local->dmaing |= 0x01;
 
 	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_START, nic_base + NE_CMD);
 	ei_outb(count & 0xff, nic_base + EN0_RCNTLO);
@@ -239,7 +239,7 @@ static void ax_block_input(struct net_device *dev, int count,
 	ei_outb(ring_offset >> 8, nic_base + EN0_RSARHI);
 	ei_outb(E8390_RREAD+E8390_START, nic_base + NE_CMD);
 
-	if (ei_status.word16) {
+	if (ei_local->word16) {
 		readsw(nic_base + NE_DATAPORT, buf, count >> 1);
 		if (count & 0x01)
 			buf[count-1] = ei_inb(nic_base + NE_DATAPORT);
@@ -248,7 +248,7 @@ static void ax_block_input(struct net_device *dev, int count,
 		readsb(nic_base + NE_DATAPORT, buf, count);
 	}
 
-	ei_status.dmaing &= ~1;
+	ei_local->dmaing &= ~1;
 }
 
 static void ax_block_output(struct net_device *dev, int count,
@@ -264,19 +264,19 @@ static void ax_block_output(struct net_device *dev, int count,
 	 * What effect will an odd byte count have on the 8390?  I
 	 * should check someday.
 	 */
-	if (ei_status.word16 && (count & 0x01))
+	if (ei_local->word16 && (count & 0x01))
 		count++;
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
-	if (ei_status.dmaing) {
+	if (ei_local->dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s."
 			"[DMAstat:%d][irqlock:%d]\n",
 			dev->name, __func__,
-		       ei_status.dmaing, ei_status.irqlock);
+		       ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
 
-	ei_status.dmaing |= 0x01;
+	ei_local->dmaing |= 0x01;
 	/* We should already be in page 0, but to be safe... */
 	ei_outb(E8390_PAGE0+E8390_START+E8390_NODMA, nic_base + NE_CMD);
 
@@ -289,7 +289,7 @@ static void ax_block_output(struct net_device *dev, int count,
 	ei_outb(start_page, nic_base + EN0_RSARHI);
 
 	ei_outb(E8390_RWRITE+E8390_START, nic_base + NE_CMD);
-	if (ei_status.word16)
+	if (ei_local->word16)
 		writesw(nic_base + NE_DATAPORT, buf, count >> 1);
 	else
 		writesb(nic_base + NE_DATAPORT, buf, count);
@@ -307,7 +307,7 @@ static void ax_block_output(struct net_device *dev, int count,
 	}
 
 	ei_outb(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
-	ei_status.dmaing &= ~0x01;
+	ei_local->dmaing &= ~0x01;
 }
 
 /* definitions for accessing MII/EEPROM interface */
@@ -758,22 +758,22 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 
 	ax_reset_8390(dev);
 
-	ei_status.name = "AX88796";
-	ei_status.tx_start_page = start_page;
-	ei_status.stop_page = stop_page;
-	ei_status.word16 = (ax->plat->wordlength == 2);
-	ei_status.rx_start_page = start_page + TX_PAGES;
+	ei_local->name = "AX88796";
+	ei_local->tx_start_page = start_page;
+	ei_local->stop_page = stop_page;
+	ei_local->word16 = (ax->plat->wordlength == 2);
+	ei_local->rx_start_page = start_page + TX_PAGES;
 
 #ifdef PACKETBUF_MEMSIZE
 	/* Allow the packet buffer size to be overridden by know-it-alls. */
-	ei_status.stop_page = ei_status.tx_start_page + PACKETBUF_MEMSIZE;
+	ei_local->stop_page = ei_local->tx_start_page + PACKETBUF_MEMSIZE;
 #endif
 
-	ei_status.reset_8390	= &ax_reset_8390;
-	ei_status.block_input	= &ax_block_input;
-	ei_status.block_output	= &ax_block_output;
-	ei_status.get_8390_hdr	= &ax_get_8390_hdr;
-	ei_status.priv = 0;
+	ei_local->reset_8390 = &ax_reset_8390;
+	ei_local->block_input = &ax_block_input;
+	ei_local->block_output = &ax_block_output;
+	ei_local->get_8390_hdr = &ax_get_8390_hdr;
+	ei_local->priv = 0;
 
 	dev->netdev_ops = &ax_netdev_ops;
 	dev->ethtool_ops = &ax_ethtool_ops;
@@ -792,7 +792,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 
 	if (first_init)
 		dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %pM\n",
-			 ei_status.word16 ? 16 : 8, dev->irq, dev->base_addr,
+			 ei_local->word16 ? 16 : 8, dev->irq, dev->base_addr,
 			 dev->dev_addr);
 
 	ret = register_netdev(dev);
@@ -811,6 +811,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 static int ax_remove(struct platform_device *_dev)
 {
 	struct net_device *dev = platform_get_drvdata(_dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	struct ax_device *ax;
 
 	ax = to_ax_dev(dev);
@@ -818,7 +819,7 @@ static int ax_remove(struct platform_device *_dev)
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 
-	iounmap(ei_status.mem);
+	iounmap(ei_local->mem);
 	release_resource(ax->mem);
 	kfree(ax->mem);
 
@@ -843,6 +844,7 @@ static int ax_remove(struct platform_device *_dev)
 static int ax_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
+	struct ei_device *ei_local;
 	struct ax_device *ax;
 	struct resource *res;
 	size_t size;
@@ -853,6 +855,7 @@ static int ax_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	/* ok, let's setup our device */
+	ei_local = netdev_priv(dev);
 	ax = to_ax_dev(dev);
 
 	memset(ax, 0, sizeof(struct ax_device));
@@ -863,7 +866,7 @@ static int ax_probe(struct platform_device *pdev)
 	ax->plat = pdev->dev.platform_data;
 	platform_set_drvdata(pdev, dev);
 
-	ei_status.rxcr_base = ax->plat->rcr_val;
+	ei_local->rxcr_base = ax->plat->rcr_val;
 
 	/* find the platform resources */
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
@@ -890,9 +893,9 @@ static int ax_probe(struct platform_device *pdev)
 	 * by using the size of the resource provided
 	 */
 	if (ax->plat->reg_offsets)
-		ei_status.reg_offset = ax->plat->reg_offsets;
+		ei_local->reg_offset = ax->plat->reg_offsets;
 	else {
-		ei_status.reg_offset = ax->reg_offsets;
+		ei_local->reg_offset = ax->reg_offsets;
 		for (ret = 0; ret < 0x18; ret++)
 			ax->reg_offsets[ret] = (size / 0x18) * ret;
 	}
@@ -904,10 +907,10 @@ static int ax_probe(struct platform_device *pdev)
 		goto exit_mem;
 	}
 
-	ei_status.mem = ioremap(res->start, size);
-	dev->base_addr = (unsigned long)ei_status.mem;
+	ei_local->mem = ioremap(res->start, size);
+	dev->base_addr = (unsigned long)ei_local->mem;
 
-	if (ei_status.mem == NULL) {
+	if (ei_local->mem == NULL) {
 		dev_err(&pdev->dev, "Cannot ioremap area (%08llx,%08llx)\n",
 			(unsigned long long)res->start,
 			(unsigned long long)res->end);
@@ -943,7 +946,7 @@ static int ax_probe(struct platform_device *pdev)
 			goto exit_mem2;
 		}
 
-		ei_status.reg_offset[0x1f] = ax->map2 - ei_status.mem;
+		ei_local->reg_offset[0x1f] = ax->map2 - ei_local->mem;
 	}
 
 	/* got resources, now initialise and register device */
@@ -962,7 +965,7 @@ static int ax_probe(struct platform_device *pdev)
 	kfree(ax->mem2);
 
  exit_mem1:
-	iounmap(ei_status.mem);
+	iounmap(ei_local->mem);
 
  exit_req:
 	release_resource(ax->mem);
-- 
1.7.2.3

