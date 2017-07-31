From: Shaohua Li <shli@kernel.org>
Subject: [PATCH V4 net 2/2] net: fix tcp reset packet flowlabel for ipv6
Date: Mon, 31 Jul 2017 15:19:23 -0700
Message-ID: <373e23f5295ee4cb725109a9e58152451a9fb4cc.1501539150.git.shli@fb.com>
References: <cover.1501539150.git.shli@fb.com>
Cc: Shaohua Li <shli@fb.com>, Eric Dumazet <eric.dumazet@gmail.com>,
        Florent Fourcot <flo@fourcot.fr>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47178 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751599AbdGaWT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 18:19:27 -0400
In-Reply-To: <cover.1501539150.git.shli@fb.com>
In-Reply-To: <cover.1501539150.git.shli@fb.com>
References: <cover.1501539150.git.shli@fb.com>
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
doesn't correctly close tcp connection. The reason is the normal packet
gets the skb->hash from sk->sk_txhash, which is generated randomly.
ip6_make_flowlabel then uses the hash to create a flowlabel. The reset
packet doesn't get assigned a hash, so the flowlabel is calculated with
flowi6.

Since user can't change timewait sock flowlabel, we create a flowlabel
for timewait socket with the random generated hash (sk->sk_txhash), then
use it in reset packet. In this way, the reset packet will have the same
flowlabel as normal packets.

This also fixes the flowlabel issue for reset packet if user configures
flowlabel, which is ignored previously.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Florent Fourcot <flo@fourcot.fr>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/net/ipv6.h       |  9 ++++-----
 net/ipv4/tcp_minisocks.c |  8 +++++++-
 net/ipv6/ip6_gre.c       |  2 +-
 net/ipv6/ip6_output.c    |  4 ++--
 net/ipv6/ip6_tunnel.c    |  2 +-
 net/ipv6/tcp_ipv6.c      | 18 +++++++++++++++++-
 6 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7548367..f8713fd 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -773,10 +773,8 @@ static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
 
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel,
-					struct flowi6 *fl6)
+					struct flowi6 *fl6, u32 hash)
 {
-	u32 hash;
-
 	/* @flowlabel may include more than a flow label, eg, the traffic class.
 	 * Here we want only the flow label value.
 	 */
@@ -788,7 +786,8 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 	     net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
 		return flowlabel;
 
-	hash = skb_get_hash_flowi6(skb, fl6);
+	if (skb)
+		hash = skb_get_hash_flowi6(skb, fl6);
 
 	flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
 
@@ -814,7 +813,7 @@ static inline int ip6_default_np_autolabel(struct net *net)
 static inline void ip6_set_txhash(struct sock *sk) { }
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel,
-					struct flowi6 *fl6)
+					struct flowi6 *fl6, u32 hash)
 {
 	return flowlabel;
 }
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0ff83c1..ac41b25 100644
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
+				flowlabel = ip6_make_flowlabel(
+					sock_net(sk), NULL, 0, np->autoflowlabel,
+					NULL, sk->sk_txhash);
+			tw->tw_flowlabel = be32_to_cpu(flowlabel);
 			tw->tw_ipv6only = sk->sk_ipv6only;
 		}
 #endif
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 67ff2aa..36db44a 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -948,7 +948,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 	ip6_flow_hdr(ipv6h, 0,
 		     ip6_make_flowlabel(dev_net(dev), skb,
 					t->fl.u.ip6.flowlabel, true,
-					&t->fl.u.ip6));
+					&t->fl.u.ip6, 0));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
 	ipv6h->saddr = t->parms.laddr;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 162efba..cefd249 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -230,7 +230,7 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 		hlimit = ip6_dst_hoplimit(dst);
 
 	ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
-						     np->autoflowlabel, fl6));
+						     np->autoflowlabel, fl6, 0));
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
@@ -1702,7 +1702,7 @@ struct sk_buff *__ip6_make_skb(struct sock *sk,
 
 	ip6_flow_hdr(hdr, v6_cork->tclass,
 		     ip6_make_flowlabel(net, skb, fl6->flowlabel,
-					np->autoflowlabel, fl6));
+					np->autoflowlabel, fl6, 0));
 	hdr->hop_limit = v6_cork->hop_limit;
 	hdr->nexthdr = proto;
 	hdr->saddr = fl6->saddr;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 3a0ba2a..9c5d129 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1201,7 +1201,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, dsfield,
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6, 0));
 	ipv6h->hop_limit = hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
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
2.9.3
