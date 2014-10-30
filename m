From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] syncookies: only increment SYNCOOKIESFAILED on validation error
Date: Thu, 30 Oct 2014 02:55:38 +0100
Message-ID: <1414634138-23238-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37333 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756973AbaJ3Bzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 21:55:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only count packets that failed cookie-authentication.
We can get SYNCOOKIESFAILED > 0 while we never even sent a single cookie.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/syncookies.c | 7 +++++--
 net/ipv6/syncookies.c | 7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 32b98d0..4ac7bca 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -275,8 +275,11 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
 
-	if (tcp_synq_no_recent_overflow(sk) ||
-	    (mss = __cookie_v4_check(ip_hdr(skb), th, cookie)) == 0) {
+	if (tcp_synq_no_recent_overflow(sk))
+		goto out;
+
+	mss = __cookie_v4_check(ip_hdr(skb), th, cookie);
+	if (mss == 0) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
 	}
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 0e26e79..be291ba 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -171,8 +171,11 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
 
-	if (tcp_synq_no_recent_overflow(sk) ||
-		(mss = __cookie_v6_check(ipv6_hdr(skb), th, cookie)) == 0) {
+	if (tcp_synq_no_recent_overflow(sk))
+		goto out;
+
+	mss = __cookie_v6_check(ipv6_hdr(skb), th, cookie);
+	if (mss == 0) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
 	}
-- 
2.0.4
