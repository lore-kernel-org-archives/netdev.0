From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v3 03/10] net/fec: add mac field into platform data and consolidate fec_get_mac
Date: Wed, 5 Jan 2011 22:07:30 +0800
Message-ID: <1294236457-17476-4-git-send-email-shawn.guo@freescale.com>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:57878
	"EHLO AM1EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751283Ab1AEOGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 09:06:12 -0500
In-Reply-To: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mac field into fec_platform_data and consolidate function
fec_get_mac to get mac address in following order.

 1) module parameter via kernel command line fec.macaddr=0x00,0x04,...
 2) from flash in case of CONFIG_M5272 or fec_platform_data mac
    field for others, which typically have mac stored in fuse
 3) fec mac address registers set by bootloader

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v3:
 - Use module parameter than new kernel command line to pass
   mac address
 - Change variable name and comment to remove confusing word
   "default"
 - Fix copyright breakage in fec.h

 drivers/net/fec.c   |   81 ++++++++++++++++++++++++---------------------------
 include/linux/fec.h |    3 ++
 2 files changed, 41 insertions(+), 43 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 47f6b3b..47a3c7b 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -59,15 +59,11 @@
 #define FEC_ALIGNMENT	0x3
 #endif
 
-/*
- * Define the fixed address of the FEC hardware.
- */
-#if defined(CONFIG_M5272)
-
-static unsigned char	fec_mac_default[] = {
-	0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
-};
+static unsigned char macaddr[ETH_ALEN];
+module_param_array(macaddr, byte, NULL, 0);
+MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 
+#if defined(CONFIG_M5272)
 /*
  * Some hardware gets it MAC address out of local flash memory.
  * if this is non-zero then assume it is the address to get MAC from.
@@ -537,37 +533,50 @@ rx_processing_done:
 }
 
 /* ------------------------------------------------------------------------- */
-#ifdef CONFIG_M5272
 static void __inline__ fec_get_mac(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
+	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
 	unsigned char *iap, tmpaddr[ETH_ALEN];
 
-	if (FEC_FLASHMAC) {
-		/*
-		 * Get MAC address from FLASH.
-		 * If it is all 1's or 0's, use the default.
-		 */
-		iap = (unsigned char *)FEC_FLASHMAC;
-		if ((iap[0] == 0) && (iap[1] == 0) && (iap[2] == 0) &&
-		    (iap[3] == 0) && (iap[4] == 0) && (iap[5] == 0))
-			iap = fec_mac_default;
-		if ((iap[0] == 0xff) && (iap[1] == 0xff) && (iap[2] == 0xff) &&
-		    (iap[3] == 0xff) && (iap[4] == 0xff) && (iap[5] == 0xff))
-			iap = fec_mac_default;
-	} else {
-		*((unsigned long *) &tmpaddr[0]) = readl(fep->hwp + FEC_ADDR_LOW);
-		*((unsigned short *) &tmpaddr[4]) = (readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
+	/*
+	 * try to get mac address in following order:
+	 *
+	 * 1) module parameter via kernel command line in form
+	 *    fec.macaddr=0x00,0x04,0x9f,0x01,0x30,0xe0
+	 */
+	iap = macaddr;
+
+	/*
+	 * 2) from flash or fuse (via platform data)
+	 */
+	if (!is_valid_ether_addr(iap)) {
+#ifdef CONFIG_M5272
+		if (FEC_FLASHMAC)
+			iap = (unsigned char *)FEC_FLASHMAC;
+#else
+		if (pdata)
+			memcpy(iap, pdata->mac, ETH_ALEN);
+#endif
+	}
+
+	/*
+	 * 3) FEC mac registers set by bootloader
+	 */
+	if (!is_valid_ether_addr(iap)) {
+		*((unsigned long *) &tmpaddr[0]) =
+			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
+		*((unsigned short *) &tmpaddr[4]) =
+			be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
 		iap = &tmpaddr[0];
 	}
 
 	memcpy(dev->dev_addr, iap, ETH_ALEN);
 
-	/* Adjust MAC if using default MAC address */
-	if (iap == fec_mac_default)
-		 dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->pdev->id;
+	/* Adjust MAC if using macaddr */
+	if (iap == macaddr)
+		 dev->dev_addr[ETH_ALEN-1] = macaddr[ETH_ALEN-1] + fep->pdev->id;
 }
-#endif
 
 /* ------------------------------------------------------------------------- */
 
@@ -1087,22 +1096,8 @@ static int fec_enet_init(struct net_device *dev)
 	fep->hwp = (void __iomem *)dev->base_addr;
 	fep->netdev = dev;
 
-	/* Set the Ethernet address */
-#ifdef CONFIG_M5272
+	/* Get the Ethernet address */
 	fec_get_mac(dev);
-#else
-	{
-		unsigned long l;
-		l = readl(fep->hwp + FEC_ADDR_LOW);
-		dev->dev_addr[0] = (unsigned char)((l & 0xFF000000) >> 24);
-		dev->dev_addr[1] = (unsigned char)((l & 0x00FF0000) >> 16);
-		dev->dev_addr[2] = (unsigned char)((l & 0x0000FF00) >> 8);
-		dev->dev_addr[3] = (unsigned char)((l & 0x000000FF) >> 0);
-		l = readl(fep->hwp + FEC_ADDR_HIGH);
-		dev->dev_addr[4] = (unsigned char)((l & 0xFF000000) >> 24);
-		dev->dev_addr[5] = (unsigned char)((l & 0x00FF0000) >> 16);
-	}
-#endif
 
 	/* Set receive and transmit descriptor base. */
 	fep->rx_bd_base = cbd_base;
diff --git a/include/linux/fec.h b/include/linux/fec.h
index 5d3523d..bcff455 100644
--- a/include/linux/fec.h
+++ b/include/linux/fec.h
@@ -3,6 +3,8 @@
  * Copyright (c) 2009 Orex Computed Radiography
  *   Baruch Siach <baruch@tkos.co.il>
  *
+ * Copyright (C) 2010 Freescale Semiconductor, Inc.
+ *
  * Header file for the FEC platform data
  *
  * This program is free software; you can redistribute it and/or modify
@@ -16,6 +18,7 @@
 
 struct fec_platform_data {
 	phy_interface_t phy;
+	unsigned char mac[ETH_ALEN];
 };
 
 #endif
-- 
1.7.1


