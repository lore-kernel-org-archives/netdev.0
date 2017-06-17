From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 17/21] net: remove dst gc related code
Date: Sat, 17 Jun 2017 10:42:40 -0700
Message-ID: <20170617174244.132862-18-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35923 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752755AbdFQRnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:53 -0400
Received: by mail-pg0-f65.google.com with SMTP id e187so1835408pgc.3
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:52 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

This patch removes all dst gc related code and all the dst free
functions

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/dst.h |  21 ------
 net/core/dev.c    |   1 -
 net/core/dst.c    | 213 ------------------------------------------------------
 3 files changed, 235 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 88ebb87ad312..0c56d1fc4d7f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -425,28 +425,9 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev, int initial_ref,
 void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	      struct net_device *dev, int initial_ref, int initial_obsolete,
 	      unsigned short flags);
-void __dst_free(struct dst_entry *dst);
 struct dst_entry *dst_destroy(struct dst_entry *dst);
 void dst_dev_put(struct dst_entry *dst);
 
-static inline void dst_free(struct dst_entry *dst)
-{
-	if (dst->obsolete > 0)
-		return;
-	if (!atomic_read(&dst->__refcnt)) {
-		dst = dst_destroy(dst);
-		if (!dst)
-			return;
-	}
-	__dst_free(dst);
-}
-
-static inline void dst_rcu_free(struct rcu_head *head)
-{
-	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
-	dst_free(dst);
-}
-
 static inline void dst_confirm(struct dst_entry *dst)
 {
 }
@@ -508,8 +489,6 @@ static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
-void dst_subsys_init(void);
-
 /* Flags for xfrm_lookup flags argument. */
 enum {
 	XFRM_LOOKUP_ICMP = 1 << 0,
diff --git a/net/core/dev.c b/net/core/dev.c
index b8d6dd9e8b5c..5d1830b8d2cf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -8681,7 +8681,6 @@ static int __init net_dev_init(void)
 	rc = cpuhp_setup_state_nocalls(CPUHP_NET_DEV_DEAD, "net/dev:dead",
 				       NULL, dev_cpu_dead);
 	WARN_ON(rc < 0);
-	dst_subsys_init();
 	rc = 0;
 out:
 	return rc;
diff --git a/net/core/dst.c b/net/core/dst.c
index 64056ecca5b8..30bea01d2262 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -42,108 +42,6 @@
  * to dirty as few cache lines as possible in __dst_free().
  * As this is not a very strong hint, we dont force an alignment on SMP.
  */
-static struct {
-	spinlock_t		lock;
-	struct dst_entry	*list;
-	unsigned long		timer_inc;
-	unsigned long		timer_expires;
-} dst_garbage = {
-	.lock = __SPIN_LOCK_UNLOCKED(dst_garbage.lock),
-	.timer_inc = DST_GC_MAX,
-};
-static void dst_gc_task(struct work_struct *work);
-static void ___dst_free(struct dst_entry *dst);
-
-static DECLARE_DELAYED_WORK(dst_gc_work, dst_gc_task);
-
-static DEFINE_MUTEX(dst_gc_mutex);
-/*
- * long lived entries are maintained in this list, guarded by dst_gc_mutex
- */
-static struct dst_entry         *dst_busy_list;
-
-static void dst_gc_task(struct work_struct *work)
-{
-	int    delayed = 0;
-	int    work_performed = 0;
-	unsigned long expires = ~0L;
-	struct dst_entry *dst, *next, head;
-	struct dst_entry *last = &head;
-
-	mutex_lock(&dst_gc_mutex);
-	next = dst_busy_list;
-
-loop:
-	while ((dst = next) != NULL) {
-		next = dst->next;
-		prefetch(&next->next);
-		cond_resched();
-		if (likely(atomic_read(&dst->__refcnt))) {
-			last->next = dst;
-			last = dst;
-			delayed++;
-			continue;
-		}
-		work_performed++;
-
-		dst = dst_destroy(dst);
-		if (dst) {
-			/* NOHASH and still referenced. Unless it is already
-			 * on gc list, invalidate it and add to gc list.
-			 *
-			 * Note: this is temporary. Actually, NOHASH dst's
-			 * must be obsoleted when parent is obsoleted.
-			 * But we do not have state "obsoleted, but
-			 * referenced by parent", so it is right.
-			 */
-			if (dst->obsolete > 0)
-				continue;
-
-			___dst_free(dst);
-			dst->next = next;
-			next = dst;
-		}
-	}
-
-	spin_lock_bh(&dst_garbage.lock);
-	next = dst_garbage.list;
-	if (next) {
-		dst_garbage.list = NULL;
-		spin_unlock_bh(&dst_garbage.lock);
-		goto loop;
-	}
-	last->next = NULL;
-	dst_busy_list = head.next;
-	if (!dst_busy_list)
-		dst_garbage.timer_inc = DST_GC_MAX;
-	else {
-		/*
-		 * if we freed less than 1/10 of delayed entries,
-		 * we can sleep longer.
-		 */
-		if (work_performed <= delayed/10) {
-			dst_garbage.timer_expires += dst_garbage.timer_inc;
-			if (dst_garbage.timer_expires > DST_GC_MAX)
-				dst_garbage.timer_expires = DST_GC_MAX;
-			dst_garbage.timer_inc += DST_GC_INC;
-		} else {
-			dst_garbage.timer_inc = DST_GC_INC;
-			dst_garbage.timer_expires = DST_GC_MIN;
-		}
-		expires = dst_garbage.timer_expires;
-		/*
-		 * if the next desired timer is more than 4 seconds in the
-		 * future then round the timer to whole seconds
-		 */
-		if (expires > 4*HZ)
-			expires = round_jiffies_relative(expires);
-		schedule_delayed_work(&dst_gc_work, expires);
-	}
-
-	spin_unlock_bh(&dst_garbage.lock);
-	mutex_unlock(&dst_gc_mutex);
-}
-
 int dst_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	kfree_skb(skb);
@@ -216,34 +114,6 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 }
 EXPORT_SYMBOL(dst_alloc);
 
