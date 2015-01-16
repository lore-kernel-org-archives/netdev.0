From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 12/12] amd-xgbe-phy: Allow certain PHY settings
 to be set by UEFI
Date: Fri, 16 Jan 2015 12:47:21 -0600
Message-ID: <20150116184721.18809.55035.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44023 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756793AbbAPSy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:29 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Certain PHY settings need to be configurable by UEFI depending on the
platform being used.  Add new device tree / ACPI properties that, if
present, will override the pre-determined values currently used.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 .../devicetree/bindings/net/amd-xgbe-phy.txt       |   16 ++
 drivers/net/phy/amd-xgbe-phy.c                     |  159 +++++++++++++++++---
 2 files changed, 152 insertions(+), 23 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
index d54fe1a..33df393 100644
--- a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
+++ b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
@@ -16,6 +16,18 @@ Optional properties:
     0 - 1GbE and 10GbE (default)
     1 - 2.5GbE and 10GbE
 
+The following optional properties are represented by an array with each
+value corresponding to a particular speed. The first array value represents
+the setting for the 1GbE speed, the second value for the 2.5GbE speed and
+the third value for the 10GbE speed.  All three values are required if the
+property is used.
+- amd,serdes-blwc: Baseline wandering correction enablement
+    0 - Off
+    1 - On
+- amd,serdes-cdr-rate: CDR rate speed selection
+- amd,serdes-pq-skew: PQ (data sampling) skew
+- amd,serdes-tx-amp: TX amplitude boost
+
 Example:
 	xgbe_phy@e1240800 {
 		compatible = "amd,xgbe-phy-seattle-v1a", "ethernet-phy-ieee802.3-c45";
@@ -25,4 +37,8 @@ Example:
 		interrupt-parent = <&gic>;
 		interrupts = <0 323 4>;
 		amd,speed-set = <0>;
+		amd,serdes-blwc = <1>, <1>, <0>;
+		amd,serdes-cdr-rate = <2>, <2>, <7>;
+		amd,serdes-pq-skew = <10>, <10>, <30>;
+		amd,serdes-tx-amp = <15>, <15>, <10>;
 	};
diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 2f210743..9e3af54 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -88,6 +88,15 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XGBE_PHY_MASK	0xfffffff0
 
 #define XGBE_PHY_SPEEDSET_PROPERTY	"amd,speed-set"
+#define XGBE_PHY_BLWC_PROPERTY		"amd,serdes-blwc"
+#define XGBE_PHY_CDR_RATE_PROPERTY	"amd,serdes-cdr-rate"
+#define XGBE_PHY_PQ_SKEW_PROPERTY	"amd,serdes-pq-skew"
+#define XGBE_PHY_TX_AMP_PROPERTY	"amd,serdes-tx-amp"
+
+#define XGBE_PHY_SPEEDS			3
+#define XGBE_PHY_SPEED_1000		0
+#define XGBE_PHY_SPEED_2500		1
+#define XGBE_PHY_SPEED_10000		2
 
 #define XGBE_AN_INT_CMPLT		0x01
 #define XGBE_AN_INC_LINK		0x02
@@ -152,10 +161,10 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define SIR0_STATUS_RX_READY_WIDTH	1
 #define SIR0_STATUS_TX_READY_INDEX	8
 #define SIR0_STATUS_TX_READY_WIDTH	1
+#define SIR1_SPEED_CDR_RATE_INDEX	12
+#define SIR1_SPEED_CDR_RATE_WIDTH	4
 #define SIR1_SPEED_DATARATE_INDEX	4
 #define SIR1_SPEED_DATARATE_WIDTH	2
-#define SIR1_SPEED_PI_SPD_SEL_INDEX	12
-#define SIR1_SPEED_PI_SPD_SEL_WIDTH	4
 #define SIR1_SPEED_PLLSEL_INDEX		3
 #define SIR1_SPEED_PLLSEL_WIDTH		1
 #define SIR1_SPEED_RATECHANGE_INDEX	6
@@ -165,20 +174,26 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define SIR1_SPEED_WORDMODE_INDEX	0
 #define SIR1_SPEED_WORDMODE_WIDTH	3
 
+#define SPEED_10000_BLWC		0
 #define SPEED_10000_CDR			0x7
 #define SPEED_10000_PLL			0x1
+#define SPEED_10000_PQ			0x1e
 #define SPEED_10000_RATE		0x0
 #define SPEED_10000_TXAMP		0xa
 #define SPEED_10000_WORD		0x7
 
+#define SPEED_2500_BLWC			1
 #define SPEED_2500_CDR			0x2
 #define SPEED_2500_PLL			0x0
