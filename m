From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Tue, 27 May 2008 07:13:46 -0700
Message-ID: <20080527141346.12851.2280.stgit@localhost.localdomain>
References: <20080527141339.12851.98781.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46957 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758271AbYE0VNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 17:13:36 -0400
In-Reply-To: <20080527141339.12851.98781.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the netlink interface definition for Data Center Bridging.
This technology uses 802.1Qaz and 801.1Qbb for extending ethernet to
converge different traffic types on a single link.  E.g. Fibre Channel
over Ethernet and regular LAN traffic.  The goal is to use priority flow
control to pause individual flows at the MAC/network level, without
impacting other network flows.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/dcbnl.h     |  241 +++++++++++++++
 include/linux/netdevice.h |    8 
 net/Kconfig               |    1 
 net/Makefile              |    3 
 net/dcb/Kconfig           |   12 +
 net/dcb/Makefile          |    1 
 net/dcb/dcbnl.c           |  722 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 988 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
new file mode 100644
index 0000000..db50f6c
--- /dev/null
+++ b/include/linux/dcbnl.h
@@ -0,0 +1,241 @@
+#ifndef __LINUX_DCBNL_H__
+#define __LINUX_DCBNL_H__
+/*
+ * Data Center Bridging (DCB) netlink header
+ *
+ * Copyright 2008, Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
+ */
+
+#define DCB_PROTO_VERSION 1
+
+/**
+ * enum dcbnl_commands - supported DCB commands
+ *
+ * @DCB_CMD_UNDEFINED: unspecified command to catch errors
+ * @DCB_CMD_GSTATE: request the state of DCB in the device
+ * @DCB_CMD_SSTATE: set the state of DCB in the device
+ * @DCB_CMD_PGTX_GCFG: request the priority group configuration for Tx
+ * @DCB_CMD_PGTX_SCFG: set the priority group configuration for Tx
+ * @DCB_CMD_PGRX_GCFG: request the priority group configuration for Rx
+ * @DCB_CMD_PGRX_SCFG: set the priority group configuration for Rx
+ * @DCB_CMD_PFC_GCFG: request the priority flow control configuration
+ * @DCB_CMD_PFC_SCFG: set the priority flow control configuration
+ * @DCB_CMD_SET_ALL: apply all changes to the underlying device
+ * @DCB_CMD_GPERM_HWADDR: get the permanent MAC address of the underlying
+ *                        device.  Only useful when using bonding.
+ */
+enum dcbnl_commands {
+	DCB_CMD_UNDEFINED,
+
+	DCB_CMD_GSTATE,
+	DCB_CMD_SSTATE,
+
+	DCB_CMD_PGTX_GCFG,
+	DCB_CMD_PGTX_SCFG,
+	DCB_CMD_PGRX_GCFG,
+	DCB_CMD_PGRX_SCFG,
+
+	DCB_CMD_PFC_GCFG,
+	DCB_CMD_PFC_SCFG,
+
+	DCB_CMD_SET_ALL,
+	DCB_CMD_GPERM_HWADDR,
+
+	__DCB_CMD_ENUM_MAX,
+	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
+};
+
+
+/**
+ * enum dcbnl_attrs - DCB top-level netlink attributes
+ *
+ * @DCB_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_ATTR_IFNAME: interface name of the underlying device (NLA_STRING)
+ * @DCB_ATTR_STATE: state of the DCB state machine in the device (NLA_U8)
+ * @DCB_ATTR_PFC_CFG: priority flow control configuration (NLA_NESTED)
+ * @DCB_ATTR_PG_CFG: priority group configuration (NLA_NESTED)
+ * @DCB_ATTR_SET_ALL: bool to commit changes to hardware or not (NLA_U8)
+ * @DCB_ATTR_PERM_HWADDR: MAC address of the physical device (NLA_NESTED)
+ */
+enum dcbnl_attrs {
+	DCB_ATTR_UNDEFINED,
+
+	DCB_ATTR_IFNAME,
+	DCB_ATTR_STATE,
+	DCB_ATTR_PFC_CFG,
+	DCB_ATTR_PG_CFG,
+	DCB_ATTR_SET_ALL,
+	DCB_ATTR_PERM_HWADDR,
+
+	__DCB_ATTR_ENUM_MAX,
+	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
+};
+
+
+/**
+ * enum dcbnl_perm_hwaddr_attrs - DCB Permanent HW Address nested attributes
+ *
+ * @DCB_PERM_HW_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_PERM_HW_ATTR_0: MAC address from receive address 0 (NLA_U8)
+ * @DCB_PERM_HW_ATTR_1: MAC address from receive address 1 (NLA_U8)
+ * @DCB_PERM_HW_ATTR_2: MAC address from receive address 2 (NLA_U8)
+ * @DCB_PERM_HW_ATTR_3: MAC address from receive address 3 (NLA_U8)
+ * @DCB_PERM_HW_ATTR_4: MAC address from receive address 4 (NLA_U8)
+ * @DCB_PERM_HW_ATTR_5: MAC address from receive address 5 (NLA_U8)
+ * @DCB_PERM_HW_ATTR_ALL: apply to all MAC addresses (NLA_FLAG)
+ *
+ * These attributes are used when bonding DCB interfaces together.
+ *
+ */
+enum dcbnl_perm_hwaddr_attrs {
+	DCB_PERM_HW_ATTR_UNDEFINED,
+
+	DCB_PERM_HW_ATTR_0,
+	DCB_PERM_HW_ATTR_1,
+	DCB_PERM_HW_ATTR_2,
+	DCB_PERM_HW_ATTR_3,
+	DCB_PERM_HW_ATTR_4,
+	DCB_PERM_HW_ATTR_5,
+	DCB_PERM_HW_ATTR_ALL,
+
+	__DCB_PERM_HW_ATTR_ENUM_MAX,
+	DCB_PERM_HW_ATTR_MAX = __DCB_PERM_HW_ATTR_ENUM_MAX - 1,
+};
+
+/**
+ * enum dcbnl_pfc_attrs - DCB Priority Flow Control user-priority nested attrs
+ *
+ * @DCB_PFC_UP_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_PFC_UP_ATTR_0: Priority Flow Control value for User Priority 0 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_1: Priority Flow Control value for User Priority 1 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_2: Priority Flow Control value for User Priority 2 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_3: Priority Flow Control value for User Priority 3 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_4: Priority Flow Control value for User Priority 4 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_5: Priority Flow Control value for User Priority 5 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_6: Priority Flow Control value for User Priority 6 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_7: Priority Flow Control value for User Priority 7 (NLA_U8)
+ * @DCB_PFC_UP_ATTR_MAX: highest attribute number currently defined
+ * @DCB_PFC_UP_ATTR_ALL: apply to all priority flow control attrs (NLA_FLAG) 
+ *
+ */
+enum dcbnl_pfc_up_attrs {
+	DCB_PFC_UP_ATTR_UNDEFINED,
+
+	DCB_PFC_UP_ATTR_0,
+	DCB_PFC_UP_ATTR_1,
+	DCB_PFC_UP_ATTR_2,
+	DCB_PFC_UP_ATTR_3,
+	DCB_PFC_UP_ATTR_4,
+	DCB_PFC_UP_ATTR_5,
+	DCB_PFC_UP_ATTR_6,
+	DCB_PFC_UP_ATTR_7,
+	DCB_PFC_UP_ATTR_ALL,
+
+	__DCB_PFC_UP_ATTR_ENUM_MAX,
+	DCB_PFC_UP_ATTR_MAX = __DCB_PFC_UP_ATTR_ENUM_MAX - 1,
+};
+
+/**
+ * enum dcbnl_pg_attrs - DCB Priority Group attributes
+ *
+ * @DCB_PG_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_PG_ATTR_TC_0: Priority Group Traffic Class 0 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_1: Priority Group Traffic Class 1 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_2: Priority Group Traffic Class 2 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_3: Priority Group Traffic Class 3 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_4: Priority Group Traffic Class 4 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_5: Priority Group Traffic Class 5 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_6: Priority Group Traffic Class 6 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_7: Priority Group Traffic Class 7 configuration (NLA_NESTED)
+ * @DCB_PG_ATTR_TC_MAX: highest attribute number currently defined
+ * @DCB_PG_ATTR_TC_ALL: apply to all traffic classes (NLA_NESTED)
+ * @DCB_PG_ATTR_BWG_0: Bandwidth group 0 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_1: Bandwidth group 1 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_2: Bandwidth group 2 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_3: Bandwidth group 3 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_4: Bandwidth group 4 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_5: Bandwidth group 5 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_6: Bandwidth group 6 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_7: Bandwidth group 7 configuration (NLA_U8)
+ * @DCB_PG_ATTR_BWG_MAX: highest attribute number currently defined
+ * @DCB_PG_ATTR_BWG_ALL: apply to all bandwidth groups (NLA_FLAG)
+ *
+ */
+enum dcbnl_pg_attrs {
+	DCB_PG_ATTR_UNDEFINED,
+
+	DCB_PG_ATTR_TC_0,
+	DCB_PG_ATTR_TC_1,
+	DCB_PG_ATTR_TC_2,
+	DCB_PG_ATTR_TC_3,
+	DCB_PG_ATTR_TC_4,
+	DCB_PG_ATTR_TC_5,
+	DCB_PG_ATTR_TC_6,
+	DCB_PG_ATTR_TC_7,
+	DCB_PG_ATTR_TC_MAX,
+	DCB_PG_ATTR_TC_ALL,
+
+	DCB_PG_ATTR_BWG_0,
+	DCB_PG_ATTR_BWG_1,
+	DCB_PG_ATTR_BWG_2,
+	DCB_PG_ATTR_BWG_3,
+	DCB_PG_ATTR_BWG_4,
+	DCB_PG_ATTR_BWG_5,
+	DCB_PG_ATTR_BWG_6,
+	DCB_PG_ATTR_BWG_7,
+	DCB_PG_ATTR_BWG_MAX,
+	DCB_PG_ATTR_BWG_ALL,
+
+	__DCB_PG_ATTR_ENUM_MAX,
+	DCB_PG_ATTR_MAX = __DCB_PG_ATTR_ENUM_MAX - 1,
+};
+
+/**
+ * enum dcbnl_tc_attrs - DCB Traffic Class attributes
+ *
+ * @DCB_TC_ATTR_PARAM_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_TC_ATTR_PARAM_STRICT_PRIO: Type of strict bandwidth aggregration (link
+ *                                 strict or group strict) (NLA_U8)
+ * @DCB_TC_ATTR_PARAM_BW_GROUP_ID: Bandwidth group this traffic class belongs to
+ *                                 (NLA_U8)
+ * @DCB_TC_ATTR_PARAM_BW_PCT: Percentage of bandwidth in the bandwidth group
+ *                            this traffic class has (NLA_U8)
+ * @DCB_TC_ATTR_PARAM_UP_MAPPING: Traffic class to user priority map (NLA_U8)
+ * @DCB_TC_ATTR_PARAM_ALL: apply to all traffic class parameters (NLA_FLAG)
+ *
+ */
+enum dcbnl_tc_attrs {
+	DCB_TC_ATTR_PARAM_UNDEFINED,
+
+	DCB_TC_ATTR_PARAM_STRICT_PRIO,
+	DCB_TC_ATTR_PARAM_BW_GROUP_ID,
+	DCB_TC_ATTR_PARAM_BW_PCT,
+	DCB_TC_ATTR_PARAM_UP_MAPPING,
+	DCB_TC_ATTR_PARAM_ALL,
+
+	__DCB_TC_ATTR_PARAM_ENUM_MAX,
+	DCB_TC_ATTR_PARAM_MAX = __DCB_TC_ATTR_PARAM_ENUM_MAX - 1,
+};
+
+/* 
+ * Ops struct for the netlink callbacks.  Used by DCB-enabled drivers through
+ * the netdevice struct.
+ */
+struct dcbnl_genl_ops {
+	u8   (*getstate)(struct net_device *);
+	void (*setstate)(struct net_device *, u8);
+	void (*getpermhwaddr)(struct net_device *, u8 *);
+	void (*setpgtccfgtx)(struct net_device *, int, u8, u8, u8, u8);
+	void (*setpgbwgcfgtx)(struct net_device *, int, u8);
+	void (*setpgtccfgrx)(struct net_device *, int, u8, u8, u8, u8);
+	void (*setpgbwgcfgrx)(struct net_device *, int, u8);
+	void (*getpgtccfgtx)(struct net_device *, int, u8 *, u8 *, u8 *, u8 *);
+	void (*getpgbwgcfgtx)(struct net_device *, int, u8 *);
+	void (*getpgtccfgrx)(struct net_device *, int, u8 *, u8 *, u8 *, u8 *);
+	void (*getpgbwgcfgrx)(struct net_device *, int, u8 *);
+	void (*setpfccfg)(struct net_device *, int, u8);
+	void (*getpfccfg)(struct net_device *, int, u8 *);
+	u8   (*setall)(struct net_device *);
+};
+
+#endif /* __LINUX_DCBNL_H__ */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f27fd20..f28a1fa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -42,6 +42,9 @@
 #include <linux/workqueue.h>
 
 #include <net/net_namespace.h>
