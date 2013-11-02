From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 07/11] openvswitch: collect mega flow mask stats
Date: Sat,  2 Nov 2013 00:43:46 -0700
Message-ID: <1383378230-59624-8-git-send-email-jesse@nicira.com>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:51871 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752142Ab3KBVxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 17:53:55 -0400
Received: by mail-pb0-f41.google.com with SMTP id wy17so2468859pbc.14
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 14:53:54 -0700 (PDT)
In-Reply-To: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Collect mega flow mask stats. ovs-dpctl show command can be used to
display them for debugging and performance tuning.

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/uapi/linux/openvswitch.h | 17 ++++++++++++++---
 net/openvswitch/datapath.c       | 38 +++++++++++++++++++++++++++++++-------
 net/openvswitch/datapath.h       |  4 ++++
 net/openvswitch/flow_table.c     | 16 +++++++++++++++-
 net/openvswitch/flow_table.h     |  4 +++-
 5 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index a74d375..2cc4644 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -63,15 +63,18 @@ enum ovs_datapath_cmd {
  * not be sent.
  * @OVS_DP_ATTR_STATS: Statistics about packets that have passed through the
  * datapath.  Always present in notifications.
+ * @OVS_DP_ATTR_MEGAFLOW_STATS: Statistics about mega flow masks usage for the
+ * datapath. Always present in notifications.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_DP_* commands.
  */
 enum ovs_datapath_attr {
 	OVS_DP_ATTR_UNSPEC,
-	OVS_DP_ATTR_NAME,       /* name of dp_ifindex netdev */
-	OVS_DP_ATTR_UPCALL_PID, /* Netlink PID to receive upcalls */
-	OVS_DP_ATTR_STATS,      /* struct ovs_dp_stats */
+	OVS_DP_ATTR_NAME,		/* name of dp_ifindex netdev */
+	OVS_DP_ATTR_UPCALL_PID,		/* Netlink PID to receive upcalls */
+	OVS_DP_ATTR_STATS,		/* struct ovs_dp_stats */
+	OVS_DP_ATTR_MEGAFLOW_STATS,	/* struct ovs_dp_megaflow_stats */
 	__OVS_DP_ATTR_MAX
 };
 
@@ -84,6 +87,14 @@ struct ovs_dp_stats {
 	__u64 n_flows;           /* Number of flows present */
 };
 
+struct ovs_dp_megaflow_stats {
+	__u64 n_mask_hit;	 /* Number of masks used for flow lookups. */
+	__u32 n_masks;		 /* Number of masks for the datapath. */
+	__u32 pad0;		 /* Pad for future expension. */
+	__u64 pad1;		 /* Pad for future expension. */
+	__u64 pad2;		 /* Pad for future expension. */
+};
+
 struct ovs_vport_stats {
 	__u64   rx_packets;		/* total packets received       */
 	__u64   tx_packets;		/* total packets transmitted    */
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index cf27097..5bc5a4e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -221,6 +221,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	struct dp_stats_percpu *stats;
 	struct sw_flow_key key;
 	u64 *stats_counter;
+	u32 n_mask_hit;
 	int error;
 
 	stats = this_cpu_ptr(dp->stats_percpu);
@@ -233,7 +234,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key, &n_mask_hit);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
 
@@ -258,6 +259,7 @@ out:
 	/* Update datapath statistics. */
 	u64_stats_update_begin(&stats->sync);
 	(*stats_counter)++;
+	stats->n_mask_hit += n_mask_hit;
 	u64_stats_update_end(&stats->sync);
 }
 
@@ -563,13 +565,18 @@ static struct genl_ops dp_packet_genl_ops[] = {
 	}
 };
 
-static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats)
+static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats,
+			 struct ovs_dp_megaflow_stats *mega_stats)
 {
 	int i;
 
+	memset(mega_stats, 0, sizeof(*mega_stats));
+
 	stats->n_flows = ovs_flow_tbl_count(&dp->table);
+	mega_stats->n_masks = ovs_flow_tbl_num_masks(&dp->table);
 
 	stats->n_hit = stats->n_missed = stats->n_lost = 0;
+
 	for_each_possible_cpu(i) {
 		const struct dp_stats_percpu *percpu_stats;
 		struct dp_stats_percpu local_stats;
@@ -585,6 +592,7 @@ static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats)
 		stats->n_hit += local_stats.n_hit;
 		stats->n_missed += local_stats.n_missed;
 		stats->n_lost += local_stats.n_lost;
+		mega_stats->n_mask_hit += local_stats.n_mask_hit;
 	}
 }
 
