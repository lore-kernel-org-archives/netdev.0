From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 11/12] openvswitch: Support programming of flows into hardware
Date: Wed, 28 Sep 2016 14:43:01 +0200
Message-ID: <1475066582-1971-12-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35523 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932124AbcI1MnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:24 -0400
Received: by mail-wm0-f52.google.com with SMTP id l132so234069995wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:23 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The purpose of this prototype is to attempt to further discussion of
how Open vSwitch and similar flows may be programmed into hardware.

The approach taken in this prototype here is to always add flows to
software, the existing behaviour, and program flows into hardware when
possible.  As Open vSwitch datapath flows do not overlap this should be
safe even if some flows are programmed into hardware and some are not.

User-space is provided with the possibility of opting out
by setting the OVS_FLOW_ATTR_HW_REQ attribute of a request to
VS_FLOW_HW_REQ_SKIP_HW. There is scope to add other modes as needed,
for example: skip adding flow to software.

User-space is also provided with feedback on weather a flow has been
programmed into hardware or not via the OVS_FLOW_ATTR_HW_STATUS attribute
of replies.

Overall the intention is to allow the kernel to manage resources,
including flows, and for user-space to have secondary control using
the above mentioned attributes.

Access to hardware, to program flows into hardware, remove them from
hardware and obtain the statistics of flows programmed into hardware is
done via SDOs as per switchdev patches earlier in the patchset which
comprise this prototype. The earlier patches also include an implementation
of the relevant SDOs for the Rocker switch.

Some implementation notes:

