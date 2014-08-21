From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 10/12] openvswitch: add support for datapath hardware offload
Date: Thu, 21 Aug 2014 18:19:03 +0200
Message-ID: <1408637945-10390-11-git-send-email-jiri@resnulli.us>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:45725 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbaHUQTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:19:46 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so8939060wiv.7
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 09:19:44 -0700 (PDT)
In-Reply-To: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benefit from the possibility to work with flows in switch devices and
use the swdev api to offload flow datapath.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/sw_flow.h        |  14 +++
 net/openvswitch/Makefile       |   3 +-
 net/openvswitch/datapath.c     |  33 ++++++
 net/openvswitch/datapath.h     |   3 +
 net/openvswitch/flow_table.c   |   1 +
 net/openvswitch/hw_offload.c   | 235 +++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/hw_offload.h   |  22 ++++
 net/openvswitch/vport-netdev.c |   3 +
 net/openvswitch/vport.h        |   2 +
 9 files changed, 315 insertions(+), 1 deletion(-)
 create mode 100644 net/openvswitch/hw_offload.c
 create mode 100644 net/openvswitch/hw_offload.h

diff --git a/include/linux/sw_flow.h b/include/linux/sw_flow.h
index b622fde..079d065 100644
--- a/include/linux/sw_flow.h
+++ b/include/linux/sw_flow.h
@@ -80,7 +80,21 @@ struct sw_flow_mask {
 	struct sw_flow_key key;
 };
 
+enum sw_flow_action_type {
+	SW_FLOW_ACTION_TYPE_OUTPUT,
+	SW_FLOW_ACTION_TYPE_VLAN_PUSH,
+	SW_FLOW_ACTION_TYPE_VLAN_POP,
+};
+
 struct sw_flow_action {
+	enum sw_flow_action_type type;
+	union {
+		struct net_device *output_dev;
+		struct {
+			__be16 vlan_proto;
+			u16 vlan_tci;
+		} vlan;
+	};
 };
 
 struct sw_flow_actions {
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 3591cb5..5152437 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -13,7 +13,8 @@ openvswitch-y := \
 	flow_table.o \
 	vport.o \
 	vport-internal_dev.o \
-	vport-netdev.o
+	vport-netdev.o \
+	hw_offload.o
 
 ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
 openvswitch-y += vport-vxlan.o
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 75bb07f..3e43e1d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -57,6 +57,7 @@
 #include "flow_netlink.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
+#include "hw_offload.h"
 
 int ovs_net_id __read_mostly;
 
@@ -864,6 +865,9 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 			acts = NULL;
 			goto err_unlock_ovs;
 		}
+		error = ovs_hw_flow_insert(dp, new_flow);
+		if (error)
+			pr_warn("failed to insert flow into hw\n");
 
 		if (unlikely(reply)) {
 			error = ovs_flow_cmd_fill_info(new_flow,
@@ -896,10 +900,18 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 				goto err_unlock_ovs;
 			}
 		}
+		error = ovs_hw_flow_remove(dp, flow);
+		if (error)
+			pr_warn("failed to remove flow from hw\n");
+
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
 		rcu_assign_pointer(flow->sf_acts, acts);
 