@@ -743,6 +751,14 @@ static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
 	return skb;
 }
 
+static struct sw_flow *__ovs_flow_tbl_lookup(struct flow_table *tbl,
+					      const struct sw_flow_key *key)
+{
+	u32 __always_unused n_mask_hit;
+
+	return ovs_flow_tbl_lookup(tbl, key, &n_mask_hit);
+}
+
 static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -793,7 +809,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_ovs;
 
 	/* Check if this is a duplicate flow */
-	flow = ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow) {
 		/* Bail out if we're not allowed to create a new flow. */
 		error = -ENOENT;
@@ -905,7 +921,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	flow = ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
@@ -953,7 +969,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto unlock;
 
-	flow = ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
@@ -1067,6 +1083,7 @@ static size_t ovs_dp_cmd_msg_size(void)
 
 	msgsize += nla_total_size(IFNAMSIZ);
 	msgsize += nla_total_size(sizeof(struct ovs_dp_stats));
+	msgsize += nla_total_size(sizeof(struct ovs_dp_megaflow_stats));
 
 	return msgsize;
 }
@@ -1076,6 +1093,7 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 {
 	struct ovs_header *ovs_header;
 	struct ovs_dp_stats dp_stats;
+	struct ovs_dp_megaflow_stats dp_megaflow_stats;
 	int err;
 
 	ovs_header = genlmsg_put(skb, portid, seq, &dp_datapath_genl_family,
@@ -1091,8 +1109,14 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 	if (err)
 		goto nla_put_failure;
 
-	get_dp_stats(dp, &dp_stats);
-	if (nla_put(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats), &dp_stats))
+	get_dp_stats(dp, &dp_stats, &dp_megaflow_stats);
+	if (nla_put(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats),
+			&dp_stats))
+		goto nla_put_failure;
+
+	if (nla_put(skb, OVS_DP_ATTR_MEGAFLOW_STATS,
+			sizeof(struct ovs_dp_megaflow_stats),
+			&dp_megaflow_stats))
 		goto nla_put_failure;
 
 	return genlmsg_end(skb, ovs_header);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index acfd4af..d3d14a58 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -46,11 +46,15 @@
  * @n_lost: Number of received packets that had no matching flow in the flow
  * table that could not be sent to userspace (normally due to an overflow in
  * one of the datapath's queues).
+ * @n_mask_hit: Number of masks looked up for flow match.
+ *   @n_mask_hit / (@n_hit + @n_missed)  will be the average masks looked
+ *   up per packet.
  */
 struct dp_stats_percpu {
 	u64 n_hit;
 	u64 n_missed;
 	u64 n_lost;
+	u64 n_mask_hit;
 	struct u64_stats_sync sync;
 };
 
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 036e019..536b4d2 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -430,13 +430,16 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 }
 
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
-				    const struct sw_flow_key *key)
+				    const struct sw_flow_key *key,
+				    u32 *n_mask_hit)
 {
 	struct table_instance *ti = rcu_dereference(tbl->ti);
 	struct sw_flow_mask *mask;
 	struct sw_flow *flow;
 
+	*n_mask_hit = 0;
 	list_for_each_entry_rcu(mask, &tbl->mask_list, list) {
+		(*n_mask_hit)++;
 		flow = masked_flow_lookup(ti, key, mask);
 		if (flow)  /* Found */
 			return flow;
@@ -444,6 +447,17 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 	return NULL;
 }
 
+int ovs_flow_tbl_num_masks(const struct flow_table *table)
+{
+	struct sw_flow_mask *mask;
+	int num = 0;
+
+	list_for_each_entry(mask, &table->mask_list, list)
+		num++;
+
+	return num;
+}
+
 static struct table_instance *table_instance_expand(struct table_instance *ti)
 {
 	return table_instance_rehash(ti, ti->n_buckets * 2);
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index 4db5f78..fbe45d5 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -66,10 +66,12 @@ int ovs_flow_tbl_flush(struct flow_table *flow_table);
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
 			struct sw_flow_mask *mask);
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
+int  ovs_flow_tbl_num_masks(const struct flow_table *table);
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
 				       u32 *bucket, u32 *idx);
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
-				    const struct sw_flow_key *);
+				    const struct sw_flow_key *,
+				    u32 *n_mask_hit);
 
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 			       struct sw_flow_match *match);
-- 
1.8.3.2
