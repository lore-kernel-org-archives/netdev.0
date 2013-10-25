From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCH net-next 3/6] smc911x: replace printk with netdev_ calls
Date: Fri, 25 Oct 2013 02:26:59 -0400
Message-ID: <1382682422-22677-4-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:35265 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab3JYG1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:27:18 -0400
Received: by mail-qa0-f42.google.com with SMTP id w8so344289qac.8
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 23:27:18 -0700 (PDT)
In-Reply-To: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smc911x.c | 34 ++++++++++++++++++----------------
 drivers/net/ethernet/smsc/smc911x.h |  2 +-
 2 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index afe01c4..22efe1c 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -109,10 +109,10 @@ MODULE_ALIAS("platform:smc911x");
 #define DBG(n, args...)				 \
 	do {					 \
 		if (SMC_DEBUG & (n))		 \
-			printk(args);		 \
+			printk(KERN_DEBUG args); \
 	} while (0)
 
-#define PRINTK(args...)   printk(args)
+#define PRINTK(args...)   printk(KERN_DEBUG args)
 #else
 #define DBG(n, args...)   do { } while (0)
 #define PRINTK(args...)   printk(KERN_DEBUG args)
@@ -130,6 +130,7 @@ static void PRINT_PKT(u_char *buf, int length)
 
 	for (i = 0; i < lines ; i ++) {
 		int cur;
+		printk(KERN_DEBUG);
 		for (cur = 0; cur < 8; cur++) {
 			u_char a, b;
 			a = *buf++;
@@ -138,6 +139,7 @@ static void PRINT_PKT(u_char *buf, int length)
 		}
 		printk("\n");
 	}
+	printk(KERN_DEBUG);
 	for (i = 0; i < remainder/2 ; i++) {
 		u_char a, b;
 		a = *buf++;
@@ -545,7 +547,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 *	  End padding				 15 bytes
 	 */
 	if (unlikely(free < (skb->len + 8 + 15 + 15))) {
-		printk("%s: No Tx free space %d < %d\n",
+		netdev_warn(dev, "%s: No Tx free space %d < %d\n",
 			dev->name, free, skb->len);
 		lp->pending_tx_skb = NULL;
 		dev->stats.tx_errors++;
@@ -900,7 +902,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 		return;
 
 	if (smc911x_phy_reset(dev, phyaddr)) {
-		printk("%s: PHY reset timed out\n", dev->name);
+		netdev_info(dev, "%s: PHY reset timed out\n", dev->name);
 		return;
 	}
 	spin_lock_irqsave(&lp->lock, flags);
@@ -922,7 +924,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 	/* Copy our capabilities from MII_BMSR to MII_ADVERTISE */
 	SMC_GET_PHY_BMSR(lp, phyaddr, my_phy_caps);
 	if (!(my_phy_caps & BMSR_ANEGCAPABLE)) {
-		printk(KERN_INFO "Auto negotiation NOT supported\n");
+		netdev_info(dev, "Auto negotiation NOT supported\n");
 		smc911x_phy_fixed(dev);
 		goto smc911x_phy_configure_exit;
 	}
@@ -1805,7 +1807,7 @@ static int smc911x_probe(struct net_device *dev)
 	val = SMC_GET_BYTE_TEST(lp);
 	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
 	if (val != 0x87654321) {
-		printk(KERN_ERR "Invalid chip endian 0x%08x\n",val);
+		netdev_err(dev, "Invalid chip endian 0x%08x\n",val);
 		retval = -ENODEV;
 		goto err_out;
 	}
@@ -1821,7 +1823,7 @@ static int smc911x_probe(struct net_device *dev)
 		if (chip_ids[i].id == chip_id) break;
 	}
 	if (!chip_ids[i].id) {
-		printk(KERN_ERR "Unknown chip ID %04x\n", chip_id);
+		netdev_err(dev, "Unknown chip ID %04x\n", chip_id);
 		retval = -ENODEV;
 		goto err_out;
 	}
@@ -1835,7 +1837,7 @@ static int smc911x_probe(struct net_device *dev)
 
 	/* Validate the TX FIFO size requested */
 	if ((tx_fifo_kb < 2) || (tx_fifo_kb > 14)) {
-		printk(KERN_ERR "Invalid TX FIFO size requested %d\n", tx_fifo_kb);
+		netdev_err(dev, "Invalid TX FIFO size requested %d\n", tx_fifo_kb);
 		retval = -EINVAL;
 		goto err_out;
 	}
@@ -1924,7 +1926,7 @@ static int smc911x_probe(struct net_device *dev)
 		}
 	}
 	if (dev->irq == 0) {
-		printk("%s: Couldn't autodetect your IRQ. Use irq=xx.\n",
+		netdev_warn(dev, "%s: Couldn't autodetect your IRQ. Use irq=xx.\n",
 			dev->name);
 		retval = -ENODEV;
 		goto err_out;
@@ -1980,24 +1982,24 @@ static int smc911x_probe(struct net_device *dev)
 	retval = register_netdev(dev);
 	if (retval == 0) {
 		/* now, print out the card info, in a short format.. */
-		printk("%s: %s (rev %d) at %#lx IRQ %d",
+		netdev_info(dev, "%s: %s (rev %d) at %#lx IRQ %d",
 			dev->name, version_string, lp->revision,
 			dev->base_addr, dev->irq);
 
 #ifdef SMC_USE_DMA
 		if (lp->rxdma != -1)
-			printk(" RXDMA %d ", lp->rxdma);
+			printk(" RXDMA %d", lp->rxdma);
 
 		if (lp->txdma != -1)
-			printk("TXDMA %d", lp->txdma);
+			printk(" TXDMA %d", lp->txdma);
 #endif
 		printk("\n");
 		if (!is_valid_ether_addr(dev->dev_addr)) {
-			printk("%s: Invalid ethernet MAC address. Please "
-					"set using ifconfig\n", dev->name);
+			netdev_warn(dev, "%s: Invalid ethernet MAC address. "
+					"Please set using ifconfig\n", dev->name);
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: %pM\n",
+			netdev_info(dev, "%s: Ethernet addr: %pM\n",
 				dev->name, dev->dev_addr);
 		}
 
@@ -2093,7 +2095,7 @@ release_both:
 release_1:
 		release_mem_region(res->start, SMC911X_IO_EXTENT);
 out:
-		printk("%s: not found (%d).\n", CARDNAME, ret);
+		netdev_info(ndev, "%s: not found (%d).\n", CARDNAME, ret);
 	}
 #ifdef SMC_USE_DMA
 	else {
diff --git a/drivers/net/ethernet/smsc/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
index d51261b..b1b76e0 100644
--- a/drivers/net/ethernet/smsc/smc911x.h
+++ b/drivers/net/ethernet/smsc/smc911x.h
@@ -227,7 +227,7 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 #define SMC_DMA_ACK_IRQ(dev, dma)					\
 {									\
 	if (DCSR(dma) & DCSR_BUSERR) {					\
-		printk("%s: DMA %d bus error!\n", dev->name, dma);	\
+		netdev_err(dev, "%s: DMA %d bus error!\n", dev->name, dma);	\
 	}								\
 	DCSR(dma) = DCSR_STARTINTR|DCSR_ENDINTR|DCSR_BUSERR;		\
 }
-- 
1.8.3.1