+#define SPEED_2500_PQ			0xa
 #define SPEED_2500_RATE			0x1
 #define SPEED_2500_TXAMP		0xf
 #define SPEED_2500_WORD			0x1
 
+#define SPEED_1000_BLWC			1
 #define SPEED_1000_CDR			0x2
 #define SPEED_1000_PLL			0x0
+#define SPEED_1000_PQ			0xa
 #define SPEED_1000_RATE			0x3
 #define SPEED_1000_TXAMP		0xf
 #define SPEED_1000_WORD			0x1
@@ -193,15 +208,6 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define RXTX_REG114_PQ_REG_INDEX	9
 #define RXTX_REG114_PQ_REG_WIDTH	7
 
-#define RXTX_10000_BLWC			0
-#define RXTX_10000_PQ			0x1e
-
-#define RXTX_2500_BLWC			1
-#define RXTX_2500_PQ			0xa
-
-#define RXTX_1000_BLWC			1
-#define RXTX_1000_PQ			0xa
-
 /* Bit setting and getting macros
  *  The get macro will extract the current bit field value from within
  *  the variable
@@ -303,6 +309,30 @@ do {									\
 	XRXTX_IOWRITE((_priv), _reg, reg_val);				\
 } while (0)
 
+static const u32 amd_xgbe_phy_serdes_blwc[] = {
+	SPEED_1000_BLWC,
+	SPEED_2500_BLWC,
+	SPEED_10000_BLWC,
+};
+
+static const u32 amd_xgbe_phy_serdes_cdr_rate[] = {
+	SPEED_1000_CDR,
+	SPEED_2500_CDR,
+	SPEED_10000_CDR,
+};
+
+static const u32 amd_xgbe_phy_serdes_pq_skew[] = {
+	SPEED_1000_PQ,
+	SPEED_2500_PQ,
+	SPEED_10000_PQ,
+};
+
+static const u32 amd_xgbe_phy_serdes_tx_amp[] = {
+	SPEED_1000_TXAMP,
+	SPEED_2500_TXAMP,
+	SPEED_10000_TXAMP,
+};
+
 enum amd_xgbe_phy_an {
 	AMD_XGBE_AN_READY = 0,
 	AMD_XGBE_AN_PAGE_RECEIVED,
@@ -353,6 +383,17 @@ struct amd_xgbe_phy_priv {
 
 	unsigned int speed_set;
 
+	/* SerDes UEFI configurable settings.
+	 *   Switching between modes/speeds requires new values for some
+	 *   SerDes settings.  The values can be supplied as device
+	 *   properties in array format.  The first array entry is for
+	 *   1GbE, second for 2.5GbE and third for 10GbE
+	 */
+	u32 serdes_blwc[XGBE_PHY_SPEEDS];
+	u32 serdes_cdr_rate[XGBE_PHY_SPEEDS];
+	u32 serdes_pq_skew[XGBE_PHY_SPEEDS];
+	u32 serdes_tx_amp[XGBE_PHY_SPEEDS];
+
 	/* Auto-negotiation state machine support */
 	struct mutex an_mutex;
 	enum amd_xgbe_phy_an an_result;
@@ -483,12 +524,16 @@ static int amd_xgbe_phy_xgmii_mode(struct phy_device *phydev)
 
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, DATARATE, SPEED_10000_RATE);
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, WORDMODE, SPEED_10000_WORD);
-	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, TXAMP, SPEED_10000_TXAMP);
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, PLLSEL, SPEED_10000_PLL);
-	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, PI_SPD_SEL, SPEED_10000_CDR);
 
-	XRXTX_IOWRITE_BITS(priv, RXTX_REG20, BLWC_ENA, RXTX_10000_BLWC);
-	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG, RXTX_10000_PQ);
+	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, CDR_RATE,
+			   priv->serdes_cdr_rate[XGBE_PHY_SPEED_10000]);
+	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, TXAMP,
+			   priv->serdes_tx_amp[XGBE_PHY_SPEED_10000]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG20, BLWC_ENA,
+			   priv->serdes_blwc[XGBE_PHY_SPEED_10000]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG,
+			   priv->serdes_pq_skew[XGBE_PHY_SPEED_10000]);
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
@@ -531,12 +576,16 @@ static int amd_xgbe_phy_gmii_2500_mode(struct phy_device *phydev)
 
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, DATARATE, SPEED_2500_RATE);
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, WORDMODE, SPEED_2500_WORD);
-	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, TXAMP, SPEED_2500_TXAMP);
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, PLLSEL, SPEED_2500_PLL);
-	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, PI_SPD_SEL, SPEED_2500_CDR);
 
