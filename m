From: Teresa Remmet <t.remmet@phytec.de>
Subject: [PATCH v3] net: phy: smsc: Fix disabling energy detect mode
Date: Wed, 20 Jan 2016 13:40:35 +0100
Message-ID: <1453293635-6121-1-git-send-email-t.remmet@phytec.de>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the lan87xx_read_status function is getting called the
energy detect mode is enabled again even if it has been
disabled by device tree.

Added private struct to check the energy detect status.

Signed-off-by: Teresa Remmet <t.remmet@phytec.de>
---
Changes since v2:
- fixed bool variable
- read oftree property with of_property_read_bool()

Changes since v1:
- reordered variable definition
- moved private variable into a struct for better readability 
- deleted smsc_phy_remove fuction as it is not needed

 drivers/net/phy/smsc.c | 54 ++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 44 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index e485f26..2e21e93 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -24,6 +24,10 @@
 #include <linux/netdevice.h>
 #include <linux/smscphy.h>
 
+struct smsc_phy_priv {
+	bool energy_enable;
+};
+
 static int smsc_phy_config_intr(struct phy_device *phydev)
 {
 	int rc = phy_write (phydev, MII_LAN83C185_IM,
@@ -43,19 +47,14 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 
 static int smsc_phy_config_init(struct phy_device *phydev)
 {
-	int __maybe_unused len;
-	struct device *dev __maybe_unused = &phydev->mdio.dev;
-	struct device_node *of_node __maybe_unused = dev->of_node;
+	struct smsc_phy_priv *priv = phydev->priv;
+
 	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
-	int enable_energy = 1;
 
 	if (rc < 0)
 		return rc;
 
-	if (of_find_property(of_node, "smsc,disable-energy-detect", &len))
-		enable_energy = 0;
-
-	if (enable_energy) {
+	if (priv->energy_enable) {
 		/* Enable energy detect mode for this SMSC Transceivers */
 		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
 			       rc | MII_LAN83C185_EDPWRDOWN);
@@ -110,10 +109,13 @@ static int lan911x_config_init(struct phy_device *phydev)
  */
 static int lan87xx_read_status(struct phy_device *phydev)
 {
+	struct smsc_phy_priv *priv = phydev->priv;
+
 	int err = genphy_read_status(phydev);
-	int i;
 
-	if (!phydev->link) {
+	if (!phydev->link && priv->energy_enable) {
+		int i;
+
 		/* Disable EDPD to wake up PHY */
 		int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
 		if (rc < 0)
@@ -149,6 +151,26 @@ static int lan87xx_read_status(struct phy_device *phydev)
 	return err;
 }
 
+static int smsc_phy_probe(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+	struct smsc_phy_priv *priv;
+
+	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->energy_enable = true;
+
+	if (of_property_read_bool(of_node, "smsc,disable-energy-detect"))
+		priv->energy_enable = false;
+
+	phydev->priv = priv;
+
+	return 0;
+}
+
 static struct phy_driver smsc_phy_driver[] = {
 {
 	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
@@ -159,6 +181,8 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -180,6 +204,8 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -201,6 +227,8 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= lan87xx_read_status,
@@ -222,6 +250,8 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -242,6 +272,8 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= lan87xx_read_status,
@@ -263,6 +295,8 @@ static struct phy_driver smsc_phy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 
+	.probe		= smsc_phy_probe,
+
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= lan87xx_read_status,
-- 
1.9.1
