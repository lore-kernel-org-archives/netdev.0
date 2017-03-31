From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: dsa: Mock-up driver
Date: Thu, 30 Mar 2017 18:43:21 -0700
Message-ID: <20170331014321.3248-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36547 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934681AbdCaBnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 21:43:31 -0400
Received: by mail-wr0-f196.google.com with SMTP id k6so15299364wre.3
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:43:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for a DSA mock-up driver which essentially does
the following:

- registers/unregisters 4 fixed PHYs to the slave network devices
- uses eth0 (configurable) as the master netdev
- registers the switch as a fixed MDIO device against the fixed MDIO bus
  at address 31
- includes dynamic debug prints for dsa_switch_ops functions that can be
  enabled to get call traces

This is a good way to test modular builds as well as exercise the DSA
APIs without requiring access to real hardware. This does not test the
data-path, although this could be added later on.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2;

- removed an unnecessary change to include/linux/fixed_phy.h

 drivers/net/dsa/Kconfig           |   8 +
 drivers/net/dsa/Makefile          |   2 +-
 drivers/net/dsa/dsa_loop.c        | 329 ++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/dsa_loop.h        |  19 +++
 drivers/net/dsa/dsa_loop_bdinfo.c |  34 ++++
 5 files changed, 391 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/dsa/dsa_loop.c
 create mode 100644 drivers/net/dsa/dsa_loop.h
 create mode 100644 drivers/net/dsa/dsa_loop_bdinfo.c

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 564b267c8428..ba2e655eec19 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -34,4 +34,12 @@ config NET_DSA_QCA8K
 	  This enables support for the Qualcomm Atheros QCA8K Ethernet
 	  switch chips.
 
+config NET_DSA_LOOP
+	tristate "DSA mock-up Ethernet switch chip support"
+	depends on NET_DSA
+	select FIXED_PHY
+	---help---
+	  This enables support for a fake mock-up switch chip which
+	  exercises the DSA APIs.
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index a3c941632217..5c8830991041 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -2,6 +2,6 @@ obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm-sf2.o
 bcm-sf2-objs			:= bcm_sf2.o bcm_sf2_cfp.o
 obj-$(CONFIG_NET_DSA_QCA8K)	+= qca8k.o
-
 obj-y				+= b53/
 obj-y				+= mv88e6xxx/
