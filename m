From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Tue, 22 Oct 2013 11:23:46 -0700
Message-ID: <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, nbd@openwrt.org,
	blogic@openwrt.org, jogo@openwrt.org, gary@mlbassoc.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2516 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392Ab3JVSYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 14:24:11 -0400
In-Reply-To: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an Ethernet Switch generic netlink configuration API
which allows for doing the required configuration of managed Ethernet
switches commonly found in Wireless/Cable/DSL routers in the market.

Since this API is based on the Generic Netlink infrastructure it is very
easy to extend a particular switch driver to support additional features
and to adapt it to specific switches.

So far the API includes support for:

- getting/setting a port VLAN id
- getting/setting VLAN port membership
- getting a port link status
- getting a port statistics counters
- resetting a switch device
- applying a configuration to a switch device

Unlike the Distributed Switch Architecture code, this API is much
smaller and does not interfere with the networking stack packet flow, but
rather focuses on the control path of managed switches.

A concrete example of a switch driver is included in subsequent patches
to illustrate how it can be used as well as the required user-space
controlling tools.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/swconfig.txt |  162 +++++
 MAINTAINERS                           |   10 +
 drivers/net/phy/Kconfig               |    6 +
 drivers/net/phy/Makefile              |    1 +
 drivers/net/phy/swconfig.c            | 1078 +++++++++++++++++++++++++++++++++
 include/linux/swconfig.h              |  180 ++++++
 include/uapi/linux/Kbuild             |    1 +
 include/uapi/linux/swconfig.h         |  103 ++++
 8 files changed, 1541 insertions(+)
 create mode 100644 Documentation/networking/swconfig.txt
 create mode 100644 drivers/net/phy/swconfig.c
 create mode 100644 include/linux/swconfig.h
 create mode 100644 include/uapi/linux/swconfig.h

