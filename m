From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Thu, 12 Jul 2007 20:48:45 +0300
Message-ID: <1184262525.3477.135.camel@ranko-fc2.spidernet.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
	 <20070712073746.GA1708@ff.dom.local>
	 <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
	 <20070712104641.GB1708@ff.dom.local>
	 <1184240842.3477.110.camel@ranko-fc2.spidernet.net>
	 <46961970.7080209@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-af8dJ/POfrC5mfYKvloM"
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:24067 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbXGLRtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 13:49:08 -0400
In-Reply-To: <46961970.7080209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-af8dJ/POfrC5mfYKvloM
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2007-07-12 at 14:07 +0200, Patrick McHardy wrote:
> [Removed Andrew from CC]
> 
> Ranko Zivojnovic wrote:
> > I agree - it does look like the most sensible thing to do - have
> > gnet_stats_basic and gnet_stats_rate_est allocated within the
> > gen_estimator struct rather than pointers looking here and there - and
> > provide api to maintain those stats - it simplifies the picture.
> 
> 
> The API is not very pretty, some improvement there would be welcome.
> 
> > Also - the stats_lock in this case could be local to gen_estimator
> > struct, thus making the implementation completely "dev agnostic" - and
> > will not break on dev removal.
> 
> 
> The queue lock is used since thats what protects the qdisc counters.

Ok - here's the patch for a review - it compiles clean ... and that's as
much as it has been tested - I'll try give it a run later today or
definitely tomorrow.

'bstats' and 'rate_est' are now embedded into gen_estimator as well as
the spin_lock that protects them.

Introduced two new inline functions: gen_bstat_add() and gen_bstat_skb()
for maintaining the bstats within the gen_estimator structure.

Note that gen_bstat_skb includes also the TSO check and effectively
propagates the TSO support to all schedulers.

R.

--=-af8dJ/POfrC5mfYKvloM
Content-Disposition: attachment; filename=t
Content-Type: text/plain; name=t; charset=UTF-8
Content-Transfer-Encoding: 7bit

 include/net/act_api.h     |    6 +-
 include/net/gen_stats.h   |   42 ++++++++++--
 include/net/sch_generic.h |    7 +-
 net/core/gen_estimator.c  |  159 +++++++++++++++++++--------------------------
 net/sched/act_api.c       |   23 ++++--
 net/sched/act_police.c    |   34 +++++-----
 net/sched/sch_api.c       |   16 ++--
 net/sched/sch_atm.c       |    3 +-
 net/sched/sch_cbq.c       |   39 ++++++------
 net/sched/sch_dsmark.c    |    3 +-
 net/sched/sch_generic.c   |    2 +-
 net/sched/sch_hfsc.c      |   34 +++++-----
 net/sched/sch_htb.c       |   36 +++++------
 net/sched/sch_ingress.c   |    9 +--
 net/sched/sch_netem.c     |    6 +-
 net/sched/sch_prio.c      |    5 +-
 net/sched/sch_red.c       |    3 +-
 net/sched/sch_sfq.c       |    3 +-
 net/sched/sch_tbf.c       |    3 +-
 net/sched/sch_teql.c      |    3 +-
 20 files changed, 214 insertions(+), 222 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 2f0273f..f5e0f05 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -16,9 +16,9 @@ struct tcf_common {
 	u32				tcfc_capab;
 	int				tcfc_action;
 	struct tcf_t			tcfc_tm;
+	struct gen_estimator		*tcfc_ge;
 	struct gnet_stats_basic		tcfc_bstats;
 	struct gnet_stats_queue		tcfc_qstats;
-	struct gnet_stats_rate_est	tcfc_rate_est;
 	spinlock_t			tcfc_lock;
 };
 #define tcf_next	common.tcfc_next
