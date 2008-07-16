From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: [PATCH RFC] net_sched: add generic qdisc size table
Date: Thu, 17 Jul 2008 02:40:55 +0300
Message-ID: <20080717024055.18323q4r4ll8sf0g@hayate.ip6>
References: <20080710193434.19525.83454.stgit@fate.lan>
	<20080710193440.19525.93085.stgit@fate.lan> <487B61A9.5090204@trash.net>
	<20080715135244.17106mgc64fxlpj4@hayate.ip6> <487C821D.1010806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=_3kkghnsrny0w"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:57788 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757499AbYGPXk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 19:40:59 -0400
In-Reply-To: <487C821D.1010806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_3kkghnsrny0w
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting "Patrick McHardy" <kaber@trash.net>:

> Jussi Kivilinna wrote:
>> Quoting "Patrick McHardy" <kaber@trash.net>:
>>
>>>
>>> I thought you were going to make this a generic qdisc feature.
>>> Why is configuration still qdisc specific?
>>>
>>
>> I was thinking keeping scope of this patch within hfsc, as done  =20
>> with rest of rate table qdiscs. So it would be better to have they  =20
>> all to use generic size table instead of duplicating rtab code.
>
> Well, to use this feature consistently (meaning sizes propagate
> down to inner qdiscs) it needs to be a generic feature.
>
>>> I was thinking of something like this:
>>>
>>> - add generic attributes for configuring size tables for any
>>>  qdisc, handle those in sch_api
>>>
>>> - add qdisc_enqueue() wrapper that calculates the size and
>>>  stores it in skb->cb, convert direct calls of sch->enqueue
>>>  to use it
>>>
>>> - change direct uses of skb->len to use the size from the cb
>>>
>>> The second step might need a bit more thought to make sure
>>> qdiscs don't get confused when the dequeued packet is larger
>>> than the enqueued one, but I think they usually don't care.
>>>
>>
>> I guess I'll start over using your size table patch as base then.
>
> I'm not sure that part is correct in my patch :)
>

Here's first version of generic size table feature. Didn't get chance =20
to test too much yet but hfsc&sfq seems to be ok.

  - Jussi

--=_3kkghnsrny0w
Content-Type: text/x-patch;
	charset=UTF-8;
	name="01-add-qdisc_enqueue-wrapper.diff"
Content-Disposition: attachment;
	filename="01-add-qdisc_enqueue-wrapper.diff"
Content-Transfer-Encoding: quoted-printable

net_sched: Add qdisc_enqueue wrapper

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/net/sch_generic.h |    5 +++++
 net/core/dev.c            |    2 +-
 net/mac80211/wme.c        |    2 +-
 net/sched/sch_atm.c       |    2 +-
 net/sched/sch_cbq.c       |    5 +++--
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_hfsc.c      |    2 +-
 net/sched/sch_htb.c       |    3 +--
 net/sched/sch_netem.c     |   19 +++++++++++--------
 net/sched/sch_prio.c      |    3 ++-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_tbf.c       |    3 ++-
 12 files changed, 30 insertions(+), 20 deletions(-)


diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 5ba66b5..e3b0d71 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -258,6 +258,11 @@ static inline bool qdisc_tx_is_noop(const struct net_de=
vice *dev)
 =09return (txq->qdisc =3D=3D &noop_qdisc);
 }
=20
+static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+=09return sch->enqueue(skb, sch);
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *s=
ch,
 =09=09=09=09       struct sk_buff_head *list)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 9b49f74..ee2df34 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1733,7 +1733,7 @@ gso:
 =09=09if (q->enqueue) {
 =09=09=09/* reset queue_mapping to zero */
 =09=09=09skb_set_queue_mapping(skb, 0);
-=09=09=09rc =3D q->enqueue(skb, q);
+=09=09=09rc =3D qdisc_enqueue(skb, q);
 =09=09=09qdisc_run(txq);
 =09=09=09spin_unlock(&txq->lock);
=20
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 6ae43a3..e263917 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -212,7 +212,7 @@ static int wme_qdiscop_enqueue(struct sk_buff *skb, stru=
ct Qdisc* qd)
 =09} else {
 =09=09skb_set_queue_mapping(skb, queue);
 =09=09qdisc =3D q->queues[queue];
-=09=09err =3D qdisc->enqueue(skb, qdisc);
+=09=09err =3D qdisc_enqueue(skb, qdisc);
 =09=09if (err =3D=3D NET_XMIT_SUCCESS) {
 =09=09=09qd->q.qlen++;
 =09=09=09qd->bstats.bytes +=3D skb->len;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 0de757e..68ed35e 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -429,7 +429,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qd=
isc *sch)
 #endif
 =09}
=20
-=09ret =3D flow->q->enqueue(skb, flow->q);
+=09ret =3D qdisc_enqueue(skb, flow->q);
 =09if (ret !=3D 0) {
 drop: __maybe_unused
 =09=09sch->qstats.drops++;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 4efc836..1bcb3e8 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -387,7 +387,8 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 =09cl->q->__parent =3D sch;
 #endif
-=09if ((ret =3D cl->q->enqueue(skb, cl->q)) =3D=3D NET_XMIT_SUCCESS) {
+=09ret =3D qdisc_enqueue(skb, cl->q);
+=09if (ret =3D=3D NET_XMIT_SUCCESS) {
 =09=09sch->q.qlen++;
 =09=09sch->bstats.packets++;
 =09=09sch->bstats.bytes+=3Dlen;
@@ -671,7 +672,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct =
Qdisc *child)
 =09=09q->rx_class =3D cl;
 =09=09cl->q->__parent =3D sch;
=20
-=09=09if (cl->q->enqueue(skb, cl->q) =3D=3D 0) {
+=09=09if (qdisc_enqueue(skb, cl->q) =3D=3D 0) {
 =09=09=09sch->q.qlen++;
 =09=09=09sch->bstats.packets++;
 =09=09=09sch->bstats.bytes+=3Dlen;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 3aafbd1..44d347e 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -252,7 +252,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qd=
isc *sch)
 =09=09}
 =09}
=20
-=09err =3D p->q->enqueue(skb, p->q);
+=09err =3D qdisc_enqueue(skb, p->q);
 =09if (err !=3D NET_XMIT_SUCCESS) {
 =09=09sch->qstats.drops++;
 =09=09return err;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 997d520..0ded6d0 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1586,7 +1586,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 =09}
=20
 =09len =3D skb->len;
-=09err =3D cl->qdisc->enqueue(skb, cl->qdisc);
+=09err =3D qdisc_enqueue(skb, cl->qdisc);
 =09if (unlikely(err !=3D NET_XMIT_SUCCESS)) {
 =09=09cl->qstats.drops++;
 =09=09sch->qstats.drops++;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c8ca54c..5fc0325 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -572,8 +572,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc=
 *sch)
 =09=09kfree_skb(skb);
 =09=09return ret;
 #endif
-=09} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=3D
-=09=09   NET_XMIT_SUCCESS) {
+=09} else if (qdisc_enqueue(skb, cl->un.leaf.q) !=3D NET_XMIT_SUCCESS) {
 =09=09sch->qstats.drops++;
 =09=09cl->qstats.drops++;
 =09=09return NET_XMIT_DROP;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bc585f2..cbdbc6a 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -82,6 +82,11 @@ struct netem_skb_cb {
 =09psched_time_t=09time_to_send;
 };
=20
+static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
+{
+=09return (struct netem_skb_cb *)skb->cb;
+}
+
 /* init_crandom - initialize correlated random number generator
  * Use entropy source for initial seed.
  */
@@ -184,7 +189,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdi=
sc *sch)
 =09=09u32 dupsave =3D q->duplicate; /* prevent duplicating a dup... */
 =09=09q->duplicate =3D 0;
