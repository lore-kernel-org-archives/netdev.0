From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 8/8] net: dsa: mv88e6xxx: Allow them to be proper PHY drivers
Date: Wed, 29 Apr 2015 18:57:44 -0700
Message-ID: <1430359064-23454-9-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33592 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbbD3B6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:13 -0400
Received: by pacwv17 with SMTP id wv17so44665465pac.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:12 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register a PHY fixup for the different MV88E6xxx switches supported by
the 88e6xxxx driver, basically replacing the legacy probe function.

Since these are all now a PHY driver, the Ethernet MAC controller attached
to it needs to be signaled proper link parameters (speed, duplex, link)

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6123_61_65.c | 116 ++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6131.c       | 107 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6171.c       |  95 +++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6352.c       | 102 +++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.c       |  40 ++++++++++++-
 drivers/net/dsa/mv88e6xxx.h       |  12 ++++
 6 files changed, 470 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index b4af6d5aff7c..acd0e08d6b21 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -296,6 +296,122 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_regs		= mv88e6xxx_get_regs,
 };
 
+/* PHY library read status callback, must reflect the CPU port link parameters
+ * towards the attached Ethernet MAC driver
+ */
+static int mv88e6123_61_65_read_status(struct phy_device *phydev)
+{
+	phydev->link = 1;
+	phydev->speed = SPEED_1000;
+	phydev->duplex = DUPLEX_FULL;
+	phydev->state = PHY_RUNNING;
+
+	netif_carrier_on(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev);
+
+	return 0;
+}
+
+static int mv88e6123_61_65_phy_probe(struct phy_device *phydev)
+{
+	struct dsa_switch *ds;
+
+	ds = dsa_alloc_switch(sizeof(struct mv88e6xxx_priv_state));
+	if (!ds)
+		return -ENOMEM;
+
+	phydev->priv = ds;
+	phydev->is_switch = true;
+	ds->drv = &mv88e6123_61_65_switch_driver;
+	ds->tag_protocol = DSA_TAG_PROTO_EDSA;
+	ds->master_dev = &phydev->dev;
+
+	return 0;
+}
+
+static void mv88e6123_61_65_remove(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+
+	dsa_switch_unregister(ds);
+	kfree(ds);
+	phydev->priv = NULL;
+}
+
+static int mv88e6123_61_65_phy_fixup(struct phy_device *phydev)
+{
+	int ret;
+
+	if (phydev->addr != 16)
+		return 0;
+
+	ret = __mv88e6xxx_reg_read(phydev->bus, phydev->addr, REG_PORT(0), 0x03);
+	if (ret < 0)
+		return 0;
+
+	switch (ret) {
+	case PORT_SWITCH_ID_6123_A1:
+	case PORT_SWITCH_ID_6123_A2:
+	case PORT_SWITCH_ID_6161_A1:
+	case PORT_SWITCH_ID_6161_A2:
+	case PORT_SWITCH_ID_6165_A1:
+	case PORT_SWITCH_ID_6165_A2:
+		phydev->phy_id = ret;
+		break;
+	default:
+		ret &= 0xfff0;
+		switch (ret) {
+		case PORT_SWITCH_ID_6123:
+		case PORT_SWITCH_ID_6161:
+		case PORT_SWITCH_ID_6165:
+			phydev->phy_id = ret;
+			break;
+		}
+	}
+
+	return 0;
+}
+
+#define MV88E61XX_DRV(_magic, _name)			\
+{							\
+	.phy_id		= (_magic),			\
+	.phy_id_mask	= 0xffffffff,			\
+	.name		= (_name),			\
+	.features	= PHY_GBIT_FEATURES,		\
+	.config_init	= mv88e6xxx_config_init,	\
+	.config_aneg	= mv88e6xxx_config_aneg,	\
+	.read_status	= mv88e6123_61_65_read_status,	\
+	.probe		= mv88e6123_61_65_phy_probe,	\
+	.remove		= mv88e6123_61_65_remove,	\
+	.driver		= { .owner = THIS_MODULE },	\
+}
+
+static struct phy_driver mv88e6123_61_65_phy_drivers[] = {
+	MV88E61XX_DRV(PORT_SWITCH_ID_6123_A1, "Marvell 88E6123 (A1)"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6123_A2, "Marvell 88E6123 (A2)"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6123, "Marvell 88E6123"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6161_A1, "Marvell 88E6161 (A1)"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6161_A2, "Marvell 88E6161 (A2)"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6161, "Marvell 88E6161"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6165_A1, "Marvell 88E6165 (A1)"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6165_A2, "Marvell 88E6165 (A2)"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6165, "Marvell 88E6165"),
+};
+
+int __init mv88e6123_61_65_phy_drivers_register(void)
+{
+	phy_register_fixup_for_id(PHY_ANY_ID, mv88e6123_61_65_phy_fixup);
+
+	return phy_drivers_register(mv88e6123_61_65_phy_drivers,
+				    ARRAY_SIZE(mv88e6123_61_65_phy_drivers));
+}
+
+void __exit mv88e6123_61_65_phy_drivers_unregister(void)
+{
+	phy_drivers_unregister(mv88e6123_61_65_phy_drivers,
+			       ARRAY_SIZE(mv88e6123_61_65_phy_drivers));
+}
+
 MODULE_ALIAS("platform:mv88e6123");
 MODULE_ALIAS("platform:mv88e6161");
 MODULE_ALIAS("platform:mv88e6165");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e54824fa0d95..e60e3e3a2e65 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -313,6 +313,113 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 };
 
