From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 08/11] openvswitch: Per cpu flow stats.
Date: Tue, 29 Oct 2013 17:22:21 -0700
Message-ID: <1383092544-50599-9-git-send-email-jesse@nicira.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:37091 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752807Ab3J3AWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:43 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so125458pab.0
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:42 -0700 (PDT)
In-Reply-To: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

With mega flow implementation ovs flow can be shared between
multiple CPUs which makes stats updates highly contended
operation. Following patch allocates separate stats for each
CPU to make stats update scalable.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c   | 54 +++++++++++++----------------------
 net/openvswitch/flow.c       | 68 +++++++++++++++++++++++++++++++++++++++-----
 net/openvswitch/flow.h       | 20 ++++++++-----
 net/openvswitch/flow_table.c | 14 +++++++--
 4 files changed, 105 insertions(+), 51 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5bc5a4e..8c8875b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -251,9 +251,9 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	OVS_CB(skb)->flow = flow;
 	OVS_CB(skb)->pkt_key = &key;
 
-	stats_counter = &stats->n_hit;
-	ovs_flow_used(OVS_CB(skb)->flow, skb);
+	ovs_flow_stats_update(OVS_CB(skb)->flow, skb);
 	ovs_execute_actions(dp, skb);
+	stats_counter = &stats->n_hit;
 
 out:
 	/* Update datapath statistics. */
@@ -453,14 +453,6 @@ out:
 	return err;
 }
 
-static void clear_stats(struct sw_flow *flow)
-{
-	flow->used = 0;
-	flow->tcp_flags = 0;
-	flow->packet_count = 0;
-	flow->byte_count = 0;
-}
-
 static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 {
 	struct ovs_header *ovs_header = info->userhdr;
@@ -634,11 +626,9 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 {
 	const int skb_orig_len = skb->len;
 	struct nlattr *start;
-	struct ovs_flow_stats stats;
+	struct sw_flow_stats flow_stats;
 	struct ovs_header *ovs_header;
 	struct nlattr *nla;
-	unsigned long used;
-	u8 tcp_flags;
 	int err;
 
 	ovs_header = genlmsg_put(skb, portid, seq, &dp_flow_genl_family, flags, cmd);
@@ -667,24 +657,24 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 
 	nla_nest_end(skb, nla);
 
-	spin_lock_bh(&flow->lock);
-	used = flow->used;
-	stats.n_packets = flow->packet_count;
-	stats.n_bytes = flow->byte_count;
-	tcp_flags = flow->tcp_flags;
-	spin_unlock_bh(&flow->lock);
-
-	if (used &&
-	    nla_put_u64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used)))
+	ovs_flow_stats_get(flow, &flow_stats);
+	if (flow_stats.used &&
+	    nla_put_u64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(flow_stats.used)))
 		goto nla_put_failure;
 
-	if (stats.n_packets &&
-	    nla_put(skb, OVS_FLOW_ATTR_STATS,
-		    sizeof(struct ovs_flow_stats), &stats))
-		goto nla_put_failure;
+	if (flow_stats.packet_count) {
+		struct ovs_flow_stats stats = {
+			.n_packets = flow_stats.packet_count,
+			.n_bytes = flow_stats.byte_count,
+		};
 
-	if (tcp_flags &&
-	    nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS, tcp_flags))
+		if (nla_put(skb, OVS_FLOW_ATTR_STATS,
+			    sizeof(struct ovs_flow_stats), &stats))
+			goto nla_put_failure;
+	}
+
+	if (flow_stats.tcp_flags &&
+	    nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS, flow_stats.tcp_flags))
 		goto nla_put_failure;
 
 	/* If OVS_FLOW_ATTR_ACTIONS doesn't fit, skip dumping the actions if
@@ -822,7 +812,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			error = PTR_ERR(flow);
 			goto err_unlock_ovs;
 		}
-		clear_stats(flow);
 
 		flow->key = masked_key;
 		flow->unmasked_key = key;
@@ -868,11 +857,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 					       info->snd_seq, OVS_FLOW_CMD_NEW);
 
 		/* Clear stats. */
-		if (a[OVS_FLOW_ATTR_CLEAR]) {
-			spin_lock_bh(&flow->lock);
-			clear_stats(flow);
-			spin_unlock_bh(&flow->lock);
-		}
+		if (a[OVS_FLOW_ATTR_CLEAR])
+			ovs_flow_stats_clear(flow);
 	}
 	ovs_unlock();
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 617810f..2d82995 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -35,6 +35,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/sctp.h>
+#include <linux/smp.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/icmp.h>
@@ -61,8 +62,9 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 #define TCP_FLAGS_OFFSET 13
 #define TCP_FLAG_MASK 0x3f
 
