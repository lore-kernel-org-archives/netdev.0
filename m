From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 18/18]: Use rtnl_link API
Date: Wed, 13 Jun 2007 18:51:06 +0200 (MEST)
Message-ID: <20070613165103.7780.5886.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35976 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758870AbXFMQvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:51:09 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Use rtnl_link API

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b4bb367897c114980367013f1a636bb6a9630a11
tree 8f1904816e27d07df5a7a910dc1e81a08215b490
parent 84bb1e021b6c3567bebccfc5e3dd4ab7d8f5bfae
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:47:07 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:45:04 +0200

 include/linux/if_link.h  |   34 +++++++
 net/8021q/Makefile       |    2 
 net/8021q/vlan.c         |   29 ++++--
 net/8021q/vlan.h         |   10 ++
 net/8021q/vlan_netlink.c |  236 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 300 insertions(+), 11 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3144bab..422084d 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -153,4 +153,38 @@ enum
 
 #define IFLA_INFO_MAX	(__IFLA_INFO_MAX - 1)
 
+/* VLAN section */
+
+enum
+{
+	IFLA_VLAN_UNSPEC,
+	IFLA_VLAN_ID,
+	IFLA_VLAN_FLAGS,
+	IFLA_VLAN_EGRESS_QOS,
+	IFLA_VLAN_INGRESS_QOS,
+	__IFLA_VLAN_MAX,
+};
+
+#define IFLA_VLAN_MAX	(__IFLA_VLAN_MAX - 1)
+
+struct ifla_vlan_flags {
+	__u32	flags;
+	__u32	mask;
+};
+
+enum
+{
+	IFLA_VLAN_QOS_UNSPEC,
+	IFLA_VLAN_QOS_MAPPING,
+	__IFLA_VLAN_QOS_MAX
+};
+
+#define IFLA_VLAN_QOS_MAX	(__IFLA_VLAN_QOS_MAX - 1)
+
+struct ifla_vlan_qos_mapping
+{
+	__u32 from;
+	__u32 to;
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/8021q/Makefile b/net/8021q/Makefile
index 97feb44..10ca7f4 100644
--- a/net/8021q/Makefile
+++ b/net/8021q/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_VLAN_8021Q) += 8021q.o
 
-8021q-objs := vlan.o vlan_dev.o
+8021q-objs := vlan.o vlan_dev.o vlan_netlink.o
 
 ifeq ($(CONFIG_PROC_FS),y)
 8021q-objs += vlanproc.o
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index f12f914..e7583ee 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -97,15 +97,22 @@ static int __init vlan_proto_init(void)
 
 	/* Register us to receive netdevice events */
 	err = register_netdevice_notifier(&vlan_notifier_block);
-	if (err < 0) {
-		dev_remove_pack(&vlan_packet_type);
-		vlan_proc_cleanup();
-		return err;
-	}
+	if (err < 0)
+		goto err1;
 
-	vlan_ioctl_set(vlan_ioctl_handler);
+	err = vlan_netlink_init();
+	if (err < 0)
+		goto err2;
 
+	vlan_ioctl_set(vlan_ioctl_handler);
 	return 0;
+
+err2:
+	unregister_netdevice_notifier(&vlan_notifier_block);
+err1:
+	vlan_proc_cleanup();
+	dev_remove_pack(&vlan_packet_type);
+	return err;
 }
 
 /* Cleanup all vlan devices
@@ -136,6 +143,7 @@ static void __exit vlan_cleanup_module(void)
 {
 	int i;
 
+	vlan_netlink_fini();
 	vlan_ioctl_set(NULL);
 
 	/* Un-register us from receiving netdevice events */
@@ -306,7 +314,7 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 	return ret;
 }
 
-static int unregister_vlan_device(struct net_device *dev)
+int unregister_vlan_device(struct net_device *dev)
 {
 	int ret;
 
@@ -361,7 +369,7 @@ static int vlan_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static void vlan_setup(struct net_device *new_dev)
+void vlan_setup(struct net_device *new_dev)
 {
 	SET_MODULE_OWNER(new_dev);
 
@@ -410,7 +418,7 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
 	}
 }
 