+static int mv88e6131_read_status(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	phydev->link = 1;
+	phydev->duplex = DUPLEX_FULL;
+	if (ps->id == PORT_SWITCH_ID_6085)
+		phydev->speed = SPEED_100;
+	else
+		phydev->speed = SPEED_1000;
+	phydev->state = PHY_RUNNING;
+
+	netif_carrier_on(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev);
+
+	return 0;
+}
+
+static int mv88e6131_phy_probe(struct phy_device *phydev)
+{
+	struct dsa_switch *ds;
+
+	ds = dsa_alloc_switch(sizeof(struct mv88e6xxx_priv_state));
+	if (!ds)
+		return -ENOMEM;
+
+	phydev->priv = ds;
+	phydev->is_switch = true;
+	ds->master_dev = &phydev->dev;
+	ds->drv = &mv88e6131_switch_driver;
+	ds->tag_protocol = DSA_TAG_PROTO_DSA;
+
+	return 0;
+}
+
+static void mv88e6131_remove(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+
+	dsa_switch_unregister(ds);
+	kfree(ds);
+	phydev->priv = NULL;
+}
+
+static int mv88e6131_phy_fixup(struct phy_device *phydev)
+{
+	int ret;
+
+	if (phydev->addr != 16)
+		return 0;
+
+	ret = __mv88e6xxx_reg_read(phydev->bus, phydev->addr, REG_PORT(0), 0x03);
+	if (ret < 0)
+		return 0;
+
+	if (ret == PORT_SWITCH_ID_6131_B2) {
+		phydev->phy_id = ret;
+		return 0;
+	}
+
+	ret &= 0xfff0;
+	switch (ret) {
+	case PORT_SWITCH_ID_6085:
+	case PORT_SWITCH_ID_6095:
+	case PORT_SWITCH_ID_6131:
+		phydev->phy_id = ret;
+		break;
+	}
+
+	return 0;
+}
+
+#define MV88E61XX_DRV(_magic, _feat, _name)		\
+{							\
+	.phy_id		= (_magic),			\
+	.phy_id_mask	= 0xffffffff,			\
+	.name		= _name,			\
+	.features	= (_feat),			\
+	.config_init	= mv88e6xxx_config_init,	\
+	.config_aneg	= mv88e6xxx_config_aneg,	\
+	.read_status	= mv88e6131_read_status,	\
+	.probe		= mv88e6131_phy_probe,		\
+	.remove		= mv88e6131_remove,		\
+	.driver		= { .owner = THIS_MODULE },	\
+}
+static struct phy_driver mv88e6131_phy_drivers[] = {
+	MV88E61XX_DRV(PORT_SWITCH_ID_6085, PHY_BASIC_FEATURES, "Marvell 88E6085"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6095, PHY_GBIT_FEATURES, "Marvell 88E6095/88E6095F"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6131_B2, PHY_GBIT_FEATURES, "Marvell 88E6131 (B2)"),
+	MV88E61XX_DRV(PORT_SWITCH_ID_6131, PHY_GBIT_FEATURES, "Marvell 88E6131"),
+};
+
+int __init mv88e6131_phy_drivers_register(void)
+{
+	phy_register_fixup_for_id(PHY_ANY_ID, mv88e6131_phy_fixup);
+
+	return phy_drivers_register(mv88e6131_phy_drivers,
+				    ARRAY_SIZE(mv88e6131_phy_drivers));
+}
+
+void __exit mv88e6131_phy_drivers_unregister(void)
+{
+	phy_drivers_unregister(mv88e6131_phy_drivers,
+			       ARRAY_SIZE(mv88e6131_phy_drivers));
+}
+
 MODULE_ALIAS("platform:mv88e6085");
 MODULE_ALIAS("platform:mv88e6095");
 MODULE_ALIAS("platform:mv88e6095f");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 9104efea0e3e..120a0f46e321 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -307,5 +307,100 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
