From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 2/2] net: bgmac: enable master mode for BCM54210E and B50212E PHYs
Date: Thu, 12 Oct 2017 10:21:26 +0200
Message-ID: <20171012082126.30660-3-zajec5@gmail.com>
References: <20171012082126.30660-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>,
        Jon Mason <jon.mason@broadcom.com>,
        Steve Lin <steven.lin1@broadcom.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        bcm-kernel-feedback-list@broadcom.com,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:46127 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753246AbdJLIWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 04:22:32 -0400
Received: by mail-lf0-f68.google.com with SMTP id g70so5051099lfl.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 01:22:31 -0700 (PDT)
In-Reply-To: <20171012082126.30660-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

There are 4 very similar PHYs:
0x600d84a1: BCM54210E (rev B0)
0x600d84a2: BCM54210E (rev B1)
0x600d84a5: B50212E (rev B0)
0x600d84a6: B50212E (rev B1)
that need setting master mode manually. It's because they run in slave
mode by default with Automatic Slave/Master configuration disabled which
can lead to unreliable connection with massive ping loss.

So far it was reported for a board with BCM47189 SoC and B50212E B1 PHY
connected to the bgmac supported ethernet device. Telling PHY driver to
setup PHY properly solves this issue.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/ethernet/broadcom/bgmac-bcma.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
index 6322594ab260..6fe074c1588b 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -184,13 +184,19 @@ static int bgmac_probe(struct bcma_device *core)
 
 	if (!bgmac_is_bcm4707_family(core) &&
 	    !(ci->id == BCMA_CHIP_ID_BCM53573 && core->core_unit == 1)) {
+		struct phy_device *phydev;
+
 		mii_bus = bcma_mdio_mii_register(bgmac);
 		if (IS_ERR(mii_bus)) {
 			err = PTR_ERR(mii_bus);
 			goto err;
 		}
-
 		bgmac->mii_bus = mii_bus;
+
+		phydev = mdiobus_get_phy(bgmac->mii_bus, bgmac->phyaddr);
+		if (ci->id == BCMA_CHIP_ID_BCM53573 && phydev &&
+		    (phydev->drv->phy_id & phydev->drv->phy_id_mask) == PHY_ID_BCM54210E)
+			phydev->dev_flags |= PHY_BRCM_EN_MASTER_MODE;
 	}
 
 	if (core->bus->hosttype == BCMA_HOSTTYPE_PCI) {
-- 
2.11.0