@@ -29,8 +29,10 @@ struct tcf_common {
 #define tcf_action	common.tcfc_action
 #define tcf_tm		common.tcfc_tm
 #define tcf_bstats	common.tcfc_bstats
+#define tcf_ge		common.tcfc_ge
+#define tcf_ge_bstats	common.tcfc_ge->bstats
+#define tcf_ge_rate_est	common.tcfc_ge->rate_est
 #define tcf_qstats	common.tcfc_qstats
-#define tcf_rate_est	common.tcfc_rate_est
 #define tcf_lock	common.tcfc_lock
 
 struct tcf_police {
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index 0b95cf0..1103ec8 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -20,6 +20,21 @@ struct gnet_dump
 	struct tc_stats   tc_stats;
 };
 
+struct gen_estimator
+{
+	struct list_head	list;
+	struct gnet_stats_basic	bstats;
+	struct gnet_stats_rate_est	rate_est;
+	spinlock_t		stats_lock; /* Protects the stats updates */
+	unsigned		interval;
+	int			ewma_log;
+	u64			last_bytes;
+	u32			last_packets;
+	u32			avpps;
+	u32			avbps;
+	struct rcu_head		e_rcu;
+};
+
 extern int gnet_stats_start_copy(struct sk_buff *skb, int type,
 				 spinlock_t *lock, struct gnet_dump *d);
 
@@ -37,13 +52,24 @@ extern int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 
 extern int gnet_stats_finish_copy(struct gnet_dump *d);
 
-extern int gen_new_estimator(struct gnet_stats_basic *bstats,
-			     struct gnet_stats_rate_est *rate_est,
-			     spinlock_t *stats_lock, struct rtattr *opt);
-extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
-			       struct gnet_stats_rate_est *rate_est);
-extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
-				 struct gnet_stats_rate_est *rate_est,
-				 spinlock_t *stats_lock, struct rtattr *opt);
+extern int gen_new_estimator(struct rtattr *opt, struct gen_estimator **ep);
+extern void gen_kill_estimator(struct gen_estimator *ep);
+extern int gen_replace_estimator(struct rtattr *opt, struct gen_estimator **ep);
+
+static inline void gen_bstat_add(struct gen_estimator *e,
+				  int bytes,
+				  int packets)
+{
+	spin_lock(&e->stats_lock);
+	e->bstats.bytes += bytes;
+	e->bstats.packets += packets;
+	spin_unlock(&e->stats_lock);
+}
+
+static inline void gen_bstat_skb(struct gen_estimator *e,
+				  struct sk_buff *skb)
+{
+	gen_bstat_add(e, skb->len, skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1);
+}
 
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1b8e351..ff13671 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -40,9 +40,9 @@ struct Qdisc
 	struct net_device	*dev;
 	struct list_head	list;
 
-	struct gnet_stats_basic	bstats;
+	struct gen_estimator	*ge;
+
 	struct gnet_stats_queue	qstats;
-	struct gnet_stats_rate_est	rate_est;
 	spinlock_t		*stats_lock;
 	struct rcu_head 	q_rcu;
 	int			(*reshape_fail)(struct sk_buff *skb,
@@ -185,8 +185,7 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 {
 	__skb_queue_tail(list, skb);
 	sch->qstats.backlog += skb->len;
-	sch->bstats.bytes += skb->len;
-	sch->bstats.packets++;
+	gen_bstat_skb(sch->ge, skb);
 
 	return NET_XMIT_SUCCESS;
 }
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cc84d8d..502deb3 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -77,82 +77,65 @@
 
 #define EST_MAX_INTERVAL	5
 
-struct gen_estimator
-{
-	struct gen_estimator	*next;
-	struct gnet_stats_basic	*bstats;
-	struct gnet_stats_rate_est	*rate_est;
-	spinlock_t		*stats_lock;
-	unsigned		interval;
-	int			ewma_log;
-	u64			last_bytes;
-	u32			last_packets;
-	u32			avpps;
-	u32			avbps;
-};
-
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
 
-		spin_lock(e->stats_lock);
-		nbytes = e->bstats->bytes;
-		npackets = e->bstats->packets;
+		spin_lock(&e->stats_lock);
+		nbytes = e->bstats.bytes;
+		npackets = e->bstats.packets;
 		rate = (nbytes - e->last_bytes)<<(7 - idx);
 		e->last_bytes = nbytes;
 		e->avbps += ((long)rate - (long)e->avbps) >> e->ewma_log;
-		e->rate_est->bps = (e->avbps+0xF)>>5;
+		e->rate_est.bps = (e->avbps+0xF)>>5;
 
 		rate = (npackets - e->last_packets)<<(12 - idx);
 		e->last_packets = npackets;
 		e->avpps += ((long)rate - (long)e->avpps) >> e->ewma_log;
-		e->rate_est->pps = (e->avpps+0x1FF)>>10;
-		spin_unlock(e->stats_lock);
+		e->rate_est.pps = (e->avpps+0x1FF)>>10;
+		spin_unlock(&e->stats_lock);
 	}
 