+static int mv88e6171_read_status(struct phy_device *phydev)
+{
+	phydev->link = 1;
+	phydev->duplex = DUPLEX_FULL;
+	phydev->state = PHY_RUNNING;
+
+	netif_carrier_on(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev);
+
+	return 0;
+}
+
+static int mv88e6171_phy_probe(struct phy_device *phydev)
+{
+	struct dsa_switch *ds;
+
+	ds = dsa_alloc_switch(sizeof(struct mv88e6xxx_priv_state));
+	if (!ds)
+		return -ENOMEM;
+
+	/* We cannot register the switch yet, since we do not have an attached
+	 * network device
+	 */
+	phydev->is_switch = true;
+	phydev->priv = ds;
+	ds->master_dev = &phydev->dev;
+	ds->drv = &mv88e6171_switch_driver;
+	ds->tag_protocol = DSA_TAG_PROTO_EDSA;
+
+	return 0;
+}
+
+static void mv88e6171_remove(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+
+	dsa_switch_unregister(ds);
+	kfree(ds);
+	phydev->priv = NULL;
+}
+
+static int mv88e6171_phy_fixup(struct phy_device *phydev)
+{
+	int ret;
+
+	if (phydev->addr != 16)
+		return 0;
+
+	ret = __mv88e6xxx_reg_read(phydev->bus, phydev->addr, REG_PORT(0), 0x03);
+	if (ret < 0)
+		return 0;
+
+	ret &= 0xfff0;
+	switch (ret) {
+	case PORT_SWITCH_ID_6171:
+	case PORT_SWITCH_ID_6172:
+		phydev->phy_id = ret;
+		break;
+	}
+
+	return 0;
+}
+
+#define MV88E6171_DRV(_magic, _name)			\
+{							\
+	.phy_id		= (_magic),			\
+	.phy_id_mask	= 0xfffffff0,			\
+	.name		= _name,			\
+	.features	= PHY_GBIT_FEATURES,		\
+	.config_init	= mv88e6xxx_config_init,	\
+	.config_aneg	= mv88e6xxx_config_aneg,	\
+	.read_status	= mv88e6171_read_status,	\
+	.probe		= mv88e6171_phy_probe,		\
+	.remove		= mv88e6171_remove,		\
+	.driver		= { .owner = THIS_MODULE },	\
+}
+static struct phy_driver mv88e6171_phy_drivers[] = {
+	MV88E6171_DRV(PORT_SWITCH_ID_6171, "Marvell 88E6171"),
+	MV88E6171_DRV(PORT_SWITCH_ID_6172, "Marvell 88E6172"),
+};
+
+int __init mv88e6171_phy_drivers_register(void)
+{
+	phy_register_fixup_for_id(PHY_ANY_ID, mv88e6171_phy_fixup);
+
+	return phy_drivers_register(mv88e6171_phy_drivers,
+				    ARRAY_SIZE(mv88e6171_phy_drivers));
+}
+
+void __exit mv88e6171_phy_drivers_unregister(void)
+{
+	phy_drivers_unregister(mv88e6171_phy_drivers,
+			       ARRAY_SIZE(mv88e6171_phy_drivers));
+}
+
 MODULE_ALIAS("platform:mv88e6171");
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 126c11b81e75..e7198edddd13 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -551,4 +551,106 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
+static int mv88e6352_read_status(struct phy_device *phydev)
+{
+	phydev->link = 1;
+	phydev->duplex = DUPLEX_FULL;
+	phydev->speed = SPEED_1000;
+	phydev->state = PHY_RUNNING;
+
+	netif_carrier_on(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev);
+
+	return 0;
+}
+
+static int mv88e6352_phy_probe(struct phy_device *phydev)
+{
+	struct dsa_switch *ds;
+
+	ds = dsa_alloc_switch(sizeof(struct mv88e6xxx_priv_state));
+	if (!ds)
+		return -ENOMEM;
+
+	phydev->priv = ds;
+	phydev->is_switch = true;
+	ds->master_dev = &phydev->dev;
+	ds->drv = &mv88e6352_switch_driver;
+	ds->tag_protocol = DSA_TAG_PROTO_EDSA;
+
+	return 0;
+}
+
+static void mv88e6352_remove(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+
+	dsa_switch_unregister(ds);
+	kfree(ds);
+	phydev->priv = NULL;
+}
+
+static int mv88e6352_phy_fixup(struct phy_device *phydev)
+{
+	int ret;
+
+	if (phydev->addr != 16)
+		return 0;
+
+	ret = __mv88e6xxx_reg_read(phydev->bus, phydev->addr, REG_PORT(0), 0x03);
+	if (ret < 0)
+		return 0;
+
+	switch (ret) {
+	case PORT_SWITCH_ID_6352_A0:
+	case PORT_SWITCH_ID_6352_A1:
+		phydev->phy_id = ret;
+		return 0;
+	}
+
+	ret &= 0xfff0;
+	switch (ret) {
+	case PORT_SWITCH_ID_6176:
+	case PORT_SWITCH_ID_6352:
+		phydev->phy_id = ret;
+		break;
+	}
+
+	return 0;
+}
+#define MV88E6352_DRV(_magic, _name)			\
+{							\
+	.phy_id		= (_magic),			\
+	.phy_id_mask	= 0xffffffff,			\
+	.name		= _name,			\
+	.features	= PHY_GBIT_FEATURES,		\
+	.config_init	= mv88e6xxx_config_init,	\
+	.config_aneg	= mv88e6xxx_config_aneg,	\
+	.read_status	= mv88e6352_read_status,	\
+	.probe		= mv88e6352_phy_probe,		\
+	.remove		= mv88e6352_remove,		\
+	.driver		= { .owner = THIS_MODULE },	\
+}
+
+static struct phy_driver mv88e6352_phy_drivers[] = {
+	MV88E6352_DRV(PORT_SWITCH_ID_6176, "Marvell 88E6176"),
+	MV88E6352_DRV(PORT_SWITCH_ID_6352_A0, "Marvell 88E6352 (A0)"),
+	MV88E6352_DRV(PORT_SWITCH_ID_6352_A1, "Marvell 88E6352 (A1)"),
+	MV88E6352_DRV(PORT_SWITCH_ID_6352, "Marvell 88E6352"),
+};
+
+int __init mv88e6352_phy_drivers_register(void)
+{
+	phy_register_fixup_for_id(PHY_ANY_ID, mv88e6352_phy_fixup);
+
+	return phy_drivers_register(mv88e6352_phy_drivers,
+				    ARRAY_SIZE(mv88e6352_phy_drivers));
+}
+
+void __exit mv88e6352_phy_drivers_unregister(void)
+{
+	phy_drivers_unregister(mv88e6352_phy_drivers,
+			       ARRAY_SIZE(mv88e6352_phy_drivers));
+}
+
 MODULE_ALIAS("platform:mv88e6352");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index af639ab4c55b..c51c6f179682 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -75,10 +75,22 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 	return ret & 0xffff;
 }
 
