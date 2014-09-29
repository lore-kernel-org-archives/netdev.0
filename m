From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next 1/2] tcp: move TCP_ECN_create_request out of header
Date: Mon, 29 Sep 2014 13:08:29 +0200
Message-ID: <1411988910-23710-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59433 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751786AbaI2LIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 07:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After Octavian Purdilas tcp ipv4/ipv6 unification work this helper only
has a single callsite.

While at it, convert name to lowercase, suggested by Stephen.

Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h    | 34 ----------------------------------
 net/ipv4/tcp_input.c | 36 +++++++++++++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1f57c53..545a79a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -861,40 +861,6 @@ static inline void tcp_ca_event(struct sock *sk, const enum tcp_ca_event event)
 		icsk->icsk_ca_ops->cwnd_event(sk, event);
 }
 
-/* RFC3168 : 6.1.1 SYN packets must not have ECT/ECN bits set
- *
- * If we receive a SYN packet with these bits set, it means a
- * network is playing bad games with TOS bits. In order to
- * avoid possible false congestion notifications, we disable
- * TCP ECN negociation.
- *
- * Exception: tcp_ca wants ECN. This is required for DCTCP
- * congestion control; it requires setting ECT on all packets,
- * including SYN. We inverse the test in this case: If our
- * local socket wants ECN, but peer only set ece/cwr (but not
- * ECT in IP header) its probably a non-DCTCP aware sender.
- */
-static inline void
-TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
-		       const struct sock *listen_sk)
-{
-	const struct tcphdr *th = tcp_hdr(skb);
-	const struct net *net = sock_net(listen_sk);
-	bool th_ecn = th->ece && th->cwr;
-	bool ect, need_ecn;
-
-	if (!th_ecn)
-		return;
-
-	ect = !INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield);
-	need_ecn = tcp_ca_needs_ecn(listen_sk);
-
-	if (!ect && !need_ecn && net->ipv4.sysctl_tcp_ecn)
-		inet_rsk(req)->ecn_ok = 1;
-	else if (ect && need_ecn)
-		inet_rsk(req)->ecn_ok = 1;
-}
-
 /* These functions determine how the current flow behaves in respect of SACK
  * handling. SACK is negotiated with the peer, and therefore it can vary
  * between different flows.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fc13317..174181e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5906,6 +5906,40 @@ static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
 #endif
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
+static void tcp_ecn_create_request(struct request_sock *req,
+				   const struct sk_buff *skb,
+				   const struct sock *listen_sk)
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
 int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		     const struct tcp_request_sock_ops *af_ops,
 		     struct sock *sk, struct sk_buff *skb)
@@ -5966,7 +6000,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		goto drop_and_free;
 
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb, sk);
+		tcp_ecn_create_request(req, skb, sk);
 
 	if (want_cookie) {
 		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
-- 
1.8.1.5
