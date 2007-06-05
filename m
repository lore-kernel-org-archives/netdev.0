From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 08/08]: Use rtnl_link API
Date: Tue,  5 Jun 2007 16:23:42 +0200 (MEST)
Message-ID: <20070605142341.20372.44516.sendpatchset@localhost.localdomain>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64176 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764505AbXFEOXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:44 -0400
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Use rtnl_link API

---
commit 6e11b791711627a87abfe1bd8c21a4f4d369bca6
tree 5fbe3c1ff51dd87c80748b2793878c076ed57ed7
parent fba4579d0d3c365f1ff5473e905dac68c5ec62f3
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:53:18 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:53:18 +0200

 include/linux/if_link.h   |   25 ++++++
 include/linux/rtnetlink.h |    3 -
 net/8021q/Makefile        |    2 
 net/8021q/vlan.c          |   33 +++++---
 net/8021q/vlan.h          |    5 +
 net/8021q/vlan_netlink.c  |  194 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 248 insertions(+), 14 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 936bd1b..b77e5a8 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -154,4 +154,29 @@ enum
 
 #define IFLA_INFO_MAX	(__IFLA_INFO_MAX - 1)
 
+enum
+{
+	IFLA_VLAN_UNSPEC,
+	IFLA_VLAN_ID,
+	IFLA_VLAN_EGRESS_QOS,
+	IFLA_VLAN_INGRESS_QOS,
+	__IFLA_VLAN_MAX,
+};
+
+#define IFLA_VLAN_MAX	(__IFLA_VLAN_MAX - 1)
+
+struct ifla_vlan_qos_mapping
+{
+	__u32 from;
+	__u32 to;
+};
+
+enum {
+	IFLA_VLAN_QOS_UNSPEC,
+	IFLA_VLAN_QOS_MAPPING,
+	__IFLA_VLAN_QOS_MAX
+};
+
+#define IFLA_VLAN_QOS_MAX	(__IFLA_VLAN_QOS_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6f228c7..dcc0202 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -409,7 +409,8 @@ struct rtgenmsg
 
 #define RTNL_LF_DUMMY		128
 #define RTNL_LF_IFB		129
-#define RTNL_LF_MAX		129
+#define RTNL_LF_VLAN		130
+#define RTNL_LF_MAX		130
 
 #define RTNL_LF_OFFSET		(RTNL_LF_COMPAT_END - RTNL_LF_COMPAT_MAX)
 #define RTNL_LF_NUM		(NPROTO + RTNL_LF_MAX - RTNL_LF_COMPAT_END)
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
index e5405cf..475ca57 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -51,7 +51,6 @@ static char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
 static int vlan_device_event(struct notifier_block *, unsigned long, void *);
 static int vlan_ioctl_handler(void __user *);
-static int unregister_vlan_dev(struct net_device *);
 
 static struct notifier_block vlan_notifier_block = {
 	.notifier_call = vlan_device_event,
@@ -97,15 +96,22 @@ static int __init vlan_proto_init(void)
 
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
@@ -119,7 +125,7 @@ static void __exit vlan_cleanup_devices(void)
 	rtnl_lock();
 	for_each_netdev_safe(dev, nxt) {
 		if (dev->priv_flags & IFF_802_1Q_VLAN)
-			unregister_vlan_dev(dev);
+			vlan_unregister_dev(dev);
 	}
 	rtnl_unlock();
 }
@@ -132,6 +138,7 @@ static void __exit vlan_cleanup_module(void)
 {
 	int i;
 
+	vlan_netlink_fini();
 	vlan_ioctl_set(NULL);
 
 	/* Un-register us from receiving netdevice events */
@@ -230,7 +237,7 @@ static void vlan_rcu_free(struct rcu_head *rcu)
  * last one on the underlying device and the group was destroyed,
  * 0 otherwise.
  */
-static int unregister_vlan_dev(struct net_device *dev)
+int vlan_unregister_dev(struct net_device *dev)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
 	unsigned short vlan_id = VLAN_DEV_INFO(dev)->vlan_id;
@@ -331,7 +338,7 @@ static int vlan_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static void vlan_setup(struct net_device *new_dev)
+void vlan_setup(struct net_device *new_dev)
 {
 	SET_MODULE_OWNER(new_dev);
 
@@ -358,6 +365,8 @@ static void vlan_setup(struct net_device *new_dev)
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
 	new_dev->destructor = free_netdev;
 	new_dev->do_ioctl = vlan_dev_ioctl;
+
+	new_dev->link_family = RTNL_LF_VLAN;
 }
 
 static void vlan_transfer_operstate(const struct net_device *dev, struct net_device *vlandev)
@@ -595,7 +604,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!vlandev)
 				continue;
 
