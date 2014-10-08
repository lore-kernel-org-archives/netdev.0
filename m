From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC] datapath: offload hooks
Date: Wed,  8 Oct 2014 09:40:51 +0900
Message-ID: <1412728851-32534-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	John Fastabend <john.r.fastabend@intel.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Alexi Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Bert van Leeuwen <bert.vanleeuwen@netronome.com>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:45442 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134AbaJHAlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 20:41:36 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so5847406pdb.7
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 17:41:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert van Leeuwen <bert.vanleeuwen@netronome.com>

Hi,

the purpose of posting this patch is to further the ongoing discussion
on hardware offloads for Open vSwitch. It reflects work at Netronome to
provide such offloads. The intention is for this work to be generic.

There is an accompanying document to this patch which attempts to
describe the problem-space the hooks operate in. The document
is intended to be fairly generic and high level. It is intended
to be a point for ongoing discussion and as such comments via
the Google-docs interface are welcome. It is not intended to be
Netronome specific.

https://docs.google.com/a/netronome.com/document/d/1UtG3xY0xMzIwMG732gaypyR6vxGxinkRrnMLnVS4Zao/edit#

The document at the URL above is indented to supplement the Open vSwitch
Hardware Offload Architecture document, which I believe is collated by
Thomas Graf.

https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit#

This patch is the collective work by a number of engineers at Netronome.

Co-authored-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Signed-off-by: Bert van Leeuwen <bert.vanleeuwen@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
 datapath/Modules.mk       |   2 +
 datapath/datapath.c       |  22 ++++++
 datapath/datapath.h       |   4 +
 datapath/flow.h           |   1 +
 datapath/linux/.gitignore |   1 +
 datapath/offload_ops.c    |  49 ++++++++++++
 datapath/offload_ops.h    | 184 ++++++++++++++++++++++++++++++++++++++++++++++
 datapath/vport.h          |   3 +
 8 files changed, 266 insertions(+)
 create mode 100644 datapath/offload_ops.c
 create mode 100644 datapath/offload_ops.h

diff --git a/datapath/Modules.mk b/datapath/Modules.mk
index 90e158c..3286621 100644
--- a/datapath/Modules.mk
+++ b/datapath/Modules.mk
@@ -7,6 +7,7 @@ build_modules = $(both_modules)	# Modules to build
 dist_modules = $(both_modules)	# Modules to distribute
 
 openvswitch_sources = \
+	offload_ops.c \
 	actions.c \
 	datapath.c \
 	dp_notify.c \
@@ -22,6 +23,7 @@ openvswitch_sources = \
 	vport-vxlan.c
 
 openvswitch_headers = \
+	offload_ops.h \
 	compat.h \
 	datapath.h \
 	flow.h \
diff --git a/datapath/datapath.c b/datapath/datapath.c
index 3ca9716..b598f48 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -61,6 +61,7 @@
 #include "vlan.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
+#include "offload_ops.h"
 
 int ovs_net_id __read_mostly;
 
@@ -651,6 +652,7 @@ static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats,
 		stats->n_lost += local_stats.n_lost;
 		mega_stats->n_mask_hit += local_stats.n_mask_hit;
 	}
+	ovs_offload_dp_stats_get(dp, stats);
 }
 
 static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
@@ -705,6 +707,7 @@ static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
 	unsigned long used;
 
 	ovs_flow_stats_get(flow, &stats, &used, &tcp_flags);
+	ovs_offload_flow_stats_get(flow, &stats, &used, &tcp_flags);
 
 	if (used &&
 	    nla_put_u64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used)))
@@ -906,6 +909,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 			acts = NULL;
 			goto err_unlock_ovs;
 		}
+		ovs_offload_flow_new(new_flow);
 
 		if (unlikely(reply)) {
 			error = ovs_flow_cmd_fill_info(dp, new_flow,
@@ -1059,6 +1063,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 						       OVS_FLOW_CMD_NEW);
 			BUG_ON(error < 0);
 		}