* ovs_hw_flow_stats_add should probably update tcp_flags.

  However an implication of that would be that the hardware to which
  offloads is being made a) supports tracking tcp_flags and b) by
  implication parses L4 headers.  If that is a requirement of allowing
  Open vSwitch flows to be programmed into hardware, then so be it. But if
  it is a hard requirement then it may eliminate some hardware options.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/uapi/linux/openvswitch.h |  36 ++++++++
 net/openvswitch/datapath.c       |  73 +++++++++++++++--
 net/openvswitch/flow.c           | 173 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/flow.h           |  59 +++++++++++++
 net/openvswitch/flow_netlink.c   |  42 ++++++++++
 net/openvswitch/flow_netlink.h   |   3 +
 net/openvswitch/vport-netdev.c   |  39 +++++++++
 7 files changed, 420 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 59ed3992c760..96e223a04b09 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -506,6 +506,11 @@ struct ovs_key_ct_labels {
  * @OVS_FLOW_ATTR_UFID_FLAGS: A 32-bit value of OR'd %OVS_UFID_F_*
  * flags that provide alternative semantics for flow installation and
  * retrieval. Optional for all requests.
+ * @OVS_FLOW_ATTR_HW_REQ: A 32-bit value giving a OVS_HW_FLOW_REQ_*.
+ * Present in requests if it would not be OVS_FLOW_HW_REQ_DEFAULT.
+ * @OVS_FLOW_ATTR_HW_STATUS: A 32-bit value giving a OVS_HW_FLOW_STATUS_*.
+ * Ignored in all requests. Present in notifications if it would not be
+ * OVS_FLOW_HW_STATUS_NOT_PRESENT.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_FLOW_* commands.
@@ -524,12 +529,43 @@ enum ovs_flow_attr {
 	OVS_FLOW_ATTR_UFID,      /* Variable length unique flow identifier. */
 	OVS_FLOW_ATTR_UFID_FLAGS,/* u32 of OVS_UFID_F_*. */
 	OVS_FLOW_ATTR_PAD,
+	OVS_FLOW_ATTR_HW_REQ,    /* u32 which is one of OVS_HW_FLOW_REQ_*. */
+	OVS_FLOW_ATTR_HW_STATUS, /* s32 which is one of OVS_HW_FLOW_STATUS_* or
+				  * a negative errno. */
 	__OVS_FLOW_ATTR_MAX
 };
 
 #define OVS_FLOW_ATTR_MAX (__OVS_FLOW_ATTR_MAX - 1)
 
 /**
+ * enum ovs_flow_hw_req - Attributes for requesting programming of a flow into software and hardware.
+ * @OVS_FLOW_HW_REQ_DEFAULT: Use default determined by implementation
+ * @OVS_FLOW_HW_REQ_SKIP_HW: Do not program flow into hardware
+ *
+ * Influence programming of flow into software and hardware.
+ */
+enum ovs_flow_hw_req {
+	OVS_FLOW_HW_REQ_DEFAULT,
+	OVS_FLOW_HW_REQ_SKIP_HW,
+	__OVS_FLOW_HW_MAX,
+};
+
+/**
+ * enum ovs_flow_hw_status - Status of attempt to program flow into hardware
+ * @OVS_FLOW_HW_STATUS_NOT_PRESENT: Flow was not programmed into hardware
+ * because: it was not requested; it was removed from hardware as requested;
+ * programming flows into hardware is not supported by the datapath.
+ * @OVS_FLOW_HW_STATUS_PRESENT: Flow is programmed into hardware
+ *
+ * Status of request of programming programming flow into hardware.
+ */
+enum ovs_flow_hw_status {
+	OVS_FLOW_HW_STATUS_NOT_PRESENT,
+	OVS_FLOW_HW_STATUS_PRESENT,
+	__OVS_FLOW_HW_STATUS_MAX,
+};
+
+/**
  * Omit attributes for notifications.
  *
  * If a datapath request contains an %OVS_UFID_F_OMIT_* flag, then the datapath
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 365d480031d3..2b06acce5ff5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -50,6 +50,7 @@
 #include <net/genetlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/switchdev.h>
 
 #include "datapath.h"
 #include "flow.h"
@@ -762,7 +763,7 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
 }
 
 /* Called with ovs_mutex or RCU read lock. */
-static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
+static int ovs_flow_cmd_fill_stats(struct sw_flow *flow, int dp_ifindex,
 				   struct sk_buff *skb)
 {
 	struct ovs_flow_stats stats;
@@ -770,6 +771,7 @@ static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
 	unsigned long used;
 
 	ovs_flow_stats_get(flow, &stats, &used, &tcp_flags);
+	ovs_hw_flow_stats_add(flow, dp_ifindex, skb, &stats, &used);
 
 	if (used &&
 	    nla_put_u64_64bit(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used),
@@ -829,8 +831,20 @@ static int ovs_flow_cmd_fill_actions(const struct sw_flow *flow,
 	return 0;
 }
 
+static int ovs_hw_flow_put_status(const struct sw_flow *flow,
+				  struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_SWITCHDEV
+       if (flow->hw_flow_present &&
+	   nla_put_s32(skb, OVS_FLOW_ATTR_HW_STATUS,
+		       OVS_FLOW_HW_STATUS_NOT_PRESENT))
+	       return -EMSGSIZE;
+#endif
+       return 0;
+}
+
 /* Called with ovs_mutex or RCU read lock. */
-static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
+static int ovs_flow_cmd_fill_info(struct sw_flow *flow, int dp_ifindex,
 				  struct sk_buff *skb, u32 portid,
 				  u32 seq, u32 flags, u8 cmd, u32 ufid_flags)
 {
@@ -861,7 +875,11 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 			goto error;
 	}
 
-	err = ovs_flow_cmd_fill_stats(flow, skb);
+	err = ovs_flow_cmd_fill_stats(flow, dp_ifindex, skb);
+	if (err)
+		goto error;
+
+	err = ovs_hw_flow_put_status(flow, skb);
 	if (err)
 		goto error;
 
@@ -901,7 +919,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
 }
 
 /* Called with ovs_mutex. */
-static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
+static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
 					       int dp_ifindex,
 					       struct genl_info *info, u8 cmd,
 					       bool always, u32 ufid_flags)
@@ -933,6 +951,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_actions *acts;
 	struct sw_flow_match match;
 	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
+	enum ovs_flow_hw_req hw_req = OVS_FLOW_HW_REQ_DEFAULT;
 	int error;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
@@ -947,6 +966,15 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto error;
 	}
 
+	if (a[OVS_FLOW_ATTR_HW_REQ]) {
+		hw_req = nla_get_u32(a[OVS_FLOW_ATTR_HW_REQ]);
+
+		if (hw_req > OVS_FLOW_HW_REQ_SKIP_HW) {
+			OVS_NLERR(log, "Unsupported hardware flow request for new flow.");
+			goto error;
+		}
+	}
+
 	/* Most of the time we need to allocate a new flow, do it before
 	 * locking.
 	 */
@@ -1012,6 +1040,9 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 			goto err_unlock_ovs;
 		}
 
