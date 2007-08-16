From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable
 and friendly ?
Date: Thu, 16 Aug 2007 17:40:44 +0200
Message-ID: <20070816174044.43c90ff4.dada1@cosmosbay.com>
References: <20070816153619.2c699e21.dada1@cosmosbay.com>
	<E1ILft1-0001Db-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:38696 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756094AbXHPPkq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 11:40:46 -0400
In-Reply-To: <E1ILft1-0001Db-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007 21:59:43 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Eric Dumazet <dada1@cosmosbay.com> wrote:
> > 
> > Yes, I already did this (with the current softirq based timer model),
> > but how can dst_dev_event() do its work, since the GC is using 
> > a private list. (In my patch, time to GC process XXX.000 entries is about XX seconds.)
> > 
> > We would have to change dst_dev_event() to :
> > - Signal to GC it has to stop as soon as possible.
> > - Wait for GC be stoped (busy wait I suspect we cannot sleep in dst_dev_event() ? )
> 
> You can sleep in dst_dev_event so just use a mutex to separate
> it from the GC.

Thanks for the suggestion, I added dst_mutex and attempt a mutex_trylock() inside dst_run_gc().

So do you think this patch is enough or should we convert dst_run_gc processing from softirq to workqueue too ?

Eric

[PATCH] net/core/dst.c : let dst_run_gc() do its job incrementally

When the periodic route cache flush is done, we can feed dst_garbage_list with a huge number of dst_entry structs.

Then dst_run_gc() is doing a scan of a possibly huge list of dst_entries, eventually freeing some (less than 1%) of them, while holding the dst_lock spinlock for the whole scan. This sometimes triggers a soft lockup. 

Then it rearms a timer to redo the full thing 1/10 s later. The slowdown can last one minute or so.
No need to say that machine is not really usable in the meantime.

This patch attempts to solve the problem giving dst_run_gc() the ability to perform its work by chunks instead of whole list scan. We limit a chunk by the number of entries that could not be freed in a run. This should limit the CPU cache trashing (currently 128 bytes per entry on x86_64), yet giving a chance to free unreferenced entries (not included in the quota) if the load is really high.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--- linux-2.6.22/net/core/dst.c.orig
+++ linux-2.6.22/net/core/dst.c
@@ -9,6 +9,7 @@
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/mutex.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -28,10 +29,17 @@
  * 4) All operations modify state, so a spinlock is used.
  */
 static struct dst_entry 	*dst_garbage_list;
+static struct dst_entry     *dst_garbage_wrk;
+static struct dst_entry     *dst_garbage_inuse;
+static int dst_gc_running;
 #if RT_CACHE_DEBUG >= 2
 static atomic_t			 dst_total = ATOMIC_INIT(0);
 #endif
 static DEFINE_SPINLOCK(dst_lock);
+/*
+ * A mutex is used to synchronize GC with dst_dev_event()
+ */
+static DEFINE_MUTEX(dst_mutex);
 
 static unsigned long dst_gc_timer_expires;
 static unsigned long dst_gc_timer_inc = DST_GC_MAX;