+		ovs_offload_flow_set(flow);
 	} else {
 		/* Could not alloc without acts before locking. */
 		reply = ovs_flow_cmd_build_info(dp, flow,
@@ -1073,6 +1078,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	/* Clear stats. */
 	if (a[OVS_FLOW_ATTR_CLEAR])
 		ovs_flow_stats_clear(flow);
+		ovs_offload_flow_stats_clear(flow);
 	ovs_unlock();
 
 	if (reply)
@@ -1172,6 +1178,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
+	ovs_offload_flow_del(flow);
 	ovs_flow_tbl_remove(&dp->table, flow);
 	ovs_unlock();
 
@@ -1461,6 +1468,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_ports_array;
 	}
 
+	ovs_offload_dp_new(dp);
 	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
 				   info->snd_seq, 0, OVS_DP_CMD_NEW);
 	BUG_ON(err < 0);
@@ -1530,6 +1538,7 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		goto err_unlock_free;
 
+	ovs_offload_dp_del(dp);
 	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
 				   info->snd_seq, 0, OVS_DP_CMD_DEL);
 	BUG_ON(err < 0);
@@ -1563,6 +1572,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_free;
 
 	ovs_dp_change(dp, info->attrs);
+	ovs_offload_dp_set(dp);
 
 	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
 				   info->snd_seq, 0, OVS_DP_CMD_NEW);
@@ -1695,6 +1705,7 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 		goto nla_put_failure;
 
 	ovs_vport_get_stats(vport, &vport_stats);
+	ovs_offload_vport_stats_get(vport, &vport_stats);
 	if (nla_put(skb, OVS_VPORT_ATTR_STATS, sizeof(struct ovs_vport_stats),
 		    &vport_stats))
 		goto nla_put_failure;
@@ -1833,10 +1844,14 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	err = 0;
 	if (a[OVS_VPORT_ATTR_STATS])
 		ovs_vport_set_stats(vport, nla_data(a[OVS_VPORT_ATTR_STATS]));
+		ovs_offload_vport_stats_set(vport,
+					    nla_data(a[OVS_VPORT_ATTR_STATS]));
+
 
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
 	BUG_ON(err < 0);
+	ovs_offload_vport_new(skb, vport, &parms);
 	ovs_unlock();
 
 	ovs_notify(&dp_vport_genl_family, &ovs_dp_vport_multicast_group, reply, info);
@@ -1891,6 +1906,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
 	BUG_ON(err < 0);
+	ovs_offload_vport_set(skb, vport);
 	ovs_unlock();
 
 	ovs_notify(&dp_vport_genl_family, &ovs_dp_vport_multicast_group, reply, info);
@@ -1928,6 +1944,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 				      info->snd_seq, 0, OVS_VPORT_CMD_DEL);
 	BUG_ON(err < 0);
 	ovs_dp_detach_port(vport);
+	ovs_offload_vport_del(skb, vport);
 	ovs_unlock();
 
 	ovs_notify(&dp_vport_genl_family, &ovs_dp_vport_multicast_group, reply, info);
@@ -2149,6 +2166,10 @@ static int __init dp_init(void)
 	if (err < 0)
 		goto error_unreg_notifier;
 
+        err = ovs_offload_init_handler();
+        if (err)
+                goto error;
+
 	return 0;
 
 error_unreg_notifier:
