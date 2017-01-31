From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V3 3/3] net: bgmac: use PHY subsystem for initializing PHY
Date: Tue, 31 Jan 2017 19:37:56 +0100
Message-ID: <20170131183756.20395-4-zajec5@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
 <20170131183756.20395-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34808 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbdAaSiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:38:22 -0500
Received: by mail-lf0-f65.google.com with SMTP id q89so34643492lfi.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:38:22 -0800 (PST)
In-Reply-To: <20170131183756.20395-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

This adds support for using bgmac with PHYs supported by standalone PHY
drivers. Having any PHY initialization in bgmac is hacky and shouldn't
be extended but rather removed if anyone has hardware to test it.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
index 9d9984999dce..6ce80cbcb48e 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
@@ -132,6 +132,10 @@ static void bcma_mdio_phy_init(struct bgmac *bgmac)
 	struct bcma_chipinfo *ci = &bgmac->bcma.core->bus->chipinfo;
 	u8 i;
 
+	/* For some legacy hardware we do chipset-based PHY initialization here
+	 * without even detecting PHY ID. It's hacky and should be cleaned as
+	 * soon as someone can test it.
+	 */
 	if (ci->id == BCMA_CHIP_ID_BCM5356) {
 		for (i = 0; i < 5; i++) {
 			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x008b);
@@ -140,6 +144,7 @@ static void bcma_mdio_phy_init(struct bgmac *bgmac)
 			bcma_mdio_phy_write(bgmac, i, 0x12, 0x2aaa);
 			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000b);
 		}
+		return;
 	}
 	if ((ci->id == BCMA_CHIP_ID_BCM5357 && ci->pkg != 10) ||
 	    (ci->id == BCMA_CHIP_ID_BCM4749 && ci->pkg != 10) ||
@@ -161,7 +166,12 @@ static void bcma_mdio_phy_init(struct bgmac *bgmac)
 			bcma_mdio_phy_write(bgmac, i, 0x17, 0x9273);
 			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000b);
 		}
+		return;
 	}
+
+	/* For all other hw do initialization using PHY subsystem. */
+	if (bgmac->net_dev && bgmac->net_dev->phydev)
+		phy_init_hw(bgmac->net_dev->phydev);
 }
 
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyreset */
-- 
2.11.0
