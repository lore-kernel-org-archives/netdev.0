From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: [PATCH 2/3] Enable the use of TCP options with syncookies
Date: Fri, 15 Feb 2008 09:47:09 -0800
Message-ID: <1203097630-13237-2-git-send-email-ggriffin.kernel@gmail.com>
References: <1203097630-13237-1-git-send-email-ggriffin.kernel@gmail.com>
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:11164 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526AbYBORj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 12:39:26 -0500
Received: by wx-out-0506.google.com with SMTP id h31so727692wxd.4
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 09:39:25 -0800 (PST)
In-Reply-To: <1203097630-13237-1-git-send-email-ggriffin.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the use of extended tcp options when syncookies are in use and the
client supports tcp timestamps.

The general concept is to encode the tcp options as the initial timestamp
that we send to the requestor in our synack.  We can then decode the
timestamp echo reply value on the returning ack.

This implementation encodes the following options in the timestamp,
snd_wscale, rcv_wscale, sack_ok, and also the necessary bits to calculate
the rtt, and ts_off accurately.  Note that there are still 5 unused bits
that could be used for future options.

Signed-off-by: Glenn Griffin <ggriffin.kernel@gmail.com>
---
 include/linux/tcp.h   |    3 ++
 include/net/tcp.h     |    4 ++
 net/ipv4/syncookies.c |   90 ++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp_ipv4.c   |    5 +--
 net/ipv4/tcp_output.c |   10 +++++-
 5 files changed, 104 insertions(+), 8 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 68387dc..f5a23e1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -233,6 +233,9 @@ struct tcp_request_sock {
 	u32			 	rcv_isn;
 	u32			 	snt_isn;
 	u32				ts_off;
+#ifdef CONFIG_SYN_COOKIES
+	u8				want_cookie_ts;
+#endif
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c935de7..42b36f5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -438,6 +438,7 @@ extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 				    struct ip_options *opt);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
 				     __u16 *mss);
+extern __u32 cookie_init_timestamp(struct request_sock *req);
 
 /* tcp_output.c */
 
@@ -958,6 +959,9 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
 	ireq->rmt_port = tcp_hdr(skb)->source;
+#ifdef CONFIG_SYN_COOKIES
+	tcp_rsk(req)->want_cookie_ts = 0;
+#endif
 }
 
 extern void tcp_enter_memory_pressure(void);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index f470fe4..eb5d804 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -35,6 +35,9 @@ module_init(init_syncookies);
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
+#define TSBITS 18
+#define TSMASK (((__u32)1 << TSBITS) - 1)
+
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
@@ -144,6 +147,23 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 				     jiffies / (HZ * 60), mssind);
 }
 
+__u32 cookie_init_timestamp(struct request_sock *req)
+{
+	struct inet_request_sock *ireq = inet_rsk(req);
+	__u32 init_ts = 0;
+
+	if (ireq->wscale_ok) {
+		init_ts |= ireq->snd_wscale << TSBITS;
+		init_ts |= ireq->rcv_wscale << (4 + TSBITS);
+	}
+	init_ts |= ireq->sack_ok << (8 + TSBITS);
+
+	init_ts |= tcp_time_stamp & TSMASK;
+
+	return init_ts;
+}
+
+
 /*
  * This (misnamed) value is the age of syncookie which is permitted.
  * Its ideal value should be dependent on TCP_TIMEOUT_INIT and
@@ -184,6 +204,52 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	return child;
 }
 
+/* when syncookies are in effect and tcp timestamps are enabled we will store
+ * additional tcp options encoded in the timestamp value.
+ *
+ * The 18 lsb of tcp timestamp is stored in the 18 lsb of the tcp timestamp sent
+ *
+ * 18 bits should be enough to contain a very conservative 2*MSL on a 1000 HZ
+ * system
+ *
+ * The next 4 lsb are for snd_wscale
+ * The next 4 lsb are for rcv_wscale
+ * The next 1 lsb are for sack_ok
+ */
+static __u32 cookie_check_timestamp(__u32 ts,
+				    struct tcp_options_received *tcp_opt)
+{
+	__u32 init_ts = ts & TSMASK;
+
+	 /*
+	  * check if tcp_time_stamp overflowed 18bits
+	  * while waiting for response
+	  */
+	if ((tcp_time_stamp & TSMASK) >= init_ts)
+		/* likely no overflow occurred */
+		init_ts |= tcp_time_stamp & (~TSMASK);
+	else
+		/*
+		 * overflow occurred, but we can be sure it's only one bit
+		 * since the cookie_check verifies the cookie was generated
+		 * within the last 4 minutes
+		 */
+		init_ts |= ((tcp_time_stamp >> TSBITS) - 1) << TSBITS;
+
+	tcp_opt->tstamp_ok = 1;
+	tcp_opt->snd_wscale = (ts >> TSBITS) & 0xf;
+	tcp_opt->rcv_wscale = (ts >> (TSBITS + 4)) & 0xf;
+	tcp_opt->sack_ok = (ts >> (TSBITS + 8)) & 0x1;
+
+	if (tcp_opt->sack_ok)
+		tcp_sack_reset(tcp_opt);
+
+	if (tcp_opt->snd_wscale || tcp_opt->rcv_wscale)
+		tcp_opt->wscale_ok = 1;
+
+	return init_ts;
+}
+
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
@@ -197,6 +263,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	int mss;
 	struct rtable *rt;
 	__u8 rcv_wscale;
