From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 05 Jun 2012 11:28:27 +0200
Message-ID: <1338888507.2760.2146.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57195 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516Ab2FEJ2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 05:28:32 -0400
Received: by bkcji2 with SMTP id ji2so4409159bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 02:28:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
the routing cache) added a race :

Before freeing an inetpeer, we must respect a RCU grace period, and make
sure no user will attempt to increase refcnt.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/inetpeer.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index d4d61b6..f936e95 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -108,6 +108,11 @@ int inet_peer_threshold __read_mostly = 65536 + 128;	/* start to throw entries m
 int inet_peer_minttl __read_mostly = 120 * HZ;	/* TTL under high load: 120 sec */
 int inet_peer_maxttl __read_mostly = 10 * 60 * HZ;	/* usual time to live: 10 min */
 
+static void inetpeer_free_rcu(struct rcu_head *head)
+{
+	kmem_cache_free(peer_cachep, container_of(head, struct inet_peer, rcu));
+}
+
 static void inetpeer_gc_worker(struct work_struct *work)
 {
 	struct inet_peer *p, *n;
@@ -137,9 +142,9 @@ static void inetpeer_gc_worker(struct work_struct *work)
 
 		n = list_entry(p->gc_list.next, struct inet_peer, gc_list);
 
-		if (!atomic_read(&p->refcnt)) {
+		if (atomic_cmpxchg(&p->refcnt, 0, -1) == 0) {
 			list_del(&p->gc_list);
-			kmem_cache_free(peer_cachep, p);
+			call_rcu(&p->rcu, inetpeer_free_rcu);
 		}
 	}
 
@@ -364,11 +369,6 @@ do {								\
 	peer_avl_rebalance(stack, stackptr, base);		\
 } while (0)
 
-static void inetpeer_free_rcu(struct rcu_head *head)
-{
-	kmem_cache_free(peer_cachep, container_of(head, struct inet_peer, rcu));
-}
-
 static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base,
 			     struct inet_peer __rcu **stack[PEER_MAXDEPTH])
 {
