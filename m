From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next-2.6] syncookies: avoid unneeded tcp header flag double check
Date: Thu,  3 Jun 2010 12:43:44 +0200
Message-ID: <1275561824-24227-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60310 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753937Ab0FCKpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:45:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

caller: if (!th->rst && !th->syn && th->ack)
callee: if (!th->ack)

make the caller only check for !syn (common for 3whs), and move
the !rst / ack test to the callee.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/syncookies.c |    2 +-
 net/ipv4/tcp_ipv4.c   |    2 +-
 net/ipv6/syncookies.c |    2 +-
 net/ipv6/tcp_ipv6.c   |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5c24db4..c9dac86 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -266,7 +266,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	struct rtable *rt;
 	__u8 rcv_wscale;
 
-	if (!sysctl_tcp_syncookies || !th->ack)
+	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
 
 	if (tcp_synq_no_recent_overflow(sk) ||
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a13f881..6558dfd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1506,7 +1506,7 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	}
 
 #ifdef CONFIG_SYN_COOKIES
-	if (!th->rst && !th->syn && th->ack)
+	if (!th->syn)
 		sk = cookie_v4_check(sk, skb, &(IPCB(skb)->opt));
 #endif
 	return sk;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 1238370..9fcb3ec 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -174,7 +174,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
 
-	if (!sysctl_tcp_syncookies || !th->ack)
+	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
 
 	if (tcp_synq_no_recent_overflow(sk) ||
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e487080..5887141 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1157,7 +1157,7 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 	}
 
 #ifdef CONFIG_SYN_COOKIES
-	if (!th->rst && !th->syn && th->ack)
+	if (!th->syn)
 		sk = cookie_v6_check(sk, skb);
 #endif
 	return sk;
-- 
1.6.4.4

