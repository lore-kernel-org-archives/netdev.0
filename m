From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Mon, 3 Aug 2009 21:38:47 +0200
Message-ID: <20090803193847.GA3471@ami.dom.local>
References: <OF1689973C.61968A07-ON65257607.003168D7-65257607.0033083B@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:49715 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754664AbZHCTjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 15:39:17 -0400
Received: by fxm17 with SMTP id 17so2841993fxm.37
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 12:39:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OF1689973C.61968A07-ON65257607.003168D7-65257607.0033083B@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2 wrote, On 08/03/2009 11:17 AM:

> It is not going through for some reason though I sent the patch about
> 1.5 hours back. Is it OK if I attach the patch this one time while I figure
> out what needs to be done to fix my mailer to start working again?
> 
> Following attachment contains the description and the patch.
> 
> thanks,
> 
> - KK
> 
> 
> (See attached file: patch.dont_queue)

Since this quoted part looks very similarly I'm using it here, so
forget my note if something has changed.

> 
> 
> Krishna Kumar2/India/IBM@IBMIN wrote on 08/03/2009 01:40:16 PM:
> 
>> Krishna Kumar2/India/IBM@IBMIN
>> 08/03/2009 01:40 PM
>>
>> To
>>
>> davem@davemloft.net
>>
>> cc
>>
>> Krishna Kumar2/India/IBM@IBMIN, herbert@gondor.apana.org.au,
> kaber@trash.net,
>> jarkao2@gmail.com, netdev@vger.kernel.org
>>
>> Subject
>>
>> [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
>>
>> From: Krishna Kumar <krkumar2@in.ibm.com>
>>
>> dev_queue_xmit enqueue's a skb and calls qdisc_run which
>> dequeue's the skb and xmits it. In most cases (after
>> instrumenting the code), the skb that is enqueue'd is the
>> same one that is dequeue'd (unless the queue gets stopped
>> or multiple cpu's write to the same queue and ends in a
>> race with qdisc_run). For default qdiscs, we can remove
>> this path and simply xmit the skb since this is a work
>> conserving queue.
>>
>> The patch uses a new flag - TCQ_F_CAN_BYPASS to identify
>> the default fast queue. I plan to use this flag for the
>> previous patch also (rename if required).  The controversial
>> part of the patch is incrementing qlen when a skb is
>> requeued, this is to avoid checks like the second line below:
>>
>> +    } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
>>>> THIS LINE:   !q->gso_skb &&
>> +               !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
>>
>> Results of a 4 hour testing for multiple netperf sessions
>> (1, 2, 4, 8, 12 sessions on a 4 cpu system-X and 1, 2, 4,
>> 8, 16, 32 sessions on a 16 cpu P6). Aggregate Mb/s across
>> the iterations:
>>
>> -----------------------------------------------------------------
>>      |         System-X          |               P6
>> -----------------------------------------------------------------
>> Size |  ORG BW          NEW BW   |      ORG BW          NEW BW
>> -----|---------------------------|-------------------------------
>> 16K  |  154264          156234   |      155350          157569
>> 64K  |  154364          154825   |      155790          158845
>> 128K |  154644          154803   |      153418          155572
>> 256K |  153882          152007   |      154784          154596
>> -----------------------------------------------------------------
>>
>> Netperf reported Service demand reduced by 15% on the P6 but
>> no noticeable difference on the system-X box.
>>
>> Please review.
>>
>> Thanks,
>>
>> - KK
>>
>> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>> ---
>>
>>  include/net/sch_generic.h |    9 +++
>>  net/core/dev.c            |   46 ++++++++++++-----
>>  net/sched/sch_generic.c   |   94 +++++++++++++++++++++---------------
>>  3 files changed, 99 insertions(+), 50 deletions(-)
>>
>> diff -ruNp org/include/net/sch_generic.h new/include/net/sch_generic.h
>> --- org/include/net/sch_generic.h   2009-03-24 08:54:16.000000000 +0530
>> +++ new/include/net/sch_generic.h   2009-07-28 19:37:10.000000000 +0530
>> @@ -45,6 +45,7 @@ struct Qdisc
>>  #define TCQ_F_BUILTIN      1
>>  #define TCQ_F_THROTTLED      2
>>  #define TCQ_F_INGRESS      4
>> +#define TCQ_F_CAN_BYPASS   8
>>  #define TCQ_F_WARN_NONWC   (1 << 16)
>>     int         padded;
>>     struct Qdisc_ops   *ops;
>> @@ -182,6 +183,11 @@ struct qdisc_skb_cb {
>>     char         data[];
>>  };
>>
>> +static inline int qdisc_qlen(struct Qdisc *q)
>> +{
>> +   return q->q.qlen;
>> +}
>> +
>>  static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
>>  {
>>     return (struct qdisc_skb_cb *)skb->cb;
>> @@ -306,6 +312,9 @@ extern struct Qdisc *qdisc_create_dflt(s
>>                     struct Qdisc_ops *ops, u32 parentid);
>>  extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
>>                 struct qdisc_size_table *stab);
>> +extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>> +            struct net_device *dev, struct netdev_queue *txq,
>> +            spinlock_t *root_lock);

