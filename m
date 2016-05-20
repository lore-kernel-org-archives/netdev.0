From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Fri, 20 May 2016 05:44:25 -0700
Message-ID: <1463748265.18194.279.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
	 <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35650 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbcETMo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 08:44:28 -0400
Received: by mail-pa0-f68.google.com with SMTP id rw9so10867675pab.2
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 05:44:28 -0700 (PDT)
In-Reply-To: <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 19:45 -0700, Eric Dumazet wrote:
> On Thu, 2016-05-19 at 18:50 -0700, Cong Wang wrote:
> > On Thu, May 19, 2016 at 5:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >
> > > These stats are using u64 or u32 fields, so reading integral values
> > > should not prevent writers from doing concurrent updates if the kernel
> > > arch is a 64bit one.
> > >
> > > Being able to atomically fetch all counters like packets and bytes sent
> > > at the expense of interfering in fast path (queue and dequeue packets)
> > > is simply not worth the pain, as the values are generally stale after 1
> > > usec.
> > 
> > I think one purpose of this lock is to make sure we have an atomic
> > snapshot of these counters as a whole. IOW, we may need another
> > lock rather than the qdisc root lock to guarantee this.
> 
> Right, this was stated in the changelog.
> 
> I played a bit at changing qdisc->__state to a seqcount.
> 
> But this would add 2 additional smp_wmb() barriers.

Although this would allow the mechanism to be used both on 32bit an
64bit kernels.

This would also add LOCKDEP annotations which can be nice for debugging.

Also the seqcount value >> 1 would give us the number of __qdisc_run()
and we could compute packets/(seqcount>>1) to get the average number of
packets processed per round.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 941ec99cd3b6..471095beca09 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4610,6 +4610,7 @@ static int bond_check_params(struct bond_params *params)
 static struct lock_class_key bonding_netdev_xmit_lock_key;
 static struct lock_class_key bonding_netdev_addr_lock_key;
 static struct lock_class_key bonding_tx_busylock_key;
+static struct lock_class_key bonding_qdisc_running;
 
 static void bond_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -4625,6 +4626,7 @@ static void bond_set_lockdep_class(struct net_device *dev)
 			  &bonding_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
 	dev->qdisc_tx_busylock = &bonding_tx_busylock_key;
+	dev->qdisc_running = &bonding_qdisc_running;
 }
 
 /* Called from registration process */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c148edfe4965..e06646b69b06 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1862,6 +1862,7 @@ struct net_device {
 #endif
 	struct phy_device	*phydev;
 	struct lock_class_key	*qdisc_tx_busylock;
+	struct lock_class_key	*qdisc_running;
 	bool			proto_down;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a1fd76c22a59..bff8d895ef8a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -29,13 +29,6 @@ enum qdisc_state_t {
 	__QDISC_STATE_THROTTLED,
 };
 
-/*
- * following bits are only changed while qdisc lock is held
- */
-enum qdisc___state_t {
-	__QDISC___STATE_RUNNING = 1,
-};
-
 struct qdisc_size_table {
 	struct rcu_head		rcu;
 	struct list_head	list;
@@ -93,7 +86,7 @@ struct Qdisc {
 	unsigned long		state;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
-	unsigned int		__state;
+	seqcount_t		running;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
 	int			padded;
@@ -104,20 +97,20 @@ struct Qdisc {
 
 static inline bool qdisc_is_running(const struct Qdisc *qdisc)
 {
-	return (qdisc->__state & __QDISC___STATE_RUNNING) ? true : false;
+	return (raw_read_seqcount(&qdisc->running) & 1) ? true : false;
 }
 
 static inline bool qdisc_run_begin(struct Qdisc *qdisc)
 {
 	if (qdisc_is_running(qdisc))
 		return false;
-	qdisc->__state |= __QDISC___STATE_RUNNING;
+	write_seqcount_begin(&qdisc->running);
 	return true;
 }
 
 static inline void qdisc_run_end(struct Qdisc *qdisc)
 {
-	qdisc->__state &= ~__QDISC___STATE_RUNNING;
+	write_seqcount_end(&qdisc->running);
 }
 
 static inline bool qdisc_may_bulk(const struct Qdisc *qdisc)
diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff431d570..55b414dead29 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3075,7 +3075,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
 	 * separate lock before trying to get qdisc main lock.
-	 * This permits __QDISC___STATE_RUNNING owner to get the lock more
+	 * This permits qdisc->running owner to get the lock more
 	 * often and dequeue packets faster.
 	 */
 	contended = qdisc_is_running(q);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 269dd71b3828..d25412364c07 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -110,7 +110,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 
 /*
  * Transmit possibly several skbs, and handle the return status as
- * required. Holding the __QDISC___STATE_RUNNING bit guarantees that
+ * required. Owning running seqcount bit guarantees that
  * only one CPU can execute this function.
  *
  * Returns to the caller:
@@ -163,7 +163,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 /*
  * NOTE: Called under qdisc_lock(q) with locally disabled BH.
  *
- * __QDISC___STATE_RUNNING guarantees only one CPU can process
+ * running seqcount guarantees only one CPU can process (dequeue packets)
  * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
  * this queue.
  *
@@ -379,6 +379,7 @@ struct Qdisc noop_qdisc = {
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
+	.running	=	SEQCNT_ZERO(noop_qdisc.running),
 	.busylock	=	__SPIN_LOCK_UNLOCKED(noop_qdisc.busylock),
 };
 EXPORT_SYMBOL(noop_qdisc);
@@ -537,6 +538,7 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 EXPORT_SYMBOL(pfifo_fast_ops);
 
 static struct lock_class_key qdisc_tx_busylock;
+static struct lock_class_key qdisc_running_class;
 
 struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 			  const struct Qdisc_ops *ops)
@@ -570,6 +572,10 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	lockdep_set_class(&sch->busylock,
 			  dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);
 
+	seqcount_init(&sch->running);
+	lockdep_set_class(&sch->running,
+			  dev->qdisc_running ?: &qdisc_running_class);
+
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
