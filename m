From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: avoid RCU for NOCACHE dst
Date: Fri, 15 Oct 2010 17:44:11 +0200
Message-ID: <1287157451.2647.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47243 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275Ab0JOPoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 11:44:15 -0400
Received: by wyb28 with SMTP id 28so773380wyb.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 08:44:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no point using RCU for dst we allocate for a very short time
(used once).

Change dst_release() to take DST_NOCACHE into account, but also change
skb_dst_set_noref() to force a refcount increment for such dst.

This is a _huge_ gain, because we dont waste memory to store xx thousand
of dsts. Instead of queueing them to RCU, we can free them instantly. 

CPU caches can stay hot, re-using same memory blocks to hold temporary
dsts.

Note : remove unneeded smp_mb__before_atomic_dec(); in dst_release(),
since atomic_dec_return() implies a full memory barrier.

Stress test, 160.000.000 udp frames sent, IP route cache disabled
(DDOS).

Before:

real    0m38.091s
user    0m13.189s
sys     7m53.018s

After:

real	0m29.946s
user	0m12.157s
sys	7m40.605s

For reference, if IP route cache was enabled :

real	0m32.030s
user	0m10.521s
sys	8m15.243s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |   14 +-------------
 net/core/dst.c         |   29 ++++++++++++++++++++++++++++-
 net/ipv4/route.c       |    9 ++++-----
 3 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0b53c43..9ccbbbd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -460,19 +460,7 @@ static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
 	skb->_skb_refdst = (unsigned long)dst;
 }
 
-/**
- * skb_dst_set_noref - sets skb dst, without a reference
- * @skb: buffer
- * @dst: dst entry
- *
- * Sets skb dst, assuming a reference was not taken on dst
- * skb_dst_drop() should not dst_release() this dst
- */
-static inline void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
-{
-	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
-	skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
-}
+extern void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst);
 
 /**
  * skb_dst_is_noref - Test if skb dst isnt refcounted
diff --git a/net/core/dst.c b/net/core/dst.c
index 32e542d..8abe628 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -271,13 +271,40 @@ void dst_release(struct dst_entry *dst)
 	if (dst) {
 		int newrefcnt;
 
-		smp_mb__before_atomic_dec();
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		WARN_ON(newrefcnt < 0);
+		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt) {
+			dst = dst_destroy(dst);
+			if (dst)
+				__dst_free(dst);
+		}
 	}
 }
 EXPORT_SYMBOL(dst_release);
 
+/**
+ * skb_dst_set_noref - sets skb dst, without a reference
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was not taken on dst
+ * skb_dst_drop() should not dst_release() this dst
+ */
+void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
+{
+	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
+	/* If dst not in cache, we must take a reference, because
+	 * dst_release() will destroy dst as soon as its refcount becomes zero
+	 */
+	if (unlikely(dst->flags & DST_NOCACHE)) {
+		dst_hold(dst);
+		skb_dst_set(skb, dst);
+	} else {
+		skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
+	}
+}
+EXPORT_SYMBOL(skb_dst_set_noref);
+
 /* Dirty hack. We did it in 2.2 (in __dst_free),
  * we have _very_ good reasons not to repeat
  * this mistake in 2.3, but we have no choice
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0755aa4..f2ce07b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1105,9 +1105,9 @@ restart:
 		 * Note that we do rt_free on this new route entry, so that
 		 * once its refcount hits zero, we are still able to reap it
 		 * (Thanks Alexey)
-		 * Note also the rt_free uses call_rcu.  We don't actually
-		 * need rcu protection here, this is just our path to get
-		 * on the route gc list.
+		 * Note: To avoid expensive rcu stuff for this uncached dst,
+		 * we set DST_NOCACHE so that dst_release() can free dst without
+		 * waiting a grace period.
 		 */
 
 		rt->dst.flags |= DST_NOCACHE;
@@ -1117,12 +1117,11 @@ restart:
 				if (net_ratelimit())
 					printk(KERN_WARNING
 					    "Neighbour table failure & not caching routes.\n");
-				rt_drop(rt);
+				ip_rt_put(rt);
 				return err;
 			}
 		}
 
-		rt_free(rt);
 		goto skip_hashing;
 	}
 


