From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] ipv4: Restore old dst_free() behavior.
Date: Tue, 31 Jul 2012 13:08:23 +0200
Message-ID: <1343732903.21269.190.camel@edumazet-glaptop>
References: <20120730.223827.74792864437911339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35731 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab2GaLI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 07:08:27 -0400
Received: by bkwj10 with SMTP id j10so3228100bkw.19
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 04:08:26 -0700 (PDT)
In-Reply-To: <20120730.223827.74792864437911339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Mon, 2012-07-30 at 22:38 -0700, David Miller wrote:
> Eric, this is what I'd like to propose.
> 
> It seems the problem you were likely running into was simply
> the fact that we were not inserting an RCU grace period for
> the dst_free() that we do when purging a FIB nexthop.
> 
> So this reverts your change, and instead adds the necessary
> call_rcu_bh() wrapper around the dst_free() done in fib_semantics.c
> 
> That makes it so that we don't need all of that inc_not_zero stuff for
> sockets, and the special dst flag.  If we set the pointer to NULL,
> then do the dst_free() via RCU, we can test that refcount safely in
> dst_free() since it can only decrease at that point.
> 
> What do you think?  Does it pass your tests?

It doesnt.

But I believe I found why, thats the good news ;)

In the past, we used RCU only for input routes, thats why using
call_rcu_bh() was OK.

But now we alse cache output routes, we must use call_rcu(), because
on output path we use rcu_read_lock() 'only', in process context,
not from softirq handler.

If you dont mind, I would like to keep inet_sk_rx_dst_set() helper
because I believe its cleaner and I'll probably add IPv6 stuff on it
(the cookie thing)

Also I added __rcu attributes to nh_rth_output and nh_rth_input to
better document what is going on in this code.

Thanks

[PATCH v2] ipv4: Restore old dst_free() behavior

commit 404e0a8b6a55 (net: ipv4: fix RCU races on dst refcounts) tried
to solve a race but added a problem at device/fib dismantle time :

We really want to call dst_free() as soon as possible, even if sockets
still have dst in their cache.
dst_release() calls in free_fib_info_rcu() are not welcomed.

Root of the problem was that now we also cache output routes (in
nh_rth_output), we must use call_rcu() instead of call_rcu_bh() in
rt_free(), because output route lookups are done in process context.

Based on feedback and initial patch from David Miller (adding another
call_rcu_bh() call in fib, but it appears it was not the right fix)

I left the inet_sk_rx_dst_set() helper and added __rcu attributes
to nh_rth_output and nh_rth_input to better document what is going on in
this code.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/dst.h        |    7 ++++++-
 include/net/inet_sock.h  |   10 +++-------
 include/net/ip_fib.h     |    4 ++--
 net/core/dst.c           |   26 +++++---------------------
 net/decnet/dn_route.c    |    6 ------
 net/ipv4/fib_semantics.c |   21 +++++++++++++++++----
 net/ipv4/route.c         |   26 +++++++++++++++++---------
 7 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 31a9fd3..baf5978 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -61,7 +61,6 @@ struct dst_entry {
 #define DST_NOPEER		0x0040
 #define DST_FAKE_RTABLE		0x0080
 #define DST_XFRM_TUNNEL		0x0100
-#define DST_RCU_FREE		0x0200
 
 	unsigned short		pending_confirm;
 
@@ -383,6 +382,12 @@ static inline void dst_free(struct dst_entry *dst)
 	__dst_free(dst);
 }
 
+static inline void dst_rcu_free(struct rcu_head *head)
+{
+	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
+	dst_free(dst);
+}
+
 static inline void dst_confirm(struct dst_entry *dst)
 {
 	dst->pending_confirm = 1;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e3fd34c..83b567f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -253,13 +253,9 @@ static inline void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb
 {
 	struct dst_entry *dst = skb_dst(skb);
 
-	if (atomic_inc_not_zero(&dst->__refcnt)) {
-		if (!(dst->flags & DST_RCU_FREE))
-			dst->flags |= DST_RCU_FREE;
-
-		sk->sk_rx_dst = dst;
-		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-	}
+	dst_hold(dst);
+	sk->sk_rx_dst = dst;
+	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 }
 
 #endif	/* _INET_SOCK_H */
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e69c3a4..e521a03 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -81,8 +81,8 @@ struct fib_nh {
 	__be32			nh_gw;
 	__be32			nh_saddr;
 	int			nh_saddr_genid;
-	struct rtable		*nh_rth_output;
-	struct rtable		*nh_rth_input;
+	struct rtable __rcu	*nh_rth_output;
+	struct rtable __rcu	*nh_rth_input;
 	struct fnhe_hash_bucket	*nh_exceptions;
 };
 
diff --git a/net/core/dst.c b/net/core/dst.c
index d9e33eb..069d51d 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -258,15 +258,6 @@ again:
 }
 EXPORT_SYMBOL(dst_destroy);
 
