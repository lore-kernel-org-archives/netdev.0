From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next RFC v3 10/10] openvswitch: add support
	for datapath hardware offload
Date: Thu, 17 Apr 2014 14:15:38 +0200
Message-ID: <1397736938-11838-1-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1397736876-11771-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Benefit from the possibility to work with flows in switch devices and
use the swdev api to offload flow datapath.

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/linux/sw_flow.h      |  16 +++-
 net/openvswitch/Makefile     |   3 +-
 net/openvswitch/datapath.c   |  16 +++-
 net/openvswitch/hw_offload.c | 170 +++++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/hw_offload.h |  31 ++++++++
 5 files changed, 231 insertions(+), 5 deletions(-)
 create mode 100644 net/openvswitch/hw_offload.c
 create mode 100644 net/openvswitch/hw_offload.h

diff --git a/include/linux/sw_flow.h b/include/linux/sw_flow.h
index 3bbd5aa..12a24f9 100644
--- a/include/linux/sw_flow.h
+++ b/include/linux/sw_flow.h
@@ -102,7 +102,21 @@ struct sw_flow {
 	struct sw_flow_mask *mask;
 };
 
+enum sw_flow_action_type {
+	SW_FLOW_ACTION_TYPE_OUTPUT,
+	SW_FLOW_ACTION_TYPE_VLAN_PUSH,
+	SW_FLOW_ACTION_TYPE_VLAN_POP,
+};
+
 struct sw_flow_action {
-}
+	enum sw_flow_action_type type;
+	union {
+		struct net_device *output_dev;
+		struct {
+			__be16 vlan_proto;
+			u16 vlan_tci;
+		} vlan;
+	};
+};
 
 #endif /* _LINUX_SW_FLOW_H_ */
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
index 10ffb0a..f1e0792 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -59,6 +59,7 @@
 #include "flow_netlink.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
+#include "hw_offload.h"
 
 int ovs_net_id __read_mostly;
 
@@ -840,13 +841,15 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		flow->flow.key = masked_key;
 		flow->flow.unmasked_key = key;
 		rcu_assign_pointer(flow->sf_acts, acts);
+		acts = NULL;
 
 		/* Put flow in bucket. */
 		error = ovs_flow_tbl_insert(&dp->table, flow, &mask);
-		if (error) {
-			acts = NULL;
+		if (error)
 			goto err_flow_free;
-		}
+		error = ovs_hw_flow_insert(dp, flow, flow->sf_acts);
+		if (error)
+			goto err_flow_tbl_remove;
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 	} else {
@@ -868,6 +871,10 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		if (!ovs_flow_cmp_unmasked_key(flow, &match))
 			goto err_unlock_ovs;
 
+		error = ovs_hw_flow_actions_update(dp, flow, acts);
+		if (error)
+			goto err_unlock_ovs;
+
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
 		rcu_assign_pointer(flow->sf_acts, acts);
@@ -888,6 +895,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			     0, PTR_ERR(reply));
 	return 0;
 
+err_flow_tbl_remove:
+	ovs_flow_tbl_remove(&dp->table, flow);
 err_flow_free:
 	ovs_flow_free(flow, false);
 err_unlock_ovs:
@@ -985,6 +994,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
+	ovs_hw_flow_remove(dp, flow);
 	ovs_flow_tbl_remove(&dp->table, flow);
 
 	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_portid,
