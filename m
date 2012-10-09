From: Andrew May <acmay@acmay.org>
Subject: [RFC Patch] 405gp IBM EMAC Phy probe fails with no link
Date: Mon, 08 Oct 2012 23:23:35 -0700
Message-ID: <5073C2E7.4050903@acmay.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080308060202010005060400"
To: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from biz61.inmotionhosting.com ([74.124.213.197]:57400 "EHLO
	biz61.inmotionhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab2JIGoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 02:44:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080308060202010005060400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I have an older PPC 405GP board with a 2.6.33 kernel that fails to 
install a eth0 instance because the phy probe fails when there is no 
good ethernet link.
I have looked at the latest kernel code and it seems just about the same 
in this area, but I have not tried it.

Does anyone else still have a 405GP board to try and see if eth0 comes 
up with not enet cable?

I tried to probe the phy earlier and skip the emac_configure() call in 
emac_init_phy() to avoid doing the MR0_SRST bit set.
But the phy read still times out.

I then went with this approach to re-call emac_init_phy() after the 
emac_reset() finally completes when a cable is plugged in.
Does anyone else have any ideas why the phy probe fails on the first pass?

--------------080308060202010005060400
Content-Type: text/x-patch;
 name="ibm_phyprobe.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ibm_phyprobe.patch"

diff -ur linux.orig/drivers/net/ibm_newemac/core.c linux/drivers/net/ibm_newemac/core.c
--- linux.orig/drivers/net/ibm_newemac/core.c	2012-10-08 12:38:33.000000000 -0700
+++ linux/drivers/net/ibm_newemac/core.c	2012-10-08 14:31:35.797089192 -0700
@@ -106,6 +106,7 @@
  */
 static DECLARE_WAIT_QUEUE_HEAD(emac_probe_wait);
 
+static int emac_init_phy(struct emac_instance *dev);
 /* Having stable interface names is a doomed idea. However, it would be nice
  * if we didn't have completely random interface names at boot too :-) It's
  * just a matter of making everybody's life easier. Since we are doing
@@ -135,7 +136,7 @@
 				  EMAC_FTR_440EP_PHY_CLK_FIX))
 		DBG(dev, "%s" NL, error);
 	else if (net_ratelimit())
-		printk(KERN_ERR "%s: %s\n", dev->ofdev->node->full_name, error);
+		printk(KERN_INFO "%s: %s\n", dev->ofdev->node->full_name, error);
 }
 
 /* EMAC PHY clock workaround:
@@ -161,6 +162,7 @@
 }
 
 /* PHY polling intervals */
+#define PHY_POLL_NO_PHY 	(5 * HZ)
 #define PHY_POLL_LINK_ON	HZ
 #define PHY_POLL_LINK_OFF	(HZ / 5)
 
@@ -1156,8 +1158,12 @@
 
 	/* Start PHY polling now.
 	 */
-	if (dev->phy.address >= 0) {
+	if (dev->phy.address >= 0 || dev->phy.address == -2) {
 		int link_poll_interval;
+		if (dev->phy.address == -2) {
+			netif_carrier_off(dev->ndev);
+			link_poll_interval = PHY_POLL_NO_PHY;
+		}else 
 		if (dev->phy.def->ops->poll_link(&dev->phy)) {
 			dev->phy.def->ops->read_link(&dev->phy);
 			emac_rx_clk_default(dev);
@@ -1243,7 +1249,17 @@
 	if (!dev->opened)
 		goto bail;
 
-	if (dev->phy.def->ops->poll_link(&dev->phy)) {
+
+	if (!dev->phy.def) {
+		/* If the reset finally clears, because the phy now
+		 * has a link, then reprobe for the phy.
+		 */
+		if (emac_reset(dev) == 0)
+		{
+			emac_init_phy(dev);
+		}
+		link_poll_interval = PHY_POLL_NO_PHY;
+	}else if (dev->phy.def->ops->poll_link(&dev->phy)) {
 		if (!netif_carrier_ok(dev->ndev)) {
 			emac_rx_clk_default(dev);
 			/* Get new link parameters */
@@ -2376,7 +2392,7 @@
 	return 0;
 }
 
-static int __devinit emac_init_phy(struct emac_instance *dev)
+static int emac_init_phy(struct emac_instance *dev)
 {
 	struct device_node *np = dev->ofdev->node;
 	struct net_device *ndev = dev->ndev;
@@ -2470,7 +2486,9 @@
 	mutex_unlock(&emac_phy_map_lock);
 	if (i == 0x20) {
 		printk(KERN_WARNING "%s: can't find PHY!\n", np->full_name);
-		return -ENXIO;
+		busy_phy_map = 0;
+		dev->phy.address = -2;
+		return 0;
 	}
 
 	/* Init PHY */

--------------080308060202010005060400--