+static inline struct mii_bus *mv88e6xxx_mii_bus(struct dsa_switch *ds)
+{
+	struct phy_device *phydev;
+	if (ds->from_pd)
+		return dsa_host_dev_to_mii_bus(ds->master_dev);
+
+	phydev = to_phy_device(ds->master_dev);
+
+	return phydev->bus;
+}
+
+
 /* Must be called with SMI mutex held */
 static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+	struct mii_bus *bus = mv88e6xxx_mii_bus(ds);
 	int ret;
 
 	if (bus == NULL)
@@ -142,7 +154,7 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 static int _mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg,
 				u16 val)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+	struct mii_bus *bus = mv88e6xxx_mii_bus(ds);
 
 	if (bus == NULL)
 		return -EINVAL;
@@ -1446,19 +1458,36 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 	return ret;
 }
 
+int mv88e6xxx_config_init(struct phy_device *phydev)
+{
+	struct dsa_switch *ds = phydev->priv;
+
+	/* We now have an attached network device, register this device */
+	return dsa_switch_register_phydev(ds, phydev);
+}
+
+int mv88e6xxx_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
 	register_switch_driver(&mv88e6131_switch_driver);
+	mv88e6131_phy_drivers_register();
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
 	register_switch_driver(&mv88e6123_61_65_switch_driver);