-	if (elist[idx].list != NULL)
+	if (!list_empty(&elist[idx].list))
 		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
-	read_unlock(&est_lock);
+	rcu_read_unlock();
 }
 
 /**
  * gen_new_estimator - create a new rate estimator
- * @bstats: basic statistics
- * @rate_est: rate estimator statistics
- * @stats_lock: statistics lock
  * @opt: rate estimator configuration TLV
+ * @ep: new gen_estimator struct is returned through this pointer on success
  *
- * Creates a new rate estimator with &bstats as source and &rate_est
- * as destination. A new timer with the interval specified in the
+ * Creates a new rate estimator with bstats as source and rate_est
+ * as destination. A timer with the interval specified in the
  * configuration TLV is created. Upon each interval, the latest statistics
- * will be read from &bstats and the estimated rate will be stored in
- * &rate_est with the statistics lock grabed during this period.
+ * will be read from bstats and the estimated rate will be stored in
+ * rate_est with the statistics lock grabed during this period.
  *
  * Returns 0 on success or a negative error code.
+ *
+ * NOTE: Called under rtnl_mutex
  */
-int gen_new_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock, struct rtattr *opt)
+int gen_new_estimator(struct rtattr *opt, struct gen_estimator **ep)
 {
 	struct gen_estimator *est;
 	struct gnet_estimator *parm = RTA_DATA(opt);
+	int idx;
 
 	if (RTA_PAYLOAD(opt) < sizeof(*parm))
 		return -EINVAL;
@@ -164,84 +147,74 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	if (est == NULL)
 		return -ENOBUFS;
 
-	est->interval = parm->interval + 2;
-	est->bstats = bstats;
-	est->rate_est = rate_est;
-	est->stats_lock = stats_lock;
+	spin_lock_init(&est->stats_lock);
+	est->interval = idx = parm->interval + 2;
 	est->ewma_log = parm->ewma_log;
-	est->last_bytes = bstats->bytes;
-	est->avbps = rate_est->bps<<5;
-	est->last_packets = bstats->packets;
-	est->avpps = rate_est->pps<<10;
-
-	est->next = elist[est->interval].list;
-	if (est->next == NULL) {
-		init_timer(&elist[est->interval].timer);
-		elist[est->interval].timer.data = est->interval;
-		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
-		elist[est->interval].timer.function = est_timer;
-		add_timer(&elist[est->interval].timer);
+
+	if (*ep != NULL) {
+		est->last_bytes = (*ep)->bstats.bytes;
+		est->avbps = (*ep)->rate_est.bps<<5;
+		est->last_packets = (*ep)->bstats.packets;
+		est->avpps = (*ep)->rate_est.pps<<10;
+	}
+
+	if (!elist[idx].timer.function) {
+		INIT_LIST_HEAD(&elist[idx].list);
+		setup_timer(&elist[idx].timer, est_timer, est->interval);
 	}
-	write_lock_bh(&est_lock);
-	elist[est->interval].list = est;
-	write_unlock_bh(&est_lock);
+
+	if (list_empty(&elist[idx].list))
+		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+
+	list_add_rcu(&est->list, &elist[idx].list);
+
+	*ep = est;
+
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
- * @bstats: basic statistics
- * @rate_est: rate estimator statistics
+ * @ep: rate estimator to kill
+ *
+ * Removes the rate estimator specified
  *
- * Removes the rate estimator specified by &bstats and &rate_est
- * and deletes the timer.
+ * NOTE: Called under rtnl_mutex
  */
-void gen_kill_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est)
+void gen_kill_estimator(struct gen_estimator *e)
 {
-	int idx;
-	struct gen_estimator *est, **pest;
-
-	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-		int killed = 0;
-		pest = &elist[idx].list;
-		while ((est=*pest) != NULL) {
-			if (est->rate_est != rate_est || est->bstats != bstats) {
-				pest = &est->next;
-				continue;
-			}
-
-			write_lock_bh(&est_lock);
-			*pest = est->next;
-			write_unlock_bh(&est_lock);
-
-			kfree(est);
-			killed++;
-		}
-		if (killed && elist[idx].list == NULL)
-			del_timer(&elist[idx].timer);
-	}
+	list_del_rcu(&e->list);
+	call_rcu(&e->e_rcu, __gen_kill_estimator);
 }
 
 /**
  * gen_replace_estimator - replace rate estimator configruation
- * @bstats: basic statistics
- * @rate_est: rate estimator statistics
- * @stats_lock: statistics lock
  * @opt: rate estimator configuration TLV
+ * @ep: new gen_estimator struct is returned through this pointer on success
  *
  * Replaces the configuration of a rate estimator by calling
  * gen_kill_estimator() and gen_new_estimator().
  *
  * Returns 0 on success or a negative error code.
  */
