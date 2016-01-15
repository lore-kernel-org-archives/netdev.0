From: Teresa Remmet <t.remmet@phytec.de>
Subject: [PATCH] net: phy: smsc: Fix disabling energy detect mode
Date: Fri, 15 Jan 2016 10:20:33 +0100
Message-ID: <1452849633-26877-1-git-send-email-t.remmet@phytec.de>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the lan87xx_read_status function is getting called the
energy detect mode is enabled again even if it has been
disabled by device tree.

Added private variable to check the energy detect status.

Signed-off-by: Teresa Remmet <t.remmet@phytec.de>
---
 drivers/net/phy/smsc.c | 61 ++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 52 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index e485f26..5adb7f3 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -43,19 +43,14 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 
 static int smsc_phy_config_init(struct phy_device *phydev)
 {
-	int __maybe_unused len;
-	struct device *dev __maybe_unused = &phydev->mdio.dev;
-	struct device_node *of_node __maybe_unused = dev->of_node;
+	bool *energy_enable = phydev->priv;
+
 	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
-	int enable_energy = 1;
 
 	if (rc < 0)
 		return rc;
 
-	if (of_find_property(of_node, "smsc,disable-energy-detect", &len))
-		enable_energy = 0;
-
-	if (enable_energy) {
+	if (*energy_enable) {
 		/* Enable energy detect mode for this SMSC Transceivers */
 		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
 			       rc | MII_LAN83C185_EDPWRDOWN);
@@ -110,10 +105,11 @@ static int lan911x_config_init(struct phy_device *phydev)
  */
 static int lan87xx_read_status(struct phy_device *phydev)
 {
+	bool *energy_enable = phydev->priv;
 	int err = genphy_read_status(phydev);
 	int i;
 
-	if (!phydev->link) {
+	if (!phydev->link && *energy_enable) {
 		/* Disable EDPD to wake up PHY */
 		int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
 		if (rc < 0)
@@ -149,6 +145,35 @@ static int lan87xx_read_status(struct phy_device *phydev)
 	return err;
 }
 
+static int smsc_phy_probe(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->mdio.dev;
+	bool *energy_enable;
+	int __maybe_unused len;
+	struct device_node *of_node __maybe_unused = dev->of_node;
+
+	energy_enable = devm_kzalloc(dev, sizeof(*energy_enable), GFP_KERNEL);
+	if (!energy_enable)
+		return -ENOMEM;
+
+	*energy_enable = true;
+	if (of_find_property(of_node, "smsc,disable-energy-detect", &len))
+		*energy_enable = false;
+
+	phydev->priv = energy_enable;
+
+	return 0;
+}
+
+static void smsc_phy_remove(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->mdio.dev;
+	bool *priv = phydev->priv;
+
+	if (priv)
+		devm_kfree(dev, priv);
+}
+
 static struct phy_driver smsc_phy_driver[] = {
 {
 	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
@@ -159,6 +184,9 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+	.remove		= smsc_phy_remove,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -180,6 +208,9 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+	.remove		= smsc_phy_remove,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -201,6 +232,9 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+	.remove		= smsc_phy_remove,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= lan87xx_read_status,
@@ -222,6 +256,9 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+	.remove		= smsc_phy_remove,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -242,6 +279,9 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+	.remove		= smsc_phy_remove,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= lan87xx_read_status,
@@ -263,6 +303,9 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+	.remove		= smsc_phy_remove,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= lan87xx_read_status,
-- 
1.9.1
