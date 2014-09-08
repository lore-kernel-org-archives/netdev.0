From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] inet: remove dead inetpeer sequence code
Date: Mon,  8 Sep 2014 19:08:34 -0400
Message-ID: <1410217714-26421-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:36489 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbaIHXIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 19:08:47 -0400
Received: by mail-yh0-f73.google.com with SMTP id a41so161234yho.0
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 16:08:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inetpeer sequence numbers are no longer incremented, so no need to
check and flush the tree. The function that increments the sequence
number was already dead code and removed in in "ipv4: remove unused
function" (068a6e18). Remove the code that checks for a change, too.

Verifying that v4_seq and v6_seq are never incremented and thus that
flush_check compares bp->flush_seq to 0 is trivial.

The second part of the change removes flush_check completely even
though bp->flush_seq is exactly !0 once, at initialization. This
change is correct because the time this branch is true is when
bp->root == peer_avl_empty_rcu, in which the branch and
inetpeer_invalidate_tree are a NOOP.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/inetpeer.h |  1 -
 net/ipv4/inetpeer.c    | 21 ---------------------
 2 files changed, 22 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 01d590e..80479ab 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -61,7 +61,6 @@ struct inet_peer {
 struct inet_peer_base {
 	struct inet_peer __rcu	*root;
 	seqlock_t		lock;
-	u32			flush_seq;
 	int			total;
 };
 
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index bd5f592..241afd7 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -72,29 +72,10 @@ void inet_peer_base_init(struct inet_peer_base *bp)
 {
 	bp->root = peer_avl_empty_rcu;
 	seqlock_init(&bp->lock);
-	bp->flush_seq = ~0U;
 	bp->total = 0;
 }
 EXPORT_SYMBOL_GPL(inet_peer_base_init);
 
-static atomic_t v4_seq = ATOMIC_INIT(0);
-static atomic_t v6_seq = ATOMIC_INIT(0);
-
-static atomic_t *inetpeer_seq_ptr(int family)
-{
-	return (family == AF_INET ? &v4_seq : &v6_seq);
-}
-
-static inline void flush_check(struct inet_peer_base *base, int family)
-{
-	atomic_t *fp = inetpeer_seq_ptr(family);
-
-	if (unlikely(base->flush_seq != atomic_read(fp))) {
-		inetpeer_invalidate_tree(base);
-		base->flush_seq = atomic_read(fp);
-	}
-}
-
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
 /* Exported for sysctl_net_ipv4.  */
@@ -444,8 +425,6 @@ struct inet_peer *inet_getpeer(struct inet_peer_base *base,
 	unsigned int sequence;
 	int invalidated, gccnt = 0;
 
-	flush_check(base, daddr->family);
-
 	/* Attempt a lockless lookup first.
 	 * Because of a concurrent writer, we might not find an existing entry.
 	 */
-- 
2.1.0.rc2.206.gedb03e5
