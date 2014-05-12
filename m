From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/5] net: tcp: add flag for ca to indicate that ECN is required
Date: Mon, 12 May 2014 22:59:41 +0200
Message-ID: <1399928384-24143-3-git-send-email-fw@strlen.de>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Glenn Judd <glenn.judd@morganstanley.com>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56529 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753658AbaELVfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 17:35:48 -0400
In-Reply-To: <1399928384-24143-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

This patch adds a flag to TCP congestion algorithms that allows
for requesting to mark IPv4/IPv6 sockets with transport as ECN
capable, that is, ECT(0), when required by a congestion algorithm.

It is currently used and needed in DataCenter TCP (DCTCP), as it
requires both peers to assert ECT on all IP packets sent - it
uses ECN feedback (i.e. CE, Congestion Encountered) from switches
inside the data center to derive feedback to the end hosts.

Therefore, simply add a new flag to icsk_ca_ops. Note that DCTCP's
algorithm/behaviour slightly diverges from RFC3168, therefore this
is only (!) enabled iff the assigned congestion control ops module
has requested this. By that, we can tightly couple this logic really
only to provided congestion control ops.

Joint work with Florian Westphal and Glenn Judd.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h     | 45 ++++++++++++++++++++++++++++-----------------
 net/ipv4/tcp_ipv4.c   |  2 +-
 net/ipv4/tcp_output.c |  9 ++++++++-
 net/ipv6/tcp_ipv6.c   |  2 +-
 4 files changed, 38 insertions(+), 20 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8ae165f..92d1600 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -734,23 +734,6 @@ struct tcp_skb_cb {
 
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
@@ -783,6 +766,7 @@ enum tcp_ca_event {
 #define TCP_CA_BUF_MAX	(TCP_CA_NAME_MAX*TCP_CA_MAX)
 
 #define TCP_CONG_NON_RESTRICTED 0x1
+#define TCP_CONG_NEEDS_ECN	0x2
 
 struct tcp_congestion_ops {
 	struct list_head	list;
@@ -848,6 +832,13 @@ static inline void tcp_set_ca_state(struct sock *sk, const u8 ca_state)
 	icsk->icsk_ca_state = ca_state;
 }
 
+static inline bool tcp_ca_needs_ecn(const struct sock *sk)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	return icsk->icsk_ca_ops->flags & TCP_CONG_NEEDS_ECN;
+}
+
 static inline void tcp_ca_event(struct sock *sk, const enum tcp_ca_event event)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -856,6 +847,26 @@ static inline void tcp_ca_event(struct sock *sk, const enum tcp_ca_event event)
 		icsk->icsk_ca_ops->cwnd_event(sk, event);
 }
 
+/* RFC3168 : 6.1.1 SYN packets must not have ECT/ECN bits set
+ *
+ * If we receive a SYN packet with these bits set, it means a network is
+ * playing bad games with TOS bits. In order to avoid possible false congestion
+ * notifications, we disable TCP ECN negociation.
+ */
+static inline void
+TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
+		       const struct sock *listen_sk)
+{
+	const struct tcphdr *th = tcp_hdr(skb);
+	const struct net *net = sock_net(listen_sk);
+
+	if (net->ipv4.sysctl_tcp_ecn && th->ece && th->cwr &&
+	    (INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield) ||
+	     tcp_ca_needs_ecn(listen_sk))) {
+		inet_rsk(req)->ecn_ok = 1;
+	}
+}
+
 /* These functions determine how the current flow behaves in respect of SACK
  * handling. SACK is negotiated with the peer, and therefore it can vary
  * between different flows.
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ad166dc..d7d9c54 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1512,7 +1512,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb, sock_net(sk));
+		TCP_ECN_create_request(req, skb, sk);
 
 	if (want_cookie) {
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 694711a..1f983dd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -331,7 +331,8 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->ecn_flags = 0;
-	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1) {
+	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
+	    tcp_ca_needs_ecn(sk)) {
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 	}
@@ -953,6 +954,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (likely((tcb->tcp_flags & TCPHDR_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
 
+	if (tcp_ca_needs_ecn(sk))
+		INET_ECN_xmit(sk);
+
 #ifdef CONFIG_TCP_MD5SIG
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
@@ -2860,6 +2864,9 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_OUTSEGS);
 
+	if (tcp_ca_needs_ecn(sk))
+		INET_ECN_xmit(sk);
+
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
 	if (md5) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7fa6743..b1c8765 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1013,7 +1013,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb, sock_net(sk));
+		TCP_ECN_create_request(req, skb, sk);
 
 	ireq->ir_iif = sk->sk_bound_dev_if;
 
-- 
1.8.1.5
