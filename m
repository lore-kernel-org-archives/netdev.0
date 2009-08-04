From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Tue, 4 Aug 2009 12:25:07 +0530
Message-ID: <OF104CB719.2A67F34E-ON65257608.001D0048-65257608.0026016D@in.ibm.com>
References: <OF1689973C.61968A07-ON65257607.003168D7-65257607.0033083B@in.ibm.com> <20090803193847.GA3471@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=EABBFC9BDF8E86D88f9e8a93df938690918cEABBFC9BDF8E86D8"
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([59.145.155.8]:52215 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462AbZHDGzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 02:55:36 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id n746p93F008069
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 12:21:09 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n746tUu81781792
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 12:25:30 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n746tTWc031173
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 12:25:30 +0530
In-Reply-To: <20090803193847.GA3471@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0__=EABBFC9BDF8E86D88f9e8a93df938690918cEABBFC9BDF8E86D8
Content-type: text/plain; charset=US-ASCII

Jarek Poplawski <jarkao2@gmail.com> wrote on 08/04/2009 01:08:47 AM:

Hi Jarek,

> Since this quoted part looks very similarly I'm using it here, so
> forget my note if something has changed.

Thanks for your feedback. Yes, the inline patch is the same as the
attached one.

> >> @@ -306,6 +312,9 @@ extern struct Qdisc *qdisc_create_dflt(s
> >>                     struct Qdisc_ops *ops, u32 parentid);
> >>  extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
> >>                 struct qdisc_size_table *stab);
> >> +extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> >> +            struct net_device *dev, struct netdev_queue *txq,
> >> +            spinlock_t *root_lock);
>
> Probably this would look better in pkt_sched.h around __qdisc_run()?

I had it originally in pkt_sched.h, for some reason I had moved it to
sch_generic.h, I will move it back.

> >> +static inline int __dev_hw_xmit(struct sk_buff *skb, struct Qdisc *q,
>
> I guess, we don't touch "hw" in this function yet?

Right - this was due to lack of a good name. Maybe I can call it
__dev_xmit_skb?

> >> -   kfree_skb(qdisc->gso_skb);
> >> -   qdisc->gso_skb = NULL;
> >> +   if (qdisc->gso_skb) {
> >> +      kfree_skb(qdisc->gso_skb);
> >> +      qdisc->gso_skb = NULL;
> >> +      qdisc->q.qlen--;
>
> You don't need this here: qdiscs should zero it in ops->reset().

I will keep it around, as you said in your other mail.

> >> +      /* Can by-pass the queue discipline for default qdisc */
> >> +      qdisc->flags = TCQ_F_CAN_BYPASS;
>
> "|=" looks nicer to me.

Agreed - and required if qdisc_create_dflt (and the functions it calls)
is changed to set the flags.

> >>     } else {
> >>        qdisc =  &noqueue_qdisc;
> >>     }
>
> I wonder if we shouldn't update bstats yet. Btw, try checkpatch.

Rate estimator isn't used for default qdisc, so is anything
required? Also, checkpatch suggested to change the original code:
        "if (unlikely((skb = dequeue_skb(q)) == NULL))"
since it appears as "new code", hope that change is fine.

The patch after incorporating the review comments is both attached
and inlined, since my mailer is still not working (I sent this mail
about an hour back but this one didn't seem to have made it while
one of my latter mails did).

Thanks,

- KK

 (See attached file: patch4)

----------------------------------------------------------------------
 include/net/pkt_sched.h   |    3 +
 include/net/sch_generic.h |    6 ++
 net/core/dev.c            |   46 ++++++++++++-----
 net/sched/sch_generic.c   |   93 ++++++++++++++++++++++--------------
 4 files changed, 99 insertions(+), 49 deletions(-)

diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
--- org/include/net/pkt_sched.h 2009-08-04 11:41:21.000000000 +0530
+++ new/include/net/pkt_sched.h 2009-08-04 11:42:18.000000000 +0530
@@ -87,6 +87,9 @@ extern struct qdisc_rate_table *qdisc_ge
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 extern void qdisc_put_stab(struct qdisc_size_table *tab);
 extern void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
+extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+                          struct net_device *dev, struct netdev_queue
*txq,
+                          spinlock_t *root_lock);

 extern void __qdisc_run(struct Qdisc *q);

