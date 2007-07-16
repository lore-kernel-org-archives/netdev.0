From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Mon, 16 Jul 2007 20:45:05 +0300
Message-ID: <1184607905.18564.50.camel@ranko-fc2.spidernet.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
	 <20070712073746.GA1708@ff.dom.local>
	 <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
	 <20070712104641.GB1708@ff.dom.local>
	 <1184240842.3477.110.camel@ranko-fc2.spidernet.net>
	 <46961970.7080209@trash.net>
	 <1184262525.3477.135.camel@ranko-fc2.spidernet.net>
	 <20070713121733.GB3282@ff.dom.local>
	 <1184329602.16732.16.camel@ranko-fc2.spidernet.net>
	 <20070713134231.GC3282@ff.dom.local> <20070716070032.GA1871@ff.dom.local>
	 <469B6CA4.9030205@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-6KHpq91N0AoFWbHG88Rq"
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:23767 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbXGPRp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:45:26 -0400
In-Reply-To: <469B6CA4.9030205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6KHpq91N0AoFWbHG88Rq
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > There is probably quite easy way to get rid of this one race only
> > by e.g. replacing *bstats field with NULL in gen_kill_estimator,
> > and check for this in est_timer just after taking a lock.
> > 
You are absolutely right - I definitely overcomplicated the solution to
the actual problem in hand - the deadlock... Attached is the patch that
does exactly as above and should put a final resolution to the current
gen_estimator issues ... I've also given it a spin and so far it looks
ok. I will re-post it tomorrow evening for inclusion in the tree if no
objections come in the mean time.

> Jarek Poplawski wrote:
> > The gain from an api change would be mainly faster gen_kill_
> > and gen_replace_estimator. But, on the other hand, you have it
> > almost done. Ranko, I think these changes need opinion of more
> > maintainers as soon as possible - after all they could have some
> > objections; IMHO at least: Jamal Hadi Salim, Thomas Graf (authors
> > plus act_), Stephen Hemminger (sch_netem) and Jiri Benc
> > (net/mac80211).

>From my point of view the api change would help in untying the knot
entirely... It would become an independent piece of code with a sole
focus on the rate estimation. I am even thinking of making it even more
independent than the previous patch I posted... A pure small library
that can be configured to track rates with configurable algo's etc... It
may prove to be useful for the other things as well. 

But now that gen_estimator issues are hopefully resolved through this
simpler patch - the api change can take its own pace.

Patrick McHardy wrote:
> Frankly, all we need is a final patch.

The patch that resolves the ABBA deadlock is attached. WRT api patch -
although I did not face any problems so far, I still need to do more
comprehensive testing...

Best regards and thanks for the patience,

R.



--=-6KHpq91N0AoFWbHG88Rq
Content-Disposition: attachment; filename=x
Content-Type: text/plain; name=x; charset=UTF-8
Content-Transfer-Encoding: 7bit

[NET] gen_estimator deadlock fix

-Fixes ABBA deadlock noted by Patrick McHardy <kaber@trash.net>:

> There is at least one ABBA deadlock, est_timer() does:
> read_lock(&est_lock)
> spin_lock(e->stats_lock) (which is dev->queue_lock)
>
> and qdisc_destroy calls htb_destroy under dev->queue_lock, which
> calls htb_destroy_class, then gen_kill_estimator and this
> write_locks est_lock.

To fix the ABBA deadlock the rate estimators are now kept on an rcu list.

-The est_lock changes the use from protecting the list to protecting
the update to the 'bstat' pointer in order to avoid NULL dereferencing.

-The 'interval' member of the gen_estimator structure removed as it is
not needed.

Signed-off-by: Ranko Zivojnovic <ranko@spidernet.net>

---

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cc84d8d..590a767 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -79,27 +79,27 @@
 
 struct gen_estimator
 {
-	struct gen_estimator	*next;
+	struct list_head	list;
 	struct gnet_stats_basic	*bstats;
 	struct gnet_stats_rate_est	*rate_est;
 	spinlock_t		*stats_lock;
-	unsigned		interval;
 	int			ewma_log;
 	u64			last_bytes;
 	u32			last_packets;
 	u32			avpps;
 	u32			avbps;
+	struct rcu_head		e_rcu;
 };
 
 struct gen_estimator_head
 {
 	struct timer_list	timer;
-	struct gen_estimator	*list;
+	struct list_head	list;
 };
 
 static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
 
-/* Estimator array lock */
+/* Protects against NULL dereference */
 static DEFINE_RWLOCK(est_lock);
 
 static void est_timer(unsigned long arg)
@@ -107,13 +107,17 @@ static void est_timer(unsigned long arg)
 	int idx = (int)arg;
 	struct gen_estimator *e;
 