-int
-gen_replace_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock,
-	struct rtattr *opt)
+int gen_replace_estimator(struct rtattr *opt, struct gen_estimator **ep)
 {
-    gen_kill_estimator(bstats, rate_est);
-    return gen_new_estimator(bstats, rate_est, stats_lock, opt);
+	struct gen_estimator *old = *ep;
+	int err;
+
+	err = gen_new_estimator(opt, ep);
+
+	if (!err)
+		gen_kill_estimator(old);
+
+	return err;
 }
 
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index feef366..bf94944 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -32,8 +32,7 @@ void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 			write_lock_bh(hinfo->lock);
 			*p1p = p->tcfc_next;
 			write_unlock_bh(hinfo->lock);
-			gen_kill_estimator(&p->tcfc_bstats,
-					   &p->tcfc_rate_est);
+			gen_kill_estimator(p->tcfc_ge);
 			kfree(p);
 			return;
 		}
@@ -209,7 +208,13 @@ struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind,
 }
 EXPORT_SYMBOL(tcf_hash_check);
 
-struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_action *a, int size, int bind, u32 *idx_gen, struct tcf_hashinfo *hinfo)
+struct tcf_common *tcf_hash_create(u32 index,
+				   struct rtattr *est,
+				   struct tc_action *a,
+				   int size,
+				   int bind,
+				   u32 *idx_gen,
+				   struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 
@@ -223,9 +228,11 @@ struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_acti
 	p->tcfc_index = index ? index : tcf_hash_new_index(idx_gen, hinfo);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
-	if (est)
-		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
-				  &p->tcfc_lock, est);
+	if (est) {
+		gen_new_estimator(est, &p->tcfc_ge);
+		/* XXX TO-DO: verify successful return from
+		   gen_new_estimator()! */
+	}
 	a->priv = (void *) p;
 	return p;
 }
@@ -598,8 +605,8 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 		if (a->ops->get_stats(skb, a) < 0)
 			goto errout;
 