diff -ruNp org/include/net/sch_generic.h new/include/net/sch_generic.h
--- org/include/net/sch_generic.h       2009-03-24 08:54:16.000000000 +0530
+++ new/include/net/sch_generic.h       2009-08-04 11:02:39.000000000 +0530
@@ -45,6 +45,7 @@ struct Qdisc
 #define TCQ_F_BUILTIN          1
 #define TCQ_F_THROTTLED                2
 #define TCQ_F_INGRESS          4
+#define TCQ_F_CAN_BYPASS       8
 #define TCQ_F_WARN_NONWC       (1 << 16)
        int                     padded;
        struct Qdisc_ops        *ops;
@@ -182,6 +183,11 @@ struct qdisc_skb_cb {
        char                    data[];
 };

+static inline int qdisc_qlen(struct Qdisc *q)
+{
+       return q->q.qlen;
+}
+
 static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
 {
        return (struct qdisc_skb_cb *)skb->cb;
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c  2009-07-27 09:08:24.000000000 +0530
+++ new/net/core/dev.c  2009-08-04 11:44:57.000000000 +0530
@@ -1786,6 +1786,38 @@ static struct netdev_queue *dev_pick_tx(
        return netdev_get_tx_queue(dev, queue_index);
 }

+static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
+                                struct net_device *dev,
+                                struct netdev_queue *txq)
+{
+       spinlock_t *root_lock = qdisc_lock(q);
+       int rc;
+
+       spin_lock(root_lock);
+       if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
+               kfree_skb(skb);
+               rc = NET_XMIT_DROP;
+       } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
+                  !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
+               /*
+                * This is a work-conserving queue; there are no old skbs
+                * waiting to be sent out; and the qdisc is not running -
+                * xmit the skb directly.
+                */
+               if (sch_direct_xmit(skb, q, dev, txq, root_lock))
+                       __qdisc_run(q);
+               else
+                       clear_bit(__QDISC_STATE_RUNNING, &q->state);
+               rc = NET_XMIT_SUCCESS;
+       } else {
+               rc = qdisc_enqueue_root(skb, q);
+               qdisc_run(q);
+       }
+       spin_unlock(root_lock);
+
+       return rc;
+}
+
 /**
  *     dev_queue_xmit - transmit a buffer
  *     @skb: buffer to transmit
@@ -1859,19 +1891,7 @@ gso:
        skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
        if (q->enqueue) {
-               spinlock_t *root_lock = qdisc_lock(q);
-
-               spin_lock(root_lock);
-
-               if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED,
&q->state))) {
-                       kfree_skb(skb);
-                       rc = NET_XMIT_DROP;
-               } else {
-                       rc = qdisc_enqueue_root(skb, q);
-                       qdisc_run(q);
-               }
-               spin_unlock(root_lock);
-
+               rc = __dev_xmit_skb(skb, q, dev, txq);
                goto out;
        }

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c 2009-05-25 07:48:07.000000000 +0530
+++ new/net/sched/sch_generic.c 2009-08-04 11:00:38.000000000 +0530
@@ -37,15 +37,11 @@
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */

-static inline int qdisc_qlen(struct Qdisc *q)
-{
-       return q->q.qlen;
-}
-
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
        q->gso_skb = skb;
        q->qstats.requeues++;
+       q->q.qlen++;    /* it's still part of the queue */
        __netif_schedule(q);

        return 0;
@@ -61,9 +57,11 @@ static inline struct sk_buff *dequeue_sk

                /* check the reason of requeuing without tx lock first */
                txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-               if (!netif_tx_queue_stopped(txq) &&
!netif_tx_queue_frozen(txq))
+               if (!netif_tx_queue_stopped(txq) &&
+                   !netif_tx_queue_frozen(txq)) {
                        q->gso_skb = NULL;
-               else
+                       q->q.qlen--;
+               } else
                        skb = NULL;
        } else {
                skb = q->dequeue(q);
@@ -103,44 +101,23 @@ static inline int handle_dev_cpu_collisi
 }

 /*
- * NOTE: Called under qdisc_lock(q) with locally disabled BH.
- *
- * __QDISC_STATE_RUNNING guarantees only one CPU can process
- * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
- * this queue.
- *
- *  netif_tx_lock serializes accesses to device driver.
- *
- *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
- *  if one is grabbed, another must be free.
- *
- * Note, that this procedure can be called by a watchdog timer
+ * Transmit one skb, and handle the return status as required. Holding the
+ * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute this
+ * function.
  *
  * Returns to the caller:
  *                             0  - queue is empty or throttled.
  *                             >0 - queue is not empty.
- *
  */
