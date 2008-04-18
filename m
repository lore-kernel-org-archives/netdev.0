From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] Add support for board-level PHY fixups
Date: Fri, 18 Apr 2008 17:29:54 -0500
Message-ID: <1208557794-5940-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:38869 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbYDRWaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 18:30:00 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3IMTtCP023786
	for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 15:29:56 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3IMTsMo017727
	for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 17:29:54 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes the specific interaction between the platform and the PHY requires
special handling.  For instance, to change where the PHY's clock input is, or to
add a delay to account for latency issues in the data path.  We add a mechanism
for registering a callback with the PHY Lib to be called on matching PHYs when
they are brought up, or reset.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 Documentation/networking/phy.txt |   38 +++++++++++-
 drivers/net/phy/mdio_bus.c       |    3 +
 drivers/net/phy/phy.c            |    4 +-
 drivers/net/phy/phy_device.c     |  129 ++++++++++++++++++++++++++++++++++----
 include/linux/phy.h              |   24 +++++++-
 5 files changed, 182 insertions(+), 16 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 0bc95ea..8df6a7b 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -1,7 +1,7 @@
 
 -------
 PHY Abstraction Layer
-(Updated 2006-11-30)
+(Updated 2008-04-08)
 
 Purpose
 
@@ -291,3 +291,39 @@ Writing a PHY driver
  Feel free to look at the Marvell, Cicada, and Davicom drivers in
  drivers/net/phy/ for examples (the lxt and qsemi drivers have
  not been tested as of this writing)
+
+Board Fixups
+
+ Sometimes the specific interaction between the platform and the PHY requires
+ special handling.  For instance, to change where the PHY's clock input is,
+ or to add a delay to account for latency issues in the data path.  In order
+ to support such contingencies, the PHY Layer allows platform code to register
+ fixups to be run when the PHY is brought up (or subsequently reset).
+
+ When the PHY Layer brings up a PHY it checks to see if there are any fixups
+ registered for it, matching based on UID (contained in the PHY device's phy_id
+ field) and the bus identifier (contained in phydev->dev.bus_id).  Both must
+ match, however two constants, PHY_ANY_ID and PHY_ANY_UID, are provided as
+ wildcards for the bus ID and UID, respectively.
+
+ When a match is found, the PHY layer will invoke the run function associated
+ with the fixup.  This function is passed a pointer to the phy_device of
+ interest.  It should therefore only operate on that PHY.
+
+ The platform code can either register the fixup using phy_register_fixup():
+
+	int phy_register_fixup(const char *phy_id,
+		u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *));
+
+ Or using one of the two stubs, phy_register_fixup_for_uid() and
+ phy_register_fixup_for_id():
+
+ int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *));
+ int phy_register_fixup_for_id(const char *phy_id,
+		int (*run)(struct phy_device *));
+
+ The stubs set one of the two matching criteria, and set the other one to
+ match anything.
+
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 963630c..94e0b7e 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -89,6 +89,9 @@ int mdiobus_register(struct mii_bus *bus)
 
 			phydev->bus = bus;
 
+			/* Run all of the fixups for this PHY */
+			phy_scan_fixups(phydev);
+
 			err = device_register(&phydev->dev);
 
 			if (err) {
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 12fccb1..3c18bb5 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -406,8 +406,10 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		
 		if (mii_data->reg_num == MII_BMCR 
 				&& val & BMCR_RESET
-				&& phydev->drv->config_init)
+				&& phydev->drv->config_init) {
+			phy_scan_fixups(phydev);
 			phydev->drv->config_init(phydev);
+		}
 		break;
 
 	default:
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8b1121b..ddf8d51 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -53,6 +53,96 @@ static void phy_device_release(struct device *dev)
 	phy_device_free(to_phy_device(dev));
 }
 
