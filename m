From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Tue, 4 Aug 2009 07:22:05 +0000
Message-ID: <20090804072205.GA4927@ff.dom.local>
References: <OF1689973C.61968A07-ON65257607.003168D7-65257607.0033083B@in.ibm.com> <20090803193847.GA3471@ami.dom.local> <OF104CB719.2A67F34E-ON65257608.001D0048-65257608.0026016D@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:38310 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932494AbZHDHWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 03:22:14 -0400
Received: by bwz19 with SMTP id 19so2902792bwz.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 00:22:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OF104CB719.2A67F34E-ON65257608.001D0048-65257608.0026016D@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2009 at 12:25:07PM +0530, Krishna Kumar2 wrote:
> Jarek Poplawski <jarkao2@gmail.com> wrote on 08/04/2009 01:08:47 AM:
> 
> Hi Jarek,
> 
> > Since this quoted part looks very similarly I'm using it here, so
> > forget my note if something has changed.
> 
> Thanks for your feedback. Yes, the inline patch is the same as the
> attached one.
> 
> > >> @@ -306,6 +312,9 @@ extern struct Qdisc *qdisc_create_dflt(s
> > >>                     struct Qdisc_ops *ops, u32 parentid);
> > >>  extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
> > >>                 struct qdisc_size_table *stab);
> > >> +extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> > >> +            struct net_device *dev, struct netdev_queue *txq,
> > >> +            spinlock_t *root_lock);
> >
> > Probably this would look better in pkt_sched.h around __qdisc_run()?
> 
> I had it originally in pkt_sched.h, for some reason I had moved it to
> sch_generic.h, I will move it back.
> 
> > >> +static inline int __dev_hw_xmit(struct sk_buff *skb, struct Qdisc *q,
> >
> > I guess, we don't touch "hw" in this function yet?
> 
> Right - this was due to lack of a good name. Maybe I can call it
> __dev_xmit_skb?

Looks better to me.

> 
> > >> -   kfree_skb(qdisc->gso_skb);
> > >> -   qdisc->gso_skb = NULL;
> > >> +   if (qdisc->gso_skb) {
> > >> +      kfree_skb(qdisc->gso_skb);
> > >> +      qdisc->gso_skb = NULL;
> > >> +      qdisc->q.qlen--;
> >
> > You don't need this here: qdiscs should zero it in ops->reset().
> 
> I will keep it around, as you said in your other mail.

Actually I meant:
-      qdisc->q.qlen--;
+      qdisc->q.qlen = 0;
because you can do it after another qdisc->q.qlen = 0.

> 
> > >> +      /* Can by-pass the queue discipline for default qdisc */
> > >> +      qdisc->flags = TCQ_F_CAN_BYPASS;
> >
> > "|=" looks nicer to me.
> 
> Agreed - and required if qdisc_create_dflt (and the functions it calls)
> is changed to set the flags.
> 
> > >>     } else {
> > >>        qdisc =  &noqueue_qdisc;
> > >>     }
> >
> > I wonder if we shouldn't update bstats yet. Btw, try checkpatch.
> 
> Rate estimator isn't used for default qdisc, so is anything
> required?

I meant "Sent" stats from "tc -s qdisc sh" could be misleading.

> Also, checkpatch suggested to change the original code:
>         "if (unlikely((skb = dequeue_skb(q)) == NULL))"
> since it appears as "new code", hope that change is fine.

I mainly meant a whitespace warning.

> 
> The patch after incorporating the review comments is both attached
> and inlined, since my mailer is still not working (I sent this mail
> about an hour back but this one didn't seem to have made it while
> one of my latter mails did).

I got 2 very similar messages this time, several minutes ago ;-)

Thanks,
Jarek P.

