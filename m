From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2] syncookies: add support for ECN
Date: Mon, 21 Jun 2010 23:48:45 +0200
Message-ID: <1277156925-7295-2-git-send-email-fw@strlen.de>
References: <1277156925-7295-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40541 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932653Ab0FUVvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 17:51:05 -0400
In-Reply-To: <1277156925-7295-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows use of ECN when syncookies are in effect by encoding ecn_ok
into the syn-ack tcp timestamp.

While at it, remove a uneeded #ifdef CONFIG_SYN_COOKIES.
With CONFIG_SYN_COOKIES=nm want_cookie is ifdef'd to 0 and gcc
removes the "if (0)".

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h     |    2 +-
 net/ipv4/syncookies.c |   15 ++++++++++-----
 net/ipv4/tcp_ipv4.c   |    6 ++----
 net/ipv6/syncookies.c |    5 +++--
 net/ipv6/tcp_ipv6.c   |    2 +-
 5 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 18c246c..c2f96c2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -464,7 +464,7 @@ extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb,
 				     __u16 *mss);
 
 extern __u32 cookie_init_timestamp(struct request_sock *req);
-extern bool cookie_check_timestamp(struct tcp_options_received *tcp_opt);
+extern bool cookie_check_timestamp(struct tcp_options_received *opt, bool *);
 
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 8896329..650cace 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -19,7 +19,7 @@
 #include <net/route.h>
 
 /* Timestamps: lowest bits store TCP options */
-#define TSBITS 5
+#define TSBITS 6
 #define TSMASK (((__u32)1 << TSBITS) - 1)
 
 extern int sysctl_tcp_syncookies;
@@ -73,6 +73,7 @@ __u32 cookie_init_timestamp(struct request_sock *req)
 
 	options = ireq->wscale_ok ? ireq->snd_wscale : 0xf;
 	options |= ireq->sack_ok << 4;
+	options |= ireq->ecn_ok << 5;
 
 	ts = ts_now & ~TSMASK;
 	ts |= options;
@@ -226,11 +227,11 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  * This extracts these options from the timestamp echo.
  *
  * The lowest 4 bits store snd_wscale.
- * The next lsb is for sack_ok
+ * next 2 bits indicate SACK and ECN support.
  *
  * return false if we decode an option that should not be.
  */
-bool cookie_check_timestamp(struct tcp_options_received *tcp_opt)
+bool cookie_check_timestamp(struct tcp_options_received *tcp_opt, bool *ecn_ok)
 {
 	/* echoed timestamp, lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr & TSMASK;
@@ -244,6 +245,9 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt)
 		return false;
 
 	tcp_opt->sack_ok = (options >> 4) & 0x1;
+	*ecn_ok = (options >> 5) & 1;
+	if (*ecn_ok && !sysctl_tcp_ecn)
+		return false;
 
 	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
 		return false;
@@ -272,6 +276,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	int mss;
 	struct rtable *rt;
 	__u8 rcv_wscale;
+	bool ecn_ok;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -288,7 +293,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
 
-	if (!cookie_check_timestamp(&tcp_opt))
+	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
 		goto out;
 
 	ret = NULL;
@@ -305,7 +310,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->rmt_port		= th->source;
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
-	ireq->ecn_ok		= 0;
+	ireq->ecn_ok		= ecn_ok;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2e41e6f..8fa32f5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1328,14 +1328,12 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	if (!want_cookie)
+	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
 	if (want_cookie) {
-#ifdef CONFIG_SYN_COOKIES
-		req->cookie_ts = tmp_opt.tstamp_ok;
-#endif
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
+		req->cookie_ts = tmp_opt.tstamp_ok;
 	} else if (!isn) {
 		struct inet_peer *peer = NULL;
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 84d818c..09fd34f 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -164,6 +164,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
+	bool ecn_ok;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -180,7 +181,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
 
-	if (!cookie_check_timestamp(&tcp_opt))
+	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
 		goto out;
 
 	ret = NULL;
@@ -215,7 +216,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	req->expires = 0UL;
 	req->retrans = 0;
-	ireq->ecn_ok		= 0;
+	ireq->ecn_ok		= ecn_ok;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f875345..5ebc27e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1269,7 +1269,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	treq = inet6_rsk(req);
 	ipv6_addr_copy(&treq->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&treq->loc_addr, &ipv6_hdr(skb)->daddr);
-	if (!want_cookie)
+	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
 	if (!isn) {
-- 
1.7.1

