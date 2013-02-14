From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/7] xfrm: Add a state resolution packet queue
Date: Thu, 14 Feb 2013 12:47:24 +0100
Message-ID: <1360842447-3344-5-git-send-email-steffen.klassert@secunet.com>
References: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44538 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759576Ab3BNLrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 06:47:55 -0500
In-Reply-To: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the default, we blackhole packets until the key manager resolves
the states. This patch implements a packet queue where IPsec packets
are queued until the states are resolved. We generate a dummy xfrm
bundle, the output routine of the returned route enqueues the packet
to a per policy queue and arms a timer that checks for state resolution
when dst_output() is called. Once the states are resolved, the packets
are sent out of the queue. If the states are not resolved after some
time, the queue is flushed.

This patch keeps the defaut behaviour to blackhole packets as long
as we have no states. To enable the packet queue the sysctl
xfrm_larval_drop must be switched off.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |    1 +
 include/net/xfrm.h     |    7 ++
 net/xfrm/xfrm_policy.c |  229 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 233 insertions(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 9a78810..3da47e0 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -61,6 +61,7 @@ struct dst_entry {
 #define DST_NOPEER		0x0040
 #define DST_FAKE_RTABLE		0x0080
 #define DST_XFRM_TUNNEL		0x0100
+#define DST_XFRM_QUEUE		0x0200
 
 	unsigned short		pending_confirm;
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 814a1ba..30f3e5b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -501,6 +501,12 @@ struct xfrm_policy_walk {
 	u32 seq;
 };
 
+struct xfrm_policy_queue {
+	struct sk_buff_head	hold_queue;
+	struct timer_list	hold_timer;
+	unsigned long		timeout;
+};
+
 struct xfrm_policy {
 #ifdef CONFIG_NET_NS
 	struct net		*xp_net;
@@ -522,6 +528,7 @@ struct xfrm_policy {
 	struct xfrm_lifetime_cfg lft;
 	struct xfrm_lifetime_cur curlft;
 	struct xfrm_policy_walk_entry walk;
+	struct xfrm_policy_queue polq;
 	u8			type;
 	u8			action;
 	u8			flags;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 41eabc4..456b11b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -35,6 +35,10 @@
 
 #include "xfrm_hash.h"
 
+#define XFRM_QUEUE_TMO_MIN ((unsigned)(HZ/10))
+#define XFRM_QUEUE_TMO_MAX ((unsigned)(60*HZ))
+#define XFRM_MAX_QUEUE_LEN	100
+
 DEFINE_MUTEX(xfrm_cfg_mutex);
 EXPORT_SYMBOL(xfrm_cfg_mutex);
 
@@ -51,7 +55,7 @@ static struct kmem_cache *xfrm_dst_cache __read_mostly;
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
 static int xfrm_bundle_ok(struct xfrm_dst *xdst);
-
+static void xfrm_policy_queue_process(unsigned long arg);
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
@@ -287,8 +291,11 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
 		atomic_set(&policy->refcnt, 1);
+		skb_queue_head_init(&policy->polq.hold_queue);
 		setup_timer(&policy->timer, xfrm_policy_timer,
 				(unsigned long)policy);
+		setup_timer(&policy->polq.hold_timer, xfrm_policy_queue_process,
+			    (unsigned long)policy);
 		policy->flo.ops = &xfrm_policy_fc_ops;
 	}
 	return policy;
@@ -309,6 +316,16 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 }
 EXPORT_SYMBOL(xfrm_policy_destroy);
 
+static void xfrm_queue_purge(struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(list)) != NULL) {
+		dev_put(skb->dev);
+		kfree_skb(skb);
+	}
+}
+
 /* Rule must be locked. Release descentant resources, announce
  * entry dead. The rule must be unlinked from lists to the moment.
  */
@@ -319,6 +336,9 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 
 	atomic_inc(&policy->genid);
 
+	del_timer(&policy->polq.hold_timer);
+	xfrm_queue_purge(&policy->polq.hold_queue);
+
 	if (del_timer(&policy->timer))
 		xfrm_pol_put(policy);
 
@@ -562,6 +582,31 @@ static inline int selector_cmp(struct xfrm_selector *s1, struct xfrm_selector *s
 	return 0;
 }
 
