From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] [Syncookies:] Add support for TCP-options via timestamps.
Date: Mon, 31 Mar 2008 02:09:42 +0200
Message-ID: <1206922182-2214-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Glenn Griffin <ggriffin.kernel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:49149 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753674AbYCaAJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 20:09:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the use of SACK and window scaling when syncookies are used
and the client supports tcp timestamps. Options are then restored
from the timestamp echo.

Based on earlier work by Glenn Griffin.
This patch avoids increasing the size of structs by encoding TCP
options into the least significant bits of the timestamp and
by not using any 'timestamp offset'.

The downside is that the timestamp sent in the packet after the synack
will increase by several seconds.

Reviewed-by: Hagen Paul Pfeifer <hagen@jauu.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
CC: Glenn Griffin <ggriffin.kernel@gmail.com>
---

Glenns original patch:
http://marc.info/?l=linux-netdev&m=120309729612244&w=2

Also see
http://marc.info/?l=linux-netdev&m=120309729512241&w=2
for the previous discussion of Glenns patch set.

 include/net/request_sock.h |    2 +-
 include/net/tcp.h          |    3 +
 net/ipv4/syncookies.c      |   94 +++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp_ipv4.c        |    5 +-
 net/ipv4/tcp_output.c      |    6 ++-
 net/ipv6/syncookies.c      |   53 +++++++++++++++++++++++--
 net/ipv6/tcp_ipv6.c        |    5 +-
 7 files changed, 151 insertions(+), 17 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 0369f98..b987813 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -45,7 +45,7 @@ struct request_sock {
 	struct request_sock		*dl_next; /* Must be first member! */
 	u16				mss;
 	u8				retrans;
-	u8				__pad;
+	u8				cookie_ts; /* syncookie: encode tcpopts in timestamp */
 	/* The following two fields can be easily recomputed I think -AK */
 	u32				window_clamp; /* window clamp at creation time */
 	u32				rcv_wnd;	  /* rcv_wnd offered first time */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 723b368..83ad43b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -442,6 +442,8 @@ extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
 				     __u16 *mss);
 
+extern __u32 cookie_init_timestamp(struct request_sock *req);
+
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
 extern __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb,
@@ -956,6 +958,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	struct inet_request_sock *ireq = inet_rsk(req);
 
 	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
+	req->cookie_ts = 0;
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	req->mss = rx_opt->mss_clamp;
 	req->ts_recent = rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index abc752d..274a27d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -19,6 +19,10 @@
 #include <linux/kernel.h>
 #include <net/tcp.h>
 
+/* Timestamps: lowest 9 bits store TCP options */
+#define TSBITS 9
+#define TSMASK (((__u32)1 << TSBITS) - 1)
+
 extern int sysctl_tcp_syncookies;
 
 __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
@@ -51,6 +55,43 @@ static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 	return tmp[17];
 }
 
+
+static u32 options_encode(u32 options)
+{
+	u32 ts, ts_now = tcp_time_stamp;
+
+	if (unlikely(options > ts_now)) { /* recent overflow */
+		options |= ~(TSMASK);
+		return options;
+	}
+	ts = ts_now & ~TSMASK;
+	ts |= options;
+	if (ts > ts_now) { /* try to fix up ... */
+		ts >>= TSBITS;
+		ts--;
+		ts <<= TSBITS;
+		ts |= options;
+	}
+        return ts;
+}
+
+
+__u32 cookie_init_timestamp(struct request_sock *req)
+{
+	struct inet_request_sock *ireq;
+	u32 options = 0;
+
+	ireq = inet_rsk(req);
+	if (ireq->wscale_ok) {
+		options = ireq->snd_wscale;
+		options |= ireq->rcv_wscale << 4;
+	}
+	options |= ireq->sack_ok << 8;
+
+	return options_encode(options);
+}
+
+
 static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
 				   __be16 dport, __u32 sseq, __u32 count,
 				   __u32 data)
@@ -185,6 +226,36 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	return child;
 }
 
+
+/*
+ * when syncookies are in effect and tcp timestamps are enabled we store
+ * additional tcp options in the timestamp value.
+ *
+ *
+ *
+ * The lowest 4 bits are for snd_wscale
+ * The next 4 lsb are for rcv_wscale
+ * The next 1 lsb are for sack_ok
+ */
+static void cookie_check_timestamp(struct tcp_options_received *tcp_opt)
+{
+	/* echoed timestamp, 9 lowest bits contain options */
+	u32 options = tcp_opt->rcv_tsecr & TSMASK;
+
+	tcp_opt->snd_wscale = options & 0xf;
+	options >>= 4;
+	tcp_opt->rcv_wscale = options & 0xf;
+
+	tcp_opt->sack_ok = (options >> 4) & 0x1;
+
+	if (tcp_opt->sack_ok)
+		tcp_sack_reset(tcp_opt);
+
+	if (tcp_opt->snd_wscale || tcp_opt->rcv_wscale)
+		tcp_opt->wscale_ok = 1;
+}
+
+
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
@@ -198,6 +269,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	int mss;
 	struct rtable *rt;
 	__u8 rcv_wscale;
+	struct tcp_options_received tcp_opt;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
@@ -210,6 +282,13 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESRECV);
 
+	/* check for timestamp cookie support */
+	memset(&tcp_opt, 0, sizeof(tcp_opt));
+	tcp_parse_options(skb, &tcp_opt, 0);
+
+	if (tcp_opt.saw_tstamp)
+		cookie_check_timestamp(&tcp_opt);
+
 	ret = NULL;
 	req = reqsk_alloc(&tcp_request_sock_ops); /* for safety */
 	if (!req)
@@ -228,6 +307,12 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
 	ireq->opt		= NULL;
