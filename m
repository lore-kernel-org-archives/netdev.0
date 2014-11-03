From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next v3 2/3] syncookies: split cookie_check_timestamp() into two functions
Date: Mon,  3 Nov 2014 14:01:59 +0100
Message-ID: <1415019720-17106-3-git-send-email-fw@strlen.de>
References: <1415019720-17106-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44866 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751169AbaKCNCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 08:02:09 -0500
In-Reply-To: <1415019720-17106-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function cookie_check_timestamp(), both called from IPv4/6 context,
is being used to decode the echoed timestamp from the SYN/ACK into TCP
options used for follow-up communication with the peer.

We can remove ECN handling from that function, split it into a separate
one, and simply rename the original function into cookie_decode_options().
cookie_decode_options() just fills in tcp_option struct based on the
echoed timestamp received from the peer. Anything that fails in this
function will actually discard the request socket.

While this is the natural place for decoding options such as ECN which
commit 172d69e63c7f ("syncookies: add support for ECN") added, we argue
that in particular for ECN handling, it can be checked at a later point
in time as the request sock would actually not need to be dropped from
this, but just ECN support turned off.

Therefore, we split this functionality into cookie_ecn_ok(), which tells
|us if the timestamp indicates ECN support AND the tcp_ecn sysctl is enabled.

This prepares for per-route ECN support: just looking at the tcp_ecn sysctl
won't be enough anymore at that point; if the timestamp indicates ECN
and sysctl tcp_ecn == 0, we will also need to check the ECN dst metric.

This would mean adding a route lookup to cookie_check_timestamp(), which
we definitely want to avoid. As we already do a route lookup at a later
point in cookie_{v4,v6}_check(), we can simply make use of that as well
for the new cookie_ecn_ok() function w/o any additional cost.

Joint work with Daniel Borkmann.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 This patch was not part of earlier versions of the set.

 include/net/tcp.h     |  9 ++++-----
 net/ipv4/syncookies.c | 31 +++++++++++++++++++++----------
 net/ipv6/syncookies.c |  5 ++---
 3 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3a35b15..36c5084 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -490,17 +490,16 @@ u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 			      u16 *mssp);
 __u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
 			      __u16 *mss);
-#endif
-
 __u32 cookie_init_timestamp(struct request_sock *req);
-bool cookie_check_timestamp(struct tcp_options_received *opt, struct net *net,
-			    bool *ecn_ok);
+bool cookie_timestamp_decode(struct tcp_options_received *opt);
+bool cookie_ecn_ok(const struct tcp_options_received *opt,
+		   const struct net *net);
 
 /* From net/ipv6/syncookies.c */
 int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
 		      u32 cookie);
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
-#ifdef CONFIG_SYN_COOKIES
+
 u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
 			      const struct tcphdr *th, u16 *mssp);
 __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index c3792c0..6de7725 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -241,10 +241,10 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  * additional tcp options in the timestamp.
  * This extracts these options from the timestamp echo.
  *
- * return false if we decode an option that should not be.
+ * return false if we decode a tcp option that is disabled
+ * on the host.
  */
-bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
-			struct net *net, bool *ecn_ok)
+bool cookie_timestamp_decode(struct tcp_options_received *tcp_opt)
 {
 	/* echoed timestamp, lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr;
@@ -258,9 +258,6 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
 		return false;
 
 	tcp_opt->sack_ok = (options & TS_OPT_SACK) ? TCP_SACK_SEEN : 0;
-	*ecn_ok = options & TS_OPT_ECN;
-	if (*ecn_ok && !net->ipv4.sysctl_tcp_ecn)
-		return false;
 
 	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
 		return false;
@@ -273,7 +270,22 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
 
 	return sysctl_tcp_window_scaling != 0;
 }
-EXPORT_SYMBOL(cookie_check_timestamp);
+EXPORT_SYMBOL(cookie_timestamp_decode);
+
+bool cookie_ecn_ok(const struct tcp_options_received *tcp_opt,
+		   const struct net *net)
+{
+	bool ecn_ok = tcp_opt->rcv_tsecr & TS_OPT_ECN;
+
+	if (!ecn_ok)
+		return false;
+
+	if (net->ipv4.sysctl_tcp_ecn)
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(cookie_ecn_ok);
 
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 {
@@ -289,7 +301,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct rtable *rt;
 	__u8 rcv_wscale;
-	bool ecn_ok = false;
 	struct flowi4 fl4;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
@@ -310,7 +321,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
+	if (!cookie_timestamp_decode(&tcp_opt))
 		goto out;
 
 	ret = NULL;
@@ -328,7 +339,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_loc_addr	= ip_hdr(skb)->daddr;
 	ireq->ir_rmt_addr	= ip_hdr(skb)->saddr;
 	ireq->ir_mark		= inet_request_mark(sk, skb);
-	ireq->ecn_ok		= ecn_ok;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
@@ -377,6 +387,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 				  dst_metric(&rt->dst, RTAX_INITRWND));
 
 	ireq->rcv_wscale  = rcv_wscale;
+	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk));
 
 	ret = get_cookie_sock(sk, skb, req, &rt->dst);
 	/* ip_queue_xmit() depends on our flow being setup
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index be291ba..52cc8cb 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -166,7 +166,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
-	bool ecn_ok = false;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -186,7 +185,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
+	if (!cookie_timestamp_decode(&tcp_opt))
 		goto out;
 
 	ret = NULL;
@@ -223,7 +222,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	req->expires = 0UL;
 	req->num_retrans = 0;
-	ireq->ecn_ok		= ecn_ok;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
@@ -264,6 +262,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 				  dst_metric(dst, RTAX_INITRWND));
 
 	ireq->rcv_wscale = rcv_wscale;
+	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk));
 
 	ret = get_cookie_sock(sk, skb, req, dst);
 out:
-- 
2.0.4