-	XRXTX_IOWRITE_BITS(priv, RXTX_REG20, BLWC_ENA, RXTX_2500_BLWC);
-	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG, RXTX_2500_PQ);
+	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, CDR_RATE,
+			   priv->serdes_cdr_rate[XGBE_PHY_SPEED_2500]);
+	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, TXAMP,
+			   priv->serdes_tx_amp[XGBE_PHY_SPEED_2500]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG20, BLWC_ENA,
+			   priv->serdes_blwc[XGBE_PHY_SPEED_2500]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG,
+			   priv->serdes_pq_skew[XGBE_PHY_SPEED_2500]);
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
@@ -579,12 +628,16 @@ static int amd_xgbe_phy_gmii_mode(struct phy_device *phydev)
 
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, DATARATE, SPEED_1000_RATE);
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, WORDMODE, SPEED_1000_WORD);
-	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, TXAMP, SPEED_1000_TXAMP);
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, PLLSEL, SPEED_1000_PLL);
-	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, PI_SPD_SEL, SPEED_1000_CDR);
 
-	XRXTX_IOWRITE_BITS(priv, RXTX_REG20, BLWC_ENA, RXTX_1000_BLWC);
-	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG, RXTX_1000_PQ);
+	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, CDR_RATE,
+			   priv->serdes_cdr_rate[XGBE_PHY_SPEED_1000]);
+	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, TXAMP,
+			   priv->serdes_tx_amp[XGBE_PHY_SPEED_1000]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG20, BLWC_ENA,
+			   priv->serdes_blwc[XGBE_PHY_SPEED_1000]);
+	XRXTX_IOWRITE_BITS(priv, RXTX_REG114, PQ_REG,
+			   priv->serdes_pq_skew[XGBE_PHY_SPEED_1000]);
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
@@ -1555,6 +1608,66 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		goto err_sir1;
 	}
 
+	if (device_property_present(phy_dev, XGBE_PHY_BLWC_PROPERTY)) {
+		ret = device_property_read_u32_array(phy_dev,
+						     XGBE_PHY_BLWC_PROPERTY,
+						     priv->serdes_blwc,
+						     XGBE_PHY_SPEEDS);
+		if (ret) {
+			dev_err(dev, "invalid %s property\n",
+				XGBE_PHY_BLWC_PROPERTY);
+			goto err_sir1;
+		}
+	} else {
+		memcpy(priv->serdes_blwc, amd_xgbe_phy_serdes_blwc,
+		       sizeof(priv->serdes_blwc));
+	}
+
+	if (device_property_present(phy_dev, XGBE_PHY_CDR_RATE_PROPERTY)) {
+		ret = device_property_read_u32_array(phy_dev,
+						     XGBE_PHY_CDR_RATE_PROPERTY,
+						     priv->serdes_cdr_rate,
+						     XGBE_PHY_SPEEDS);
+		if (ret) {
+			dev_err(dev, "invalid %s property\n",
+				XGBE_PHY_CDR_RATE_PROPERTY);
+			goto err_sir1;
+		}
+	} else {
+		memcpy(priv->serdes_cdr_rate, amd_xgbe_phy_serdes_cdr_rate,
+		       sizeof(priv->serdes_cdr_rate));
+	}
+
+	if (device_property_present(phy_dev, XGBE_PHY_PQ_SKEW_PROPERTY)) {
+		ret = device_property_read_u32_array(phy_dev,
+						     XGBE_PHY_PQ_SKEW_PROPERTY,
+						     priv->serdes_pq_skew,
+						     XGBE_PHY_SPEEDS);
+		if (ret) {
+			dev_err(dev, "invalid %s property\n",
+				XGBE_PHY_PQ_SKEW_PROPERTY);
+			goto err_sir1;
+		}
+	} else {
+		memcpy(priv->serdes_pq_skew, amd_xgbe_phy_serdes_pq_skew,
+		       sizeof(priv->serdes_pq_skew));
+	}
+
+	if (device_property_present(phy_dev, XGBE_PHY_TX_AMP_PROPERTY)) {
+		ret = device_property_read_u32_array(phy_dev,
+						     XGBE_PHY_TX_AMP_PROPERTY,
+						     priv->serdes_tx_amp,
+						     XGBE_PHY_SPEEDS);
+		if (ret) {
+			dev_err(dev, "invalid %s property\n",
+				XGBE_PHY_TX_AMP_PROPERTY);
+			goto err_sir1;
+		}
+	} else {
+		memcpy(priv->serdes_tx_amp, amd_xgbe_phy_serdes_tx_amp,
+		       sizeof(priv->serdes_tx_amp));
+	}
+
 	phydev->priv = priv;
 
 	if (!priv->adev || acpi_disabled)
