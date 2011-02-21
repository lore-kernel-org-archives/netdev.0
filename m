From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/9] ax88796: use netdev_<LEVEL> instead of dev_<LEVEL> and pr_<LEVEL>
Date: Mon, 21 Feb 2011 14:03:16 +0100
Message-ID: <1298293400-21570-6-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35852 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab1BUNDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:30 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |   46 ++++++++++++++++++++--------------------------
 1 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index eac5b10..1370cac 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -143,12 +143,11 @@ static int ax_initial_check(struct net_device *dev)
 static void ax_reset_8390(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device *ax = to_ax_dev(dev);
 	unsigned long reset_start_time = jiffies;
 	void __iomem *addr = (void __iomem *)dev->base_addr;
 
 	if (ei_debug > 1)
-		dev_dbg(&ax->dev->dev, "resetting the 8390 t=%ld\n", jiffies);
+		netdev_dbg(dev, "resetting the 8390 t=%ld\n", jiffies);
 
 	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
 
@@ -158,8 +157,7 @@ static void ax_reset_8390(struct net_device *dev)
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
 		if (jiffies - reset_start_time > 2 * HZ / 100) {
-			dev_warn(&ax->dev->dev, "%s: %s did not complete.\n",
-			       __func__, dev->name);
+			netdev_warn(dev, "%s: did not complete.\n", __func__);
 			break;
 		}
 	}
@@ -172,14 +170,13 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 			    int ring_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_local->dmaing) {
-		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s "
+		netdev_err(dev, "DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __func__,
+			__func__,
 			ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
@@ -217,15 +214,14 @@ static void ax_block_input(struct net_device *dev, int count,
 			   struct sk_buff *skb, int ring_offset)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	char *buf = skb->data;
 
 	if (ei_local->dmaing) {
-		dev_err(&ax->dev->dev,
-			"%s: DMAing conflict in %s "
+		netdev_err(dev,
+			"DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __func__,
+			__func__,
 			ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
@@ -255,7 +251,6 @@ static void ax_block_output(struct net_device *dev, int count,
 			    const unsigned char *buf, const int start_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	unsigned long dma_start;
 
@@ -269,9 +264,9 @@ static void ax_block_output(struct net_device *dev, int count,
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_local->dmaing) {
-		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s."
+		netdev_err(dev, "DMAing conflict in %s."
 			"[DMAstat:%d][irqlock:%d]\n",
-			dev->name, __func__,
+			__func__,
 		       ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
@@ -298,8 +293,7 @@ static void ax_block_output(struct net_device *dev, int count,
 
 	while ((ei_inb(nic_base + EN0_ISR) & ENISR_RDC) == 0) {
 		if (jiffies - dma_start > 2 * HZ / 100) {		/* 20ms */
-			dev_warn(&ax->dev->dev,
-				 "%s: timeout waiting for Tx RDC.\n", dev->name);
+			netdev_warn(dev, "timeout waiting for Tx RDC.\n");
 			ax_reset_8390(dev);
 			ax_NS8390_init(dev, 1);
 			break;
@@ -404,7 +398,7 @@ static void
 ax_phy_issueaddr(struct net_device *dev, int phy_addr, int reg, int opc)
 {
 	if (phy_debug)
-		pr_debug("%s: dev %p, %04x, %04x, %d\n",
+		netdev_dbg(dev, "%s: dev %p, %04x, %04x, %d\n",
 			__func__, dev, phy_addr, reg, opc);
 
 	ax_mii_ei_outbits(dev, 0x3f, 6);	/* pre-amble */
@@ -431,7 +425,7 @@ ax_phy_read(struct net_device *dev, int phy_addr, int reg)
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	if (phy_debug)
-		pr_debug("%s: %04x.%04x => read %04x\n", __func__,
+		netdev_dbg(dev, "%s: %04x.%04x => read %04x\n", __func__,
 			 phy_addr, reg, result);
 
 	return result;
@@ -441,10 +435,9 @@ static void
 ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
 {
 	struct ei_device *ei = netdev_priv(dev);
-	struct ax_device *ax = to_ax_dev(dev);
 	unsigned long flags;
 
-	dev_dbg(&ax->dev->dev, "%s: %p, %04x, %04x %04x\n",
+	netdev_dbg(dev, "%s: %p, %04x, %04x %04x\n",
 		__func__, dev, phy_addr, reg, value);
 
 	spin_lock_irqsave(&ei->page_lock, flags);
@@ -478,7 +471,7 @@ static int ax_open(struct net_device *dev)
 	struct ei_device *ei_local = netdev_priv(dev);
 	int ret;
 
-	dev_dbg(&ax->dev->dev, "%s: open\n", dev->name);
+	netdev_dbg(dev, "open\n");
 
 	ret = request_irq(dev->irq, ax_ei_interrupt, ax->irqflags,
 			  dev->name, dev);
@@ -514,7 +507,7 @@ static int ax_close(struct net_device *dev)
 	struct ax_device *ax = to_ax_dev(dev);
 	struct ei_device *ei_local = netdev_priv(dev);
 
-	dev_dbg(&ax->dev->dev, "%s: close\n", dev->name);
+	netdev_dbg(dev, "close\n");
 
 	/* turn the phy off */
 
@@ -785,14 +778,14 @@ static int ax_init_dev(struct net_device *dev)
 
 	ax_NS8390_init(dev, 0);
 
-	dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %pM\n",
-		 ei_local->word16 ? 16 : 8, dev->irq, dev->base_addr,
-		 dev->dev_addr);
-
 	ret = register_netdev(dev);
 	if (ret)
 		goto out_irq;
 
+	netdev_info(dev, "%dbit, irq %d, %lx, MAC: %pM\n",
+		    ei_local->word16 ? 16 : 8, dev->irq, dev->base_addr,
+		    dev->dev_addr);
+
 	return 0;
 
  out_irq:
@@ -849,6 +842,7 @@ static int ax_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	/* ok, let's setup our device */
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	ei_local = netdev_priv(dev);
 	ax = to_ax_dev(dev);
 
-- 
1.7.2.3