Probably this would look better in pkt_sched.h around __qdisc_run()?

>>  extern void tcf_destroy(struct tcf_proto *tp);
>>  extern void tcf_destroy_chain(struct tcf_proto **fl);
>>
>> diff -ruNp org2/net/core/dev.c new2/net/core/dev.c
>> --- org2/net/core/dev.c   2009-07-27 09:08:24.000000000 +0530
>> +++ new2/net/core/dev.c   2009-07-28 19:37:10.000000000 +0530
>> @@ -1786,6 +1786,38 @@ static struct netdev_queue *dev_pick_tx(
>>     return netdev_get_tx_queue(dev, queue_index);
>>  }
>>
>> +static inline int __dev_hw_xmit(struct sk_buff *skb, struct Qdisc *q,

I guess, we don't touch "hw" in this function yet?

>> +            struct net_device *dev,
>> +            struct netdev_queue *txq)
>> +{
>> +   spinlock_t *root_lock = qdisc_lock(q);
>> +   int rc;
>> +
>> +   spin_lock(root_lock);
>> +   if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
>> +      kfree_skb(skb);
>> +      rc = NET_XMIT_DROP;
>> +   } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
>> +         !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
>> +      /*
>> +       * This is the default work-conserving queue; there are no
>> +       * old skbs waiting to be sent out; and the qdisc is not
>> +       * running - xmit the skb directly.
>> +       */
>> +      if (sch_direct_xmit(skb, q, dev, txq, root_lock))
>> +         __qdisc_run(q);
>> +      else
>> +         clear_bit(__QDISC_STATE_RUNNING, &q->state);
>> +      rc = 0;

-      rc = 0;
+      rc = NET_XMIT_SUCCESS;