=20
-=09=09rootq->enqueue(skb2, rootq);
+=09=09qdisc_enqueue(skb2, rootq);
 =09=09q->duplicate =3D dupsave;
 =09}
=20
@@ -205,7 +210,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdi=
sc *sch)
 =09=09skb->data[net_random() % skb_headlen(skb)] ^=3D 1<<(net_random() % 8)=
;
 =09}
=20
-=09cb =3D (struct netem_skb_cb *)skb->cb;
+=09cb =3D netem_skb_cb(skb);
 =09if (q->gap =3D=3D 0 =09=09/* not doing reordering */
 =09    || q->counter < q->gap =09/* inside last reordering gap */
 =09    || q->reorder < get_crandom(&q->reorder_cor)) {
@@ -218,7 +223,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdi=
sc *sch)
 =09=09now =3D psched_get_time();
 =09=09cb->time_to_send =3D now + delay;
 =09=09++q->counter;
-=09=09ret =3D q->qdisc->enqueue(skb, q->qdisc);
+=09=09ret =3D qdisc_enqueue(skb, q->qdisc);
 =09} else {
 =09=09/*
 =09=09 * Do re-ordering by putting one out of N packets at the front
@@ -277,8 +282,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
=20
 =09skb =3D q->qdisc->dequeue(q->qdisc);
 =09if (skb) {
-=09=09const struct netem_skb_cb *cb
-=09=09=09=3D (const struct netem_skb_cb *)skb->cb;
+=09=09const struct netem_skb_cb *cb =3D netem_skb_cb(skb);
 =09=09psched_time_t now =3D psched_get_time();
=20
 =09=09/* if more time remaining? */
@@ -454,7 +458,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qd=
isc *sch)
 {
 =09struct fifo_sched_data *q =3D qdisc_priv(sch);
 =09struct sk_buff_head *list =3D &sch->q;
-=09psched_time_t tnext =3D ((struct netem_skb_cb *)nskb->cb)->time_to_send;
+=09psched_time_t tnext =3D netem_skb_cb(nskb)->time_to_send;
 =09struct sk_buff *skb;
=20
 =09if (likely(skb_queue_len(list) < q->limit)) {
@@ -465,8 +469,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qd=
isc *sch)
 =09=09}
=20
 =09=09skb_queue_reverse_walk(list, skb) {
-=09=09=09const struct netem_skb_cb *cb
-=09=09=09=09=3D (const struct netem_skb_cb *)skb->cb;
+=09=09=09const struct netem_skb_cb *cb =3D netem_skb_cb(skb);
=20
 =09=09=09if (tnext >=3D cb->time_to_send)
 =09=09=09=09break;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 39157f7..918d090 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -86,7 +86,8 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 =09}
 #endif
=20
-=09if ((ret =3D qdisc->enqueue(skb, qdisc)) =3D=3D NET_XMIT_SUCCESS) {
+=09ret =3D qdisc_enqueue(skb, qdisc);
+=09if (ret =3D=3D NET_XMIT_SUCCESS) {
 =09=09sch->bstats.bytes +=3D skb->len;
 =09=09sch->bstats.packets++;
 =09=09sch->q.qlen++;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 77098ac..b48a391 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -92,7 +92,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* =
sch)
 =09=09=09break;
 =09}
=20
-=09ret =3D child->enqueue(skb, child);
+=09ret =3D qdisc_enqueue(skb, child);
 =09if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
 =09=09sch->bstats.bytes +=3D skb->len;
 =09=09sch->bstats.packets++;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 444c227..7d705b8 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -133,7 +133,8 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc=
* sch)
 =09=09return NET_XMIT_DROP;
 =09}
=20
-=09if ((ret =3D q->qdisc->enqueue(skb, q->qdisc)) !=3D 0) {
+=09ret =3D qdisc_enqueue(skb, q->qdisc);
+=09if (ret !=3D 0) {
 =09=09sch->qstats.drops++;
 =09=09return ret;
 =09}
--=_3kkghnsrny0w
Content-Type: text/x-patch;
	charset=UTF-8;
	name="02-add-accessor-function-for-packet-len-for-qdiscs.diff"
Content-Disposition: attachment;
	filename="02-add-accessor-function-for-packet-len-for-qdiscs.diff"
Content-Transfer-Encoding: quoted-printable

net_sched: Add accessor function for packet length for qdiscs

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/net/sch_generic.h |   17 +++++++++++------
 net/sched/sch_atm.c       |    4 ++--
 net/sched/sch_cbq.c       |   14 ++++++--------
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    2 +-
 net/sched/sch_gred.c      |   12 ++++++------
 net/sched/sch_hfsc.c      |   14 ++++++--------
 net/sched/sch_htb.c       |    9 +++++----
 net/sched/sch_netem.c     |    6 +++---
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_sfq.c       |   16 ++++++++--------
 net/sched/sch_tbf.c       |    9 ++++++---
 net/sched/sch_teql.c      |    6 +++---
 14 files changed, 60 insertions(+), 55 deletions(-)


diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e3b0d71..1f1de3b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -258,6 +258,11 @@ static inline bool qdisc_tx_is_noop(const struct net_de=
vice *dev)
 =09return (txq->qdisc =3D=3D &noop_qdisc);
 }