-static void dst_rcu_destroy(struct rcu_head *head)
-{
-	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
-
-	dst = dst_destroy(dst);
-	if (dst)
-		__dst_free(dst);
-}
-
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
@@ -274,14 +265,10 @@ void dst_release(struct dst_entry *dst)
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		WARN_ON(newrefcnt < 0);
-		if (unlikely(dst->flags & (DST_NOCACHE | DST_RCU_FREE)) && !newrefcnt) {
-			if (dst->flags & DST_RCU_FREE) {
-				call_rcu_bh(&dst->rcu_head, dst_rcu_destroy);
-			} else {
-				dst = dst_destroy(dst);
-				if (dst)
-					__dst_free(dst);
-			}
+		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt) {
+			dst = dst_destroy(dst);
+			if (dst)
+				__dst_free(dst);
 		}
 	}
 }
@@ -333,14 +320,11 @@ EXPORT_SYMBOL(__dst_destroy_metrics_generic);
  */
 void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
 {
-	bool hold;
-
 	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
 	/* If dst not in cache, we must take a reference, because
 	 * dst_release() will destroy dst as soon as its refcount becomes zero
 	 */
-	hold = (dst->flags & (DST_NOCACHE | DST_RCU_FREE)) == DST_NOCACHE;
-	if (unlikely(hold)) {
+	if (unlikely(dst->flags & DST_NOCACHE)) {
 		dst_hold(dst);
 		skb_dst_set(skb, dst);
 	} else {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 2671977..85a3604 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -184,12 +184,6 @@ static __inline__ unsigned int dn_hash(__le16 src, __le16 dst)
 	return dn_rt_hash_mask & (unsigned int)tmp;
 }
 
-static inline void dst_rcu_free(struct rcu_head *head)
-{
-	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
-	dst_free(dst);
-}
-
 static inline void dnrt_free(struct dn_route *rt)
 {
 	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index e55171f..625cf18 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -161,6 +161,21 @@ static void free_nh_exceptions(struct fib_nh *nh)
 	kfree(hash);
 }
 
+static void rt_nexthop_free(struct rtable __rcu **rtp)
+{
+	struct rtable *rt = rcu_dereference_protected(*rtp, 1);
+
+	if (!rt)
+		return;
+
+	/* Not even needed : RCU_INIT_POINTER(*rtp, NULL);
+	 * because we waited an RCU grace period before calling
+	 * free_fib_info_rcu()
+	 */
+
+	dst_free(&rt->dst);
+}
+
 /* Release a nexthop info record */
 static void free_fib_info_rcu(struct rcu_head *head)
 {
@@ -171,10 +186,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 			dev_put(nexthop_nh->nh_dev);
 		if (nexthop_nh->nh_exceptions)
 			free_nh_exceptions(nexthop_nh);
-		if (nexthop_nh->nh_rth_output)
-			dst_release(&nexthop_nh->nh_rth_output->dst);
-		if (nexthop_nh->nh_rth_input)
-			dst_release(&nexthop_nh->nh_rth_input->dst);
+		rt_nexthop_free(&nexthop_nh->nh_rth_output);
+		rt_nexthop_free(&nexthop_nh->nh_rth_input);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d6eabcf..2bd1074 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1199,23 +1199,31 @@ restart:
 	fnhe->fnhe_stamp = jiffies;
 }
 
+static inline void rt_free(struct rtable *rt)
+{
+	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
+}
+
 static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 {
-	struct rtable *orig, *prev, **p = &nh->nh_rth_output;
+	struct rtable *orig, *prev, **p = (struct rtable **)&nh->nh_rth_output;
 
 	if (rt_is_input_route(rt))
-		p = &nh->nh_rth_input;
+		p = (struct rtable **)&nh->nh_rth_input;
 
 	orig = *p;
 
-	rt->dst.flags |= DST_RCU_FREE;
-	dst_hold(&rt->dst);
 	prev = cmpxchg(p, orig, rt);
 	if (prev == orig) {
 		if (orig)
-			dst_release(&orig->dst);
+			rt_free(orig);
 	} else {
-		dst_release(&rt->dst);
+		/* Routes we intend to cache in the FIB nexthop have
+		 * the DST_NOCACHE bit clear.  However, if we are
+		 * unsuccessful at storing this route into the cache
+		 * we really need to set it.
+		 */
+		rt->dst.flags |= DST_NOCACHE;
 	}
 }
 
@@ -1412,7 +1420,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	do_cache = false;
 	if (res->fi) {
 		if (!itag) {
-			rth = FIB_RES_NH(*res).nh_rth_input;
+			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
 			if (rt_cache_valid(rth)) {
 				skb_dst_set_noref(skb, &rth->dst);
 				goto out;
@@ -1574,7 +1582,7 @@ local_input:
 	do_cache = false;
 	if (res.fi) {
 		if (!itag) {
-			rth = FIB_RES_NH(res).nh_rth_input;
+			rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
 			if (rt_cache_valid(rth)) {
 				skb_dst_set_noref(skb, &rth->dst);
 				err = 0;
@@ -1742,7 +1750,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (fi) {
 		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
 		if (!fnhe) {
-			rth = FIB_RES_NH(*res).nh_rth_output;
+			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_output);
 			if (rt_cache_valid(rth)) {
 				dst_hold(&rth->dst);
 				return rth;
