From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] net: dsa: Remove hwmon support
Date: Wed, 11 Jan 2017 02:03:24 +0100
Message-ID: <1484096604-25033-3-git-send-email-andrew@lunn.ch>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54660 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760131AbdAKBD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 20:03:59 -0500
In-Reply-To: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the Marvell mv88e6xxx DSA driver made use of the HWMON support in
DSA. The temperature sensor is actually in the embedded PHY, and the
PHY driver now supports it. So remove all HWMON support from DSA and
drivers.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 154 ----------------------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  16 ----
 include/net/dsa.h                     |   8 --
 net/dsa/Kconfig                       |  11 ---
 net/dsa/Makefile                      |   1 -
 net/dsa/dsa.c                         |   4 -
 net/dsa/dsa_priv.h                    |   9 --
 net/dsa/hwmon.c                       | 147 --------------------------------
 8 files changed, 350 deletions(-)
 delete mode 100644 net/dsa/hwmon.c

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index eea8e0176e33..81843204b850 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2964,154 +2964,6 @@ static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_chip *chip)
 		of_node_put(chip->mdio_np);
 }
 
-#ifdef CONFIG_NET_DSA_HWMON
-
-static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	u16 val;
-	int ret;
-
-	*temp = 0;
-
-	mutex_lock(&chip->reg_lock);
-
-	ret = mv88e6xxx_phy_write(chip, 0x0, 0x16, 0x6);
-	if (ret < 0)
-		goto error;
-
-	/* Enable temperature sensor */
-	ret = mv88e6xxx_phy_read(chip, 0x0, 0x1a, &val);
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_phy_write(chip, 0x0, 0x1a, val | (1 << 5));
-	if (ret < 0)
-		goto error;
-
-	/* Wait for temperature to stabilize */
-	usleep_range(10000, 12000);
-
-	ret = mv88e6xxx_phy_read(chip, 0x0, 0x1a, &val);
-	if (ret < 0)
-		goto error;
-
-	/* Disable temperature sensor */
-	ret = mv88e6xxx_phy_write(chip, 0x0, 0x1a, val & ~(1 << 5));
-	if (ret < 0)
-		goto error;
-
-	*temp = ((val & 0x1f) - 5) * 5;
-
-error:
-	mv88e6xxx_phy_write(chip, 0x0, 0x16, 0x0);
-	mutex_unlock(&chip->reg_lock);
-	return ret;
-}
-
-static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
-	u16 val;
-	int ret;
-
-	*temp = 0;
-
-	mutex_lock(&chip->reg_lock);
-	ret = mv88e6xxx_phy_page_read(chip, phy, 6, 27, &val);
-	mutex_unlock(&chip->reg_lock);
-	if (ret < 0)
-		return ret;
-
-	*temp = (val & 0xff) - 25;
-
-	return 0;
-}
-
-static int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP))
-		return -EOPNOTSUPP;
-
-	if (mv88e6xxx_6320_family(chip) || mv88e6xxx_6352_family(chip))
-		return mv88e63xx_get_temp(ds, temp);
-
-	return mv88e61xx_get_temp(ds, temp);
-}
-
-static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
-	u16 val;
-	int ret;
-
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
-		return -EOPNOTSUPP;
-
-	*temp = 0;
-
-	mutex_lock(&chip->reg_lock);
-	ret = mv88e6xxx_phy_page_read(chip, phy, 6, 26, &val);
-	mutex_unlock(&chip->reg_lock);
-	if (ret < 0)
-		return ret;
-
-	*temp = (((val >> 8) & 0x1f) * 5) - 25;
-
-	return 0;
-}
-
-static int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
-	u16 val;
-	int err;
-
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
-		return -EOPNOTSUPP;
-
-	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_phy_page_read(chip, phy, 6, 26, &val);
-	if (err)
-		goto unlock;
-	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
-	err = mv88e6xxx_phy_page_write(chip, phy, 6, 26,
-				       (val & 0xe0ff) | (temp << 8));
-unlock:
-	mutex_unlock(&chip->reg_lock);
-
-	return err;
-}
-
-static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
-	u16 val;
-	int ret;
-
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
-		return -EOPNOTSUPP;
-
-	*alarm = false;
-
-	mutex_lock(&chip->reg_lock);
-	ret = mv88e6xxx_phy_page_read(chip, phy, 6, 26, &val);
-	mutex_unlock(&chip->reg_lock);
-	if (ret < 0)
-		return ret;
-
-	*alarm = !!(val & 0x40);
-
-	return 0;
-}
-#endif /* CONFIG_NET_DSA_HWMON */
-
 static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