-	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &h->tcf_rate_est) < 0 ||
+	if (gnet_stats_copy_basic(&d, &h->tcf_ge_bstats) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &h->tcf_ge_rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &h->tcf_qstats) < 0)
 		goto errout;
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index d204038..2a3e1d5 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -108,8 +108,7 @@ void tcf_police_destroy(struct tcf_police *p)
 			write_lock_bh(&police_lock);
 			*p1p = p->tcf_next;
 			write_unlock_bh(&police_lock);
-			gen_kill_estimator(&p->tcf_bstats,
-					   &p->tcf_rate_est);
+			gen_kill_estimator(p->tcf_ge);
 			if (p->tcfp_R_tab)
 				qdisc_put_rtab(p->tcfp_R_tab);
 			if (p->tcfp_P_tab)
@@ -217,10 +216,11 @@ override:
 	if (tb[TCA_POLICE_AVRATE-1])
 		police->tcfp_ewma_rate =
 			*(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
-	if (est)
-		gen_replace_estimator(&police->tcf_bstats,
-				      &police->tcf_rate_est,
-				      &police->tcf_lock, est);
+	if (est) {
+		gen_replace_estimator(est, &police->tcf_ge);
+		/* XXX TO-DO: verify successful return from
+		   gen_replace_estimator()! */
+	}
 
 	spin_unlock_bh(&police->tcf_lock);
 	if (ret != ACT_P_CREATED)
@@ -263,11 +263,10 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 
 	spin_lock(&police->tcf_lock);
 
-	police->tcf_bstats.bytes += skb->len;
-	police->tcf_bstats.packets++;
+	gen_bstat_skb(police->tcf_ge, skb);
 
 	if (police->tcfp_ewma_rate &&
-	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
+	    police->tcf_ge_rate_est.bps >= police->tcfp_ewma_rate) {
 		police->tcf_qstats.overlimits++;
 		spin_unlock(&police->tcf_lock);
 		return police->tcf_action;
@@ -476,9 +475,11 @@ struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
 	police->tcf_index = parm->index ? parm->index :
 		tcf_police_new_index();
 	police->tcf_action = parm->action;
-	if (est)
-		gen_new_estimator(&police->tcf_bstats, &police->tcf_rate_est,
-				  &police->tcf_lock, est);
+	if (est) {
+		gen_new_estimator(est, &police->tcf_ge);
+		/* XXX TO-DO: verify successful return from
+		   gen_new_estimator()! */
+	}
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	write_lock_bh(&police_lock);
 	police->tcf_next = tcf_police_ht[h];
@@ -501,11 +502,10 @@ int tcf_police(struct sk_buff *skb, struct tcf_police *police)
 
 	spin_lock(&police->tcf_lock);
 
-	police->tcf_bstats.bytes += skb->len;
-	police->tcf_bstats.packets++;
+	gen_bstat_skb(police->tcf_ge, skb);
 
 	if (police->tcfp_ewma_rate &&
-	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
+	    police->tcf_ge_rate_est.bps >= police->tcfp_ewma_rate) {
 		police->tcf_qstats.overlimits++;
 		spin_unlock(&police->tcf_lock);
 		return police->tcf_action;
@@ -583,8 +583,8 @@ int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *police)
 					 &d) < 0)
 		goto errout;
 
-	if (gnet_stats_copy_basic(&d, &police->tcf_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &police->tcf_rate_est) < 0 ||
+	if (gnet_stats_copy_basic(&d, &police->tcf_ge_bstats) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &police->tcf_ge_rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &police->tcf_qstats) < 0)
 		goto errout;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d92ea26..dbcc846 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -504,9 +504,7 @@ qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
 		if (tca[TCA_RATE-1]) {
-			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
-						sch->stats_lock,
-						tca[TCA_RATE-1]);
+			err = gen_new_estimator(tca[TCA_RATE-1], &sch->ge);
 			if (err) {
 				/*
 				 * Any broken qdiscs that would require
@@ -545,9 +543,11 @@ static int qdisc_change(struct Qdisc *sch, struct rtattr **tca)
 		if (err)
 			return err;
 	}
-	if (tca[TCA_RATE-1])
-		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-			sch->stats_lock, tca[TCA_RATE-1]);
+	if (tca[TCA_RATE-1]) {
+		gen_replace_estimator(tca[TCA_RATE-1], &sch->ge);
+		/* XXX TO-DO: verify successful return from
+			   gen_replace_estimator()! */
+	}
 	return 0;
 }
 
