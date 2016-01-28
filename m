From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 36/40] net: fec: use mac set by bootloader before fuses
Date: Thu, 28 Jan 2016 14:26:00 -0700
Message-ID: <1454016364-30985-37-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34447 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967843AbcA1V3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:29:09 -0500
Received: by mail-pa0-f46.google.com with SMTP id uo6so29726221pac.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:29:09 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a bootloader initializes the mac, prefer that
to device tree or fuses.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 33 +++++++++++++------------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9db645d..11968a9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1625,16 +1625,24 @@ static void fec_get_mac(struct net_device *ndev)
 	struct fec_platform_data *pdata = dev_get_platdata(&fep->pdev->dev);
 	unsigned char *iap, tmpaddr[ETH_ALEN];
 
-	/*
-	 * try to get mac address in following order:
+	/* try to get mac address in following order:
 	 *
 	 * 1) module parameter via kernel command line in form
 	 *    fec.macaddr=0x00,0x04,0x9f,0x01,0x30,0xe0
 	 */
 	iap = macaddr;
 
-	/*
-	 * 2) from device tree data
+	/* 2) FEC mac registers set by bootloader
+	 */
+	if (!is_valid_ether_addr(iap)) {
+		*((__be32 *)&tmpaddr[0]) =
+			cpu_to_be32(readl(fep->hwp + FEC_ADDR_LOW));
+		*((__be16 *)&tmpaddr[4]) =
+			cpu_to_be16(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
+		iap = &tmpaddr[0];
+	}
+
+	/* 3) from device tree data
 	 */
 	if (!is_valid_ether_addr(iap)) {
 		struct device_node *np = fep->pdev->dev.of_node;
@@ -1645,8 +1653,7 @@ static void fec_get_mac(struct net_device *ndev)
 		}
 	}
 
-	/*
-	 * 3) from flash or fuse (via platform data)
+	/* 4) from flash or fuse (via platform data)
 	 */
 	if (!is_valid_ether_addr(iap)) {
 #ifdef CONFIG_M5272
@@ -1658,19 +1665,7 @@ static void fec_get_mac(struct net_device *ndev)
 #endif
 	}
 
-	/*
-	 * 4) FEC mac registers set by bootloader
-	 */
-	if (!is_valid_ether_addr(iap)) {
-		*((__be32 *) &tmpaddr[0]) =
-			cpu_to_be32(readl(fep->hwp + FEC_ADDR_LOW));
-		*((__be16 *) &tmpaddr[4]) =
-			cpu_to_be16(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
-		iap = &tmpaddr[0];
-	}
-
-	/*
-	 * 5) random mac address
+	/* 5) random mac address
 	 */
 	if (!is_valid_ether_addr(iap)) {
 		/* Report it and use a random ethernet address instead */
-- 
2.5.0
