From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 18:49:21 -0700 (PDT)
Message-ID: <20080817.184921.08829673.davem@davemloft.net>
References: <20080818012516.GB31337@gondor.apana.org.au>
	<20080817.183505.163224950.davem@davemloft.net>
	<20080818013633.GA31653@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbYHRBtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 21:49:21 -0400
In-Reply-To: <20080818013633.GA31653@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Aug 2008 11:36:33 +1000

> On Sun, Aug 17, 2008 at 06:35:05PM -0700, David Miller wrote:
> > I think I see another way out of this:
> > 
> > 1) Add __QDISC_STATE_DEACTIVATE.
> > 
> > 2) Set it right before dev_deactivate() swaps resets the qdisc
> >    pointer.
> > 
> > 3) Test it in dev_queue_xmit() et al. once the qdisc root lock is
> >    acquired, and drop lock and resample ->qdisc if
> >    __QDISC_STATE_DEACTIVATE is set.
> 
> Yep this sounds good to me.

Here it is as a patch below.

The test being added to __netif_schedule() is just a reminder that
we have to address the "both bits clear" case somehow, likely with
Jarko's patch which I unintentionally reimplemented :)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a7abfda..757ab08 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -27,6 +27,7 @@ enum qdisc_state_t
 {
 	__QDISC_STATE_RUNNING,
 	__QDISC_STATE_SCHED,
+	__QDISC_STATE_DEACTIVATED,
 };
 
 struct qdisc_size_table {
diff --git a/net/core/dev.c b/net/core/dev.c
index 600bb23..b88f669 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1341,6 +1341,9 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 
 void __netif_schedule(struct Qdisc *q)
 {
+	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
+		return;
+
 	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
 		struct softnet_data *sd;
 		unsigned long flags;
@@ -1790,6 +1793,8 @@ gso:
 	rcu_read_lock_bh();
 
 	txq = dev_pick_tx(dev, skb);
+
+resample_qdisc:
 	q = rcu_dereference(txq->qdisc);
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -1800,6 +1805,11 @@ gso:
 
 		spin_lock(root_lock);
 
+		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
+			spin_unlock(root_lock);
+			goto resample_qdisc;
+		}
+
 		rc = qdisc_enqueue_root(skb, q);
 		qdisc_run(q);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4685746..ff1c455 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -597,6 +597,9 @@ static void transition_one_qdisc(struct net_device *dev,
 	struct Qdisc *new_qdisc = dev_queue->qdisc_sleeping;
 	int *need_watchdog_p = _need_watchdog;
 
+	if (!(new_qdisc->flags & TCQ_F_BUILTIN))
+		clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
+
 	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
 	if (need_watchdog_p && new_qdisc != &noqueue_qdisc)
 		*need_watchdog_p = 1;
@@ -640,6 +643,9 @@ static void dev_deactivate_queue(struct net_device *dev,
 	if (qdisc) {
 		spin_lock_bh(qdisc_lock(qdisc));
 
+		if (!(qdisc->flags & TCQ_F_BUILTIN))
+			set_bit(__QDISC_STATE_DEACTIVATED, &qdisc->state);
+
 		dev_queue->qdisc = qdisc_default;
 		qdisc_reset(qdisc);
 
