From: Shaohua Li <shli@kernel.org>
Subject: [PATCH v5 net 2/2] net: fix tcp reset packet flowlabel for ipv6
Date: Mon, 14 Aug 2017 19:53:21 -0700
Message-ID: <005e2d619b46ed18e44230e8e94a878ffb6735c5.1502761278.git.shli@fb.com>
References: <cover.1502761278.git.shli@fb.com>
Cc: Kernel-team@fb.com, Shaohua Li <shli@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Florent Fourcot <flo@fourcot.fr>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49852 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750989AbdHOCx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 22:53:26 -0400
In-Reply-To: <cover.1502761278.git.shli@fb.com>
In-Reply-To: <cover.1502761278.git.shli@fb.com>
References: <cover.1502761278.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>

Please see below tcpdump output:
21:00:48.109122 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [S], cksum 0x0529 (incorrect -> 0xf56c), seq 3282214508, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 0,nop,wscale 7], length 0
21:00:48.109381 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [S.], cksum 0x0529 (incorrect -> 0x49ad), seq 1923801573, ack 3282214509, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 2500903437,nop,wscale 7], length 0
21:00:48.109548 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1bdf), seq 1, ack 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
21:00:48.109823 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 62) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [P.], cksum 0x053f (incorrect -> 0xb8b1), seq 1:31, ack 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 30
21:00:48.109910 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [.], cksum 0x0521 (incorrect -> 0x1bc1), seq 1, ack 31, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
21:00:48.110043 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [P.], cksum 0x0539 (incorrect -> 0xb726), seq 1:25, ack 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 24
21:00:48.110173 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba7), seq 31, ack 25, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
21:00:48.110211 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [F.], cksum 0x0521 (incorrect -> 0x1ba7), seq 25, ack 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 0
21:00:48.151099 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba6), seq 31, ack 26, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
21:00:49.110524 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [P.], cksum 0x0539 (incorrect -> 0xb324), seq 31:55, ack 26, win 342, options [nop,nop,TS val 2500904438 ecr 2500903438], length 24
21:00:49.110637 IP6 (flowlabel 0xb34d5, hlim 64, next-header TCP (6) payload length: 20) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [R], cksum 0x0515 (incorrect -> 0x668c), seq 1923801599, win 0, length 0

The tcp reset packet has a different flowlabel, which causes our router
doesn't correctly close tcp connection. We are using flowlabel to do
load balance. Routers in the path maintain connection state. So if flow
label changes, the packet is routed through a different router. In this
case, the old router doesn't get the reset packet to close the tcp
connection.

The reason is the normal packet gets the skb->hash from sk->sk_txhash,
which is generated randomly.  ip6_make_flowlabel then uses the hash to
create a flowlabel. The reset packet doesn't get assigned a hash, so the
flowlabel is calculated with flowi6.

Since user can't change timewait sock flowlabel, we create a fake
flowlabel for timewait socket with the random generated hash
(sk->sk_txhash), then use it in reset packet. In this way, the reset
packet will have the same flowlabel as normal packets.

This also fixes the flowlabel issue for reset packet if user configures
flowlabel, which is ignored previously.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Florent Fourcot <flo@fourcot.fr>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/net/ipv6.h       | 42 +++++++++++++++++++++++++++++++++---------
 net/ipv4/tcp_minisocks.c |  8 +++++++-
 net/ipv6/tcp_ipv6.c      | 18 +++++++++++++++++-
 3 files changed, 57 insertions(+), 11 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7548367..fef395c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -771,6 +771,30 @@ static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
 
 #define IP6_DEFAULT_AUTO_FLOW_LABELS	IP6_AUTO_FLOW_LABEL_OPTOUT
 
+static inline bool ip6_need_make_flowlabel(struct net *net, __be32 flowlabel,
+	bool autolabel)
+{
+	if (flowlabel ||
+	    net->ipv6.sysctl.auto_flowlabels == IP6_AUTO_FLOW_LABEL_OFF ||
+	    (!autolabel &&
+	     net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
+		return false;
+
+	return true;
+}
+
+static inline __be32 __ip6_make_flowlabel(struct net *net, u32 hash)
+{
+	__be32 flowlabel;
+
+	flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
+
+	if (net->ipv6.sysctl.flowlabel_state_ranges)
+		flowlabel |= IPV6_FLOWLABEL_STATELESS_FLAG;
+
+	return flowlabel;
+}
+
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel,
 					struct flowi6 *fl6)
@@ -782,20 +806,20 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 	 */
 	flowlabel &= IPV6_FLOWLABEL_MASK;
 
-	if (flowlabel ||
-	    net->ipv6.sysctl.auto_flowlabels == IP6_AUTO_FLOW_LABEL_OFF ||
-	    (!autolabel &&
-	     net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
+	if (!ip6_need_make_flowlabel(net, flowlabel, autolabel))
 		return flowlabel;
 
 	hash = skb_get_hash_flowi6(skb, fl6);
 
-	flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
-
-	if (net->ipv6.sysctl.flowlabel_state_ranges)
-		flowlabel |= IPV6_FLOWLABEL_STATELESS_FLAG;
+	return __ip6_make_flowlabel(net, hash);
+}
 
-	return flowlabel;
+static inline __be32 ip6_make_flowlabel_from_hash(struct net *net,
+	bool autolabel, u32 hash)
+{
+	if (!ip6_need_make_flowlabel(net, 0, autolabel))
+		return 0;
+	return __ip6_make_flowlabel(net, hash);
 }
 
 static inline int ip6_default_np_autolabel(struct net *net)
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0ff83c1..8e17058 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -276,11 +276,17 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
+			__be32 flowlabel;
 
 			tw->tw_v6_daddr = sk->sk_v6_daddr;
 			tw->tw_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 			tw->tw_tclass = np->tclass;
-			tw->tw_flowlabel = be32_to_cpu(np->flow_label & IPV6_FLOWLABEL_MASK);
+			flowlabel = np->flow_label & IPV6_FLOWLABEL_MASK;
+			if (flowlabel == 0)
+				flowlabel = ip6_make_flowlabel_from_hash(
+					sock_net(sk), np->autoflowlabel,
+					sk->sk_txhash);
+			tw->tw_flowlabel = be32_to_cpu(flowlabel);
 			tw->tw_ipv6only = sk->sk_ipv6only;
 		}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2521690..bb47b6c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -891,6 +891,8 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 	struct sock *sk1 = NULL;
 #endif
 	int oif;
+	u8 tclass = 0;
+	__be32 flowlabel = 0;
 
 	if (th->rst)
 		return;
@@ -939,7 +941,21 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 			  (th->doff << 2);
 
 	oif = sk ? sk->sk_bound_dev_if : 0;
-	tcp_v6_send_response(sk, skb, seq, ack_seq, 0, 0, 0, oif, key, 1, 0, 0);
+	if (sk) {
+		if (sk_fullsock(sk)) {
+			struct ipv6_pinfo *np = inet6_sk(sk);
+
+			tclass = np->tclass;
+			flowlabel = np->flow_label & IPV6_FLOWLABEL_MASK;
+		} else {
+			struct inet_timewait_sock *tw = inet_twsk(sk);
+
+			tclass = tw->tw_tclass;
+			flowlabel = cpu_to_be32(tw->tw_flowlabel);
+		}
+	}
+	tcp_v6_send_response(sk, skb, seq, ack_seq, 0, 0, 0, oif, key, 1,
+		tclass, flowlabel);
 
 #ifdef CONFIG_TCP_MD5SIG
 out:
-- 
2.9.5
