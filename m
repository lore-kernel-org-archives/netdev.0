From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCH net-next 2/6] smc91x: replace printk with netdev_ calls
Date: Fri, 25 Oct 2013 02:26:58 -0400
Message-ID: <1382682422-22677-3-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:60106 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab3JYG1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:27:16 -0400
Received: by mail-qa0-f48.google.com with SMTP id k4so348976qaq.7
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 23:27:15 -0700 (PDT)
In-Reply-To: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smc91x.c | 53 +++++++++++++++++++-------------------
 drivers/net/ethernet/smsc/smc91x.h |  2 +-
 2 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 73be7f3..d425d33 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -58,7 +58,7 @@
  *   22/09/04  Nicolas Pitre      big update (see commit log for details)
  */
 static const char version[] =
-	"smc91x.c: v1.1, sep 22 2004 by Nicolas Pitre <nico@fluxnic.net>\n";
+	"smc91x.c: v1.1, sep 22 2004 by Nicolas Pitre <nico@fluxnic.net>";
 
 /* Debugging level */
 #ifndef SMC_DEBUG
@@ -152,10 +152,10 @@ MODULE_ALIAS("platform:smc91x");
 #define DBG(n, args...)					\
 	do {						\
 		if (SMC_DEBUG >= (n))			\
-			printk(args);	\
+			printk(KERN_DEBUG args);	\
 	} while (0)
 
-#define PRINTK(args...)   printk(args)
+#define PRINTK(args...)   printk(KERN_DEBUG args)
 #else
 #define DBG(n, args...)   do { } while(0)
 #define PRINTK(args...)   printk(KERN_DEBUG args)
@@ -173,6 +173,7 @@ static void PRINT_PKT(u_char *buf, int length)
 
 	for (i = 0; i < lines ; i ++) {
 		int cur;
+		printk(KERN_DEBUG);
 		for (cur = 0; cur < 8; cur++) {
 			u_char a, b;
 			a = *buf++;
@@ -181,6 +182,7 @@ static void PRINT_PKT(u_char *buf, int length)
 		}
 		printk("\n");
 	}
