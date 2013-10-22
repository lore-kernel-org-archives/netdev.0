From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 4/4 net-next] net: phy: add fake switch driver
Date: Tue, 22 Oct 2013 11:23:49 -0700
Message-ID: <1382466229-15123-5-git-send-email-f.fainelli@gmail.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, nbd@openwrt.org,
	blogic@openwrt.org, jogo@openwrt.org, gary@mlbassoc.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2641 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655Ab3JVSYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 14:24:12 -0400
In-Reply-To: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a fake switch driver which can be used to test both the kernel
swconfig API and user-land swconfig tool for regression and features
additions.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/Kconfig          |   8 ++
 drivers/net/phy/Makefile         |   1 +
 drivers/net/phy/swconfig-hwsim.c | 230 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 239 insertions(+)
 create mode 100644 drivers/net/phy/swconfig-hwsim.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d02ed5a..6bb940e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -18,6 +18,14 @@ config SWCONFIG
 	  Switch configuration API using netlink. This allows
 	  you to configure the VLAN features of certain switches.
 
+config SWCONFIG_HWSIM
+	tristate "Fake switch driver"
+	depends on SWCONFIG
+	---help---
+	  Fake switch driver which simulates an 8 port Gigabit switch
+	  for regression testing of the swconfig kernel and user-space
+	  API.
+
 comment "MII PHY device drivers"
 
 config AT803X_PHY
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 1998034..b72405a 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -4,6 +4,7 @@ libphy-objs			:= phy.o phy_device.o mdio_bus.o
 
 obj-$(CONFIG_PHYLIB)		+= libphy.o
 obj-$(CONFIG_SWCONFIG)		+= swconfig.o
+obj-$(CONFIG_SWCONFIG_HWSIM)	+= swconfig-hwsim.o
 obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
 obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_CICADA_PHY)	+= cicada.o
