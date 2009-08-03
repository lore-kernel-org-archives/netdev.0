From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Mon, 3 Aug 2009 14:47:24 +0530
Message-ID: <OF1689973C.61968A07-ON65257607.003168D7-65257607.0033083B@in.ibm.com>
References: <20090803081016.32746.23400.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=EABBFC94DFA2EE478f9e8a93df938690918cEABBFC94DFA2EE47"
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([59.145.155.9]:49709 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbZHCJnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 05:43:51 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n739fdUc011991
	for <netdev@vger.kernel.org>; Mon, 3 Aug 2009 15:11:39 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n739hiFO1396908
	for <netdev@vger.kernel.org>; Mon, 3 Aug 2009 15:13:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n739hh36007407
	for <netdev@vger.kernel.org>; Mon, 3 Aug 2009 19:43:44 +1000
In-Reply-To: <20090803081016.32746.23400.sendpatchset@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0__=EABBFC94DFA2EE478f9e8a93df938690918cEABBFC94DFA2EE47
Content-type: text/plain; charset=US-ASCII

It is not going through for some reason though I sent the patch about
1.5 hours back. Is it OK if I attach the patch this one time while I figure
out what needs to be done to fix my mailer to start working again?

Following attachment contains the description and the patch.

thanks,

- KK


(See attached file: patch.dont_queue)


Krishna Kumar2/India/IBM@IBMIN wrote on 08/03/2009 01:40:16 PM:

> Krishna Kumar2/India/IBM@IBMIN
> 08/03/2009 01:40 PM
>
> To
>
> davem@davemloft.net
>
> cc
>
> Krishna Kumar2/India/IBM@IBMIN, herbert@gondor.apana.org.au,
kaber@trash.net,
> jarkao2@gmail.com, netdev@vger.kernel.org
>
> Subject
>
> [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
>
> From: Krishna Kumar <krkumar2@in.ibm.com>
>
> dev_queue_xmit enqueue's a skb and calls qdisc_run which
> dequeue's the skb and xmits it. In most cases (after
> instrumenting the code), the skb that is enqueue'd is the
> same one that is dequeue'd (unless the queue gets stopped
> or multiple cpu's write to the same queue and ends in a
> race with qdisc_run). For default qdiscs, we can remove
> this path and simply xmit the skb since this is a work
> conserving queue.
>
> The patch uses a new flag - TCQ_F_CAN_BYPASS to identify
> the default fast queue. I plan to use this flag for the
> previous patch also (rename if required).  The controversial
> part of the patch is incrementing qlen when a skb is
> requeued, this is to avoid checks like the second line below:
>
> +    } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
> >> THIS LINE:   !q->gso_skb &&
> +               !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
>
> Results of a 4 hour testing for multiple netperf sessions
> (1, 2, 4, 8, 12 sessions on a 4 cpu system-X and 1, 2, 4,
> 8, 16, 32 sessions on a 16 cpu P6). Aggregate Mb/s across
> the iterations:
>
> -----------------------------------------------------------------
>      |         System-X          |               P6
> -----------------------------------------------------------------
> Size |  ORG BW          NEW BW   |      ORG BW          NEW BW
> -----|---------------------------|-------------------------------
> 16K  |  154264          156234   |      155350          157569
> 64K  |  154364          154825   |      155790          158845
> 128K |  154644          154803   |      153418          155572
> 256K |  153882          152007   |      154784          154596
> -----------------------------------------------------------------
>
> Netperf reported Service demand reduced by 15% on the P6 but
> no noticeable difference on the system-X box.
>
> Please review.
>
> Thanks,
>
> - KK
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>
>  include/net/sch_generic.h |    9 +++
>  net/core/dev.c            |   46 ++++++++++++-----
>  net/sched/sch_generic.c   |   94 +++++++++++++++++++++---------------
>  3 files changed, 99 insertions(+), 50 deletions(-)
>
> diff -ruNp org/include/net/sch_generic.h new/include/net/sch_generic.h
> --- org/include/net/sch_generic.h   2009-03-24 08:54:16.000000000 +0530
> +++ new/include/net/sch_generic.h   2009-07-28 19:37:10.000000000 +0530
> @@ -45,6 +45,7 @@ struct Qdisc
>  #define TCQ_F_BUILTIN      1
>  #define TCQ_F_THROTTLED      2
>  #define TCQ_F_INGRESS      4
> +#define TCQ_F_CAN_BYPASS   8
>  #define TCQ_F_WARN_NONWC   (1 << 16)
>     int         padded;
>     struct Qdisc_ops   *ops;
> @@ -182,6 +183,11 @@ struct qdisc_skb_cb {
>     char         data[];
>  };
>
> +static inline int qdisc_qlen(struct Qdisc *q)
> +{
> +   return q->q.qlen;
> +}
> +
>  static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
>  {
>     return (struct qdisc_skb_cb *)skb->cb;
> @@ -306,6 +312,9 @@ extern struct Qdisc *qdisc_create_dflt(s
>                     struct Qdisc_ops *ops, u32 parentid);
>  extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
>                 struct qdisc_size_table *stab);
> +extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> +            struct net_device *dev, struct netdev_queue *txq,
> +            spinlock_t *root_lock);
>  extern void tcf_destroy(struct tcf_proto *tp);
>  extern void tcf_destroy_chain(struct tcf_proto **fl);
>
> diff -ruNp org2/net/core/dev.c new2/net/core/dev.c
> --- org2/net/core/dev.c   2009-07-27 09:08:24.000000000 +0530
> +++ new2/net/core/dev.c   2009-07-28 19:37:10.000000000 +0530
> @@ -1786,6 +1786,38 @@ static struct netdev_queue *dev_pick_tx(
>     return netdev_get_tx_queue(dev, queue_index);
>  }
>
> +static inline int __dev_hw_xmit(struct sk_buff *skb, struct Qdisc *q,
> +            struct net_device *dev,
> +            struct netdev_queue *txq)
> +{
> +   spinlock_t *root_lock = qdisc_lock(q);
> +   int rc;
> +
> +   spin_lock(root_lock);
> +   if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> +      kfree_skb(skb);
> +      rc = NET_XMIT_DROP;
> +   } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
> +         !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
> +      /*
> +       * This is the default work-conserving queue; there are no
> +       * old skbs waiting to be sent out; and the qdisc is not
> +       * running - xmit the skb directly.
> +       */
> +      if (sch_direct_xmit(skb, q, dev, txq, root_lock))
> +         __qdisc_run(q);
> +      else
> +         clear_bit(__QDISC_STATE_RUNNING, &q->state);
> +      rc = 0;
> +   } else {
> +      rc = qdisc_enqueue_root(skb, q);
> +      qdisc_run(q);
> +   }
> +   spin_unlock(root_lock);
> +
> +   return rc;
> +}
> +
>  /**
>   *   dev_queue_xmit - transmit a buffer
>   *   @skb: buffer to transmit
> @@ -1859,19 +1891,7 @@ gso:
>     skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
>  #endif
>     if (q->enqueue) {
> -      spinlock_t *root_lock = qdisc_lock(q);
> -
> -      spin_lock(root_lock);
> -
> -      if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> -         kfree_skb(skb);
> -         rc = NET_XMIT_DROP;
> -      } else {
> -         rc = qdisc_enqueue_root(skb, q);
> -         qdisc_run(q);
> -      }
> -      spin_unlock(root_lock);
> -
> +      rc = __dev_hw_xmit(skb, q, dev, txq);
>        goto out;
>     }
>
> diff -ruNp org2/net/sched/sch_generic.c new2/net/sched/sch_generic.c
> --- org2/net/sched/sch_generic.c   2009-05-25 07:48:07.000000000 +0530
> +++ new2/net/sched/sch_generic.c   2009-07-28 19:40:39.000000000 +0530
> @@ -37,15 +37,11 @@
>   * - updates to tree and tree walking are only done under the rtnl
mutex.
>   */
>
> -static inline int qdisc_qlen(struct Qdisc *q)
> -{
> -   return q->q.qlen;
> -}
> -
>  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>  {
>     q->gso_skb = skb;
>     q->qstats.requeues++;
> +   q->q.qlen++;   /* it's still part of the queue */
>     __netif_schedule(q);
>
>     return 0;
> @@ -61,9 +57,11 @@ static inline struct sk_buff *dequeue_sk
>
>        /* check the reason of requeuing without tx lock first */
>        txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> -      if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
> +      if (!netif_tx_queue_stopped(txq) &&
> +          !netif_tx_queue_frozen(txq)) {
>           q->gso_skb = NULL;
> -      else
> +         q->q.qlen--;
> +      } else
>           skb = NULL;
>     } else {
>        skb = q->dequeue(q);
> @@ -102,45 +100,24 @@ static inline int handle_dev_cpu_collisi
>     return ret;
>  }
>
> -/*
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
> +/*
> + * Transmit one skb, and handle the return status as required. Holding
the
> + * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute
this
> + * function.
>   *
>   * Returns to the caller:
>   *            0  - queue is empty or throttled.
>   *            >0 - queue is not empty.
> - *
>   */
> -static inline int qdisc_restart(struct Qdisc *q)
> +int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> +          struct net_device *dev, struct netdev_queue *txq,
> +          spinlock_t *root_lock)
>  {
> -   struct netdev_queue *txq;
>     int ret = NETDEV_TX_BUSY;
> -   struct net_device *dev;
> -   spinlock_t *root_lock;
> -   struct sk_buff *skb;
> -
> -   /* Dequeue packet */
> -   if (unlikely((skb = dequeue_skb(q)) == NULL))
> -      return 0;
> -
> -   root_lock = qdisc_lock(q);
>
>     /* And release qdisc */
>     spin_unlock(root_lock);
>
> -   dev = qdisc_dev(q);
> -   txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> -
>     HARD_TX_LOCK(dev, txq, smp_processor_id());
>     if (!netif_tx_queue_stopped(txq) &&
>         !netif_tx_queue_frozen(txq))
> @@ -177,6 +154,43 @@ static inline int qdisc_restart(struct Q
>     return ret;
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
> + *            0  - queue is empty or throttled.
> + *            >0 - queue is not empty.
> + *
> + */
> +static inline int qdisc_restart(struct Qdisc *q)
> +{
> +   struct netdev_queue *txq;
> +   struct net_device *dev;
> +   spinlock_t *root_lock;
> +   struct sk_buff *skb;
> +
> +   /* Dequeue packet */
> +   if (unlikely((skb = dequeue_skb(q)) == NULL))
> +      return 0;
> +
> +   root_lock = qdisc_lock(q);
> +   dev = qdisc_dev(q);
> +   txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> +
> +   return sch_xmit_direct(skb, q, dev, txq, root_lock);
> +}
> +
>  void __qdisc_run(struct Qdisc *q)
>  {
>     unsigned long start_time = jiffies;
> @@ -547,8 +561,11 @@ void qdisc_reset(struct Qdisc *qdisc)
>     if (ops->reset)
>        ops->reset(qdisc);
>
> -   kfree_skb(qdisc->gso_skb);
> -   qdisc->gso_skb = NULL;
> +   if (qdisc->gso_skb) {
> +      kfree_skb(qdisc->gso_skb);
> +      qdisc->gso_skb = NULL;
> +      qdisc->q.qlen--;
> +   }
>  }
>  EXPORT_SYMBOL(qdisc_reset);
>
> @@ -605,6 +622,9 @@ static void attach_one_default_qdisc(str
>           printk(KERN_INFO "%s: activation failed\n", dev->name);
>           return;
>        }
> +
> +      /* Can by-pass the queue discipline for default qdisc */
> +      qdisc->flags = TCQ_F_CAN_BYPASS;
>     } else {
>        qdisc =  &noqueue_qdisc;
>     }
--0__=EABBFC94DFA2EE478f9e8a93df938690918cEABBFC94DFA2EE47
Content-type: application/octet-stream;
	name="patch.dont_queue"
Content-Disposition: attachment; filename="patch.dont_queue"
Content-transfer-encoding: base64

RnJvbTogS3Jpc2huYSBLdW1hciA8a3JrdW1hcjJAaW4uaWJtLmNvbT4KCmRldl9xdWV1ZV94bWl0
IGVucXVldWUncyBhIHNrYiBhbmQgY2FsbHMgcWRpc2NfcnVuIHdoaWNoCmRlcXVldWUncyB0aGUg
c2tiIGFuZCB4bWl0cyBpdC4gSW4gbW9zdCBjYXNlcyAoYWZ0ZXIKaW5zdHJ1bWVudGluZyB0aGUg
Y29kZSksIHRoZSBza2IgdGhhdCBpcyBlbnF1ZXVlJ2QgaXMgdGhlCnNhbWUgb25lIHRoYXQgaXMg
ZGVxdWV1ZSdkICh1bmxlc3MgdGhlIHF1ZXVlIGdldHMgc3RvcHBlZApvciBtdWx0aXBsZSBjcHUn
cyB3cml0ZSB0byB0aGUgc2FtZSBxdWV1ZSBhbmQgZW5kcyBpbiBhCnJhY2Ugd2l0aCBxZGlzY19y
dW4pLiBGb3IgZGVmYXVsdCBxZGlzY3MsIHdlIGNhbiByZW1vdmUKdGhpcyBwYXRoIGFuZCBzaW1w
bHkgeG1pdCB0aGUgc2tiIHNpbmNlIHRoaXMgaXMgYSB3b3JrCmNvbnNlcnZpbmcgcXVldWUuCgpU
aGUgcGF0Y2ggdXNlcyBhIG5ldyBmbGFnIC0gVENRX0ZfQ0FOX0JZUEFTUyB0byBpZGVudGlmeQp0
aGUgZGVmYXVsdCBmYXN0IHF1ZXVlLiBJIHBsYW4gdG8gdXNlIHRoaXMgZmxhZyBmb3IgdGhlCnBy
ZXZpb3VzIHBhdGNoIGFsc28gKHJlbmFtZSBpZiByZXF1aXJlZCkuICBUaGUgY29udHJvdmVyc2lh
bApwYXJ0IG9mIHRoZSBwYXRjaCBpcyBpbmNyZW1lbnRpbmcgcWxlbiB3aGVuIGEgc2tiIGlzCnJl
cXVldWVkLCB0aGlzIGlzIHRvIGF2b2lkIGNoZWNrcyBsaWtlIHRoZSBzZWNvbmQgbGluZSBiZWxv
dzoKCisgICAgfSBlbHNlIGlmICgocS0+ZmxhZ3MgJiBUQ1FfRl9DQU5fQllQQVNTKSAmJiAhcWRp
c2NfcWxlbihxKSAmJgo+PiBUSElTIExJTkU6ICAgIXEtPmdzb19za2IgJiYKKyAgICAgICAgICAg
ICAgICF0ZXN0X2FuZF9zZXRfYml0KF9fUURJU0NfU1RBVEVfUlVOTklORywgJnEtPnN0YXRlKSkg
ewoKUmVzdWx0cyBvZiBhIDQgaG91ciB0ZXN0aW5nIGZvciBtdWx0aXBsZSBuZXRwZXJmIHNlc3Np
b25zCigxLCAyLCA0LCA4LCAxMiBzZXNzaW9ucyBvbiBhIDQgY3B1IHN5c3RlbS1YIGFuZCAxLCAy
LCA0LAo4LCAxNiwgMzIgc2Vzc2lvbnMgb24gYSAxNiBjcHUgUDYpLiBBZ2dyZWdhdGUgTWIvcyBh
Y3Jvc3MKdGhlIGl0ZXJhdGlvbnM6CgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogICAgIHwgICAgICAgICBTeXN0ZW0tWCAg
ICAgICAgICB8ICAgICAgICAgICAgICAgUDYKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KU2l6ZSB8ICBPUkcgQlcgICAgICAg
ICAgTkVXIEJXICAgfCAgICAgIE9SRyBCVyAgICAgICAgICBORVcgQlcKLS0tLS18LS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tfC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMTZLICB8
ICAxNTQyNjQgICAgICAgICAgMTU2MjM0ICAgfCAgICAgIDE1NTM1MCAgICAgICAgICAxNTc1NjkK
NjRLICB8ICAxNTQzNjQgICAgICAgICAgMTU0ODI1ICAgfCAgICAgIDE1NTc5MCAgICAgICAgICAx
NTg4NDUKMTI4SyB8ICAxNTQ2NDQgICAgICAgICAgMTU0ODAzICAgfCAgICAgIDE1MzQxOCAgICAg
ICAgICAxNTU1NzIKMjU2SyB8ICAxNTM4ODIgICAgICAgICAgMTUyMDA3ICAgfCAgICAgIDE1NDc4
NCAgICAgICAgICAxNTQ1OTYKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KCk5ldHBlcmYgcmVwb3J0ZWQgU2VydmljZSBkZW1h
bmQgcmVkdWNlZCBieSAxNSUgb24gdGhlIFA2IGJ1dApubyBub3RpY2VhYmxlIGRpZmZlcmVuY2Ug
b24gdGhlIHN5c3RlbS1YIGJveC4KClBsZWFzZSByZXZpZXcuCgpUaGFua3MsCgotIEtLCgpTaWdu
ZWQtb2ZmLWJ5OiBLcmlzaG5hIEt1bWFyIDxrcmt1bWFyMkBpbi5pYm0uY29tPgotLS0KCiBpbmNs
dWRlL25ldC9zY2hfZ2VuZXJpYy5oIHwgICAgOSArKysKIG5ldC9jb3JlL2Rldi5jICAgICAgICAg
ICAgfCAgIDQ2ICsrKysrKysrKysrKy0tLS0tCiBuZXQvc2NoZWQvc2NoX2dlbmVyaWMuYyAgIHwg
ICA5NCArKysrKysrKysrKysrKysrKysrKystLS0tLS0tLS0tLS0tLS0KIDMgZmlsZXMgY2hhbmdl
ZCwgOTkgaW5zZXJ0aW9ucygrKSwgNTAgZGVsZXRpb25zKC0pCgpkaWZmIC1ydU5wIG9yZy9pbmNs
dWRlL25ldC9zY2hfZ2VuZXJpYy5oIG5ldy9pbmNsdWRlL25ldC9zY2hfZ2VuZXJpYy5oCi0tLSBv
cmcvaW5jbHVkZS9uZXQvc2NoX2dlbmVyaWMuaAkyMDA5LTAzLTI0IDA4OjU0OjE2LjAwMDAwMDAw
MCArMDUzMAorKysgbmV3L2luY2x1ZGUvbmV0L3NjaF9nZW5lcmljLmgJMjAwOS0wNy0yOCAxOToz
NzoxMC4wMDAwMDAwMDAgKzA1MzAKQEAgLTQ1LDYgKzQ1LDcgQEAgc3RydWN0IFFkaXNjCiAjZGVm
aW5lIFRDUV9GX0JVSUxUSU4JCTEKICNkZWZpbmUgVENRX0ZfVEhST1RUTEVECQkyCiAjZGVmaW5l
IFRDUV9GX0lOR1JFU1MJCTQKKyNkZWZpbmUgVENRX0ZfQ0FOX0JZUEFTUwk4CiAjZGVmaW5lIFRD
UV9GX1dBUk5fTk9OV0MJKDEgPDwgMTYpCiAJaW50CQkJcGFkZGVkOwogCXN0cnVjdCBRZGlzY19v
cHMJKm9wczsKQEAgLTE4Miw2ICsxODMsMTEgQEAgc3RydWN0IHFkaXNjX3NrYl9jYiB7CiAJY2hh
cgkJCWRhdGFbXTsKIH07CiAKK3N0YXRpYyBpbmxpbmUgaW50IHFkaXNjX3FsZW4oc3RydWN0IFFk
aXNjICpxKQoreworCXJldHVybiBxLT5xLnFsZW47Cit9CisKIHN0YXRpYyBpbmxpbmUgc3RydWN0
IHFkaXNjX3NrYl9jYiAqcWRpc2Nfc2tiX2NiKHN0cnVjdCBza19idWZmICpza2IpCiB7CiAJcmV0
dXJuIChzdHJ1Y3QgcWRpc2Nfc2tiX2NiICopc2tiLT5jYjsKQEAgLTMwNiw2ICszMTIsOSBAQCBl
eHRlcm4gc3RydWN0IFFkaXNjICpxZGlzY19jcmVhdGVfZGZsdChzCiAJCQkJICAgICAgIHN0cnVj
dCBRZGlzY19vcHMgKm9wcywgdTMyIHBhcmVudGlkKTsKIGV4dGVybiB2b2lkIHFkaXNjX2NhbGN1
bGF0ZV9wa3RfbGVuKHN0cnVjdCBza19idWZmICpza2IsCiAJCQkJICAgc3RydWN0IHFkaXNjX3Np
emVfdGFibGUgKnN0YWIpOworZXh0ZXJuIGludCBzY2hfZGlyZWN0X3htaXQoc3RydWN0IHNrX2J1
ZmYgKnNrYiwgc3RydWN0IFFkaXNjICpxLAorCQkJICAgc3RydWN0IG5ldF9kZXZpY2UgKmRldiwg
c3RydWN0IG5ldGRldl9xdWV1ZSAqdHhxLAorCQkJICAgc3BpbmxvY2tfdCAqcm9vdF9sb2NrKTsK
IGV4dGVybiB2b2lkIHRjZl9kZXN0cm95KHN0cnVjdCB0Y2ZfcHJvdG8gKnRwKTsKIGV4dGVybiB2
b2lkIHRjZl9kZXN0cm95X2NoYWluKHN0cnVjdCB0Y2ZfcHJvdG8gKipmbCk7CiAKZGlmZiAtcnVO
cCBvcmcyL25ldC9jb3JlL2Rldi5jIG5ldzIvbmV0L2NvcmUvZGV2LmMKLS0tIG9yZzIvbmV0L2Nv
cmUvZGV2LmMJMjAwOS0wNy0yNyAwOTowODoyNC4wMDAwMDAwMDAgKzA1MzAKKysrIG5ldzIvbmV0
L2NvcmUvZGV2LmMJMjAwOS0wNy0yOCAxOTozNzoxMC4wMDAwMDAwMDAgKzA1MzAKQEAgLTE3ODYs
NiArMTc4NiwzOCBAQCBzdGF0aWMgc3RydWN0IG5ldGRldl9xdWV1ZSAqZGV2X3BpY2tfdHgoCiAJ
cmV0dXJuIG5ldGRldl9nZXRfdHhfcXVldWUoZGV2LCBxdWV1ZV9pbmRleCk7CiB9CiAKK3N0YXRp
YyBpbmxpbmUgaW50IF9fZGV2X2h3X3htaXQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IFFk
aXNjICpxLAorCQkJCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYsCisJCQkJc3RydWN0IG5ldGRldl9x
dWV1ZSAqdHhxKQoreworCXNwaW5sb2NrX3QgKnJvb3RfbG9jayA9IHFkaXNjX2xvY2socSk7CisJ
aW50IHJjOworCisJc3Bpbl9sb2NrKHJvb3RfbG9jayk7CisJaWYgKHVubGlrZWx5KHRlc3RfYml0
KF9fUURJU0NfU1RBVEVfREVBQ1RJVkFURUQsICZxLT5zdGF0ZSkpKSB7CisJCWtmcmVlX3NrYihz
a2IpOworCQlyYyA9IE5FVF9YTUlUX0RST1A7CisJfSBlbHNlIGlmICgocS0+ZmxhZ3MgJiBUQ1Ff
Rl9DQU5fQllQQVNTKSAmJiAhcWRpc2NfcWxlbihxKSAmJgorCQkgICAhdGVzdF9hbmRfc2V0X2Jp
dChfX1FESVNDX1NUQVRFX1JVTk5JTkcsICZxLT5zdGF0ZSkpIHsKKwkJLyoKKwkJICogVGhpcyBp
cyB0aGUgZGVmYXVsdCB3b3JrLWNvbnNlcnZpbmcgcXVldWU7IHRoZXJlIGFyZSBubworCQkgKiBv
bGQgc2ticyB3YWl0aW5nIHRvIGJlIHNlbnQgb3V0OyBhbmQgdGhlIHFkaXNjIGlzIG5vdAorCQkg
KiBydW5uaW5nIC0geG1pdCB0aGUgc2tiIGRpcmVjdGx5LgorCQkgKi8KKwkJaWYgKHNjaF9kaXJl
Y3RfeG1pdChza2IsIHEsIGRldiwgdHhxLCByb290X2xvY2spKQorCQkJX19xZGlzY19ydW4ocSk7
CisJCWVsc2UKKwkJCWNsZWFyX2JpdChfX1FESVNDX1NUQVRFX1JVTk5JTkcsICZxLT5zdGF0ZSk7
CisJCXJjID0gMDsKKwl9IGVsc2UgeworCQlyYyA9IHFkaXNjX2VucXVldWVfcm9vdChza2IsIHEp
OworCQlxZGlzY19ydW4ocSk7CisJfQorCXNwaW5fdW5sb2NrKHJvb3RfbG9jayk7CisKKwlyZXR1
cm4gcmM7Cit9CisKIC8qKgogICoJZGV2X3F1ZXVlX3htaXQgLSB0cmFuc21pdCBhIGJ1ZmZlcgog
ICoJQHNrYjogYnVmZmVyIHRvIHRyYW5zbWl0CkBAIC0xODU5LDE5ICsxODkxLDcgQEAgZ3NvOgog
CXNrYi0+dGNfdmVyZCA9IFNFVF9UQ19BVChza2ItPnRjX3ZlcmQsQVRfRUdSRVNTKTsKICNlbmRp
ZgogCWlmIChxLT5lbnF1ZXVlKSB7Ci0JCXNwaW5sb2NrX3QgKnJvb3RfbG9jayA9IHFkaXNjX2xv
Y2socSk7Ci0KLQkJc3Bpbl9sb2NrKHJvb3RfbG9jayk7Ci0KLQkJaWYgKHVubGlrZWx5KHRlc3Rf
Yml0KF9fUURJU0NfU1RBVEVfREVBQ1RJVkFURUQsICZxLT5zdGF0ZSkpKSB7Ci0JCQlrZnJlZV9z
a2Ioc2tiKTsKLQkJCXJjID0gTkVUX1hNSVRfRFJPUDsKLQkJfSBlbHNlIHsKLQkJCXJjID0gcWRp
c2NfZW5xdWV1ZV9yb290KHNrYiwgcSk7Ci0JCQlxZGlzY19ydW4ocSk7Ci0JCX0KLQkJc3Bpbl91
bmxvY2socm9vdF9sb2NrKTsKLQorCQlyYyA9IF9fZGV2X2h3X3htaXQoc2tiLCBxLCBkZXYsIHR4
cSk7CiAJCWdvdG8gb3V0OwogCX0KIApkaWZmIC1ydU5wIG9yZzIvbmV0L3NjaGVkL3NjaF9nZW5l
cmljLmMgbmV3Mi9uZXQvc2NoZWQvc2NoX2dlbmVyaWMuYwotLS0gb3JnMi9uZXQvc2NoZWQvc2No
X2dlbmVyaWMuYwkyMDA5LTA1LTI1IDA3OjQ4OjA3LjAwMDAwMDAwMCArMDUzMAorKysgbmV3Mi9u
ZXQvc2NoZWQvc2NoX2dlbmVyaWMuYwkyMDA5LTA3LTI4IDE5OjQwOjM5LjAwMDAwMDAwMCArMDUz
MApAQCAtMzcsMTUgKzM3LDExIEBACiAgKiAtIHVwZGF0ZXMgdG8gdHJlZSBhbmQgdHJlZSB3YWxr
aW5nIGFyZSBvbmx5IGRvbmUgdW5kZXIgdGhlIHJ0bmwgbXV0ZXguCiAgKi8KIAotc3RhdGljIGlu
bGluZSBpbnQgcWRpc2NfcWxlbihzdHJ1Y3QgUWRpc2MgKnEpCi17Ci0JcmV0dXJuIHEtPnEucWxl
bjsKLX0KLQogc3RhdGljIGlubGluZSBpbnQgZGV2X3JlcXVldWVfc2tiKHN0cnVjdCBza19idWZm
ICpza2IsIHN0cnVjdCBRZGlzYyAqcSkKIHsKIAlxLT5nc29fc2tiID0gc2tiOwogCXEtPnFzdGF0
cy5yZXF1ZXVlcysrOworCXEtPnEucWxlbisrOwkvKiBpdCdzIHN0aWxsIHBhcnQgb2YgdGhlIHF1
ZXVlICovCiAJX19uZXRpZl9zY2hlZHVsZShxKTsKIAogCXJldHVybiAwOwpAQCAtNjEsOSArNTcs
MTEgQEAgc3RhdGljIGlubGluZSBzdHJ1Y3Qgc2tfYnVmZiAqZGVxdWV1ZV9zawogCiAJCS8qIGNo
ZWNrIHRoZSByZWFzb24gb2YgcmVxdWV1aW5nIHdpdGhvdXQgdHggbG9jayBmaXJzdCAqLwogCQl0
eHEgPSBuZXRkZXZfZ2V0X3R4X3F1ZXVlKGRldiwgc2tiX2dldF9xdWV1ZV9tYXBwaW5nKHNrYikp
OwotCQlpZiAoIW5ldGlmX3R4X3F1ZXVlX3N0b3BwZWQodHhxKSAmJiAhbmV0aWZfdHhfcXVldWVf
ZnJvemVuKHR4cSkpCisJCWlmICghbmV0aWZfdHhfcXVldWVfc3RvcHBlZCh0eHEpICYmCisJCSAg
ICAhbmV0aWZfdHhfcXVldWVfZnJvemVuKHR4cSkpIHsKIAkJCXEtPmdzb19za2IgPSBOVUxMOwot
CQllbHNlCisJCQlxLT5xLnFsZW4tLTsKKwkJfSBlbHNlCiAJCQlza2IgPSBOVUxMOwogCX0gZWxz
ZSB7CiAJCXNrYiA9IHEtPmRlcXVldWUocSk7CkBAIC0xMDIsNDUgKzEwMCwyNCBAQCBzdGF0aWMg
aW5saW5lIGludCBoYW5kbGVfZGV2X2NwdV9jb2xsaXNpCiAJcmV0dXJuIHJldDsKIH0KIAotLyoK
LSAqIE5PVEU6IENhbGxlZCB1bmRlciBxZGlzY19sb2NrKHEpIHdpdGggbG9jYWxseSBkaXNhYmxl
ZCBCSC4KLSAqCi0gKiBfX1FESVNDX1NUQVRFX1JVTk5JTkcgZ3VhcmFudGVlcyBvbmx5IG9uZSBD
UFUgY2FuIHByb2Nlc3MKLSAqIHRoaXMgcWRpc2MgYXQgYSB0aW1lLiBxZGlzY19sb2NrKHEpIHNl
cmlhbGl6ZXMgcXVldWUgYWNjZXNzZXMgZm9yCi0gKiB0aGlzIHF1ZXVlLgotICoKLSAqICBuZXRp
Zl90eF9sb2NrIHNlcmlhbGl6ZXMgYWNjZXNzZXMgdG8gZGV2aWNlIGRyaXZlci4KLSAqCi0gKiAg
cWRpc2NfbG9jayhxKSBhbmQgbmV0aWZfdHhfbG9jayBhcmUgbXV0dWFsbHkgZXhjbHVzaXZlLAot
ICogIGlmIG9uZSBpcyBncmFiYmVkLCBhbm90aGVyIG11c3QgYmUgZnJlZS4KLSAqCi0gKiBOb3Rl
LCB0aGF0IHRoaXMgcHJvY2VkdXJlIGNhbiBiZSBjYWxsZWQgYnkgYSB3YXRjaGRvZyB0aW1lcgor
LyogCisgKiBUcmFuc21pdCBvbmUgc2tiLCBhbmQgaGFuZGxlIHRoZSByZXR1cm4gc3RhdHVzIGFz
IHJlcXVpcmVkLiBIb2xkaW5nIHRoZQorICogX19RRElTQ19TVEFURV9SVU5OSU5HIGJpdCBndWFy
YW50ZWVzIHRoYXQgb25seSBvbmUgQ1BVIGNhbiBleGVjdXRlIHRoaXMKKyAqIGZ1bmN0aW9uLgog
ICoKICAqIFJldHVybnMgdG8gdGhlIGNhbGxlcjoKICAqCQkJCTAgIC0gcXVldWUgaXMgZW1wdHkg
b3IgdGhyb3R0bGVkLgogICoJCQkJPjAgLSBxdWV1ZSBpcyBub3QgZW1wdHkuCi0gKgogICovCi1z
dGF0aWMgaW5saW5lIGludCBxZGlzY19yZXN0YXJ0KHN0cnVjdCBRZGlzYyAqcSkKK2ludCBzY2hf
ZGlyZWN0X3htaXQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IFFkaXNjICpxLAorCQkgICAg
c3RydWN0IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IG5ldGRldl9xdWV1ZSAqdHhxLAorCQkgICAg
c3BpbmxvY2tfdCAqcm9vdF9sb2NrKQogewotCXN0cnVjdCBuZXRkZXZfcXVldWUgKnR4cTsKIAlp
bnQgcmV0ID0gTkVUREVWX1RYX0JVU1k7Ci0Jc3RydWN0IG5ldF9kZXZpY2UgKmRldjsKLQlzcGlu
bG9ja190ICpyb290X2xvY2s7Ci0Jc3RydWN0IHNrX2J1ZmYgKnNrYjsKLQotCS8qIERlcXVldWUg
cGFja2V0ICovCi0JaWYgKHVubGlrZWx5KChza2IgPSBkZXF1ZXVlX3NrYihxKSkgPT0gTlVMTCkp
Ci0JCXJldHVybiAwOwotCi0Jcm9vdF9sb2NrID0gcWRpc2NfbG9jayhxKTsKIAogCS8qIEFuZCBy
ZWxlYXNlIHFkaXNjICovCiAJc3Bpbl91bmxvY2socm9vdF9sb2NrKTsKIAotCWRldiA9IHFkaXNj
X2RldihxKTsKLQl0eHEgPSBuZXRkZXZfZ2V0X3R4X3F1ZXVlKGRldiwgc2tiX2dldF9xdWV1ZV9t
YXBwaW5nKHNrYikpOwotCiAJSEFSRF9UWF9MT0NLKGRldiwgdHhxLCBzbXBfcHJvY2Vzc29yX2lk
KCkpOwogCWlmICghbmV0aWZfdHhfcXVldWVfc3RvcHBlZCh0eHEpICYmCiAJICAgICFuZXRpZl90
eF9xdWV1ZV9mcm96ZW4odHhxKSkKQEAgLTE3Nyw2ICsxNTQsNDMgQEAgc3RhdGljIGlubGluZSBp
bnQgcWRpc2NfcmVzdGFydChzdHJ1Y3QgUQogCXJldHVybiByZXQ7CiB9CiAKKy8qCisgKiBOT1RF
OiBDYWxsZWQgdW5kZXIgcWRpc2NfbG9jayhxKSB3aXRoIGxvY2FsbHkgZGlzYWJsZWQgQkguCisg
KgorICogX19RRElTQ19TVEFURV9SVU5OSU5HIGd1YXJhbnRlZXMgb25seSBvbmUgQ1BVIGNhbiBw
cm9jZXNzCisgKiB0aGlzIHFkaXNjIGF0IGEgdGltZS4gcWRpc2NfbG9jayhxKSBzZXJpYWxpemVz
IHF1ZXVlIGFjY2Vzc2VzIGZvcgorICogdGhpcyBxdWV1ZS4KKyAqCisgKiAgbmV0aWZfdHhfbG9j
ayBzZXJpYWxpemVzIGFjY2Vzc2VzIHRvIGRldmljZSBkcml2ZXIuCisgKgorICogIHFkaXNjX2xv
Y2socSkgYW5kIG5ldGlmX3R4X2xvY2sgYXJlIG11dHVhbGx5IGV4Y2x1c2l2ZSwKKyAqICBpZiBv
bmUgaXMgZ3JhYmJlZCwgYW5vdGhlciBtdXN0IGJlIGZyZWUuCisgKgorICogTm90ZSwgdGhhdCB0
aGlzIHByb2NlZHVyZSBjYW4gYmUgY2FsbGVkIGJ5IGEgd2F0Y2hkb2cgdGltZXIKKyAqCisgKiBS
ZXR1cm5zIHRvIHRoZSBjYWxsZXI6CisgKgkJCQkwICAtIHF1ZXVlIGlzIGVtcHR5IG9yIHRocm90
dGxlZC4KKyAqCQkJCT4wIC0gcXVldWUgaXMgbm90IGVtcHR5LgorICoKKyAqLworc3RhdGljIGlu
bGluZSBpbnQgcWRpc2NfcmVzdGFydChzdHJ1Y3QgUWRpc2MgKnEpCit7CisJc3RydWN0IG5ldGRl
dl9xdWV1ZSAqdHhxOworCXN0cnVjdCBuZXRfZGV2aWNlICpkZXY7CisJc3BpbmxvY2tfdCAqcm9v
dF9sb2NrOworCXN0cnVjdCBza19idWZmICpza2I7CisKKwkvKiBEZXF1ZXVlIHBhY2tldCAqLwor
CWlmICh1bmxpa2VseSgoc2tiID0gZGVxdWV1ZV9za2IocSkpID09IE5VTEwpKQorCQlyZXR1cm4g
MDsKKworCXJvb3RfbG9jayA9IHFkaXNjX2xvY2socSk7CisJZGV2ID0gcWRpc2NfZGV2KHEpOwor
CXR4cSA9IG5ldGRldl9nZXRfdHhfcXVldWUoZGV2LCBza2JfZ2V0X3F1ZXVlX21hcHBpbmcoc2ti
KSk7CisKKwlyZXR1cm4gc2NoX3htaXRfZGlyZWN0KHNrYiwgcSwgZGV2LCB0eHEsIHJvb3RfbG9j
ayk7Cit9CisKIHZvaWQgX19xZGlzY19ydW4oc3RydWN0IFFkaXNjICpxKQogewogCXVuc2lnbmVk
IGxvbmcgc3RhcnRfdGltZSA9IGppZmZpZXM7CkBAIC01NDcsOCArNTYxLDExIEBAIHZvaWQgcWRp
c2NfcmVzZXQoc3RydWN0IFFkaXNjICpxZGlzYykKIAlpZiAob3BzLT5yZXNldCkKIAkJb3BzLT5y
ZXNldChxZGlzYyk7CiAKLQlrZnJlZV9za2IocWRpc2MtPmdzb19za2IpOwotCXFkaXNjLT5nc29f
c2tiID0gTlVMTDsKKwlpZiAocWRpc2MtPmdzb19za2IpIHsKKwkJa2ZyZWVfc2tiKHFkaXNjLT5n
c29fc2tiKTsKKwkJcWRpc2MtPmdzb19za2IgPSBOVUxMOworCQlxZGlzYy0+cS5xbGVuLS07CisJ
fQogfQogRVhQT1JUX1NZTUJPTChxZGlzY19yZXNldCk7CiAKQEAgLTYwNSw2ICs2MjIsOSBAQCBz
dGF0aWMgdm9pZCBhdHRhY2hfb25lX2RlZmF1bHRfcWRpc2Moc3RyCiAJCQlwcmludGsoS0VSTl9J
TkZPICIlczogYWN0aXZhdGlvbiBmYWlsZWRcbiIsIGRldi0+bmFtZSk7CiAJCQlyZXR1cm47CiAJ
CX0KKworCQkvKiBDYW4gYnktcGFzcyB0aGUgcXVldWUgZGlzY2lwbGluZSBmb3IgZGVmYXVsdCBx
ZGlzYyAqLworCQlxZGlzYy0+ZmxhZ3MgPSBUQ1FfRl9DQU5fQllQQVNTOwogCX0gZWxzZSB7CiAJ
CXFkaXNjID0gICZub3F1ZXVlX3FkaXNjOwogCX0K

--0__=EABBFC94DFA2EE478f9e8a93df938690918cEABBFC94DFA2EE47--

