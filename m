From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: build_ehash_secret() and rt_bind_peer()
 cleanups
Date: Thu, 19 Aug 2010 17:46:55 +0200
Message-ID: <1282232815.2549.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50204 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab0HSPrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 11:47:00 -0400
Received: by eyg5 with SMTP id 5so1370728eyg.19
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 08:46:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now cmpxchg() is available on all arches, we can use it in
build_ehash_secret() and rt_bind_peer() instead of using spinlocks.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
---
 net/ipv4/af_inet.c |    8 +++-----
 net/ipv4/route.c   |   11 +++--------
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6a1100c..f581f77 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -227,18 +227,16 @@ EXPORT_SYMBOL(inet_ehash_secret);
 
 /*
  * inet_ehash_secret must be set exactly once
- * Instead of using a dedicated spinlock, we (ab)use inetsw_lock
  */
 void build_ehash_secret(void)
 {
 	u32 rnd;
+
 	do {
 		get_random_bytes(&rnd, sizeof(rnd));
 	} while (rnd == 0);
-	spin_lock_bh(&inetsw_lock);
-	if (!inet_ehash_secret)
-		inet_ehash_secret = rnd;
-	spin_unlock_bh(&inetsw_lock);
+
+	cmpxchg(&inet_ehash_secret, 0, rnd);
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3f56b6e..ae3dba7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1268,18 +1268,13 @@ skip_hashing:
 
 void rt_bind_peer(struct rtable *rt, int create)
 {
-	static DEFINE_SPINLOCK(rt_peer_lock);
 	struct inet_peer *peer;
 
 	peer = inet_getpeer(rt->rt_dst, create);
 
-	spin_lock_bh(&rt_peer_lock);
-	if (rt->peer == NULL) {
-		rt->peer = peer;
-		peer = NULL;
-	}
-	spin_unlock_bh(&rt_peer_lock);
-	if (peer)
+	peer = cmpxchg(&rt->peer, NULL, peer);
+
+	if (unlikely(peer))
 		inet_putpeer(peer);
 }
 


