From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: rename switch operations structure
Date: Tue, 23 Aug 2016 12:38:56 -0400
Message-ID: <20160823163856.21456-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the dsa_switch_driver structure contains only function pointers
as it is supposed to, rename it to the more appropriate dsa_switch_ops,
uniformly to any other operations structure in the kernel.

No functional changes here, basically just the result of something like:
s/dsa_switch_driver *drv/dsa_switch_ops *ops/g

However keep the {un,}register_switch_driver functions and their
dsa_switch_drivers list as is, since they represent the -- likely to be
deprecated soon -- legacy DSA registration framework.

In the meantime, also fix the following checks from checkpatch.pl to
make it happy with this patch:

    CHECK: Comparison to NULL could be written "!ops"
    #403: FILE: net/dsa/dsa.c:470:
    +	if (ops == NULL) {

    CHECK: Comparison to NULL could be written "ds->ops->get_strings"
    #773: FILE: net/dsa/slave.c:697:
    +		if (ds->ops->get_strings != NULL)

    CHECK: Comparison to NULL could be written "ds->ops->get_ethtool_stats"
    #824: FILE: net/dsa/slave.c:785:
    +	if (ds->ops->get_ethtool_stats != NULL)

    CHECK: Comparison to NULL could be written "ds->ops->get_sset_count"
    #835: FILE: net/dsa/slave.c:798:
    +		if (ds->ops->get_sset_count != NULL)

    total: 0 errors, 0 warnings, 4 checks, 784 lines checked

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 Documentation/networking/dsa/dsa.txt |  10 +--
 drivers/net/dsa/b53/b53_common.c     |   4 +-
 drivers/net/dsa/bcm_sf2.c            |   4 +-
 drivers/net/dsa/mv88e6060.c          |   6 +-
 drivers/net/dsa/mv88e6xxx/chip.c     |   8 +-
 include/net/dsa.h                    |  10 +--
 net/dsa/dsa.c                        |  70 ++++++++---------
 net/dsa/dsa2.c                       |  16 ++--
 net/dsa/slave.c                      | 146 +++++++++++++++++------------------
 9 files changed, 137 insertions(+), 137 deletions(-)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 9d05ed7..44ed453 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -227,9 +227,9 @@ to address individual switches in the tree.
 
 dsa_switch: structure describing a switch device in the tree, referencing a
 dsa_switch_tree as a backpointer, slave network devices, master network device,
-and a reference to the backing dsa_switch_driver
+and a reference to the backing dsa_switch_ops
 
-dsa_switch_driver: structure referencing function pointers, see below for a full
+dsa_switch_ops: structure referencing function pointers, see below for a full
 description.
 
 Design limitations
@@ -357,10 +357,10 @@ regular HWMON devices in /sys/class/hwmon/.
 Driver development
 ==================
 
-DSA switch drivers need to implement a dsa_switch_driver structure which will
+DSA switch drivers need to implement a dsa_switch_ops structure which will
 contain the various members described below.
 
-register_switch_driver() registers this dsa_switch_driver in its internal list
+register_switch_driver() registers this dsa_switch_ops in its internal list
 of drivers to probe for. unregister_switch_driver() does the exact opposite.
 
 Unless requested differently by setting the priv_size member accordingly, DSA
@@ -379,7 +379,7 @@ Switch configuration
   buses, return a non-NULL string
 
 - setup: setup function for the switch, this function is responsible for setting
-  up the dsa_switch_driver private structure with all it needs: register maps,
+  up the dsa_switch_ops private structure with all it needs: register maps,
   interrupts, mutexes, locks etc.. This function is also expected to properly
   configure the switch to separate all network interfaces from each other, that
   is, they should be isolated by the switch hardware itself, typically by creating
diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 65ecb51..6fb77cc 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1378,7 +1378,7 @@ static enum dsa_tag_protocol b53_get_tag_protocol(struct dsa_switch *ds)
 	return DSA_TAG_PROTO_NONE;
 }
 
