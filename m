From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2] syncookies: print synflood warning if syn queue is full
Date: Fri, 16 Oct 2009 21:49:30 +0200
Message-ID: <1255722570-12803-1-git-send-email-fw@strlen.de>
References: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:44834 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751013AbZJPTuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 15:50:35 -0400
In-Reply-To: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always print a warning if the syn queue is full, just like
the tcp/ipv6 code does.

The "want_cookie" define is no longer needed -- gcc
removes the relevant branches in the CONFIG_SYN_COOKIES=n case.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_ipv4.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..93b02a3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -786,19 +786,19 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
-#ifdef CONFIG_SYN_COOKIES
 static void syn_flood_warning(struct sk_buff *skb)
 {
-	static unsigned long warntime;
-
-	if (time_after(jiffies, (warntime + HZ * 60))) {
-		warntime = jiffies;
+#ifdef CONFIG_SYN_COOKIES
+	if (sysctl_tcp_syncookies)
 		printk(KERN_INFO
-		       "possible SYN flooding on port %d. Sending cookies.\n",
-		       ntohs(tcp_hdr(skb)->dest));
-	}
-}
+		       "Possible SYN flooding on port %d. "
+		       "Sending cookies.\n", ntohs(tcp_hdr(skb)->dest));
+	else
 #endif
+		printk(KERN_INFO
+		       "Possible SYN flooding on port %d. "
+		       "Dropping request.\n", ntohs(tcp_hdr(skb)->dest));
+}
 
 /*
  * Save and compile IPv4 options into the request_sock if needed.
@@ -1217,11 +1217,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
-#ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
-#else
-#define want_cookie 0 /* Argh, why doesn't gcc optimize this :( */
-#endif
 
 	/* Never answer to SYNs send to broadcast or multicast */
 	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
@@ -1232,6 +1228,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * evidently real one.
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+		if (net_ratelimit())
+			syn_flood_warning(skb);
 #ifdef CONFIG_SYN_COOKIES
 		if (sysctl_tcp_syncookies) {
 			want_cookie = 1;
@@ -1283,10 +1281,9 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	if (want_cookie) {
 #ifdef CONFIG_SYN_COOKIES
-		syn_flood_warning(skb);
 		req->cookie_ts = tmp_opt.tstamp_ok;
-#endif
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
+#endif
 	} else if (!isn) {
 		struct inet_peer *peer = NULL;
 
-- 
1.6.3.3

