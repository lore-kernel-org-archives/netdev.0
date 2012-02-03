From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] net: fec: Remove macaddr option
Date: Fri, 3 Feb 2012 15:25:04 -0200
Message-ID: <1328289904-22401-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <kernel@pengutronix.de>,
	<shawn.guo@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:20405
	"EHLO VA3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753592Ab2BCRZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 12:25:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"macaddr" option allows users to pass the MAC address via kernel command line.

Feedbacks from Alan Cox and David Miller (http://www.spinics.net/lists/linux-usb/msg57821.html )
mention that this is not a good idea, so remove it.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   37 ++++++++++-----------------------
 1 files changed, 11 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index e5885cc..560c3c7 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -114,10 +114,6 @@ static const struct of_device_id fec_dt_ids[] = {
 };
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
 
-static unsigned char macaddr[ETH_ALEN];
-module_param_array(macaddr, byte, NULL, 0);
-MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
-
 #if defined(CONFIG_M5272)
 /*
  * Some hardware gets it MAC address out of local flash memory.
@@ -795,31 +791,24 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
 	unsigned char *iap, tmpaddr[ETH_ALEN];
-
-	/*
-	 * try to get mac address in following order:
-	 *
-	 * 1) module parameter via kernel command line in form
-	 *    fec.macaddr=0x00,0x04,0x9f,0x01,0x30,0xe0
-	 */
-	iap = macaddr;
+	iap = tmpaddr;
 
 #ifdef CONFIG_OF
 	/*
-	 * 2) from device tree data
+	 * try to get mac address in the following order:
+	 *
+	 * 1) from device tree data
 	 */
-	if (!is_valid_ether_addr(iap)) {
-		struct device_node *np = fep->pdev->dev.of_node;
-		if (np) {
-			const char *mac = of_get_mac_address(np);
-			if (mac)
-				iap = (unsigned char *) mac;
-		}
+	struct device_node *np = fep->pdev->dev.of_node;
+	if (np) {
+		const char *mac = of_get_mac_address(np);
+		if (mac)
+			iap = (unsigned char *) mac;
 	}
 #endif
 
 	/*
-	 * 3) from flash or fuse (via platform data)
+	 * 2) from flash or fuse (via platform data)
 	 */
 	if (!is_valid_ether_addr(iap)) {
 #ifdef CONFIG_M5272
@@ -832,7 +821,7 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	}
 
 	/*
-	 * 4) FEC mac registers set by bootloader
+	 * 3) FEC mac registers set by bootloader
 	 */
 	if (!is_valid_ether_addr(iap)) {
 		*((unsigned long *) &tmpaddr[0]) =
@@ -843,10 +832,6 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	}
 
 	memcpy(ndev->dev_addr, iap, ETH_ALEN);
-
-	/* Adjust MAC if using macaddr */
-	if (iap == macaddr)
-		 ndev->dev_addr[ETH_ALEN-1] = macaddr[ETH_ALEN-1] + fep->dev_id;
 }
 
 /* ------------------------------------------------------------------------- */
-- 
1.7.1
