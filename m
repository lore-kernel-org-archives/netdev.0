From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
	to -mm tree
Date: Mon, 09 Jul 2007 19:43:40 +0300
Message-ID: <1183999420.18656.54.camel@ranko-fc2.spidernet.net>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>
	 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>
	 <20070705142135.GG4759@ff.dom.local>
	 <1183646029.4069.11.camel@ranko-fc2.spidernet.net>
	 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>
	 <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>
	 <20070706064523.GA2144@ff.dom.local>
	 <1183727654.6389.3.camel@ranko-fc2.spidernet.net>
	 <468E4FD9.4060702@trash.net>
	 <1183733732.6389.26.camel@ranko-fc2.spidernet.net>
	 <1183794918.30237.69.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707071704370.1808@x2>
	 <1183984861.18656.21.camel@ranko-fc2.spidernet.net>
	 <46923DA8.9010208@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vp57iio1V4L4gIpMgGih"
Cc: Jarek Poplawski <jarkao2@o2.pl>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:34704 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761790AbXGIQoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 12:44:13 -0400
In-Reply-To: <46923DA8.9010208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vp57iio1V4L4gIpMgGih
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2007-07-09 at 15:52 +0200, Patrick McHardy wrote:
> Ranko Zivojnovic wrote:
> > Patrick, I've taken liberty to try and implement this myself. Attached
> > is the whole new gen_estimator-fix-locking-and-timer-related-bugs.patch
> > that is RCU lists based. Please be kind to review.
> 
> Thanks for taking care of this, I'm a bit behind.

Glad to be able to help.

