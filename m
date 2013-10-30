From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 10/11] openvswitch: Widen TCP flags handling.
Date: Tue, 29 Oct 2013 17:22:23 -0700
Message-ID: <1383092544-50599-11-git-send-email-jesse@nicira.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:59841 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752807Ab3J3AWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:45 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so581454pbb.17
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:45 -0700 (PDT)
In-Reply-To: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jrajahalme@nicira.com>

Widen TCP flags handling from 7 bits (uint8_t) to 12 bits (uint16_t).
The kernel interface remains at 8 bits, which makes no functional
difference now, as none of the higher bits is currently of interest
to the userspace.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c | 5 +++--
 net/openvswitch/flow.c     | 8 +++-----
 net/openvswitch/flow.h     | 2 +-
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8c8875b..376b2ad 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -673,8 +673,9 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 			goto nla_put_failure;
 	}
 
-	if (flow_stats.tcp_flags &&
-	    nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS, flow_stats.tcp_flags))
+	if ((u8)ntohs(flow_stats.tcp_flags) &&
+	    nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS,
+		       (u8)ntohs(flow_stats.tcp_flags)))
 		goto nla_put_failure;
 
 	/* If OVS_FLOW_ATTR_ACTIONS doesn't fit, skip dumping the actions if
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2d82995..6ee7a41 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -59,20 +59,18 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 	return cur_ms - idle_ms;
 }
 
-#define TCP_FLAGS_OFFSET 13
-#define TCP_FLAG_MASK 0x3f
+#define TCP_FLAGS_BE16(tp) (*(__be16 *)&tcp_flag_word(tp) & htons(0x0FFF))
 
 void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb)
 {
 	struct sw_flow_stats *stats = &flow->stats[smp_processor_id()];
-	u8 tcp_flags = 0;
+	__be16 tcp_flags = 0;
 
 	if ((flow->key.eth.type == htons(ETH_P_IP) ||
 	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
 	    flow->key.ip.proto == IPPROTO_TCP &&
 	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
-		u8 *tcp = (u8 *)tcp_hdr(skb);
-		tcp_flags = *(tcp + TCP_FLAGS_OFFSET) & TCP_FLAG_MASK;
+		tcp_flags = TCP_FLAGS_BE16(tcp_hdr(skb));
 	}
 
 	spin_lock(&stats->lock);
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index b844252..a5504de 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -150,7 +150,7 @@ struct sw_flow_stats {
 	u64 byte_count;			/* Number of bytes matched. */
 	unsigned long used;		/* Last used time (in jiffies). */
 	spinlock_t lock;		/* Lock for atomic stats update. */
-	u8 tcp_flags;			/* Union of seen TCP flags. */
+	__be16 tcp_flags;		/* Union of seen TCP flags. */
 } ____cacheline_aligned_in_smp;
 
 struct sw_flow {
-- 
1.8.3.2