-			if (unregister_vlan_dev(vlandev))
+			if (vlan_unregister_dev(vlandev))
 				/* Group was destroyed? */
 				break;
 		}
@@ -706,7 +715,7 @@ static int vlan_ioctl_handler(void __user *arg)
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		err = unregister_vlan_dev(dev);
+		err = vlan_unregister_dev(dev);
 		break;
 
 	case GET_VLAN_INGRESS_PRIORITY_CMD:
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 47f0c53..351bd55 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -73,7 +73,12 @@ void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
 int vlan_check_device(struct net_device *dev, unsigned short vlan_id);
+int vlan_check_device(struct net_device *dev, unsigned short vlan_id);
+void vlan_setup(struct net_device *dev);
 int vlan_register_dev(struct net_device *dev);
 int vlan_unregister_dev(struct net_device *dev);
 
+int vlan_netlink_init(void);
+void vlan_netlink_fini(void);
+
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
new file mode 100644
index 0000000..32fb195
--- /dev/null
+++ b/net/8021q/vlan_netlink.c
@@ -0,0 +1,194 @@
+/*
+ *	VLAN netlink control interface
+ *
+ * 	Copyright (c) 2007 Patrick McHardy <kaber@trash.net>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
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
+	struct net_device *dev;
+	u16 id;
+	int err;
+
+	if (!tb[IFLA_LINK])
+		return -EINVAL;
+
+	if (!data || !data[IFLA_VLAN_ID])
+		return -EINVAL;
+
+	id = nla_get_u16(data[IFLA_VLAN_ID]);
+	if (id >= VLAN_VID_MASK)
+		return -EINVAL;
+
+	err = vlan_validate_qos_map(data[IFLA_VLAN_INGRESS_QOS]);
+	if (err < 0)
+		return err;
+
+	err = vlan_validate_qos_map(data[IFLA_VLAN_EGRESS_QOS]);
+	if (err < 0)
+		return err;
+
+	dev = __dev_get_by_index(nla_get_u32(tb[IFLA_LINK]));
+	if (!dev)
+		return -ENODEV;
+
+	return vlan_check_device(dev, id);
+}
+
+static int vlan_newlink(struct net_device *dev,
+			struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct ifla_vlan_qos_mapping *m;
+	struct nlattr *attr;
+	int rem;
+
+	vlan->vlan_id  = nla_get_u16(data[IFLA_VLAN_ID]);
+	vlan->real_dev = __dev_get_by_index(nla_get_u32(tb[IFLA_LINK]));
+
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
+	return vlan_register_dev(dev);
+}
+
+static void vlan_dellink(struct net_device *dev)
+{
+	vlan_unregister_dev(dev);
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
+static size_t vlan_get_size(struct net_device *dev)
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+
+	return nla_total_size(2) +	/* IFLA_VLAN_ID */
+	       vlan_qos_map_size(vlan->nr_ingress_mappings) +
+	       vlan_qos_map_size(vlan->nr_egress_mappings);
+}
+
+static int vlan_fill_info(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_priority_tci_mapping *pm;
+	struct ifla_vlan_qos_mapping m;
+	struct nlattr *nest;
+	unsigned int i;
+
+	NLA_PUT_U16(skb, IFLA_VLAN_ID, VLAN_DEV_INFO(dev)->vlan_id);
+
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
+static const struct rtnl_link_ops vlan_link_ops = {
+	.name			= "vlan",
+	.family			= RTNL_LF_VLAN,
+	.maxtype		= IFLA_VLAN_MAX,
+	.policy			= vlan_policy,
+	.dev_priv_size		= sizeof(struct vlan_dev_info),
+	.dev_setup		= vlan_setup,
+	.validate		= vlan_validate,
+	.newlink		= vlan_newlink,
+	.dellink		= vlan_dellink,
+	.get_size		= vlan_get_size,
+	.fill_info		= vlan_fill_info,
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
+MODULE_ALIAS_RTNL_LINK_FAMILY("vlan", RTNL_LF_VLAN);
