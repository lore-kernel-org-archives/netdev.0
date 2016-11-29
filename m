From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next 3/4] net: phy: Add mdi(x) support in Microsemi PHYs driver
Date: Tue, 29 Nov 2016 15:16:48 +0530
Message-ID: <1480412809-6122-4-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0053.outbound.protection.outlook.com ([104.47.32.53]:42687
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752224AbcK2KCL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:02:11 -0500
In-Reply-To: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
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

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 105 +++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 97 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 92018ba..d1e26e1 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -27,6 +27,11 @@ enum rgmii_rx_clock_delay {
 
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
@@ -44,12 +49,20 @@ enum rgmii_rx_clock_delay {
 #define EDGE_RATE_CNTL_POS                5
 #define EDGE_RATE_CNTL_MASK               0x00E0
 
+#define MSCC_PHY_DEV_AUX_CNTL		  28
+#define HP_AUTO_MDIX_X_OVER_IND_MASK	  0x2000
+
 #define MSCC_EXT_PAGE_ACCESS		  31
 #define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
 #define MSCC_PHY_PAGE_EXTENDED		  0x0001 /* Extended registers */
 #define MSCC_PHY_PAGE_EXTENDED_2	  0x0002 /* Extended reg - page 2 */
 
 /* Extended Page 1 Registers */
+#define MSCC_PHY_EXT_MODE_CNTL		  19
+#define FORCE_MDI_CROSSOVER_MASK	  0x000C
+#define FORCE_MDI_CROSSOVER_MDIX	  0x000C
+#define FORCE_MDI_CROSSOVER_MDI		  0x0008
+
 #define MSCC_PHY_ACTIPHY_CNTL		  20
 #define DOWNSHIFT_CNTL_MASK		  0x001C
 #define DOWNSHIFT_EN			  0x0010
@@ -110,6 +123,59 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_mdix_get(struct phy_device *phydev, u8 *mdix)
+{
+	u16 reg_val;
+
+	reg_val = phy_read(phydev, MSCC_PHY_DEV_AUX_CNTL);
+	if (reg_val & HP_AUTO_MDIX_X_OVER_IND_MASK)
+		*mdix = ETH_TP_MDI_X;
+	else
+		*mdix = ETH_TP_MDI;
+
+	return 0;
+}
+
+static int vsc85xx_mdix_set(struct phy_device *phydev, u8 mdix)
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
+		return rc;
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
+	if (rc != 0)
+		return rc;
+
+	reg_val = phy_read(phydev, MSCC_PHY_EXT_MODE_CNTL);
+	reg_val &= ~(FORCE_MDI_CROSSOVER_MASK);
+	if (mdix == ETH_TP_MDI)
+		reg_val |= FORCE_MDI_CROSSOVER_MDI;
+	else if (mdix == ETH_TP_MDI_X)
+		reg_val |= FORCE_MDI_CROSSOVER_MDIX;
+	rc = phy_write(phydev, MSCC_PHY_EXT_MODE_CNTL, reg_val);
+	if (rc != 0)
+		return rc;
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+	if (rc != 0)
+		return rc;
+
+	return genphy_restart_aneg(phydev);
+}
+
 static int vsc85xx_downshift_get(struct phy_device *phydev, u8 *count)
 {
 	int rc;
@@ -381,6 +447,7 @@ static int vsc85xx_default_config(struct phy_device *phydev)
 	int rc;
 	u16 reg_val;
 
+	phydev->mdix_ctrl = ETH_TP_MDI_AUTO;
 	mutex_lock(&phydev->lock);
 	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
 	if (rc != 0)
@@ -470,6 +537,28 @@ static int vsc85xx_config_intr(struct phy_device *phydev)
 	return rc;
 }
 
+static int vsc85xx_config_aneg(struct phy_device *phydev)
+{
+	int rc;
+
+	rc = vsc85xx_mdix_set(phydev, phydev->mdix_ctrl);
+	if (rc < 0)
+		return rc;
+
+	return genphy_config_aneg(phydev);
+}
+
+static int vsc85xx_read_status(struct phy_device *phydev)
+{
+	int rc;
+
+	rc = vsc85xx_mdix_get(phydev, &phydev->mdix);
+	if (rc < 0)
+		return rc;
+
+	return genphy_read_status(phydev);
+}
+
 static int vsc85xx_probe(struct phy_device *phydev)
 {
 	int rate_magic;
@@ -500,9 +589,9 @@ static struct phy_driver vsc85xx_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.soft_reset	= &genphy_soft_reset,
 	.config_init	= &vsc85xx_config_init,
-	.config_aneg	= &genphy_config_aneg,
+	.config_aneg    = &vsc85xx_config_aneg,
 	.aneg_done	= &genphy_aneg_done,
-	.read_status	= &genphy_read_status,
+	.read_status	= &vsc85xx_read_status,
 	.ack_interrupt	= &vsc85xx_ack_interrupt,
 	.config_intr	= &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
@@ -521,9 +610,9 @@ static struct phy_driver vsc85xx_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.soft_reset	= &genphy_soft_reset,
 	.config_init    = &vsc85xx_config_init,
-	.config_aneg    = &genphy_config_aneg,
+	.config_aneg    = &vsc85xx_config_aneg,
 	.aneg_done	= &genphy_aneg_done,
-	.read_status    = &genphy_read_status,
+	.read_status	= &vsc85xx_read_status,
 	.ack_interrupt  = &vsc85xx_ack_interrupt,
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
@@ -542,9 +631,9 @@ static struct phy_driver vsc85xx_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.soft_reset	= &genphy_soft_reset,
 	.config_init	= &vsc85xx_config_init,
-	.config_aneg	= &genphy_config_aneg,
+	.config_aneg	= &vsc85xx_config_aneg,
 	.aneg_done	= &genphy_aneg_done,
-	.read_status	= &genphy_read_status,
+	.read_status	= &vsc85xx_read_status,
 	.ack_interrupt	= &vsc85xx_ack_interrupt,
 	.config_intr	= &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
@@ -563,9 +652,9 @@ static struct phy_driver vsc85xx_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.soft_reset	= &genphy_soft_reset,
 	.config_init    = &vsc85xx_config_init,
-	.config_aneg    = &genphy_config_aneg,
+	.config_aneg    = &vsc85xx_config_aneg,
 	.aneg_done	= &genphy_aneg_done,
-	.read_status    = &genphy_read_status,
+	.read_status	= &vsc85xx_read_status,
 	.ack_interrupt  = &vsc85xx_ack_interrupt,
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
-- 
2.7.4
