From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next v3 3/3] net: allow setting ecn via routing table
Date: Mon,  3 Nov 2014 14:02:00 +0100
Message-ID: <1415019720-17106-4-git-send-email-fw@strlen.de>
References: <1415019720-17106-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44870 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080AbaKCNCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 08:02:15 -0500
In-Reply-To: <1415019720-17106-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to set ECN on a per-route basis in case the sysctl
tcp_ecn is not set to 1. In other words, when ECN is set for specific
routes, it provides a tcp_ecn=1 behaviour for that route while the rest
of the stack acts according to the global settings.

One can use 'ip route change dev $dev $net features ecn' to toggle this.

Having a more fine-grained per-route setting can be beneficial for various
reasons, for example, 1) within data centers, or 2) local ISPs may deploy
ECN support for their own video/streaming services [1], etc.

There was a recent measurement study/paper [2] which scanned the Alexa's
publicly available top million websites list from a vantage point in US,
Europe and Asia:

Half of the Alexa list will now happily use ECN (tcp_ecn=2, most likely
blamed to commit 255cac91c3 ("tcp: extend ECN sysctl to allow server-side
only ECN") ;)); the break in connectivity on-path was found is about
1 in 10,000 cases. Timeouts rather than receiving back RSTs were much
more common in the negotiation phase (and mostly seen in the Alexa
middle band, ranks around 50k-150k): from 12-thousand hosts on which
there _may_ be ECN-linked connection failures, only 79 failed with RST
when _not_ failing with RST when ECN is not requested.

It's unclear though, how much equipment in the wild actually marks CE
when buffers start to fill up.

We thought about a fallback to non-ECN for retransmitted SYNs as another
global option (which could perhaps one day be made default), but as Eric
points out, there's much more work needed to detect broken middleboxes.

Two examples Eric mentioned are buggy firewalls that accept only a single
SYN per flow, and middleboxes that successfully let an ECN flow establish,
but later mark CE for all packets (so cwnd converges to 1).

 [1] http://www.ietf.org/proceedings/89/slides/slides-89-tsvarea-1.pdf, p.15
 [2] http://ecn.ethz.ch/

Joint work with Daniel Borkmann.

Reference: http://thread.gmane.org/gmane.linux.network/335797
Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v2:
  - alter new cookie_ecn_ok() ok function to also evaluate
  RTAX_FEATURE_ECN if timestamp-ecn-bit is set and the ecn sysctl
  is off.
  - extra blank line in tcp_output.c to appease checkpatch.pl

 include/net/tcp.h     |  2 +-
 net/ipv4/syncookies.c |  6 +++---
 net/ipv4/tcp_input.c  | 25 +++++++++++++++----------
 net/ipv4/tcp_output.c | 13 +++++++++++--
 net/ipv6/syncookies.c |  2 +-
 5 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 36c5084..f50f29faf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -493,7 +493,7 @@ __u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
 __u32 cookie_init_timestamp(struct request_sock *req);
 bool cookie_timestamp_decode(struct tcp_options_received *opt);
 bool cookie_ecn_ok(const struct tcp_options_received *opt,
-		   const struct net *net);
+		   const struct net *net, const struct dst_entry *dst);
 
 /* From net/ipv6/syncookies.c */
 int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 6de7725..45fe60c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -273,7 +273,7 @@ bool cookie_timestamp_decode(struct tcp_options_received *tcp_opt)
 EXPORT_SYMBOL(cookie_timestamp_decode);
 
 bool cookie_ecn_ok(const struct tcp_options_received *tcp_opt,
-		   const struct net *net)
+		   const struct net *net, const struct dst_entry *dst)
 {
 	bool ecn_ok = tcp_opt->rcv_tsecr & TS_OPT_ECN;
 
@@ -283,7 +283,7 @@ bool cookie_ecn_ok(const struct tcp_options_received *tcp_opt,
 	if (net->ipv4.sysctl_tcp_ecn)
 		return true;
 
-	return false;
+	return dst_feature(dst, RTAX_FEATURE_ECN);
 }
 EXPORT_SYMBOL(cookie_ecn_ok);
 
@@ -387,7 +387,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 				  dst_metric(&rt->dst, RTAX_INITRWND));
 
 	ireq->rcv_wscale  = rcv_wscale;
-	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk));
+	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), &rt->dst);
 
 	ret = get_cookie_sock(sk, skb, req, &rt->dst);
 	/* ip_queue_xmit() depends on our flow being setup
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4e4617e..9db942a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5876,20 +5876,22 @@ static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
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
@@ -5954,13 +5956,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
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
@@ -6008,6 +6004,15 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
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
index a3d453b..0b88158 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -333,10 +333,19 @@ static void tcp_ecn_send_synack(struct sock *sk, struct sk_buff *skb)
 static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	bool use_ecn = sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
+		       tcp_ca_needs_ecn(sk);
+
+	if (!use_ecn) {
+		const struct dst_entry *dst = __sk_dst_get(sk);
+
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
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 52cc8cb..7337fc7 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -262,7 +262,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 				  dst_metric(dst, RTAX_INITRWND));
 
 	ireq->rcv_wscale = rcv_wscale;
-	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk));
+	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), dst);
 
 	ret = get_cookie_sock(sk, skb, req, dst);
 out:
-- 
2.0.4