-	read_lock(&est_lock);
-	for (e = elist[idx].list; e; e = e->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(e, &elist[idx].list, list) {
 		u64 nbytes;
 		u32 npackets;
 		u32 rate;
 
 		spin_lock(e->stats_lock);
+		read_lock(&est_lock);
+		if (e->bstats == NULL)
+			goto skip;
+
 		nbytes = e->bstats->bytes;
 		npackets = e->bstats->packets;
 		rate = (nbytes - e->last_bytes)<<(7 - idx);
@@ -125,12 +129,14 @@ static void est_timer(unsigned long arg)
 		e->last_packets = npackets;
 		e->avpps += ((long)rate - (long)e->avpps) >> e->ewma_log;
 		e->rate_est->pps = (e->avpps+0x1FF)>>10;
+skip:
+		read_unlock(&est_lock);
 		spin_unlock(e->stats_lock);
 	}
 
-	if (elist[idx].list != NULL)
+	if (!list_empty(&elist[idx].list))
 		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
-	read_unlock(&est_lock);
+	rcu_read_unlock();
 }
 
 /**
@@ -147,12 +153,17 @@ static void est_timer(unsigned long arg)
  * &rate_est with the statistics lock grabed during this period.
  *
  * Returns 0 on success or a negative error code.
+ *
+ * NOTE: Called under rtnl_mutex
  */
 int gen_new_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock, struct rtattr *opt)
+		      struct gnet_stats_rate_est *rate_est,
+		      spinlock_t *stats_lock,
+		      struct rtattr *opt)
 {
 	struct gen_estimator *est;
 	struct gnet_estimator *parm = RTA_DATA(opt);
+	int idx;
 
 	if (RTA_PAYLOAD(opt) < sizeof(*parm))
 		return -EINVAL;
@@ -164,7 +175,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	if (est == NULL)
 		return -ENOBUFS;
 
-	est->interval = parm->interval + 2;
+	idx = parm->interval + 2;
 	est->bstats = bstats;
 	est->rate_est = rate_est;
 	est->stats_lock = stats_lock;
@@ -174,20 +185,25 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
 
-	est->next = elist[est->interval].list;
-	if (est->next == NULL) {
-		init_timer(&elist[est->interval].timer);
-		elist[est->interval].timer.data = est->interval;
-		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
-		elist[est->interval].timer.function = est_timer;
-		add_timer(&elist[est->interval].timer);
+	if (!elist[idx].timer.function) {
+		INIT_LIST_HEAD(&elist[idx].list);
+		setup_timer(&elist[idx].timer, est_timer, idx);
 	}
-	write_lock_bh(&est_lock);
-	elist[est->interval].list = est;
-	write_unlock_bh(&est_lock);
+
+	if (list_empty(&elist[idx].list))
+		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+
+	list_add_rcu(&est->list, &elist[idx].list);
 	return 0;
 }
 
+static void __gen_kill_estimator(struct rcu_head *head)
+{
+	struct gen_estimator *e = container_of(head,
+					struct gen_estimator, e_rcu);
+	kfree(e);
+}
+
 /**
  * gen_kill_estimator - remove a rate estimator
  * @bstats: basic statistics
@@ -195,31 +211,32 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
  *
  * Removes the rate estimator specified by &bstats and &rate_est
  * and deletes the timer.
+ *
+ * NOTE: Called under rtnl_mutex
  */
 void gen_kill_estimator(struct gnet_stats_basic *bstats,
 	struct gnet_stats_rate_est *rate_est)
 {
 	int idx;
-	struct gen_estimator *est, **pest;
+	struct gen_estimator *e, *n;
 
 	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-		int killed = 0;
-		pest = &elist[idx].list;
-		while ((est=*pest) != NULL) {
-			if (est->rate_est != rate_est || est->bstats != bstats) {
-				pest = &est->next;
+
+		/* Skip non initialized indexes */
+		if (!elist[idx].timer.function)
+			continue;
+
+		list_for_each_entry_safe(e, n, &elist[idx].list, list) {
+			if (e->rate_est != rate_est || e->bstats != bstats)
 				continue;
-			}
 
 			write_lock_bh(&est_lock);
-			*pest = est->next;
+			e->bstats = NULL;
 			write_unlock_bh(&est_lock);
 
-			kfree(est);
-			killed++;
+			list_del_rcu(&e->list);
+			call_rcu(&e->e_rcu, __gen_kill_estimator);
 		}
-		if (killed && elist[idx].list == NULL)
-			del_timer(&elist[idx].timer);
 	}
 }
 

--=-6KHpq91N0AoFWbHG88Rq--