+static void xfrm_policy_requeue(struct xfrm_policy *old,
+				struct xfrm_policy *new)
+{
+	struct xfrm_policy_queue *pq = &old->polq;
+	struct sk_buff_head list;
+
+	__skb_queue_head_init(&list);
+
+	spin_lock_bh(&pq->hold_queue.lock);
+	skb_queue_splice_init(&pq->hold_queue, &list);
+	del_timer(&pq->hold_timer);
+	spin_unlock_bh(&pq->hold_queue.lock);
+
+	if (skb_queue_empty(&list))
+		return;
+
+	pq = &new->polq;
+
+	spin_lock_bh(&pq->hold_queue.lock);
+	skb_queue_splice(&list, &pq->hold_queue);
+	pq->timeout = XFRM_QUEUE_TMO_MIN;
+	mod_timer(&pq->hold_timer, jiffies);
+	spin_unlock_bh(&pq->hold_queue.lock);
+}
+
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 {
 	struct net *net = xp_net(policy);
@@ -603,8 +648,10 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	net->xfrm.policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
 	rt_genid_bump(net);
-	if (delpol)
+	if (delpol) {
+		xfrm_policy_requeue(delpol, policy);
 		__xfrm_policy_unlink(delpol, dir);
+	}
 	policy->index = delpol ? delpol->index : xfrm_gen_index(net, dir);
 	hlist_add_head(&policy->byidx, net->xfrm.policy_byidx+idx_hash(net, policy->index));
 	policy->curlft.add_time = get_seconds();
@@ -1115,11 +1162,15 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 		pol->index = xfrm_gen_index(net, XFRM_POLICY_MAX+dir);
 		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
 	}
