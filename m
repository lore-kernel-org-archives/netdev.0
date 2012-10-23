From: Paolo Pisati <p.pisati@gmail.com>
Subject: [PATCH 6/6] fec: remove mac address handling as a module parameter
Date: Tue, 23 Oct 2012 19:15:33 +0200
Message-ID: <1351012533-3524-7-git-send-email-p.pisati@gmail.com>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:45173 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab2JWRRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:17:17 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so3893295wib.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:17:16 -0700 (PDT)
In-Reply-To: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paolo Pisati <p.pisati@gmail.com>
---
 drivers/net/ethernet/freescale/fec.c |   27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index c136230..d5bb97d 100644
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
@@ -786,21 +782,16 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
-	unsigned char *iap, tmpaddr[ETH_ALEN];
+	unsigned char *iap = NULL, tmpaddr[ETH_ALEN];
 
 	/*
 	 * try to get mac address in following order:
-	 *
-	 * 1) module parameter via kernel command line in form
-	 *    fec.macaddr=0x00,0x04,0x9f,0x01,0x30,0xe0
 	 */
-	iap = macaddr;
-
 #ifdef CONFIG_OF
 	/*
-	 * 2) from device tree data
+	 * 1) from device tree data
 	 */
-	if (!is_valid_ether_addr(iap)) {
+	{
 		struct device_node *np = fep->pdev->dev.of_node;
 		if (np) {
 			const char *mac = of_get_mac_address(np);
@@ -811,9 +802,9 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 #endif
 
 	/*
-	 * 3) from flash or fuse (via platform data)
+	 * 2) from flash or fuse (via platform data)
 	 */
-	if (!is_valid_ether_addr(iap)) {
+	if (iap == NULL || !is_valid_ether_addr(iap)) {
 #ifdef CONFIG_M5272
 		if (FEC_FLASHMAC)
 			iap = (unsigned char *)FEC_FLASHMAC;
@@ -824,9 +815,9 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	}
 
 	/*
-	 * 4) FEC mac registers set by bootloader
+	 * 3) FEC mac registers set by bootloader
 	 */
-	if (!is_valid_ether_addr(iap)) {
+	if (iap == NULL || !is_valid_ether_addr(iap)) {
 		*((unsigned long *) &tmpaddr[0]) =
 			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
 		*((unsigned short *) &tmpaddr[4]) =
@@ -835,10 +826,6 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	}
 
 	memcpy(ndev->dev_addr, iap, ETH_ALEN);
-
-	/* Adjust MAC if using macaddr */
-	if (iap == macaddr)
-		 ndev->dev_addr[ETH_ALEN-1] = macaddr[ETH_ALEN-1] + fep->dev_id;
 }
 
 /* ------------------------------------------------------------------------- */
-- 
1.7.9.5