diff --git a/net/openvswitch/hw_offload.c b/net/openvswitch/hw_offload.c
new file mode 100644
index 0000000..c4c64d0
--- /dev/null
+++ b/net/openvswitch/hw_offload.c
@@ -0,0 +1,170 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/rcupdate.h>
+#include <linux/netdevice.h>
+#include <linux/sw_flow.h>
+#include <linux/switchdev.h>
+
+#include "datapath.h"
+#include "vport-netdev.h"
+
+static struct net_device *__dp_master(struct datapath *dp)
+{
+	struct vport *local;
+
+	local = ovs_vport_ovsl_rcu(dp, OVSP_LOCAL);
+	BUG_ON(!local);
+	return local->ops->get_netdev(local);
+}
+
+static int sw_flow_action_create(struct datapath *dp,
+				 struct sw_flow_action **p_action,
+				 size_t *p_action_count,
+				 struct sw_flow_actions *acts)
+{
+	const struct nlattr *attr = acts->actions;
+	int len = acts->actions_len;
+	const struct nlattr *a;
+	int rem;
+	struct sw_flow_action *action, *cur;
+	size_t action_count = 0;
+	int err;
+
+	for (a = attr, rem = len; rem > 0; a = nla_next(a, &rem))
+		action_count++;
+
+	action = kzalloc(sizeof(*action) * action_count, GFP_KERNEL);
+	if (!action)
+		return -ENOMEM;
+
+	cur = action;
+	for (a = attr, rem = len; rem > 0; a = nla_next(a, &rem)) {
+		switch (nla_type(a)) {
+		case OVS_ACTION_ATTR_OUTPUT:
+			{
+				struct vport *vport;
+
+				vport = ovs_vport_ovsl_rcu(dp, nla_get_u32(a));
+				if (vport->ops->type != OVS_VPORT_TYPE_NETDEV) {
+					err = -EOPNOTSUPP;
+					goto errout;
+				}
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
+		action++;
+	}
+	*p_action = action;
+	*p_action_count = action_count;
+	return 0;
+
+errout:
+	kfree(action);
+	return err;
+}
+
+int ovs_hw_flow_insert(struct datapath *dp, struct ovs_flow *flow,
+		       struct sw_flow_actions *acts)
+{
+	struct list_head *iter;
+	struct net_device *dev;
+	struct sw_flow_action *action;
+	size_t action_count;
+	int err;
+
+	err = sw_flow_action_create(dp, &action, &action_count, acts);
+	if (err)
+		return err;
+
+	rcu_read_lock();
+	netdev_for_each_all_lower_dev_rcu(__dp_master(dp), dev, iter) {
+		err = swdev_flow_insert(dev, &flow->flow);
+		if (err && err != -EOPNOTSUPP)
+			break;
+		err = swdev_flow_action_set(dev, &flow->flow,
+					    action, action_count);
+		if (err && err != -EOPNOTSUPP)
+			break;
+	}
+	rcu_read_unlock();
+
+	kfree(action);
+
+	return err;
+}
+
+void ovs_hw_flow_remove(struct datapath *dp, struct ovs_flow *flow)
+{
+	struct list_head *iter;
+	struct net_device *dev;
+
+	rcu_read_lock();
+	netdev_for_each_all_lower_dev_rcu(__dp_master(dp), dev, iter)
+		swdev_flow_remove(dev, &flow->flow);
+	rcu_read_unlock();
+}
+
+int ovs_hw_flow_actions_update(struct datapath *dp, struct ovs_flow *flow,
+			       struct sw_flow_actions *acts)
+{
+	struct list_head *iter;
+	struct net_device *dev;
+	struct sw_flow_action *action;
+	size_t action_count;
+	int err;
+
+	err = sw_flow_action_create(dp, &action, &action_count, acts);
+	if (err)
+		return err;
+
+	rcu_read_lock();
+	netdev_for_each_all_lower_dev_rcu(__dp_master(dp), dev, iter) {
+		err = swdev_flow_action_set(dev, &flow->flow,
+					    action, action_count);
+		if (err && err != -EOPNOTSUPP)
+			break;
+	}
+	rcu_read_unlock();
+
+	kfree(action);
+
+	return err;
+}
diff --git a/net/openvswitch/hw_offload.h b/net/openvswitch/hw_offload.h
new file mode 100644
index 0000000..7ecb60f
--- /dev/null
+++ b/net/openvswitch/hw_offload.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef HW_OFFLOAD_H
+#define HW_OFFLOAD_H 1
+
+#include "datapath.h"
+#include "flow.h"
+
+int ovs_hw_flow_insert(struct datapath *dp, struct ovs_flow *flow,
+		       struct sw_flow_actions *acts);
+void ovs_hw_flow_remove(struct datapath *dp, struct ovs_flow *flow);
+int ovs_hw_flow_actions_update(struct datapath *dp, struct ovs_flow *flow,
+			       struct sw_flow_actions *acts);
+
+#endif
-- 
1.9.0