-static struct dsa_switch_driver b53_switch_ops = {
+static struct dsa_switch_ops b53_switch_ops = {
 	.get_tag_protocol	= b53_get_tag_protocol,
 	.setup			= b53_setup,
 	.set_addr		= b53_set_addr,
@@ -1618,7 +1618,7 @@ static int b53_switch_init(struct b53_device *dev)
 			dev->vta_regs[1] = chip->vta_regs[1];
 			dev->vta_regs[2] = chip->vta_regs[2];
 			dev->jumbo_pm_reg = chip->jumbo_pm_reg;
-			ds->drv = &b53_switch_ops;
+			ds->ops = &b53_switch_ops;
 			dev->cpu_port = chip->cpu_port;
 			dev->num_vlans = chip->vlans;
 			dev->num_arl_entries = chip->arl_entries;
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index b47a74b..220e5d1 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1581,7 +1581,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static struct dsa_switch_driver bcm_sf2_switch_driver = {
+static struct dsa_switch_ops bcm_sf2_switch_ops = {
 	.setup			= bcm_sf2_sw_setup,
 	.get_tag_protocol	= bcm_sf2_sw_get_tag_protocol,
 	.set_addr		= bcm_sf2_sw_set_addr,
@@ -1632,7 +1632,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	priv = (struct bcm_sf2_priv *)(ds + 1);
 	ds->priv = priv;
 	ds->dev = &pdev->dev;
-	ds->drv = &bcm_sf2_switch_driver;
+	ds->ops = &bcm_sf2_switch_ops;
 
 	dev_set_drvdata(&pdev->dev, ds);
 
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 1fdfbf3..7ff9d37 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -252,7 +252,7 @@ mv88e6060_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	return reg_write(ds, addr, regnum, val);
 }
 
-static struct dsa_switch_driver mv88e6060_switch_driver = {
+static struct dsa_switch_ops mv88e6060_switch_ops = {
 	.get_tag_protocol = mv88e6060_get_tag_protocol,
 	.probe		= mv88e6060_drv_probe,
 	.setup		= mv88e6060_setup,
@@ -263,14 +263,14 @@ static struct dsa_switch_driver mv88e6060_switch_driver = {
 
 static int __init mv88e6060_init(void)
 {
-	register_switch_driver(&mv88e6060_switch_driver);
+	register_switch_driver(&mv88e6060_switch_ops);
 	return 0;
 }
 module_init(mv88e6060_init);
 
 static void __exit mv88e6060_cleanup(void)
 {
-	unregister_switch_driver(&mv88e6060_switch_driver);
+	unregister_switch_driver(&mv88e6060_switch_ops);
 }
 module_exit(mv88e6060_cleanup);
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 82d4516..750d01d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3976,7 +3976,7 @@ free:
 	return NULL;
 }
 
-static struct dsa_switch_driver mv88e6xxx_switch_driver = {
+static struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.probe			= mv88e6xxx_drv_probe,
 	.get_tag_protocol	= mv88e6xxx_get_tag_protocol,
 	.setup			= mv88e6xxx_setup,
@@ -4025,7 +4025,7 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
 
 	ds->dev = dev;
 	ds->priv = chip;
-	ds->drv = &mv88e6xxx_switch_driver;
+	ds->ops = &mv88e6xxx_switch_ops;
 
 	dev_set_drvdata(dev, ds);
 
@@ -4118,7 +4118,7 @@ static struct mdio_driver mv88e6xxx_driver = {
 
 static int __init mv88e6xxx_init(void)
 {
-	register_switch_driver(&mv88e6xxx_switch_driver);
+	register_switch_driver(&mv88e6xxx_switch_ops);
 	return mdio_driver_register(&mv88e6xxx_driver);
 }
 module_init(mv88e6xxx_init);
@@ -4126,7 +4126,7 @@ module_init(mv88e6xxx_init);
 static void __exit mv88e6xxx_cleanup(void)
 {
 	mdio_driver_unregister(&mv88e6xxx_driver);
-	unregister_switch_driver(&mv88e6xxx_switch_driver);
+	unregister_switch_driver(&mv88e6xxx_switch_ops);
 }
 module_exit(mv88e6xxx_cleanup);
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8ca2684..2ebeba4 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -165,9 +165,9 @@ struct dsa_switch {
 	struct dsa_chip_data	*cd;
 
 	/*
-	 * The used switch driver.
+	 * The switch operations.
 	 */
-	struct dsa_switch_driver	*drv;
+	struct dsa_switch_ops	*ops;
 
 	/*
 	 * An array of which element [a] indicates which port on this
@@ -236,7 +236,7 @@ struct switchdev_obj;
 struct switchdev_obj_port_fdb;
 struct switchdev_obj_port_vlan;
 
-struct dsa_switch_driver {
+struct dsa_switch_ops {
 	struct list_head	list;
 
 	/*
@@ -371,8 +371,8 @@ struct dsa_switch_driver {
 				 int (*cb)(struct switchdev_obj *obj));
 };
 
-void register_switch_driver(struct dsa_switch_driver *type);
-void unregister_switch_driver(struct dsa_switch_driver *type);
+void register_switch_driver(struct dsa_switch_ops *type);
+void unregister_switch_driver(struct dsa_switch_ops *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 static inline void *ds_to_priv(struct dsa_switch *ds)
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 8d3a28d..d8d267e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -61,27 +61,27 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 static DEFINE_MUTEX(dsa_switch_drivers_mutex);
 static LIST_HEAD(dsa_switch_drivers);
 
-void register_switch_driver(struct dsa_switch_driver *drv)
+void register_switch_driver(struct dsa_switch_ops *ops)
 {
 	mutex_lock(&dsa_switch_drivers_mutex);
-	list_add_tail(&drv->list, &dsa_switch_drivers);
+	list_add_tail(&ops->list, &dsa_switch_drivers);
 	mutex_unlock(&dsa_switch_drivers_mutex);
 }
 EXPORT_SYMBOL_GPL(register_switch_driver);
 
-void unregister_switch_driver(struct dsa_switch_driver *drv)
+void unregister_switch_driver(struct dsa_switch_ops *ops)
 {
 	mutex_lock(&dsa_switch_drivers_mutex);
-	list_del_init(&drv->list);
+	list_del_init(&ops->list);
 	mutex_unlock(&dsa_switch_drivers_mutex);
 }
 EXPORT_SYMBOL_GPL(unregister_switch_driver);
 
-static struct dsa_switch_driver *
+static struct dsa_switch_ops *
 dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 		 const char **_name, void **priv)
 {
-	struct dsa_switch_driver *ret;
+	struct dsa_switch_ops *ret;
 	struct list_head *list;
 	const char *name;
 
@@ -90,13 +90,13 @@ dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 
 	mutex_lock(&dsa_switch_drivers_mutex);
 	list_for_each(list, &dsa_switch_drivers) {
-		struct dsa_switch_driver *drv;
+		struct dsa_switch_ops *ops;
 
-		drv = list_entry(list, struct dsa_switch_driver, list);
+		ops = list_entry(list, struct dsa_switch_ops, list);
 
-		name = drv->probe(parent, host_dev, sw_addr, priv);
+		name = ops->probe(parent, host_dev, sw_addr, priv);
 		if (name != NULL) {
-			ret = drv;
+			ret = ops;
 			break;
 		}
 	}
@@ -117,7 +117,7 @@ static ssize_t temp1_input_show(struct device *dev,
 	struct dsa_switch *ds = dev_get_drvdata(dev);
 	int temp, ret;
 
-	ret = ds->drv->get_temp(ds, &temp);
+	ret = ds->ops->get_temp(ds, &temp);
 	if (ret < 0)
 		return ret;
 
@@ -131,7 +131,7 @@ static ssize_t temp1_max_show(struct device *dev,
 	struct dsa_switch *ds = dev_get_drvdata(dev);
 	int temp, ret;
 
-	ret = ds->drv->get_temp_limit(ds, &temp);
+	ret = ds->ops->get_temp_limit(ds, &temp);
 	if (ret < 0)
 		return ret;
 
@@ -149,7 +149,7 @@ static ssize_t temp1_max_store(struct device *dev,
 	if (ret < 0)
 		return ret;
 
-	ret = ds->drv->set_temp_limit(ds, DIV_ROUND_CLOSEST(temp, 1000));
+	ret = ds->ops->set_temp_limit(ds, DIV_ROUND_CLOSEST(temp, 1000));
 	if (ret < 0)
 		return ret;
 
@@ -164,7 +164,7 @@ static ssize_t temp1_max_alarm_show(struct device *dev,
 	bool alarm;
 	int ret;
 
-	ret = ds->drv->get_temp_alarm(ds, &alarm);
+	ret = ds->ops->get_temp_alarm(ds, &alarm);
 	if (ret < 0)
 		return ret;
 
@@ -184,15 +184,15 @@ static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
 {
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct dsa_switch *ds = dev_get_drvdata(dev);
-	struct dsa_switch_driver *drv = ds->drv;
+	struct dsa_switch_ops *ops = ds->ops;
 	umode_t mode = attr->mode;
 
 	if (index == 1) {
-		if (!drv->get_temp_limit)
+		if (!ops->get_temp_limit)
 			mode = 0;
-		else if (!drv->set_temp_limit)
+		else if (!ops->set_temp_limit)
 			mode &= ~S_IWUSR;
-	} else if (index == 2 && !drv->get_temp_alarm) {
+	} else if (index == 2 && !ops->get_temp_alarm) {
 		mode = 0;
 	}
 	return mode;
@@ -228,8 +228,8 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 
 		genphy_config_init(phydev);
 		genphy_read_status(phydev);
-		if (ds->drv->adjust_link)
-			ds->drv->adjust_link(ds, port, phydev);
+		if (ds->ops->adjust_link)
+			ds->ops->adjust_link(ds, port, phydev);
 	}
 
 	return 0;
@@ -303,7 +303,7 @@ void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds)
 
 static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
-	struct dsa_switch_driver *drv = ds->drv;
+	struct dsa_switch_ops *ops = ds->ops;
 	struct dsa_switch_tree *dst = ds->dst;
 	struct dsa_chip_data *cd = ds->cd;
 	bool valid_name_found = false;
@@ -356,7 +356,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (dst->cpu_switch == index) {
 		enum dsa_tag_protocol tag_protocol;
 
-		tag_protocol = drv->get_tag_protocol(ds);
+		tag_protocol = ops->get_tag_protocol(ds);
 		dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 		if (IS_ERR(dst->tag_ops)) {
 			ret = PTR_ERR(dst->tag_ops);
@@ -371,15 +371,15 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	/*
 	 * Do basic register setup.
 	 */
-	ret = drv->setup(ds);
+	ret = ops->setup(ds);
 	if (ret < 0)
 		goto out;
 
-	ret = drv->set_addr(ds, dst->master_netdev->dev_addr);
+	ret = ops->set_addr(ds, dst->master_netdev->dev_addr);
 	if (ret < 0)
 		goto out;
 
-	if (!ds->slave_mii_bus && drv->phy_read) {
+	if (!ds->slave_mii_bus && ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(parent);
 		if (!ds->slave_mii_bus) {
 			ret = -ENOMEM;
@@ -426,7 +426,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * register with hardware monitoring subsystem.
 	 * Treat registration error as non-fatal and ignore it.
 	 */
-	if (drv->get_temp) {
+	if (ops->get_temp) {
 		const char *netname = netdev_name(dst->master_netdev);
 		char hname[IFNAMSIZ + 1];
 		int i, j;
@@ -457,7 +457,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		 struct device *parent, struct device *host_dev)
 {
 	struct dsa_chip_data *cd = dst->pd->chip + index;
-	struct dsa_switch_driver *drv;
+	struct dsa_switch_ops *ops;
 	struct dsa_switch *ds;
 	int ret;
 	const char *name;
@@ -466,8 +466,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Probe for switch model.
 	 */
-	drv = dsa_switch_probe(parent, host_dev, cd->sw_addr, &name, &priv);
-	if (drv == NULL) {
+	ops = dsa_switch_probe(parent, host_dev, cd->sw_addr, &name, &priv);
+	if (!ops) {
 		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
 			   index);
 		return ERR_PTR(-EINVAL);
@@ -486,7 +486,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->dst = dst;
 	ds->index = index;
 	ds->cd = cd;
-	ds->drv = drv;
+	ds->ops = ops;
 	ds->priv = priv;
 	ds->dev = parent;
 
@@ -541,7 +541,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		ds->dsa_port_mask |= ~(1 << port);
 	}
 
-	if (ds->slave_mii_bus && ds->drv->phy_read)
+	if (ds->slave_mii_bus && ds->ops->phy_read)
 		mdiobus_unregister(ds->slave_mii_bus);
 }
 
@@ -560,8 +560,8 @@ int dsa_switch_suspend(struct dsa_switch *ds)
 			return ret;
 	}
 
-	if (ds->drv->suspend)
-		ret = ds->drv->suspend(ds);
+	if (ds->ops->suspend)
+		ret = ds->ops->suspend(ds);
 
 	return ret;
 }
@@ -571,8 +571,8 @@ int dsa_switch_resume(struct dsa_switch *ds)
 {
 	int i, ret = 0;
 
-	if (ds->drv->resume)
-		ret = ds->drv->resume(ds);
+	if (ds->ops->resume)
+		ret = ds->ops->resume(ds);
 
 	if (ret)
 		return ret;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 2e34322..8278385 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -294,25 +294,25 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	int err;
 
 	/* Initialize ds->phys_mii_mask before registering the slave MDIO bus
-	 * driver and before drv->setup() has run, since the switch drivers and
+	 * driver and before ops->setup() has run, since the switch drivers and
 	 * the slave MDIO bus driver rely on these values for probing PHY
 	 * devices or not
 	 */
 	ds->phys_mii_mask = ds->enabled_port_mask;
 
-	err = ds->drv->setup(ds);
+	err = ds->ops->setup(ds);
 	if (err < 0)
 		return err;
 
-	err = ds->drv->set_addr(ds, dst->master_netdev->dev_addr);
+	err = ds->ops->set_addr(ds, dst->master_netdev->dev_addr);
 	if (err < 0)
 		return err;
 
-	err = ds->drv->set_addr(ds, dst->master_netdev->dev_addr);
+	err = ds->ops->set_addr(ds, dst->master_netdev->dev_addr);
 	if (err < 0)
 		return err;
 
-	if (!ds->slave_mii_bus && ds->drv->phy_read) {
+	if (!ds->slave_mii_bus && ds->ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
 		if (!ds->slave_mii_bus)
 			return -ENOMEM;
@@ -374,7 +374,7 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 		dsa_user_port_unapply(port, index, ds);
 	}
 
-	if (ds->slave_mii_bus && ds->drv->phy_read)
+	if (ds->slave_mii_bus && ds->ops->phy_read)
 		mdiobus_unregister(ds->slave_mii_bus);
 }
 
@@ -466,7 +466,7 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 		dst->cpu_port = index;
 	}
 
-	tag_protocol = ds->drv->get_tag_protocol(ds);
+	tag_protocol = ds->ops->get_tag_protocol(ds);
 	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 	if (IS_ERR(dst->tag_ops)) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
@@ -543,7 +543,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 
 		ds->ports[reg].dn = port;
 
-		/* Initialize enabled_port_mask now for drv->setup()
+		/* Initialize enabled_port_mask now for ops->setup()
 		 * to have access to a correct value, just like what
 		 * net/dsa/dsa.c::dsa_switch_setup_one does.
 		 */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index fc91967..9f6c2a2 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -28,7 +28,7 @@ static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 	struct dsa_switch *ds = bus->priv;
 
 	if (ds->phys_mii_mask & (1 << addr))
-		return ds->drv->phy_read(ds, addr, reg);
+		return ds->ops->phy_read(ds, addr, reg);
 
 	return 0xffff;
 }
@@ -38,7 +38,7 @@ static int dsa_slave_phy_write(struct mii_bus *bus, int addr, int reg, u16 val)
 	struct dsa_switch *ds = bus->priv;
 
 	if (ds->phys_mii_mask & (1 << addr))
-		return ds->drv->phy_write(ds, addr, reg, val);
+		return ds->ops->phy_write(ds, addr, reg, val);
 
 	return 0;
 }
@@ -98,14 +98,14 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_allmulti;
 	}
 
-	if (ds->drv->port_enable) {
-		err = ds->drv->port_enable(ds, p->port, p->phy);
+	if (ds->ops->port_enable) {
+		err = ds->ops->port_enable(ds, p->port, p->phy);
 		if (err)
 			goto clear_promisc;
 	}
 
-	if (ds->drv->port_stp_state_set)
-		ds->drv->port_stp_state_set(ds, p->port, stp_state);
+	if (ds->ops->port_stp_state_set)
+		ds->ops->port_stp_state_set(ds, p->port, stp_state);
 
 	if (p->phy)
 		phy_start(p->phy);
@@ -144,11 +144,11 @@ static int dsa_slave_close(struct net_device *dev)
 	if (!ether_addr_equal(dev->dev_addr, master->dev_addr))
 		dev_uc_del(master, dev->dev_addr);
 
-	if (ds->drv->port_disable)
-		ds->drv->port_disable(ds, p->port, p->phy);
+	if (ds->ops->port_disable)
+		ds->ops->port_disable(ds, p->port, p->phy);
 
-	if (ds->drv->port_stp_state_set)
-		ds->drv->port_stp_state_set(ds, p->port, BR_STATE_DISABLED);
+	if (ds->ops->port_stp_state_set)
+		ds->ops->port_stp_state_set(ds, p->port, BR_STATE_DISABLED);
 
 	return 0;
 }
@@ -209,13 +209,13 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 	struct dsa_switch *ds = p->parent;
 
 	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->drv->port_vlan_prepare || !ds->drv->port_vlan_add)
+		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
 			return -EOPNOTSUPP;
 
-		return ds->drv->port_vlan_prepare(ds, p->port, vlan, trans);
+		return ds->ops->port_vlan_prepare(ds, p->port, vlan, trans);
 	}
 
-	ds->drv->port_vlan_add(ds, p->port, vlan, trans);
+	ds->ops->port_vlan_add(ds, p->port, vlan, trans);
 
 	return 0;
 }
@@ -226,10 +226,10 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (!ds->drv->port_vlan_del)
+	if (!ds->ops->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	return ds->drv->port_vlan_del(ds, p->port, vlan);
+	return ds->ops->port_vlan_del(ds, p->port, vlan);
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
@@ -239,8 +239,8 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->drv->port_vlan_dump)
-		return ds->drv->port_vlan_dump(ds, p->port, vlan, cb);
+	if (ds->ops->port_vlan_dump)
+		return ds->ops->port_vlan_dump(ds, p->port, vlan, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -253,13 +253,13 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 	struct dsa_switch *ds = p->parent;
 
 	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->drv->port_fdb_prepare || !ds->drv->port_fdb_add)
+		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->drv->port_fdb_prepare(ds, p->port, fdb, trans);
+		return ds->ops->port_fdb_prepare(ds, p->port, fdb, trans);
 	}
 
-	ds->drv->port_fdb_add(ds, p->port, fdb, trans);
+	ds->ops->port_fdb_add(ds, p->port, fdb, trans);
 
 	return 0;
 }
@@ -271,8 +271,8 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (ds->drv->port_fdb_del)
-		ret = ds->drv->port_fdb_del(ds, p->port, fdb);
+	if (ds->ops->port_fdb_del)
+		ret = ds->ops->port_fdb_del(ds, p->port, fdb);
 
 	return ret;
 }
@@ -284,8 +284,8 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->drv->port_fdb_dump)
-		return ds->drv->port_fdb_dump(ds, p->port, fdb, cb);
+	if (ds->ops->port_fdb_dump)
+		return ds->ops->port_fdb_dump(ds, p->port, fdb, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -308,9 +308,9 @@ static int dsa_slave_stp_state_set(struct net_device *dev,
 	struct dsa_switch *ds = p->parent;
 
 	if (switchdev_trans_ph_prepare(trans))
-		return ds->drv->port_stp_state_set ? 0 : -EOPNOTSUPP;
+		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
 
-	ds->drv->port_stp_state_set(ds, p->port, attr->u.stp_state);
+	ds->ops->port_stp_state_set(ds, p->port, attr->u.stp_state);
 
 	return 0;
 }
@@ -326,8 +326,8 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
-	if (ds->drv->port_vlan_filtering)
-		return ds->drv->port_vlan_filtering(ds, p->port,
+	if (ds->ops->port_vlan_filtering)
+		return ds->ops->port_vlan_filtering(ds, p->port,
 						    attr->u.vlan_filtering);
 
 	return 0;
@@ -365,8 +365,8 @@ static int dsa_slave_ageing_time(struct net_device *dev,
 	ds->ports[p->port].ageing_time = ageing_time;
 	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
 
-	if (ds->drv->set_ageing_time)
-		return ds->drv->set_ageing_time(ds, ageing_time);
+	if (ds->ops->set_ageing_time)
+		return ds->ops->set_ageing_time(ds, ageing_time);
 
 	return 0;
 }
@@ -481,8 +481,8 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 
 	p->bridge_dev = br;
 
-	if (ds->drv->port_bridge_join)
-		ret = ds->drv->port_bridge_join(ds, p->port, br);
+	if (ds->ops->port_bridge_join)
+		ret = ds->ops->port_bridge_join(ds, p->port, br);
 
 	return ret == -EOPNOTSUPP ? 0 : ret;
 }
@@ -493,16 +493,16 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev)
 	struct dsa_switch *ds = p->parent;
 
 