>> +   } else {
>> +      rc = qdisc_enqueue_root(skb, q);
>> +      qdisc_run(q);
>> +   }
>> +   spin_unlock(root_lock);
>> +
>> +   return rc;
>> +}
>> +
>>  /**
>>   *   dev_queue_xmit - transmit a buffer
>>   *   @skb: buffer to transmit
>> @@ -1859,19 +1891,7 @@ gso:
>>     skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
>>  #endif
>>     if (q->enqueue) {
>> -      spinlock_t *root_lock = qdisc_lock(q);
>> -
>> -      spin_lock(root_lock);
>> -
>> -      if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
>> -         kfree_skb(skb);
>> -         rc = NET_XMIT_DROP;
>> -      } else {
>> -         rc = qdisc_enqueue_root(skb, q);
>> -         qdisc_run(q);
>> -      }
>> -      spin_unlock(root_lock);
>> -
>> +      rc = __dev_hw_xmit(skb, q, dev, txq);
>>        goto out;
>>     }
>>
>> diff -ruNp org2/net/sched/sch_generic.c new2/net/sched/sch_generic.c
>> --- org2/net/sched/sch_generic.c   2009-05-25 07:48:07.000000000 +0530
>> +++ new2/net/sched/sch_generic.c   2009-07-28 19:40:39.000000000 +0530
>> @@ -37,15 +37,11 @@
>>   * - updates to tree and tree walking are only done under the rtnl
> mutex.
>>   */
>>
>> -static inline int qdisc_qlen(struct Qdisc *q)
>> -{
>> -   return q->q.qlen;
>> -}
>> -
>>  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>>  {
>>     q->gso_skb = skb;
>>     q->qstats.requeues++;
>> +   q->q.qlen++;   /* it's still part of the queue */
>>     __netif_schedule(q);
>>
>>     return 0;
>> @@ -61,9 +57,11 @@ static inline struct sk_buff *dequeue_sk
>>
>>        /* check the reason of requeuing without tx lock first */
>>        txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>> -      if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
>> +      if (!netif_tx_queue_stopped(txq) &&
>> +          !netif_tx_queue_frozen(txq)) {
>>           q->gso_skb = NULL;
>> -      else
>> +         q->q.qlen--;
>> +      } else
>>           skb = NULL;
>>     } else {
>>        skb = q->dequeue(q);
>> @@ -102,45 +100,24 @@ static inline int handle_dev_cpu_collisi
>>     return ret;
>>  }
>>
>> -/*
>> - * NOTE: Called under qdisc_lock(q) with locally disabled BH.
>> - *
>> - * __QDISC_STATE_RUNNING guarantees only one CPU can process
>> - * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
>> - * this queue.
>> - *
>> - *  netif_tx_lock serializes accesses to device driver.
>> - *
>> - *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
>> - *  if one is grabbed, another must be free.
>> - *
>> - * Note, that this procedure can be called by a watchdog timer
>> +/*
>> + * Transmit one skb, and handle the return status as required. Holding
> the
>> + * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute
> this
>> + * function.
>>   *
>>   * Returns to the caller:
>>   *            0  - queue is empty or throttled.
>>   *            >0 - queue is not empty.
>> - *
>>   */
>> -static inline int qdisc_restart(struct Qdisc *q)
>> +int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>> +          struct net_device *dev, struct netdev_queue *txq,
>> +          spinlock_t *root_lock)
>>  {
>> -   struct netdev_queue *txq;
>>     int ret = NETDEV_TX_BUSY;
>> -   struct net_device *dev;
>> -   spinlock_t *root_lock;
>> -   struct sk_buff *skb;
>> -
>> -   /* Dequeue packet */
>> -   if (unlikely((skb = dequeue_skb(q)) == NULL))
>> -      return 0;
>> -
>> -   root_lock = qdisc_lock(q);
>>
>>     /* And release qdisc */
>>     spin_unlock(root_lock);
>>
>> -   dev = qdisc_dev(q);
>> -   txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>> -
>>     HARD_TX_LOCK(dev, txq, smp_processor_id());
>>     if (!netif_tx_queue_stopped(txq) &&
>>         !netif_tx_queue_frozen(txq))
>> @@ -177,6 +154,43 @@ static inline int qdisc_restart(struct Q
>>     return ret;
>>  }
>>
>> +/*
>> + * NOTE: Called under qdisc_lock(q) with locally disabled BH.
>> + *
>> + * __QDISC_STATE_RUNNING guarantees only one CPU can process
>> + * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
>> + * this queue.
>> + *
>> + *  netif_tx_lock serializes accesses to device driver.
>> + *
>> + *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
>> + *  if one is grabbed, another must be free.
>> + *
>> + * Note, that this procedure can be called by a watchdog timer
>> + *
>> + * Returns to the caller:
>> + *            0  - queue is empty or throttled.
>> + *            >0 - queue is not empty.
>> + *
>> + */
>> +static inline int qdisc_restart(struct Qdisc *q)
>> +{
>> +   struct netdev_queue *txq;
>> +   struct net_device *dev;
>> +   spinlock_t *root_lock;
>> +   struct sk_buff *skb;
>> +
>> +   /* Dequeue packet */
>> +   if (unlikely((skb = dequeue_skb(q)) == NULL))
>> +      return 0;
>> +
>> +   root_lock = qdisc_lock(q);
>> +   dev = qdisc_dev(q);
>> +   txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>> +
>> +   return sch_xmit_direct(skb, q, dev, txq, root_lock);
>> +}
>> +
>>  void __qdisc_run(struct Qdisc *q)
>>  {
>>     unsigned long start_time = jiffies;
>> @@ -547,8 +561,11 @@ void qdisc_reset(struct Qdisc *qdisc)
>>     if (ops->reset)
>>        ops->reset(qdisc);
>>
>> -   kfree_skb(qdisc->gso_skb);
>> -   qdisc->gso_skb = NULL;
>> +   if (qdisc->gso_skb) {
>> +      kfree_skb(qdisc->gso_skb);
>> +      qdisc->gso_skb = NULL;
>> +      qdisc->q.qlen--;

You don't need this here: qdiscs should zero it in ops->reset().

>> +   }
>>  }
>>  EXPORT_SYMBOL(qdisc_reset);
>>
>> @@ -605,6 +622,9 @@ static void attach_one_default_qdisc(str
>>           printk(KERN_INFO "%s: activation failed\n", dev->name);
>>           return;
>>        }
>> +
>> +      /* Can by-pass the queue discipline for default qdisc */
>> +      qdisc->flags = TCQ_F_CAN_BYPASS;

"|=" looks nicer to me.

>>     } else {
>>        qdisc =  &noqueue_qdisc;
>>     }

I wonder if we shouldn't update bstats yet. Btw, try checkpatch.

Thanks,
Jarek P.