@@ -4372,12 +4224,6 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.set_eee		= mv88e6xxx_set_eee,
 	.get_eee		= mv88e6xxx_get_eee,
-#ifdef CONFIG_NET_DSA_HWMON
-	.get_temp		= mv88e6xxx_get_temp,
-	.get_temp_limit		= mv88e6xxx_get_temp_limit,
-	.set_temp_limit		= mv88e6xxx_set_temp_limit,
-	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
-#endif
 	.get_eeprom_len		= mv88e6xxx_get_eeprom_len,
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a224d66dafd9..994f88fd7be1 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -496,12 +496,6 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_STU,
 
-	/* Internal temperature sensor.
-	 * Available from any enabled port's PHY register 26, page 6.
-	 */
-	MV88E6XXX_CAP_TEMP,
-	MV88E6XXX_CAP_TEMP_LIMIT,
-
 	/* VLAN Table Unit.
 	 * The VTU is used to program 802.1Q VLANs. See GLOBAL_VTU_OP.
 	 */
@@ -532,8 +526,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
 #define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
-#define MV88E6XXX_FLAG_TEMP		BIT_ULL(MV88E6XXX_CAP_TEMP)
-#define MV88E6XXX_FLAG_TEMP_LIMIT	BIT_ULL(MV88E6XXX_CAP_TEMP_LIMIT)
 #define MV88E6XXX_FLAG_VTU		BIT_ULL(MV88E6XXX_CAP_VTU)
 
 /* Ingress Rate Limit unit */
@@ -585,7 +577,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
@@ -604,8 +595,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_TEMP |		\
-	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
@@ -620,7 +609,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
@@ -636,8 +624,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_TEMP |		\
-	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
@@ -650,8 +636,6 @@ struct mv88e6xxx_ops;
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_TEMP |		\
-	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
diff --git a/include/net/dsa.h b/include/net/dsa.h
index b94d1f2ef912..904747967726 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -307,14 +307,6 @@ struct dsa_switch_ops {
 	int	(*get_eee)(struct dsa_switch *ds, int port,
 			   struct ethtool_eee *e);
 
-#ifdef CONFIG_NET_DSA_HWMON
-	/* Hardware monitoring */
-	int	(*get_temp)(struct dsa_switch *ds, int *temp);
-	int	(*get_temp_limit)(struct dsa_switch *ds, int *temp);
-	int	(*set_temp_limit)(struct dsa_switch *ds, int temp);
-	int	(*get_temp_alarm)(struct dsa_switch *ds, bool *alarm);
-#endif
-
 	/* EEPROM access */
 	int	(*get_eeprom_len)(struct dsa_switch *ds);
 	int	(*get_eeprom)(struct dsa_switch *ds,
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 39bb5b3a82f2..9649238eef40 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -15,17 +15,6 @@ config NET_DSA
 
 if NET_DSA
 
-config NET_DSA_HWMON
-	bool "Distributed Switch Architecture HWMON support"
-	default y
-	depends on HWMON && !(NET_DSA=y && HWMON=m)
-	---help---
-	  Say Y if you want to expose thermal sensor data on switches supported
-	  by the Distributed Switch Architecture.
-
-	  Some of those switches contain thermal sensors. This data is available
-	  via the hwmon sysfs interface and exposes the onboard sensors.
-
 # tagging formats
 config NET_DSA_TAG_BRCM
 	bool
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 560b6747c276..a3380ed0e0be 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,7 +1,6 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
 dsa_core-y += dsa.o slave.o dsa2.o
-dsa_core-$(CONFIG_NET_DSA_HWMON) += hwmon.o
 
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fd532487dfdf..4d0e5877d3bf 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -316,8 +316,6 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (ret)
 		return ret;
 
-	dsa_hwmon_register(ds);
-
 	return 0;
 }
 
@@ -376,8 +374,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 {
 	int port;
 
-	dsa_hwmon_unregister(ds);
-
 	/* Destroy network devices for physical switch ports. */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(ds->enabled_port_mask & (1 << port)))
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7e3385ec73f4..63ae1484abae 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -56,15 +56,6 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 int dsa_cpu_port_ethtool_setup(struct dsa_switch *ds);
 void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds);
 
