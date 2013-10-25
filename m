From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCH net-next 4/6] smc9194: replace printk with netdev_ calls
Date: Fri, 25 Oct 2013 02:27:00 -0400
Message-ID: <1382682422-22677-5-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33329 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab3JYG1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:27:21 -0400
Received: by mail-qc0-f174.google.com with SMTP id v1so1982157qcw.19
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 23:27:20 -0700 (PDT)
In-Reply-To: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smc9194.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index e85c2e7..c0a45a9 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -55,7 +55,7 @@
  ----------------------------------------------------------------------------*/
 
 static const char version[] =
-	"smc9194.c:v0.14 12/15/00 by Erik Stahlman (erik@vt.edu)\n";
+	"smc9194.c:v0.14 12/15/00 by Erik Stahlman (erik@vt.edu)";
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -612,7 +612,7 @@ static void smc_hardware_send_packet( struct net_device * dev )
 	packet_no = inb( ioaddr + PNR_ARR + 1 );
 	if ( packet_no & 0x80 ) {
 		/* or isn't there?  BAD CHIP! */
-		printk(KERN_DEBUG CARDNAME": Memory allocation failed.\n");
+		netdev_dbg(dev, CARDNAME": Memory allocation failed.\n");
 		dev_kfree_skb_any(skb);
 		lp->saved_skb = NULL;
 		netif_wake_queue(dev);
@@ -865,7 +865,6 @@ static const struct net_device_ops smc_netdev_ops = {
 static int __init smc_probe(struct net_device *dev, int ioaddr)
 {
 	int i, memory, retval;
-	static unsigned version_printed;
 	unsigned int bank;
 
 	const char *version_string;
@@ -937,8 +936,7 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	   It might be prudent to check a listing of MAC addresses
 	   against the hardware address, or do some other tests. */
 
-	if (version_printed++ == 0)
-		printk("%s", version);
+	pr_info_once("%s\n", version);
 
 	/* fill in some of the fields */
 	dev->base_addr = ioaddr;
@@ -1027,18 +1025,18 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 
 	/* now, print out the card info, in a short format.. */
 
-	printk("%s: %s(r:%d) at %#3x IRQ:%d INTF:%s MEM:%db ", dev->name,
+	netdev_info(dev, "%s: %s(r:%d) at %#3x IRQ:%d INTF:%s MEM:%db ", dev->name,
 		version_string, revision_register & 0xF, ioaddr, dev->irq,
 		if_string, memory );
 	/*
 	 . Print the Ethernet address
 	*/
-	printk("ADDR: %pM\n", dev->dev_addr);
+	netdev_info(dev, "ADDR: %pM\n", dev->dev_addr);
 
 	/* Grab the IRQ */
       	retval = request_irq(dev->irq, smc_interrupt, 0, DRV_NAME, dev);
       	if (retval) {
-		printk("%s: unable to get IRQ %d (irqval=%d).\n", DRV_NAME,
+		netdev_warn(dev, "%s: unable to get IRQ %d (irqval=%d).\n", DRV_NAME,
 			dev->irq, retval);
   	  	goto err_out;
       	}
@@ -1061,13 +1059,14 @@ static void print_packet( byte * buf, int length )
 	int remainder;
 	int lines;
 
-	printk("Packet of length %d\n", length);
+	printk(KERN_DEBUG "Packet of length %d\n", length);
 	lines = length / 16;
 	remainder = length % 16;
 
 	for ( i = 0; i < lines ; i ++ ) {
 		int cur;
 
+		printk(KERN_DEBUG);
 		for ( cur = 0; cur < 8; cur ++ ) {
 			byte a, b;
 
@@ -1077,6 +1076,7 @@ static void print_packet( byte * buf, int length )
 		}
 		printk("\n");
 	}
+	printk(KERN_DEBUG);
 	for ( i = 0; i < remainder/2 ; i++ ) {
 		byte a, b;
 
@@ -1151,7 +1151,7 @@ static void smc_timeout(struct net_device *dev)
 {
 	/* If we get here, some higher level has decided we are broken.
 	   There should really be a "kick me" function call instead. */
-	printk(KERN_WARNING CARDNAME": transmit timed out, %s?\n",
+	netdev_warn(dev, CARDNAME": transmit timed out, %s?\n",
 		tx_done(dev) ? "IRQ conflict" :
 		"network cable problem");
 	/* "kick" the adaptor */
@@ -1323,7 +1323,7 @@ static void smc_tx( struct net_device * dev )
 	dev->stats.tx_errors++;
 	if ( tx_status & TS_LOSTCAR ) dev->stats.tx_carrier_errors++;
 	if ( tx_status & TS_LATCOL  ) {
-		printk(KERN_DEBUG CARDNAME
+		netdev_dbg(dev, CARDNAME
 			": Late collision occurred on last xmit.\n");
 		dev->stats.tx_window_errors++;
 	}
@@ -1332,7 +1332,7 @@ static void smc_tx( struct net_device * dev )
 #endif
 
 	if ( tx_status & TS_SUCCESS ) {
-		printk(CARDNAME": Successful packet caused interrupt\n");
+		netdev_info(dev, CARDNAME": Successful packet caused interrupt\n");
 	}
 	/* re-enable transmit */
 	SMC_SELECT_BANK( 0 );
-- 
1.8.3.1
