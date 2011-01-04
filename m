From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v2 03/10] net/fec: add mac field into platform data and consolidate fec_get_mac
Date: Tue, 4 Jan 2011 17:24:09 +0800
Message-ID: <1294133056-21195-4-git-send-email-shawn.guo@freescale.com>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:9487 "EHLO
	VA3EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750853Ab1ADJXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 04:23:04 -0500
In-Reply-To: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mac field into fec_platform_data and consolidate function
fec_get_mac to get mac address in following order.

 1) kernel command line fec_mac=xx:xx:xx...
 2) from flash in case of CONFIG_M5272 or fec_platform_data mac
    field for others, which typically have mac stored in fuse
 3) fec mac address registers set by bootloader

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
 drivers/net/fec.c   |   90 ++++++++++++++++++++++++++++----------------------
 include/linux/fec.h |    2 +
 2 files changed, 52 insertions(+), 40 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 47f6b3b..cd59814 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -59,15 +59,9 @@
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
+static unsigned char fec_mac_default[ETH_ALEN];
 
+#if defined(CONFIG_M5272)
 /*
  * Some hardware gets it MAC address out of local flash memory.
  * if this is non-zero then assume it is the address to get MAC from.
@@ -537,27 +531,40 @@ rx_processing_done:
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
+	 * 1) kernel command line fec_mac=xx:xx:xx...
+	 */
+	iap = fec_mac_default;
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
 
@@ -567,7 +574,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 	if (iap == fec_mac_default)
 		 dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->pdev->id;
 }
-#endif
 
 /* ------------------------------------------------------------------------- */
 
@@ -1063,6 +1069,24 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_do_ioctl           = fec_enet_ioctl,
 };
 
+static int __init fec_mac_addr_setup(char *mac_addr)
+{
+	int i;
+	unsigned int tmp;
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		if (sscanf(mac_addr + 3*i, "%2x", &tmp) != 1) {
+			printk(KERN_WARNING "Malformed fec mac address\n");
+			return 0;
+		}
+		fec_mac_default[i] = tmp;
+	}
+
+	return 1;
+}
+
+__setup("fec_mac=", fec_mac_addr_setup);
+
  /*
   * XXX:  We need to clean up on failure exits here.
   *
@@ -1087,22 +1111,8 @@ static int fec_enet_init(struct net_device *dev)
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
index 5d3523d..bf0c69f 100644
--- a/include/linux/fec.h
+++ b/include/linux/fec.h
@@ -1,6 +1,7 @@
 /* include/linux/fec.h
  *
  * Copyright (c) 2009 Orex Computed Radiography
+ * Copyright (C) 2010 Freescale Semiconductor, Inc.
  *   Baruch Siach <baruch@tkos.co.il>
  *
  * Header file for the FEC platform data
@@ -16,6 +17,7 @@
 
 struct fec_platform_data {
 	phy_interface_t phy;
+	unsigned char mac[ETH_ALEN];
 };
 
 #endif
-- 
1.7.1


