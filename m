From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next-2.6] syncookies: make v4/v6 synflood warning behaviour the same
Date: Thu,  3 Jun 2010 12:43:12 +0200
Message-ID: <1275561792-24179-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60309 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752771Ab0FCKpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:45:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

both syn_flood_warning functions print a message, but
ipv4 version only prints a warning if CONFIG_SYN_COOKIES=y.

Make the v4 one behave like the v6 one.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_ipv4.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 202cf09..a13f881 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -793,19 +793,20 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
-#ifdef CONFIG_SYN_COOKIES
-static void syn_flood_warning(struct sk_buff *skb)
+static void syn_flood_warning(const struct sk_buff *skb)
 {
-	static unsigned long warntime;
+	const char *msg;
 
-	if (time_after(jiffies, (warntime + HZ * 60))) {
-		warntime = jiffies;
-		printk(KERN_INFO
-		       "possible SYN flooding on port %d. Sending cookies.\n",
-		       ntohs(tcp_hdr(skb)->dest));
-	}
-}
+#ifdef CONFIG_SYN_COOKIES
+	if (sysctl_tcp_syncookies)
+		msg = "Sending cookies";
+	else
 #endif
+		msg = "Dropping request";
+
+	pr_info("TCP: Possible SYN flooding on port %d. %s.\n",
+				ntohs(tcp_hdr(skb)->dest), msg);
+}
 
 /*
  * Save and compile IPv4 options into the request_sock if needed.
@@ -1243,6 +1244,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * evidently real one.
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+		if (net_ratelimit())
+			syn_flood_warning(skb);
 #ifdef CONFIG_SYN_COOKIES
 		if (sysctl_tcp_syncookies) {
 			want_cookie = 1;
@@ -1328,7 +1331,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	if (want_cookie) {
 #ifdef CONFIG_SYN_COOKIES
-		syn_flood_warning(skb);
 		req->cookie_ts = tmp_opt.tstamp_ok;
 #endif
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
-- 
1.6.4.4

