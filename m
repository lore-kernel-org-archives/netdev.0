From: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Subject: [PATCH v3 1/2] Add support for ksz9031 PAD skew configuration over devicetree.
Date: Tue, 29 Apr 2014 11:33:24 +0200
Message-ID: <1398764005-23855-2-git-send-email-hchaumette@adeneo-embedded.com>
References: <1398764005-23855-1-git-send-email-hchaumette@adeneo-embedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rdunlap@infradead.org, xobs@kosagi.com, davem@davemloft.net,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.adetelgroup.com ([94.247.26.71]:45134 "EHLO
	hbg-pa71.hmc-pa.adm" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757134AbaD2JeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 05:34:10 -0400
In-Reply-To: <1398764005-23855-1-git-send-email-hchaumette@adeneo-embedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for ksz9031 PAD skew configuration over devicetree.

Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>
---
 drivers/net/phy/micrel.c | 167 +++++++++++++----------------------------------
 1 file changed, 44 insertions(+), 123 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index df56b26..c936b72 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -271,156 +271,77 @@ static int ksz9031_extended_read(struct phy_device *phydev,
 	return phy_read(phydev, MII_KSZ9031RN_MMD_REGDATA_REG);
 }
 
-/* Two 5-bit fields register */
-static int ksz9031_load_clk_skew_values(struct phy_device *phydev,
-					struct device_node *of_node,
-					char *field1, char *field2)
+static int ksz9031_of_load_skew_values(struct phy_device *phydev,
+				       struct device_node *of_node,
+				       u16 reg, size_t field_sz,
+				       char *field[], u8 numfields)
 {
-	int val1 = -1;
-	int val2 = -2;
-	int newval;
+	int val[4] = {-1, -2, -3, -4};
 	int matches = 0;
+	u16 mask;
+	u16 maxval;
+	u16 newval;
+	int i;
 
-	if (!of_property_read_u32(of_node, field1, &val1))
-		matches++;
-
-	if (!of_property_read_u32(of_node, field2, &val2))
-		matches++;
+	for (i = 0; i < numfields; i++)
+		if (!of_property_read_u32(of_node, field[i], val + i))
+			matches++;
 
 	if (!matches)
 		return 0;
 
-	if (matches < 2)
-		newval = ksz9031_extended_read(phydev, OP_DATA, 2,
-				MII_KSZ9031RN_CLK_PAD_SKEW);
-	else
-		newval = 0;
-
-	if (val1 != -1)
-		newval = (newval & 0xffe0) |
-			 ((val1 / KSZ9031_PS_TO_REG) & 0x1f);
-
-	if (val2 != -2)
-		newval = (newval & 0xfc1f) |
-			 (((val2 / KSZ9031_PS_TO_REG) & 0x1f) << 5);
-
-	return ksz9031_extended_write(phydev, OP_DATA, 2,
-			MII_KSZ9031RN_CLK_PAD_SKEW, newval);
-}
-
-/* Four 4-bit fields register */
-static int ksz9031_load_data_skew_values(struct phy_device *phydev,
-					 struct device_node *of_node, u16 reg,
-					 char *field1, char *field2,
-					 char *field3, char *field4)
-{
-	int val1 = -1;
-	int val2 = -2;
-	int val3 = -3;
-	int val4 = -4;
-	int newval;
-	int matches = 0;
-
-	if (!of_property_read_u32(of_node, field1, &val1))
-		matches++;
-
-	if (!of_property_read_u32(of_node, field2, &val2))
-		matches++;
-
-	if (!of_property_read_u32(of_node, field3, &val3))
-		matches++;
-
-	if (!of_property_read_u32(of_node, field4, &val4))
-		matches++;
-
-	if (!matches)
-		return 0;
-
-	if (matches < 4)
+	if (matches < numfields)
 		newval = ksz9031_extended_read(phydev, OP_DATA, 2, reg);
 	else
 		newval = 0;
 
-	if (val1 != -1)
-		newval = (newval & 0xfff0) |
-			 (((val1 / KSZ9031_PS_TO_REG) & 0xf) << 0);
-
-	if (val2 != -2)
-		newval = (newval & 0xff0f) |
-			 (((val2 / KSZ9031_PS_TO_REG) & 0xf) << 4);
-
-	if (val3 != -3)
-		newval = (newval & 0xf0ff) |
-			 (((val3 / KSZ9031_PS_TO_REG) & 0xf) << 8);
-
-	if (val4 != -4)
-		newval = (newval & 0x0fff) |
-			 (((val4 / KSZ9031_PS_TO_REG) & 0xf) << 12);
+	maxval = (field_sz == 4) ? 0xf : 0x1f;
+	for (i = 0; i < numfields; i++)
+		if (val[i] != -(i + 1)) {
+			mask = 0xffff;
+			mask ^= maxval << (field_sz * i);
+			newval = (newval & mask) |
+				(((val[i] / KSZ9031_PS_TO_REG) & maxval)
+					<< (field_sz * i));
+		}
 
 	return ksz9031_extended_write(phydev, OP_DATA, 2, reg, newval);
 }
 
-/* Two 4-bit fields register */
-static int ksz9031_load_ctrl_skew_values(struct phy_device *phydev,
-					 struct device_node *of_node,
-					 char *field1, char *field2)
-{
-	int val1 = -1;
-	int val2 = -2;
-	int newval;
-	int matches = 0;
-
-	if (!of_property_read_u32(of_node, field1, &val1))
-		matches++;
-
-	if (!of_property_read_u32(of_node, field2, &val2))
-		matches++;
-
-	if (!matches)
-		return 0;
-
-	if (matches < 2)
-		newval = ksz9031_extended_read(phydev, OP_DATA, 2,
-				MII_KSZ9031RN_CONTROL_PAD_SKEW);
-	else
-		newval = 0;
-
-	if (val1 != -1)
-		newval = (newval & 0xfff0) |
-			 (((val1 / KSZ9031_PS_TO_REG) & 0xf) << 0);
-
-	if (val2 != -2)
-		newval = (newval & 0xff0f) |
-			 (((val2 / KSZ9031_PS_TO_REG) & 0xf) << 4);
-
-	return ksz9031_extended_write(phydev, OP_DATA, 2,
-			MII_KSZ9031RN_CONTROL_PAD_SKEW, newval);
-}
-
 static int ksz9031_config_init(struct phy_device *phydev)
 {
 	struct device *dev = &phydev->dev;
 	struct device_node *of_node = dev->of_node;
+	char *clk_skews[2] = {"rxc-skew-ps", "txc-skew-ps"};
+	char *rx_data_skews[4] = {
+		"rxd0-skew-ps", "rxd1-skew-ps",
+		"rxd2-skew-ps", "rxd3-skew-ps"
+	};
+	char *tx_data_skews[4] = {
+		"txd0-skew-ps", "txd1-skew-ps",
+		"txd2-skew-ps", "txd3-skew-ps"
+	};
+	char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
 
 	if (!of_node && dev->parent->of_node)
 		of_node = dev->parent->of_node;
 
 	if (of_node) {
-		ksz9031_load_clk_skew_values(phydev, of_node,
-				"rxc-skew-ps", "txc-skew-ps");
+		ksz9031_of_load_skew_values(phydev, of_node,
+				MII_KSZ9031RN_CLK_PAD_SKEW, 5,
+				clk_skews, 2);
 
-		ksz9031_load_data_skew_values(phydev, of_node,
-				MII_KSZ9031RN_RX_DATA_PAD_SKEW,
-				"rxd0-skew-ps", "rxd1-skew-ps",
-				"rxd2-skew-ps", "rxd3-skew-ps");
+		ksz9031_of_load_skew_values(phydev, of_node,
+				MII_KSZ9031RN_CONTROL_PAD_SKEW, 4,
+				control_skews, 2);
 
-		ksz9031_load_data_skew_values(phydev, of_node,
-				MII_KSZ9031RN_TX_DATA_PAD_SKEW,
-				"txd0-skew-ps", "txd1-skew-ps",
-				"txd2-skew-ps", "txd3-skew-ps");
+		ksz9031_of_load_skew_values(phydev, of_node,
+				MII_KSZ9031RN_RX_DATA_PAD_SKEW, 4,
+				rx_data_skews, 4);
 
-		ksz9031_load_ctrl_skew_values(phydev, of_node,
-				"txen-skew-ps", "rxdv-skew-ps");
+		ksz9031_of_load_skew_values(phydev, of_node,
+				MII_KSZ9031RN_TX_DATA_PAD_SKEW, 4,
+				tx_data_skews, 4);
 	}
 	return 0;
 }
-- 
1.9.2