-static int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id)
+int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id)
 {
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		printk(VLAN_DBG "%s: VLANs not supported on %s.\n",
@@ -447,7 +455,7 @@ static int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_
 	return 0;
 }
 
-static int register_vlan_dev(struct net_device *dev)
+int register_vlan_dev(struct net_device *dev)
 {
 	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
 	struct net_device *real_dev = vlan->real_dev;
@@ -567,6 +575,7 @@ static int register_vlan_device(struct net_device *real_dev,
 	VLAN_DEV_INFO(new_dev)->dent = NULL;
 	VLAN_DEV_INFO(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
 
+	new_dev->rtnl_link_ops = &vlan_link_ops;
 	err = register_vlan_dev(new_dev);
 	if (err < 0)
 		goto out_free_newdev;
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index b837390..fe6bb0f 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -72,4 +72,14 @@ void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
+int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id);
+void vlan_setup(struct net_device *dev);
+int register_vlan_dev(struct net_device *dev);
+int unregister_vlan_device(struct net_device *dev);
+
+int vlan_netlink_init(void);
+void vlan_netlink_fini(void);
+
+extern struct rtnl_link_ops vlan_link_ops;
+
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
new file mode 100644
index 0000000..844c7e4
--- /dev/null
+++ b/net/8021q/vlan_netlink.c
@@ -0,0 +1,236 @@
+/*
+ *	VLAN netlink control interface
+ *
+ * 	Copyright (c) 2007 Patrick McHardy <kaber@trash.net>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+#include <net/netlink.h>
+#include <net/rtnetlink.h>
+#include "vlan.h"
+
+
+static const struct nla_policy vlan_policy[IFLA_VLAN_MAX + 1] = {
+	[IFLA_VLAN_ID]		= { .type = NLA_U16 },
+	[IFLA_VLAN_FLAGS]	= { .len = sizeof(struct ifla_vlan_flags) },
+	[IFLA_VLAN_EGRESS_QOS]	= { .type = NLA_NESTED },
+	[IFLA_VLAN_INGRESS_QOS] = { .type = NLA_NESTED },
+};
+
+static const struct nla_policy vlan_map_policy[IFLA_VLAN_QOS_MAX + 1] = {
+	[IFLA_VLAN_QOS_MAPPING] = { .len = sizeof(struct ifla_vlan_qos_mapping) },
+};
+
+
+static inline int vlan_validate_qos_map(struct nlattr *attr)
+{
+	if (!attr)
+		return 0;
+	return nla_validate_nested(attr, IFLA_VLAN_QOS_MAX, vlan_map_policy);
+}
+
+static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	struct ifla_vlan_flags *flags;
+	u16 id;
+	int err;
+
+	if (!data)
+		return -EINVAL;
+
+	if (data[IFLA_VLAN_ID]) {
+		id = nla_get_u16(data[IFLA_VLAN_ID]);
+		if (id >= VLAN_VID_MASK)
+			return -ERANGE;
+	}
+	if (data[IFLA_VLAN_FLAGS]) {
+		flags = nla_data(data[IFLA_VLAN_FLAGS]);
+		if ((flags->flags & flags->mask) & ~VLAN_FLAG_REORDER_HDR)
+			return -EINVAL;
+	}
+
+	err = vlan_validate_qos_map(data[IFLA_VLAN_INGRESS_QOS]);
+	if (err < 0)
+		return err;
+	err = vlan_validate_qos_map(data[IFLA_VLAN_EGRESS_QOS]);
+	if (err < 0)
+		return err;
+	return 0;
+}
+
+static int vlan_changelink(struct net_device *dev,
+			   struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct ifla_vlan_flags *flags;
+	struct ifla_vlan_qos_mapping *m;
+	struct nlattr *attr;
+	int rem;
+
+	if (data[IFLA_VLAN_FLAGS]) {
+		flags = nla_data(data[IFLA_VLAN_FLAGS]);
+		vlan->flags = (vlan->flags & ~flags->mask) |
+			      (flags->flags & flags->mask);
+	}
+	if (data[IFLA_VLAN_INGRESS_QOS]) {
+		nla_for_each_nested(attr, data[IFLA_VLAN_INGRESS_QOS], rem) {
+			m = nla_data(attr);
+			vlan_dev_set_ingress_priority(dev, m->to, m->from);
+		}
+	}
+	if (data[IFLA_VLAN_EGRESS_QOS]) {
+		nla_for_each_nested(attr, data[IFLA_VLAN_EGRESS_QOS], rem) {
+			m = nla_data(attr);
+			vlan_dev_set_egress_priority(dev, m->from, m->to);
+		}
+	}
+	return 0;
+}
+
+static int vlan_newlink(struct net_device *dev,
+			struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct net_device *real_dev;
+	int err;
+
+	if (!data[IFLA_VLAN_ID])
+		return -EINVAL;
+
+	if (!tb[IFLA_LINK])
+		return -EINVAL;
+	real_dev = __dev_get_by_index(nla_get_u32(tb[IFLA_LINK]));
+	if (!real_dev)
+		return -ENODEV;
+
+	vlan->vlan_id  = nla_get_u16(data[IFLA_VLAN_ID]);
+	vlan->real_dev = real_dev;
+	vlan->flags    = VLAN_FLAG_REORDER_HDR;
+
+	err = vlan_check_real_dev(real_dev, vlan->vlan_id);
+	if (err < 0)
+		return err;
+
+	if (!tb[IFLA_MTU])
+		dev->mtu = real_dev->mtu;
+	else if (dev->mtu > real_dev->mtu)
+		return -EINVAL;
+
+	err = vlan_changelink(dev, tb, data);
+	if (err < 0)
+		return err;
+
+	return register_vlan_dev(dev);
+}
+
+static void vlan_dellink(struct net_device *dev)
+{
+	unregister_vlan_device(dev);
+}
+
+static inline size_t vlan_qos_map_size(unsigned int n)
+{
+	if (n == 0)
+		return 0;
+	/* IFLA_VLAN_{EGRESS,INGRESS}_QOS + n * IFLA_VLAN_QOS_MAPPING */
+	return nla_total_size(sizeof(struct nlattr)) +
+	       nla_total_size(sizeof(struct ifla_vlan_qos_mapping)) * n;
+}
+
+static size_t vlan_get_size(const struct net_device *dev)
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+
+	return nla_total_size(2) +	/* IFLA_VLAN_ID */
+	       vlan_qos_map_size(vlan->nr_ingress_mappings) +
+	       vlan_qos_map_size(vlan->nr_egress_mappings);
+}
+
+static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_priority_tci_mapping *pm;
+	struct ifla_vlan_flags f;
+	struct ifla_vlan_qos_mapping m;
+	struct nlattr *nest;
+	unsigned int i;
+
+	NLA_PUT_U16(skb, IFLA_VLAN_ID, VLAN_DEV_INFO(dev)->vlan_id);
+	if (vlan->flags) {
+		f.flags = vlan->flags;
+		f.mask  = ~0;
+		NLA_PUT(skb, IFLA_VLAN_FLAGS, sizeof(f), &f);
+	}
+	if (vlan->nr_ingress_mappings) {
+		nest = nla_nest_start(skb, IFLA_VLAN_INGRESS_QOS);
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		for (i = 0; i < ARRAY_SIZE(vlan->ingress_priority_map); i++) {
+			if (!vlan->ingress_priority_map[i])
+				continue;
+
+			m.from = i;
+			m.to   = vlan->ingress_priority_map[i];
+			NLA_PUT(skb, IFLA_VLAN_QOS_MAPPING,
+				sizeof(m), &m);
+		}
+		nla_nest_end(skb, nest);
+	}
+
+	if (vlan->nr_egress_mappings) {
+		nest = nla_nest_start(skb, IFLA_VLAN_EGRESS_QOS);
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		for (i = 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
+			for (pm = vlan->egress_priority_map[i]; pm;
+			     pm = pm->next) {
+				if (!pm->vlan_qos)
+					continue;
+
+				m.from = pm->priority;
+				m.to   = (pm->vlan_qos >> 13) & 0x7;
+				NLA_PUT(skb, IFLA_VLAN_QOS_MAPPING,
+					sizeof(m), &m);
+			}
+		}
+		nla_nest_end(skb, nest);
+	}
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+struct rtnl_link_ops vlan_link_ops __read_mostly = {
+	.kind		= "vlan",
+	.maxtype	= IFLA_VLAN_MAX,
+	.policy		= vlan_policy,
+	.priv_size	= sizeof(struct vlan_dev_info),
+	.setup		= vlan_setup,
+	.validate	= vlan_validate,
+	.newlink	= vlan_newlink,
+	.changelink	= vlan_changelink,
+	.dellink	= vlan_dellink,
+	.get_size	= vlan_get_size,
+	.fill_info	= vlan_fill_info,
+};
+
+int __init vlan_netlink_init(void)
+{
+	return rtnl_link_register(&vlan_link_ops);
+}
+
+void __exit vlan_netlink_fini(void)
+{
+	rtnl_link_unregister(&vlan_link_ops);
+}
+
+MODULE_ALIAS_RTNL_LINK("vlan");
