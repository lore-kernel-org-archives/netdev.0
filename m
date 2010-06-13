From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next-2.6] syncookies: check decoded options against sysctl settings
Date: Sun, 13 Jun 2010 23:34:35 +0200
Message-ID: <1276464875-4460-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:52689 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752152Ab0FMVq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 17:46:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Discard the ACK if we find options that do not match current sysctl
settings.

Previously it was possible to create a connection with sack,
wscale, etc. enabled even if the feature was disabled via sysctl.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h     |    2 +-
 net/ipv4/syncookies.c |   25 +++++++++++++++++++------
 net/ipv6/syncookies.c |    4 ++--
 3 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5731664..cca040e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -464,7 +464,7 @@ extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb,
 				     __u16 *mss);
 
 extern __u32 cookie_init_timestamp(struct request_sock *req);
-extern void cookie_check_timestamp(struct tcp_options_received *tcp_opt);
+extern bool cookie_check_timestamp(struct tcp_options_received *tcp_opt);
 
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 02bef6a..51b5662 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -230,23 +230,36 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  * The lowest 4 bits are for snd_wscale
  * The next 4 lsb are for rcv_wscale
  * The next lsb is for sack_ok
+ *
+ * return false if we decode an option that should not be.
  */
-void cookie_check_timestamp(struct tcp_options_received *tcp_opt)
+bool cookie_check_timestamp(struct tcp_options_received *tcp_opt)
 {
 	/* echoed timestamp, 9 lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr & TSMASK;
 
+	if (!tcp_opt->saw_tstamp)  {
+		tcp_clear_options(tcp_opt);
+		return true;
+	}
+
+	if (!sysctl_tcp_timestamps)
+		return false;
+
 	tcp_opt->snd_wscale = options & 0xf;
 	options >>= 4;
 	tcp_opt->rcv_wscale = options & 0xf;
 
 	tcp_opt->sack_ok = (options >> 4) & 0x1;
 
-	if (tcp_opt->sack_ok)
-		tcp_sack_reset(tcp_opt);
+	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
+		return false;
 
-	if (tcp_opt->snd_wscale || tcp_opt->rcv_wscale)
+	if (tcp_opt->snd_wscale || tcp_opt->rcv_wscale) {
 		tcp_opt->wscale_ok = 1;
+		return sysctl_tcp_window_scaling != 0;
+	}
+	return true;
 }
 EXPORT_SYMBOL(cookie_check_timestamp);
 
@@ -281,8 +294,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
 
-	if (tcp_opt.saw_tstamp)
-		cookie_check_timestamp(&tcp_opt);
+	if (!cookie_check_timestamp(&tcp_opt))
+		goto out;
 
 	ret = NULL;
 	req = inet_reqsk_alloc(&tcp_request_sock_ops); /* for safety */
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 70d330f..c7ee574 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -180,8 +180,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
 
-	if (tcp_opt.saw_tstamp)
-		cookie_check_timestamp(&tcp_opt);
+	if (!cookie_check_timestamp(&tcp_opt))
+		goto out;
 
 	ret = NULL;
 	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
-- 
1.6.4.4

