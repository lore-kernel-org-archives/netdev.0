From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 08/17] openvswitch: Per cpu flow stats.
Date: Mon,  6 Jan 2014 16:16:07 -0800
Message-ID: <1389053776-62865-9-git-send-email-jesse@nicira.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

With mega flow implementation ovs flow can be shared between
multiple CPUs which makes stats updates highly contended
operation. This patch uses per-CPU stats in cases where a flow
is likely to be shared (if there is a wildcard in the 5-tuple
and therefore likely to be spread by RSS). In other situations,
it uses the current strategy, saving memory and allocation time.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c     | 50 +++++++---------------
 net/openvswitch/flow.c         | 96 +++++++++++++++++++++++++++++++++++++++---
 net/openvswitch/flow.h         | 29 ++++++++++---
 net/openvswitch/flow_netlink.c | 56 ++++++++++++++++++++++--
 net/openvswitch/flow_netlink.h |  1 +
 net/openvswitch/flow_table.c   | 31 +++++++++++++-
 net/openvswitch/flow_table.h   |  2 +-
 7 files changed, 210 insertions(+), 55 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5da2534..50d7782 100644
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
@@ -459,14 +459,6 @@ out:
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
@@ -505,7 +497,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		packet->protocol = htons(ETH_P_802_2);
 
 	/* Build an sw_flow for sending this packet. */
-	flow = ovs_flow_alloc();
+	flow = ovs_flow_alloc(false);
 	err = PTR_ERR(flow);
 	if (IS_ERR(flow))
 		goto err_kfree_skb;
@@ -641,10 +633,10 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	const int skb_orig_len = skb->len;
 	struct nlattr *start;
 	struct ovs_flow_stats stats;
+	__be16 tcp_flags;
+	unsigned long used;
 	struct ovs_header *ovs_header;
 	struct nlattr *nla;
-	unsigned long used;
-	u8 tcp_flags;
 	int err;
 
 	ovs_header = genlmsg_put(skb, portid, seq, &dp_flow_genl_family, flags, cmd);
@@ -673,24 +665,17 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 
 	nla_nest_end(skb, nla);
 
-	spin_lock_bh(&flow->lock);
-	used = flow->used;
-	stats.n_packets = flow->packet_count;
-	stats.n_bytes = flow->byte_count;
-	tcp_flags = (u8)ntohs(flow->tcp_flags);
-	spin_unlock_bh(&flow->lock);
-
+	ovs_flow_stats_get(flow, &stats, &used, &tcp_flags);
 	if (used &&
 	    nla_put_u64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used)))
 		goto nla_put_failure;
 
 	if (stats.n_packets &&
-	    nla_put(skb, OVS_FLOW_ATTR_STATS,
-		    sizeof(struct ovs_flow_stats), &stats))
+	    nla_put(skb, OVS_FLOW_ATTR_STATS, sizeof(struct ovs_flow_stats), &stats))
 		goto nla_put_failure;
 
-	if (tcp_flags &&
-	    nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS, tcp_flags))
+	if ((u8)ntohs(tcp_flags) &&
+	     nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS, (u8)ntohs(tcp_flags)))
 		goto nla_put_failure;
 
 	/* If OVS_FLOW_ATTR_ACTIONS doesn't fit, skip dumping the actions if
@@ -770,6 +755,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	struct sw_flow_actions *acts = NULL;
 	struct sw_flow_match match;
+	bool exact_5tuple;
 	int error;
 
 	/* Extract key. */
@@ -778,7 +764,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		goto error;
 
 	ovs_match_init(&match, &key, &mask);