-	if (ds->drv->port_bridge_leave)
-		ds->drv->port_bridge_leave(ds, p->port);
+	if (ds->ops->port_bridge_leave)
+		ds->ops->port_bridge_leave(ds, p->port);
 
 	p->bridge_dev = NULL;
 
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
-	if (ds->drv->port_stp_state_set)
-		ds->drv->port_stp_state_set(ds, p->port, BR_STATE_FORWARDING);
+	if (ds->ops->port_stp_state_set)
+		ds->ops->port_stp_state_set(ds, p->port, BR_STATE_FORWARDING);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
@@ -605,8 +605,8 @@ static int dsa_slave_get_regs_len(struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->drv->get_regs_len)
-		return ds->drv->get_regs_len(ds, p->port);
+	if (ds->ops->get_regs_len)
+		return ds->ops->get_regs_len(ds, p->port);
 
 	return -EOPNOTSUPP;
 }
@@ -617,8 +617,8 @@ dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->drv->get_regs)
-		ds->drv->get_regs(ds, p->port, regs, _p);
+	if (ds->ops->get_regs)
+		ds->ops->get_regs(ds, p->port, regs, _p);
 }
 
 static int dsa_slave_nway_reset(struct net_device *dev)
@@ -651,8 +651,8 @@ static int dsa_slave_get_eeprom_len(struct net_device *dev)
 	if (ds->cd && ds->cd->eeprom_len)
 		return ds->cd->eeprom_len;
 
