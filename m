From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper PHY driver
Date: Wed, 29 Apr 2015 18:57:43 -0700
Message-ID: <1430359064-23454-8-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33492 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbbD3B6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:11 -0400
Received: by pdbnk13 with SMTP id nk13so45268589pdb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:11 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the Marvell 88E6060 switch driver into a proper PHY library
driver that can be registered. To make sure we do not introduce
functional changes, the PHY driver provides autoneg and status callbacks
to make sure the attached Ethernet MAC driver still sees a link UP at
the CPU port full speed.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6060.c | 114 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 109 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index c29aebe1e62b..7bd15bbb0787 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -19,9 +19,23 @@
 #define REG_PORT(p)		(8 + (p))
 #define REG_GLOBAL		0x0f
 
+#define MV88E6060_MAGIC		0x600
+#define MV88E6060_MAGIC_MASK	0xfff0
+
+static inline struct mii_bus *mv88e6060_mii_bus(struct dsa_switch *ds)
+{
+	struct phy_device *phydev;
+
+	if (ds->from_pd)
+		return dsa_host_dev_to_mii_bus(ds->master_dev);
+
+	phydev = to_phy_device(ds->master_dev);
+	return phydev->bus;
+}
+
 static int reg_read(struct dsa_switch *ds, int addr, int reg)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+	struct mii_bus *bus = mv88e6060_mii_bus(ds);
 
 	if (bus == NULL)
 		return -EINVAL;
@@ -42,7 +56,7 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
 
 static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+	struct mii_bus *bus = mv88e6060_mii_bus(ds);
 
 	if (bus == NULL)
 		return -EINVAL;
@@ -59,7 +73,7 @@ static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 			return __ret;				\
 	})
 
-static char *mv88e6060_probe(struct device *host_dev, int sw_addr)
+static char *mv88e6060_switch_probe(struct device *host_dev, int sw_addr)
 {
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
 	int ret;
@@ -275,7 +289,7 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
 
 static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.tag_protocol	= DSA_TAG_PROTO_TRAILER,
-	.probe		= mv88e6060_probe,
+	.probe		= mv88e6060_switch_probe,
 	.setup		= mv88e6060_setup,
 	.set_addr	= mv88e6060_set_addr,
 	.phy_read	= mv88e6060_phy_read,
@@ -283,16 +297,106 @@ static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.poll_link	= mv88e6060_poll_link,
 };
 
+static int mv88e6060_probe(struct phy_device *phydev)
+{
+	struct dsa_switch *ds;
+
+	ds = dsa_alloc_switch(0);
+	if (!ds)
+		return -ENOMEM;
+
+	phydev->priv = ds;
+	phydev->is_switch = true;
+	ds->master_dev = &phydev->dev;
+	ds->tag_protocol = DSA_TAG_PROTO_TRAILER;
+	ds->drv = &mv88e6060_switch_driver;
+
+	return 0;
+}
+
+static void mv88e6060_remove(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+
+	dsa_switch_unregister(ds);
+	phydev->priv = NULL;
+}
+
+static int mv88e6060_config_init(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+
+	return dsa_switch_register_phydev(ds, phydev);
+}
+
+static int mv88e6060_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+
+/* Called by the network device driver attached to this PHY
+ * we need to reflect the CPU port status here since the Ethernet MAC will
+ * use those PHY device link parameters for its configuration
+ */
+static int mv88e6060_read_status(struct phy_device *phydev)
+{
+	phydev->speed = 100;
+	phydev->duplex = DUPLEX_FULL;
+	phydev->link = 1;
+	phydev->state = PHY_RUNNING;
+
+	netif_carrier_on(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev);
+
+	return 0;
+}
+
+/* Read the switch identifier register using the special Port register, and if
+ * successful, override the PHY ID for this device
+ */
+static int mv88e6060_phy_fixup(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Marvell switches should be accessed using MDIO address 16 */
+	if (phydev->addr != 16)
+		return 0;
+
+	ret = mdiobus_read(phydev->bus, REG_PORT(0), 0x03) &
+			   MV88E6060_MAGIC_MASK;
+	if (ret != MV88E6060_MAGIC)
+		return 0;
+
+	phydev->phy_id = MV88E6060_MAGIC;
+
+	return 0;
+}
+
+static struct phy_driver mv88e6060_phy_driver = {
+	.phy_id		= MV88E6060_MAGIC,
+	.name		= "Marvell 88E6060",
+	.phy_id_mask	= 0xffffffff,
+	.features	= PHY_BASIC_FEATURES,
+	.probe		= mv88e6060_probe,
+	.remove		= mv88e6060_remove,
+	.config_aneg	= mv88e6060_config_aneg,
+	.config_init	= mv88e6060_config_init,
+	.read_status	= mv88e6060_read_status,
+	.driver		= { .owner = THIS_MODULE, },
+};
+
 static int __init mv88e6060_init(void)
 {
 	register_switch_driver(&mv88e6060_switch_driver);
-	return 0;
+	phy_register_fixup_for_id(PHY_ANY_ID, mv88e6060_phy_fixup);
+	return phy_driver_register(&mv88e6060_phy_driver);
 }
 module_init(mv88e6060_init);
 
 static void __exit mv88e6060_cleanup(void)
 {
 	unregister_switch_driver(&mv88e6060_switch_driver);
+	phy_driver_unregister(&mv88e6060_phy_driver);
 }
 module_exit(mv88e6060_cleanup);
 
-- 
2.1.0
