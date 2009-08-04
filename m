From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Tue, 4 Aug 2009 22:23:16 +0200
Message-ID: <20090804202316.GA26852@ami.dom.local>
References: <20090804155135.26922.12356.sendpatchset@localhost.localdomain> <OF5F51C767.3D9CCC17-ON65257608.00598327-65257608.0059D467@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:35625 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbZHDUXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:23:37 -0400
Received: by fxm17 with SMTP id 17so3509150fxm.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 13:23:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OF5F51C767.3D9CCC17-ON65257608.00598327-65257608.0059D467@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2009 at 09:51:10PM +0530, Krishna Kumar2 wrote:
> I will send out a final version after any more comments with a fix for a
> typo:
> 
> -static inline int __qdisc_update_bstats(struct Qdisc *sch, unsigned int
> len)
> +static inline void __qdisc_update_bstats(struct Qdisc *sch, unsigned int
> len)
> 
> Thanks,
> 
> - KK

Yes, except this typo this patch looks OK to me.

Thanks,
Jarek P.

> 
> Krishna Kumar2/India/IBM@IBMIN wrote on 08/04/2009 09:21:35 PM:
> > Hi Jarek,
> >
> > (Sorry that you are getting this mail twice since the mail didn't go out
> to
> > others, but this time I have fixed my mailer)
> >
> > > Actually I meant:
> > > -      qdisc->q.qlen--;
> > > +      qdisc->q.qlen = 0;
> > > because you can do it after another qdisc->q.qlen = 0.
> >
> > You are right - I saw some of the sched resets setting it to zero (while
> others
> > dont touch it). I will reset to zero.
> >
> > > > > I wonder if we shouldn't update bstats yet. Btw, try checkpatch.
> > > >
> > > > Rate estimator isn't used for default qdisc, so is anything
> > > > required?
> > >
> > > I meant "Sent" stats from "tc -s qdisc sh" could be misleading.
> >
> > You are right - for a single netperf run, the stats magically show 0
> > packets/bytes sent!
> >
> > > > Also, checkpatch suggested to change the original code:
> > > >         "if (unlikely((skb = dequeue_skb(q)) == NULL))"
> > > > since it appears as "new code", hope that change is fine.
> > >
> > > I mainly meant a whitespace warning.
> >
> > Yes, I had fixed that also.
> >
> > A compile and single-netperf-run tested patch is inlined below - the only
> > two changes from last patch is setting qlen=0 and updating bstats. Now
> > the stats show:
> >
> > qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> >  Sent 10170288228 bytes 157522 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >
> > On the original kernel, I got:
> > qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> >  Sent 10157266798 bytes 177539 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >
> > Thanks,
> >
> > - KK
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
> >  include/net/pkt_sched.h   |    3 +
> >  include/net/sch_generic.h |   15 +++++
> >  net/core/dev.c            |   51 ++++++++++++++-----
> >  net/sched/sch_generic.c   |   93 ++++++++++++++++++++++--------------
> >  4 files changed, 111 insertions(+), 51 deletions(-)
> >
> > diff -ruNp org2/include/net/pkt_sched.h new5/include/net/pkt_sched.h
> > --- org2/include/net/pkt_sched.h   2009-08-04 11:41:21.000000000 +0530
> > +++ new5/include/net/pkt_sched.h   2009-08-04 18:47:16.000000000 +0530
> > @@ -87,6 +87,9 @@ extern struct qdisc_rate_table *qdisc_ge
> >  extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
> >  extern void qdisc_put_stab(struct qdisc_size_table *tab);
> >  extern void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
> > +extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> > +            struct net_device *dev, struct netdev_queue *txq,
> > +            spinlock_t *root_lock);
> >
> >  extern void __qdisc_run(struct Qdisc *q);
> >
> > diff -ruNp org2/include/net/sch_generic.h new5/include/net/sch_generic.h
> > --- org2/include/net/sch_generic.h   2009-03-24 08:54:16.000000000 +0530
> > +++ new5/include/net/sch_generic.h   2009-08-04 19:58:26.000000000 +0530
> > @@ -45,6 +45,7 @@ struct Qdisc
> >  #define TCQ_F_BUILTIN      1
> >  #define TCQ_F_THROTTLED      2
> >  #define TCQ_F_INGRESS      4
> > +#define TCQ_F_CAN_BYPASS   8
> >  #define TCQ_F_WARN_NONWC   (1 << 16)
> >     int         padded;
> >     struct Qdisc_ops   *ops;
> > @@ -182,6 +183,11 @@ struct qdisc_skb_cb {
> >     char         data[];
> >  };
> >
> > +static inline int qdisc_qlen(struct Qdisc *q)
> > +{
> > +   return q->q.qlen;
> > +}
> > +
> >  static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
> >  {
> >     return (struct qdisc_skb_cb *)skb->cb;
> > @@ -387,13 +393,18 @@ static inline int qdisc_enqueue_root(str
> >     return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
> >  }
> >
> > +static inline int __qdisc_update_bstats(struct Qdisc *sch, unsigned int
> len)
> > +{
> > +   sch->bstats.bytes += len;
> > +   sch->bstats.packets++;
> > +}
> > +
> >  static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc
> *sch,
> >                     struct sk_buff_head *list)
> >  {
> >     __skb_queue_tail(list, skb);
> >     sch->qstats.backlog += qdisc_pkt_len(skb);
> > -   sch->bstats.bytes += qdisc_pkt_len(skb);
> > -   sch->bstats.packets++;
> > +   __qdisc_update_bstats(sch, qdisc_pkt_len(skb));
> >
> >     return NET_XMIT_SUCCESS;
> >  }
> > diff -ruNp org2/net/core/dev.c new5/net/core/dev.c
> > --- org2/net/core/dev.c   2009-07-27 09:08:24.000000000 +0530
> > +++ new5/net/core/dev.c   2009-08-04 20:26:57.000000000 +0530
> > @@ -1786,6 +1786,43 @@ static struct netdev_queue *dev_pick_tx(
> >     return netdev_get_tx_queue(dev, queue_index);
> >  }
> >
> > +static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
> > +             struct net_device *dev,
> > +             struct netdev_queue *txq)
> > +{
> > +   spinlock_t *root_lock = qdisc_lock(q);
> > +   int rc;
> > +
> > +   spin_lock(root_lock);
> > +   if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> > +      kfree_skb(skb);
> > +      rc = NET_XMIT_DROP;
> > +   } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
> > +         !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
> > +      unsigned int len = skb->len;
> > +
> > +      /*
> > +       * This is a work-conserving queue; there are no old skbs
> > +       * waiting to be sent out; and the qdisc is not running -
> > +       * xmit the skb directly.
> > +       */
> > +      if (sch_direct_xmit(skb, q, dev, txq, root_lock))
> > +         __qdisc_run(q);
> > +      else
> > +         clear_bit(__QDISC_STATE_RUNNING, &q->state);
> > +
> > +      __qdisc_update_bstats(q, len);
> > +
> > +      rc = NET_XMIT_SUCCESS;
> > +   } else {
> > +      rc = qdisc_enqueue_root(skb, q);
> > +      qdisc_run(q);
> > +   }
> > +   spin_unlock(root_lock);
> > +
> > +   return rc;
> > +}
> > +
> >  /**
> >   *   dev_queue_xmit - transmit a buffer
> >   *   @skb: buffer to transmit
> > @@ -1859,19 +1896,7 @@ gso:
> >     skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
> >  #endif
> >     if (q->enqueue) {
> > -      spinlock_t *root_lock = qdisc_lock(q);
> > -
> > -      spin_lock(root_lock);
> > -
> > -      if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> > -         kfree_skb(skb);
> > -         rc = NET_XMIT_DROP;
> > -      } else {
> > -         rc = qdisc_enqueue_root(skb, q);
> > -         qdisc_run(q);
> > -      }
> > -      spin_unlock(root_lock);
> > -
> > +      rc = __dev_xmit_skb(skb, q, dev, txq);
> >        goto out;
> >     }
> >
> > diff -ruNp org2/net/sched/sch_generic.c new5/net/sched/sch_generic.c
> > --- org2/net/sched/sch_generic.c   2009-05-25 07:48:07.000000000 +0530
> > +++ new5/net/sched/sch_generic.c   2009-08-04 19:38:27.000000000 +0530
> > @@ -37,15 +37,11 @@
> >   * - updates to tree and tree walking are only done under the rtnl
> mutex.
> >   */
> >
> > -static inline int qdisc_qlen(struct Qdisc *q)
> > -{
> > -   return q->q.qlen;
> > -}
> > -
> >  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
> >  {
> >     q->gso_skb = skb;
> >     q->qstats.requeues++;
> > +   q->q.qlen++;   /* it's still part of the queue */
> >     __netif_schedule(q);
> >
> >     return 0;
> > @@ -61,9 +57,11 @@ static inline struct sk_buff *dequeue_sk
> >
> >        /* check the reason of requeuing without tx lock first */
> >        txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> > -      if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
> > +      if (!netif_tx_queue_stopped(txq) &&
> > +          !netif_tx_queue_frozen(txq)) {
> >           q->gso_skb = NULL;
> > -      else
> > +         q->q.qlen--;
> > +      } else
> >           skb = NULL;
> >     } else {
> >        skb = q->dequeue(q);
> > @@ -103,44 +101,23 @@ static inline int handle_dev_cpu_collisi
> >  }
> >
> >  /*
> > - * NOTE: Called under qdisc_lock(q) with locally disabled BH.
> > - *
> > - * __QDISC_STATE_RUNNING guarantees only one CPU can process
> > - * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
> > - * this queue.
> > - *
> > - *  netif_tx_lock serializes accesses to device driver.
> > - *
> > - *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
> > - *  if one is grabbed, another must be free.
> > - *
> > - * Note, that this procedure can be called by a watchdog timer
> > + * Transmit one skb, and handle the return status as required. Holding
> the
> > + * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute
> this
> > + * function.
> >   *
> >   * Returns to the caller:
> >   *            0  - queue is empty or throttled.
> >   *            >0 - queue is not empty.
> > - *
> >   */
> > -static inline int qdisc_restart(struct Qdisc *q)
> > +int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> > +          struct net_device *dev, struct netdev_queue *txq,
> > +          spinlock_t *root_lock)
> >  {
> > -   struct netdev_queue *txq;
> >     int ret = NETDEV_TX_BUSY;
> > -   struct net_device *dev;
> > -   spinlock_t *root_lock;
> > -   struct sk_buff *skb;
> > -
> > -   /* Dequeue packet */
> > -   if (unlikely((skb = dequeue_skb(q)) == NULL))
> > -      return 0;
> > -
> > -   root_lock = qdisc_lock(q);
> >
> >     /* And release qdisc */
> >     spin_unlock(root_lock);
> >
> > -   dev = qdisc_dev(q);
> > -   txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> > -
> >     HARD_TX_LOCK(dev, txq, smp_processor_id());
> >     if (!netif_tx_queue_stopped(txq) &&
> >         !netif_tx_queue_frozen(txq))
> > @@ -177,6 +154,44 @@ static inline int qdisc_restart(struct Q
> >     return ret;
> >  }
> >
> > +/*
> > + * NOTE: Called under qdisc_lock(q) with locally disabled BH.
> > + *
> > + * __QDISC_STATE_RUNNING guarantees only one CPU can process
> > + * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
> > + * this queue.
> > + *
> > + *  netif_tx_lock serializes accesses to device driver.
> > + *
> > + *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
> > + *  if one is grabbed, another must be free.
> > + *
> > + * Note, that this procedure can be called by a watchdog timer
> > + *
> > + * Returns to the caller:
> > + *            0  - queue is empty or throttled.
> > + *            >0 - queue is not empty.
> > + *
> > + */
> > +static inline int qdisc_restart(struct Qdisc *q)
> > +{
> > +   struct netdev_queue *txq;
> > +   struct net_device *dev;
> > +   spinlock_t *root_lock;
> > +   struct sk_buff *skb;
> > +
> > +   /* Dequeue packet */
> > +   skb = dequeue_skb(q);
> > +   if (unlikely(!skb))
> > +      return 0;
> > +
> > +   root_lock = qdisc_lock(q);
> > +   dev = qdisc_dev(q);
> > +   txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> > +
> > +   return sch_direct_xmit(skb, q, dev, txq, root_lock);
> > +}
> > +
> >  void __qdisc_run(struct Qdisc *q)
> >  {
> >     unsigned long start_time = jiffies;
> > @@ -547,8 +562,11 @@ void qdisc_reset(struct Qdisc *qdisc)
> >     if (ops->reset)
> >        ops->reset(qdisc);
> >
> > -   kfree_skb(qdisc->gso_skb);
> > -   qdisc->gso_skb = NULL;
> > +   if (qdisc->gso_skb) {
> > +      kfree_skb(qdisc->gso_skb);
> > +      qdisc->gso_skb = NULL;
> > +      qdisc->q.qlen = 0;
> > +   }
> >  }
> >  EXPORT_SYMBOL(qdisc_reset);
> >
> > @@ -605,6 +623,9 @@ static void attach_one_default_qdisc(str
> >           printk(KERN_INFO "%s: activation failed\n", dev->name);
> >           return;
> >        }
> > +
> > +      /* Can by-pass the queue discipline for default qdisc */
> > +      qdisc->flags |= TCQ_F_CAN_BYPASS;
> >     } else {
> >        qdisc =  &noqueue_qdisc;
> >     }
> 
