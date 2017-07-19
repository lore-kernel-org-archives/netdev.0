From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH 1/2] net: phy: at803x: Fix RGMII RX and TX clock delays setup
Date: Wed, 19 Jul 2017 17:31:56 +0200
Message-ID: <33ed5f4f-9939-dc00-b973-db39c16f2393@sigmadesigns.com>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:38990 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933565AbdGSPkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 11:40:21 -0400
In-Reply-To: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code supports enabling RGMII RX and TX clock delays.
The unstated assumption is that these settings are disabled by
default at reset, which is not the case.

RX clock delay is enabled at reset. And TX clock delay "survives"
across SW resets. Thus, if the bootloader enables TX clock delay,
it will remain enabled at reset in Linux.

Provide disable functions to configure the RGMII clock delays
exactly as specified in the fwspec.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 drivers/net/phy/at803x.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index c1e52b9dc58d..9c96eaaaa2cb 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -117,12 +117,24 @@ static inline int at803x_enable_rx_delay(struct phy_device *phydev)
 					AT803X_DEBUG_RX_CLK_DLY_EN);
 }
 
+static inline int at803x_disable_rx_delay(struct phy_device *phydev)
+{
+	return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0,
+					AT803X_DEBUG_RX_CLK_DLY_EN, 0);
+}
+
 static inline int at803x_enable_tx_delay(struct phy_device *phydev)
 {
 	return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5, 0,
 					AT803X_DEBUG_TX_CLK_DLY_EN);
 }
 
+static inline int at803x_disable_tx_delay(struct phy_device *phydev)
+{
+	return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5,
+					AT803X_DEBUG_TX_CLK_DLY_EN, 0);
+}
+
 /* save relevant PHY registers to private copy */
 static void at803x_context_save(struct phy_device *phydev,
 				struct at803x_context *context)
@@ -284,18 +296,22 @@ static int at803x_config_init(struct phy_device *phydev)
 		return ret;
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID ||
-			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
+			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
 		ret = at803x_enable_rx_delay(phydev);
-		if (ret < 0)
-			return ret;
-	}
+	else
+		ret = at803x_disable_rx_delay(phydev);
+
+	if (ret < 0)
+		return ret;
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID ||
-			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
+			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
 		ret = at803x_enable_tx_delay(phydev);
-		if (ret < 0)
-			return ret;
-	}
+	else
+		ret = at803x_disable_tx_delay(phydev);
+
+	if (ret < 0)
+		return ret;
 
 	return 0;
 }
-- 
2.11.0