+obj-$(CONFIG_NET_DSA_LOOP)	+= dsa_loop.o dsa_loop_bdinfo.o
diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
new file mode 100644
index 000000000000..0a9a2f846efd
--- /dev/null
+++ b/drivers/net/dsa/dsa_loop.c
@@ -0,0 +1,329 @@
+/*
+ * Distributed Switch Architecture loopback driver
+ *
+ * Copyright (C) 2016, Florian Fainelli <f.fainelli@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
+#include <linux/export.h>
+#include <linux/workqueue.h>
+#include <linux/module.h>
+#include <linux/if_bridge.h>
+#include <net/switchdev.h>
+#include <net/dsa.h>
+
+#include "dsa_loop.h"
+
+struct dsa_loop_vlan {
+	u16 members;
+	u16 untagged;
+};
+
+#define DSA_LOOP_VLANS	5
+
+struct dsa_loop_priv {
+	struct mii_bus	*bus;
+	unsigned int	port_base;
+	struct dsa_loop_vlan vlans[DSA_LOOP_VLANS];
+	struct net_device *netdev;
+	u16 pvid;
+};
+
+static struct phy_device *phydevs[PHY_MAX_ADDR];
+
+static enum dsa_tag_protocol dsa_loop_get_protocol(struct dsa_switch *ds)
+{
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	return DSA_TAG_PROTO_NONE;
+}
+
+static int dsa_loop_setup(struct dsa_switch *ds)
+{
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	return 0;
+}
+
+static int dsa_loop_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	return 0;
+}
+
+static int dsa_loop_phy_read(struct dsa_switch *ds, int port, int regnum)
+{
+	struct dsa_loop_priv *ps = ds->priv;
+	struct mii_bus *bus = ps->bus;
+
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	return mdiobus_read_nested(bus, ps->port_base + port, regnum);
+}
+
+static int dsa_loop_phy_write(struct dsa_switch *ds, int port,
+			      int regnum, u16 value)
+{
+	struct dsa_loop_priv *ps = ds->priv;
+	struct mii_bus *bus = ps->bus;
+
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	return mdiobus_write_nested(bus, ps->port_base + port, regnum, value);
+}
+
+static int dsa_loop_port_bridge_join(struct dsa_switch *ds, int port,
+				     struct net_device *bridge)
+{
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	return 0;
+}
+
+static void dsa_loop_port_bridge_leave(struct dsa_switch *ds, int port,
+				       struct net_device *bridge)
+{
+	dev_dbg(ds->dev, "%s\n", __func__);
+}
+
+static void dsa_loop_port_stp_state_set(struct dsa_switch *ds, int port,
+					u8 state)
+{
+	dev_dbg(ds->dev, "%s\n", __func__);
+}
+
+static int dsa_loop_port_vlan_filtering(struct dsa_switch *ds, int port,
+					bool vlan_filtering)
+{
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	return 0;
+}
+
+static int dsa_loop_port_vlan_prepare(struct dsa_switch *ds, int port,
+				      const struct switchdev_obj_port_vlan *vlan,
+				      struct switchdev_trans *trans)
+{
+	struct dsa_loop_priv *ps = ds->priv;
+	struct mii_bus *bus = ps->bus;
+
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	/* Just do a sleeping operation to make lockdep checks effective */
+	mdiobus_read(bus, ps->port_base + port, MII_BMSR);
+
+	if (vlan->vid_end > DSA_LOOP_VLANS)
+		return -ERANGE;
+
+	return 0;
+}
+
+static void dsa_loop_port_vlan_add(struct dsa_switch *ds, int port,
+				   const struct switchdev_obj_port_vlan *vlan,
+				   struct switchdev_trans *trans)
+{
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
+	struct dsa_loop_priv *ps = ds->priv;
+	struct mii_bus *bus = ps->bus;
+	struct dsa_loop_vlan *vl;
+	u16 vid;
+
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	/* Just do a sleeping operation to make lockdep checks effective */
+	mdiobus_read(bus, ps->port_base + port, MII_BMSR);
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		vl = &ps->vlans[vid];
+
+		vl->members |= BIT(port);
+		if (untagged)
+			vl->untagged |= BIT(port);
+		else
+			vl->untagged &= ~BIT(port);
+	}
+
+	if (pvid)
+		ps->pvid = vid;
+}
+
+static int dsa_loop_port_vlan_del(struct dsa_switch *ds, int port,
+				  const struct switchdev_obj_port_vlan *vlan)
+{
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	struct dsa_loop_priv *ps = ds->priv;
+	struct mii_bus *bus = ps->bus;
+	struct dsa_loop_vlan *vl;
+	u16 vid, pvid;
+
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	/* Just do a sleeping operation to make lockdep checks effective */
+	mdiobus_read(bus, ps->port_base + port, MII_BMSR);
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		vl = &ps->vlans[vid];
+
+		vl->members &= ~BIT(port);
+		if (untagged)
+			vl->untagged &= ~BIT(port);
+
+		if (pvid == vid)
+			pvid = 1;
+	}
+	ps->pvid = pvid;
+
+	return 0;
+}
+
+static int dsa_loop_port_vlan_dump(struct dsa_switch *ds, int port,
+				   struct switchdev_obj_port_vlan *vlan,
+				   int (*cb)(struct switchdev_obj *obj))
+{
+	struct dsa_loop_priv *ps = ds->priv;
+	struct mii_bus *bus = ps->bus;
+	struct dsa_loop_vlan *vl;
+	u16 vid, vid_start = 0;
+	int err;
+
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	/* Just do a sleeping operation to make lockdep checks effective */
+	mdiobus_read(bus, ps->port_base + port, MII_BMSR);
+
+	for (vid = vid_start; vid < DSA_LOOP_VLANS; vid++) {
+		vl = &ps->vlans[vid];
+
+		if (!(vl->members & BIT(port)))
+			continue;
+
+		vlan->vid_begin = vlan->vid_end = vid;
+		vlan->flags = 0;
+
+		if (vl->untagged & BIT(port))
+			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+		if (ps->pvid == vid)
+			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+
+		err = cb(&vlan->obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+static struct dsa_switch_ops dsa_loop_driver = {
+	.get_tag_protocol	= dsa_loop_get_protocol,
+	.setup			= dsa_loop_setup,
+	.set_addr		= dsa_loop_set_addr,
+	.phy_read		= dsa_loop_phy_read,
+	.phy_write		= dsa_loop_phy_write,
+	.port_bridge_join	= dsa_loop_port_bridge_join,
+	.port_bridge_leave	= dsa_loop_port_bridge_leave,
+	.port_stp_state_set	= dsa_loop_port_stp_state_set,
+	.port_vlan_filtering	= dsa_loop_port_vlan_filtering,
+	.port_vlan_prepare	= dsa_loop_port_vlan_prepare,
+	.port_vlan_add		= dsa_loop_port_vlan_add,
+	.port_vlan_del		= dsa_loop_port_vlan_del,
+	.port_vlan_dump		= dsa_loop_port_vlan_dump,
+};
+
+static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
+{
+	struct dsa_loop_pdata *pdata = mdiodev->dev.platform_data;
+	struct dsa_loop_priv *ps;
+	struct dsa_switch *ds;
+
+	if (!pdata)
+		return -ENODEV;
+
+	dev_info(&mdiodev->dev, "%s: 0x%0x\n",
+		 pdata->name, pdata->enabled_ports);
+
+	ds = dsa_switch_alloc(&mdiodev->dev, DSA_MAX_PORTS);
+	if (!ds)
+		return -ENOMEM;
+
+	ps = devm_kzalloc(&mdiodev->dev, sizeof(*ps), GFP_KERNEL);
+	ps->netdev = dev_get_by_name(&init_net, pdata->netdev);
+	if (!ps->netdev)
+		return -EPROBE_DEFER;
+
+	pdata->cd.netdev[DSA_LOOP_CPU_PORT] = &ps->netdev->dev;
+
+	ds->dev = &mdiodev->dev;
+	ds->ops = &dsa_loop_driver;
+	ds->priv = ps;
+	ps->bus = mdiodev->bus;
+
+	dev_set_drvdata(&mdiodev->dev, ds);
+
+	return dsa_register_switch(ds, ds->dev);
+}
+
+static void dsa_loop_drv_remove(struct mdio_device *mdiodev)
+{
+	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
+	struct dsa_loop_priv *ps = ds->priv;
+
+	dsa_unregister_switch(ds);
+	dev_put(ps->netdev);
+}
+
+static struct mdio_driver dsa_loop_drv = {
+	.mdiodrv.driver	= {
+		.name	= "dsa-loop",
+	},
+	.probe	= dsa_loop_drv_probe,
+	.remove	= dsa_loop_drv_remove,
+};
+
+#define NUM_FIXED_PHYS	(DSA_LOOP_NUM_PORTS - 2)
+
+static void unregister_fixed_phys(void)
+{
+	unsigned int i;
+
+	for (i = 0; i < NUM_FIXED_PHYS; i++)
+		if (phydevs[i])
+			fixed_phy_unregister(phydevs[i]);
+}
+
+static int __init dsa_loop_init(void)
+{
+	struct fixed_phy_status status = {
+		.link = 1,
+		.speed = SPEED_100,
+		.duplex = DUPLEX_FULL,
+	};
+	unsigned int i;
+
+	for (i = 0; i < NUM_FIXED_PHYS; i++)
+		phydevs[i] = fixed_phy_register(PHY_POLL, &status, -1, NULL);
+
+	return mdio_driver_register(&dsa_loop_drv);
+}
+module_init(dsa_loop_init);
+
+static void __exit dsa_loop_exit(void)
+{
+	mdio_driver_unregister(&dsa_loop_drv);
+	unregister_fixed_phys();
+}
+module_exit(dsa_loop_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Fainelli");
+MODULE_DESCRIPTION("DSA loopback driver");
+
diff --git a/drivers/net/dsa/dsa_loop.h b/drivers/net/dsa/dsa_loop.h
new file mode 100644
index 000000000000..dc396877fc95
--- /dev/null
+++ b/drivers/net/dsa/dsa_loop.h
@@ -0,0 +1,19 @@
+#ifndef __DSA_LOOP_H
+#define __DSA_LOOP_H
+
+struct dsa_chip_data;
+
+struct dsa_loop_pdata {
+	/* Must be first, such that dsa_register_switch() can access this
+	 * without gory pointer manipulations
+	 */
+	struct dsa_chip_data cd;
+	const char *name;
+	unsigned int enabled_ports;
+	const char *netdev;
+};
+
+#define DSA_LOOP_NUM_PORTS	6
+#define DSA_LOOP_CPU_PORT	(DSA_LOOP_NUM_PORTS - 1)
+
+#endif /* __DSA_LOOP_H */
diff --git a/drivers/net/dsa/dsa_loop_bdinfo.c b/drivers/net/dsa/dsa_loop_bdinfo.c
new file mode 100644
index 000000000000..b4a54cd7c178
--- /dev/null
+++ b/drivers/net/dsa/dsa_loop_bdinfo.c
@@ -0,0 +1,34 @@
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/phy.h>
+#include <net/dsa.h>
+
+#include "dsa_loop.h"
+
+static struct dsa_loop_pdata dsa_loop_pdata = {
+	.cd = {
+		.port_names[0] = "lan1",
+		.port_names[1] = "lan2",
+		.port_names[2] = "lan3",
+		.port_names[3] = "lan4",
+		.port_names[DSA_LOOP_CPU_PORT] = "cpu",
+	},
+	.name = "DSA mockup driver",
+	.enabled_ports = 0x1f,
+	.netdev = "eth0",
+};
+
+static const struct mdio_board_info bdinfo = {
+	.bus_id	= "fixed-0",
+	.modalias = "dsa-loop",
+	.mdio_addr = 31,
+	.platform_data = &dsa_loop_pdata,
+};
+
+static int __init dsa_loop_bdinfo_init(void)
+{
+	return mdiobus_register_board_info(&bdinfo, 1);
+}
+arch_initcall(dsa_loop_bdinfo_init)
+
+MODULE_LICENSE("GPL");
-- 
2.9.3