+		if (hw_req == OVS_FLOW_HW_REQ_DEFAULT)
+			ovs_hw_flow_new(dp, new_flow, match.key_attrs, acts);
+
 		if (unlikely(reply)) {
 			error = ovs_flow_cmd_fill_info(new_flow,
 						       ovs_header->dp_ifindex,
@@ -1036,6 +1067,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 			error = -EEXIST;
 			goto err_unlock_ovs;
 		}
+
 		/* The flow identifier has to be the same for flow updates.
 		 * Look for any overlapping flow.
 		 */
@@ -1050,6 +1082,12 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 				goto err_unlock_ovs;
 			}
 		}
+
+		if (hw_req == OVS_FLOW_HW_REQ_DEFAULT)
+			ovs_hw_flow_set(dp, flow, match.key_attrs, acts);
+		else
+			ovs_hw_flow_del(dp, flow);
+
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
 		rcu_assign_pointer(flow->sf_acts, acts);
@@ -1120,10 +1158,27 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_match match;
 	struct sw_flow_id sfid;
 	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
-	int error = 0;
+	enum ovs_flow_hw_req hw_req = OVS_FLOW_HW_REQ_DEFAULT;
+	int error;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 	bool ufid_present;
 
+	/* Extract key. */
+	error = -EINVAL;
+	if (!a[OVS_FLOW_ATTR_KEY]) {
+		OVS_NLERR(log, "Flow key attribute not present in set flow.");
+		goto error;
+	}
+
+	if (a[OVS_FLOW_ATTR_HW_REQ]) {
+		hw_req = nla_get_u32(a[OVS_FLOW_ATTR_HW_REQ]);
+
+		if (hw_req > OVS_FLOW_HW_REQ_SKIP_HW) {
+			OVS_NLERR(log, "Unsupported hardware flow request for new flow.");
+			goto error;
+		}
+	}
+
 	ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
 	if (a[OVS_FLOW_ATTR_KEY]) {
 		ovs_match_init(&match, &key, true, &mask);
@@ -1207,6 +1262,12 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	/* Clear stats. */
 	if (a[OVS_FLOW_ATTR_CLEAR])
 		ovs_flow_stats_clear(flow);
+
+	if (hw_req == OVS_FLOW_HW_REQ_DEFAULT)
+		ovs_hw_flow_set(dp, flow, match.key_attrs, acts);
+	else
+		ovs_hw_flow_del(dp, flow);
+
 	ovs_unlock();
 
 	if (reply)
@@ -1330,6 +1391,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
+	ovs_hw_flow_del(dp, flow);
+
 	ovs_flow_tbl_remove(&dp->table, flow);
 	ovs_unlock();
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 634cc10d6dee..9b9bf924c489 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -53,6 +53,177 @@
 #include "flow_netlink.h"
 #include "vport.h"
 
+#ifdef CONFIG_NET_SWITCHDEV
+/* Must be called with ovs_mutex or rcu_read_lock. */
+static int ovs_hw_flow(const struct datapath *dp,
+		       struct sw_flow *flow, u64 key_attrs,
+		       const struct sw_flow_actions *acts)
+{
+	struct vport *vport;
+	int err;
+
+	if (!(flow->key_attrs | BIT_ULL(OVS_KEY_ATTR_IN_PORT)))
+		return -ENOTSUPP;
+
+	vport = ovs_lookup_vport(dp, flow->key.phy.in_port);
+	if (!vport)
+		return -EINVAL;
+
+	if (acts) {
+		struct nlattr *actions;
+
+		actions = ovs_switchdev_flow_actions(dp, acts->actions,
+						     acts->actions_len);
+		if (IS_ERR(actions))
+			return PTR_ERR(actions);
+
+		rtnl_lock();
+		err = switchdev_sw_flow_add(vport->dev, &flow->key,
+					    &flow->mask->key, key_attrs,
+					    actions, acts->actions_len);
+		rtnl_unlock();
+		kfree(actions);
+
+		flow->key_attrs = key_attrs;
+	} else {
+		rtnl_lock();
+		err = switchdev_sw_flow_del(vport->dev, &flow->key,
+					    &flow->mask->key, key_attrs);
+		rtnl_unlock();
+	}
+
+	return err;
+}
+
+void ovs_hw_flow_new(const struct datapath *dp, struct sw_flow *flow,
+		     u64 key_attrs, const struct sw_flow_actions *acts)
+{
+	if (ovs_hw_flow(dp, flow, key_attrs, acts) < 0)
+		flow->hw_flow_present = false;
+	else
+		flow->hw_flow_present = true;
+
+	memset(&flow->hw_stats, 0, sizeof flow->hw_stats);
+	memset(&flow->hw_stats_offset, 0, sizeof flow->hw_stats_offset);
+	memset(&flow->hw_stats_base, 0, sizeof flow->hw_stats_base);
+}
+
+void ovs_hw_flow_del(const struct datapath *dp, struct sw_flow *flow)
+{
+	int err;
+
+	if (!flow->hw_flow_present)
+		return;
+
+	err = ovs_hw_flow(dp, flow, flow->key_attrs, NULL);
+	if (err) {
+		net_warn_ratelimited("openvswitch: could not delete hardware flow: %d\n", err);
+		return;
+	}
+
+	flow->hw_flow_present = false;
+
+	flow->hw_stats_base.rx_packets += flow->hw_stats.rx_packets -
+		flow->hw_stats_offset.rx_packets;
+	flow->hw_stats_base.rx_bytes += flow->hw_stats.rx_bytes -
+		flow->hw_stats_offset.rx_bytes;
+
+	/* In case flow is once again programmed into hardware by
+	 * ovs_hw_flow_set()
+	 */
+	memset(&flow->hw_stats, 0, sizeof flow->hw_stats);
+	memset(&flow->hw_stats_offset, 0, sizeof flow->hw_stats_offset);
+}
+
+void ovs_hw_flow_set(const struct datapath *dp, struct sw_flow *flow,
+		     u64 key_attrs, const struct sw_flow_actions *acts)
+{
+	int err;
+
+	/* Try to add flow to hardware.
+	 * This may succeed where even if the flow was previously not added
+	 * to hardware. e.g. because the vport for the output action exists
+	 * but did not earlier.
+	 */
+	err = ovs_hw_flow(dp, flow, key_attrs, acts);
+	if (err < 0) {
+		ovs_hw_flow_del(dp, flow);
+		flow->hw_flow_present = false;
+	} else {
+		flow->hw_flow_present = true;
+	}
+}
+
+/* Must be called with ovs_mutex or rcu_read_lock. */
+/* XXX: ovs_hw_flow_stats_add should probably update tcp_flags.
+ *
+ * However an implication of that would be that the hardware to which
+ * offloads is being made a) supports tracking tcp_flags and b) by
+ * implication parses L4 headers.  If that is a requirement of allowing
+ * Open vSwitch flows to be programmed into hardware, then so be it. But if
+ * it is a hard requirement then it may eliminate some hardware options.
+ */
+int ovs_hw_flow_stats_add(struct sw_flow *flow, int dp_ifindex,
+			  struct sk_buff *skb, struct ovs_flow_stats *stats,
+			  unsigned long *used)
+{
+	struct net *net = sock_net(skb->sk);
+	const struct datapath *dp;
+	struct vport *vport;
+	int err;
+
+	/* Residual statistics from flow programmed into and then
+	 * removed from hardware. */
+	stats->n_packets += flow->hw_stats_base.rx_packets;
+	stats->n_bytes += flow->hw_stats_base.rx_bytes;
+
+	if (!flow->hw_flow_present)
+		return 0;
+
+	dp = get_dp_rcu(net, dp_ifindex);
+	if (!dp)
+		return -EINVAL;
+
+	/* This is not called unless ovs_hw_flow() has previously succeeded
+	 * and thus the flow has an in_port.
+	 */
+	vport = ovs_lookup_vport(dp, flow->key.phy.in_port);
+	if (!vport)
+		return -EINVAL;
+
+	err = switchdev_sw_flow_get_stats(vport->dev, &flow->key,
+					  &flow->mask->key, flow->key_attrs,
+					  &flow->hw_stats);
+	if (err)
+		return err;
+
+	stats->n_packets += flow->hw_stats.rx_packets -
+		flow->hw_stats_offset.rx_packets;
+	stats->n_bytes += flow->hw_stats.rx_bytes -
+		flow->hw_stats_offset.rx_bytes;
+	/* The aim of the condition here is to provide a zero value
+	 * if the flow programmed into hardware has not been used
+	 * since stats were last reset. This is in keeping with
+	 * the treatment of software flows.
+	 */
+	if (flow->hw_stats.last_used > flow->hw_stats_offset.last_used)
+		*used = max(*used, flow->hw_stats.last_used);
+
+	return 0;
+}
+
+/* Called with ovs_mutex. */
+static void ovs_hw_flow_stats_clear(struct sw_flow *flow)
+{
+	flow->hw_stats_offset = flow->hw_stats;
+}
+
+#else /* CONFIG_NET_SWITCHDEV */
+
+static void ovs_hw_flow_stats_clear(struct sw_flow *flow) {}
+
+#endif /* CONFIG_NET_SWITCHDEV */
+
 u64 ovs_flow_used_time(unsigned long flow_jiffies)
 {
 	struct timespec cur_ts;
@@ -181,6 +352,8 @@ void ovs_flow_stats_clear(struct sw_flow *flow)
 			spin_unlock_bh(&stats->lock);
 		}
 	}