-void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
+void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb)
 {
+	struct sw_flow_stats *stats = &flow->stats[smp_processor_id()];
 	u8 tcp_flags = 0;
 
 	if ((flow->key.eth.type == htons(ETH_P_IP) ||
@@ -73,12 +75,64 @@ void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
 		tcp_flags = *(tcp + TCP_FLAGS_OFFSET) & TCP_FLAG_MASK;
 	}
 
-	spin_lock(&flow->lock);
-	flow->used = jiffies;
-	flow->packet_count++;
-	flow->byte_count += skb->len;
-	flow->tcp_flags |= tcp_flags;
-	spin_unlock(&flow->lock);
+	spin_lock(&stats->lock);
+	stats->used = jiffies;
+	stats->packet_count++;
+	stats->byte_count += skb->len;
+	stats->tcp_flags |= tcp_flags;
+	spin_unlock(&stats->lock);
+}
+
+void ovs_flow_stats_get(struct sw_flow *flow, struct sw_flow_stats *res)
+{
+	int cpu, cur_cpu;
+
+	memset(res, 0, sizeof(*res));
+
+	cur_cpu = get_cpu();
+	for_each_possible_cpu(cpu) {
+		struct sw_flow_stats *stats = &flow->stats[cpu];
+
+		if (cpu == cur_cpu)
+			local_bh_disable();
+
+		spin_lock(&stats->lock);
+		if (time_after(stats->used, res->used))
+			res->used = stats->used;
+		res->packet_count += stats->packet_count;
+		res->byte_count += stats->byte_count;
+		res->tcp_flags |= stats->tcp_flags;
+		spin_unlock(&stats->lock);
+
+		if (cpu == cur_cpu)
+			local_bh_enable();
+
+	}
+	put_cpu();
+}
+
+void ovs_flow_stats_clear(struct sw_flow *flow)
+{
+	int cpu, cur_cpu;
+
+	cur_cpu = get_cpu();
+	for_each_possible_cpu(cpu) {
+		struct sw_flow_stats *stats = &flow->stats[cpu];
+
+		if (cpu == cur_cpu)
+			local_bh_disable();
+
+		spin_lock(&stats->lock);
+		stats->used = 0;
+		stats->packet_count = 0;
+		stats->byte_count = 0;
+		stats->tcp_flags = 0;
+		spin_unlock(&stats->lock);
+
+		if (cpu == cur_cpu)
+			local_bh_enable();
+	}
+	put_cpu();
 }
 
 static int check_header(struct sk_buff *skb, int len)
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 098fd1d..b844252 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -19,6 +19,7 @@
 #ifndef FLOW_H
 #define FLOW_H 1
 
+#include <linux/cache.h>
 #include <linux/kernel.h>
 #include <linux/netlink.h>
 #include <linux/openvswitch.h>
@@ -144,6 +145,14 @@ struct sw_flow_actions {
 	struct nlattr actions[];
 };
 
+struct sw_flow_stats {
+	u64 packet_count;		/* Number of packets matched. */
+	u64 byte_count;			/* Number of bytes matched. */
+	unsigned long used;		/* Last used time (in jiffies). */
+	spinlock_t lock;		/* Lock for atomic stats update. */
+	u8 tcp_flags;			/* Union of seen TCP flags. */
+} ____cacheline_aligned_in_smp;
+
 struct sw_flow {
 	struct rcu_head rcu;
 	struct hlist_node hash_node[2];
@@ -153,12 +162,7 @@ struct sw_flow {
 	struct sw_flow_key unmasked_key;
 	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
-
-	spinlock_t lock;	/* Lock for values below. */
-	unsigned long used;	/* Last used time (in jiffies). */
-	u64 packet_count;	/* Number of packets matched. */
-	u64 byte_count;		/* Number of bytes matched. */
-	u8 tcp_flags;		/* Union of seen TCP flags. */
+	struct sw_flow_stats stats[];
 };
 
 struct arp_eth_header {
@@ -175,7 +179,9 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
-void ovs_flow_used(struct sw_flow *, struct sk_buff *);
+void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb);
+void ovs_flow_stats_get(struct sw_flow *flow, struct sw_flow_stats *res);
+void ovs_flow_stats_clear(struct sw_flow *flow);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 536b4d2..feb1b9b 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -75,15 +75,19 @@ void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 struct sw_flow *ovs_flow_alloc(void)
 {
 	struct sw_flow *flow;
+	int cpu;
 
 	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
 	if (!flow)
 		return ERR_PTR(-ENOMEM);
 
-	spin_lock_init(&flow->lock);
 	flow->sf_acts = NULL;
 	flow->mask = NULL;
 
+	memset(flow->stats, 0, num_possible_cpus() * sizeof(struct sw_flow_stats));
+	for_each_possible_cpu(cpu)
+		spin_lock_init(&flow->stats[cpu].lock);
+
 	return flow;
 }
 
@@ -574,11 +578,15 @@ int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
  * Returns zero if successful or a negative error code. */
 int ovs_flow_init(void)
 {
+	int flow_size;
+
 	BUILD_BUG_ON(__alignof__(struct sw_flow_key) % __alignof__(long));
 	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
 
-	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
-					0, NULL);
+	flow_size = sizeof(struct sw_flow) +
+		    (num_possible_cpus() * sizeof(struct sw_flow_stats));
+
+	flow_cache = kmem_cache_create("sw_flow", flow_size, 0, 0, NULL);
 	if (flow_cache == NULL)
 		return -ENOMEM;
 
-- 
1.8.3.2