=20
+static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
+{
+=09return skb->len;
+}
+
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 =09return sch->enqueue(skb, sch);
@@ -267,8 +272,8 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *s=
kb, struct Qdisc *sch,
 =09=09=09=09       struct sk_buff_head *list)
 {
 =09__skb_queue_tail(list, skb);
-=09sch->qstats.backlog +=3D skb->len;
-=09sch->bstats.bytes +=3D skb->len;
+=09sch->qstats.backlog +=3D qdisc_tx_len(skb);
+=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09sch->bstats.packets++;
=20
 =09return NET_XMIT_SUCCESS;
@@ -285,7 +290,7 @@ static inline struct sk_buff *__qdisc_dequeue_head(struc=
t Qdisc *sch,
 =09struct sk_buff *skb =3D __skb_dequeue(list);
=20
 =09if (likely(skb !=3D NULL))
-=09=09sch->qstats.backlog -=3D skb->len;
+=09=09sch->qstats.backlog -=3D qdisc_tx_len(skb);
=20
 =09return skb;
 }
@@ -301,7 +306,7 @@ static inline struct sk_buff *__qdisc_dequeue_tail(struc=
t Qdisc *sch,
 =09struct sk_buff *skb =3D __skb_dequeue_tail(list);
=20
 =09if (likely(skb !=3D NULL))
-=09=09sch->qstats.backlog -=3D skb->len;
+=09=09sch->qstats.backlog -=3D qdisc_tx_len(skb);
=20
 =09return skb;
 }
@@ -315,7 +320,7 @@ static inline int __qdisc_requeue(struct sk_buff *skb, s=
truct Qdisc *sch,
 =09=09=09=09  struct sk_buff_head *list)
 {
 =09__skb_queue_head(list, skb);
-=09sch->qstats.backlog +=3D skb->len;
+=09sch->qstats.backlog +=3D qdisc_tx_len(skb);
 =09sch->qstats.requeues++;
=20
 =09return NET_XMIT_SUCCESS;
@@ -348,7 +353,7 @@ static inline unsigned int __qdisc_queue_drop(struct Qdi=
sc *sch,
 =09struct sk_buff *skb =3D __qdisc_dequeue_tail(sch, list);
=20
 =09if (likely(skb !=3D NULL)) {
-=09=09unsigned int len =3D skb->len;
+=09=09unsigned int len =3D qdisc_tx_len(skb);
 =09=09kfree_skb(skb);
 =09=09return len;
 =09}
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 68ed35e..fdadbf0 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -437,9 +437,9 @@ drop: __maybe_unused
 =09=09=09flow->qstats.drops++;
 =09=09return ret;
 =09}
-=09sch->bstats.bytes +=3D skb->len;
+=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09sch->bstats.packets++;
-=09flow->bstats.bytes +=3D skb->len;
+=09flow->bstats.bytes +=3D qdisc_tx_len(skb);
 =09flow->bstats.packets++;
 =09/*
 =09 * Okay, this may seem weird. We pretend we've dropped the packet if
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 1bcb3e8..a4b7351 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -370,7 +370,6 @@ static int
 cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 =09struct cbq_sched_data *q =3D qdisc_priv(sch);
-=09int len =3D skb->len;
 =09int uninitialized_var(ret);
 =09struct cbq_class *cl =3D cbq_classify(skb, sch, &ret);
=20
@@ -391,7 +390,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 =09if (ret =3D=3D NET_XMIT_SUCCESS) {
 =09=09sch->q.qlen++;
 =09=09sch->bstats.packets++;
-=09=09sch->bstats.bytes+=3Dlen;
+=09=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09cbq_mark_toplevel(q, cl);
 =09=09if (!cl->next_alive)
 =09=09=09cbq_activate_class(cl);
@@ -658,7 +657,6 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *=
timer)
 #ifdef CONFIG_NET_CLS_ACT
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
-=09int len =3D skb->len;
 =09struct Qdisc *sch =3D child->__parent;
 =09struct cbq_sched_data *q =3D qdisc_priv(sch);
 =09struct cbq_class *cl =3D q->rx_class;
@@ -675,7 +673,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct =
Qdisc *child)
 =09=09if (qdisc_enqueue(skb, cl->q) =3D=3D 0) {
 =09=09=09sch->q.qlen++;
 =09=09=09sch->bstats.packets++;
-=09=09=09sch->bstats.bytes+=3Dlen;
+=09=09=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09=09if (!cl->next_alive)
 =09=09=09=09cbq_activate_class(cl);
 =09=09=09return 0;
@@ -881,7 +879,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 =09=09=09if (skb =3D=3D NULL)
 =09=09=09=09goto skip_class;
=20
-=09=09=09cl->deficit -=3D skb->len;
+=09=09=09cl->deficit -=3D qdisc_tx_len(skb);
 =09=09=09q->tx_class =3D cl;
 =09=09=09q->tx_borrowed =3D borrow;
 =09=09=09if (borrow !=3D cl) {
@@ -889,11 +887,11 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 =09=09=09=09borrow->xstats.borrows++;
 =09=09=09=09cl->xstats.borrows++;
 #else
-=09=09=09=09borrow->xstats.borrows +=3D skb->len;
-=09=09=09=09cl->xstats.borrows +=3D skb->len;
+=09=09=09=09borrow->xstats.borrows +=3D qdisc_tx_len(skb);
+=09=09=09=09cl->xstats.borrows +=3D qdisc_tx_len(skb);
 #endif
 =09=09=09}
-=09=09=09q->tx_len =3D skb->len;
+=09=09=09q->tx_len =3D qdisc_tx_len(skb);
=20
 =09=09=09if (cl->deficit <=3D 0) {
 =09=09=09=09q->active[prio] =3D cl;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 44d347e..4a4cd62 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -258,7 +258,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qd=
isc *sch)
 =09=09return err;
 =09}
=20
-=09sch->bstats.bytes +=3D skb->len;
+=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09sch->bstats.packets++;
 =09sch->q.qlen++;
=20
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 1d97fa4..9f63fb4 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -27,7 +27,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc=
* sch)
 {
 =09struct fifo_sched_data *q =3D qdisc_priv(sch);
=20
-=09if (likely(sch->qstats.backlog + skb->len <=3D q->limit))
+=09if (likely(sch->qstats.backlog + qdisc_tx_len(skb) <=3D q->limit))
 =09=09return qdisc_enqueue_tail(skb, sch);
=20
 =09return qdisc_reshape_fail(skb, sch);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 39fa285..36f4326 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -188,7 +188,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdis=
c* sch)
 =09}
=20
 =09q->packetsin++;
-=09q->bytesin +=3D skb->len;
+=09q->bytesin +=3D qdisc_tx_len(skb);
=20
 =09if (gred_wred_mode(t))
 =09=09gred_load_wred_set(t, q);
@@ -226,8 +226,8 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdis=
c* sch)
 =09=09=09break;
 =09}
=20
-=09if (q->backlog + skb->len <=3D q->limit) {
-=09=09q->backlog +=3D skb->len;
+=09if (q->backlog + qdisc_tx_len(skb) <=3D q->limit) {
+=09=09q->backlog +=3D qdisc_tx_len(skb);
 =09=09return qdisc_enqueue_tail(skb, sch);
 =09}
=20
@@ -254,7 +254,7 @@ static int gred_requeue(struct sk_buff *skb, struct Qdis=
c* sch)
 =09} else {
 =09=09if (red_is_idling(&q->parms))
 =09=09=09red_end_of_idle_period(&q->parms);
-=09=09q->backlog +=3D skb->len;
+=09=09q->backlog +=3D qdisc_tx_len(skb);
 =09}
=20
 =09return qdisc_requeue(skb, sch);
@@ -277,7 +277,7 @@ static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 =09=09=09=09       "VQ 0x%x after dequeue, screwing up "
 =09=09=09=09       "backlog.\n", tc_index_to_dp(skb));
 =09=09} else {
-=09=09=09q->backlog -=3D skb->len;
+=09=09=09q->backlog -=3D qdisc_tx_len(skb);
=20
 =09=09=09if (!q->backlog && !gred_wred_mode(t))
 =09=09=09=09red_start_of_idle_period(&q->parms);
@@ -299,7 +299,7 @@ static unsigned int gred_drop(struct Qdisc* sch)
=20
 =09skb =3D qdisc_dequeue_tail(sch);
 =09if (skb) {
-=09=09unsigned int len =3D skb->len;
+=09=09unsigned int len =3D qdisc_tx_len(skb);
 =09=09struct gred_sched_data *q;
 =09=09u16 dp =3D tc_index_to_dp(skb);
=20
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0ded6d0..76f8278 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -895,7 +895,7 @@ qdisc_peek_len(struct Qdisc *sch)
 =09=09=09printk("qdisc_peek_len: non work-conserving qdisc ?\n");
 =09=09return 0;
 =09}
-=09len =3D skb->len;
+=09len =3D qdisc_tx_len(skb);
 =09if (unlikely(sch->ops->requeue(skb, sch) !=3D NET_XMIT_SUCCESS)) {
 =09=09if (net_ratelimit())
 =09=09=09printk("qdisc_peek_len: failed to requeue\n");
@@ -1574,7 +1574,6 @@ static int
 hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 =09struct hfsc_class *cl;
-=09unsigned int len;
 =09int err;
=20
 =09cl =3D hfsc_classify(skb, sch, &err);
@@ -1585,7 +1584,6 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 =09=09return err;
 =09}
=20
-=09len =3D skb->len;
 =09err =3D qdisc_enqueue(skb, cl->qdisc);
 =09if (unlikely(err !=3D NET_XMIT_SUCCESS)) {
 =09=09cl->qstats.drops++;
@@ -1594,12 +1592,12 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 =09}
=20
 =09if (cl->qdisc->q.qlen =3D=3D 1)
-=09=09set_active(cl, len);
+=09=09set_active(cl, qdisc_tx_len(skb));
=20
 =09cl->bstats.packets++;
-=09cl->bstats.bytes +=3D len;
+=09cl->bstats.bytes +=3D qdisc_tx_len(skb);
 =09sch->bstats.packets++;
-=09sch->bstats.bytes +=3D len;
+=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09sch->q.qlen++;
=20
 =09return NET_XMIT_SUCCESS;
@@ -1649,9 +1647,9 @@ hfsc_dequeue(struct Qdisc *sch)
 =09=09return NULL;
 =09}
=20
-=09update_vf(cl, skb->len, cur_time);
+=09update_vf(cl, qdisc_tx_len(skb), cur_time);
 =09if (realtime)
-=09=09cl->cl_cumul +=3D skb->len;
+=09=09cl->cl_cumul +=3D qdisc_tx_len(skb);
=20
 =09if (cl->qdisc->q.qlen !=3D 0) {
 =09=09if (cl->cl_flags & HFSC_RSC) {
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 5fc0325..5e1dcf8 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -579,13 +579,13 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdi=
sc *sch)
 =09} else {
 =09=09cl->bstats.packets +=3D
 =09=09=09skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-=09=09cl->bstats.bytes +=3D skb->len;
+=09=09cl->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09htb_activate(q, cl);
 =09}
=20
 =09sch->q.qlen++;
 =09sch->bstats.packets +=3D skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-=09sch->bstats.bytes +=3D skb->len;
+=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09return NET_XMIT_SUCCESS;
 }
=20
@@ -642,7 +642,7 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc=
 *sch)
 static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 =09=09=09     int level, struct sk_buff *skb)
 {
-=09int bytes =3D skb->len;
+=09int bytes =3D qdisc_tx_len(skb);
 =09long toks, diff;
 =09enum htb_cmode old_mode;
=20
@@ -855,7 +855,8 @@ next:
 =09} while (cl !=3D start);
=20
 =09if (likely(skb !=3D NULL)) {
-=09=09if ((cl->un.leaf.deficit[level] -=3D skb->len) < 0) {
+=09=09cl->un.leaf.deficit[level] -=3D qdisc_tx_len(skb);
+=09=09if (cl->un.leaf.deficit[level] < 0) {
 =09=09=09cl->un.leaf.deficit[level] +=3D cl->un.leaf.quantum;
 =09=09=09htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
 =09=09=09=09=09  ptr[0]) + prio);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index cbdbc6a..bc9d6af 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -236,7 +236,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdi=
sc *sch)
=20
 =09if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
 =09=09sch->q.qlen++;
-=09=09sch->bstats.bytes +=3D skb->len;
+=09=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09sch->bstats.packets++;
 =09} else
 =09=09sch->qstats.drops++;
@@ -477,8 +477,8 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qd=
isc *sch)
=20
 =09=09__skb_queue_after(list, skb, nskb);
=20
-=09=09sch->qstats.backlog +=3D nskb->len;
-=09=09sch->bstats.bytes +=3D nskb->len;
+=09=09sch->qstats.backlog +=3D qdisc_tx_len(nskb);
+=09=09sch->bstats.bytes +=3D qdisc_tx_len(nskb);
 =09=09sch->bstats.packets++;
=20
 =09=09return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 918d090..b5889e8 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -88,7 +88,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
=20
 =09ret =3D qdisc_enqueue(skb, qdisc);
 =09if (ret =3D=3D NET_XMIT_SUCCESS) {
-=09=09sch->bstats.bytes +=3D skb->len;
+=09=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09sch->bstats.packets++;
 =09=09sch->q.qlen++;
 =09=09return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index b48a391..6f34e80 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -94,7 +94,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* =
sch)
=20
 =09ret =3D qdisc_enqueue(skb, child);
 =09if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
-=09=09sch->bstats.bytes +=3D skb->len;
+=09=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09sch->bstats.packets++;
 =09=09sch->q.qlen++;
 =09} else {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8458f63..ca3876b 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -245,7 +245,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 =09if (d > 1) {
 =09=09sfq_index x =3D q->dep[d + SFQ_DEPTH].next;
 =09=09skb =3D q->qs[x].prev;
-=09=09len =3D skb->len;
+=09=09len =3D qdisc_tx_len(skb);
 =09=09__skb_unlink(skb, &q->qs[x]);
 =09=09kfree_skb(skb);
 =09=09sfq_dec(q, x);
@@ -261,7 +261,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 =09=09q->next[q->tail] =3D q->next[d];
 =09=09q->allot[q->next[d]] +=3D q->quantum;
 =09=09skb =3D q->qs[d].prev;
-=09=09len =3D skb->len;
+=09=09len =3D qdisc_tx_len(skb);
 =09=09__skb_unlink(skb, &q->qs[d]);
 =09=09kfree_skb(skb);
 =09=09sfq_dec(q, d);
@@ -305,7 +305,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 =09if (q->qs[x].qlen >=3D q->limit)
 =09=09return qdisc_drop(skb, sch);
=20
-=09sch->qstats.backlog +=3D skb->len;
+=09sch->qstats.backlog +=3D qdisc_tx_len(skb);
 =09__skb_queue_tail(&q->qs[x], skb);
 =09sfq_inc(q, x);
 =09if (q->qs[x].qlen =3D=3D 1) {=09=09/* The flow is new */
@@ -320,7 +320,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 =09=09}
 =09}
 =09if (++sch->q.qlen <=3D q->limit) {
-=09=09sch->bstats.bytes +=3D skb->len;
+=09=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09sch->bstats.packets++;
 =09=09return 0;
 =09}
