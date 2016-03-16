From: Samuel Gauthier <samuel.gauthier@6wind.com>
Subject: [PATCH net-next 1/2] ovs: split ovs_flow_stats_update into skb and stats
Date: Wed, 16 Mar 2016 16:07:51 +0100
Message-ID: <1458140872-22438-2-git-send-email-samuel.gauthier@6wind.com>
References: <1458140872-22438-1-git-send-email-samuel.gauthier@6wind.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Samuel Gauthier <samuel.gauthier@6wind.com>
To: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38661 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbcCPPI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 11:08:28 -0400
In-Reply-To: <1458140872-22438-1-git-send-email-samuel.gauthier@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function to update statistics takes a skbuff as parameter. It
would be handy to have the statistics update part in one function, and
the skbuff part in another one.

The next commit will make use of the new ovs_flow_stats_update
function.

Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
---
 net/openvswitch/datapath.c |  2 +-
 net/openvswitch/flow.c     | 17 ++++++++++++-----
 net/openvswitch/flow.h     |  4 ++--
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0cc66a4e492d..8c6dcffe9b62 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -284,7 +284,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		goto out;
 	}
 
-	ovs_flow_stats_update(flow, key->tp.flags, skb);
+	ovs_flow_stats_update_skb(flow, key->tp.flags, skb);
 	sf_acts = rcu_dereference(flow->sf_acts);
 	ovs_execute_actions(dp, skb, sf_acts, key);
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 0ea128eeeab2..831db351fef9 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -67,12 +67,11 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 
 #define TCP_FLAGS_BE16(tp) (*(__be16 *)&tcp_flag_word(tp) & htons(0x0FFF))
 
-void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
-			   const struct sk_buff *skb)
+static void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
+				  unsigned int count, unsigned int len)
 {
 	struct flow_stats *stats;
 	int node = numa_node_id();
-	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	stats = rcu_dereference(flow->stats[node]);
 
@@ -109,7 +108,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 							      node);
 				if (likely(new_stats)) {
 					new_stats->used = jiffies;
-					new_stats->packet_count = 1;
+					new_stats->packet_count = count;
 					new_stats->byte_count = len;
 					new_stats->tcp_flags = tcp_flags;
 					spin_lock_init(&new_stats->lock);
@@ -124,13 +123,21 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 	}
 
 	stats->used = jiffies;
-	stats->packet_count++;
+	stats->packet_count += count;
 	stats->byte_count += len;
 	stats->tcp_flags |= tcp_flags;
 unlock:
 	spin_unlock(&stats->lock);
 }
 
+void ovs_flow_stats_update_skb(struct sw_flow *flow, __be16 tcp_flags,
+			       const struct sk_buff *skb)
+{
+	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
+
+	ovs_flow_stats_update(flow, tcp_flags, 1, len);
+}
+
 /* Must be called with rcu_read_lock or ovs_mutex. */
 void ovs_flow_stats_get(const struct sw_flow *flow,
 			struct ovs_flow_stats *ovs_stats,
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 1d055c559eaf..51e10c4b1ce6 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -210,8 +210,8 @@ static inline bool ovs_identifier_is_key(const struct sw_flow_id *sfid)
 	return !ovs_identifier_is_ufid(sfid);
 }
 
-void ovs_flow_stats_update(struct sw_flow *, __be16 tcp_flags,
-			   const struct sk_buff *);
+void ovs_flow_stats_update_skb(struct sw_flow *, __be16 tcp_flags,
+			       const struct sk_buff *);
 void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
 			unsigned long *used, __be16 *tcp_flags);
 void ovs_flow_stats_clear(struct sw_flow *);
-- 
2.2.1.62.g3f15098