+	printk(KERN_DEBUG);
 	for (i = 0; i < remainder/2 ; i++) {
 		u_char a, b;
 		a = *buf++;
@@ -226,7 +228,7 @@ static void PRINT_PKT(u_char *buf, int length)
 		unsigned long timeout = jiffies + 2;			\
 		while (SMC_GET_MMU_CMD(lp) & MC_BUSY) {		\
 			if (time_after(jiffies, timeout)) {		\
-				printk("%s: timeout %s line %d\n",	\
+				netdev_dbg(dev, "%s: timeout %s line %d\n",	\
 					dev->name, __FILE__, __LINE__);	\
 				break;					\
 			}						\
@@ -433,7 +435,7 @@ static inline void  smc_rcv(struct net_device *dev)
 		}
 		if (packet_len < 6) {
 			/* bloody hardware */
-			printk(KERN_ERR "%s: fubar (rxlen %u status %x\n",
+			netdev_err(dev, "%s: fubar (rxlen %u status %x\n",
 					dev->name, packet_len, status);
 			status |= RS_TOOSHORT;
 		}
@@ -568,7 +570,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 
 	packet_no = SMC_GET_AR(lp);
 	if (unlikely(packet_no & AR_FAILED)) {
-		printk("%s: Memory allocation failed.\n", dev->name);
+		netdev_err(dev, "%s: Memory allocation failed.\n", dev->name);
 		dev->stats.tx_errors++;
 		dev->stats.tx_fifo_errors++;
 		smc_special_unlock(&lp->lock, flags);
@@ -654,7 +656,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	numPages = ((skb->len & ~1) + (6 - 1)) >> 8;
 	if (unlikely(numPages > 7)) {
-		printk("%s: Far too big packet error.\n", dev->name);
+		netdev_warn(dev, "%s: Far too big packet error.\n", dev->name);
 		dev->stats.tx_errors++;
 		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
@@ -740,7 +742,7 @@ static void smc_tx(struct net_device *dev)
 			"late collision" : "too many collisions");
 		dev->stats.tx_window_errors++;
 		if (!(dev->stats.tx_window_errors & 63) && net_ratelimit()) {
-			printk(KERN_INFO "%s: unexpectedly large number of "
+			netdev_info(dev, "%s: unexpectedly large number of "
 			       "bad collisions. Please check duplex "
 			       "setting.\n", dev->name);
 		}
@@ -1055,7 +1057,7 @@ static void smc_phy_configure(struct work_struct *work)
 		goto smc_phy_configure_exit;
 
 	if (smc_phy_reset(dev, phyaddr)) {
-		printk("%s: PHY reset timed out\n", dev->name);
+		netdev_info(dev, "%s: PHY reset timed out\n", dev->name);
 		goto smc_phy_configure_exit;
 	}
 
@@ -1082,7 +1084,7 @@ static void smc_phy_configure(struct work_struct *work)
 	my_phy_caps = smc_phy_read(dev, phyaddr, MII_BMSR);
 
 	if (!(my_phy_caps & BMSR_ANEGCAPABLE)) {
-		printk(KERN_INFO "Auto negotiation NOT supported\n");
+		netdev_info(dev, "Auto negotiation NOT supported\n");
 		smc_phy_fixed(dev);
 		goto smc_phy_configure_exit;
 	}
@@ -1179,7 +1181,7 @@ static void smc_10bt_check_media(struct net_device *dev, int init)
 			netif_carrier_on(dev);
 		}
 		if (netif_msg_link(lp))
-			printk(KERN_INFO "%s: link %s\n", dev->name,
+			netdev_info(dev, "%s: link %s\n", dev->name,
 			       new_carrier ? "up" : "down");
 	}
 }
@@ -1856,7 +1858,6 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 		     unsigned long irq_flags)
 {
 	struct smc_local *lp = netdev_priv(dev);
-	static int version_printed = 0;
 	int retval;
 	unsigned int val, revision_register;
 	const char *version_string;
@@ -1868,7 +1869,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	DBG(2, "%s: bank signature probe returned 0x%04x\n", CARDNAME, val);
 	if ((val & 0xFF00) != 0x3300) {
 		if ((val & 0xFF) == 0x33) {
-			printk(KERN_WARNING
+			netdev_warn(dev,
 				"%s: Detected possible byte-swapped interface"
 				" at IOADDR %p\n", CARDNAME, ioaddr);
 		}
@@ -1897,7 +1898,8 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	val = SMC_GET_BASE(lp);
 	val = ((val & 0x1F00) >> 3) << SMC_IO_SHIFT;
 	if (((unsigned int)ioaddr & (0x3e0 << SMC_IO_SHIFT)) != val) {
-		printk("%s: IOADDR %p doesn't match configuration (%x).\n",
+		netdev_warn(dev, "%s: IOADDR %p doesn't match "
+			"configuration (%x).\n",
 			CARDNAME, ioaddr, val);
 	}
 
@@ -1912,8 +1914,8 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	version_string = chip_ids[ (revision_register >> 4) & 0xF];
 	if (!version_string || (revision_register & 0xff00) != 0x3300) {
 		/* I don't recognize this chip, so... */
-		printk("%s: IO %p: Unrecognized revision register 0x%04x"
-			", Contact author.\n", CARDNAME,
+		netdev_warn(dev, "%s: IO %p: Unrecognized revision "
+			"register 0x%04x, Contact author.\n", CARDNAME,
 			ioaddr, revision_register);
 
 		retval = -ENODEV;
@@ -1921,8 +1923,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	}
 
 	/* At this point I'll assume that the chip is an SMC91x. */
-	if (version_printed++ == 0)
-		printk("%s", version);
+	pr_info_once("%s\n", version);
 
 	/* fill in some of the fields */
 	dev->base_addr = (unsigned long)ioaddr;
@@ -1940,7 +1941,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	/*
 	 * If dev->irq is 0, then the device has to be banged on to see
 	 * what the IRQ is.
- 	 *
+	 *
 	 * This banging doesn't always detect the IRQ, for unknown reasons.
 	 * a workaround is to reset the chip and try again.
 	 *
@@ -1965,7 +1966,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 		}
 	}
 	if (dev->irq == 0) {
-		printk("%s: Couldn't autodetect your IRQ. Use irq=xx.\n",
+		netdev_warn(dev, "%s: Couldn't autodetect your IRQ. Use irq=xx.\n",
 			dev->name);
 		retval = -ENODEV;
 		goto err_out;
@@ -2030,7 +2031,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	retval = register_netdev(dev);
 	if (retval == 0) {
 		/* now, print out the card info, in a short format.. */
-		printk("%s: %s (rev %d) at %p IRQ %d",
+		netdev_info(dev, "%s: %s (rev %d) at %p IRQ %d",
 			dev->name, version_string, revision_register & 0x0f,
 			lp->base, dev->irq);
 
@@ -2042,11 +2043,11 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 			THROTTLE_TX_PKTS ? " [throttle_tx]" : "");
 
 		if (!is_valid_ether_addr(dev->dev_addr)) {
-			printk("%s: Invalid ethernet MAC address.  Please "
-			       "set using ifconfig\n", dev->name);
+			netdev_warn(dev, "%s: Invalid ethernet MAC address. "
+					"Please set using ifconfig\n", dev->name);
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: %pM\n",
+			netdev_info(dev, "%s: Ethernet addr: %pM\n",
 			       dev->name, dev->dev_addr);
 		}
 
@@ -2165,7 +2166,7 @@ static inline void smc_request_datacs(struct platform_device *pdev, struct net_d
 			return;
 
 		if(!request_mem_region(res->start, SMC_DATA_EXTENT, CARDNAME)) {
-			printk(KERN_INFO "%s: failed to request datacs memory region.\n", CARDNAME);
+			netdev_info(ndev, "%s: failed to request datacs memory region.\n", CARDNAME);
 			return;
 		}
 
@@ -2307,7 +2308,7 @@ static int smc_drv_probe(struct platform_device *pdev)
  out_free_netdev:
 	free_netdev(ndev);
  out:
-	printk("%s: not found (%d).\n", CARDNAME, ret);
+	netdev_info(dev, "%s: not found (%d).\n", CARDNAME, ret);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 98eedb9..22794c5 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -907,7 +907,7 @@ static const char * chip_ids[ 16 ] =  {
 	({								\
 		int __b = SMC_CURRENT_BANK(lp);			\
 		if (unlikely((__b & ~0xf0) != (0x3300 | bank))) {	\
-			printk( "%s: bank reg screwed (0x%04x)\n",	\
+			printk( KERN_ERR "%s: bank reg screwed (0x%04x)\n",	\
 				CARDNAME, __b );			\
 			BUG();						\
 		}							\
-- 
1.8.3.1