-	if (ds->drv->get_eeprom_len)
-		return ds->drv->get_eeprom_len(ds);
+	if (ds->ops->get_eeprom_len)
+		return ds->ops->get_eeprom_len(ds);
 
 	return 0;
 }
@@ -663,8 +663,8 @@ static int dsa_slave_get_eeprom(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->drv->get_eeprom)
-		return ds->drv->get_eeprom(ds, eeprom, data);
+	if (ds->ops->get_eeprom)
+		return ds->ops->get_eeprom(ds, eeprom, data);
 
 	return -EOPNOTSUPP;
 }
@@ -675,8 +675,8 @@ static int dsa_slave_set_eeprom(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->drv->set_eeprom)
-		return ds->drv->set_eeprom(ds, eeprom, data);
+	if (ds->ops->set_eeprom)
+		return ds->ops->set_eeprom(ds, eeprom, data);
 
 	return -EOPNOTSUPP;
 }
@@ -694,8 +694,8 @@ static void dsa_slave_get_strings(struct net_device *dev,
 		strncpy(data + len, "tx_bytes", len);
 		strncpy(data + 2 * len, "rx_packets", len);
 		strncpy(data + 3 * len, "rx_bytes", len);
-		if (ds->drv->get_strings != NULL)
-			ds->drv->get_strings(ds, p->port, data + 4 * len);
+		if (ds->ops->get_strings)
+			ds->ops->get_strings(ds, p->port, data + 4 * len);
 	}
 }
 