@@ -42,26 +50,39 @@ static DEFINE_TIMER(dst_gc_timer, dst_ru
 
 static void dst_run_gc(unsigned long dummy)
 {
-	int    delayed = 0;
-	int    work_performed;
-	struct dst_entry * dst, **dstp;
+	int    quota = 1000;
+	int    work_performed = 0;
+	struct dst_entry *dst, *next;
+	struct dst_entry *first = NULL, *last = NULL;
 
-	if (!spin_trylock(&dst_lock)) {
+	if (!mutex_trylock(&dst_mutex)) {
 		mod_timer(&dst_gc_timer, jiffies + HZ/10);
 		return;
 	}
+	dst_gc_running = 1;
 
+	spin_lock(&dst_lock);
 	del_timer(&dst_gc_timer);
-	dstp = &dst_garbage_list;
-	work_performed = 0;
-	while ((dst = *dstp) != NULL) {
-		if (atomic_read(&dst->__refcnt)) {
-			dstp = &dst->next;
-			delayed++;
+	if (!dst_garbage_wrk) {
+		dst_garbage_wrk = dst_garbage_list;
+		dst_garbage_list = dst_garbage_inuse;
+		dst_garbage_inuse = NULL;
+	}
+	next = dst_garbage_wrk;
+	spin_unlock(&dst_lock);
+
+	while ((dst = next) != NULL) {
+		next = dst->next;
+		if (likely(atomic_read(&dst->__refcnt))) {
+			if (unlikely(last == NULL))
+				last = dst;
+			dst->next = first;
+			first = dst;
+			if (--quota == 0)
+				break;
 			continue;
 		}
-		*dstp = dst->next;
-		work_performed = 1;
+		work_performed++;
 
 		dst = dst_destroy(dst);
 		if (dst) {
@@ -77,16 +98,26 @@ static void dst_run_gc(unsigned long dum
 				continue;
 
 			___dst_free(dst);
-			dst->next = *dstp;
-			*dstp = dst;
-			dstp = &dst->next;
+			dst->next = next;
+			next = dst;
 		}
 	}
-	if (!dst_garbage_list) {
+	dst_garbage_wrk = next;
+
+	spin_lock(&dst_lock);
+	dst_gc_running = 0;
+	if (last != NULL) {
+		last->next = dst_garbage_inuse;
+		dst_garbage_inuse = first;
+	}
+	/*
+	 * If all lists are empty, no need to rearm a timer
+	 */
+	if (!dst_garbage_list && !dst_garbage_wrk && !dst_garbage_inuse) {
 		dst_gc_timer_inc = DST_GC_MAX;
 		goto out;
 	}
-	if (!work_performed) {
+	if (!work_performed && !dst_garbage_wrk) {
 		if ((dst_gc_timer_expires += dst_gc_timer_inc) > DST_GC_MAX)
 			dst_gc_timer_expires = DST_GC_MAX;
 		dst_gc_timer_inc += DST_GC_INC;
@@ -95,8 +126,11 @@ static void dst_run_gc(unsigned long dum
 		dst_gc_timer_expires = DST_GC_MIN;
 	}
 #if RT_CACHE_DEBUG >= 2
-	printk("dst_total: %d/%d %ld\n",
-	       atomic_read(&dst_total), delayed,  dst_gc_timer_expires);
+	if (net_msg_warn)
+		printk(KERN_DEBUG "dst_run_gc: "
+		"dst_total=%d quota=%d perf=%d expires=%ld\n",
+		atomic_read(&dst_total), quota,
+		work_performed, dst_gc_timer_expires);
 #endif
 	/* if the next desired timer is more than 4 seconds in the future
 	 * then round the timer to whole seconds
@@ -109,6 +143,7 @@ static void dst_run_gc(unsigned long dum
 
 out:
 	spin_unlock(&dst_lock);
+	mutex_unlock(&dst_mutex);
 }
 
 static int dst_discard(struct sk_buff *skb)
@@ -157,7 +192,7 @@ void __dst_free(struct dst_entry * dst)
 	___dst_free(dst);
 	dst->next = dst_garbage_list;
 	dst_garbage_list = dst;
-	if (dst_gc_timer_inc > DST_GC_INC) {
+	if (dst_gc_timer_inc > DST_GC_INC && !dst_gc_running) {
 		dst_gc_timer_inc = DST_GC_INC;
 		dst_gc_timer_expires = DST_GC_MIN;
 		mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
@@ -224,7 +259,7 @@ again:
  *
  * Commented and originally written by Alexey.
  */
-static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
+static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			      int unregister)
 {
 	if (dst->ops->ifdown)
@@ -251,15 +286,34 @@ static int dst_dev_event(struct notifier
 {
 	struct net_device *dev = ptr;
 	struct dst_entry *dst;
+	struct dst_entry *first, *last;
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
 	case NETDEV_DOWN:
+		mutex_lock(&dst_mutex); /* guard against GC */
+
 		spin_lock_bh(&dst_lock);
-		for (dst = dst_garbage_list; dst; dst = dst->next) {
-			dst_ifdown(dst, dev, event != NETDEV_DOWN);
+		first = dst_garbage_list;
+		if (first) {
+			dst_garbage_list = NULL;
+			spin_unlock_bh(&dst_lock);
+			for (dst = first; dst; dst = dst->next) {
+				last = dst;
+				dst_ifdown(dst, dev, event != NETDEV_DOWN);
+			}
+			spin_lock_bh(&dst_lock);
+			last->next = dst_garbage_list;
+			dst_garbage_list = first;
 		}
 		spin_unlock_bh(&dst_lock);
+		for (dst = dst_garbage_wrk; dst; dst = dst->next) {
+			dst_ifdown(dst, dev, event != NETDEV_DOWN);
+		}
+		for (dst = dst_garbage_inuse; dst; dst = dst->next) {
+			dst_ifdown(dst, dev, event != NETDEV_DOWN);
+		}
+		mutex_unlock(&dst_mutex);
 		break;
 	}
 	return NOTIFY_DONE;
