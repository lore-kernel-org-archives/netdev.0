From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 5/5] net: phy: Add downshift get/set support in Microsemi PHYs driver
Date: Fri, 4 Nov 2016 11:35:42 +0100
Message-ID: <1478255742-25693-6-git-send-email-allan.nielsen@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>,
        "Raju Lakkaraju" <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0068.outbound.protection.outlook.com ([104.47.41.68]:32256
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933568AbcKDLIq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 07:08:46 -0400
In-Reply-To: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Implements the phy tunable function pointers and implement downshift
functionality for MSCC PHYs.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 drivers/net/phy/mscc.c | 102 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 102 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index d0026ab..7edd32d 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -46,8 +46,15 @@ enum rgmii_rx_clock_delay {
 
 #define MSCC_EXT_PAGE_ACCESS		  31
 #define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
+#define MSCC_PHY_PAGE_EXTENDED		  0x0001 /* Extended registers */
 #define MSCC_PHY_PAGE_EXTENDED_2	  0x0002 /* Extended reg - page 2 */
 
+/* Extended Page 1 Registers */
+#define MSCC_PHY_ACTIPHY_CNTL		  20
+#define DOWNSHIFT_CNTL_MASK		  0x001C
+#define DOWNSHIFT_EN			  0x0010
+#define DOWNSHIFT_CNTL_POS		  2
+
 /* Extended Page 2 Registers */
 #define MSCC_PHY_RGMII_CNTL		  20
 #define RGMII_RX_CLK_DELAY_MASK		  0x0070
@@ -75,6 +82,8 @@ enum rgmii_rx_clock_delay {
 #define MSCC_VDDMAC_2500		  2500
 #define MSCC_VDDMAC_3300		  3300
 
+#define DOWNSHIFT_COUNT_MAX		  5
+
 struct vsc8531_private {
 	int rate_magic;
 };
@@ -101,6 +110,66 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_downshift_get(struct phy_device *phydev, u8 *count)
+{
+	int rc;
+	u16 reg_val;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
+	if (rc != 0)
+		goto out_unlock;
+
+	reg_val = phy_read(phydev, MSCC_PHY_ACTIPHY_CNTL);
+	reg_val &= DOWNSHIFT_CNTL_MASK;
+	if (!(reg_val & DOWNSHIFT_EN))
+		*count = 0;
+	else
+		*count = ((reg_val & ~DOWNSHIFT_EN) >> DOWNSHIFT_CNTL_POS) + 2;
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
+static int vsc85xx_downshift_set(struct phy_device *phydev, u8 count)
+{
+	int rc;
+	u16 reg_val;
+
+	if (count == DOWNSHIFT_DEV_DEFAULT_COUNT) {
+		/* Default downshift count 3 (i.e. Bit3:2 = 0b01) */
+		count = ((1 << DOWNSHIFT_CNTL_POS) | DOWNSHIFT_EN);
+	} else if (count > DOWNSHIFT_COUNT_MAX || count == 1) {
+		phydev_err(phydev, "Invalid downshift count\n");
+		return -EINVAL;
+	} else if (count) {
+		/* Downshift count is either 2,3,4 or 5 */
+		count = (((count - 2) << DOWNSHIFT_CNTL_POS) | DOWNSHIFT_EN);
+	}
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
+	if (rc != 0)
+		goto out_unlock;
+
+	reg_val = phy_read(phydev, MSCC_PHY_ACTIPHY_CNTL);
+	reg_val &= ~(DOWNSHIFT_CNTL_MASK);
+	reg_val |= count;
+	rc = phy_write(phydev, MSCC_PHY_ACTIPHY_CNTL, reg_val);
+	if (rc != 0)
+		goto out_unlock;
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
 static int vsc85xx_wol_set(struct phy_device *phydev,
 			   struct ethtool_wolinfo *wol)
 {
@@ -329,6 +398,31 @@ static int vsc85xx_default_config(struct phy_device *phydev)
 	return rc;
 }
 
+static int vsc85xx_get_tunable(struct phy_device *phydev,
+			       struct ethtool_tunable *tuna, void *data)
+{
+	switch (tuna->id) {
+	case ETHTOOL_PHY_DOWNSHIFT:
+		return vsc85xx_downshift_get(phydev, (u8 *)data);
+	default:
+		phydev_err(phydev, "Unsupported PHY tunable id\n");
+		return -EINVAL;
+	}
+}
+
+static int vsc85xx_set_tunable(struct phy_device *phydev,
+			       struct ethtool_tunable *tuna,
+			       const void *data)
+{
+	switch (tuna->id) {
+	case ETHTOOL_PHY_DOWNSHIFT:
+		return vsc85xx_downshift_set(phydev, *(u8 *)data);
+	default:
+		phydev_err(phydev, "Unsupported PHY tunable id\n");
+		return -EINVAL;
+	}
+}
+
 static int vsc85xx_config_init(struct phy_device *phydev)
 {
 	int rc;
@@ -418,6 +512,8 @@ static struct phy_driver vsc85xx_driver[] = {
 	.probe		= &vsc85xx_probe,
 	.set_wol	= &vsc85xx_wol_set,
 	.get_wol	= &vsc85xx_wol_get,
+	.get_tunable	= &vsc85xx_get_tunable,
+	.set_tunable	= &vsc85xx_set_tunable,
 },
 {
 	.phy_id		= PHY_ID_VSC8531,
@@ -437,6 +533,8 @@ static struct phy_driver vsc85xx_driver[] = {
 	.probe		= &vsc85xx_probe,
 	.set_wol	= &vsc85xx_wol_set,
 	.get_wol	= &vsc85xx_wol_get,
+	.get_tunable	= &vsc85xx_get_tunable,
+	.set_tunable	= &vsc85xx_set_tunable,
 },
 {
 	.phy_id		= PHY_ID_VSC8540,
@@ -456,6 +554,8 @@ static struct phy_driver vsc85xx_driver[] = {
 	.probe		= &vsc85xx_probe,
 	.set_wol	= &vsc85xx_wol_set,
 	.get_wol	= &vsc85xx_wol_get,
+	.get_tunable	= &vsc85xx_get_tunable,
+	.set_tunable	= &vsc85xx_set_tunable,
 },
 {
 	.phy_id		= PHY_ID_VSC8541,
@@ -475,6 +575,8 @@ static struct phy_driver vsc85xx_driver[] = {
 	.probe		= &vsc85xx_probe,
 	.set_wol	= &vsc85xx_wol_set,
 	.get_wol	= &vsc85xx_wol_get,
+	.get_tunable	= &vsc85xx_get_tunable,
+	.set_tunable	= &vsc85xx_set_tunable,
 }
 
 };
-- 
2.7.3