+	mv88e6123_61_65_phy_drivers_register();
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
 	register_switch_driver(&mv88e6352_switch_driver);
+	mv88e6352_phy_drivers_register();
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
 	register_switch_driver(&mv88e6171_switch_driver);
+	mv88e6171_phy_drivers_register();
 #endif
 	return 0;
 }
@@ -1468,12 +1497,19 @@ static void __exit mv88e6xxx_cleanup(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
 	unregister_switch_driver(&mv88e6171_switch_driver);
+	mv88e6171_phy_drivers_unregister();
+#endif
+#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
+	unregister_switch_driver(&mv88e6352_switch_driver);
+	mv88e6352_phy_drivers_unregister();
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
 	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
+	mv88e6123_61_65_phy_drivers_unregister();
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
 	unregister_switch_driver(&mv88e6131_switch_driver);
+	mv88e6131_phy_drivers_unregister();
 #endif
 }
 module_exit(mv88e6xxx_cleanup);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e045154f3364..449f948ca27f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -315,6 +315,18 @@ extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
 extern struct dsa_switch_driver mv88e6352_switch_driver;
 extern struct dsa_switch_driver mv88e6171_switch_driver;
 
+int mv88e6xxx_config_init(struct phy_device *phydev);
+int mv88e6xxx_config_aneg(struct phy_device *phydev);
+
+int mv88e6123_61_65_phy_drivers_register(void);
+void mv88e6123_61_65_phy_drivers_unregister(void);
+int mv88e6131_phy_drivers_register(void);
+void mv88e6131_phy_drivers_unregister(void);
+int mv88e6352_phy_drivers_register(void);
+void mv88e6352_phy_drivers_unregister(void);
+int mv88e6171_phy_drivers_register(void);
+void mv88e6171_phy_drivers_unregister(void);
+
 #define REG_READ(addr, reg)						\
 	({								\
 		int __ret;						\
-- 
2.1.0