@@ -352,7 +352,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 =09=09q->hash[x] =3D hash;
 =09}
=20
-=09sch->qstats.backlog +=3D skb->len;
+=09sch->qstats.backlog +=3D qdisc_tx_len(skb);
 =09__skb_queue_head(&q->qs[x], skb);
 =09/* If selected queue has length q->limit+1, this means that
 =09 * all another queues are empty and we do simple tail drop.
@@ -363,7 +363,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 =09=09skb =3D q->qs[x].prev;
 =09=09__skb_unlink(skb, &q->qs[x]);
 =09=09sch->qstats.drops++;
-=09=09sch->qstats.backlog -=3D skb->len;
+=09=09sch->qstats.backlog -=3D qdisc_tx_len(skb);
 =09=09kfree_skb(skb);
 =09=09return NET_XMIT_CN;
 =09}
@@ -411,7 +411,7 @@ sfq_dequeue(struct Qdisc *sch)
 =09skb =3D __skb_dequeue(&q->qs[a]);
 =09sfq_dec(q, a);
 =09sch->q.qlen--;
-=09sch->qstats.backlog -=3D skb->len;
+=09sch->qstats.backlog -=3D qdisc_tx_len(skb);
=20
 =09/* Is the slot empty? */
 =09if (q->qs[a].qlen =3D=3D 0) {
@@ -423,7 +423,7 @@ sfq_dequeue(struct Qdisc *sch)
 =09=09}
 =09=09q->next[q->tail] =3D a;
 =09=09q->allot[a] +=3D q->quantum;
-=09} else if ((q->allot[a] -=3D skb->len) <=3D 0) {
+=09} else if ((q->allot[a] -=3D qdisc_tx_len(skb)) <=3D 0) {
 =09=09q->tail =3D a;
 =09=09a =3D q->next[a];
 =09=09q->allot[a] +=3D q->quantum;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 7d705b8..1e3d52e 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -123,7 +123,10 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdis=
c* sch)
 =09struct tbf_sched_data *q =3D qdisc_priv(sch);
 =09int ret;
