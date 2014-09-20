From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 2/5] net: tcp: add flag for ca to indicate that ECN is required
Date: Sat, 20 Sep 2014 23:29:19 +0200
Message-ID: <1411248562-26581-3-git-send-email-fw@strlen.de>
References: <1411248562-26581-1-git-send-email-fw@strlen.de>
Cc: hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	glenn.judd@morganstanley.com, dborkman@redhat.com,
	netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38435 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754764AbaITV3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:29:47 -0400
In-Reply-To: <1411248562-26581-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

This patch adds a flag to TCP congestion algorithms that allows
for requesting to mark IPv4/IPv6 sockets with transport as ECN
capable, that is, ECT(0), when required by a congestion algorithm.

It is currently used and needed in DataCenter TCP (DCTCP), as it
requires both peers to assert ECT on all IP packets sent - it
uses ECN feedback (i.e. CE, Congestion Encountered information)
from switches inside the data center to derive feedback to the
end hosts.

Therefore, simply add a new flag to icsk_ca_ops. Note that DCTCP's
algorithm/behaviour slightly diverges from RFC3168, therefore this
is only (!) enabled iff the assigned congestion control ops module
has requested this. By that, we can tightly couple this logic really
only to the provided congestion control ops.

Joint work with Florian Westphal and Glenn Judd.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
---
 v1->v2:
  - Update stale comment wrt. DCTCP ECN usage
  - Don't call INET_ECN_xmit for every packet

 include/net/tcp.h     | 61 +++++++++++++++++++++++++++++++++++++--------------
 net/ipv4/tcp_input.c  |  2 +-
 net/ipv4/tcp_output.c | 25 +++++++++++++++------
 3 files changed, 63 insertions(+), 25 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1c75356..82d012e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -724,23 +724,6 @@ struct tcp_skb_cb {
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
 
-/* RFC3168 : 6.1.1 SYN packets must not have ECT/ECN bits set
- *
- * If we receive a SYN packet with these bits set, it means a network is
- * playing bad games with TOS bits. In order to avoid possible false congestion
- * notifications, we disable TCP ECN negociation.
- */
-static inline void
-TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
-		struct net *net)
-{
-	const struct tcphdr *th = tcp_hdr(skb);
-
-	if (net->ipv4.sysctl_tcp_ecn && th->ece && th->cwr &&
-	    INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield))
-		inet_rsk(req)->ecn_ok = 1;
-}
-
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
  */
@@ -772,7 +755,10 @@ enum tcp_ca_event {
 #define TCP_CA_MAX	128
 #define TCP_CA_BUF_MAX	(TCP_CA_NAME_MAX*TCP_CA_MAX)
 
+/* Algorithm can be set on socket without CAP_NET_ADMIN privileges */
 #define TCP_CONG_NON_RESTRICTED 0x1
+/* Requires ECN/ECT set on all packets */
+#define TCP_CONG_NEEDS_ECN	0x2
 
 struct tcp_congestion_ops {
 	struct list_head	list;
@@ -821,6 +807,13 @@ u32 tcp_reno_ssthresh(struct sock *sk);
 void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
 extern struct tcp_congestion_ops tcp_reno;
 
+static inline bool tcp_ca_needs_ecn(const struct sock *sk)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	return icsk->icsk_ca_ops->flags & TCP_CONG_NEEDS_ECN;
+}
+
 static inline void tcp_set_ca_state(struct sock *sk, const u8 ca_state)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -838,6 +831,40 @@ static inline void tcp_ca_event(struct sock *sk, const enum tcp_ca_event event)
 		icsk->icsk_ca_ops->cwnd_event(sk, event);
 }
 