diff --git a/drivers/net/phy/swconfig-hwsim.c b/drivers/net/phy/swconfig-hwsim.c
new file mode 100644
index 0000000..39cb141
--- /dev/null
+++ b/drivers/net/phy/swconfig-hwsim.c
@@ -0,0 +1,230 @@
+/*
+ * Simulation swconfig driver
+ *
+ * Copyright (C) 2013, Florian Fainelli <f.fainelli@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/swconfig.h>
+
+struct swconfig_hwsim_port_state {
+	unsigned int speed;
+	unsigned int link;
+	unsigned int duplex;
+};
+
+#define SWCONFIG_HWSIM_NUM_PORTS	8
+
+struct swconfig_hwsim_state {
+	struct switch_dev dev;
+	struct net_device *loopback;
+	char buf[255];
+	struct swconfig_hwsim_port_state ports[SWCONFIG_HWSIM_NUM_PORTS];
+};
+
+#define get_state(_dev) container_of((_dev), struct swconfig_hwsim_state, dev)
+
+static int swconfig_hwsim_get_name(struct switch_dev *dev,
+				   const struct switch_attr *attr,
+				   struct switch_val *val)
+{
+	struct swconfig_hwsim_state *state = get_state(dev);
+
+	val->value.s = state->dev.name;
+
+	return 0;
+}
+
+static int swconfig_hwsim_get_port_status(struct switch_dev *dev,
+					 const struct switch_attr *attr,
+					 struct switch_val *val)
+{
+	struct swconfig_hwsim_state *state = get_state(dev);
+	struct swconfig_hwsim_port_state *port_state;
+	int port = val->port_vlan;
+	char *buf = state->buf;
+	int len;
+
+	port_state = &state->ports[port];
+
+	if (!port_state->link)
+		len = snprintf(buf, sizeof(state->buf), "down");
+	else
+		len = snprintf(buf, sizeof(state->buf),
+				"up, %d Mbps, %s duplex",
+				port_state->speed,
+				port_state->duplex ? "full" : "half");
+
+	buf[len] = '\0';
+
+	val->value.s = buf;
+
+	return 0;
+}
+
+static int swconfig_hwsim_get_link(struct switch_dev *dev,
+				   const struct switch_attr *attr,
+				   struct switch_val *val)
+{
+	struct swconfig_hwsim_state *state = get_state(dev);
+	struct swconfig_hwsim_port_state *port_state;
+	int port = val->port_vlan;
+
+	port_state = &state->ports[port];
+
+	if (port_state->link)
+		val->value.i = port_state->speed;
+	else
+		val->value.i = 0;
+
+	return 0;
+}
+
+static int swconfig_hwsim_set_link(struct switch_dev *dev,
+				   const struct switch_attr *attr,
+				   struct switch_val *val)
+{
+	struct swconfig_hwsim_state *state = get_state(dev);
+	struct swconfig_hwsim_port_state *port_state;
+	int port = val->port_vlan;
+
+	/* Validate user input speed */
+	switch (val->value.i) {
+	case SWITCH_PORT_SPEED_UNKNOWN:
+	case SWITCH_PORT_SPEED_10:
+	case SWITCH_PORT_SPEED_100:
+	case SWITCH_PORT_SPEED_1000:
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	port_state = &state->ports[port];
+
+	if (val->value.i == SWITCH_PORT_SPEED_UNKNOWN)
+		port_state->link = 0;
+	else {
+		port_state->link = 1;
+		port_state->speed = val->value.i;
+	}
+
+	return 0;
+}
+
+enum swconfig_hwsim_port {
+	SWCONFIG_HWSIM_PORT_STATUS,
+	SWCONFIG_HWSIM_PORT_LINK,
+};
+
+static const struct switch_attr swconfig_hwsim_attr_port[] = {
+	[SWCONFIG_HWSIM_PORT_STATUS] = {
+		.id = SWCONFIG_HWSIM_PORT_STATUS,
+		.type = SWITCH_TYPE_STRING,
+		.description = "Returns the port status",
+		.name = "status",
+		.get = swconfig_hwsim_get_port_status,
+	},
+	[SWCONFIG_HWSIM_PORT_LINK] = {
+		.id = SWCONFIG_HWSIM_PORT_LINK,
+		.type = SWITCH_TYPE_INT,
+		.description = "Sets link speed",
+		.name = "link",
+		.get = swconfig_hwsim_get_link,
+		.set = swconfig_hwsim_set_link,
+	},
+};
+
+enum swconfig_hwsim_globals {
+	SWCONFIG_HWSIM_GET_NAME,
+};
+
+static const struct switch_attr swconfig_hwsim_attr_global[] = {
+	[SWCONFIG_HWSIM_GET_NAME] = {
+		.id = SWCONFIG_HWSIM_GET_NAME,
+		.type = SWITCH_TYPE_STRING,
+		.description = "Returns the name of the switch",
+		.name = "name",
+		.get = swconfig_hwsim_get_name,
+	},
+};
+
+static int swconfig_hwsim_apply_config(struct switch_dev *dev)
+{
+	return 0;
+}
+
+static int swconfig_hwsim_reset_switch(struct switch_dev *dev)
+{
+	struct swconfig_hwsim_state *state = get_state(dev);
+	unsigned int i;
+
+	for (i = 0; i < SWCONFIG_HWSIM_NUM_PORTS; i++) {
+		state->ports[i].speed = 1000;
+		state->ports[i].link = 1;
+		state->ports[i].duplex = 1;
+	}
+
+	return 0;
+}
+
+static const struct switch_dev_ops swconfig_hwsim_ops = {
+	.attr_global = {
+		.attr = swconfig_hwsim_attr_global,
+		.n_attr = ARRAY_SIZE(swconfig_hwsim_attr_global),
+	},
+
+	.attr_port = {
+		.attr = swconfig_hwsim_attr_port,
+		.n_attr = ARRAY_SIZE(swconfig_hwsim_attr_port),
+	},
+
+	.apply_config = swconfig_hwsim_apply_config,
+	.reset_switch = swconfig_hwsim_reset_switch,
+};
+
+static struct swconfig_hwsim_state swconfig_hwsim_state = {
+	.dev = {
+		.name = "Fake switch",
+		.ops = &swconfig_hwsim_ops,
+		.ports = SWCONFIG_HWSIM_NUM_PORTS,
+		.cpu_port = SWCONFIG_HWSIM_NUM_PORTS - 1,
+	},
+};
+
+int swconfig_hwsim_init(void)
+{
+	swconfig_hwsim_state.loopback = dev_get_by_name(&init_net, "lo");
+	if (!swconfig_hwsim_state.loopback)
+		return -ENODEV;
+
+
+	return register_switch(&swconfig_hwsim_state.dev,
+				swconfig_hwsim_state.loopback);
+}
+
+void swconfig_hwsim_exit(void)
+{
+	unregister_switch(&swconfig_hwsim_state.dev);
+	dev_put(swconfig_hwsim_state.loopback);
+}
+
+module_init(swconfig_hwsim_init);
+module_exit(swconfig_hwsim_exit);
+
+MODULE_AUTHOR("Florian Fainelli <f.fainelli@gmail.com>");
+MODULE_DESCRIPTION("Fake switch driver");
+MODULE_LICENSE("Dual BSD/GPL");
-- 
1.8.3.2