=20
-=09if (skb->len > q->max_size) {
+=09/* qdisc_tx_len() before qdisc_enqueue() wrapper, might return different
+=09 * length than after wrapper. Should recalculate tx_len here if q->qdisc
+=09 * has size table? */
+=09if (qdisc_tx_len(skb) > q->max_size) {
 =09=09sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_ACT
 =09=09if (sch->reshape_fail =3D=3D NULL || sch->reshape_fail(skb, sch))
@@ -140,7 +143,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc=
* sch)
 =09}
=20
 =09sch->q.qlen++;
-=09sch->bstats.bytes +=3D skb->len;
+=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09sch->bstats.packets++;
 =09return 0;
 }
@@ -181,7 +184,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 =09=09psched_time_t now;
 =09=09long toks;
 =09=09long ptoks =3D 0;
-=09=09unsigned int len =3D skb->len;
+=09=09unsigned int len =3D qdisc_tx_len(skb);
=20
 =09=09now =3D psched_get_time();
 =09=09toks =3D psched_tdiff_bounded(now, q->t_c, q->buffer);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 8ac0598..2b25275 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -83,7 +83,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
=20
 =09if (q->q.qlen < dev->tx_queue_len) {
 =09=09__skb_queue_tail(&q->q, skb);
-=09=09sch->bstats.bytes +=3D skb->len;
+=09=09sch->bstats.bytes +=3D qdisc_tx_len(skb);
 =09=09sch->bstats.packets++;
 =09=09return 0;
 =09}
@@ -270,7 +270,6 @@ static int teql_master_xmit(struct sk_buff *skb, struct =
net_device *dev)
 =09struct Qdisc *start, *q;
 =09int busy;
 =09int nores;
-=09int len =3D skb->len;
 =09int subq =3D skb_get_queue_mapping(skb);
 =09struct sk_buff *skb_res =3D NULL;
=20
@@ -305,7 +304,8 @@ restart:
 =09=09=09=09=09master->slaves =3D NEXT_SLAVE(q);
 =09=09=09=09=09netif_wake_queue(dev);
 =09=09=09=09=09master->stats.tx_packets++;
-=09=09=09=09=09master->stats.tx_bytes +=3D len;
+=09=09=09=09=09master->stats.tx_bytes +=3D
+=09=09=09=09=09=09qdisc_tx_len(skb);
 =09=09=09=09=09return 0;
 =09=09=09=09}
 =09=09=09=09netif_tx_unlock(slave);
--=_3kkghnsrny0w
Content-Type: text/x-patch;
	charset=UTF-8;
	name="03-add-size-table-for-qdiscs.diff"
Content-Disposition: attachment;
	filename="03-add-size-table-for-qdiscs.diff"
Content-Transfer-Encoding: quoted-printable

net_sched: Add size table for qdiscs

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Add size table functions for qdiscs and calculate packet size in
qdisc_enqueue().

Based on patch by Patrick McHardy
 http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   21 ++++++++
 include/linux/rtnetlink.h |    1=20
 include/net/pkt_sched.h   |    1=20
 include/net/sch_generic.h |   30 +++++++++++-
 net/core/dev.c            |    1=20
 net/sched/sch_api.c       |  117 ++++++++++++++++++++++++++++++++++++++++++=
++-
 net/sched/sch_generic.c   |    1=20
 net/sched/sch_netem.c     |    3 +
 net/sched/sch_tbf.c       |    6 +-
 9 files changed, 174 insertions(+), 7 deletions(-)


diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..eae53bf 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,27 @@ struct tc_ratespec
=20
 #define TC_RTAB_SIZE=091024
=20
+struct tc_sizespec {
+=09unsigned char=09cell_log;
+=09unsigned char=09size_log;
+=09short=09=09cell_align;
+=09int=09=09overhead;
+=09unsigned=09linklayer;
+=09unsigned=09mpu;
+=09unsigned=09mtu;
+};
+
+#define TC_STAB_DATA_SIZE 1024
+
+enum {
+=09TCA_STAB_UNSPEC,
+=09TCA_STAB_BASE,
+=09TCA_STAB_DATA,
+=09__TCA_STAB_MAX
+};
+
+#define TCA_STAB_MAX (__TCA_STAB_MAX - 1)
+
 /* FIFO section */
=20
 struct tc_fifo_qopt
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index b358c70..f4d386c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -482,6 +482,7 @@ enum
 =09TCA_RATE,
 =09TCA_FCNT,
 =09TCA_STATS2,
+=09TCA_STAB,
 =09__TCA_MAX
 };
=20
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index d58c1a5..7a8a2a0 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -83,6 +83,7 @@ extern struct Qdisc *qdisc_lookup_class(struct net_device =
*dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 =09=09struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
+extern void qdisc_put_stab(struct qdisc_size_table *tab);
=20
 extern void __qdisc_run(struct netdev_queue *txq);
=20
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1f1de3b..81805d0 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -23,6 +23,13 @@ struct qdisc_rate_table
 =09int=09=09refcnt;
 };
=20
+struct qdisc_size_table {
+=09struct list_head=09list;
+=09struct tc_sizespec=09szopts;
+=09int=09=09=09refcnt;
+=09u16=09=09=09data[512];
+};
+
 struct Qdisc
 {
 =09int =09=09=09(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
@@ -33,6 +40,7 @@ struct Qdisc
 #define TCQ_F_INGRESS=094
 =09int=09=09=09padded;
 =09struct Qdisc_ops=09*ops;
+=09struct qdisc_size_table=09*stab;
 =09u32=09=09=09handle;
 =09u32=09=09=09parent;
 =09atomic_t=09=09refcnt;
@@ -154,6 +162,16 @@ struct tcf_proto
 =09struct tcf_proto_ops=09*ops;
 };
=20
+struct qdisc_skb_cb {
+=09unsigned int=09=09tx_len;
+=09char=09=09=09data[];
+};
+
+static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
+{
+=09return (struct qdisc_skb_cb *)skb->cb;
+}
+
 static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
 {
 =09return qdisc->dev_queue->dev;
@@ -224,6 +242,8 @@ extern struct Qdisc *qdisc_alloc(struct netdev_queue *de=
v_queue,
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 =09=09=09=09       struct netdev_queue *dev_queue,
 =09=09=09=09       struct Qdisc_ops *ops, u32 parentid);
+extern void qdisc_calculate_tx_len(struct sk_buff *skb,
+=09=09=09=09   struct qdisc_size_table *stab);
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto **fl);
=20
@@ -258,13 +278,21 @@ static inline bool qdisc_tx_is_noop(const struct net_d=
evice *dev)
 =09return (txq->qdisc =3D=3D &noop_qdisc);
 }
=20
+static inline void qdisc_root_init_tx_len(struct sk_buff *skb,
+=09=09=09=09=09  struct Qdisc *sch)
+{
+=09qdisc_skb_cb(skb)->tx_len =3D skb->len;
+}
+
 static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
 {
-=09return skb->len;
+=09return qdisc_skb_cb(skb)->tx_len;
 }