+/* RFC3168 : 6.1.1 SYN packets must not have ECT/ECN bits set
+ *
+ * If we receive a SYN packet with these bits set, it means a
+ * network is playing bad games with TOS bits. In order to
+ * avoid possible false congestion notifications, we disable
+ * TCP ECN negociation.
+ *
+ * Exception: tcp_ca wants ECN. This is required for DCTCP
+ * congestion control; it requires setting ECT on all packets,
+ * including SYN. We inverse the test in this case: If our
+ * local socket wants ECN, but peer only set ece/cwr (but not
+ * ECT in IP header) its probably a non-DCTCP aware sender.
+ */
+static inline void
+TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
+		       const struct sock *listen_sk)
+{
+	const struct tcphdr *th = tcp_hdr(skb);
+	const struct net *net = sock_net(listen_sk);
+	bool th_ecn = th->ece && th->cwr;
+	bool ect, need_ecn;
+
+	if (!th_ecn)
+		return;
+
+	ect = !INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield);
+	need_ecn = tcp_ca_needs_ecn(listen_sk);
+
+	if (!ect && !need_ecn && net->ipv4.sysctl_tcp_ecn)
+		inet_rsk(req)->ecn_ok = 1;
+	else if (ect && need_ecn)
+		inet_rsk(req)->ecn_ok = 1;
+}
+
 /* These functions determine how the current flow behaves in respect of SACK
  * handling. SACK is negotiated with the peer, and therefore it can vary
  * between different flows.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ea92f23..0af12a4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5944,7 +5944,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		goto drop_and_free;
 
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb, sock_net(sk));
+		TCP_ECN_create_request(req, skb, sk);
 
 	if (want_cookie) {
 		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7f1280d..3a0ef04 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -318,11 +318,15 @@ static u16 tcp_select_window(struct sock *sk)
 }
 
 /* Packet ECN state for a SYN-ACK */
-static inline void TCP_ECN_send_synack(const struct tcp_sock *tp, struct sk_buff *skb)
+static inline void TCP_ECN_send_synack(struct sock *sk, struct sk_buff *skb)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
+
 	TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_CWR;
 	if (!(tp->ecn_flags & TCP_ECN_OK))
 		TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_ECE;
+	else if (tcp_ca_needs_ecn(sk))
+		INET_ECN_xmit(sk);
 }
 
 /* Packet ECN state for a SYN.  */
@@ -331,17 +335,24 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->ecn_flags = 0;
-	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1) {
+	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
+	    tcp_ca_needs_ecn(sk)) {
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
+		if (tcp_ca_needs_ecn(sk))
+			INET_ECN_xmit(sk);
 	}
 }
 
 static __inline__ void
-TCP_ECN_make_synack(const struct request_sock *req, struct tcphdr *th)
+TCP_ECN_make_synack(const struct request_sock *req, struct tcphdr *th,
+		    struct sock *sk)
 {
-	if (inet_rsk(req)->ecn_ok)
+	if (inet_rsk(req)->ecn_ok) {
 		th->ece = 1;
+		if (tcp_ca_needs_ecn(sk))
+			INET_ECN_xmit(sk);
+	}
 }
 
 /* Set up ECN state for a packet on a ESTABLISHED socket that is about to
@@ -362,7 +373,7 @@ static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
 				tcp_hdr(skb)->cwr = 1;
 				skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 			}
-		} else {
+		} else if (!tcp_ca_needs_ecn(sk)) {
 			/* ACK or retransmitted segment: clear ECT|CE */
 			INET_ECN_dontxmit(sk);
 		}
@@ -2781,7 +2792,7 @@ int tcp_send_synack(struct sock *sk)
 		}
 
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ACK;
-		TCP_ECN_send_synack(tcp_sk(sk), skb);
+		TCP_ECN_send_synack(sk, skb);
 	}
 	return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 }
@@ -2840,7 +2851,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	memset(th, 0, sizeof(struct tcphdr));
 	th->syn = 1;
 	th->ack = 1;
-	TCP_ECN_make_synack(req, th);
+	TCP_ECN_make_synack(req, th, sk);
 	th->source = htons(ireq->ir_num);
 	th->dest = ireq->ir_rmt_port;
 	/* Setting of flags are superfluous here for callers (and ECE is
-- 
1.7.11.7