+		error = ovs_hw_flow_insert(dp, flow);
+		if (error)
+			pr_warn("failed to insert flow into hw\n");
+
 		if (unlikely(reply)) {
 			error = ovs_flow_cmd_fill_info(flow,
 						       ovs_header->dp_ifindex,
@@ -993,9 +1005,17 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	/* Update actions, if present. */
 	if (likely(acts)) {
+		error = ovs_hw_flow_remove(dp, flow);
+		if (error)
+			pr_warn("failed to remove flow from hw\n");
+
 		old_acts = ovsl_dereference(flow->sf_acts);
 		rcu_assign_pointer(flow->sf_acts, acts);
 
+		error = ovs_hw_flow_insert(dp, flow);
+		if (error)
+			pr_warn("failed to insert flow into hw\n");
+
 		if (unlikely(reply)) {
 			error = ovs_flow_cmd_fill_info(flow,
 						       ovs_header->dp_ifindex,
@@ -1109,6 +1129,9 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	if (unlikely(!a[OVS_FLOW_ATTR_KEY])) {
+		err = ovs_hw_flow_flush(dp);
+		if (err)
+			pr_warn("failed to flush flows from hw\n");
 		err = ovs_flow_tbl_flush(&dp->table);
 		goto unlock;
 	}
@@ -1120,6 +1143,9 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_flow_tbl_remove(&dp->table, flow);
+	err = ovs_hw_flow_remove(dp, flow);
+	if (err)
+		pr_warn("failed to remove flow from hw\n");
 	ovs_unlock();
 
 	reply = ovs_flow_cmd_alloc_info((const struct ovs_flow_actions __force *) flow->sf_acts,
@@ -1368,6 +1394,8 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++)
 		INIT_HLIST_HEAD(&dp->ports[i]);
 
+	INIT_LIST_HEAD(&dp->swdev_rep_list);
+
 	/* Set up our datapath device. */
 	parms.name = nla_data(a[OVS_DP_ATTR_NAME]);
 	parms.type = OVS_VPORT_TYPE_INTERNAL;
@@ -1431,6 +1459,7 @@ err:
 static void __dp_destroy(struct datapath *dp)
 {
 	int i;
+	int err;
 
 	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
 		struct vport *vport;
@@ -1448,6 +1477,10 @@ static void __dp_destroy(struct datapath *dp)
 	 */
 	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 
+	err = ovs_hw_flow_flush(dp);
+	if (err)
+		pr_warn("failed to flush flows from hw\n");
+
 	/* RCU destroy the flow table */
 	ovs_flow_tbl_destroy(&dp->table, true);
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 291f5a0..9dc11a6 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -90,6 +90,9 @@ struct datapath {
 #endif
 
 	u32 user_features;
+
+	/* List of switchdev representative ports */
+	struct list_head swdev_rep_list;
 };
 
 /**
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index e7d9a41..c01e4cb 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -85,6 +85,7 @@ struct ovs_flow *ovs_flow_alloc(void)
 
 	flow->sf_acts = NULL;
 	flow->flow.mask = NULL;
+	flow->flow.actions = NULL;
 	flow->stats_last_writer = NUMA_NO_NODE;
 
 	/* Initialize the default stat node. */
diff --git a/net/openvswitch/hw_offload.c b/net/openvswitch/hw_offload.c
new file mode 100644
index 0000000..edb8a68
--- /dev/null
+++ b/net/openvswitch/hw_offload.c
@@ -0,0 +1,235 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/sw_flow.h>
+#include <linux/switchdev.h>
+
+#include "datapath.h"
+#include "vport-netdev.h"
+
+static int sw_flow_action_create(struct datapath *dp,
+				 struct sw_flow_actions **p_actions,
+				 struct ovs_flow_actions *acts)
+{
+	const struct nlattr *attr = acts->actions;
+	int len = acts->actions_len;
+	const struct nlattr *a;
+	int rem;
+	struct sw_flow_actions *actions;
+	struct sw_flow_action *cur;
+	size_t count = 0;
+	int err;
+
+	for (a = attr, rem = len; rem > 0; a = nla_next(a, &rem))
+		count++;
+
+	actions = kzalloc(sizeof(struct sw_flow_actions) +
+			  sizeof(struct sw_flow_action) * count,
+			  GFP_KERNEL);
+	if (!actions)
+		return -ENOMEM;
+	actions->count = count;
+
+	cur = actions->actions;
+	for (a = attr, rem = len; rem > 0; a = nla_next(a, &rem)) {
+		switch (nla_type(a)) {
+		case OVS_ACTION_ATTR_OUTPUT:
+			{
+				struct vport *vport;
+
+				vport = ovs_vport_ovsl_rcu(dp, nla_get_u32(a));
+				cur->type = SW_FLOW_ACTION_TYPE_OUTPUT;
+				cur->output_dev = vport->ops->get_netdev(vport);
+			}
+			break;
+
+		case OVS_ACTION_ATTR_PUSH_VLAN:
+			{
+				const struct ovs_action_push_vlan *vlan;
+
+				vlan = nla_data(a);
+				cur->type = SW_FLOW_ACTION_TYPE_VLAN_PUSH;
+				cur->vlan.vlan_proto = vlan->vlan_tpid;
+				cur->vlan.vlan_tci = vlan->vlan_tci;
+			}
+			break;
+
+		case OVS_ACTION_ATTR_POP_VLAN:
+			cur->type = SW_FLOW_ACTION_TYPE_VLAN_POP;
+			break;
+
+		default:
+			err = -EOPNOTSUPP;
+			goto errout;
+		}
+		cur++;
+	}
+	*p_actions = actions;
+	return 0;
+
+errout:
+	kfree(actions);
+	return err;
+}
+
+int ovs_hw_flow_insert(struct datapath *dp, struct ovs_flow *flow)
+{
+	struct sw_flow_actions *actions;
+	struct vport *vport;
+	struct net_device *dev;
+	int err;
+
+	ASSERT_OVSL();
+	BUG_ON(flow->flow.actions);
+
+	err = sw_flow_action_create(dp, &actions, flow->sf_acts);
+	if (err)
+		return err;
+	flow->flow.actions = actions;
+
+	list_for_each_entry(vport, &dp->swdev_rep_list, swdev_rep_list) {
+		dev = vport->ops->get_netdev(vport);
+		BUG_ON(!dev);
+		err = swdev_flow_insert(dev, &flow->flow);
+		if (err == -ENODEV) /* out device is not in this switch */
+			continue;
+		if (err)
+			break;
+	}
+
+	if (err) {
+		kfree(actions);
+		flow->flow.actions = NULL;
+	}
+	return err;
+}
+
+int ovs_hw_flow_remove(struct datapath *dp, struct ovs_flow *flow)
+{
+	struct vport *vport;
+	struct net_device *dev;
+	int err = 0;
+
+	ASSERT_OVSL();
+	list_for_each_entry(vport, &dp->swdev_rep_list, swdev_rep_list) {
+		dev = vport->ops->get_netdev(vport);
+		BUG_ON(!dev);
+		err = swdev_flow_remove(dev, &flow->flow);
+		if (err == -ENODEV) /* out device is not in this switch */
+			continue;
+		if (err)
+			break;
+	}
+	kfree(flow->flow.actions);
+	flow->flow.actions = NULL;
+	return err;
+}
+
+int ovs_hw_flow_flush(struct datapath *dp)
+{
+	struct table_instance *ti;
+	int i;
+	int ver;
+	int err;
+
+	ti = ovsl_dereference(dp->table.ti);
+	ver = ti->node_ver;
+
+	for (i = 0; i < ti->n_buckets; i++) {
+		struct ovs_flow *flow;
+		struct hlist_head *head = flex_array_get(ti->buckets, i);
+
+		hlist_for_each_entry(flow, head, hash_node[ver]) {
+			err = ovs_hw_flow_remove(dp, flow);
+			if (err)
+				return err;
+		}
+	}
+	return 0;
+}
+
+static bool __is_vport_in_swdev_rep_list(struct datapath *dp,
+					 struct vport *vport)
+{
+	struct vport *cur_vport;
+
+	list_for_each_entry(cur_vport, &dp->swdev_rep_list, swdev_rep_list) {
+		if (cur_vport == vport)
+			return true;
+	}
+	return false;
+}
+
+static struct vport *__find_vport_by_swdev_id(struct datapath *dp,
+					      struct vport *vport)
+{
+	struct net_device *dev;
+	struct vport *cur_vport;
+	struct netdev_phys_item_id id;
+	struct netdev_phys_item_id cur_id;
+	int i;
+	int err;
+
+	err = swdev_get_id(vport->ops->get_netdev(vport), &id);
+	if (err)
+		return ERR_PTR(err);
+
+	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+		hlist_for_each_entry(cur_vport, &dp->ports[i], dp_hash_node) {
+			if (cur_vport->ops->type != OVS_VPORT_TYPE_NETDEV)
+				continue;
+			if (cur_vport == vport)
+				continue;
+			dev = cur_vport->ops->get_netdev(cur_vport);
+			if (!dev)
+				continue;
+			err = swdev_get_id(dev, &cur_id);
+			if (err)
+				continue;
+			if (netdev_phys_item_ids_match(&id, &cur_id))
+				return cur_vport;
+		}
+	}
+	return ERR_PTR(-ENOENT);
+}
+
+void ovs_hw_port_add(struct datapath *dp, struct vport *vport)
+{
+	struct vport *found_vport;
+
+	ASSERT_OVSL();
+	/* The representative list contains always one port per switch dev id */
+	found_vport = __find_vport_by_swdev_id(dp, vport);
+	if (IS_ERR(found_vport) && PTR_ERR(found_vport) == -ENOENT) {
+		list_add(&vport->swdev_rep_list, &dp->swdev_rep_list);
+		pr_debug("%s added to rep_list\n", vport->ops->get_name(vport));
+	}
+}
+
+void ovs_hw_port_del(struct datapath *dp, struct vport *vport)
+{
+	struct vport *found_vport;
+
+	ASSERT_OVSL();
+	if (!__is_vport_in_swdev_rep_list(dp, vport))
+		return;
+
+	list_del(&vport->swdev_rep_list);
+	pr_debug("%s deleted from rep_list\n", vport->ops->get_name(vport));
+	found_vport = __find_vport_by_swdev_id(dp, vport);
+	if (!IS_ERR(found_vport)) {
+		list_add(&found_vport->swdev_rep_list, &dp->swdev_rep_list);
+		pr_debug("%s added to rep_list instead\n",
+			 found_vport->ops->get_name(found_vport));
+	}
+}
diff --git a/net/openvswitch/hw_offload.h b/net/openvswitch/hw_offload.h
new file mode 100644
index 0000000..83972d7
--- /dev/null
+++ b/net/openvswitch/hw_offload.h
@@ -0,0 +1,22 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef HW_OFFLOAD_H
+#define HW_OFFLOAD_H 1
+
+#include "datapath.h"
+#include "flow.h"
+
+int ovs_hw_flow_insert(struct datapath *dp, struct ovs_flow *flow);
+int ovs_hw_flow_remove(struct datapath *dp, struct ovs_flow *flow);
+int ovs_hw_flow_flush(struct datapath *dp);
+void ovs_hw_port_add(struct datapath *dp, struct vport *vport);
+void ovs_hw_port_del(struct datapath *dp, struct vport *vport);
+
+#endif
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index aaf3d14..c5953de 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -32,6 +32,7 @@
 #include "datapath.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
+#include "hw_offload.h"
 
 struct netdev_vport {
 	struct rcu_head rcu;
@@ -136,6 +137,7 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	dev_set_promiscuity(netdev_vport->dev, 1);
 	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
 	rtnl_unlock();
+	ovs_hw_port_add(vport->dp, vport);
 
 	return vport;
 
@@ -176,6 +178,7 @@ static void netdev_destroy(struct vport *vport)
 {
 	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
 
+	ovs_hw_port_del(vport->dp, vport);
 	rtnl_lock();
 	if (netdev_vport->dev->priv_flags & IFF_OVS_DATAPATH)
 		ovs_netdev_detach_dev(vport);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index f434271..c28604a 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -110,6 +110,8 @@ struct vport {
 
 	spinlock_t stats_lock;
 	struct vport_err_stats err_stats;
+
+	struct list_head swdev_rep_list;
 };
 
 /**
-- 
1.9.3