@@ -822,8 +822,8 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
 		goto rtattr_failure;
 
-	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
+	if (gnet_stats_copy_basic(&d, &q->ge->bstats) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &q->ge->rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
 		goto rtattr_failure;
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 54b92d2..35065f9 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -437,8 +437,7 @@ static int atm_tc_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 		if (flow) flow->qstats.drops++;
 		return ret;
 	}
-	sch->bstats.bytes += skb->len;
-	sch->bstats.packets++;
+	gen_bstat_skb(sch->ge, skb);
 	flow->bstats.bytes += skb->len;
 	flow->bstats.packets++;
 	/*
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index b184c35..5c00954 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -129,9 +129,10 @@ struct cbq_class
 	long			avgidle;
 	long			deficit;	/* Saved deficit for WRR */
 	psched_time_t		penalized;
-	struct gnet_stats_basic bstats;
+
+	struct gen_estimator	*ge; 		/* byte and packet stats
+						   collected here */
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
 	struct tc_cbq_xstats	xstats;
 
 	struct tcf_proto	*filter_list;
@@ -385,7 +386,6 @@ static int
 cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	int len = skb->len;
 	int ret;
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
@@ -404,8 +404,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #endif
 	if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
-		sch->bstats.packets++;
-		sch->bstats.bytes+=len;
+		gen_bstat_skb(sch->ge, skb);
 		cbq_mark_toplevel(q, cl);
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
@@ -674,7 +673,6 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
-	int len = skb->len;
 	struct Qdisc *sch = child->__parent;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = q->rx_class;
@@ -690,8 +688,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 
 		if (cl->q->enqueue(skb, cl->q) == 0) {
 			sch->q.qlen++;
-			sch->bstats.packets++;
-			sch->bstats.bytes+=len;
+			gen_bstat_skb(sch->ge, skb);
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
 			return 0;
@@ -749,8 +746,7 @@ cbq_update(struct cbq_sched_data *q)
 		long avgidle = cl->avgidle;
 		long idle;
 
-		cl->bstats.packets++;
-		cl->bstats.bytes += len;
+		gen_bstat_add(cl->ge, len, 1);
 
 		/*
 		   (now - last) is total time between packet right edges.
@@ -1634,8 +1630,8 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	if (cl->undertime != PSCHED_PASTPERFECT)
 		cl->xstats.undertime = cl->undertime - q->now;
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	if (gnet_stats_copy_basic(d, &cl->ge->bstats) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->ge->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1706,7 +1702,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(cl->ge);
 	if (cl != &q->link)
 		kfree(cl);
 }
@@ -1851,10 +1847,11 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE-1])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev->queue_lock,
-					      tca[TCA_RATE-1]);
+		if (tca[TCA_RATE-1]) {
+			gen_replace_estimator(tca[TCA_RATE-1], &cl->ge);
+			/* XXX TO-DO: verify successful return from
+			   gen_replace_estimator()! */
+		}
 		return 0;
 	}
 
@@ -1939,9 +1936,11 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 		cbq_set_fopt(cl, RTA_DATA(tb[TCA_CBQ_FOPT-1]));
 	sch_tree_unlock(sch);
 
-	if (tca[TCA_RATE-1])
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock, tca[TCA_RATE-1]);
+	if (tca[TCA_RATE-1]) {
+		gen_new_estimator(tca[TCA_RATE-1], &cl->ge);
+		/* XXX TO-DO: verify successful return from
+		   gen_new_estimator()! */
+	}
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 4d2c233..8c44328 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -265,8 +265,7 @@ static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 		return err;
 	}
 