-	error = ovs_nla_get_match(&match,
+	error = ovs_nla_get_match(&match, &exact_5tuple,
 				  a[OVS_FLOW_ATTR_KEY], a[OVS_FLOW_ATTR_MASK]);
 	if (error)
 		goto error;
@@ -817,12 +803,11 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			goto err_unlock_ovs;
 
 		/* Allocate flow. */
-		flow = ovs_flow_alloc();
+		flow = ovs_flow_alloc(!exact_5tuple);
 		if (IS_ERR(flow)) {
 			error = PTR_ERR(flow);
 			goto err_unlock_ovs;
 		}
-		clear_stats(flow);
 
 		flow->key = masked_key;
 		flow->unmasked_key = key;
@@ -866,11 +851,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 
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
 
@@ -908,7 +890,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_match_init(&match, &key, NULL);
-	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
+	err = ovs_nla_get_match(&match, NULL, a[OVS_FLOW_ATTR_KEY], NULL);
 	if (err)
 		return err;
 
@@ -962,7 +944,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_match_init(&match, &key, NULL);
-	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
+	err = ovs_nla_get_match(&match, NULL, a[OVS_FLOW_ATTR_KEY], NULL);
 	if (err)
 		goto unlock;
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index b409f52..16f4b46 100644
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
@@ -60,10 +61,16 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 
 #define TCP_FLAGS_BE16(tp) (*(__be16 *)&tcp_flag_word(tp) & htons(0x0FFF))
 
-void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
+void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb)
 {
+	struct flow_stats *stats;
 	__be16 tcp_flags = 0;
 
+	if (!flow->stats.is_percpu)
+		stats = flow->stats.stat;
+	else
+		stats = this_cpu_ptr(flow->stats.cpu_stats);
+
 	if ((flow->key.eth.type == htons(ETH_P_IP) ||
 	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
 	    flow->key.ip.proto == IPPROTO_TCP &&
@@ -71,12 +78,87 @@ void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
 		tcp_flags = TCP_FLAGS_BE16(tcp_hdr(skb));
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
+static void stats_read(struct flow_stats *stats,
+		       struct ovs_flow_stats *ovs_stats,
+		       unsigned long *used, __be16 *tcp_flags)
+{
+	spin_lock(&stats->lock);
+	if (time_after(stats->used, *used))
+		*used = stats->used;
+	*tcp_flags |= stats->tcp_flags;
+	ovs_stats->n_packets += stats->packet_count;
+	ovs_stats->n_bytes += stats->byte_count;
+	spin_unlock(&stats->lock);
+}
+
+void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *ovs_stats,
+			unsigned long *used, __be16 *tcp_flags)
+{
+	int cpu, cur_cpu;
+
+	*used = 0;
+	*tcp_flags = 0;
+	memset(ovs_stats, 0, sizeof(*ovs_stats));
+
+	if (!flow->stats.is_percpu) {
+		stats_read(flow->stats.stat, ovs_stats, used, tcp_flags);
+	} else {
+		cur_cpu = get_cpu();
+		for_each_possible_cpu(cpu) {
+			struct flow_stats *stats;
+
+			if (cpu == cur_cpu)
+				local_bh_disable();
+
+			stats = per_cpu_ptr(flow->stats.cpu_stats, cpu);
+			stats_read(stats, ovs_stats, used, tcp_flags);
+
+			if (cpu == cur_cpu)
+				local_bh_enable();
+		}
+		put_cpu();
+	}
+}
+
+static void stats_reset(struct flow_stats *stats)
+{
+	spin_lock(&stats->lock);
+	stats->used = 0;
+	stats->packet_count = 0;
+	stats->byte_count = 0;
+	stats->tcp_flags = 0;
+	spin_unlock(&stats->lock);
+}
+
+void ovs_flow_stats_clear(struct sw_flow *flow)
+{
+	int cpu, cur_cpu;
+
+	if (!flow->stats.is_percpu) {
+		stats_reset(flow->stats.stat);
+	} else {
+		cur_cpu = get_cpu();
+
+		for_each_possible_cpu(cpu) {
+
+			if (cpu == cur_cpu)
+				local_bh_disable();
+
+			stats_reset(per_cpu_ptr(flow->stats.cpu_stats, cpu));
+
+			if (cpu == cur_cpu)
+				local_bh_enable();
+		}
+		put_cpu();
+	}
 }
 
 static int check_header(struct sk_buff *skb, int len)
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 176406d..2d770e2 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -19,6 +19,7 @@
 #ifndef FLOW_H
 #define FLOW_H 1
 
+#include <linux/cache.h>
 #include <linux/kernel.h>
 #include <linux/netlink.h>
 #include <linux/openvswitch.h>
@@ -146,6 +147,22 @@ struct sw_flow_actions {
 	struct nlattr actions[];
 };
 
+struct flow_stats {
+	u64 packet_count;		/* Number of packets matched. */
+	u64 byte_count;			/* Number of bytes matched. */
+	unsigned long used;		/* Last used time (in jiffies). */
+	spinlock_t lock;		/* Lock for atomic stats update. */
+	__be16 tcp_flags;		/* Union of seen TCP flags. */
+};
+
+struct sw_flow_stats {
+	bool is_percpu;
+	union {
+		struct flow_stats *stat;
+		struct flow_stats __percpu *cpu_stats;
+	};
+};
+
 struct sw_flow {
 	struct rcu_head rcu;
 	struct hlist_node hash_node[2];
@@ -155,12 +172,7 @@ struct sw_flow {
 	struct sw_flow_key unmasked_key;
 	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
-
-	spinlock_t lock;	/* Lock for values below. */
-	unsigned long used;	/* Last used time (in jiffies). */
-	u64 packet_count;	/* Number of packets matched. */
-	u64 byte_count;		/* Number of bytes matched. */
-	__be16 tcp_flags;	/* Union of seen TCP flags. */
+	struct sw_flow_stats stats;
 };
 
 struct arp_eth_header {
@@ -177,7 +189,10 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
-void ovs_flow_used(struct sw_flow *, struct sk_buff *);
+void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb);
+void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *stats,
+			unsigned long *used, __be16 *tcp_flags);
+void ovs_flow_stats_clear(struct sw_flow *flow);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 2bc1bc1..3ccb92f 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -266,6 +266,20 @@ static bool is_all_zero(const u8 *fp, size_t size)
 	return true;
 }
 
+static bool is_all_set(const u8 *fp, size_t size)
+{
+	int i;
+
+	if (!fp)
+		return false;
+
+	for (i = 0; i < size; i++)
+		if (fp[i] != 0xff)
+			return false;
+
+	return true;
+}
+
 static int __parse_flow_nlattrs(const struct nlattr *attr,
 				const struct nlattr *a[],
 				u64 *attrsp, bool nz)
@@ -487,8 +501,9 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	return 0;
 }
 