-	if (old_pol)
+	if (old_pol) {
+		if (pol)
+			xfrm_policy_requeue(old_pol, pol);
+
 		/* Unlinking succeeds always. This is the only function
 		 * allowed to delete or replace socket policy.
 		 */
 		__xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
+	}
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (old_pol) {
@@ -1310,6 +1361,8 @@ static struct flow_cache_object *xfrm_bundle_flo_get(struct flow_cache_object *f
 		 * It means we need to try again resolving. */
 		if (xdst->num_xfrms > 0)
 			return NULL;
+	} else if (dst->flags & DST_XFRM_QUEUE) {
+		return NULL;
 	} else {
 		/* Real bundle */
 		if (stale_bundle(dst))
@@ -1673,6 +1726,171 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	return xdst;
 }
 
+static void xfrm_policy_queue_process(unsigned long arg)
+{
+	int err = 0;
+	struct sk_buff *skb;
+	struct sock *sk;
+	struct dst_entry *dst;
+	struct net_device *dev;
+	struct xfrm_policy *pol = (struct xfrm_policy *)arg;
+	struct xfrm_policy_queue *pq = &pol->polq;
+	struct flowi fl;
+	struct sk_buff_head list;
+
+	spin_lock(&pq->hold_queue.lock);
+	skb = skb_peek(&pq->hold_queue);
+	dst = skb_dst(skb);
+	sk = skb->sk;
+	xfrm_decode_session(skb, &fl, dst->ops->family);
+	spin_unlock(&pq->hold_queue.lock);
+
+	dst_hold(dst->path);
+	dst = xfrm_lookup(xp_net(pol), dst->path, &fl,
+			  sk, 0);
+	if (IS_ERR(dst))
+		goto purge_queue;
+
+	if (dst->flags & DST_XFRM_QUEUE) {
+		dst_release(dst);
+
+		if (pq->timeout >= XFRM_QUEUE_TMO_MAX)
+			goto purge_queue;
+
+		pq->timeout = pq->timeout << 1;
+		mod_timer(&pq->hold_timer, jiffies + pq->timeout);
+		return;
+	}
+
+	dst_release(dst);
+
+	__skb_queue_head_init(&list);
+
+	spin_lock(&pq->hold_queue.lock);
+	pq->timeout = 0;
+	skb_queue_splice_init(&pq->hold_queue, &list);
+	spin_unlock(&pq->hold_queue.lock);
+
+	while (!skb_queue_empty(&list)) {
+		skb = __skb_dequeue(&list);
+
+		xfrm_decode_session(skb, &fl, skb_dst(skb)->ops->family);
+		dst_hold(skb_dst(skb)->path);
+		dst = xfrm_lookup(xp_net(pol), skb_dst(skb)->path,
+				  &fl, skb->sk, 0);
+		if (IS_ERR(dst)) {
+			dev_put(skb->dev);
+			kfree_skb(skb);
+			continue;
+		}
+
+		nf_reset(skb);
+		skb_dst_drop(skb);
+		skb_dst_set(skb, dst);
+
+		dev = skb->dev;
+		err = dst_output(skb);
+		dev_put(dev);
+	}
+
+	return;
+
+purge_queue:
+	pq->timeout = 0;
+	xfrm_queue_purge(&pq->hold_queue);
+}
+
+static int xdst_queue_output(struct sk_buff *skb)
+{
+	unsigned long sched_next;
+	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_dst *xdst = (struct xfrm_dst *) dst;
+	struct xfrm_policy_queue *pq = &xdst->pols[0]->polq;
+
+	if (pq->hold_queue.qlen > XFRM_MAX_QUEUE_LEN) {
+		kfree_skb(skb);
+		return -EAGAIN;
+	}
+
+	skb_dst_force(skb);
+	dev_hold(skb->dev);
+
+	spin_lock_bh(&pq->hold_queue.lock);
+
+	if (!pq->timeout)
+		pq->timeout = XFRM_QUEUE_TMO_MIN;
+
+	sched_next = jiffies + pq->timeout;
+
+	if (del_timer(&pq->hold_timer)) {
+		if (time_before(pq->hold_timer.expires, sched_next))
+			sched_next = pq->hold_timer.expires;
+	}
+
+	__skb_queue_tail(&pq->hold_queue, skb);
+	mod_timer(&pq->hold_timer, sched_next);
+
+	spin_unlock_bh(&pq->hold_queue.lock);
+
+	return 0;
+}
+
+static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
+						 struct dst_entry *dst,
+						 const struct flowi *fl,
+						 int num_xfrms,
+						 u16 family)
+{
+	int err;
+	struct net_device *dev;
+	struct dst_entry *dst1;
+	struct xfrm_dst *xdst;
+
+	xdst = xfrm_alloc_dst(net, family);
+	if (IS_ERR(xdst))
+		return xdst;
+
+	if (net->xfrm.sysctl_larval_drop || num_xfrms <= 0 ||
+	    (fl->flowi_flags & FLOWI_FLAG_CAN_SLEEP))
+		return xdst;
+
+	dst1 = &xdst->u.dst;
+	dst_hold(dst);
+	xdst->route = dst;
+
+	dst_copy_metrics(dst1, dst);
+
+	dst1->obsolete = DST_OBSOLETE_FORCE_CHK;
+	dst1->flags |= DST_HOST | DST_XFRM_QUEUE;
+	dst1->lastuse = jiffies;
+
+	dst1->input = dst_discard;
+	dst1->output = xdst_queue_output;
+
+	dst_hold(dst);
+	dst1->child = dst;
+	dst1->path = dst;
+
+	xfrm_init_path((struct xfrm_dst *)dst1, dst, 0);
+
+	err = -ENODEV;
+	dev = dst->dev;
+	if (!dev)
+		goto free_dst;
+
+	err = xfrm_fill_dst(xdst, dev, fl);
+	if (err)
+		goto free_dst;
+
+out:
+	return xdst;
+
+free_dst:
+	dst_release(dst1);
+	xdst = ERR_PTR(err);
+	goto out;
+}
+
 static struct flow_cache_object *
 xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 		   struct flow_cache_object *oldflo, void *ctx)
@@ -1751,7 +1969,7 @@ make_dummy_bundle:
 	/* We found policies, but there's no bundles to instantiate:
 	 * either because the policy blocks, has no transformations or
 	 * we could not build template (no xfrm_states).*/
-	xdst = xfrm_alloc_dst(net, family);
+	xdst = xfrm_create_dummy_bundle(net, dst_orig, fl, num_xfrms, family);
 	if (IS_ERR(xdst)) {
 		xfrm_pols_put(pols, num_pols);
 		return ERR_CAST(xdst);
@@ -2359,6 +2577,9 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 	    (dst->dev && !netif_running(dst->dev)))
 		return 0;
 
+	if (dst->flags & DST_XFRM_QUEUE)
+		return 1;
+
 	last = NULL;
 
 	do {
-- 
1.7.9.5
