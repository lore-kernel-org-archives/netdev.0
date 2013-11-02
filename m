From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 09/11] openvswitch: Widen TCP flags handling.
Date: Sat,  2 Nov 2013 00:43:48 -0700
Message-ID: <1383378230-59624-10-git-send-email-jesse@nicira.com>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:45140 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754648Ab3KBVyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 17:54:14 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so5243556pdj.37
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 14:54:14 -0700 (PDT)
In-Reply-To: <1383378230-59624-1-git-send-email-jesse@nicira.com>
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
 net/openvswitch/datapath.c | 2 +-
 net/openvswitch/flow.c     | 8 +++-----
 net/openvswitch/flow.h     | 2 +-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5bc5a4e..1408adc 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -671,7 +671,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	used = flow->used;
 	stats.n_packets = flow->packet_count;
 	stats.n_bytes = flow->byte_count;
-	tcp_flags = flow->tcp_flags;
+	tcp_flags = (u8)ntohs(flow->tcp_flags);
 	spin_unlock_bh(&flow->lock);
 
 	if (used &&
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 617810f..b73c768 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -58,19 +58,17 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 	return cur_ms - idle_ms;
 }
 
-#define TCP_FLAGS_OFFSET 13
-#define TCP_FLAG_MASK 0x3f
+#define TCP_FLAGS_BE16(tp) (*(__be16 *)&tcp_flag_word(tp) & htons(0x0FFF))
 
 void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
 {
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
 
 	spin_lock(&flow->lock);
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 098fd1d..204e0cc 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -158,7 +158,7 @@ struct sw_flow {
 	unsigned long used;	/* Last used time (in jiffies). */
 	u64 packet_count;	/* Number of packets matched. */
 	u64 byte_count;		/* Number of bytes matched. */
-	u8 tcp_flags;		/* Union of seen TCP flags. */
+	__be16 tcp_flags;	/* Union of seen TCP flags. */
 };
 
 struct arp_eth_header {
-- 
1.8.3.2