-	sch->bstats.bytes += skb->len;
-	sch->bstats.packets++;
+	gen_bstat_skb(sch->ge, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c81649c..acc6d90 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -506,7 +506,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 		return;
 
 	list_del(&qdisc->list);
-	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+	gen_kill_estimator(qdisc->ge);
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 874452c..2b95b04 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -116,9 +116,10 @@ struct hfsc_class
 	u32		classid;	/* class id */
 	unsigned int	refcnt;		/* usage count */
 
-	struct gnet_stats_basic bstats;
+	struct gen_estimator *ge;	/* byte and packet stats collected here
+					 */
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+
 	unsigned int	level;		/* class level in hierarchy */
 	struct tcf_proto *filter_list;	/* filter list */
 	unsigned int	filter_cnt;	/* filter count */
@@ -1050,10 +1051,11 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		}
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE-1])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev->queue_lock,
-					      tca[TCA_RATE-1]);
+		if (tca[TCA_RATE-1]) {
+			gen_replace_estimator(tca[TCA_RATE-1], &cl->ge);
+			/* XXX TO-DO: verify successful return from
+			   gen_replace_estimator()! */
+		}
 		return 0;
 	}
 
@@ -1106,9 +1108,11 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->cl_pcvtoff = parent->cl_cvtoff;
 	sch_tree_unlock(sch);
 
-	if (tca[TCA_RATE-1])
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock, tca[TCA_RATE-1]);
+	if (tca[TCA_RATE-1]) {
+		gen_new_estimator(tca[TCA_RATE-1], &cl->ge);
+		/* XXX TO-DO: verify successful return from
+		   gen_new_estimator()! */
+	}
 	*arg = (unsigned long)cl;
 	return 0;
 }
@@ -1120,7 +1124,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->qdisc);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(cl->ge);
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1373,8 +1377,8 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.work    = cl->cl_total;
 	xstats.rtwork  = cl->cl_cumul;
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	if (gnet_stats_copy_basic(d, &cl->ge->bstats) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->ge->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1587,10 +1591,8 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl->qdisc->q.qlen == 1)
 		set_active(cl, len);
 
-	cl->bstats.packets++;
-	cl->bstats.bytes += len;
-	sch->bstats.packets++;
-	sch->bstats.bytes += len;
+	gen_bstat_skb(cl->ge, skb);
+	gen_bstat_skb(sch->ge, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index b417a95..25bddd8 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -71,9 +71,8 @@ enum htb_cmode {
 struct htb_class {
 	/* general class parameters */
 	u32 classid;
-	struct gnet_stats_basic bstats;
+	struct gen_estimator *ge; /* byte and packet stats collected here */
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
 	struct tc_htb_xstats xstats;	/* our special stats */
 	int refcnt;		/* usage count of this class */
 
@@ -603,15 +602,12 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		cl->qstats.drops++;
 		return NET_XMIT_DROP;
 	} else {
-		cl->bstats.packets +=
-			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes += skb->len;
+		gen_bstat_skb(cl->ge, skb);
 		htb_activate(q, cl);
 	}
 
 	sch->q.qlen++;
-	sch->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-	sch->bstats.bytes += skb->len;
+	gen_bstat_skb(sch->ge, skb);
 	return NET_XMIT_SUCCESS;
 }
 
@@ -696,9 +692,7 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 
 		/* update byte stats except for leaves which are already updated */
 		if (cl->level) {
-			cl->bstats.bytes += bytes;
-			cl->bstats.packets += skb_is_gso(skb)?
-					skb_shinfo(skb)->gso_segs:1;
+			gen_bstat_skb(cl->ge, skb);
 		}
 		cl = cl->parent;
 	}