@@ -714,8 +714,8 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 		dst->master_ethtool_ops.get_ethtool_stats(dev, stats, data);
 	}
 
-	if (ds->drv->get_ethtool_stats)
-		ds->drv->get_ethtool_stats(ds, cpu_port, data + count);
+	if (ds->ops->get_ethtool_stats)
+		ds->ops->get_ethtool_stats(ds, cpu_port, data + count);
 }
 
 static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
@@ -727,8 +727,8 @@ static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
 	if (dst->master_ethtool_ops.get_sset_count)
 		count += dst->master_ethtool_ops.get_sset_count(dev, sset);
 
-	if (sset == ETH_SS_STATS && ds->drv->get_sset_count)
-		count += ds->drv->get_sset_count(ds);
+	if (sset == ETH_SS_STATS && ds->ops->get_sset_count)
+		count += ds->ops->get_sset_count(ds);
 
 	return count;
 }
@@ -755,14 +755,14 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 		dst->master_ethtool_ops.get_strings(dev, stringset, data);
 	}
 
-	if (stringset == ETH_SS_STATS && ds->drv->get_strings) {
+	if (stringset == ETH_SS_STATS && ds->ops->get_strings) {
 		ndata = data + mcount * len;
 		/* This function copies ETH_GSTRINGS_LEN bytes, we will mangle
 		 * the output after to prepend our CPU port prefix we
 		 * constructed earlier
 		 */
-		ds->drv->get_strings(ds, cpu_port, ndata);
-		count = ds->drv->get_sset_count(ds);
+		ds->ops->get_strings(ds, cpu_port, ndata);
+		count = ds->ops->get_sset_count(ds);
 		for (i = 0; i < count; i++) {
 			memmove(ndata + (i * len + sizeof(pfx)),
 				ndata + i * len, len - sizeof(pfx));
@@ -782,8 +782,8 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 	data[1] = dev->stats.tx_bytes;
 	data[2] = dev->stats.rx_packets;
 	data[3] = dev->stats.rx_bytes;
-	if (ds->drv->get_ethtool_stats != NULL)
-		ds->drv->get_ethtool_stats(ds, p->port, data + 4);
+	if (ds->ops->get_ethtool_stats)
+		ds->ops->get_ethtool_stats(ds, p->port, data + 4);
 }
 
 static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
@@ -795,8 +795,8 @@ static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 		int count;
 
 		count = 4;
-		if (ds->drv->get_sset_count != NULL)
-			count += ds->drv->get_sset_count(ds);
+		if (ds->ops->get_sset_count)
+			count += ds->ops->get_sset_count(ds);
 
 		return count;
 	}
@@ -809,8 +809,8 @@ static void dsa_slave_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->drv->get_wol)
-		ds->drv->get_wol(ds, p->port, w);
+	if (ds->ops->get_wol)
+		ds->ops->get_wol(ds, p->port, w);
 }
 
 static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