-static void ___dst_free(struct dst_entry *dst)
-{
-	/* The first case (dev==NULL) is required, when
-	   protocol module is unloaded.
-	 */
-	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
-		dst->input = dst_discard;
-		dst->output = dst_discard_out;
-	}
-	dst->obsolete = DST_OBSOLETE_DEAD;
-}
-
-void __dst_free(struct dst_entry *dst)
-{
-	spin_lock_bh(&dst_garbage.lock);
-	___dst_free(dst);
-	dst->next = dst_garbage.list;
-	dst_garbage.list = dst;
-	if (dst_garbage.timer_inc > DST_GC_INC) {
-		dst_garbage.timer_inc = DST_GC_INC;
-		dst_garbage.timer_expires = DST_GC_MIN;
-		mod_delayed_work(system_wq, &dst_gc_work,
-				 dst_garbage.timer_expires);
-	}
-	spin_unlock_bh(&dst_garbage.lock);
-}
-EXPORT_SYMBOL(__dst_free);
-
 struct dst_entry *dst_destroy(struct dst_entry * dst)
 {
 	struct dst_entry *child;
@@ -448,86 +318,3 @@ struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags)
 	return md_dst;
 }
 EXPORT_SYMBOL_GPL(metadata_dst_alloc_percpu);
-
-/* Dirty hack. We did it in 2.2 (in __dst_free),
- * we have _very_ good reasons not to repeat
- * this mistake in 2.3, but we have no choice
- * now. _It_ _is_ _explicit_ _deliberate_
- * _race_ _condition_.
- *
- * Commented and originally written by Alexey.
- */
-static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
-		       int unregister)
-{
-	if (dst->ops->ifdown)
-		dst->ops->ifdown(dst, dev, unregister);
-
-	if (dev != dst->dev)
-		return;
-
-	if (!unregister) {
-		dst->input = dst_discard;
-		dst->output = dst_discard_out;
-	} else {
-		dst->dev = dev_net(dst->dev)->loopback_dev;
-		dev_hold(dst->dev);
-		dev_put(dev);
-	}
-}
-
-static int dst_dev_event(struct notifier_block *this, unsigned long event,
-			 void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct dst_entry *dst, *last = NULL;
-
-	switch (event) {
-	case NETDEV_UNREGISTER_FINAL:
-	case NETDEV_DOWN:
-		mutex_lock(&dst_gc_mutex);
-		for (dst = dst_busy_list; dst; dst = dst->next) {
-			last = dst;
-			dst_ifdown(dst, dev, event != NETDEV_DOWN);
-		}
-
-		spin_lock_bh(&dst_garbage.lock);
-		dst = dst_garbage.list;
-		dst_garbage.list = NULL;
-		/* The code in dst_ifdown places a hold on the loopback device.
-		 * If the gc entry processing is set to expire after a lengthy
-		 * interval, this hold can cause netdev_wait_allrefs() to hang
-		 * out and wait for a long time -- until the the loopback
-		 * interface is released.  If we're really unlucky, it'll emit
-		 * pr_emerg messages to console too.  Reset the interval here,
-		 * so dst cleanups occur in a more timely fashion.
-		 */
-		if (dst_garbage.timer_inc > DST_GC_INC) {
-			dst_garbage.timer_inc = DST_GC_INC;
-			dst_garbage.timer_expires = DST_GC_MIN;
-			mod_delayed_work(system_wq, &dst_gc_work,
-					 dst_garbage.timer_expires);
-		}
-		spin_unlock_bh(&dst_garbage.lock);
-
-		if (last)
-			last->next = dst;
-		else
-			dst_busy_list = dst;
-		for (; dst; dst = dst->next)
-			dst_ifdown(dst, dev, event != NETDEV_DOWN);
-		mutex_unlock(&dst_gc_mutex);
-		break;
-	}
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block dst_dev_notifier = {
-	.notifier_call	= dst_dev_event,
-	.priority = -10, /* must be called after other network notifiers */
-};
-
-void __init dst_subsys_init(void)
-{
-	register_netdevice_notifier(&dst_dev_notifier);
-}
-- 
2.13.1.518.g3df882009-goog