=20
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
+=09if (sch->stab)
+=09=09qdisc_calculate_tx_len(skb, sch->stab);
 =09return sch->enqueue(skb, sch);
 }
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index ee2df34..8223b56 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1733,6 +1733,7 @@ gso:
 =09=09if (q->enqueue) {
 =09=09=09/* reset queue_mapping to zero */
 =09=09=09skb_set_queue_mapping(skb, 0);
+=09=09=09qdisc_root_init_tx_len(skb, q);
 =09=09=09rc =3D qdisc_enqueue(skb, q);
 =09=09=09qdisc_run(txq);
 =09=09=09spin_unlock(&txq->lock);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 95873f8..4d98cb7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -278,6 +278,97 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 }
 EXPORT_SYMBOL(qdisc_put_rtab);
=20
+static LIST_HEAD(qdisc_stab_list);
+
+static const struct nla_policy stab_policy[TCA_STAB_MAX + 1] =3D {
+=09[TCA_STAB_BASE]=09=3D { .len =3D sizeof(struct tc_sizespec) },
+=09[TCA_STAB_DATA] =3D { .type =3D NLA_BINARY, .len =3D TC_STAB_DATA_SIZE }=
,
+};
+
+static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt, int *err=
)
+{
+=09struct nlattr *tb[TCA_STAB_MAX + 1];
+=09struct qdisc_size_table *stab;
+=09struct tc_sizespec *s;
+=09u16 *tab;
+
+=09*err =3D nla_parse_nested(tb, TCA_STAB_MAX, opt, stab_policy);
+=09if (*err < 0)
+=09=09return NULL;
+
+=09s =3D nla_data(tb[TCA_STAB_BASE]);
+=09tab =3D nla_data(tb[TCA_STAB_DATA]);
+
+=09*err =3D -EINVAL;
+=09if (!s || !tab || nla_len(tb[TCA_STAB_DATA]) < TC_STAB_DATA_SIZE)
+=09=09return NULL;
+
+=09list_for_each_entry(stab, &qdisc_stab_list, list) {
+=09=09if (memcmp(&stab->szopts, s, sizeof(*s)) =3D=3D 0 &&
+=09=09    memcmp(stab->data, tab, TC_STAB_DATA_SIZE) =3D=3D 0) {
+=09=09=09stab->refcnt++;
+=09=09=09*err =3D 0;
+=09=09=09return stab;
+=09=09}
+=09}
+
+=09*err =3D -ENOMEM;
+=09stab =3D kmalloc(sizeof(*stab), GFP_KERNEL);
+=09if (stab) {
+=09=09stab->szopts =3D *s;
+=09=09stab->refcnt =3D 1;
+=09=09memcpy(stab->data, tab, TC_STAB_DATA_SIZE);
+=09=09list_add_tail(&stab->list, &qdisc_stab_list);
+=09=09*err =3D 0;
+=09}
+=09return stab;
+}
+
+void qdisc_put_stab(struct qdisc_size_table *tab)
+{
+=09if (!tab || --tab->refcnt)
+=09=09return;
+=09list_del(&tab->list);
+=09kfree(tab);
+}
+EXPORT_SYMBOL(qdisc_put_stab);
+
+static int qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *st=
ab)
+{
+=09struct nlattr *nest;
+
+=09nest =3D nla_nest_start(skb, TCA_STAB);
+=09NLA_PUT(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts);
+=09NLA_PUT(skb, TCA_STAB_DATA, TC_STAB_DATA_SIZE, stab->data);
+=09nla_nest_end(skb, nest);
+
+=09return skb->len;
+
+nla_put_failure:
+=09return -1;
+}
+
+void qdisc_calculate_tx_len(struct sk_buff *skb, struct qdisc_size_table *s=
tab)
+{
+=09unsigned int pktlen =3D skb->len;
+=09unsigned char size_log;
+=09int slot;
+
+=09slot =3D pktlen + stab->szopts.cell_align + stab->szopts.overhead;
+=09if (unlikely(slot < 0))
+=09=09slot =3D 0;
+=09slot >>=3D stab->szopts.cell_log;
+=09size_log =3D stab->szopts.size_log;
+=09if (unlikely(slot > 511))
+=09=09pktlen =3D ((u32)stab->data[511] << size_log) * (slot >> 9) +
+=09=09=09((u32)stab->data[slot & 0x1FF] << size_log);
+=09else
+=09=09pktlen =3D (u32)stab->data[slot] << size_log;
+
+=09qdisc_skb_cb(skb)->tx_len =3D pktlen;
+}
+EXPORT_SYMBOL(qdisc_calculate_tx_len);
+
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 =09struct qdisc_watchdog *wd =3D container_of(timer, struct qdisc_watchdog,
@@ -619,6 +710,11 @@ qdisc_create(struct net_device *dev, struct netdev_queu=
e *dev_queue,
 =09sch->handle =3D handle;
=20
 =09if (!ops->init || (err =3D ops->init(sch, tca[TCA_OPTIONS])) =3D=3D 0) {
+=09=09if (tca[TCA_STAB]) {
+=09=09=09sch->stab =3D qdisc_get_stab(tca[TCA_STAB], &err);
+=09=09=09if (sch->stab =3D=3D NULL)
+=09=09=09=09goto err_out3;
+=09=09}
 =09=09if (tca[TCA_RATE]) {
 =09=09=09err =3D gen_new_estimator(&sch->bstats, &sch->rate_est,
 =09=09=09=09=09=09&sch->dev_queue->lock,
@@ -641,6 +737,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue=
 *dev_queue,
 =09=09return sch;
 =09}
 err_out3:
+=09qdisc_put_stab(sch->stab);
 =09dev_put(dev);
 =09kfree((char *) sch - sch->padded);
 err_out2:
@@ -652,15 +749,28 @@ err_out:
=20
 static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 {
-=09if (tca[TCA_OPTIONS]) {
-=09=09int err;
+=09struct qdisc_size_table *stab =3D NULL;
+=09int err =3D 0;
=20
+=09if (tca[TCA_OPTIONS]) {
 =09=09if (sch->ops->change =3D=3D NULL)
 =09=09=09return -EINVAL;
 =09=09err =3D sch->ops->change(sch, tca[TCA_OPTIONS]);
 =09=09if (err)
 =09=09=09return err;
 =09}
+
+=09if (tca[TCA_STAB]) {
+=09=09stab =3D qdisc_get_stab(tca[TCA_STAB], &err);
+=09=09if (stab =3D=3D NULL)
+=09=09=09return err;
+=09}
+
+=09spin_lock_bh(&sch->dev_queue->lock);
+=09qdisc_put_stab(sch->stab);
+=09sch->stab =3D stab;
+=09spin_unlock_bh(&sch->dev_queue->lock);
+
 =09if (tca[TCA_RATE])
 =09=09gen_replace_estimator(&sch->bstats, &sch->rate_est,
 =09=09=09=09      &sch->dev_queue->lock, tca[TCA_RATE]);
@@ -952,6 +1062,9 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qd=
isc *q, u32 clid,
 =09=09goto nla_put_failure;
 =09q->qstats.qlen =3D q->q.qlen;
=20
+=09if (q->stab !=3D NULL && qdisc_dump_stab(skb, q->stab) < 0)
+=09=09goto nla_put_failure;
+
 =09if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
 =09=09=09=09=09 TCA_XSTATS, &q->dev_queue->lock, &d) < 0)
 =09=09goto nla_put_failure;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 243de93..53e941b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -530,6 +530,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 =09=09return;
=20
 =09list_del(&qdisc->list);
+=09qdisc_put_stab(qdisc->stab);
 =09gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
 =09if (ops->reset)
 =09=09ops->reset(qdisc);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bc9d6af..f75ba82 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -84,7 +84,7 @@ struct netem_skb_cb {
=20
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
-=09return (struct netem_skb_cb *)skb->cb;
+=09return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 }
=20
 /* init_crandom - initialize correlated random number generator
@@ -189,6 +189,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdi=
sc *sch)
 =09=09u32 dupsave =3D q->duplicate; /* prevent duplicating a dup... */
 =09=09q->duplicate =3D 0;
=20
+=09=09qdisc_root_init_tx_len(skb2, rootq);
 =09=09qdisc_enqueue(skb2, rootq);
 =09=09q->duplicate =3D dupsave;
 =09}
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1e3d52e..7f7a626 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -123,9 +123,9 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc=
* sch)
 =09struct tbf_sched_data *q =3D qdisc_priv(sch);
 =09int ret;
=20
-=09/* qdisc_tx_len() before qdisc_enqueue() wrapper, might return different
-=09 * length than after wrapper. Should recalculate tx_len here if q->qdisc
-=09 * has size table? */
+=09if (q->qdisc->stab)
+=09=09qdisc_calculate_tx_len(skb, sch->stab);
+
 =09if (qdisc_tx_len(skb) > q->max_size) {
 =09=09sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_ACT
--=_3kkghnsrny0w
Content-Type: text/x-patch;
	charset=UTF-8;
	name="01-iproute-add-size-table.diff"
Content-Disposition: attachment;
	filename="01-iproute-add-size-table.diff"
Content-Transfer-Encoding: quoted-printable

[iproute2/tc] tc_core: add size table

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Patch adds generic size table that is similiar to rate table, with=20
difference that size table stores link layer packet size.=20

Based on patch by Patrick McHardy
 http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   21 +++++++++++++++
 include/linux/rtnetlink.h |    1 +
 tc/Makefile               |    1 +
 tc/tc_class.c             |    1 +
 tc/tc_common.h            |    5 ++++
 tc/tc_core.c              |   64 ++++++++++++++++++++++++++++++++++--------=
---
 tc/tc_core.h              |    6 +++-
 tc/tc_qdisc.c             |   32 +++++++++++++++++++++++
 tc/tc_util.c              |   26 ++++++++++++++++++
 tc/tc_util.h              |    2 +
 10 files changed, 141 insertions(+), 18 deletions(-)


diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..eae53bf 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,27 @@ struct tc_ratespec
=20
 #define TC_RTAB_SIZE=091024
=20
+struct tc_sizespec {
+=09unsigned char=09cell_log;
+=09unsigned char=09size_log;
+=09short=09=09cell_align;
+=09int=09=09overhead;
+=09unsigned=09linklayer;
+=09unsigned=09mpu;
+=09unsigned=09mtu;
+};
+
+#define TC_STAB_DATA_SIZE 1024
+
+enum {
+=09TCA_STAB_UNSPEC,
+=09TCA_STAB_BASE,
+=09TCA_STAB_DATA,
+=09__TCA_STAB_MAX
+};
+
+#define TCA_STAB_MAX (__TCA_STAB_MAX - 1)
+
 /* FIFO section */
=20
 struct tc_fifo_qopt
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index c1f2d50..a125692 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -482,6 +482,7 @@ enum
 =09TCA_RATE,
 =09TCA_FCNT,
 =09TCA_STATS2,
+=09TCA_STAB,
 =09__TCA_MAX
 };
=20
diff --git a/tc/Makefile b/tc/Makefile
index bf2df00..a5ac841 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -45,6 +45,7 @@ TCLIB :=3D tc_core.o
 TCLIB +=3D tc_red.o
 TCLIB +=3D tc_cbq.o
 TCLIB +=3D tc_estimator.o
+TCLIB +=3D tc_stab.o
=20
 CFLAGS +=3D -DCONFIG_GACT -DCONFIG_GACT_PROB
=20
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 774497a..6cf19d4 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -31,6 +31,7 @@ static void usage(void)
 {
 =09fprintf(stderr, "Usage: tc class [ add | del | change | replace | show ]=
 dev STRING\n");
 =09fprintf(stderr, "       [ classid CLASSID ] [ root | parent CLASSID ]\n"=
);
+=09fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
 =09fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 =09fprintf(stderr, "\n");
 =09fprintf(stderr, "       tc class show [ dev STRING ] [ root | parent CLA=
SSID ]\n");
diff --git a/tc/tc_common.h b/tc/tc_common.h
index e01b037..4f88856 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -11,6 +11,11 @@ extern int print_action(const struct sockaddr_nl *who, st=
ruct nlmsghdr *n, void
 extern int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, =
void *arg);
 extern int print_qdisc(const struct sockaddr_nl *who, struct nlmsghdr *n, v=
oid *arg);
 extern int print_class(const struct sockaddr_nl *who, struct nlmsghdr *n, v=
oid *arg);
+extern void print_size_table(FILE *fp, const char *prefix, struct rtattr *r=
ta);
=20
 struct tc_estimator;
 extern int parse_estimator(int *p_argc, char ***p_argv, struct tc_estimator=
 *est);
+
+struct tc_sizespec;
+extern int parse_size_table(int *p_argc, char ***p_argv, struct tc_sizespec=
 *s);
+extern int check_size_table_opts(struct tc_sizespec *s);
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 855c115..dd7885c 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -87,6 +87,21 @@ unsigned tc_align_to_atm(unsigned size)
 =09return linksize;
 }
=20
+unsigned tc_adjust_size(unsigned sz, unsigned mpu, enum link_layer linklaye=
r)
+{
+=09if (sz < mpu)
+=09=09sz =3D mpu;
+
+=09switch (linklayer) {
+=09case LINKLAYER_ATM:
+=09=09return tc_align_to_atm(sz);
+=09case LINKLAYER_ETHERNET:
+=09default:
+=09=09// No size adjustments on Ethernet
+=09=09return sz;
+=09}
+}
+
 /*
    rtab[pkt_len>>cell_log] =3D pkt_xmit_time
  */
@@ -96,6 +111,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09=09   enum link_layer linklayer)
 {
 =09int i;
+=09unsigned sz;
 =09unsigned bps =3D r->rate;
 =09unsigned mpu =3D r->mpu;
=20
@@ -109,21 +125,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09}
=20
 =09for (i=3D0; i<256; i++) {
-=09=09unsigned sz =3D (i+1)<<cell_log;
-=09=09if (sz < mpu)
-=09=09=09sz =3D mpu;
-
-=09=09switch (linklayer) {
-=09=09case LINKLAYER_ATM:
-=09=09=09sz =3D tc_align_to_atm(sz);
-=09=09=09break;
-=09=09case LINKLAYER_ETHERNET:
-=09=09=09// No size adjustments on Ethernet
-=09=09=09break;
-=09=09default:
-=09=09=09break;
-=09=09}
-
+=09=09sz =3D tc_adjust_size((i + 1) << cell_log, mpu, linklayer);
 =09=09rtab[i] =3D tc_calc_xmittime(bps, sz);
 =09}
=20
@@ -132,6 +134,38 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09return cell_log;
 }
=20
+/*
+   stab[pkt_len>>cell_log] =3D pkt_xmit_size>>size_log
+ */
+
+int tc_calc_size_table(struct tc_sizespec *s, __u16 *stab)
+{
+=09int i;
+=09enum link_layer linklayer =3D s->linklayer;
+=09unsigned mtu =3D s->mtu;
+=09unsigned sz;
+
+=09if (mtu =3D=3D 0)
+=09=09mtu =3D 2047;
+
+=09s->cell_log =3D 0;
+=09while ((mtu >> s->cell_log) > 512 - 1)
+=09=09s->cell_log++;
+
+again:
+=09for (i =3D 512 - 1; i >=3D 0; i--) {
+=09=09sz =3D tc_adjust_size((i + 1) << s->cell_log, s->mpu, linklayer);
+=09=09if ((sz >> s->size_log) > UINT16_MAX) {
+=09=09=09s->size_log++;
+=09=09=09goto again;
+=09=09}
+=09=09stab[i] =3D sz >> s->size_log;
+=09}
+
+=09s->cell_align =3D -1; // Due to the sz calc
+=09return s->cell_log;
+}
+
 int tc_core_init()
 {
 =09FILE *fp;
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 9f835e8..b82d2b8 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -7,8 +7,9 @@
 #define TIME_UNITS_PER_SEC=091000000
=20
 enum link_layer {
-=09LINKLAYER_ETHERNET=3D1,
-=09LINKLAYER_ATM     =3D2,
+=09LINKLAYER_UNSPEC,
+=09LINKLAYER_ETHERNET,
+=09LINKLAYER_ATM,
 };
=20
=20
@@ -21,6 +22,7 @@ unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09=09   int cell_log, unsigned mtu, enum link_layer link_layer);
+int tc_calc_size_table(struct tc_sizespec *s, __u16 *stab);
=20
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator=
 *est);