-static inline int qdisc_restart(struct Qdisc *q)
+int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+                   struct net_device *dev, struct netdev_queue *txq,
+                   spinlock_t *root_lock)
 {
-       struct netdev_queue *txq;
        int ret = NETDEV_TX_BUSY;
-       struct net_device *dev;
-       spinlock_t *root_lock;
-       struct sk_buff *skb;
-
-       /* Dequeue packet */
-       if (unlikely((skb = dequeue_skb(q)) == NULL))
-               return 0;
-
-       root_lock = qdisc_lock(q);

        /* And release qdisc */
        spin_unlock(root_lock);

-       dev = qdisc_dev(q);
-       txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-
        HARD_TX_LOCK(dev, txq, smp_processor_id());
        if (!netif_tx_queue_stopped(txq) &&
            !netif_tx_queue_frozen(txq))
@@ -177,6 +154,44 @@ static inline int qdisc_restart(struct Q
        return ret;
 }

+/*
+ * NOTE: Called under qdisc_lock(q) with locally disabled BH.
+ *
+ * __QDISC_STATE_RUNNING guarantees only one CPU can process
+ * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
+ * this queue.
+ *
+ *  netif_tx_lock serializes accesses to device driver.
+ *
+ *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
+ *  if one is grabbed, another must be free.
+ *
+ * Note, that this procedure can be called by a watchdog timer
+ *
+ * Returns to the caller:
+ *                             0  - queue is empty or throttled.
+ *                             >0 - queue is not empty.
+ *
+ */
+static inline int qdisc_restart(struct Qdisc *q)
+{
+       struct netdev_queue *txq;
+       struct net_device *dev;
+       spinlock_t *root_lock;
+       struct sk_buff *skb;
+
+       /* Dequeue packet */
+       skb = dequeue_skb(q);
+       if (unlikely(!skb))
+               return 0;
+
+       root_lock = qdisc_lock(q);
+       dev = qdisc_dev(q);
+       txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+
+       return sch_direct_xmit(skb, q, dev, txq, root_lock);
+}
+
 void __qdisc_run(struct Qdisc *q)
 {
        unsigned long start_time = jiffies;
@@ -547,8 +562,11 @@ void qdisc_reset(struct Qdisc *qdisc)
        if (ops->reset)
                ops->reset(qdisc);

-       kfree_skb(qdisc->gso_skb);
-       qdisc->gso_skb = NULL;
+       if (qdisc->gso_skb) {
+               kfree_skb(qdisc->gso_skb);
+               qdisc->gso_skb = NULL;
+               qdisc->q.qlen--;
+       }
 }
 EXPORT_SYMBOL(qdisc_reset);

@@ -605,6 +623,9 @@ static void attach_one_default_qdisc(str
                        printk(KERN_INFO "%s: activation failed\n",
dev->name);
                        return;
                }
+
+               /* Can by-pass the queue discipline for default qdisc */
+               qdisc->flags |= TCQ_F_CAN_BYPASS;
        } else {
                qdisc =  &noqueue_qdisc;
        }

--0__=EABBFC9BDF8E86D88f9e8a93df938690918cEABBFC9BDF8E86D8
Content-type: application/octet-stream;
	name="patch4"
