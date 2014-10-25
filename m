From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 2/2] net: allow setting ecn via routing table
Date: Sun, 26 Oct 2014 00:38:49 +0200
Message-ID: <1414276729-17871-3-git-send-email-fw@strlen.de>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54076 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbaJYWjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 18:39:03 -0400
In-Reply-To: <1414276729-17871-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows to set ECN on a per-route basis in case the sysctl tcp_ecn is
not 1.  IOW, when ECN is set for specific routes, it provides a
tcp_ecn=1 behaviour for that route while the rest of the stack acts
according to the global settings.

One can use 'ip route change dev $dev $net features ecn' to toggle this.

Joint work with Daniel Borkmann.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_input.c  | 25 +++++++++++++++----------
 net/ipv4/tcp_output.c | 12 ++++++++++--
 2 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a12b455..72d7510 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5875,20 +5875,22 @@ static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
  */
 static void tcp_ecn_create_request(struct request_sock *req,
 				   const struct sk_buff *skb,
-				   const struct sock *listen_sk)
+				   const struct sock *listen_sk,
+				   struct dst_entry *dst)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 	const struct net *net = sock_net(listen_sk);
 	bool th_ecn = th->ece && th->cwr;
-	bool ect, need_ecn;
+	bool ect, need_ecn, ecn_ok;
 
 	if (!th_ecn)
 		return;
 
 	ect = !INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield);
 	need_ecn = tcp_ca_needs_ecn(listen_sk);
+	ecn_ok = net->ipv4.sysctl_tcp_ecn || dst_feature(dst, RTAX_FEATURE_ECN);
 
-	if (!ect && !need_ecn && net->ipv4.sysctl_tcp_ecn)
+	if (!ect && !need_ecn && ecn_ok)
 		inet_rsk(req)->ecn_ok = 1;
 	else if (ect && need_ecn)
 		inet_rsk(req)->ecn_ok = 1;
@@ -5953,13 +5955,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	if (!want_cookie || tmp_opt.tstamp_ok)
-		tcp_ecn_create_request(req, skb, sk);
-
-	if (want_cookie) {
-		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
-		req->cookie_ts = tmp_opt.tstamp_ok;
-	} else if (!isn) {
+	if (!want_cookie && !isn) {
 		/* VJ's idea. We save last timestamp seen
 		 * from the destination in peer table, when entering
 		 * state TIME-WAIT, and check against it before
@@ -6007,6 +6003,15 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			goto drop_and_free;
 	}
 
+	tcp_ecn_create_request(req, skb, sk, dst);
+
+	if (want_cookie) {
+		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
+		req->cookie_ts = tmp_opt.tstamp_ok;
+		if (!tmp_opt.tstamp_ok)
+			inet_rsk(req)->ecn_ok = 0;
+	}
+
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_openreq_init_rwin(req, sk, dst);
 	fastopen = !want_cookie &&
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3af2129..b1c6296 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -333,10 +333,18 @@ static void tcp_ecn_send_synack(struct sock *sk, struct sk_buff *skb)
 static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	bool use_ecn = sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
+		       tcp_ca_needs_ecn(sk);
+
+	if (!use_ecn) {
+		const struct dst_entry *dst = __sk_dst_get(sk);
+		if (dst && dst_feature(dst, RTAX_FEATURE_ECN))
+			use_ecn = true;
+	}
 
 	tp->ecn_flags = 0;
-	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
-	    tcp_ca_needs_ecn(sk)) {
+
+	if (use_ecn) {
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 		if (tcp_ca_needs_ecn(sk))
-- 
2.0.4