=20
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 1256f07..60388a4 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -32,12 +32,14 @@ static int usage(void)
 =09fprintf(stderr, "Usage: tc qdisc [ add | del | replace | change | show ]=
 dev STRING\n");
 =09fprintf(stderr, "       [ handle QHANDLE ] [ root | ingress | parent CLA=
SSID ]\n");
 =09fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
+=09fprintf(stderr, "       [ stab [ help | STAB_OPTIONS] ]\n");
 =09fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 =09fprintf(stderr, "\n");
 =09fprintf(stderr, "       tc qdisc show [ dev STRING ] [ingress]\n");
 =09fprintf(stderr, "Where:\n");
 =09fprintf(stderr, "QDISC_KIND :=3D { [p|b]fifo | tbf | prio | cbq | red | =
etc. }\n");
 =09fprintf(stderr, "OPTIONS :=3D ... try tc qdisc add <desired QDISC_KIND> =
help\n");
+=09fprintf(stderr, "STAB_OPTIONS :=3D ... try tc qdisc add stab help\n");
 =09return -1;
 }
=20
@@ -45,6 +47,10 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, ch=
ar **argv)
 {
 =09struct qdisc_util *q =3D NULL;
 =09struct tc_estimator est;
+=09struct {
+=09=09struct tc_sizespec=09szopts;
+=09=09__u16=09=09=09data[512];
+=09} stab;
 =09char  d[16];
 =09char  k[16];
 =09struct {
@@ -54,6 +60,7 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, cha=
r **argv)
 =09} req;
