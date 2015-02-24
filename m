From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe-phy: PHY KX/KR mode differences
Date: Tue, 24 Feb 2015 10:47:49 -0600
Message-ID: <20150224164749.26012.40351.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0105.outbound.protection.outlook.com ([65.55.169.105]:20261
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752970AbbBXQrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 11:47:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY requires different settings for the Decision Feedback Analyzer
(DFE) when running in KX mode vs. KR mode. Update the code to change
these settings when changing modes in order to provide a more stable
link.

Additionally, adjust the 10GbE PQ skew default setting to a more sane
value.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 .../devicetree/bindings/net/amd-xgbe-phy.txt       |    4 +
 drivers/net/phy/amd-xgbe-phy.c                     |   82 ++++++++++++++++++++
 2 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
index 33df393..8db3238 100644
--- a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
+++ b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
@@ -27,6 +27,8 @@ property is used.
 - amd,serdes-cdr-rate: CDR rate speed selection
 - amd,serdes-pq-skew: PQ (data sampling) skew
 - amd,serdes-tx-amp: TX amplitude boost
+- amd,serdes-dfe-tap-config: DFE taps available to run
+- amd,serdes-dfe-tap-enable: DFE taps to enable
 
 Example:
 	xgbe_phy@e1240800 {
@@ -41,4 +43,6 @@ Example:
 		amd,serdes-cdr-rate = <2>, <2>, <7>;
 		amd,serdes-pq-skew = <10>, <10>, <30>;
 		amd,serdes-tx-amp = <15>, <15>, <10>;
+		amd,serdes-dfe-tap-config = <3>, <3>, <1>;
+		amd,serdes-dfe-tap-enable = <0>, <0>, <127>;
 	};
diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 9e3af54..32efbd4 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -92,6 +92,8 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XGBE_PHY_CDR_RATE_PROPERTY	"amd,serdes-cdr-rate"
 #define XGBE_PHY_PQ_SKEW_PROPERTY	"amd,serdes-pq-skew"
 #define XGBE_PHY_TX_AMP_PROPERTY	"amd,serdes-tx-amp"
+#define XGBE_PHY_DFE_CFG_PROPERTY	"amd,serdes-dfe-tap-config"
+#define XGBE_PHY_DFE_ENA_PROPERTY	"amd,serdes-dfe-tap-enable"
 
 #define XGBE_PHY_SPEEDS			3
 #define XGBE_PHY_SPEED_1000		0
@@ -177,10 +179,12 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define SPEED_10000_BLWC		0
 #define SPEED_10000_CDR			0x7
 #define SPEED_10000_PLL			0x1
-#define SPEED_10000_PQ			0x1e
+#define SPEED_10000_PQ			0x12
 #define SPEED_10000_RATE		0x0
 #define SPEED_10000_TXAMP		0xa
 #define SPEED_10000_WORD		0x7
+#define SPEED_10000_DFE_TAP_CONFIG	0x1
+#define SPEED_10000_DFE_TAP_ENABLE	0x7f
 
 #define SPEED_2500_BLWC			1
 #define SPEED_2500_CDR			0x2
@@ -189,6 +193,8 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define SPEED_2500_RATE			0x1
 #define SPEED_2500_TXAMP		0xf
 #define SPEED_2500_WORD			0x1
+#define SPEED_2500_DFE_TAP_CONFIG	0x3
+#define SPEED_2500_DFE_TAP_ENABLE	0x0
 
 #define SPEED_1000_BLWC			1
 #define SPEED_1000_CDR			0x2
@@ -197,16 +203,25 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define SPEED_1000_RATE			0x3
 #define SPEED_1000_TXAMP		0xf
 #define SPEED_1000_WORD			0x1
+#define SPEED_1000_DFE_TAP_CONFIG	0x3
+#define SPEED_1000_DFE_TAP_ENABLE	0x0
 
 /* SerDes RxTx register offsets */
+#define RXTX_REG6			0x0018
 #define RXTX_REG20			0x0050
+#define RXTX_REG22			0x0058
 #define RXTX_REG114			0x01c8
+#define RXTX_REG129			0x0204
 
 /* SerDes RxTx register entry bit positions and sizes */
+#define RXTX_REG6_RESETB_RXD_INDEX	8
+#define RXTX_REG6_RESETB_RXD_WIDTH	1
 #define RXTX_REG20_BLWC_ENA_INDEX	2
 #define RXTX_REG20_BLWC_ENA_WIDTH	1
 #define RXTX_REG114_PQ_REG_INDEX	9
 #define RXTX_REG114_PQ_REG_WIDTH	7
+#define RXTX_REG129_RXDFE_CONFIG_INDEX	14
+#define RXTX_REG129_RXDFE_CONFIG_WIDTH	2
 
 /* Bit setting and getting macros
  *  The get macro will extract the current bit field value from within
@@ -333,6 +348,18 @@ static const u32 amd_xgbe_phy_serdes_tx_amp[] = {
 	SPEED_10000_TXAMP,
 };
 
+static const u32 amd_xgbe_phy_serdes_dfe_tap_cfg[] = {
+	SPEED_1000_DFE_TAP_CONFIG,
+	SPEED_2500_DFE_TAP_CONFIG,
+	SPEED_10000_DFE_TAP_CONFIG,
+};
+
+static const u32 amd_xgbe_phy_serdes_dfe_tap_ena[] = {
+	SPEED_1000_DFE_TAP_ENABLE,
+	SPEED_2500_DFE_TAP_ENABLE,
+	SPEED_10000_DFE_TAP_ENABLE,
+};
+
 enum amd_xgbe_phy_an {
 	AMD_XGBE_AN_READY = 0,
 	AMD_XGBE_AN_PAGE_RECEIVED,
@@ -393,6 +420,8 @@ struct amd_xgbe_phy_priv {
 	u32 serdes_cdr_rate[XGBE_PHY_SPEEDS];
 	u32 serdes_pq_skew[XGBE_PHY_SPEEDS];
 	u32 serdes_tx_amp[XGBE_PHY_SPEEDS];
+	u32 serdes_dfe_tap_cfg[XGBE_PHY_SPEEDS];
+	u32 serdes_dfe_tap_ena[XGBE_PHY_SPEEDS];
 
 	/* Auto-negotiation state machine support */
 	struct mutex an_mutex;
@@ -481,11 +510,16 @@ static void amd_xgbe_phy_serdes_complete_ratechange(struct phy_device *phydev)
 		status = XSIR0_IOREAD(priv, SIR0_STATUS);
 		if (XSIR_GET_BITS(status, SIR0_STATUS, RX_READY) &&
 		    XSIR_GET_BITS(status, SIR0_STATUS, TX_READY))
-			return;
+			goto rx_reset;
 	}
 
 	netdev_dbg(phydev->attached_dev, "SerDes rx/tx not ready (%#hx)\n",
 		   status);