+	ireq->snd_wscale	= tcp_opt.snd_wscale;
+	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
+	ireq->sack_ok		= tcp_opt.sack_ok;
+	ireq->wscale_ok		= tcp_opt.wscale_ok;
+	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
+	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
@@ -242,8 +327,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
-	ireq->snd_wscale = ireq->rcv_wscale = ireq->tstamp_ok = 0;
-	ireq->wscale_ok	 = ireq->sack_ok = 0;
 	req->expires	= 0UL;
 	req->retrans	= 0;
 
@@ -272,11 +355,12 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/* Try to redo what tcp_v4_send_synack did. */
-	req->window_clamp = dst_metric(&rt->u.dst, RTAX_WINDOW);
+	req->window_clamp = tp->window_clamp ? :dst_metric(&rt->u.dst, RTAX_WINDOW);
+
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
-				  0, &rcv_wscale);
-	/* BTW win scale with syncookies is 0 by definition */
+				  ireq->wscale_ok, &rcv_wscale);
+
 	ireq->rcv_wscale  = rcv_wscale;
 
 	ret = get_cookie_sock(sk, skb, req, &rt->u.dst);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ef141b8..0d4d990 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1300,10 +1300,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_parse_options(skb, &tmp_opt, 0);
 
-	if (want_cookie) {
+	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
-		tmp_opt.saw_tstamp = 0;
-	}
 
 	if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
 		/* Some OSes (unknown ones, but I see them on web server, which
@@ -1331,6 +1329,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (want_cookie) {
 #ifdef CONFIG_SYN_COOKIES
 		syn_flood_warning(skb);
+		req->cookie_ts = tmp_opt.tstamp_ok;
 #endif
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
 	} else if (!isn) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a627616..76b3653 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2233,7 +2233,11 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never scaled. */
 	th->window = htons(min(req->rcv_wnd, 65535U));
-
+#ifdef CONFIG_SYN_COOKIES
+	if (unlikely(req->cookie_ts))
+		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
+	else
+#endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	tcp_syn_build_options((__be32 *)(th + 1), dst_metric(dst, RTAX_ADVMSS), ireq->tstamp_ok,
 			      ireq->sack_ok, ireq->wscale_ok, ireq->rcv_wscale,
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 3a622e7..2737862 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -21,6 +21,9 @@
 #include <net/ipv6.h>
 #include <net/tcp.h>
 
+/* Timestamps: lowest 9 bits store TCP options */
+#define TSMASK (((__u32)1 << 9) - 1)
+
 extern int sysctl_tcp_syncookies;
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 
@@ -156,6 +159,36 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 	return mssind < NUM_MSS ? msstab[mssind] + 1 : 0;
 }
 
+
+/*
+ * when syncookies are in effect and tcp timestamps are enabled we store
+ * additional tcp options in the timestamp value.
+ *
+ *
+ *
+ * The lowest 4 bits are for snd_wscale
+ * The next 4 lsb are for rcv_wscale
+ * The next 1 lsb are for sack_ok
+ */
+static void cookie_check_timestamp(struct tcp_options_received *tcp_opt)
+{
+	/* echoed timestamp, 9 lowest bits contain options */
+	u32 options = tcp_opt->rcv_tsecr & TSMASK;
+
+	tcp_opt->snd_wscale = options & 0xf;
+	options >>= 4;
+	tcp_opt->rcv_wscale = options & 0xf;
+
+	tcp_opt->sack_ok = (options >> 4) & 0x1;
+
+	if (tcp_opt->sack_ok)
+		tcp_sack_reset(tcp_opt);
+
+	if (tcp_opt->snd_wscale || tcp_opt->rcv_wscale)
+		tcp_opt->wscale_ok = 1;
+}
+
+
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_request_sock *ireq;
@@ -170,6 +203,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
+	struct tcp_options_received tcp_opt;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
@@ -182,6 +216,13 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESRECV);
 
+	/* check for timestamp cookie support */
+	memset(&tcp_opt, 0, sizeof(tcp_opt));
+	tcp_parse_options(skb, &tcp_opt, 0);
+
+	if (tcp_opt.saw_tstamp)
+		cookie_check_timestamp(&tcp_opt);
+
 	ret = NULL;
 	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
 	if (!req)
@@ -216,8 +257,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	req->expires = 0UL;
 	req->retrans = 0;
-	ireq->snd_wscale = ireq->rcv_wscale = ireq->tstamp_ok = 0;
-	ireq->wscale_ok = ireq->sack_ok = 0;
+	ireq->snd_wscale	= tcp_opt.snd_wscale;
+	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
+	ireq->sack_ok		= tcp_opt.sack_ok;
+	ireq->wscale_ok		= tcp_opt.wscale_ok;
+	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
+	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->rcv_isn = ntohl(th->seq) - 1;
 	treq->snt_isn = cookie;
 
@@ -253,10 +298,10 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 			goto out;
 	}
 
-	req->window_clamp = dst_metric(dst, RTAX_WINDOW);
+	req->window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
-				  0, &rcv_wscale);
+				  ireq->wscale_ok, &rcv_wscale);
 
 	ireq->rcv_wscale = rcv_wscale;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6d851c3..822dbca 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1289,10 +1289,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_parse_options(skb, &tmp_opt, 0);
 
-	if (want_cookie) {
+	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
-		tmp_opt.saw_tstamp = 0;
-	}
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb);
@@ -1306,6 +1304,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	if (want_cookie) {
 		isn = cookie_v6_init_sequence(sk, skb, &req->mss);
+		req->cookie_ts = tmp_opt.tstamp_ok;
 	} else if (!isn) {
 		if (ipv6_opt_accepted(sk, skb) ||
 		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
-- 
1.5.3.7