-static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
-				const struct nlattr **a, bool is_mask)
+static int ovs_key_from_nlattrs(struct sw_flow_match *match,  bool *exact_5tuple,
+				u64 attrs, const struct nlattr **a,
+				bool is_mask)
 {
 	int err;
 	u64 orig_attrs = attrs;
@@ -545,6 +560,11 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
 		SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
 	}
 
+	if (is_mask && exact_5tuple) {
+		if (match->mask->key.eth.type != htons(0xffff))
+			*exact_5tuple = false;
+	}
+
 	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
 		const struct ovs_key_ipv4 *ipv4_key;
 
@@ -567,6 +587,13 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
 		SW_FLOW_KEY_PUT(match, ipv4.addr.dst,
 				ipv4_key->ipv4_dst, is_mask);
 		attrs &= ~(1 << OVS_KEY_ATTR_IPV4);
+
+		if (is_mask && exact_5tuple && *exact_5tuple) {
+			if (ipv4_key->ipv4_proto != 0xff ||
+			    ipv4_key->ipv4_src != htonl(0xffffffff) ||
+			    ipv4_key->ipv4_dst != htonl(0xffffffff))
+				*exact_5tuple = false;
+		}
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_IPV6)) {
@@ -598,6 +625,13 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
 				is_mask);
 
 		attrs &= ~(1 << OVS_KEY_ATTR_IPV6);
+
+		if (is_mask && exact_5tuple && *exact_5tuple) {
+			if (ipv6_key->ipv6_proto != 0xff ||
+			    !is_all_set((u8 *)ipv6_key->ipv6_src, sizeof(match->key->ipv6.addr.src)) ||
+			    !is_all_set((u8 *)ipv6_key->ipv6_dst, sizeof(match->key->ipv6.addr.dst)))
+				*exact_5tuple = false;
+		}
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_ARP)) {
@@ -640,6 +674,11 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
 					tcp_key->tcp_dst, is_mask);
 		}
 		attrs &= ~(1 << OVS_KEY_ATTR_TCP);
+
+		if (is_mask && exact_5tuple && *exact_5tuple &&
+		    (tcp_key->tcp_src != htons(0xffff) ||
+		     tcp_key->tcp_dst != htons(0xffff)))
+			*exact_5tuple = false;
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_TCP_FLAGS)) {
@@ -671,6 +710,11 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
 					udp_key->udp_dst, is_mask);
 		}
 		attrs &= ~(1 << OVS_KEY_ATTR_UDP);
