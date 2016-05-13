From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 1/8] net/sched: Enable netdev drivers to update statistics of offloaded actions
Date: Fri, 13 May 2016 12:55:35 +0000
Message-ID: <1463144142-13810-2-git-send-email-amir@vadai.me>
References: <1463144142-13810-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41770 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751555AbcEMM5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 08:57:18 -0400
In-Reply-To: <1463144142-13810-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

Introduce stats_update callback. netdev driver could call it for offloaded
actions to update the basic statistics (packets, bytes and last use).
Since bstats_update() and bstats_cpu_update() use skb as an argument to
get the counters, _bstats_update() and _bstats_cpu_update(), that get
bytes and packets as arguments, were added.

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 include/net/act_api.h     | 12 ++++++++++++
 include/net/sch_generic.h | 20 ++++++++++++++++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 03e322b..2cd9e9b 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -106,6 +106,7 @@ struct tc_action_ops {
 			int bind);
 	int     (*walk)(struct net *, struct sk_buff *,
 			struct netlink_callback *, int, struct tc_action *);
+	void	(*stats_update)(struct tc_action *, u64, u32, u64);
 };
 
 struct tc_action_net {
@@ -178,10 +179,21 @@ int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
 
 #define tc_for_each_action(_a, _exts) \
 	list_for_each_entry(a, &(_exts)->actions, list)
+
+static inline void tcf_action_stats_update(struct tc_action *a, u64 bytes,
+					   u64 packets, u64 lastuse)
+{
+	if (!a->ops->stats_update)
+		return;
+
+	a->ops->stats_update(a, bytes, packets, lastuse);
+}
+
 #else /* CONFIG_NET_CLS_ACT */
 
 #define tc_no_actions(_exts) true
 #define tc_for_each_action(_a, _exts) while (0)
+#define tcf_action_stats_update(a, bytes, packets, lastuse)
 
 #endif /* CONFIG_NET_CLS_ACT */
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 46e55f0..a1fd76c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -527,11 +527,27 @@ static inline bool qdisc_is_percpu_stats(const struct Qdisc *q)
 	return q->flags & TCQ_F_CPUSTATS;
 }
 
+static inline void _bstats_update(struct gnet_stats_basic_packed *bstats,
+				  __u64 bytes, __u32 packets)
+{
+	bstats->bytes += bytes;
+	bstats->packets += packets;
+}
+
 static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
 				 const struct sk_buff *skb)
 {
-	bstats->bytes += qdisc_pkt_len(skb);
-	bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
+	_bstats_update(bstats,
+		       qdisc_pkt_len(skb),
+		       skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1);
+}
+
+static inline void _bstats_cpu_update(struct gnet_stats_basic_cpu *bstats,
+				      __u64 bytes, __u32 packets)
+{
+	u64_stats_update_begin(&bstats->syncp);
+	_bstats_update(&bstats->bstats, bytes, packets);
+	u64_stats_update_end(&bstats->syncp);
 }
 
 static inline void bstats_cpu_update(struct gnet_stats_basic_cpu *bstats,
-- 
2.8.0