@@ -2165,6 +2186,7 @@ error:
 
 static void dp_cleanup(void)
 {
+	ovs_offload_cleanup_handler();
 	dp_unregister_genl(ARRAY_SIZE(dp_genl_families));
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 	unregister_pernet_device(&ovs_net_ops);
diff --git a/datapath/datapath.h b/datapath/datapath.h
index 651c119..fc54169 100644
--- a/datapath/datapath.h
+++ b/datapath/datapath.h
@@ -68,6 +68,7 @@ struct dp_stats_percpu {
  * @ports: Hash table for ports.  %OVSP_LOCAL port always exists.  Protected by
  * ovs_mutex and RCU.
  * @stats_percpu: Per-CPU datapath statistics.
+ * @offload: Hardware offload callbacks
  * @net: Reference to net namespace.
  *
  * Context: See the comment on locking at the top of datapath.c for additional
@@ -86,6 +87,9 @@ struct datapath {
 	/* Stats. */
 	struct dp_stats_percpu __percpu *stats_percpu;
 
+	/* Hardware offload ptr. */
+	void *offload;
+
 #ifdef CONFIG_NET_NS
 	/* Network namespace ref. */
 	struct net *net;
diff --git a/datapath/flow.h b/datapath/flow.h
index 44ed10d..e50988c 100644
--- a/datapath/flow.h
+++ b/datapath/flow.h
@@ -220,6 +220,7 @@ struct sw_flow {
 	int stats_last_writer;		/* NUMA-node id of the last writer on
 					 * 'stats[0]'.
 					 */
+	void *offload;
 	struct sw_flow_key key;
 	struct sw_flow_key unmasked_key;
 	struct sw_flow_mask *mask;
diff --git a/datapath/linux/.gitignore b/datapath/linux/.gitignore
index be233fc..0ce4663 100644
--- a/datapath/linux/.gitignore
+++ b/datapath/linux/.gitignore
@@ -51,3 +51,4 @@
 /vport.c
 /vxlan.c
 /workqueue.c
+/offload_ops.c
diff --git a/datapath/offload_ops.c b/datapath/offload_ops.c
new file mode 100644
index 0000000..2eda940
--- /dev/null
+++ b/datapath/offload_ops.c
@@ -0,0 +1,49 @@
+#include "offload_ops.h"
+
+struct ovs_offload_ops *offload_ops;
+
+int ovs_offload_register(const struct ovs_offload_ops *new_handler)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload)
+		return -EBUSY;
+	offload = kmalloc(sizeof(*offload), GFP_KERNEL);
+	if (!offload)
+		return -ENOMEM;
+	*offload = *new_handler;
+
+	rcu_assign_pointer(offload_ops, offload);
+	return 0;
+}
+
+EXPORT_SYMBOL(ovs_offload_register);
+
+int ovs_offload_unregister()
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload) {
+		rcu_assign_pointer(offload_ops, NULL);
+		kfree(offload);
+	}
+	return 0;
+}
+
+EXPORT_SYMBOL(ovs_offload_unregister);
+
+int ovs_offload_init_handler(void)
+{
+	rcu_assign_pointer(offload_ops, NULL);
+	return 0;
+}
+
+void ovs_offload_cleanup_handler(void)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload)
+		kfree(offload);
+	rcu_assign_pointer(offload_ops, NULL);
+}
+
diff --git a/datapath/offload_ops.h b/datapath/offload_ops.h
new file mode 100644
index 0000000..9783ba4
--- /dev/null
+++ b/datapath/offload_ops.h
@@ -0,0 +1,184 @@
+#ifndef _OFFLOAD_OPS_H
+#define _OFFLOAD_OPS_H
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+
+#include "datapath.h"
+#include "flow.h"
+
+struct ovs_offload_ops {
+	/* Flow offload functions  */
+	/* Called when a flow entry is added to the flow table */
+	void (*flow_new)(struct sw_flow *);
+	/* Called when a flow entry is modified */
+	void (*flow_set)(struct sw_flow *);
+	/* Called when a flow entry is removed from the flow table */
+	void (*flow_del)(struct sw_flow *);
+	/* Called when flow stats are queried */
+	void (*flow_stats_get)(const struct sw_flow *, struct ovs_flow_stats *,
+			      unsigned long *used, __be16 *tcp_flags);
+	/* Called when flow stats are removed */
+	void (*flow_stats_clear)(struct sw_flow *);
+
+	/* Port offload functions  */
+	/* Called when a vport is added to the datapath */
+	void (*vport_new)(struct sk_buff *, struct vport *,
+			  struct vport_parms *);
+	/* Called when a vport is modified */
+	void (*vport_set)(struct sk_buff *, struct vport *);
+	/* Called when a vport is removed from the datapath */
+	void (*vport_del)(struct sk_buff *, struct vport *);
+	/* Called when vport stats are queried */
+	void (*vport_stats_get)(struct vport *, struct ovs_vport_stats *);
+	/* Called when vport stats are set */
+	void (*vport_stats_set)(struct vport *, struct ovs_vport_stats *);
+
+	/* Datapath offload functions  */
+	/* Called when the datapath is created */
+	void (*dp_new)(struct datapath *);
+	/* Called when the datapath is modified */
+	void (*dp_set)(struct datapath *);
+	/* Called when the datapath is removed */
+	void (*dp_del)(struct datapath *);
+	/* Called when the datapath stats are queried */
+	void (*dp_stats_get)(struct datapath *, struct ovs_dp_stats *);
+};
+
+extern struct ovs_offload_ops *offload_ops;
+
+int ovs_offload_register(const struct ovs_offload_ops *new_handler);
+int ovs_offload_unregister(void);
+int ovs_offload_init_handler(void);
+void ovs_offload_cleanup_handler(void);
+
+/* Wrappers for calling offload function with locking in place */
+/* Flow offload functions */
+static inline void ovs_offload_flow_new(struct sw_flow *flow)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->flow_new)
+		offload->flow_new(flow);
+}
+
+static inline void ovs_offload_flow_set(struct sw_flow *flow)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->flow_set)
+		offload->flow_set(flow);
+}
+
+static inline void ovs_offload_flow_del(struct sw_flow *flow)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->flow_del)
+		offload->flow_del(flow);
+}
+
+static inline void ovs_offload_flow_stats_get(const struct sw_flow *flow,
+					      struct ovs_flow_stats *stats,
+					      unsigned long *used,
+					      __be16 *tcp_flags)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->flow_stats_get)
+		offload->flow_stats_get(flow, stats, used, tcp_flags);
+}
+
+static inline void ovs_offload_flow_stats_clear(struct sw_flow *flow)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->flow_stats_clear)
+		offload->flow_stats_clear(flow);
+}
+
+/* Port offload functions */
+static inline void ovs_offload_vport_new(struct sk_buff *skb,
+					 struct vport *vport,
+					 struct vport_parms *parms)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->vport_new)
+		offload->vport_new(skb, vport, parms);
+}
+
+static inline void ovs_offload_vport_set(struct sk_buff *skb,
+					 struct vport *vport)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->vport_set)
+		offload->vport_set(skb, vport);
+}
+
+static inline void ovs_offload_vport_del(struct sk_buff *skb,
+					 struct vport *vport)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->vport_del)
+		offload->vport_del(skb, vport);
+}
+
+static inline void
+ovs_offload_vport_stats_get(struct vport *vport,
+			    struct ovs_vport_stats *vport_stats)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->vport_stats_get)
+		offload->vport_stats_get(vport, vport_stats);
+}
+
+static inline void
+ovs_offload_vport_stats_set(struct vport *vport,
+			    struct ovs_vport_stats *vport_stats)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->vport_stats_set)
+		offload->vport_stats_set(vport, vport_stats);
+}
+
+/* Datapath offload functions */
+static inline void ovs_offload_dp_new(struct datapath *dp)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->dp_new)
+		offload->dp_new(dp);
+}
+
+static inline void ovs_offload_dp_set(struct datapath *dp)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->dp_set)
+		offload->dp_set(dp);
+}
+
+static inline void ovs_offload_dp_del(struct datapath *dp)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->dp_del)
+		offload->dp_del(dp);
+}
+
+static inline void ovs_offload_dp_stats_get(struct datapath *dp,
+						  struct ovs_dp_stats *stats)
+{
+	struct ovs_offload_ops *offload = rcu_dereference(offload_ops);
+
+	if (offload && offload->dp_stats_get)
+		offload->dp_stats_get(dp, stats);
+}
+
+#endif /* offload_ops.h */
diff --git a/datapath/vport.h b/datapath/vport.h
index 8c3da05..a2f2719 100644
--- a/datapath/vport.h
+++ b/datapath/vport.h
@@ -104,6 +104,7 @@ struct vport_portids {
  * @stats_lock: Protects @err_stats and @offset_stats.
  * @err_stats: Points to error statistics used and maintained by vport
  * @offset_stats: Added to actual statistics as a sop to compatibility with
+ * @offload: Hardware offload callbacks
  * XAPI for Citrix XenServer.  Deprecated.
  */
 struct vport {
@@ -121,6 +122,8 @@ struct vport {
 	spinlock_t stats_lock;
 	struct vport_err_stats err_stats;
 	struct ovs_vport_stats offset_stats;
+
+	void *offload;
 };
 
 /**
-- 
2.1.1