@@ -1112,8 +1106,8 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 	cl->xstats.tokens = cl->tokens;
 	cl->xstats.ctokens = cl->ctokens;
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	if (gnet_stats_copy_basic(d, &cl->ge->bstats) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->ge->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1204,7 +1198,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		BUG_TRAP(cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(cl->ge);
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
@@ -1357,9 +1351,10 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock,
-				  tca[TCA_RATE-1] ? : &est.rta);
+		gen_new_estimator(tca[TCA_RATE-1] ? : &est.rta, &cl->ge);
+		/* XXX TO-DO: verify successful return from
+		   gen_new_estimator()! */
+
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
 		INIT_HLIST_NODE(&cl->hlist);
@@ -1412,10 +1407,11 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		list_add_tail(&cl->sibling,
 			      parent ? &parent->children : &q->root);
 	} else {
-		if (tca[TCA_RATE-1])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev->queue_lock,
-					      tca[TCA_RATE-1]);
+		if (tca[TCA_RATE-1]) {
+			gen_replace_estimator(tca[TCA_RATE-1], &cl->ge);
+			/* XXX TO-DO: verify successful return from
+			   gen_replace_estimator()! */
+		}
 		sch_tree_lock(sch);
 	}
 
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index cd0aab6..7be51ad 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -145,8 +145,7 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 	 * firewall FW_* code.
 	 */
 #ifdef CONFIG_NET_CLS_ACT
-	sch->bstats.packets++;
-	sch->bstats.bytes += skb->len;
+	gen_bstat_skb(sch->ge, skb);
 	switch (result) {
 		case TC_ACT_SHOT:
 			result = TC_ACT_SHOT;
@@ -176,8 +175,7 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 		case TC_POLICE_OK:
 		case TC_POLICE_UNSPEC:
 		default:
-		sch->bstats.packets++;
-		sch->bstats.bytes += skb->len;
+		gen_bstat_skb(sch->ge, skb);
 		result = NF_ACCEPT;
 		break;
 	}
@@ -185,8 +183,7 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 #else
 	D2PRINTK("Overriding result to ACCEPT\n");
 	result = NF_ACCEPT;
-	sch->bstats.packets++;
-	sch->bstats.bytes += skb->len;
+	gen_bstat_skb(sch->ge, skb);
 #endif
 #endif
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9e5e87e..77c3575 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -231,8 +231,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
+		gen_bstat_skb(sch->ge, skb);
 	} else
 		sch->qstats.drops++;
 
@@ -506,8 +505,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 		__skb_queue_after(list, skb, nskb);
 
 		sch->qstats.backlog += nskb->len;
-		sch->bstats.bytes += nskb->len;
-		sch->bstats.packets++;
+		gen_bstat_skb(sch->ge, nskb);
 
 		return NET_XMIT_SUCCESS;
 	}
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2d8c084..5fb1954 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -88,8 +88,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #endif
 
 	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
+		gen_bstat_skb(sch->ge, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
@@ -430,7 +429,7 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
-	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, &cl_q->ge->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 9b95fef..7161a37 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -94,8 +94,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	ret = child->enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
+		gen_bstat_skb(sch->ge, skb);
 		sch->q.qlen++;
 	} else {
 		q->stats.pdrop++;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 9579573..4880299 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -271,8 +271,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		}
 	}
 	if (++sch->q.qlen < q->limit-1) {
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
+		gen_bstat_skb(sch->ge, skb);
 		return 0;
 	}
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 22e431d..817eed2 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -139,8 +139,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 
 	sch->q.qlen++;
-	sch->bstats.bytes += skb->len;
-	sch->bstats.packets++;
+	gen_bstat_skb(sch->ge, skb);
 	return 0;
 }
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 0968184..af6deaa 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -83,8 +83,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (q->q.qlen < dev->tx_queue_len) {
 		__skb_queue_tail(&q->q, skb);
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
+		gen_bstat_skb(sch->ge, skb);
 		return 0;
 	}
 

--=-af8dJ/POfrC5mfYKvloM--