=20
 =09memset(&req, 0, sizeof(req));
+=09memset(&stab, 0, sizeof(stab));
 =09memset(&est, 0, sizeof(est));
 =09memset(&d, 0, sizeof(d));
 =09memset(&k, 0, sizeof(k));
@@ -108,6 +115,10 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, =
char **argv)
 =09=09} else if (matches(*argv, "estimator") =3D=3D 0) {
 =09=09=09if (parse_estimator(&argc, &argv, &est))
 =09=09=09=09return -1;
+=09=09} else if (matches(*argv, "stab") =3D=3D 0) {
+=09=09=09if (parse_size_table(&argc, &argv, &stab.szopts) < 0)
+=09=09=09=09return -1;
+=09=09=09continue;
 =09=09} else if (matches(*argv, "help") =3D=3D 0) {
 =09=09=09usage();
 =09=09} else {
@@ -142,6 +153,23 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, =
char **argv)
 =09=09}
 =09}
=20
+=09if (check_size_table_opts(&stab.szopts)) {
+=09=09struct rtattr *tail;
+
+=09=09if (tc_calc_size_table(&stab.szopts, stab.data) < 0) {
+=09=09=09fprintf(stderr, "failed to calculate size table.\n");
+=09=09=09return -1;
+=09=09}
+
+=09=09tail =3D NLMSG_TAIL(&req.n);
+=09=09addattr_l(&req.n, sizeof(req), TCA_STAB, NULL, 0);
+=09=09addattr_l(&req.n, sizeof(req), TCA_STAB_BASE, &stab.szopts,
+=09=09=09  sizeof(stab.szopts));
+=09=09addattr_l(&req.n, sizeof(req), TCA_STAB_DATA, stab.data,
+=09=09=09  TC_STAB_DATA_SIZE);
+=09=09tail->rta_len =3D (void *)NLMSG_TAIL(&req.n) - (void *)tail;
+=09}
+
 =09if (d[0])  {
 =09=09int idx;
=20
@@ -223,6 +251,10 @@ int print_qdisc(const struct sockaddr_nl *who,
 =09=09=09fprintf(fp, "[cannot parse qdisc parameters]");
 =09}
 =09fprintf(fp, "\n");
+=09if (tb[TCA_STAB]) {
+=09=09print_size_table(fp, " ", tb[TCA_STAB]);
+=09=09fprintf(fp, "\n");
+=09}
 =09if (show_stats) {
 =09=09struct rtattr *xstats =3D NULL;
=20
diff --git a/tc/tc_util.c b/tc/tc_util.c
index cd9dd59..8ec8ec2 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -435,7 +435,7 @@ int action_a2n(char *arg, int *result)
 =09return 0;
 }
=20
-int get_linklayer(unsigned int *val, const char *arg)
+int get_linklayer(unsigned *val, const char *arg)
 {
 =09int res;
=20
@@ -452,6 +452,30 @@ int get_linklayer(unsigned int *val, const char *arg)
 =09return 0;
 }
=20
+void print_linklayer(char *buf, int len, unsigned linklayer)
+{
+=09switch (linklayer) {
+=09case LINKLAYER_UNSPEC:
+=09=09snprintf(buf, len, "%s", "unspec");
+=09=09return;
+=09case LINKLAYER_ETHERNET:
+=09=09snprintf(buf, len, "%s", "ethernet");
+=09=09return;
+=09case LINKLAYER_ATM:
+=09=09snprintf(buf, len, "%s", "atm");
+=09=09return;
+=09default:
+=09=09snprintf(buf, len, "%s", "unknown");
+=09=09return;
+=09}
+}
+
+char *sprint_linklayer(unsigned linklayer, char *buf)
+{
+=09print_linklayer(buf, SPRINT_BSIZE-1, linklayer);
+=09return buf;
+}
+
 void print_tm(FILE * f, const struct tcf_t *tm)
 {
 =09int hz =3D get_user_hz();
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 796da54..c4a386c 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -57,6 +57,7 @@ extern void print_size(char *buf, int len, __u32 size);
 extern void print_percent(char *buf, int len, __u32 percent);
 extern void print_qdisc_handle(char *buf, int len, __u32 h);
 extern void print_time(char *buf, int len, __u32 time);
+extern void print_linklayer(char *buf, int len, unsigned linklayer);
 extern char * sprint_rate(__u32 rate, char *buf);
 extern char * sprint_size(__u32 size, char *buf);
 extern char * sprint_qdisc_handle(__u32 h, char *buf);
@@ -64,6 +65,7 @@ extern char * sprint_tc_classid(__u32 h, char *buf);
 extern char * sprint_time(__u32 time, char *buf);
 extern char * sprint_ticks(__u32 ticks, char *buf);
 extern char * sprint_percent(__u32 percent, char *buf);
+extern char * sprint_linklayer(unsigned linklayer, char *buf);
=20
 extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix,=
 struct rtattr **xstats);
 extern void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix,=
 struct rtattr **xstats);
--=_3kkghnsrny0w--