+
+	ovs_hw_flow_stats_clear(flow);
 }
 
 static int check_header(struct sk_buff *skb, int len)
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index eb6bb7908e2d..134538dbe518 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -35,8 +35,10 @@
 #include <net/inet_ecn.h>
 #include <net/ip_tunnels.h>
 #include <net/dst_metadata.h>
+#include <net/switchdev.h>
 
 struct sk_buff;
+struct datapath;
 
 /* Store options at the end of the array if they are less than the
  * maximum size. This allows us to get the benefits of variable length
@@ -113,6 +115,20 @@ struct sw_flow {
 	struct sw_flow_id id;
 	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
+#ifdef CONFIG_NET_SWITCHDEV
+	bool hw_flow_present;		  /* true is flow is programmed
+					     into hardware. */
+	/* unused unless flow has been programmed in hardware. */
+	u64 key_attrs;
+	struct switchdev_obj_stats hw_stats; /* stats most recently read
+					      * from hardware, or zeroed if
+					      * not read yet. */
+	struct switchdev_obj_stats hw_stats_offset; /* Set to hw_stats when
+						     * stats are cleared. */
+	struct switchdev_obj_stats hw_stats_base; /* Set to hw_stats when
+						   * flow is removed from
+						   * hardware. */
+#endif
 	struct flow_stats __rcu *stats[]; /* One for each CPU.  First one
 					   * is allocated at flow creation time,
 					   * the rest are allocated on demand
@@ -160,4 +176,47 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 				   struct sk_buff *skb,
 				   struct sw_flow_key *key, bool log);
 
+#ifdef CONFIG_NET_SWITCHDEV
+/* Must be called with ovs_mutex or rcu_read_lock. */
+void ovs_hw_flow_new(const struct datapath *dp,
+		     struct sw_flow *flow, u64 key_attrs,
+		     const struct sw_flow_actions *acts);
+
+/* Must be called with ovs_mutex or rcu_read_lock. */
+void ovs_hw_flow_del(const struct datapath *dp, struct sw_flow *flow);
+
+/* Must be called with ovs_mutex or rcu_read_lock. */
+void ovs_hw_flow_set(const struct datapath *dp, struct sw_flow *flow,
+		     u64 key_attrs, const struct sw_flow_actions *acts);
+
+/* Must be called with ovs_mutex or rcu_read_lock. */
+int ovs_hw_flow_stats_add(struct sw_flow *flow, int dp_ifindex,
+			  struct sk_buff *skb, struct ovs_flow_stats *stats,
+			  unsigned long *used);
+#else /* CONFIG_NET_SWITCHDEV */
+static inline void ovs_hw_flow_new(const struct datapath *dp,
+				   struct sw_flow *flow, u64 key_attrs,
+				   const struct sw_flow_actions *acts)
+{
+	return 0;
+}
+
+static inline void ovs_hw_flow_del(const struct datapath *dp,
+				   struct sw_flow *flow){}
+
+static inline void ovs_hw_flow_set(const struct datapath *dp,
+				   struct sw_flow *flow, u64 key_attrs,
+				   const struct sw_flow_actions *acts)
+{
+	return 0;
+}
+
+static inline int ovs_hw_flow_stats_add(struct sw_flow *flow, int dp_ifindex,
+					struct sk_buff *skb,
+					struct ovs_flow_stats *stats,
+					unsigned long *used)
+{
+	return 0;
+}
+#endif /* CONFIG_NET_SWITCHDEV */
 #endif /* flow.h */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 89c20bdc2cc7..68096f26d6a1 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -50,6 +50,7 @@
 #include <net/vxlan.h>
 
 #include "flow_netlink.h"