+
+rx_reset:
+	/* Perform Rx reset for the DFE changes */
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG6, RESETB_RXD, 0);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG6, RESETB_RXD, 1);
 }
 
 static int amd_xgbe_phy_xgmii_mode(struct phy_device *phydev)
@@ -534,6 +568,10 @@ static int amd_xgbe_phy_xgmii_mode(struct phy_device *phydev)
 			   priv->serdes_blwc[XGBE_PHY_SPEED_10000]);
 	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG,
 			   priv->serdes_pq_skew[XGBE_PHY_SPEED_10000]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG129, RXDFE_CONFIG,
+			   priv->serdes_dfe_tap_cfg[XGBE_PHY_SPEED_10000]);
+	XRXTX_IOWRITE(priv, RXTX_REG22,
+		      priv->serdes_dfe_tap_ena[XGBE_PHY_SPEED_10000]);
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
@@ -586,6 +624,10 @@ static int amd_xgbe_phy_gmii_2500_mode(struct phy_device *phydev)
 			   priv->serdes_blwc[XGBE_PHY_SPEED_2500]);
 	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG,
 			   priv->serdes_pq_skew[XGBE_PHY_SPEED_2500]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG129, RXDFE_CONFIG,
+			   priv->serdes_dfe_tap_cfg[XGBE_PHY_SPEED_2500]);
+	XRXTX_IOWRITE(priv, RXTX_REG22,
+		      priv->serdes_dfe_tap_ena[XGBE_PHY_SPEED_2500]);
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
@@ -638,6 +680,10 @@ static int amd_xgbe_phy_gmii_mode(struct phy_device *phydev)
 			   priv->serdes_blwc[XGBE_PHY_SPEED_1000]);
 	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG,
 			   priv->serdes_pq_skew[XGBE_PHY_SPEED_1000]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG129, RXDFE_CONFIG,
+			   priv->serdes_dfe_tap_cfg[XGBE_PHY_SPEED_1000]);
+	XRXTX_IOWRITE(priv, RXTX_REG22,
+		      priv->serdes_dfe_tap_ena[XGBE_PHY_SPEED_1000]);
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
@@ -1668,6 +1714,38 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		       sizeof(priv->serdes_tx_amp));
 	}
 
+	if (device_property_present(phy_dev, XGBE_PHY_DFE_CFG_PROPERTY)) {
+		ret = device_property_read_u32_array(phy_dev,
+						     XGBE_PHY_DFE_CFG_PROPERTY,
+						     priv->serdes_dfe_tap_cfg,
+						     XGBE_PHY_SPEEDS);
+		if (ret) {
+			dev_err(dev, "invalid %s property\n",
+				XGBE_PHY_DFE_CFG_PROPERTY);
+			goto err_sir1;
+		}
+	} else {
+		memcpy(priv->serdes_dfe_tap_cfg,
+		       amd_xgbe_phy_serdes_dfe_tap_cfg,
+		       sizeof(priv->serdes_dfe_tap_cfg));
+	}
+
+	if (device_property_present(phy_dev, XGBE_PHY_DFE_ENA_PROPERTY)) {
+		ret = device_property_read_u32_array(phy_dev,
+						     XGBE_PHY_DFE_ENA_PROPERTY,
+						     priv->serdes_dfe_tap_ena,
+						     XGBE_PHY_SPEEDS);
+		if (ret) {
+			dev_err(dev, "invalid %s property\n",
+				XGBE_PHY_DFE_ENA_PROPERTY);
+			goto err_sir1;
+		}
+	} else {
+		memcpy(priv->serdes_dfe_tap_ena,
+		       amd_xgbe_phy_serdes_dfe_tap_ena,
+		       sizeof(priv->serdes_dfe_tap_ena));
+	}
+
 	phydev->priv = priv;
 
 	if (!priv->adev || acpi_disabled)