+	struct tcp_options_received tcp_opt;
+	__u32 xmit_ts = 0;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
@@ -209,6 +277,13 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESRECV);
 
+	/* check for timestamp cookie support */
+	memset(&tcp_opt, 0, sizeof(tcp_opt));
+	tcp_parse_options(skb, &tcp_opt, 0, 0);
+
+	if (tcp_opt.saw_tstamp)
+		xmit_ts = cookie_check_timestamp(tcp_opt.rcv_tsecr, &tcp_opt);
+
 	ret = NULL;
 	req = reqsk_alloc(&tcp_request_sock_ops); /* for safety */
 	if (!req)
@@ -222,11 +297,18 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	treq = tcp_rsk(req);
 	treq->rcv_isn		= ntohl(th->seq) - 1;
 	treq->snt_isn		= cookie;
+	treq->ts_off		= xmit_ts ? tcp_opt.rcv_tsecr - xmit_ts : 0;
 	req->mss		= mss;
 	ireq->rmt_port		= th->source;
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
 	ireq->opt		= NULL;
+	ireq->snd_wscale	= tcp_opt.snd_wscale;
+	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
+	ireq->sack_ok		= tcp_opt.sack_ok;
+	ireq->wscale_ok		= tcp_opt.wscale_ok;
+	ireq->tstamp_ok		= tcp_opt.tstamp_ok;
+	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
@@ -241,8 +323,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
-	ireq->snd_wscale = ireq->rcv_wscale = ireq->tstamp_ok = 0;
-	ireq->wscale_ok	 = ireq->sack_ok = 0;
 	req->expires	= 0UL;
 	req->retrans	= 0;
 
@@ -271,10 +351,12 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/* Try to redo what tcp_v4_send_synack did. */
-	req->window_clamp = dst_metric(&rt->u.dst, RTAX_WINDOW);
+	req->window_clamp = tcp_sk(sk)->window_clamp ?
+			    : dst_metric(&rt->u.dst, RTAX_WINDOW);
+
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
-				  0, &rcv_wscale);
+				  ireq->wscale_ok, &rcv_wscale);
 	/* BTW win scale with syncookies is 0 by definition */
 	ireq->rcv_wscale  = rcv_wscale;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 267eda9..e20f78e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1297,10 +1297,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_parse_options(skb, &tmp_opt, 0, 0);
 
-	if (want_cookie) {
+	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
-		tmp_opt.saw_tstamp = 0;
-	}
 
 	if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
 		/* Some OSes (unknown ones, but I see them on web server, which
@@ -1328,6 +1326,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (want_cookie) {
 #ifdef CONFIG_SYN_COOKIES
 		syn_flood_warning(skb);
+		tcp_rsk(req)->want_cookie_ts = tmp_opt.saw_tstamp;
 #endif
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
 	} else if (!isn) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 81f1383..0c900e0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2227,7 +2227,15 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->window = htons(min(req->rcv_wnd, 65535U));
 
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
-	tcp_rsk(req)->ts_off = 1000 - TCP_SKB_CB(skb)->when;
+
+#ifdef CONFIG_SYN_COOKIES
+	if (tcp_rsk(req)->want_cookie_ts)
+		tcp_rsk(req)->ts_off = cookie_init_timestamp(req) -
+				       TCP_SKB_CB(skb)->when;
+	else
+#endif
+		tcp_rsk(req)->ts_off = 1000 - TCP_SKB_CB(skb)->when;
+
 	tcp_syn_build_options((__be32 *)(th + 1), dst_metric(dst, RTAX_ADVMSS), ireq->tstamp_ok,
 			      ireq->sack_ok, ireq->wscale_ok, ireq->rcv_wscale,
 			      TCP_SKB_CB(skb)->when + tcp_rsk(req)->ts_off,
-- 
1.5.4