> See below for comments ..
> 
> > --- a/net/core/gen_estimator.c	2007-06-25 02:21:48.000000000 +0300
> > +++ b/net/core/gen_estimator.c	2007-07-09 14:27:12.053336875 +0300
> > @@ -79,7 +79,7 @@
> >  
> >  struct gen_estimator
> >  {
> > -	struct gen_estimator	*next;
> > +	struct list_head	list;
> >  	struct gnet_stats_basic	*bstats;
> >  	struct gnet_stats_rate_est	*rate_est;
> >  	spinlock_t		*stats_lock;
> > @@ -89,26 +89,27 @@
> >  	u32			last_packets;
> >  	u32			avpps;
> >  	u32			avbps;
> > +	struct rcu_head		e_rcu;
> 
> 
> You could also use synchronize_rcu(), estimator destruction is
> not particulary performance critical.

I've tried synchronize_rcu(), but it went kaboom with the below, thus
call_rcu() must stay:

---cut---
BUG: sleeping function called from invalid context at kernel/sched.c:3928
in_atomic():1, irqs_disabled():0
3 locks held by tc/2933:
 #0:  (rtnl_mutex){--..}, at: [<c0296e0a>] rtnetlink_rcv+0x18/0x42
 #1:  (&dev->queue_lock){-+..}, at: [<c029c337>] qdisc_lock_tree+0xe/0x1c
 #2:  (&dev->ingress_lock){-...}, at: [<c029dfb8>] tc_get_qdisc+0x192/0x1e9
 [<c02eec9e>] wait_for_completion+0x1a/0xb7
 [<c01e3cd4>] __spin_lock_init+0x29/0x4b
 [<c012e410>] synchronize_rcu+0x2a/0x2f
 [<c012e0bc>] wakeme_after_rcu+0x0/0x8
 [<c028da00>] gen_kill_estimator+0x70/0x9b
 [<f8b7c5a6>] htb_destroy_class+0x27/0x12f [sch_htb]
 [<f8b7d037>] htb_destroy+0x34/0x70 [sch_htb]
 [<c029c554>] qdisc_destroy+0x44/0x69
 . 
 .
 .
---cut---

> >  static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
> >  
> >  /* Estimator array lock */
> > -static DEFINE_RWLOCK(est_lock);
> > +static DEFINE_SPINLOCK(est_lock);
> 
> 
> The lock isn't needed anymore since we can rely on the rtnl
> for creation/destruction.

The 'est_lock' now completely removed.

> >  /**
> > @@ -152,6 +153,7 @@
> >  {
> >  	struct gen_estimator *est;
> >  	struct gnet_estimator *parm = RTA_DATA(opt);
> > +	int idx;
> >  
> >  	if (RTA_PAYLOAD(opt) < sizeof(*parm))
> >  		return -EINVAL;
> > @@ -163,7 +165,8 @@
> >  	if (est == NULL)
> >  		return -ENOBUFS;
> >  
> > -	est->interval = parm->interval + 2;
> > +	INIT_LIST_HEAD(&est->list);
> 
> 
> Initializing the members' list_head isn't necessary.
> 
Removed.

All the changes above now included in the attached patch. I've clean
compiled it with 2.6.22 and now testing this version.

R.

--=-vp57iio1V4L4gIpMgGih
Content-Disposition: attachment; filename=gen_estimator-fix-locking-and-timer-related-bugs.patch
Content-Type: text/x-patch; name=gen_estimator-fix-locking-and-timer-related-bugs.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- a/net/core/gen_estimator.c	2007-06-25 02:21:48.000000000 +0300
+++ b/net/core/gen_estimator.c	2007-07-09 19:08:06.801544963 +0300
@@ -79,7 +79,7 @@
 
 struct gen_estimator
 {
-	struct gen_estimator	*next;
+	struct list_head	list;
 	struct gnet_stats_basic	*bstats;
 	struct gnet_stats_rate_est	*rate_est;
 	spinlock_t		*stats_lock;
@@ -89,26 +89,24 @@
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
-static DEFINE_RWLOCK(est_lock);
-
 static void est_timer(unsigned long arg)
 {
 	int idx = (int)arg;
 	struct gen_estimator *e;
 
-	read_lock(&est_lock);
-	for (e = elist[idx].list; e; e = e->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(e, &elist[idx].list, list) {
 		u64 nbytes;
 		u32 npackets;
 		u32 rate;
@@ -127,9 +125,9 @@
 		e->rate_est->pps = (e->avpps+0x1FF)>>10;
 		spin_unlock(e->stats_lock);
 	}
-
-	mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
-	read_unlock(&est_lock);
+	if (!list_empty(&elist[idx].list))
+		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+	rcu_read_unlock();
 }
 
 /**
@@ -152,6 +150,7 @@
 {
 	struct gen_estimator *est;
 	struct gnet_estimator *parm = RTA_DATA(opt);
+	int idx;
 
 	if (RTA_PAYLOAD(opt) < sizeof(*parm))
 		return -EINVAL;
@@ -163,7 +162,7 @@
 	if (est == NULL)
 		return -ENOBUFS;
 
-	est->interval = parm->interval + 2;
+	est->interval = idx = parm->interval + 2;
 	est->bstats = bstats;
 	est->rate_est = rate_est;
 	est->stats_lock = stats_lock;
@@ -173,20 +172,24 @@
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
+		setup_timer(&elist[idx].timer, est_timer, est->interval);
 	}
-	write_lock_bh(&est_lock);
-	elist[est->interval].list = est;
-	write_unlock_bh(&est_lock);
+		
+	if (list_empty(&elist[est->interval].list))
+		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+
+	list_add_rcu(&est->list, &elist[idx].list);
 	return 0;
 }
 
+static void __gen_kill_estimator(struct rcu_head *head)
+{
+	struct gen_estimator *e = container_of(head, struct gen_estimator, e_rcu);
+	kfree(e);
+}
+
 /**
  * gen_kill_estimator - remove a rate estimator
  * @bstats: basic statistics
@@ -199,26 +202,21 @@
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
-				continue;
-			}
 
-			write_lock_bh(&est_lock);
-			*pest = est->next;
-			write_unlock_bh(&est_lock);
+		/* Skip non initialized indexes */
+		if (!elist[idx].timer.function)
+			continue;
+
+		list_for_each_entry_safe(e, n, &elist[idx].list, list) {
+			if (e->rate_est != rate_est || e->bstats != bstats)
+				continue;
 
-			kfree(est);
-			killed++;
+			list_del_rcu(&e->list);
+			call_rcu(&e->e_rcu, __gen_kill_estimator);
 		}
-		if (killed && elist[idx].list == NULL)
-			del_timer(&elist[idx].timer);
 	}
 }
 

--=-vp57iio1V4L4gIpMgGih--