> 
> Thanks,
> 
> - KK
> 
>  (See attached file: patch4)
> 
> ----------------------------------------------------------------------
>  include/net/pkt_sched.h   |    3 +
>  include/net/sch_generic.h |    6 ++
>  net/core/dev.c            |   46 ++++++++++++-----
>  net/sched/sch_generic.c   |   93 ++++++++++++++++++++++--------------
>  4 files changed, 99 insertions(+), 49 deletions(-)
> 
> diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
> --- org/include/net/pkt_sched.h 2009-08-04 11:41:21.000000000 +0530
> +++ new/include/net/pkt_sched.h 2009-08-04 11:42:18.000000000 +0530
> @@ -87,6 +87,9 @@ extern struct qdisc_rate_table *qdisc_ge
>  extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
>  extern void qdisc_put_stab(struct qdisc_size_table *tab);
>  extern void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
> +extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> +                          struct net_device *dev, struct netdev_queue
> *txq,
> +                          spinlock_t *root_lock);
> 
>  extern void __qdisc_run(struct Qdisc *q);
> 
> diff -ruNp org/include/net/sch_generic.h new/include/net/sch_generic.h
> --- org/include/net/sch_generic.h       2009-03-24 08:54:16.000000000 +0530
> +++ new/include/net/sch_generic.h       2009-08-04 11:02:39.000000000 +0530
> @@ -45,6 +45,7 @@ struct Qdisc
>  #define TCQ_F_BUILTIN          1
>  #define TCQ_F_THROTTLED                2
>  #define TCQ_F_INGRESS          4
> +#define TCQ_F_CAN_BYPASS       8
>  #define TCQ_F_WARN_NONWC       (1 << 16)
>         int                     padded;
>         struct Qdisc_ops        *ops;
> @@ -182,6 +183,11 @@ struct qdisc_skb_cb {
>         char                    data[];
>  };
> 
> +static inline int qdisc_qlen(struct Qdisc *q)
> +{
> +       return q->q.qlen;
> +}
> +
>  static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
>  {
>         return (struct qdisc_skb_cb *)skb->cb;
> diff -ruNp org/net/core/dev.c new/net/core/dev.c
> --- org/net/core/dev.c  2009-07-27 09:08:24.000000000 +0530
> +++ new/net/core/dev.c  2009-08-04 11:44:57.000000000 +0530
> @@ -1786,6 +1786,38 @@ static struct netdev_queue *dev_pick_tx(
>         return netdev_get_tx_queue(dev, queue_index);
>  }
> 
> +static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
> +                                struct net_device *dev,
> +                                struct netdev_queue *txq)
> +{
> +       spinlock_t *root_lock = qdisc_lock(q);
> +       int rc;
> +
> +       spin_lock(root_lock);
> +       if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> +               kfree_skb(skb);
> +               rc = NET_XMIT_DROP;
> +       } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
> +                  !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
> +               /*
> +                * This is a work-conserving queue; there are no old skbs
> +                * waiting to be sent out; and the qdisc is not running -
> +                * xmit the skb directly.
> +                */
> +               if (sch_direct_xmit(skb, q, dev, txq, root_lock))
> +                       __qdisc_run(q);
> +               else
> +                       clear_bit(__QDISC_STATE_RUNNING, &q->state);
> +               rc = NET_XMIT_SUCCESS;
> +       } else {
> +               rc = qdisc_enqueue_root(skb, q);
> +               qdisc_run(q);
> +       }
> +       spin_unlock(root_lock);
> +
> +       return rc;
> +}
> +
>  /**
>   *     dev_queue_xmit - transmit a buffer
>   *     @skb: buffer to transmit
> @@ -1859,19 +1891,7 @@ gso:
>         skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
>  #endif
>         if (q->enqueue) {
> -               spinlock_t *root_lock = qdisc_lock(q);
> -
> -               spin_lock(root_lock);
> -
> -               if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED,
> &q->state))) {
> -                       kfree_skb(skb);
> -                       rc = NET_XMIT_DROP;
> -               } else {
> -                       rc = qdisc_enqueue_root(skb, q);
> -                       qdisc_run(q);
> -               }
> -               spin_unlock(root_lock);
> -
> +               rc = __dev_xmit_skb(skb, q, dev, txq);
>                 goto out;
>         }
> 
> diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c 2009-05-25 07:48:07.000000000 +0530
> +++ new/net/sched/sch_generic.c 2009-08-04 11:00:38.000000000 +0530
> @@ -37,15 +37,11 @@
>   * - updates to tree and tree walking are only done under the rtnl mutex.
>   */
> 
> -static inline int qdisc_qlen(struct Qdisc *q)
> -{
> -       return q->q.qlen;
> -}
> -
>  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>  {
>         q->gso_skb = skb;
>         q->qstats.requeues++;
> +       q->q.qlen++;    /* it's still part of the queue */
>         __netif_schedule(q);
> 
>         return 0;
> @@ -61,9 +57,11 @@ static inline struct sk_buff *dequeue_sk
> 
>                 /* check the reason of requeuing without tx lock first */
>                 txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> -               if (!netif_tx_queue_stopped(txq) &&
> !netif_tx_queue_frozen(txq))
> +               if (!netif_tx_queue_stopped(txq) &&
> +                   !netif_tx_queue_frozen(txq)) {
>                         q->gso_skb = NULL;
> -               else
> +                       q->q.qlen--;
> +               } else
>                         skb = NULL;
>         } else {
>                 skb = q->dequeue(q);
> @@ -103,44 +101,23 @@ static inline int handle_dev_cpu_collisi
>  }
> 
>  /*
> - * NOTE: Called under qdisc_lock(q) with locally disabled BH.
> - *
> - * __QDISC_STATE_RUNNING guarantees only one CPU can process
> - * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
> - * this queue.
> - *
> - *  netif_tx_lock serializes accesses to device driver.
> - *
> - *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
> - *  if one is grabbed, another must be free.
> - *
> - * Note, that this procedure can be called by a watchdog timer
> + * Transmit one skb, and handle the return status as required. Holding the
> + * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute this
> + * function.
>   *
>   * Returns to the caller:
>   *                             0  - queue is empty or throttled.
>   *                             >0 - queue is not empty.
> - *
>   */
> -static inline int qdisc_restart(struct Qdisc *q)
> +int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> +                   struct net_device *dev, struct netdev_queue *txq,
> +                   spinlock_t *root_lock)
>  {
> -       struct netdev_queue *txq;
>         int ret = NETDEV_TX_BUSY;
> -       struct net_device *dev;
> -       spinlock_t *root_lock;
> -       struct sk_buff *skb;
> -
> -       /* Dequeue packet */
> -       if (unlikely((skb = dequeue_skb(q)) == NULL))
> -               return 0;
> -
> -       root_lock = qdisc_lock(q);
> 
>         /* And release qdisc */
>         spin_unlock(root_lock);
> 
> -       dev = qdisc_dev(q);
> -       txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> -
>         HARD_TX_LOCK(dev, txq, smp_processor_id());
>         if (!netif_tx_queue_stopped(txq) &&
>             !netif_tx_queue_frozen(txq))
> @@ -177,6 +154,44 @@ static inline int qdisc_restart(struct Q
>         return ret;
>  }
> 
> +/*
> + * NOTE: Called under qdisc_lock(q) with locally disabled BH.
> + *
> + * __QDISC_STATE_RUNNING guarantees only one CPU can process
> + * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
> + * this queue.
> + *
> + *  netif_tx_lock serializes accesses to device driver.
> + *
> + *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
> + *  if one is grabbed, another must be free.
> + *
> + * Note, that this procedure can be called by a watchdog timer
> + *
> + * Returns to the caller:
> + *                             0  - queue is empty or throttled.
> + *                             >0 - queue is not empty.
> + *
> + */
> +static inline int qdisc_restart(struct Qdisc *q)
> +{
> +       struct netdev_queue *txq;
> +       struct net_device *dev;
> +       spinlock_t *root_lock;
> +       struct sk_buff *skb;
> +
> +       /* Dequeue packet */
> +       skb = dequeue_skb(q);
> +       if (unlikely(!skb))
> +               return 0;
> +
> +       root_lock = qdisc_lock(q);
> +       dev = qdisc_dev(q);
> +       txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> +
> +       return sch_direct_xmit(skb, q, dev, txq, root_lock);
> +}
> +
>  void __qdisc_run(struct Qdisc *q)
>  {
>         unsigned long start_time = jiffies;
> @@ -547,8 +562,11 @@ void qdisc_reset(struct Qdisc *qdisc)
>         if (ops->reset)
>                 ops->reset(qdisc);
> 
> -       kfree_skb(qdisc->gso_skb);
> -       qdisc->gso_skb = NULL;
> +       if (qdisc->gso_skb) {
> +               kfree_skb(qdisc->gso_skb);
> +               qdisc->gso_skb = NULL;
> +               qdisc->q.qlen--;
> +       }
>  }
>  EXPORT_SYMBOL(qdisc_reset);
> 
> @@ -605,6 +623,9 @@ static void attach_one_default_qdisc(str
>                         printk(KERN_INFO "%s: activation failed\n",
> dev->name);
>                         return;
>                 }
> +
> +               /* Can by-pass the queue discipline for default qdisc */
> +               qdisc->flags |= TCQ_F_CAN_BYPASS;
>         } else {
>                 qdisc =  &noqueue_qdisc;
>         }


