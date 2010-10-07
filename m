From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] neigh: speedup neigh_hh_init()
Date: Thu, 07 Oct 2010 14:53:28 +0200
Message-ID: <1286456008.2912.171.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57851 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082Ab0JGMxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 08:53:32 -0400
Received: by fxm4 with SMTP id 4so300121fxm.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 05:53:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a new dst is used to send a frame, neigh_resolve_output() tries to
associate an struct hh_cache to this dst, calling neigh_hh_init() with
the neigh rwlock write locked.

Most of the time, hh_cache is already known and linked into neighbour,
so we find it and increment its refcount.

This patch changes the logic so that we call neigh_hh_init() with
neighbour lock read locked only, so that fast path can be run in
parallel by concurrent cpus.

This brings part of the speedup we got with commit c7d4426a98a5f
(introduce DST_NOCACHE flag) for non cached dsts, even for cached ones,
removing one of the contention point that routers hit on multiqueue
enabled machines.

Further improvements would need to use a seqlock instead of an rwlock to
protect neigh->ha[], to not dirty neigh too often and remove two atomic
ops.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    6 ++
 net/core/dst.c            |    4 -
 net/core/neighbour.c      |   99 ++++++++++++++++++++++--------------
 3 files changed, 69 insertions(+), 40 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6abcef6..4160db3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -281,6 +281,12 @@ struct hh_cache {
 	unsigned long	hh_data[HH_DATA_ALIGN(LL_MAX_HEADER) / sizeof(long)];
 };
 
+static inline void hh_cache_put(struct hh_cache *hh)
+{
+	if (atomic_dec_and_test(&hh->hh_refcnt))
+		kfree(hh);
+}
+
 /* Reserve HH_DATA_MOD byte aligned hard_header_len, but at least that much.
  * Alternative is:
  *   dev->hard_header_len ? (dev->hard_header_len +
diff --git a/net/core/dst.c b/net/core/dst.c
index 6c41b1f..978a1ee 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -228,8 +228,8 @@ again:
 	child = dst->child;
 
 	dst->hh = NULL;
-	if (hh && atomic_dec_and_test(&hh->hh_refcnt))
-		kfree(hh);
+	if (hh)
+		hh_cache_put(hh);
 
 	if (neigh) {
 		dst->neighbour = NULL;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3ffafaa..53cc548 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -709,8 +709,7 @@ void neigh_destroy(struct neighbour *neigh)
 		write_seqlock_bh(&hh->hh_lock);
 		hh->hh_output = neigh_blackhole;
 		write_sequnlock_bh(&hh->hh_lock);
-		if (atomic_dec_and_test(&hh->hh_refcnt))
-			kfree(hh);
+		hh_cache_put(hh);
 	}
 
 	skb_queue_purge(&neigh->arp_queue);
@@ -1210,39 +1209,67 @@ struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 }
 EXPORT_SYMBOL(neigh_event_ns);
 
+static inline bool neigh_hh_lookup(struct neighbour *n, struct dst_entry *dst,
+				   __be16 protocol)
+{
+	struct hh_cache *hh;
+
+	for (hh = n->hh; hh; hh = hh->hh_next) {
+		if (hh->hh_type == protocol) {
+			atomic_inc(&hh->hh_refcnt);
+			if (unlikely(cmpxchg(&dst->hh, NULL, hh) != NULL))
+				hh_cache_put(hh);
+			return true;
+		}
+	}
+	return false;
+}
+
+/* called with read_lock_bh(&n->lock); */
 static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 			  __be16 protocol)
 {
 	struct hh_cache	*hh;
 	struct net_device *dev = dst->dev;
 
-	for (hh = n->hh; hh; hh = hh->hh_next)
-		if (hh->hh_type == protocol)
-			break;
+	if (likely(neigh_hh_lookup(n, dst, protocol)))
+		return;
 
-	if (!hh && (hh = kzalloc(sizeof(*hh), GFP_ATOMIC)) != NULL) {
-		seqlock_init(&hh->hh_lock);
-		hh->hh_type = protocol;
-		atomic_set(&hh->hh_refcnt, 0);
-		hh->hh_next = NULL;
+	/* slow path */
+	hh = kzalloc(sizeof(*hh), GFP_ATOMIC);
+	if (!hh)
+		return;
 
-		if (dev->header_ops->cache(n, hh)) {
-			kfree(hh);
-			hh = NULL;
-		} else {
-			atomic_inc(&hh->hh_refcnt);
-			hh->hh_next = n->hh;
-			n->hh	    = hh;
-			if (n->nud_state & NUD_CONNECTED)
-				hh->hh_output = n->ops->hh_output;
-			else
-				hh->hh_output = n->ops->output;
-		}
+	seqlock_init(&hh->hh_lock);
+	hh->hh_type = protocol;
+	atomic_set(&hh->hh_refcnt, 2);
+
+	if (dev->header_ops->cache(n, hh)) {
+		kfree(hh);
+		return;
 	}
-	if (hh)	{
-		atomic_inc(&hh->hh_refcnt);
-		dst->hh = hh;
+	read_unlock(&n->lock);
+	write_lock(&n->lock);
+	
+	/* must check if another thread already did the insert */
+	if (neigh_hh_lookup(n, dst, protocol)) {
+		kfree(hh);
+		goto end;
 	}
+
+	if (n->nud_state & NUD_CONNECTED)
+		hh->hh_output = n->ops->hh_output;
+	else
+		hh->hh_output = n->ops->output;
+
+	hh->hh_next = n->hh;
+	n->hh	    = hh;
+
+	if (unlikely(cmpxchg(&dst->hh, NULL, hh) != NULL))
+		hh_cache_put(hh);
+end:
+	write_unlock(&n->lock);
+	read_lock(&n->lock);
 }
 
 /* This function can be used in contexts, where only old dev_queue_xmit
@@ -1281,21 +1308,17 @@ int neigh_resolve_output(struct sk_buff *skb)
 	if (!neigh_event_send(neigh, skb)) {
 		int err;
 		struct net_device *dev = neigh->dev;
+
+		read_lock_bh(&neigh->lock);
 		if (dev->header_ops->cache &&
 		    !dst->hh &&
-		    !(dst->flags & DST_NOCACHE)) {
-			write_lock_bh(&neigh->lock);
-			if (!dst->hh)
-				neigh_hh_init(neigh, dst, dst->ops->protocol);
-			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
-					      neigh->ha, NULL, skb->len);
-			write_unlock_bh(&neigh->lock);
-		} else {
-			read_lock_bh(&neigh->lock);
-			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
-					      neigh->ha, NULL, skb->len);
-			read_unlock_bh(&neigh->lock);
-		}
+		    !(dst->flags & DST_NOCACHE))
+			neigh_hh_init(neigh, dst, dst->ops->protocol);
+
+		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+				      neigh->ha, NULL, skb->len);
+		read_unlock_bh(&neigh->lock);
+
 		if (err >= 0)
 			rc = neigh->ops->queue_xmit(skb);
 		else


