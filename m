From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver for Microsemi PHYs.
Date: Wed, 28 Sep 2016 17:31:18 +0530
Message-ID: <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0070.outbound.protection.outlook.com ([104.47.37.70]:64448
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753907AbcI1MCE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 08:02:04 -0400
In-Reply-To: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

To connect two ports of the same configuration (MDI to MDI or
MDI-X to MDI-X) with a 10/100/1000 Mbit/s connection, an
Ethernet crossover cable is needed to cross over the transmit
and receive signals in the cable, so that they are matched at
the connector level.
When connecting an MDI port to an MDI-X port a straight through
cable is used while to connect two MDI ports or two MDI-X ports
a crossover cable must be used. Conventionally MDI is used on end
devices while MDI-X is used on hubs and switches

Auto MDI-X automatically detects the required cable connection
type and configures the connection appropriately, removing the
need for crossover cables to interconnect switches or connecting
PCs peer-to-peer.

VSC8531 PHY supports Auto MDI-x, MDI and MDI-X configuraion by
driver set mdix function.

Tested on Beaglebone Black with VSC 8531 PHY.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 70 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index ca6ea23..dbf8434 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -26,6 +26,11 @@ enum rgmii_rx_clock_delay {
 
 /* Microsemi VSC85xx PHY registers */
 /* IEEE 802. Std Registers */
+#define MSCC_PHY_BYPASS_CONTROL		  18
+#define DISABLE_HP_AUTO_MDIX_MASK	  0x0080
+#define DISABLE_PAIR_SWAP_CORR_MASK	  0x0020
+#define DISABLE_POLARITY_CORR_MASK	  0x0010
+
 #define MSCC_PHY_EXT_PHY_CNTL_1           23
 #define MAC_IF_SELECTION_MASK             0x1800
 #define MAC_IF_SELECTION_GMII             0
@@ -41,8 +46,16 @@ enum rgmii_rx_clock_delay {
 
 #define MSCC_EXT_PAGE_ACCESS		  31
 #define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
+#define MSCC_PHY_PAGE_EXTENDED		  0x0001 /* Extended registers */
 #define MSCC_PHY_PAGE_EXTENDED_2	  0x0002 /* Extended reg - page 2 */
 
+/* Extended Page 1 Registers */
+#define MSCC_PHY_EXT_MODE_CNTL		  19
+#define FORCE_MDI_CROSSOVER_MASK	  0x000C
+#define FORCE_MDI_CROSSOVER_MDIX	  0x000C
+#define FORCE_MDI_CROSSOVER_MDI		  0x0008
+#define FORCE_MDI_CROSSOVER_NORMAL	  0x0000
+
 /* Extended Page 2 Registers */
 #define MSCC_PHY_RGMII_CNTL		  20
 #define RGMII_RX_CLK_DELAY_MASK		  0x0070
@@ -73,6 +86,47 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_mdix_set(struct phy_device *phydev,
+			    u8 mdix)
+{
+	int rc;
+	u16 reg_val;
+
+	reg_val = phy_read(phydev, MSCC_PHY_BYPASS_CONTROL);
+	if ((mdix == ETH_TP_MDI) || (mdix == ETH_TP_MDI_X)) {
+		reg_val |= (DISABLE_PAIR_SWAP_CORR_MASK |
+			    DISABLE_POLARITY_CORR_MASK  |
+			    DISABLE_HP_AUTO_MDIX_MASK);
+	} else {
+		reg_val &= ~(DISABLE_PAIR_SWAP_CORR_MASK |
+			     DISABLE_POLARITY_CORR_MASK  |
+			     DISABLE_HP_AUTO_MDIX_MASK);
+	}
+	rc = phy_write(phydev, MSCC_PHY_BYPASS_CONTROL, reg_val);
+	if (rc != 0)
+		goto out_unlock;
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
+	if (rc != 0)
+		goto out_unlock;
+
+	reg_val = phy_read(phydev, MSCC_PHY_EXT_MODE_CNTL);
+	reg_val &= ~(FORCE_MDI_CROSSOVER_MASK);
+	if (mdix == ETH_TP_MDI)
+		reg_val |= FORCE_MDI_CROSSOVER_MDI;
+	else if (mdix == ETH_TP_MDI_X)
+		reg_val |= FORCE_MDI_CROSSOVER_MDIX;
+	rc = phy_write(phydev, MSCC_PHY_EXT_MODE_CNTL, reg_val);
+	if (rc != 0)
+		goto out_unlock;
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+
+	return rc;
+}
+
 static int vsc85xx_wol_set(struct phy_device *phydev,
 			   struct ethtool_wolinfo *wol)
 {
@@ -227,6 +281,7 @@ static int vsc85xx_default_config(struct phy_device *phydev)
 	int rc;
 	u16 reg_val;
 
+	phydev->mdix = ETH_TP_MDI_AUTO;
 	mutex_lock(&phydev->lock);
 	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
 	if (rc != 0)
@@ -288,6 +343,19 @@ static int vsc85xx_config_intr(struct phy_device *phydev)
 	return rc;
 }
 
+static int vsc85xx_config_aneg(struct phy_device *phydev)
+{
+	int rc;
+
+	rc = vsc85xx_mdix_set(phydev, phydev->mdix);
+	if (rc < 0)
+		return rc;
+
+	rc = genphy_config_aneg(phydev);
+
+	return rc;
+}
+
 /* Microsemi VSC85xx PHYs */
 static struct phy_driver vsc85xx_driver[] = {
 {
@@ -298,7 +366,7 @@ static struct phy_driver vsc85xx_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.soft_reset	= &genphy_soft_reset,
 	.config_init    = &vsc85xx_config_init,
-	.config_aneg    = &genphy_config_aneg,
+	.config_aneg    = &vsc85xx_config_aneg,
 	.aneg_done	= &genphy_aneg_done,
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc85xx_ack_interrupt,
@@ -316,7 +384,7 @@ static struct phy_driver vsc85xx_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.soft_reset	= &genphy_soft_reset,
 	.config_init    = &vsc85xx_config_init,
-	.config_aneg    = &genphy_config_aneg,
+	.config_aneg    = &vsc85xx_config_aneg,
 	.aneg_done	= &genphy_aneg_done,
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc85xx_ack_interrupt,
-- 
2.7.4