+#include "vport.h"
 
 struct ovs_len_tbl {
 	int len;
@@ -2648,3 +2649,44 @@ int ovs_nla_put_actions(const struct nlattr *attr, int len, struct sk_buff *skb)
 
 	return 0;
 }
+
+#ifdef CONFIG_NET_SWITCHDEV
+struct nlattr *ovs_switchdev_flow_actions(const struct datapath *dp,
+					  const struct nlattr *acts, u32 len)
+{
+	struct nlattr *new_acts;
+	struct nlattr *a;
+	int rem, err;
+
+	new_acts = kmalloc(len, GFP_KERNEL);
+	if (!new_acts)
+		return ERR_PTR(-ENOMEM);
+
+	memcpy(new_acts, acts, len);
+
+	for (a = new_acts, rem = len; rem > 0; a = nla_next(a, &rem)) {
+		int type = nla_type(a);
+		struct vport *vport;
+
+		/* Only support output actions at this time */
+		if (type != OVS_ACTION_ATTR_OUTPUT) {
+			err = -ENOTSUPP;
+			goto err;
+		}
+
+		/* Convert ODP ports number to ifindex. */
+		vport = ovs_lookup_vport(dp, nla_get_u32(a));
+		if (!vport) {
+			err = -ENOTSUPP;
+			goto err;
+		}
+		*(u32 *)nla_data(a) = vport->dev->ifindex;
+	}
+
+	return new_acts;
+
+err:
+	kfree(new_acts);
+	return ERR_PTR(err);
+}
+#endif
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 45f9769e5aac..3622a8a10eb4 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -76,4 +76,7 @@ int ovs_nla_put_actions(const struct nlattr *attr,
 void ovs_nla_free_flow_actions(struct sw_flow_actions *);
 void ovs_nla_free_flow_actions_rcu(struct sw_flow_actions *);
 
+struct nlattr *ovs_switchdev_flow_actions(const struct datapath *dp,
+					  const struct nlattr *acts, u32 len);
+
 #endif /* flow_netlink.h */
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4e3972344aa6..78ff0c37df53 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -144,6 +144,44 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	return ovs_netdev_link(vport, parms->name);
 }
 