-/* hwmon.c */
-#ifdef CONFIG_NET_DSA_HWMON
-void dsa_hwmon_register(struct dsa_switch *ds);
-void dsa_hwmon_unregister(struct dsa_switch *ds);
-#else
-static inline void dsa_hwmon_register(struct dsa_switch *ds) { }
-static inline void dsa_hwmon_unregister(struct dsa_switch *ds) { }
-#endif
-
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/hwmon.c b/net/dsa/hwmon.c
deleted file mode 100644
index 08831a811278..000000000000
--- a/net/dsa/hwmon.c
+++ /dev/null
@@ -1,147 +0,0 @@
-/*
- * net/dsa/hwmon.c - HWMON subsystem support
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#include <linux/ctype.h>
-#include <linux/hwmon.h>
-#include <net/dsa.h>
-
-#include "dsa_priv.h"
-
-static ssize_t temp1_input_show(struct device *dev,
-				struct device_attribute *attr, char *buf)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	int temp, ret;
-
-	ret = ds->ops->get_temp(ds, &temp);
-	if (ret < 0)
-		return ret;
-
-	return sprintf(buf, "%d\n", temp * 1000);
-}
-static DEVICE_ATTR_RO(temp1_input);
-
-static ssize_t temp1_max_show(struct device *dev,
-			      struct device_attribute *attr, char *buf)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	int temp, ret;
-
-	ret = ds->ops->get_temp_limit(ds, &temp);
-	if (ret < 0)
-		return ret;
-
-	return sprintf(buf, "%d\n", temp * 1000);
-}
-
-static ssize_t temp1_max_store(struct device *dev,
-			       struct device_attribute *attr, const char *buf,
-			       size_t count)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	int temp, ret;
-
-	ret = kstrtoint(buf, 0, &temp);
-	if (ret < 0)
-		return ret;
-
-	ret = ds->ops->set_temp_limit(ds, DIV_ROUND_CLOSEST(temp, 1000));
-	if (ret < 0)
-		return ret;
-
-	return count;
-}
-static DEVICE_ATTR_RW(temp1_max);
-
-static ssize_t temp1_max_alarm_show(struct device *dev,
-				    struct device_attribute *attr, char *buf)
-{
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	bool alarm;
-	int ret;
-
-	ret = ds->ops->get_temp_alarm(ds, &alarm);
-	if (ret < 0)
-		return ret;
-
-	return sprintf(buf, "%d\n", alarm);
-}
-static DEVICE_ATTR_RO(temp1_max_alarm);
-
-static struct attribute *dsa_hwmon_attrs[] = {
-	&dev_attr_temp1_input.attr,	/* 0 */
-	&dev_attr_temp1_max.attr,	/* 1 */
-	&dev_attr_temp1_max_alarm.attr,	/* 2 */
-	NULL
-};
-
-static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
-				       struct attribute *attr, int index)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct dsa_switch *ds = dev_get_drvdata(dev);
-	const struct dsa_switch_ops *ops = ds->ops;
-	umode_t mode = attr->mode;
-
-	if (index == 1) {
-		if (!ops->get_temp_limit)
-			mode = 0;
-		else if (!ops->set_temp_limit)
-			mode &= ~S_IWUSR;
-	} else if (index == 2 && !ops->get_temp_alarm) {
-		mode = 0;
-	}
-	return mode;
-}
-
-static const struct attribute_group dsa_hwmon_group = {
-	.attrs = dsa_hwmon_attrs,
-	.is_visible = dsa_hwmon_attrs_visible,
-};
-__ATTRIBUTE_GROUPS(dsa_hwmon);
-
-void dsa_hwmon_register(struct dsa_switch *ds)
-{
-	const char *netname = netdev_name(ds->dst->master_netdev);
-	char hname[IFNAMSIZ + 1];
-	int i, j;
-
-	/* If the switch provides temperature accessors, register with hardware
-	 * monitoring subsystem. Treat registration error as non-fatal.
-	 */
-	if (!ds->ops->get_temp)
-		return;
-
-	/* Create valid hwmon 'name' attribute */
-	for (i = j = 0; i < IFNAMSIZ && netname[i]; i++) {
-		if (isalnum(netname[i]))
-			hname[j++] = netname[i];
-	}
-	hname[j] = '\0';
-	scnprintf(ds->hwmon_name, sizeof(ds->hwmon_name), "%s_dsa%d", hname,
-		  ds->index);
-	ds->hwmon_dev = hwmon_device_register_with_groups(NULL, ds->hwmon_name,
-							  ds, dsa_hwmon_groups);
-	if (IS_ERR(ds->hwmon_dev)) {
-		pr_warn("DSA: failed to register HWMON subsystem for switch %d\n",
-			ds->index);
-		ds->hwmon_dev = NULL;
-	} else {
-		pr_info("DSA: registered HWMON subsystem for switch %d\n",
-			ds->index);
-	}
-}
-
-void dsa_hwmon_unregister(struct dsa_switch *ds)
-{
-	if (ds->hwmon_dev) {
-		hwmon_device_unregister(ds->hwmon_dev);
-		ds->hwmon_dev = NULL;
-	}
-}
-- 
2.11.0