+
+		if (is_mask && exact_5tuple && *exact_5tuple &&
+		    (udp_key->udp_src != htons(0xffff) ||
+		     udp_key->udp_dst != htons(0xffff)))
+			*exact_5tuple = false;
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_SCTP)) {
@@ -756,6 +800,7 @@ static void sw_flow_mask_set(struct sw_flow_mask *mask,
  * attribute specifies the mask field of the wildcarded flow.
  */
 int ovs_nla_get_match(struct sw_flow_match *match,
+		      bool *exact_5tuple,
 		      const struct nlattr *key,
 		      const struct nlattr *mask)
 {
@@ -803,10 +848,13 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 		}
 	}
 
-	err = ovs_key_from_nlattrs(match, key_attrs, a, false);
+	err = ovs_key_from_nlattrs(match, NULL, key_attrs, a, false);
 	if (err)
 		return err;
 
+	if (exact_5tuple)
+		*exact_5tuple = true;
+
 	if (mask) {
 		err = parse_flow_mask_nlattrs(mask, a, &mask_attrs);
 		if (err)
@@ -844,7 +892,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 			}
 		}
 
-		err = ovs_key_from_nlattrs(match, mask_attrs, a, true);
+		err = ovs_key_from_nlattrs(match, exact_5tuple, mask_attrs, a, true);
 		if (err)
 			return err;
 	} else {
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 4401510..b31fbe2 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -45,6 +45,7 @@ int ovs_nla_put_flow(const struct sw_flow_key *,
 int ovs_nla_get_flow_metadata(struct sw_flow *flow,
 			      const struct nlattr *attr);
 int ovs_nla_get_match(struct sw_flow_match *match,
+		      bool *exact_5tuple,
 		      const struct nlattr *,
 		      const struct nlattr *);
 
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 7b9cf2c..299ea8b 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -72,19 +72,42 @@ void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		*d++ = *s++ & *m++;
 }
 
-struct sw_flow *ovs_flow_alloc(void)
+struct sw_flow *ovs_flow_alloc(bool percpu_stats)
 {
 	struct sw_flow *flow;
+	int cpu;
 
 	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
 	if (!flow)
 		return ERR_PTR(-ENOMEM);
 
-	spin_lock_init(&flow->lock);
 	flow->sf_acts = NULL;
 	flow->mask = NULL;
 
+	flow->stats.is_percpu = percpu_stats;
+
+	if (!percpu_stats) {
+		flow->stats.stat = kzalloc(sizeof(*flow->stats.stat), GFP_KERNEL);
+		if (!flow->stats.stat)
+			goto err;
+
+		spin_lock_init(&flow->stats.stat->lock);
+	} else {
+		flow->stats.cpu_stats = alloc_percpu(struct flow_stats);
+		if (!flow->stats.cpu_stats)
+			goto err;
+
+		for_each_possible_cpu(cpu) {
+			struct flow_stats *cpu_stats;
+
+			cpu_stats = per_cpu_ptr(flow->stats.cpu_stats, cpu);
+			spin_lock_init(&cpu_stats->lock);
+		}
+	}
 	return flow;
+err:
+	kfree(flow);
+	return ERR_PTR(-ENOMEM);
 }
 
 int ovs_flow_tbl_count(struct flow_table *table)
@@ -118,6 +141,10 @@ static struct flex_array *alloc_buckets(unsigned int n_buckets)
 static void flow_free(struct sw_flow *flow)
 {
 	kfree((struct sf_flow_acts __force *)flow->sf_acts);
+	if (flow->stats.is_percpu)
+		free_percpu(flow->stats.cpu_stats);
+	else
+		kfree(flow->stats.stat);
 	kmem_cache_free(flow_cache, flow);
 }
 
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index f54aa82..1996e34 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -55,7 +55,7 @@ struct flow_table {
 int ovs_flow_init(void);
 void ovs_flow_exit(void);
 
-struct sw_flow *ovs_flow_alloc(void);
+struct sw_flow *ovs_flow_alloc(bool percpu_stats);
 void ovs_flow_free(struct sw_flow *, bool deferred);
 
 int ovs_flow_tbl_init(struct flow_table *);
-- 
1.8.3.2