@@ -819,8 +819,8 @@ static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (ds->drv->set_wol)
-		ret = ds->drv->set_wol(ds, p->port, w);
+	if (ds->ops->set_wol)
+		ret = ds->ops->set_wol(ds, p->port, w);
 
 	return ret;
 }
@@ -831,10 +831,10 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	struct dsa_switch *ds = p->parent;
 	int ret;
 
-	if (!ds->drv->set_eee)
+	if (!ds->ops->set_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->drv->set_eee(ds, p->port, p->phy, e);
+	ret = ds->ops->set_eee(ds, p->port, p->phy, e);
 	if (ret)
 		return ret;
 
@@ -850,10 +850,10 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	struct dsa_switch *ds = p->parent;
 	int ret;
 
-	if (!ds->drv->get_eee)
+	if (!ds->ops->get_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->drv->get_eee(ds, p->port, e);
+	ret = ds->ops->get_eee(ds, p->port, e);
 	if (ret)
 		return ret;
 
@@ -988,8 +988,8 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 		p->old_pause = p->phy->pause;
 	}
 
-	if (ds->drv->adjust_link && status_changed)
-		ds->drv->adjust_link(ds, p->port, p->phy);
+	if (ds->ops->adjust_link && status_changed)
+		ds->ops->adjust_link(ds, p->port, p->phy);
 
 	if (status_changed)
 		phy_print_status(p->phy);
@@ -1004,8 +1004,8 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 	if (dev) {
 		p = netdev_priv(dev);
 		ds = p->parent;
-		if (ds->drv->fixed_link_update)
-			ds->drv->fixed_link_update(ds, p->port, status);
+		if (ds->ops->fixed_link_update)
+			ds->ops->fixed_link_update(ds, p->port, status);
 	}
 
 	return 0;
@@ -1062,8 +1062,8 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		phy_dn = port_dn;
 	}
 
-	if (ds->drv->get_phy_flags)
-		phy_flags = ds->drv->get_phy_flags(ds, p->port);
+	if (ds->ops->get_phy_flags)
+		phy_flags = ds->ops->get_phy_flags(ds, p->port);
 
 	if (phy_dn) {
 		int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
-- 
2.9.3