+
+#ifdef CONFIG_NET_SWITCHDEV
+void ovs_netdev_clear_hw_flows(struct vport *vport)
+{
+	struct net_device *upper_dev;
+	struct table_instance *ti;
+	struct datapath *dp;
+	u32 i;
+
+	upper_dev = netdev_master_upper_dev_get(vport->dev);
+
+	rcu_read_lock();
+	dp = get_dp_rcu(dev_net(upper_dev), upper_dev->ifindex);
+	if (!dp) {
+		net_warn_ratelimited("%s: could not get datapath",
+				     vport->dev->name);
+		goto err;
+	}
+
+	ti = rcu_dereference(dp->table.ti);
+
+	for (i = 0; i < ti->n_buckets; i++) {
+		struct hlist_head *head = flex_array_get(ti->buckets, i);
+		struct sw_flow *flow;
+
+		hlist_for_each_entry_rcu(flow, head,
+					 flow_table.node[ti->node_ver])
+			if (flow->key.phy.in_port == vport->port_no)
+				ovs_hw_flow_del(dp, flow);
+	}
+
+err:
+	rcu_read_unlock();
+}
+#else
+void ovs_netdev_clear_hw_flows(struct netdev *dev) {}
+#endif
+
 static void vport_netdev_free(struct rcu_head *rcu)
 {
 	struct vport *vport = container_of(rcu, struct vport, rcu);
@@ -158,6 +196,7 @@ void ovs_netdev_detach_dev(struct vport *vport)
 	ASSERT_RTNL();
 	vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
 	netdev_rx_handler_unregister(vport->dev);
+	ovs_netdev_clear_hw_flows(vport);
 	netdev_upper_dev_unlink(vport->dev,
 				netdev_master_upper_dev_get(vport->dev));
 	dev_set_promiscuity(vport->dev, -1);
-- 
2.7.0.rc3.207.g0ac5344
