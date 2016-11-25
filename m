From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH 2/2] net: phy: realtek: fix enabling of the TX-delay for RTL8211F
Date: Fri, 25 Nov 2016 14:12:01 +0100
Message-ID: <20161125131201.19994-3-martin.blumenstingl@googlemail.com>
References: <20161125131201.19994-1-martin.blumenstingl@googlemail.com>
Cc: linux-amlogic@lists.infradead.org, jbrunet@baylibre.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        davem@davemloft.net, sean.wang@mediatek.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35543 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753305AbcKYN1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 08:27:34 -0500
In-Reply-To: <20161125131201.19994-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The old logic always enabled the TX-delay when the phy-mode was set to
PHY_INTERFACE_MODE_RGMII. There are dedicated phy-modes which tell the
PHY driver to enable the RX and/or TX delays:
- PHY_INTERFACE_MODE_RGMII should disable the RX and TX delay in the
  PHY (if required, the MAC should add the delays in this case)
- PHY_INTERFACE_MODE_RGMII_ID should enable RX and TX delay in the PHY
- PHY_INTERFACE_MODE_RGMII_TXID should enable the TX delay in the PHY
- PHY_INTERFACE_MODE_RGMII_RXID should enable the RX delay in the PHY
  (currently not supported by RTL8211F)

With this patch we enable the TX delay for PHY_INTERFACE_MODE_RGMII_ID
and PHY_INTERFACE_MODE_RGMII_TXID.
Additionally we now explicity disable the TX-delay, which seems to be
enabled automatically after a hard-reset of the PHY (by triggering it's
reset pin) to get a consistent state (as defined by the phy-mode).

This fixes a compatibility problem with some SoCs where the TX-delay was
also added by the MAC. With the TX-delay being applied twice the TX
clock was off and TX traffic was broken or very slow (<10Mbit/s) on
1000Mbit/s links.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 drivers/net/phy/realtek.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index aadd6e9..9cbe645 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -102,15 +102,19 @@ static int rtl8211f_config_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
-		/* enable TXDLY */
-		phy_write(phydev, RTL8211F_PAGE_SELECT, 0xd08);
-		reg = phy_read(phydev, 0x11);
+	phy_write(phydev, RTL8211F_PAGE_SELECT, 0xd08);
+	reg = phy_read(phydev, 0x11);
+
+	/* enable TX-delay for rgmii-id and rgmii-txid, otherwise disable it */
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
+	    phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
 		reg |= RTL8211F_TX_DELAY;
-		phy_write(phydev, 0x11, reg);
-		/* restore to default page 0 */
-		phy_write(phydev, RTL8211F_PAGE_SELECT, 0x0);
-	}
+	else
+		reg &= ~RTL8211F_TX_DELAY;
+
+	phy_write(phydev, 0x11, reg);
+	/* restore to default page 0 */
+	phy_write(phydev, RTL8211F_PAGE_SELECT, 0x0);
 
 	return 0;
 }
-- 
2.10.2