+#ifdef CONFIG_DCBNL
+#include <linux/dcbnl.h>
+#endif
 
 struct vlan_group;
 struct ethtool_ops;
@@ -752,6 +755,11 @@ struct net_device
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
 
+#ifdef CONFIG_DCBNL
+	/* Data Center Bridging netlink ops */
+	struct dcbnl_genl_ops *dcbnl_ops;
+#endif
+
 	/* The TX queue control structures */
 	unsigned int			egress_subqueue_count;
 	struct net_device_subqueue	egress_subqueue[1];
diff --git a/net/Kconfig b/net/Kconfig
index acbf7c6..fc6b832 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -192,6 +192,7 @@ source "net/lapb/Kconfig"
 source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/sched/Kconfig"
+source "net/dcb/Kconfig"
 
 menu "Network testing"
 
diff --git a/net/Makefile b/net/Makefile
index b7a1364..bc43e77 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -53,6 +53,9 @@ obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
+ifeq ($(CONFIG_DCBNL),y)
+obj-$(CONFIG_DCB)		+= dcb/
+endif
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
diff --git a/net/dcb/Kconfig b/net/dcb/Kconfig
new file mode 100644
index 0000000..bdf3880
--- /dev/null
+++ b/net/dcb/Kconfig
@@ -0,0 +1,12 @@
+config DCB
+        tristate "Data Center Bridging support"
+
+config DCBNL
+	bool "Data Center Bridging netlink interface support"
+	depends on DCB
+	default n
+	---help---
+	  This option turns on the netlink interface
+	  (dcbnl) for Data Center Bridging capable devices.
+
+	  If unsure, say N.
diff --git a/net/dcb/Makefile b/net/dcb/Makefile
new file mode 100644
index 0000000..9930f4c
--- /dev/null
+++ b/net/dcb/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_DCB) += dcbnl.o
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
new file mode 100644
index 0000000..f5f4c31
--- /dev/null
+++ b/net/dcb/dcbnl.c
@@ -0,0 +1,722 @@
+/*
+ * This is the Data Center Bridging configuration interface.
+ *
+ * Copyright 2008, Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/netlink.h>
+#include <linux/genetlink.h>
+#include <net/genetlink.h>
+#include <linux/dcbnl.h>
+
+MODULE_AUTHOR("Peter P Waskiewicz Jr, <peter.p.waskiewicz.jr@intel.com>");
+MODULE_DESCRIPTION("Data Center Bridging generic netlink interface");
+MODULE_LICENSE("GPL");
+
+/* The family */
+static struct genl_family dcbnl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = 0,
+	.name = "dcbnl",
+	.version = DCB_PROTO_VERSION,
+	.maxattr = DCB_ATTR_MAX,
+};
+
+/* DCB netlink attributes policy */
+static struct nla_policy dcbnl_genl_policy[DCB_ATTR_MAX + 1] = {
+	[DCB_ATTR_IFNAME]    = {.type = NLA_STRING, .len = IFNAMSIZ - 1},
+	[DCB_ATTR_STATE]     = {.type = NLA_U8},
+	[DCB_ATTR_PFC_CFG]   = {.type = NLA_NESTED},
+	[DCB_ATTR_PG_CFG]    = {.type = NLA_NESTED},
+	[DCB_ATTR_SET_ALL]   = {.type = NLA_U8},
+	[DCB_ATTR_PERM_HWADDR] = {.type = NLA_NESTED},
+};
+
+/* DCB permanent hardware address nested attributes */
+static struct nla_policy dcbnl_perm_hwaddr_nest[DCB_PERM_HW_ATTR_MAX + 1] = {
+	[DCB_PERM_HW_ATTR_0] = {.type = NLA_U8},
+	[DCB_PERM_HW_ATTR_1] = {.type = NLA_U8},
+	[DCB_PERM_HW_ATTR_2] = {.type = NLA_U8},
+	[DCB_PERM_HW_ATTR_3] = {.type = NLA_U8},
+	[DCB_PERM_HW_ATTR_4] = {.type = NLA_U8},
+	[DCB_PERM_HW_ATTR_5] = {.type = NLA_U8},
+	[DCB_PERM_HW_ATTR_ALL] = {.type = NLA_FLAG},
+};
+
+/* DCB priority flow control to User Priority nested attributes */
+static struct nla_policy dcbnl_pfc_up_nest[DCB_PFC_UP_ATTR_MAX + 1] = {
+	[DCB_PFC_UP_ATTR_0]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_1]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_2]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_3]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_4]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_5]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_6]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_7]   = {.type = NLA_U8},
+	[DCB_PFC_UP_ATTR_ALL] = {.type = NLA_FLAG},
+};
+
+/* DCB priority grouping nested attributes */
+static struct nla_policy dcbnl_pg_nest[DCB_PG_ATTR_MAX + 1] = {
+	[DCB_PG_ATTR_TC_0]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_1]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_2]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_3]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_4]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_5]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_6]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_7]   = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_TC_ALL] = {.type = NLA_NESTED},
+	[DCB_PG_ATTR_BWG_0]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_1]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_2]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_3]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_4]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_5]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_6]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_7]  = {.type = NLA_U8},
+	[DCB_PG_ATTR_BWG_ALL]= {.type = NLA_FLAG},
+};
+
+/* DCB traffic class nested attributes. */
+static struct nla_policy dcbnl_tc_param_nest[DCB_TC_ATTR_PARAM_MAX + 1] = {
+	[DCB_TC_ATTR_PARAM_STRICT_PRIO]     = {.type = NLA_U8},
+	[DCB_TC_ATTR_PARAM_BW_GROUP_ID]     = {.type = NLA_U8},
+	[DCB_TC_ATTR_PARAM_BW_PCT]          = {.type = NLA_U8},
+	[DCB_TC_ATTR_PARAM_UP_MAPPING]      = {.type = NLA_U8},
+	[DCB_TC_ATTR_PARAM_ALL]             = {.type = NLA_FLAG},
+};
+
+/* standard netlink reply call */
+static int dcbnl_reply(u8 value, u8 cmd, u8 attr, struct genl_info *info)
+{
+	struct sk_buff *dcbnl_skb;
+	void *data;
+	int ret = -EINVAL;
+
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb)
+		return ret;
+
+	data = genlmsg_put_reply(dcbnl_skb, info, &dcbnl_family, 0, cmd);
+	if (!data)
+		goto err;
+
+	ret = nla_put_u8(dcbnl_skb, attr, value);
+	if (ret)
+        	goto err;
+
+	/* end the message, assign the nlmsg_len. */
+	genlmsg_end(dcbnl_skb, data);
+	ret = genlmsg_reply(dcbnl_skb, info);
+	if (ret)
+        	goto err;
+
+	return 0;
+err:
+	kfree(dcbnl_skb);
+	return ret;
+}
+
+static int dcbnl_getstate(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *netdev;
+	int ret = -EINVAL;
+
+	if (!info->attrs[DCB_ATTR_IFNAME])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops || !netdev->dcbnl_ops->getstate)
+		goto err;
+
+	ret = dcbnl_reply(netdev->dcbnl_ops->getstate(netdev),
+                          DCB_CMD_GSTATE, DCB_ATTR_STATE, info);
+err:
+	dev_put(netdev);
+	return ret;
+}
+
+static int dcbnl_setstate(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *netdev;
+	int ret = -EINVAL;
+	u8 value;
+
+	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_STATE])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops || !netdev->dcbnl_ops->setstate)
+		goto err;
+
+	value = nla_get_u8(info->attrs[DCB_ATTR_STATE]);
+
+	netdev->dcbnl_ops->setstate(netdev, value);
+
+	ret = dcbnl_reply(0, DCB_CMD_SSTATE, DCB_ATTR_STATE, info);
+err:
+	dev_put(netdev);
+	return ret;
+}
+
+static int dcbnl_getperm_hwaddr(struct sk_buff *skb, struct genl_info *info)
+{
+	void *data;
+	struct sk_buff *dcbnl_skb;
+	struct nlattr *tb[DCB_PERM_HW_ATTR_MAX + 1], *nest;
+	struct net_device *netdev;
+	u8 perm_addr[MAX_ADDR_LEN];
+	int ret = -EINVAL;
+	int i;
+
+	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_PERM_HWADDR])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops || !netdev->dcbnl_ops->getpermhwaddr)
+		goto err_out;
+
+	ret = nla_parse_nested(tb, DCB_PERM_HW_ATTR_MAX,
+			       info->attrs[DCB_ATTR_PERM_HWADDR],
+			       dcbnl_perm_hwaddr_nest);
+	if (ret)
+		goto err_out;
+
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb)
+		goto err_out;
+
+	data = genlmsg_put_reply(dcbnl_skb, info, &dcbnl_family, 0,
+				 DCB_CMD_GPERM_HWADDR);
+	if (!data)
+		goto err;
+
+	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_PERM_HWADDR);
+	if (!nest)
+		goto err;
+
+	netdev->dcbnl_ops->getpermhwaddr(netdev, perm_addr);
+	for (i = 0; i < netdev->addr_len; i++) {
+		ret = nla_put_u8(dcbnl_skb, DCB_ATTR_PERM_HWADDR,
+				 perm_addr[i]);
+
+		if (ret) {
+			nla_nest_cancel(dcbnl_skb, nest);
+			goto err;
+		}
+	}
+
+	nla_nest_end(dcbnl_skb, nest);
+
+	genlmsg_end(dcbnl_skb, data);
+
+	ret = genlmsg_reply(dcbnl_skb, info);
+	if (ret)
+		goto err_out;
+
+	dev_put(netdev);
+	return 0;
+err:
+	kfree(dcbnl_skb);
+err_out:
+	dev_put(netdev);
+	return ret;
+}
+
+static int __dcbnl_pg_setcfg(struct genl_info *info, int dir)
+{
+	struct net_device *netdev = NULL;
+	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
+	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
+	int ret = -EINVAL;
+	int i;
+	u8 prio = 0, bwg_id = 0, bw_pct = 0, up_map = 0;
+
+	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_PG_CFG])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops ||
+	    !netdev->dcbnl_ops->setpgtccfgtx ||
+	    !netdev->dcbnl_ops->setpgtccfgrx ||
+	    !netdev->dcbnl_ops->setpgbwgcfgtx ||
+	    !netdev->dcbnl_ops->setpgbwgcfgrx)
+		goto err;
+
+	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX,
+			       info->attrs[DCB_ATTR_PG_CFG], dcbnl_pg_nest);
+	if (ret)
+		goto err;
+
+	for (i = DCB_PG_ATTR_TC_0; i < DCB_PG_ATTR_TC_MAX; i++) {
+		if (!pg_tb[i])
+			continue;
+
+		ret = nla_parse_nested(param_tb, DCB_TC_ATTR_PARAM_MAX,
+				       pg_tb[i], dcbnl_tc_param_nest);
+		if (ret)
+			goto err;
+
+		if (param_tb[DCB_TC_ATTR_PARAM_STRICT_PRIO])
+			prio =
+			    nla_get_u8(param_tb[DCB_TC_ATTR_PARAM_STRICT_PRIO]);
+
+		if (param_tb[DCB_TC_ATTR_PARAM_BW_GROUP_ID])
+			bwg_id =
+			    nla_get_u8(param_tb[DCB_TC_ATTR_PARAM_BW_GROUP_ID]);
+
+		if (param_tb[DCB_TC_ATTR_PARAM_BW_PCT])
+			bw_pct = nla_get_u8(param_tb[DCB_TC_ATTR_PARAM_BW_PCT]);
+
+		if (param_tb[DCB_TC_ATTR_PARAM_UP_MAPPING])
+			up_map =
+			     nla_get_u8(param_tb[DCB_TC_ATTR_PARAM_UP_MAPPING]);
+
+		/* dir: Tx = 0, Rx = 1 */
+		if (dir) {
+			/* Rx */
+			netdev->dcbnl_ops->setpgtccfgrx(netdev,
+						  i - DCB_PG_ATTR_TC_0,
+						  prio, bwg_id, bw_pct, up_map);
+		} else {
+			/* Tx */
+			netdev->dcbnl_ops->setpgtccfgtx(netdev, 
+						  i - DCB_PG_ATTR_TC_0,
+						  prio, bwg_id, bw_pct, up_map);
+		}
+	}
+
+	for (i = DCB_PG_ATTR_BWG_0; i < DCB_PG_ATTR_BWG_MAX; i++) {
+		if (!pg_tb[i])
+			continue;
+
+		bw_pct = nla_get_u8(pg_tb[i]);
+
+		/* dir: Tx = 0, Rx = 1 */
+		if (dir) {
+			/* Rx */
+			netdev->dcbnl_ops->setpgbwgcfgrx(netdev,
+						 i - DCB_PG_ATTR_BWG_0, bw_pct);
+		} else {
+			/* Tx */
+			netdev->dcbnl_ops->setpgbwgcfgtx(netdev,
+						 i - DCB_PG_ATTR_BWG_0, bw_pct);
+		}
+	}
+
+	ret = dcbnl_reply(0, (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG),
+			  DCB_ATTR_PG_CFG, info);
+
+err:
+	dev_put(netdev);
+	return ret;
+}
+
+static int dcbnl_pgtx_setcfg(struct sk_buff *skb, struct genl_info *info)
+{
+	return __dcbnl_pg_setcfg(info, 0);
+}
+
+static int dcbnl_pgrx_setcfg(struct sk_buff *skb, struct genl_info *info)
+{
+	return __dcbnl_pg_setcfg(info, 1);
+}
+
+static int __dcbnl_pg_getcfg(struct genl_info *info, int dir)
+{
+	void *data;
+	struct sk_buff *dcbnl_skb;
+	struct nlattr *pg_nest, *param_nest, *tb;
+	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
+	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
+	struct net_device *netdev;
+	u8 prio, bwg_id, bw_pct, up_map;
+	int ret  = -EINVAL;
+	int i;
+
+	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_PG_CFG])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops ||
+	    !netdev->dcbnl_ops->getpgtccfgtx ||
+	    !netdev->dcbnl_ops->getpgtccfgrx ||
+	    !netdev->dcbnl_ops->getpgbwgcfgtx ||
+	    !netdev->dcbnl_ops->getpgbwgcfgrx)
+		goto err_out;
+
+	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX,
+			       info->attrs[DCB_ATTR_PG_CFG], dcbnl_pg_nest);
+	if (ret)
+		goto err_out;
+
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb)
+		goto err_out;
+
+	data =  genlmsg_put_reply(dcbnl_skb, info, &dcbnl_family, 0,
+				 (dir) ? DCB_CMD_PGRX_GCFG : DCB_CMD_PGTX_GCFG);
+
+	if (!data)
+		goto err;
+
+	pg_nest = nla_nest_start(dcbnl_skb, DCB_ATTR_PG_CFG);
+	if (!pg_nest)
+		goto err;
+
+	for (i = DCB_PG_ATTR_TC_0; i < DCB_PG_ATTR_TC_MAX; i++) {
+		if (pg_tb[DCB_PG_ATTR_TC_ALL])
+			tb = pg_tb[DCB_PG_ATTR_TC_ALL];
+		else
+			tb = pg_tb[i];
+		ret = nla_parse_nested(param_tb, DCB_TC_ATTR_PARAM_MAX,
+				       tb, dcbnl_tc_param_nest);
+		if (ret)
+			goto err_pg;
+
+		param_nest = nla_nest_start(dcbnl_skb, i);
+		if (!param_nest)
+			goto err_pg;
+
+		if (dir) {
+			/* Rx */
+			netdev->dcbnl_ops->getpgtccfgrx(netdev,
+						i - DCB_PG_ATTR_TC_0, &prio,
+						&bwg_id, &bw_pct, &up_map);
+		} else {
+			/* Tx */
+			netdev->dcbnl_ops->getpgtccfgtx(netdev,
+						i - DCB_PG_ATTR_TC_0, &prio,
+						&bwg_id, &bw_pct, &up_map);
+		}
+
+		if (param_tb[DCB_TC_ATTR_PARAM_STRICT_PRIO] ||
+		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
+			ret = nla_put_u8(dcbnl_skb,
+					 DCB_TC_ATTR_PARAM_STRICT_PRIO, prio);
+			if (ret)
+				goto err_param;
+		}
+		if (param_tb[DCB_TC_ATTR_PARAM_BW_GROUP_ID] ||
+		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
+			ret = nla_put_u8(dcbnl_skb,
+					 DCB_TC_ATTR_PARAM_BW_GROUP_ID, bwg_id);
+			if (ret)
+				goto err_param;
+		}
+		if (param_tb[DCB_TC_ATTR_PARAM_BW_PCT] ||
+		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
+			ret = nla_put_u8(dcbnl_skb, DCB_TC_ATTR_PARAM_BW_PCT,
+					 bw_pct);
+			if (ret)
+				goto err_param;
+		}
+		if (param_tb[DCB_TC_ATTR_PARAM_UP_MAPPING] ||
+		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
+			ret = nla_put_u8(dcbnl_skb,
+					 DCB_TC_ATTR_PARAM_UP_MAPPING, up_map);
+			if (ret)
+				goto err_param;
+		}
+		nla_nest_end(dcbnl_skb, param_nest);
+	}
+
+	for (i = DCB_PG_ATTR_BWG_0; i < DCB_PG_ATTR_BWG_MAX; i++) {
+		if (dir) {
+			/* Rx */
+			netdev->dcbnl_ops->getpgbwgcfgrx(netdev,
+						i - DCB_PG_ATTR_BWG_0, &bw_pct);
+		} else {
+			/* Tx */
+			netdev->dcbnl_ops->getpgbwgcfgtx(netdev,
+						i - DCB_PG_ATTR_BWG_0, &bw_pct);
+		}
+		ret = nla_put_u8(dcbnl_skb, i, bw_pct);
+
+		if (ret)
+			goto err_pg;
+	}
+
+	nla_nest_end(dcbnl_skb, pg_nest);
+
+	genlmsg_end(dcbnl_skb, data);
+	ret = genlmsg_reply(dcbnl_skb, info);
+	if (ret)
+		goto err;
+
+	dev_put(netdev);
+	return 0;
+
+err_param:
+	nla_nest_cancel(dcbnl_skb, param_nest);
+err_pg:
+	nla_nest_cancel(dcbnl_skb, pg_nest);
+err:
+	kfree(dcbnl_skb);
+err_out:
+	dev_put(netdev);
+	return ret;
+}
+
+static int dcbnl_pgtx_getcfg(struct sk_buff *skb, struct genl_info *info)
+{
+	return __dcbnl_pg_getcfg(info, 0);
+}
+
+static int dcbnl_pgrx_getcfg(struct sk_buff *skb, struct genl_info *info)
+{
+	return __dcbnl_pg_getcfg(info, 1);
+}
+
+static int dcbnl_setpfccfg(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr *tb[DCB_PFC_UP_ATTR_MAX + 1];
+	struct net_device *netdev;
+	int i;
+	int ret = -EINVAL;
+	u8 value;
+
+	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_PFC_CFG])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops || !netdev->dcbnl_ops->setpfccfg)
+		goto err;
+
+	ret = nla_parse_nested(tb, DCB_PFC_UP_ATTR_MAX,
+		               info->attrs[DCB_ATTR_PFC_CFG],
+		               dcbnl_pfc_up_nest);
+	if (ret)
+		goto err;
+
+	for (i = DCB_PFC_UP_ATTR_0; i < DCB_PFC_UP_ATTR_MAX; i++) {
+		value = nla_get_u8(tb[i]);
+		netdev->dcbnl_ops->setpfccfg(netdev, i - DCB_PFC_UP_ATTR_0,
+					     value);
+	}
+
+	ret = dcbnl_reply(0, DCB_CMD_PFC_SCFG, DCB_ATTR_PFC_CFG, info);
+err:
+	dev_put(netdev);
+	return ret;
+}
+
+static int dcbnl_getpfccfg(struct sk_buff *skb, struct genl_info *info)
+{
+	void *data;
+	struct sk_buff *dcbnl_skb;
+	struct nlattr *tb[DCB_PFC_UP_ATTR_MAX + 1], *nest;
+	struct net_device *netdev;
+	u8 value;
+	int ret = -EINVAL;
+	int i;
+
+	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_PFC_CFG])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops || !netdev->dcbnl_ops->getpfccfg)
+		goto err_out;
+
+	ret = nla_parse_nested(tb, DCB_PFC_UP_ATTR_MAX,
+			       info->attrs[DCB_ATTR_PFC_CFG],
+			       dcbnl_pfc_up_nest);
+	if (ret)
+		goto err_out;
+
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb)
+		goto err_out;
+
+	data = genlmsg_put_reply(dcbnl_skb, info, &dcbnl_family, 0,
+				 DCB_CMD_PFC_GCFG);
+	if (!data)
+		goto err;
+
+	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_PFC_CFG);
+	if (!nest)
+		goto err;
+
+	for (i = DCB_PFC_UP_ATTR_0; i < DCB_PFC_UP_ATTR_MAX; i++) {
+		netdev->dcbnl_ops->getpfccfg(netdev, i - DCB_PFC_UP_ATTR_0,
+					     &value);
+		ret = nla_put_u8(dcbnl_skb, i, value);
+
+		if (ret) {
+			nla_nest_cancel(dcbnl_skb, nest);
+			goto err;
+		}
+	}
+	nla_nest_end(dcbnl_skb, nest);
+
+	genlmsg_end(dcbnl_skb, data);
+
+	ret = genlmsg_reply(dcbnl_skb, info);
+	if (ret)
+		goto err;
+
+	dev_put(netdev);
+	return 0;
+
+err:
+	kfree(dcbnl_skb);
+err_out:
+	dev_put(netdev);
+	return ret;
+}
+
+static int dcbnl_setall(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *netdev;
+	int ret = -EINVAL;
+
+	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_SET_ALL])
+		return ret;
+
+	netdev = dev_get_by_name(&init_net,
+				 nla_data(info->attrs[DCB_ATTR_IFNAME]));
+	if (!netdev)
+		return ret;
+
+	if (!netdev->dcbnl_ops || !netdev->dcbnl_ops->setall)
+		return ret;
+
+	ret = dcbnl_reply(netdev->dcbnl_ops->setall(netdev), DCB_CMD_SET_ALL,
+			  DCB_ATTR_SET_ALL, info);
+
+	dev_put(netdev);
+	return ret;
+}
+
+static struct genl_ops dcbnl_ops[] = {
+	{
+		.cmd = DCB_CMD_GSTATE,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_getstate,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_SSTATE,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_setstate,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_PGTX_SCFG,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_pgtx_setcfg,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_PGRX_SCFG,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_pgrx_setcfg,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_PFC_SCFG,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_setpfccfg,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_PGTX_GCFG,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_pgtx_getcfg,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_PGRX_GCFG,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_pgrx_getcfg,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_PFC_GCFG,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_getpfccfg,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_SET_ALL,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_setall,
+		.dumpit =  NULL,
+	},
+	{
+		.cmd = DCB_CMD_GPERM_HWADDR,
+		.flags = GENL_ADMIN_PERM,
+		.policy = dcbnl_genl_policy,
+		.doit = dcbnl_getperm_hwaddr,
+		.dumpit =  NULL,
+	},
+};
+
+/* init and exit */
+static int __init dcbnl_init(void)
+{
+	int err, i;
+
+	err = genl_register_family(&dcbnl_family);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(dcbnl_ops); i++) {
+		err = genl_register_ops(&dcbnl_family, &dcbnl_ops[i]);
+		if (err)
+			goto err_out;
+	}
+
+	return 0;
+
+err_out:
+	genl_unregister_family(&dcbnl_family);
+	return err;
+}
+module_init(dcbnl_init);
+
+static void __exit dcbnl_exit(void)
+{
+	genl_unregister_family(&dcbnl_family);
+}
+module_exit(dcbnl_exit);

