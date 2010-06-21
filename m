From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2] syncookies: do not store rcv_wscale in tcp timestamp
Date: Mon, 21 Jun 2010 23:48:44 +0200
Message-ID: <1277156925-7295-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40540 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932653Ab0FUVvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 17:51:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Fernando Gont there is no need to encode rcv_wscale
into the cookie.

We did not use the restored rcv_wscale anyway; it is recomputed
via tcp_select_initial_window().

Thus we can save 4 bits in the ts option space by removing rcv_wscale.
In case window scaling was not supported, we set the (invalid) wscale
value 0xf.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/syncookies.c |   35 ++++++++++++++---------------------
 net/ipv6/syncookies.c |    1 -
 2 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 51b5662..8896329 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -18,8 +18,8 @@
 #include <net/tcp.h>
 #include <net/route.h>
 
-/* Timestamps: lowest 9 bits store TCP options */
-#define TSBITS 9
+/* Timestamps: lowest bits store TCP options */
+#define TSBITS 5
 #define TSMASK (((__u32)1 << TSBITS) - 1)
 
 extern int sysctl_tcp_syncookies;
@@ -58,7 +58,7 @@ static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 
 /*
  * when syncookies are in effect and tcp timestamps are enabled we encode
- * tcp options in the lowest 9 bits of the timestamp value that will be
+ * tcp options in the lower bits of the timestamp value that will be
  * sent in the syn-ack.
  * Since subsequent timestamps use the normal tcp_time_stamp value, we
  * must make sure that the resulting initial timestamp is <= tcp_time_stamp.
@@ -70,11 +70,9 @@ __u32 cookie_init_timestamp(struct request_sock *req)
 	u32 options = 0;
 
 	ireq = inet_rsk(req);
-	if (ireq->wscale_ok) {
-		options = ireq->snd_wscale;
-		options |= ireq->rcv_wscale << 4;
-	}
-	options |= ireq->sack_ok << 8;
+
+	options = ireq->wscale_ok ? ireq->snd_wscale : 0xf;
+	options |= ireq->sack_ok << 4;
 
 	ts = ts_now & ~TSMASK;
 	ts |= options;
@@ -227,15 +225,14 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  * additional tcp options in the timestamp.
  * This extracts these options from the timestamp echo.
  *
- * The lowest 4 bits are for snd_wscale
- * The next 4 lsb are for rcv_wscale
+ * The lowest 4 bits store snd_wscale.
  * The next lsb is for sack_ok
  *
  * return false if we decode an option that should not be.
  */
 bool cookie_check_timestamp(struct tcp_options_received *tcp_opt)
 {
-	/* echoed timestamp, 9 lowest bits contain options */
+	/* echoed timestamp, lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr & TSMASK;
 
 	if (!tcp_opt->saw_tstamp)  {
@@ -246,20 +243,17 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt)
 	if (!sysctl_tcp_timestamps)
 		return false;
 
-	tcp_opt->snd_wscale = options & 0xf;
-	options >>= 4;
-	tcp_opt->rcv_wscale = options & 0xf;
-
 	tcp_opt->sack_ok = (options >> 4) & 0x1;
 
 	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
 		return false;
 
-	if (tcp_opt->snd_wscale || tcp_opt->rcv_wscale) {
-		tcp_opt->wscale_ok = 1;
-		return sysctl_tcp_window_scaling != 0;
-	}
-	return true;
+	if ((options & 0xf) == 0xf)
+		return true; /* no window scaling */
+
+	tcp_opt->wscale_ok = 1;
+	tcp_opt->snd_wscale = options & 0xf;
+	return sysctl_tcp_window_scaling != 0;
 }
 EXPORT_SYMBOL(cookie_check_timestamp);
 
@@ -313,7 +307,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
 	ireq->ecn_ok		= 0;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
-	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
 	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index c7ee574..84d818c 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -217,7 +217,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	req->retrans = 0;
 	ireq->ecn_ok		= 0;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
-	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
 	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
-- 
1.7.1