diff --git a/Documentation/networking/swconfig.txt b/Documentation/networking/swconfig.txt
new file mode 100644
index 0000000..f560066
--- /dev/null
+++ b/Documentation/networking/swconfig.txt
@@ -0,0 +1,162 @@
+Generic Netlink Switch configuration API
+
+Introduction
+============
+
+The following documentation covers the Linux Ethernet switch configuration API
+which is based on the Generic Netlink infrastructure.
+
+Scope and rationale
+===================
+
+Most Ethernet switches found in small routers are managed switches which allow
+the following operations:
+
+- configure a port to belong to a particular set of VLANs either as tagged or
+  untagged
+- configure a particular port to advertise specific link/speed/duplex settings
+- collect statistics about the number of packets/bytes transferred/received
+- any other vendor specific feature: rate limiting, single/double tagging...
+
+Such switches can be connected to the controlling CPU using different hardware
+busses, but most commonly:
+
+- SPI/I2C/GPIO bitbanging
+- MDIO
+- Memory mapped into the CPU register address space
+
+As of today the usual way to configure such a switch was either to write a
+specific driver or to write an user-space application which would have to know
+about the hardware differences and figure out a way to access the switch
+registers (spidev, SIOCIGGMIIREG, mmap...) from user-space.
+
+This has multiple issues:
+
+- proliferation of ad-hoc solutions to configure a switch both open source and
+  proprietary
+
+- absence of common software reference for switches commonly found on the market
+  (Broadcom, Lantiq/Infineon/ADMTek, Marvell, Qualcomm/Atheros...) which implies
+  a duplication effort for each implementer
+
+- inability to leverage existing hardware representation mechanisms such as
+  Device Tree (spidev, i2c-dev.. do not belong in Device Tree and rely on
+  Linux-specific "forwarder" drivers) to describe a switch device
+
+The goal of the switch configuration API is to provide a common basis to build
+re-usable and extensible switch drivers with the following ideas in mind:
+
+- having a central point of configuration on top of which a reference user-space
+  implementation can be provided but also allow for other user-space
+  implementations to exist
+
+- ensure the Linux kernel is in control of the actual hardware access
+
+- be extensible enough to support per-switch features without making the generic
+  implementation too heavy weighted and without making user-space changes each
+  and every time a new feature is added
+
+Based on these design goals the Generic Netlink kernel/user-space communication
+mechanism was chosen because it allows for all design goals to be met.
+
+Distributed Switch Architecture vs. swconfig
+============================================
+
+The Marvell Distributed Switch Architecture drivers is an existing solution
+which is a heavy switch driver infrastructure, is Marvell centric, only
+supports MDIO connected switches, mangles an Ethernet driver transmit/receive
+paths and does not offer a central control path for the user.
+
+swconfig is vendor agnostic, does not mangle the transmit/receive path
+of an Ethernet driver and is focused on the control path of the switch rather
+that the data path. It is based on Generic Netlink to allow for each switch
+driver to easily extend the swconfig API without causing major core parts rework
+each and every time someone has a specific feature to implement and offers a
+central configuration point with a well-defined API.
+
+Switch configuration API
+========================
+
+The main data structure of the switch configuration API is a "struct switch_dev"
+which contains the following members:
+
+- a set of common operations to all switches (struct switch_dev_ops)
+- a network device pointer it is physically attached to
+- a number of physical switch ports (including CPU port)
+- a set of configured vlans
+- a CPU specific port index
+
+A particular switch device is registered/unregistered using the following pair
+of functions:
+
+register_switch(struct switch_dev *sw_dev, struct net_device *dev);
+unregister_switch(struct switch_dev);
+
+A given switch driver can be backed by any kind of underlying bus driver (i2c
+client, GPIO driver, MMIO driver, directly into the Ethernet MAC driver...).
+
+The set of common operations to all switches is represented by the "struct
+switch_dev_ops" function pointers, these common operations are defined as such:
+
+- get the port list of a VLAN identifier
+- set the port list of a VLAN identifier
+- get the primary VLAN identifier of a port
+- set the primary VLAN identifier of a port
+- apply the changed configuration to the switch
+- reset the switch
+- get a port link status
+- get a port statistics counters
+
+The switch_dev_ops structure also contains an extensible way of representing and
+querying switch specific features, 3 different types of attributes are
+available:
+
+- global attributes: attributes global to a switch (name, identifier, number of
+  ports)
+- port attributes: per-port specific attributes (MIB counters, enabling port
+  mirroring...)
+- vlan attributes: per-VLAN specific attributes (VLAN id, specific VLAN
+  information)
+
+Each of these 3 categories must be represented using an array of "struct
+switch_attr" attributes. This structure must be filed with:
+
+- an unique name for the operation
+- a description for the operation
+- a setter operation
+- a getter operation
+- a data type (string, integer, port)
+- eventual min/max limits to validate user input data
+
+The "struct switch_attr" directly maps to a Generic Netlink type of command and
+will be automatically discovered by the "swconfig" user-space utility without
+requiring user-space changes.
+
+User-space reference tool
+=========================
+
+A reference user-space implementation is provided in tools/swconfig in order to
+directly configure and use a particular switch driver. This reference
+implementation is linking against libnl-1 for the moment.
+
+To build it:
+
+make -C tools/swconfig
+
+To list the available switches:
+
+./tools/swconfig list
+
+And to show a particular switch configuration for instance:
+
+./tools/swconfig dev eth0 show
+
+Fake (simulation) switch driver
+===============================
+
+A fake switch driver called swconfig-hwsim is provided in order to allow for
+easy testing of API changes and to perform regression testing. This driver will
+automatically map to the loopback device and will create a fake switch of up to
+8 Gigabit ports. Each of these ports can be configured with separate
+speed/duplex/link settings. This driver is gated with the CONFIG_SWCONFIG_HWSIM
+configuration symbol.
diff --git a/MAINTAINERS b/MAINTAINERS
index f169259..3a54262 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8117,6 +8117,16 @@ F:	lib/swiotlb.c
 F:	arch/*/kernel/pci-swiotlb.c
 F:	include/linux/swiotlb.h
 
+SWITCH CONFIGURATION API
+M:	Florian Fainelli <f.fainelli@gmail.com>
+L:	openwrt-devel@lists.openwrt.org
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/phy/swconfig*.c
+F:	include/uapi/linux/switch.h
+F:	include/linux/switch.h
+F:	Documentation/networking/swconfig.txt
+
 SYNOPSYS ARC ARCHITECTURE
 M:	Vineet Gupta <vgupta@synopsys.com>
 S:	Supported
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 342561a..9b3e117 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -12,6 +12,12 @@ menuconfig PHYLIB
 
 if PHYLIB
 
+config SWCONFIG
+	tristate "Switch configuration API"
+	---help---
+	  Switch configuration API using netlink. This allows
+	  you to configure the VLAN features of certain switches.
+
 comment "MII PHY device drivers"
 
 config AT803X_PHY
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 23a2ab2..268c7de 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -3,6 +3,7 @@
 libphy-objs			:= phy.o phy_device.o mdio_bus.o
 
 obj-$(CONFIG_PHYLIB)		+= libphy.o
+obj-$(CONFIG_SWCONFIG)		+= swconfig.o
 obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
 obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_CICADA_PHY)	+= cicada.o
diff --git a/drivers/net/phy/swconfig.c b/drivers/net/phy/swconfig.c
new file mode 100644
index 0000000..9997c35
--- /dev/null
+++ b/drivers/net/phy/swconfig.c
@@ -0,0 +1,1078 @@
+/*
+ * Switch configuration API
+ *
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
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
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/if.h>
+#include <linux/if_ether.h>
+#include <linux/capability.h>
+#include <linux/skbuff.h>
+#include <linux/swconfig.h>
+
+#define SWCONFIG_DEVNAME	"switch%d"
+
+MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
+MODULE_LICENSE("GPL");
+
+static int swdev_id;
+static struct list_head swdevs;
+static DEFINE_SPINLOCK(swdevs_lock);
+struct swconfig_callback;
+
+struct swconfig_callback {
+	struct sk_buff *msg;
+	struct genlmsghdr *hdr;
+	struct genl_info *info;
+	int cmd;
+
+	/* callback for filling in the message data */
+	int (*fill)(struct swconfig_callback *cb, void *arg);
+
+	/* callback for closing the message before sending it */
+	int (*close)(struct swconfig_callback *cb, void *arg);
+
+	struct nlattr *nest[4];
+	int args[4];
+};
+
+/* defaults */
+
+static int
+swconfig_get_vlan_ports(struct switch_dev *dev,
+			const struct switch_attr *attr, struct switch_val *val)
+{
+	int ret;
+	if (val->port_vlan >= dev->vlans)
+		return -EINVAL;
+
+	if (!dev->ops->get_vlan_ports)
+		return -EOPNOTSUPP;
+
+	ret = dev->ops->get_vlan_ports(dev, val);
+	return ret;
+}
+
+static int
+swconfig_set_vlan_ports(struct switch_dev *dev,
+			const struct switch_attr *attr, struct switch_val *val)
+{
+	struct switch_port *ports = val->value.ports;
+	const struct switch_dev_ops *ops = dev->ops;
+	int i;
+
+	if (val->port_vlan >= dev->vlans)
+		return -EINVAL;
+
+	/* validate ports */
+	if (val->len > dev->ports)
+		return -EINVAL;
+
+	if (!ops->set_vlan_ports)
+		return -EOPNOTSUPP;
+
+	for (i = 0; i < val->len; i++) {
+		if (ports[i].id >= dev->ports)
+			return -EINVAL;
+
+		if (ops->set_port_pvid &&
+		    !(ports[i].flags & (1 << SWITCH_PORT_FLAG_TAGGED)))
+			ops->set_port_pvid(dev, ports[i].id, val->port_vlan);
+	}
+
+	return ops->set_vlan_ports(dev, val);
+}
+
+static int
+swconfig_set_pvid(struct switch_dev *dev,
+			const struct switch_attr *attr, struct switch_val *val)
+{
+	if (val->port_vlan >= dev->ports)
+		return -EINVAL;
+
+	if (!dev->ops->set_port_pvid)
+		return -EOPNOTSUPP;
+
+	return dev->ops->set_port_pvid(dev, val->port_vlan, val->value.i);
+}
+
+static int
+swconfig_get_pvid(struct switch_dev *dev,
+			const struct switch_attr *attr, struct switch_val *val)
+{
+	if (val->port_vlan >= dev->ports)
+		return -EINVAL;
+
+	if (!dev->ops->get_port_pvid)
+		return -EOPNOTSUPP;
+
+	return dev->ops->get_port_pvid(dev, val->port_vlan, &val->value.i);
+}
+
+static const char *
+swconfig_speed_str(enum switch_port_speed speed)
+{
+	switch (speed) {
+	case SWITCH_PORT_SPEED_10:
+		return "10baseT";
+	case SWITCH_PORT_SPEED_100:
+		return "100baseT";
+	case SWITCH_PORT_SPEED_1000:
+		return "1000baseT";
+	default:
+		break;
+	}
+
+	return "unknown";
+}
+
+static int
+swconfig_get_link(struct switch_dev *dev,
+			const struct switch_attr *attr, struct switch_val *val)
+{
+	struct switch_port_link link;
+	int len;
+	int ret;
+
+	if (val->port_vlan >= dev->ports)
+		return -EINVAL;
+
+	if (!dev->ops->get_port_link)
+		return -EOPNOTSUPP;
+
+	memset(&link, 0, sizeof(link));
+	ret = dev->ops->get_port_link(dev, val->port_vlan, &link);
+	if (ret)
+		return ret;
+
+	memset(dev->buf, 0, sizeof(dev->buf));
+
+	if (link.link)
+		len = snprintf(dev->buf, sizeof(dev->buf),
+			       "port:%d link:up speed:%s %s-duplex %s%s%s",
+			       val->port_vlan,
+			       swconfig_speed_str(link.speed),
+			       link.duplex ? "full" : "half",
+			       link.tx_flow ? "txflow " : "",
+			       link.rx_flow ?	"rxflow " : "",
+			       link.aneg ? "auto" : "");
+	else
+		len = snprintf(dev->buf, sizeof(dev->buf), "port:%d link:down",
+			       val->port_vlan);
+
+	val->value.s = dev->buf;
+	val->len = len;
+
+	return 0;
+}
+
+static int
+swconfig_apply_config(struct switch_dev *dev,
+			const struct switch_attr *attr, struct switch_val *val)
+{
+	/* don't complain if not supported by the switch driver */
+	if (!dev->ops->apply_config)
+		return 0;
+
+	return dev->ops->apply_config(dev);
+}
+
+static int
+swconfig_reset_switch(struct switch_dev *dev,
+			const struct switch_attr *attr, struct switch_val *val)
+{
+	/* don't complain if not supported by the switch driver */
+	if (!dev->ops->reset_switch)
+		return 0;
+
+	return dev->ops->reset_switch(dev);
+}
+
+enum global_defaults {
+	GLOBAL_APPLY,
+	GLOBAL_RESET,
+};
+
+enum vlan_defaults {
+	VLAN_PORTS,
+};
+
+enum port_defaults {
+	PORT_PVID,
+	PORT_LINK,
+};
+
+static struct switch_attr default_global[] = {
+	[GLOBAL_APPLY] = {
+		.type = SWITCH_TYPE_NOVAL,
+		.name = "apply",
+		.description = "Activate changes in the hardware",
+		.set = swconfig_apply_config,
+	},
+	[GLOBAL_RESET] = {
+		.type = SWITCH_TYPE_NOVAL,
+		.name = "reset",
+		.description = "Reset the switch",
+		.set = swconfig_reset_switch,
+	}
+};
+
+static struct switch_attr default_port[] = {
+	[PORT_PVID] = {
+		.type = SWITCH_TYPE_INT,
+		.name = "pvid",
+		.description = "Primary VLAN ID",
+		.set = swconfig_set_pvid,
+		.get = swconfig_get_pvid,
+	},
+	[PORT_LINK] = {
+		.type = SWITCH_TYPE_STRING,
+		.name = "link",
+		.description = "Get port link information",
+		.set = NULL,
+		.get = swconfig_get_link,
+	}
+};
+
+static struct switch_attr default_vlan[] = {
+	[VLAN_PORTS] = {
+		.type = SWITCH_TYPE_PORTS,
+		.name = "ports",
+		.description = "VLAN port mapping",
+		.set = swconfig_set_vlan_ports,
+		.get = swconfig_get_vlan_ports,
+	},
+};
+
+static const struct switch_attr *
+swconfig_find_attr_by_name(const struct switch_attrlist *alist,
+				const char *name)
+{
+	int i;
+
+	for (i = 0; i < alist->n_attr; i++)
+		if (strcmp(name, alist->attr[i].name) == 0)
+			return &alist->attr[i];
+
+	return NULL;
+}
+
+static void swconfig_defaults_init(struct switch_dev *dev)
+{
+	const struct switch_dev_ops *ops = dev->ops;
+
+	dev->def_global = 0;
+	dev->def_vlan = 0;
+	dev->def_port = 0;
+
+	if (ops->get_vlan_ports || ops->set_vlan_ports)
+		set_bit(VLAN_PORTS, &dev->def_vlan);
+
+	if (ops->get_port_pvid || ops->set_port_pvid)
+		set_bit(PORT_PVID, &dev->def_port);
+
+	if (ops->get_port_link &&
+	    !swconfig_find_attr_by_name(&ops->attr_port, "link"))
+		set_bit(PORT_LINK, &dev->def_port);
+
+	/* always present, can be no-op */
+	set_bit(GLOBAL_APPLY, &dev->def_global);
+	set_bit(GLOBAL_RESET, &dev->def_global);
+}
+
+
+static struct genl_family switch_fam = {
+	.id = GENL_ID_GENERATE,
+	.name = "switch",
+	.hdrsize = 0,
+	.version = 1,
+	.maxattr = SWITCH_ATTR_MAX,
+};
+
+static const struct nla_policy switch_policy[SWITCH_ATTR_MAX+1] = {
+	[SWITCH_ATTR_ID] = { .type = NLA_U32 },
+	[SWITCH_ATTR_OP_ID] = { .type = NLA_U32 },
+	[SWITCH_ATTR_OP_PORT] = { .type = NLA_U32 },
+	[SWITCH_ATTR_OP_VLAN] = { .type = NLA_U32 },
+	[SWITCH_ATTR_OP_VALUE_INT] = { .type = NLA_U32 },
+	[SWITCH_ATTR_OP_VALUE_STR] = { .type = NLA_NUL_STRING },
+	[SWITCH_ATTR_OP_VALUE_PORTS] = { .type = NLA_NESTED },
+	[SWITCH_ATTR_TYPE] = { .type = NLA_U32 },
+};
+
+static const struct nla_policy port_policy[SWITCH_PORT_ATTR_MAX+1] = {
+	[SWITCH_PORT_ID] = { .type = NLA_U32 },
+	[SWITCH_PORT_FLAG_TAGGED] = { .type = NLA_FLAG },
+};
+
+static inline void
+swconfig_lock(void)
+{
+	spin_lock(&swdevs_lock);
+}
+
+static inline void
+swconfig_unlock(void)
+{
+	spin_unlock(&swdevs_lock);
+}
+
+static struct switch_dev *
+swconfig_get_dev(struct genl_info *info)
+{
+	struct switch_dev *dev = NULL;
+	struct switch_dev *p;
+	int id;
+
+	if (!info->attrs[SWITCH_ATTR_ID])
+		goto done;
+
+	id = nla_get_u32(info->attrs[SWITCH_ATTR_ID]);
+	swconfig_lock();
+	list_for_each_entry(p, &swdevs, dev_list) {
+		if (id != p->id)
+			continue;
+
+		dev = p;
+		break;
+	}
+	if (dev)
+		mutex_lock(&dev->sw_mutex);
+	else
+		pr_debug("device %d not found\n", id);
+	swconfig_unlock();
+done:
+	return dev;
+}
+
+static inline void
+swconfig_put_dev(struct switch_dev *dev)
+{
+	mutex_unlock(&dev->sw_mutex);
+}
+
+static int
+swconfig_dump_attr(struct swconfig_callback *cb, void *arg)
+{
+	struct switch_attr *op = arg;
+	struct genl_info *info = cb->info;
+	struct sk_buff *msg = cb->msg;
+	int id = cb->args[0];
+	void *hdr;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq, &switch_fam,
+			NLM_F_MULTI, SWITCH_CMD_NEW_ATTR);
+	if (IS_ERR(hdr))
+		return -1;
+
+	if (nla_put_u32(msg, SWITCH_ATTR_OP_ID, id))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, SWITCH_ATTR_OP_TYPE, op->type))
+		goto nla_put_failure;
+	if (nla_put_string(msg, SWITCH_ATTR_OP_NAME, op->name))
+		goto nla_put_failure;
+	if (op->description)
+		if (nla_put_string(msg, SWITCH_ATTR_OP_DESCRIPTION,
+			op->description))
+			goto nla_put_failure;
+
+	return genlmsg_end(msg, hdr);
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+/* spread multipart messages across multiple message buffers */
+static int
+swconfig_send_multipart(struct swconfig_callback *cb, void *arg)
+{
+	struct genl_info *info = cb->info;
+	int restart = 0;
+	int err;
+
+	do {
+		if (!cb->msg) {
+			cb->msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+			if (cb->msg == NULL)
+				goto error;
+		}
+
+		if (!(cb->fill(cb, arg) < 0))
+			break;
+
+		/* fill failed, check if this was already the second attempt */
+		if (restart)
+			goto error;
+
+		/* try again in a new message, send the current one */
+		restart = 1;
+		if (cb->close) {
+			if (cb->close(cb, arg) < 0)
+				goto error;
+		}
+		err = genlmsg_reply(cb->msg, info);
+		cb->msg = NULL;
+		if (err < 0)
+			goto error;
+
+	} while (restart);
+
+	return 0;
+
+error:
+	if (cb->msg)
+		nlmsg_free(cb->msg);
+	return -1;
+}
+
+static int
+swconfig_list_attrs(struct sk_buff *skb, struct genl_info *info)
+{
+	struct genlmsghdr *hdr = nlmsg_data(info->nlhdr);
+	const struct switch_attrlist *alist;
+	struct switch_dev *dev;
+	struct swconfig_callback cb;
+	int err = -EINVAL;
+	int i;
+
+	/* defaults */
+	struct switch_attr *def_list;
+	unsigned long *def_active;
+	int n_def;
+
+	dev = swconfig_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	switch (hdr->cmd) {
+	case SWITCH_CMD_LIST_GLOBAL:
+		alist = &dev->ops->attr_global;
+		def_list = default_global;
+		def_active = &dev->def_global;
+		n_def = ARRAY_SIZE(default_global);
+		break;
+	case SWITCH_CMD_LIST_VLAN:
+		alist = &dev->ops->attr_vlan;
+		def_list = default_vlan;
+		def_active = &dev->def_vlan;
+		n_def = ARRAY_SIZE(default_vlan);
+		break;
+	case SWITCH_CMD_LIST_PORT:
+		alist = &dev->ops->attr_port;
+		def_list = default_port;
+		def_active = &dev->def_port;
+		n_def = ARRAY_SIZE(default_port);
+		break;
+	default:
+		WARN_ON(1);
+		goto out;
+	}
+
+	memset(&cb, 0, sizeof(cb));
+	cb.info = info;
+	cb.fill = swconfig_dump_attr;
+	for (i = 0; i < alist->n_attr; i++) {
+		if (alist->attr[i].disabled)
+			continue;
+		cb.args[0] = i;
+		err = swconfig_send_multipart(&cb, (void *) &alist->attr[i]);
+		if (err < 0)
+			goto error;
+	}
+
+	/* defaults */
+	for (i = 0; i < n_def; i++) {
+		if (!test_bit(i, def_active))
+			continue;
+		cb.args[0] = SWITCH_ATTR_DEFAULTS_OFFSET + i;
+		err = swconfig_send_multipart(&cb, (void *) &def_list[i]);
+		if (err < 0)
+			goto error;
+	}
+	swconfig_put_dev(dev);
+
+	if (!cb.msg)
+		return 0;
+
+	return genlmsg_reply(cb.msg, info);
+
+error:
+	if (cb.msg)
+		nlmsg_free(cb.msg);
+out:
+	swconfig_put_dev(dev);
+	return err;
+}
+
+static const struct switch_attr *
+swconfig_lookup_attr(struct switch_dev *dev, struct genl_info *info,
+		struct switch_val *val)
+{
+	struct genlmsghdr *hdr = nlmsg_data(info->nlhdr);
+	const struct switch_attrlist *alist;
+	const struct switch_attr *attr = NULL;
+	int attr_id;
+
+	/* defaults */
+	struct switch_attr *def_list;
+	unsigned long *def_active;
+	int n_def;
+
+	if (!info->attrs[SWITCH_ATTR_OP_ID])
+		goto done;
+
+	switch (hdr->cmd) {
+	case SWITCH_CMD_SET_GLOBAL:
+	case SWITCH_CMD_GET_GLOBAL:
+		alist = &dev->ops->attr_global;
+		def_list = default_global;
+		def_active = &dev->def_global;
+		n_def = ARRAY_SIZE(default_global);
+		break;
+	case SWITCH_CMD_SET_VLAN:
+	case SWITCH_CMD_GET_VLAN:
+		alist = &dev->ops->attr_vlan;
+		def_list = default_vlan;
+		def_active = &dev->def_vlan;
+		n_def = ARRAY_SIZE(default_vlan);
+		if (!info->attrs[SWITCH_ATTR_OP_VLAN])
+			goto done;
+		val->port_vlan = nla_get_u32(info->attrs[SWITCH_ATTR_OP_VLAN]);
+		if (val->port_vlan >= dev->vlans)
+			goto done;
+		break;
+	case SWITCH_CMD_SET_PORT:
+	case SWITCH_CMD_GET_PORT:
+		alist = &dev->ops->attr_port;
+		def_list = default_port;
+		def_active = &dev->def_port;
+		n_def = ARRAY_SIZE(default_port);
+		if (!info->attrs[SWITCH_ATTR_OP_PORT])
+			goto done;
+		val->port_vlan = nla_get_u32(info->attrs[SWITCH_ATTR_OP_PORT]);
+		if (val->port_vlan >= dev->ports)
+			goto done;
+		break;
+	default:
+		WARN_ON(1);
+		goto done;
+	}
+
+	if (!alist)
+		goto done;
+
+	attr_id = nla_get_u32(info->attrs[SWITCH_ATTR_OP_ID]);
+	if (attr_id >= SWITCH_ATTR_DEFAULTS_OFFSET) {
+		attr_id -= SWITCH_ATTR_DEFAULTS_OFFSET;
+		if (attr_id >= n_def)
+			goto done;
+		if (!test_bit(attr_id, def_active))
+			goto done;
+		attr = &def_list[attr_id];
+	} else {
+		if (attr_id >= alist->n_attr)
+			goto done;
+		attr = &alist->attr[attr_id];
+	}
+
+	if (attr->disabled)
+		attr = NULL;
+
+done:
+	if (!attr)
+		pr_debug("attribute lookup failed\n");
+	val->attr = attr;
+	return attr;
+}
+
+static int
+swconfig_parse_ports(struct sk_buff *msg, struct nlattr *head,
+		struct switch_val *val, int max)
+{
+	struct nlattr *nla;
+	int rem;
+
+	val->len = 0;
+	nla_for_each_nested(nla, head, rem) {
+		struct nlattr *tb[SWITCH_PORT_ATTR_MAX+1];
+		struct switch_port *port = &val->value.ports[val->len];
+
+		if (val->len >= max)
+			return -EINVAL;
+
+		if (nla_parse_nested(tb, SWITCH_PORT_ATTR_MAX, nla,
+				port_policy))
+			return -EINVAL;
+
+		if (!tb[SWITCH_PORT_ID])
+			return -EINVAL;
+
+		port->id = nla_get_u32(tb[SWITCH_PORT_ID]);
+		if (tb[SWITCH_PORT_FLAG_TAGGED])
+			port->flags |= (1 << SWITCH_PORT_FLAG_TAGGED);
+		val->len++;
+	}
+
+	return 0;
+}
+
+static int
+swconfig_set_attr(struct sk_buff *skb, struct genl_info *info)
+{
+	const struct switch_attr *attr;
+	struct switch_dev *dev;
+	struct switch_val val;
+	int err = -EINVAL;
+
+	dev = swconfig_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	memset(&val, 0, sizeof(val));
+	attr = swconfig_lookup_attr(dev, info, &val);
+	if (!attr || !attr->set)
+		goto error;
+
+	val.attr = attr;
+	switch (attr->type) {
+	case SWITCH_TYPE_NOVAL:
+		break;
+	case SWITCH_TYPE_INT:
+		if (!info->attrs[SWITCH_ATTR_OP_VALUE_INT])
+			goto error;
+		val.value.i =
+			nla_get_u32(info->attrs[SWITCH_ATTR_OP_VALUE_INT]);
+		break;
+	case SWITCH_TYPE_STRING:
+		if (!info->attrs[SWITCH_ATTR_OP_VALUE_STR])
+			goto error;
+		val.value.s =
+			nla_data(info->attrs[SWITCH_ATTR_OP_VALUE_STR]);
+		break;
+	case SWITCH_TYPE_PORTS:
+		val.value.ports = dev->portbuf;
+		memset(dev->portbuf, 0,
+			sizeof(struct switch_port) * dev->ports);
+
+		/* TODO: implement multipart? */
+		if (info->attrs[SWITCH_ATTR_OP_VALUE_PORTS]) {
+			err = swconfig_parse_ports(skb,
+				info->attrs[SWITCH_ATTR_OP_VALUE_PORTS],
+				&val, dev->ports);
+			if (err < 0)
+				goto error;
+		} else {
+			val.len = 0;
+			err = 0;
+		}
+		break;
+	default:
+		goto error;
+	}
+
+	err = attr->set(dev, attr, &val);
+error:
+	swconfig_put_dev(dev);
+	return err;
+}
+
+static int
+swconfig_close_portlist(struct swconfig_callback *cb, void *arg)
+{
+	if (cb->nest[0])
+		nla_nest_end(cb->msg, cb->nest[0]);
+	return 0;
+}
+
+static int
+swconfig_send_port(struct swconfig_callback *cb, void *arg)
+{
+	const struct switch_port *port = arg;
+	struct nlattr *p = NULL;
+
+	if (!cb->nest[0]) {
+		cb->nest[0] = nla_nest_start(cb->msg, cb->cmd);
+		if (!cb->nest[0])
+			return -1;
+	}
+
+	p = nla_nest_start(cb->msg, SWITCH_ATTR_PORT);
+	if (!p)
+		goto error;
+
+	if (nla_put_u32(cb->msg, SWITCH_PORT_ID, port->id))
+		goto nla_put_failure;
+	if (port->flags & (1 << SWITCH_PORT_FLAG_TAGGED)) {
+		if (nla_put_flag(cb->msg, SWITCH_PORT_FLAG_TAGGED))
+			goto nla_put_failure;
+	}
+
+	nla_nest_end(cb->msg, p);
+	return 0;
+
+nla_put_failure:
+		nla_nest_cancel(cb->msg, p);
+error:
+	nla_nest_cancel(cb->msg, cb->nest[0]);
+	return -1;
+}
+
+static int
+swconfig_send_ports(struct sk_buff **msg, struct genl_info *info, int attr,
+		const struct switch_val *val)
+{
+	struct swconfig_callback cb;
+	int err = 0;
+	int i;
+
+	if (!val->value.ports)
+		return -EINVAL;
+
+	memset(&cb, 0, sizeof(cb));
+	cb.cmd = attr;
+	cb.msg = *msg;
+	cb.info = info;
+	cb.fill = swconfig_send_port;
+	cb.close = swconfig_close_portlist;
+
+	cb.nest[0] = nla_nest_start(cb.msg, cb.cmd);
+	for (i = 0; i < val->len; i++) {
+		err = swconfig_send_multipart(&cb, &val->value.ports[i]);
+		if (err)
+			goto done;
+	}
+	err = val->len;
+	swconfig_close_portlist(&cb, NULL);
+	*msg = cb.msg;
+
+done:
+	return err;
+}
+
+static int
+swconfig_get_attr(struct sk_buff *skb, struct genl_info *info)
+{
+	struct genlmsghdr *hdr = nlmsg_data(info->nlhdr);
+	const struct switch_attr *attr;
+	struct switch_dev *dev;
+	struct sk_buff *msg = NULL;
+	struct switch_val val;
+	int err = -EINVAL;
+	int cmd = hdr->cmd;
+
+	dev = swconfig_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	memset(&val, 0, sizeof(val));
+	attr = swconfig_lookup_attr(dev, info, &val);
+	if (!attr || !attr->get)
+		goto error;
+
+	if (attr->type == SWITCH_TYPE_PORTS) {
+		val.value.ports = dev->portbuf;
+		memset(dev->portbuf, 0,
+			sizeof(struct switch_port) * dev->ports);
+	}
+
+	err = attr->get(dev, attr, &val);
+	if (err)
+		goto error;
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg)
+		goto error;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq, &switch_fam,
+			0, cmd);
+	if (IS_ERR(hdr))
+		goto nla_put_failure;
+
+	switch (attr->type) {
+	case SWITCH_TYPE_INT:
+		if (nla_put_u32(msg, SWITCH_ATTR_OP_VALUE_INT, val.value.i))
+			goto nla_put_failure;
+		break;
+	case SWITCH_TYPE_STRING:
+		if (nla_put_string(msg, SWITCH_ATTR_OP_VALUE_STR, val.value.s))
+			goto nla_put_failure;
+		break;
+	case SWITCH_TYPE_PORTS:
+		err = swconfig_send_ports(&msg, info,
+				SWITCH_ATTR_OP_VALUE_PORTS, &val);
+		if (err < 0)
+			goto nla_put_failure;
+		break;
+	default:
+		pr_debug("invalid type in attribute\n");
+		err = -EINVAL;
+		goto error;
+	}
+	err = genlmsg_end(msg, hdr);
+	if (err < 0)
+		goto nla_put_failure;
+
+	swconfig_put_dev(dev);
+	return genlmsg_reply(msg, info);
+
+nla_put_failure:
+	if (msg)
+		nlmsg_free(msg);
+error:
+	swconfig_put_dev(dev);
+	if (!err)
+		err = -ENOMEM;
+	return err;
+}
+
+static int
+swconfig_send_switch(struct sk_buff *msg, u32 pid, u32 seq, int flags,
+		const struct switch_dev *dev)
+{
+	struct nlattr *p = NULL, *m = NULL;
+	void *hdr;
+	int i;
+
+	hdr = genlmsg_put(msg, pid, seq, &switch_fam, flags,
+			SWITCH_CMD_NEW_ATTR);
+	if (IS_ERR(hdr))
+		return -1;
+
+	if (nla_put_u32(msg, SWITCH_ATTR_ID, dev->id))
+		goto nla_put_failure;
+	if (nla_put_string(msg, SWITCH_ATTR_DEV_NAME, dev->devname))
+		goto nla_put_failure;
+	if (nla_put_string(msg, SWITCH_ATTR_ALIAS, dev->alias))
+		goto nla_put_failure;
+	if (nla_put_string(msg, SWITCH_ATTR_NAME, dev->name))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, SWITCH_ATTR_VLANS, dev->vlans))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, SWITCH_ATTR_PORTS, dev->ports))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, SWITCH_ATTR_CPU_PORT, dev->cpu_port))
+		goto nla_put_failure;
+
+	m = nla_nest_start(msg, SWITCH_ATTR_PORTMAP);
+	if (!m)
+		goto nla_put_failure;
+	for (i = 0; i < dev->ports; i++) {
+		p = nla_nest_start(msg, SWITCH_ATTR_PORTS);
+		if (!p)
+			continue;
+		if (dev->portmap[i].s) {
+			if (nla_put_string(msg, SWITCH_PORTMAP_SEGMENT,
+						dev->portmap[i].s))
+				goto nla_put_failure;
+			if (nla_put_u32(msg, SWITCH_PORTMAP_VIRT,
+						dev->portmap[i].virt))
+				goto nla_put_failure;
+		}
+		nla_nest_end(msg, p);
+	}
+	nla_nest_end(msg, m);
+	return genlmsg_end(msg, hdr);
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int swconfig_dump_switches(struct sk_buff *skb,
+		struct netlink_callback *cb)
+{
+	struct switch_dev *dev;
+	int start = cb->args[0];
+	int idx = 0;
+
+	swconfig_lock();
+	list_for_each_entry(dev, &swdevs, dev_list) {
+		if (++idx <= start)
+			continue;
+		if (swconfig_send_switch(skb, NETLINK_CB(cb->skb).portid,
+				cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				dev) < 0)
+			break;
+	}
+	swconfig_unlock();
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
+static int
+swconfig_done(struct netlink_callback *cb)
+{
+	return 0;
+}
+
+static struct genl_ops swconfig_ops[] = {
+	{
+		.cmd = SWITCH_CMD_LIST_GLOBAL,
+		.doit = swconfig_list_attrs,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_LIST_VLAN,
+		.doit = swconfig_list_attrs,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_LIST_PORT,
+		.doit = swconfig_list_attrs,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_GET_GLOBAL,
+		.doit = swconfig_get_attr,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_GET_VLAN,
+		.doit = swconfig_get_attr,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_GET_PORT,
+		.doit = swconfig_get_attr,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_SET_GLOBAL,
+		.doit = swconfig_set_attr,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_SET_VLAN,
+		.doit = swconfig_set_attr,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_SET_PORT,
+		.doit = swconfig_set_attr,
+		.policy = switch_policy,
+	},
+	{
+		.cmd = SWITCH_CMD_GET_SWITCH,
+		.dumpit = swconfig_dump_switches,
+		.policy = switch_policy,
+		.done = swconfig_done,
+	}
+};
+
+int
+register_switch(struct switch_dev *dev, struct net_device *netdev)
+{
+	struct switch_dev *sdev;
+	const int max_switches = 8 * sizeof(unsigned long);
+	unsigned long in_use = 0;
+	int i;
+
+	INIT_LIST_HEAD(&dev->dev_list);
+	if (netdev) {
+		dev->netdev = netdev;
+		if (!dev->alias)
+			dev->alias = netdev->name;
+	}
+	BUG_ON(!dev->alias);
+
+	if (dev->ports > 0) {
+		dev->portbuf = kzalloc(sizeof(struct switch_port) *
+				dev->ports, GFP_KERNEL);
+		if (!dev->portbuf)
+			return -ENOMEM;
+		dev->portmap = kzalloc(sizeof(struct switch_portmap) *
+				dev->ports, GFP_KERNEL);
+		if (!dev->portmap) {
+			kfree(dev->portbuf);
+			return -ENOMEM;
+		}
+	}
+	swconfig_defaults_init(dev);
+	mutex_init(&dev->sw_mutex);
+	swconfig_lock();
+	dev->id = ++swdev_id;
+
+	list_for_each_entry(sdev, &swdevs, dev_list) {
+		if (!sscanf(sdev->devname, SWCONFIG_DEVNAME, &i))
+			continue;
+		if (i < 0 || i > max_switches)
+			continue;
+
+		set_bit(i, &in_use);
+	}
+	i = find_first_zero_bit(&in_use, max_switches);
+
+	if (i == max_switches) {
+		swconfig_unlock();
+		return -ENFILE;
+	}
+
+	/* fill device name */
+	snprintf(dev->devname, IFNAMSIZ, SWCONFIG_DEVNAME, i);
+
+	list_add(&dev->dev_list, &swdevs);
+	swconfig_unlock();
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(register_switch);
+
+void
+unregister_switch(struct switch_dev *dev)
+{
+	kfree(dev->portbuf);
+	mutex_lock(&dev->sw_mutex);
+	swconfig_lock();
+	list_del(&dev->dev_list);
+	swconfig_unlock();
+	mutex_unlock(&dev->sw_mutex);
+}
+EXPORT_SYMBOL_GPL(unregister_switch);
+
+
+static int __init
+swconfig_init(void)
+{
+	int i, err;
+
+	INIT_LIST_HEAD(&swdevs);
+	err = genl_register_family(&switch_fam);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(swconfig_ops); i++) {
+		err = genl_register_ops(&switch_fam, &swconfig_ops[i]);
+		if (err)
+			goto unregister;
+	}
+
+	return 0;
+
+unregister:
+	genl_unregister_family(&switch_fam);
+	return err;
+}
+
+static void __exit
+swconfig_exit(void)
+{
+	genl_unregister_family(&switch_fam);
+}
+
+module_init(swconfig_init);
+module_exit(swconfig_exit);
+
diff --git a/include/linux/swconfig.h b/include/linux/swconfig.h
new file mode 100644
index 0000000..fd96eec
--- /dev/null
+++ b/include/linux/swconfig.h
@@ -0,0 +1,180 @@
+/*
+ * Switch configuration API
+ *
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
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
+#ifndef _LINUX_SWITCH_H
+#define _LINUX_SWITCH_H
+
+#include <net/genetlink.h>
+#include <uapi/linux/swconfig.h>
+
+struct switch_dev;
+struct switch_op;
+struct switch_val;
+struct switch_attr;
+struct switch_attrlist;
+struct switch_led_trigger;
+
+int register_switch(struct switch_dev *dev, struct net_device *netdev);
+void unregister_switch(struct switch_dev *dev);
+
+/**
+ * struct switch_attrlist - attribute list
+ *
+ * @n_attr: number of attributes
+ * @attr: pointer to the attributes array
+ */
+struct switch_attrlist {
+	int n_attr;
+	const struct switch_attr *attr;
+};
+
+enum switch_port_speed {
+	SWITCH_PORT_SPEED_UNKNOWN = 0,
+	SWITCH_PORT_SPEED_10 = 10,
+	SWITCH_PORT_SPEED_100 = 100,
+	SWITCH_PORT_SPEED_1000 = 1000,
+};
+
+struct switch_port_link {
+	bool link;
+	bool duplex;
+	bool aneg;
+	bool tx_flow;
+	bool rx_flow;
+	enum switch_port_speed speed;
+};
+
+struct switch_port_stats {
+	unsigned long tx_bytes;
+	unsigned long rx_bytes;
+};
+
+/**
+ * struct switch_dev_ops - switch driver operations
+ *
+ * @attr_global: global switch attribute list
+ * @attr_port: port attribute list
+ * @attr_vlan: vlan attribute list
+ *
+ * Callbacks:
+ *
+ * @get_vlan_ports: read the port list of a VLAN
+ * @set_vlan_ports: set the port list of a VLAN
+ *
+ * @get_port_pvid: get the primary VLAN ID of a port
+ * @set_port_pvid: set the primary VLAN ID of a port
+ *
+ * @apply_config: apply all changed settings to the switch
+ * @reset_switch: resetting the switch
+ *
+ * @get_port_link: read the port link status
+ * @get_port_stats: read the port statistics counters
+ */
+struct switch_dev_ops {
+	struct switch_attrlist attr_global, attr_port, attr_vlan;
+
+	int (*get_vlan_ports)(struct switch_dev *dev, struct switch_val *val);
+	int (*set_vlan_ports)(struct switch_dev *dev, struct switch_val *val);
+
+	int (*get_port_pvid)(struct switch_dev *dev, int port, int *val);
+	int (*set_port_pvid)(struct switch_dev *dev, int port, int val);
+
+	int (*apply_config)(struct switch_dev *dev);
+	int (*reset_switch)(struct switch_dev *dev);
+
+	int (*get_port_link)(struct switch_dev *dev, int port,
+			     struct switch_port_link *link);
+	int (*get_port_stats)(struct switch_dev *dev, int port,
+			      struct switch_port_stats *stats);
+};
+
+/**
+ * struct switch_dev - switch device
+ *
+ * @ops: switch driver operations pointer
+ * @devname: switch device name (automatically filled)
+ * @name: switch driver name returned to user-space
+ * @alias: alias name for the switch (instead of ethX) returned to user-space
+ * @netdev: network device pointer if alias is not used
+ *
+ * @ports: number of physical switch ports
+ * @vlans: number of supported VLANs
+ * @cpu_port: identifier for the CPU port
+ */
+struct switch_dev {
+	const struct switch_dev_ops *ops;
+	/* will be automatically filled */
+	char devname[IFNAMSIZ];
+
+	const char *name;
+	/* NB: either alias or netdev must be set */
+	const char *alias;
+	struct net_device *netdev;
+
+	int ports;
+	int vlans;
+	int cpu_port;
+
+	/* the following fields are internal for swconfig */
+	int id;
+	struct list_head dev_list;
+	unsigned long def_global, def_port, def_vlan;
+
+	struct mutex sw_mutex;
+	struct switch_port *portbuf;
+	struct switch_portmap *portmap;
+
+	char buf[128];
+};
+
+struct switch_port {
+	u32 id;
+	u32 flags;
+};
+
+struct switch_portmap {
+	u32 virt;
+	const char *s;
+};
+
+struct switch_val {
+	const struct switch_attr *attr;
+	int port_vlan;
+	int len;
+	union {
+		const char *s;
+		u32 i;
+		struct switch_port *ports;
+	} value;
+};
+
+struct switch_attr {
+	int disabled;
+	int type;
+	const char *name;
+	const char *description;
+
+	int (*set)(struct switch_dev *dev, const struct switch_attr *attr,
+			struct switch_val *val);
+	int (*get)(struct switch_dev *dev, const struct switch_attr *attr,
+			struct switch_val *val);
+
+	/* for driver internal use */
+	int id;
+	int ofs;
+	int max;
+};
+
+#endif /* _LINUX_SWITCH_H */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 115add2..0a995be 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -363,6 +363,7 @@ header-y += stddef.h
 header-y += string.h
 header-y += suspend_ioctls.h
 header-y += swab.h
+header-y += swconfig.h
 header-y += synclink.h
 header-y += sysctl.h
 header-y += sysinfo.h
diff --git a/include/uapi/linux/swconfig.h b/include/uapi/linux/swconfig.h
new file mode 100644
index 0000000..17cf178
--- /dev/null
+++ b/include/uapi/linux/swconfig.h
@@ -0,0 +1,103 @@
+/*
+ * Switch configuration API
+ *
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
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
+#ifndef _UAPI_LINUX_SWITCH_H
+#define _UAPI_LINUX_SWITCH_H
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/netlink.h>
+#include <linux/genetlink.h>
+#ifndef __KERNEL__
+#include <netlink/netlink.h>
+#include <netlink/genl/genl.h>
+#include <netlink/genl/ctrl.h>
+#endif
+
+/* main attributes */
+enum {
+	SWITCH_ATTR_UNSPEC,
+	/* global */
+	SWITCH_ATTR_TYPE,
+	/* device */
+	SWITCH_ATTR_ID,
+	SWITCH_ATTR_DEV_NAME,
+	SWITCH_ATTR_ALIAS,
+	SWITCH_ATTR_NAME,
+	SWITCH_ATTR_VLANS,
+	SWITCH_ATTR_PORTS,
+	SWITCH_ATTR_PORTMAP,
+	SWITCH_ATTR_CPU_PORT,
+	/* attributes */
+	SWITCH_ATTR_OP_ID,
+	SWITCH_ATTR_OP_TYPE,
+	SWITCH_ATTR_OP_NAME,
+	SWITCH_ATTR_OP_PORT,
+	SWITCH_ATTR_OP_VLAN,
+	SWITCH_ATTR_OP_VALUE_INT,
+	SWITCH_ATTR_OP_VALUE_STR,
+	SWITCH_ATTR_OP_VALUE_PORTS,
+	SWITCH_ATTR_OP_DESCRIPTION,
+	/* port lists */
+	SWITCH_ATTR_PORT,
+	SWITCH_ATTR_MAX
+};
+
+enum {
+	/* port map */
+	SWITCH_PORTMAP_PORTS,
+	SWITCH_PORTMAP_SEGMENT,
+	SWITCH_PORTMAP_VIRT,
+	SWITCH_PORTMAP_MAX
+};
+
+/* commands */
+enum {
+	SWITCH_CMD_UNSPEC,
+	SWITCH_CMD_GET_SWITCH,
+	SWITCH_CMD_NEW_ATTR,
+	SWITCH_CMD_LIST_GLOBAL,
+	SWITCH_CMD_GET_GLOBAL,
+	SWITCH_CMD_SET_GLOBAL,
+	SWITCH_CMD_LIST_PORT,
+	SWITCH_CMD_GET_PORT,
+	SWITCH_CMD_SET_PORT,
+	SWITCH_CMD_LIST_VLAN,
+	SWITCH_CMD_GET_VLAN,
+	SWITCH_CMD_SET_VLAN
+};
+
+/* data types */
+enum switch_val_type {
+	SWITCH_TYPE_UNSPEC,
+	SWITCH_TYPE_INT,
+	SWITCH_TYPE_STRING,
+	SWITCH_TYPE_PORTS,
+	SWITCH_TYPE_NOVAL,
+};
+
+/* port nested attributes */
+enum {
+	SWITCH_PORT_UNSPEC,
+	SWITCH_PORT_ID,
+	SWITCH_PORT_FLAG_TAGGED,
+	SWITCH_PORT_ATTR_MAX
+};
+
+#define SWITCH_ATTR_DEFAULTS_OFFSET	0x1000
+
+
+#endif /* _UAPI_LINUX_SWITCH_H */
-- 
1.8.3.2