+static LIST_HEAD(phy_fixup_list);
+static DEFINE_MUTEX(phy_fixup_lock);
+
+/*
+ * Creates a new phy_fixup and adds it to the list
+ * @bus_id: A string which matches phydev->dev.bus_id (or PHY_ANY_ID)
+ * @phy_uid: Used to match against phydev->phy_id (the UID of the PHY)
+ * 	It can also be PHY_ANY_UID
+ * @phy_uid_mask: Applied to phydev->phy_id and fixup->phy_uid before
+ * 	comparison
+ * @run: The actual code to be run when a matching PHY is found
+ */
+int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *))
+{
+	struct phy_fixup *fixup;
+
+	fixup = kzalloc(sizeof(struct phy_fixup), GFP_KERNEL);
+	if (!fixup)
+		return -ENOMEM;
+
+	strncpy(fixup->bus_id, bus_id, BUS_ID_SIZE);
+	fixup->phy_uid = phy_uid;
+	fixup->phy_uid_mask = phy_uid_mask;
+	fixup->run = run;
+
+	mutex_lock(&phy_fixup_lock);
+	list_add_tail(&fixup->list, &phy_fixup_list);
+	mutex_unlock(&phy_fixup_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_register_fixup);
+
+/* Registers a fixup to be run on any PHY with the UID in phy_uid */
+int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *))
+{
+	return phy_register_fixup(PHY_ANY_ID, phy_uid, phy_uid_mask, run);
+}
+EXPORT_SYMBOL(phy_register_fixup_for_uid);
+
+/* Registers a fixup to be run on the PHY with id string bus_id */
+int phy_register_fixup_for_id(const char *bus_id,
+		int (*run)(struct phy_device *))
+{
+	return phy_register_fixup(bus_id, PHY_ANY_UID, 0xffffffff, run);
+}
+EXPORT_SYMBOL(phy_register_fixup_for_id);
+
+/*
+ * Returns 1 if fixup matches phydev in bus_id and phy_uid.
+ * Fixups can be set to match any in one or more fields.
+ */
+static int phy_needs_fixup(struct phy_device *phydev, struct phy_fixup *fixup)
+{
+	if (strcmp(fixup->bus_id, phydev->dev.bus_id) != 0)
+		if (strcmp(fixup->bus_id, PHY_ANY_ID) != 0)
+			return 0;
+
+	if ((fixup->phy_uid & fixup->phy_uid_mask) !=
+			(phydev->phy_id & fixup->phy_uid_mask))
+		if (fixup->phy_uid != PHY_ANY_UID)
+			return 0;
+
+	return 1;
+}
+
+/* Runs any matching fixups for this phydev */
+int phy_scan_fixups(struct phy_device *phydev)
+{
+	struct phy_fixup *fixup;
+
+	mutex_lock(&phy_fixup_lock);
+	list_for_each_entry(fixup, &phy_fixup_list, list) {
+		if (phy_needs_fixup(phydev, fixup)) {
+			int err;
+
+			err = fixup->run(phydev);
+
+			if (err < 0)
+				return err;
+		}
+	}
+	mutex_unlock(&phy_fixup_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_scan_fixups);
+
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 {
 	struct phy_device *dev;
@@ -179,13 +269,13 @@ void phy_prepare_link(struct phy_device *phydev,
  *   choose to call only the subset of functions which provide
  *   the desired functionality.
  */
-struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
+struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
 		void (*handler)(struct net_device *), u32 flags,
 		phy_interface_t interface)
 {
 	struct phy_device *phydev;
 
-	phydev = phy_attach(dev, phy_id, flags, interface);
+	phydev = phy_attach(dev, bus_id, flags, interface);
 
 	if (IS_ERR(phydev))
 		return phydev;
@@ -226,7 +316,7 @@ static int phy_compare_id(struct device *dev, void *data)
 /**
  * phy_attach - attach a network device to a particular PHY device
  * @dev: network device to attach
- * @phy_id: PHY device to attach
+ * @bus_id: PHY device to attach
  * @flags: PHY device's dev_flags
  * @interface: PHY device's interface
  *
@@ -238,7 +328,7 @@ static int phy_compare_id(struct device *dev, void *data)
  *     change.  The phy_device is returned to the attaching driver.
  */
 struct phy_device *phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags, phy_interface_t interface)
+		const char *bus_id, u32 flags, phy_interface_t interface)
 {
 	struct bus_type *bus = &mdio_bus_type;
 	struct phy_device *phydev;
@@ -246,12 +336,12 @@ struct phy_device *phy_attach(struct net_device *dev,
 
 	/* Search the list of PHY devices on the mdio bus for the
 	 * PHY with the requested name */
-	d = bus_find_device(bus, NULL, (void *)phy_id, phy_compare_id);
+	d = bus_find_device(bus, NULL, (void *)bus_id, phy_compare_id);
 
 	if (d) {
 		phydev = to_phy_device(d);
 	} else {
-		printk(KERN_ERR "%s not found\n", phy_id);
+		printk(KERN_ERR "%s not found\n", bus_id);
 		return ERR_PTR(-ENODEV);
 	}
 
@@ -271,7 +361,7 @@ struct phy_device *phy_attach(struct net_device *dev,
 
 	if (phydev->attached_dev) {
 		printk(KERN_ERR "%s: %s already attached\n",
-				dev->name, phy_id);
+				dev->name, bus_id);
 		return ERR_PTR(-EBUSY);
 	}
 
@@ -287,6 +377,11 @@ struct phy_device *phy_attach(struct net_device *dev,
 	if (phydev->drv->config_init) {
 		int err;
 
+		err = phy_scan_fixups(phydev);
+
+		if (err < 0)
+			return ERR_PTR(err);
+
 		err = phydev->drv->config_init(phydev);
 
 		if (err < 0)
@@ -395,6 +490,7 @@ EXPORT_SYMBOL(genphy_config_advert);
  */
 int genphy_setup_forced(struct phy_device *phydev)
 {
+	int err;
 	int ctl = 0;
 
 	phydev->pause = phydev->asym_pause = 0;
@@ -407,17 +503,26 @@ int genphy_setup_forced(struct phy_device *phydev)
 	if (DUPLEX_FULL == phydev->duplex)
 		ctl |= BMCR_FULLDPLX;
 	
-	ctl = phy_write(phydev, MII_BMCR, ctl);
+	err = phy_write(phydev, MII_BMCR, ctl);
 
-	if (ctl < 0)
-		return ctl;
+	if (err < 0)
+		return err;
+
+	/*
+	 * Run the fixups on this PHY, just in case the
+	 * board code needs to change something after a reset
+	 */
+	err = phy_scan_fixups(phydev);
+
+	if (err < 0)
+		return err;
 
 	/* We just reset the device, so we'd better configure any
 	 * settings the PHY requires to operate */
 	if (phydev->drv->config_init)
-		ctl = phydev->drv->config_init(phydev);
+		err = phydev->drv->config_init(phydev);
 
-	return ctl;
+	return err;
 }
 
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 779cbcd..02df20f 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -379,6 +379,18 @@ struct phy_driver {
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
 
+#define PHY_ANY_ID "MATCH ANY PHY"
+#define PHY_ANY_UID 0xffffffff
+
+/* A Structure for boards to register fixups with the PHY Lib */
+struct phy_fixup {
+	struct list_head list;
+	char bus_id[BUS_ID_SIZE];
+	u32 phy_uid;
+	u32 phy_uid_mask;
+	int (*run)(struct phy_device *phydev);
+};
+
 int phy_read(struct phy_device *phydev, u16 regnum);
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
@@ -386,8 +398,8 @@ struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
 struct phy_device * phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags, phy_interface_t interface);
-struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
+		const char *bus_id, u32 flags, phy_interface_t interface);
+struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
 		void (*handler)(struct net_device *), u32 flags,
 		phy_interface_t interface);
 void phy_disconnect(struct phy_device *phydev);
@@ -427,5 +439,13 @@ void phy_print_status(struct phy_device *phydev);
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id);
 void phy_device_free(struct phy_device *phydev);
 
+int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *));
+int phy_register_fixup_for_id(const char *bus_id,
+		int (*run)(struct phy_device *));
+int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *));
+int phy_scan_fixups(struct phy_device *phydev);
+
 extern struct bus_type mdio_bus_type;
 #endif /* __PHY_H */
-- 
1.5.4.GIT