Content-Disposition: attachment; filename="patch4"
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
ZWQtb2ZmLWJ5OiBLcmlzaG5hIEt1bWFyIDxrcmt1bWFyMkBpbi5pYm0uY29tPgotLS0KIGluY2x1
ZGUvbmV0L3BrdF9zY2hlZC5oICAgfCAgICAzICsKIGluY2x1ZGUvbmV0L3NjaF9nZW5lcmljLmgg
fCAgICA2ICsrCiBuZXQvY29yZS9kZXYuYyAgICAgICAgICAgIHwgICA0NiArKysrKysrKysrKyst
LS0tLQogbmV0L3NjaGVkL3NjaF9nZW5lcmljLmMgICB8ICAgOTMgKysrKysrKysrKysrKysrKysr
KysrKy0tLS0tLS0tLS0tLS0tCiA0IGZpbGVzIGNoYW5nZWQsIDk5IGluc2VydGlvbnMoKyksIDQ5
IGRlbGV0aW9ucygtKQoKZGlmZiAtcnVOcCBvcmcvaW5jbHVkZS9uZXQvcGt0X3NjaGVkLmggbmV3
L2luY2x1ZGUvbmV0L3BrdF9zY2hlZC5oCi0tLSBvcmcvaW5jbHVkZS9uZXQvcGt0X3NjaGVkLmgJ
MjAwOS0wOC0wNCAxMTo0MToyMS4wMDAwMDAwMDAgKzA1MzAKKysrIG5ldy9pbmNsdWRlL25ldC9w
a3Rfc2NoZWQuaAkyMDA5LTA4LTA0IDExOjQyOjE4LjAwMDAwMDAwMCArMDUzMApAQCAtODcsNiAr
ODcsOSBAQCBleHRlcm4gc3RydWN0IHFkaXNjX3JhdGVfdGFibGUgKnFkaXNjX2dlCiBleHRlcm4g
dm9pZCBxZGlzY19wdXRfcnRhYihzdHJ1Y3QgcWRpc2NfcmF0ZV90YWJsZSAqdGFiKTsKIGV4dGVy
biB2b2lkIHFkaXNjX3B1dF9zdGFiKHN0cnVjdCBxZGlzY19zaXplX3RhYmxlICp0YWIpOwogZXh0
ZXJuIHZvaWQgcWRpc2Nfd2Fybl9ub253YyhjaGFyICp0eHQsIHN0cnVjdCBRZGlzYyAqcWRpc2Mp
OworZXh0ZXJuIGludCBzY2hfZGlyZWN0X3htaXQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0
IFFkaXNjICpxLAorCQkJICAgc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IG5ldGRldl9x
dWV1ZSAqdHhxLAorCQkJICAgc3BpbmxvY2tfdCAqcm9vdF9sb2NrKTsKIAogZXh0ZXJuIHZvaWQg
X19xZGlzY19ydW4oc3RydWN0IFFkaXNjICpxKTsKIApkaWZmIC1ydU5wIG9yZy9pbmNsdWRlL25l
dC9zY2hfZ2VuZXJpYy5oIG5ldy9pbmNsdWRlL25ldC9zY2hfZ2VuZXJpYy5oCi0tLSBvcmcvaW5j
bHVkZS9uZXQvc2NoX2dlbmVyaWMuaAkyMDA5LTAzLTI0IDA4OjU0OjE2LjAwMDAwMDAwMCArMDUz
MAorKysgbmV3L2luY2x1ZGUvbmV0L3NjaF9nZW5lcmljLmgJMjAwOS0wOC0wNCAxMTowMjozOS4w
MDAwMDAwMDAgKzA1MzAKQEAgLTQ1LDYgKzQ1LDcgQEAgc3RydWN0IFFkaXNjCiAjZGVmaW5lIFRD
UV9GX0JVSUxUSU4JCTEKICNkZWZpbmUgVENRX0ZfVEhST1RUTEVECQkyCiAjZGVmaW5lIFRDUV9G
X0lOR1JFU1MJCTQKKyNkZWZpbmUgVENRX0ZfQ0FOX0JZUEFTUwk4CiAjZGVmaW5lIFRDUV9GX1dB
Uk5fTk9OV0MJKDEgPDwgMTYpCiAJaW50CQkJcGFkZGVkOwogCXN0cnVjdCBRZGlzY19vcHMJKm9w
czsKQEAgLTE4Miw2ICsxODMsMTEgQEAgc3RydWN0IHFkaXNjX3NrYl9jYiB7CiAJY2hhcgkJCWRh
dGFbXTsKIH07CiAKK3N0YXRpYyBpbmxpbmUgaW50IHFkaXNjX3FsZW4oc3RydWN0IFFkaXNjICpx
KQoreworCXJldHVybiBxLT5xLnFsZW47Cit9CisKIHN0YXRpYyBpbmxpbmUgc3RydWN0IHFkaXNj
X3NrYl9jYiAqcWRpc2Nfc2tiX2NiKHN0cnVjdCBza19idWZmICpza2IpCiB7CiAJcmV0dXJuIChz
dHJ1Y3QgcWRpc2Nfc2tiX2NiICopc2tiLT5jYjsKZGlmZiAtcnVOcCBvcmcvbmV0L2NvcmUvZGV2
LmMgbmV3L25ldC9jb3JlL2Rldi5jCi0tLSBvcmcvbmV0L2NvcmUvZGV2LmMJMjAwOS0wNy0yNyAw
OTowODoyNC4wMDAwMDAwMDAgKzA1MzAKKysrIG5ldy9uZXQvY29yZS9kZXYuYwkyMDA5LTA4LTA0
IDExOjQ0OjU3LjAwMDAwMDAwMCArMDUzMApAQCAtMTc4Niw2ICsxNzg2LDM4IEBAIHN0YXRpYyBz
dHJ1Y3QgbmV0ZGV2X3F1ZXVlICpkZXZfcGlja190eCgKIAlyZXR1cm4gbmV0ZGV2X2dldF90eF9x
dWV1ZShkZXYsIHF1ZXVlX2luZGV4KTsKIH0KIAorc3RhdGljIGlubGluZSBpbnQgX19kZXZfeG1p
dF9za2Ioc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IFFkaXNjICpxLAorCQkJCSBzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2LAorCQkJCSBzdHJ1Y3QgbmV0ZGV2X3F1ZXVlICp0eHEpCit7CisJc3Bp
bmxvY2tfdCAqcm9vdF9sb2NrID0gcWRpc2NfbG9jayhxKTsKKwlpbnQgcmM7CisKKwlzcGluX2xv
Y2socm9vdF9sb2NrKTsKKwlpZiAodW5saWtlbHkodGVzdF9iaXQoX19RRElTQ19TVEFURV9ERUFD
VElWQVRFRCwgJnEtPnN0YXRlKSkpIHsKKwkJa2ZyZWVfc2tiKHNrYik7CisJCXJjID0gTkVUX1hN
SVRfRFJPUDsKKwl9IGVsc2UgaWYgKChxLT5mbGFncyAmIFRDUV9GX0NBTl9CWVBBU1MpICYmICFx
ZGlzY19xbGVuKHEpICYmCisJCSAgICF0ZXN0X2FuZF9zZXRfYml0KF9fUURJU0NfU1RBVEVfUlVO
TklORywgJnEtPnN0YXRlKSkgeworCQkvKgorCQkgKiBUaGlzIGlzIGEgd29yay1jb25zZXJ2aW5n
IHF1ZXVlOyB0aGVyZSBhcmUgbm8gb2xkIHNrYnMKKwkJICogd2FpdGluZyB0byBiZSBzZW50IG91
dDsgYW5kIHRoZSBxZGlzYyBpcyBub3QgcnVubmluZyAtCisJCSAqIHhtaXQgdGhlIHNrYiBkaXJl
Y3RseS4KKwkJICovCisJCWlmIChzY2hfZGlyZWN0X3htaXQoc2tiLCBxLCBkZXYsIHR4cSwgcm9v
dF9sb2NrKSkKKwkJCV9fcWRpc2NfcnVuKHEpOworCQllbHNlCisJCQljbGVhcl9iaXQoX19RRElT
Q19TVEFURV9SVU5OSU5HLCAmcS0+c3RhdGUpOworCQlyYyA9IE5FVF9YTUlUX1NVQ0NFU1M7CisJ
fSBlbHNlIHsKKwkJcmMgPSBxZGlzY19lbnF1ZXVlX3Jvb3Qoc2tiLCBxKTsKKwkJcWRpc2NfcnVu
KHEpOworCX0KKwlzcGluX3VubG9jayhyb290X2xvY2spOworCisJcmV0dXJuIHJjOworfQorCiAv
KioKICAqCWRldl9xdWV1ZV94bWl0IC0gdHJhbnNtaXQgYSBidWZmZXIKICAqCUBza2I6IGJ1ZmZl
ciB0byB0cmFuc21pdApAQCAtMTg1OSwxOSArMTg5MSw3IEBAIGdzbzoKIAlza2ItPnRjX3ZlcmQg
PSBTRVRfVENfQVQoc2tiLT50Y192ZXJkLEFUX0VHUkVTUyk7CiAjZW5kaWYKIAlpZiAocS0+ZW5x
dWV1ZSkgewotCQlzcGlubG9ja190ICpyb290X2xvY2sgPSBxZGlzY19sb2NrKHEpOwotCi0JCXNw
aW5fbG9jayhyb290X2xvY2spOwotCi0JCWlmICh1bmxpa2VseSh0ZXN0X2JpdChfX1FESVNDX1NU
QVRFX0RFQUNUSVZBVEVELCAmcS0+c3RhdGUpKSkgewotCQkJa2ZyZWVfc2tiKHNrYik7Ci0JCQly
YyA9IE5FVF9YTUlUX0RST1A7Ci0JCX0gZWxzZSB7Ci0JCQlyYyA9IHFkaXNjX2VucXVldWVfcm9v
dChza2IsIHEpOwotCQkJcWRpc2NfcnVuKHEpOwotCQl9Ci0JCXNwaW5fdW5sb2NrKHJvb3RfbG9j
ayk7Ci0KKwkJcmMgPSBfX2Rldl94bWl0X3NrYihza2IsIHEsIGRldiwgdHhxKTsKIAkJZ290byBv
dXQ7CiAJfQogCmRpZmYgLXJ1TnAgb3JnL25ldC9zY2hlZC9zY2hfZ2VuZXJpYy5jIG5ldy9uZXQv
c2NoZWQvc2NoX2dlbmVyaWMuYwotLS0gb3JnL25ldC9zY2hlZC9zY2hfZ2VuZXJpYy5jCTIwMDkt
MDUtMjUgMDc6NDg6MDcuMDAwMDAwMDAwICswNTMwCisrKyBuZXcvbmV0L3NjaGVkL3NjaF9nZW5l
cmljLmMJMjAwOS0wOC0wNCAxMTowMDozOC4wMDAwMDAwMDAgKzA1MzAKQEAgLTM3LDE1ICszNywx
MSBAQAogICogLSB1cGRhdGVzIHRvIHRyZWUgYW5kIHRyZWUgd2Fsa2luZyBhcmUgb25seSBkb25l
IHVuZGVyIHRoZSBydG5sIG11dGV4LgogICovCiAKLXN0YXRpYyBpbmxpbmUgaW50IHFkaXNjX3Fs
ZW4oc3RydWN0IFFkaXNjICpxKQotewotCXJldHVybiBxLT5xLnFsZW47Ci19Ci0KIHN0YXRpYyBp
bmxpbmUgaW50IGRldl9yZXF1ZXVlX3NrYihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QgUWRp
c2MgKnEpCiB7CiAJcS0+Z3NvX3NrYiA9IHNrYjsKIAlxLT5xc3RhdHMucmVxdWV1ZXMrKzsKKwlx
LT5xLnFsZW4rKzsJLyogaXQncyBzdGlsbCBwYXJ0IG9mIHRoZSBxdWV1ZSAqLwogCV9fbmV0aWZf
c2NoZWR1bGUocSk7CiAKIAlyZXR1cm4gMDsKQEAgLTYxLDkgKzU3LDExIEBAIHN0YXRpYyBpbmxp
bmUgc3RydWN0IHNrX2J1ZmYgKmRlcXVldWVfc2sKIAogCQkvKiBjaGVjayB0aGUgcmVhc29uIG9m
IHJlcXVldWluZyB3aXRob3V0IHR4IGxvY2sgZmlyc3QgKi8KIAkJdHhxID0gbmV0ZGV2X2dldF90
eF9xdWV1ZShkZXYsIHNrYl9nZXRfcXVldWVfbWFwcGluZyhza2IpKTsKLQkJaWYgKCFuZXRpZl90
eF9xdWV1ZV9zdG9wcGVkKHR4cSkgJiYgIW5ldGlmX3R4X3F1ZXVlX2Zyb3plbih0eHEpKQorCQlp
ZiAoIW5ldGlmX3R4X3F1ZXVlX3N0b3BwZWQodHhxKSAmJgorCQkgICAgIW5ldGlmX3R4X3F1ZXVl
X2Zyb3plbih0eHEpKSB7CiAJCQlxLT5nc29fc2tiID0gTlVMTDsKLQkJZWxzZQorCQkJcS0+cS5x
bGVuLS07CisJCX0gZWxzZQogCQkJc2tiID0gTlVMTDsKIAl9IGVsc2UgewogCQlza2IgPSBxLT5k
ZXF1ZXVlKHEpOwpAQCAtMTAzLDQ0ICsxMDEsMjMgQEAgc3RhdGljIGlubGluZSBpbnQgaGFuZGxl
X2Rldl9jcHVfY29sbGlzaQogfQogCiAvKgotICogTk9URTogQ2FsbGVkIHVuZGVyIHFkaXNjX2xv
Y2socSkgd2l0aCBsb2NhbGx5IGRpc2FibGVkIEJILgotICoKLSAqIF9fUURJU0NfU1RBVEVfUlVO
TklORyBndWFyYW50ZWVzIG9ubHkgb25lIENQVSBjYW4gcHJvY2VzcwotICogdGhpcyBxZGlzYyBh
dCBhIHRpbWUuIHFkaXNjX2xvY2socSkgc2VyaWFsaXplcyBxdWV1ZSBhY2Nlc3NlcyBmb3IKLSAq
IHRoaXMgcXVldWUuCi0gKgotICogIG5ldGlmX3R4X2xvY2sgc2VyaWFsaXplcyBhY2Nlc3NlcyB0
byBkZXZpY2UgZHJpdmVyLgotICoKLSAqICBxZGlzY19sb2NrKHEpIGFuZCBuZXRpZl90eF9sb2Nr
IGFyZSBtdXR1YWxseSBleGNsdXNpdmUsCi0gKiAgaWYgb25lIGlzIGdyYWJiZWQsIGFub3RoZXIg
bXVzdCBiZSBmcmVlLgotICoKLSAqIE5vdGUsIHRoYXQgdGhpcyBwcm9jZWR1cmUgY2FuIGJlIGNh
bGxlZCBieSBhIHdhdGNoZG9nIHRpbWVyCisgKiBUcmFuc21pdCBvbmUgc2tiLCBhbmQgaGFuZGxl
IHRoZSByZXR1cm4gc3RhdHVzIGFzIHJlcXVpcmVkLiBIb2xkaW5nIHRoZQorICogX19RRElTQ19T
VEFURV9SVU5OSU5HIGJpdCBndWFyYW50ZWVzIHRoYXQgb25seSBvbmUgQ1BVIGNhbiBleGVjdXRl
IHRoaXMKKyAqIGZ1bmN0aW9uLgogICoKICAqIFJldHVybnMgdG8gdGhlIGNhbGxlcjoKICAqCQkJ
CTAgIC0gcXVldWUgaXMgZW1wdHkgb3IgdGhyb3R0bGVkLgogICoJCQkJPjAgLSBxdWV1ZSBpcyBu
b3QgZW1wdHkuCi0gKgogICovCi1zdGF0aWMgaW5saW5lIGludCBxZGlzY19yZXN0YXJ0KHN0cnVj
dCBRZGlzYyAqcSkKK2ludCBzY2hfZGlyZWN0X3htaXQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3Ry
dWN0IFFkaXNjICpxLAorCQkgICAgc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IG5ldGRl
dl9xdWV1ZSAqdHhxLAorCQkgICAgc3BpbmxvY2tfdCAqcm9vdF9sb2NrKQogewotCXN0cnVjdCBu
ZXRkZXZfcXVldWUgKnR4cTsKIAlpbnQgcmV0ID0gTkVUREVWX1RYX0JVU1k7Ci0Jc3RydWN0IG5l
dF9kZXZpY2UgKmRldjsKLQlzcGlubG9ja190ICpyb290X2xvY2s7Ci0Jc3RydWN0IHNrX2J1ZmYg
KnNrYjsKLQotCS8qIERlcXVldWUgcGFja2V0ICovCi0JaWYgKHVubGlrZWx5KChza2IgPSBkZXF1
ZXVlX3NrYihxKSkgPT0gTlVMTCkpCi0JCXJldHVybiAwOwotCi0Jcm9vdF9sb2NrID0gcWRpc2Nf
bG9jayhxKTsKIAogCS8qIEFuZCByZWxlYXNlIHFkaXNjICovCiAJc3Bpbl91bmxvY2socm9vdF9s
b2NrKTsKIAotCWRldiA9IHFkaXNjX2RldihxKTsKLQl0eHEgPSBuZXRkZXZfZ2V0X3R4X3F1ZXVl
KGRldiwgc2tiX2dldF9xdWV1ZV9tYXBwaW5nKHNrYikpOwotCiAJSEFSRF9UWF9MT0NLKGRldiwg
dHhxLCBzbXBfcHJvY2Vzc29yX2lkKCkpOwogCWlmICghbmV0aWZfdHhfcXVldWVfc3RvcHBlZCh0
eHEpICYmCiAJICAgICFuZXRpZl90eF9xdWV1ZV9mcm96ZW4odHhxKSkKQEAgLTE3Nyw2ICsxNTQs
NDQgQEAgc3RhdGljIGlubGluZSBpbnQgcWRpc2NfcmVzdGFydChzdHJ1Y3QgUQogCXJldHVybiBy
ZXQ7CiB9CiAKKy8qCisgKiBOT1RFOiBDYWxsZWQgdW5kZXIgcWRpc2NfbG9jayhxKSB3aXRoIGxv
Y2FsbHkgZGlzYWJsZWQgQkguCisgKgorICogX19RRElTQ19TVEFURV9SVU5OSU5HIGd1YXJhbnRl
ZXMgb25seSBvbmUgQ1BVIGNhbiBwcm9jZXNzCisgKiB0aGlzIHFkaXNjIGF0IGEgdGltZS4gcWRp
c2NfbG9jayhxKSBzZXJpYWxpemVzIHF1ZXVlIGFjY2Vzc2VzIGZvcgorICogdGhpcyBxdWV1ZS4K
KyAqCisgKiAgbmV0aWZfdHhfbG9jayBzZXJpYWxpemVzIGFjY2Vzc2VzIHRvIGRldmljZSBkcml2
ZXIuCisgKgorICogIHFkaXNjX2xvY2socSkgYW5kIG5ldGlmX3R4X2xvY2sgYXJlIG11dHVhbGx5
IGV4Y2x1c2l2ZSwKKyAqICBpZiBvbmUgaXMgZ3JhYmJlZCwgYW5vdGhlciBtdXN0IGJlIGZyZWUu
CisgKgorICogTm90ZSwgdGhhdCB0aGlzIHByb2NlZHVyZSBjYW4gYmUgY2FsbGVkIGJ5IGEgd2F0
Y2hkb2cgdGltZXIKKyAqCisgKiBSZXR1cm5zIHRvIHRoZSBjYWxsZXI6CisgKgkJCQkwICAtIHF1
ZXVlIGlzIGVtcHR5IG9yIHRocm90dGxlZC4KKyAqCQkJCT4wIC0gcXVldWUgaXMgbm90IGVtcHR5
LgorICoKKyAqLworc3RhdGljIGlubGluZSBpbnQgcWRpc2NfcmVzdGFydChzdHJ1Y3QgUWRpc2Mg
KnEpCit7CisJc3RydWN0IG5ldGRldl9xdWV1ZSAqdHhxOworCXN0cnVjdCBuZXRfZGV2aWNlICpk
ZXY7CisJc3BpbmxvY2tfdCAqcm9vdF9sb2NrOworCXN0cnVjdCBza19idWZmICpza2I7CisKKwkv
KiBEZXF1ZXVlIHBhY2tldCAqLworCXNrYiA9IGRlcXVldWVfc2tiKHEpOworCWlmICh1bmxpa2Vs
eSghc2tiKSkKKwkJcmV0dXJuIDA7CisKKwlyb290X2xvY2sgPSBxZGlzY19sb2NrKHEpOworCWRl
diA9IHFkaXNjX2RldihxKTsKKwl0eHEgPSBuZXRkZXZfZ2V0X3R4X3F1ZXVlKGRldiwgc2tiX2dl
dF9xdWV1ZV9tYXBwaW5nKHNrYikpOworCisJcmV0dXJuIHNjaF9kaXJlY3RfeG1pdChza2IsIHEs
IGRldiwgdHhxLCByb290X2xvY2spOworfQorCiB2b2lkIF9fcWRpc2NfcnVuKHN0cnVjdCBRZGlz
YyAqcSkKIHsKIAl1bnNpZ25lZCBsb25nIHN0YXJ0X3RpbWUgPSBqaWZmaWVzOwpAQCAtNTQ3LDgg
KzU2MiwxMSBAQCB2b2lkIHFkaXNjX3Jlc2V0KHN0cnVjdCBRZGlzYyAqcWRpc2MpCiAJaWYgKG9w
cy0+cmVzZXQpCiAJCW9wcy0+cmVzZXQocWRpc2MpOwogCi0Ja2ZyZWVfc2tiKHFkaXNjLT5nc29f
c2tiKTsKLQlxZGlzYy0+Z3NvX3NrYiA9IE5VTEw7CisJaWYgKHFkaXNjLT5nc29fc2tiKSB7CisJ
CWtmcmVlX3NrYihxZGlzYy0+Z3NvX3NrYik7CisJCXFkaXNjLT5nc29fc2tiID0gTlVMTDsKKwkJ
cWRpc2MtPnEucWxlbi0tOworCX0KIH0KIEVYUE9SVF9TWU1CT0wocWRpc2NfcmVzZXQpOwogCkBA
IC02MDUsNiArNjIzLDkgQEAgc3RhdGljIHZvaWQgYXR0YWNoX29uZV9kZWZhdWx0X3FkaXNjKHN0
cgogCQkJcHJpbnRrKEtFUk5fSU5GTyAiJXM6IGFjdGl2YXRpb24gZmFpbGVkXG4iLCBkZXYtPm5h
bWUpOwogCQkJcmV0dXJuOwogCQl9CisKKwkJLyogQ2FuIGJ5LXBhc3MgdGhlIHF1ZXVlIGRpc2Np
cGxpbmUgZm9yIGRlZmF1bHQgcWRpc2MgKi8KKwkJcWRpc2MtPmZsYWdzIHw9IFRDUV9GX0NBTl9C
WVBBU1M7CiAJfSBlbHNlIHsKIAkJcWRpc2MgPSAgJm5vcXVldWVfcWRpc2M7CiAJfQo=

--0__=EABBFC9BDF8E86D88f9e8a93df938690918cEABBFC9BDF8E86D8--

