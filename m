From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 10:12:02 +0100
Message-ID: <1325149922.2607.33.camel@edumazet-laptop>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	 <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	 <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	 <1324664907.2915.5.camel@edumazet-laptop>
	 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
	 <1324668083.2915.15.camel@edumazet-laptop>
	 <1325132760.2607.15.camel@edumazet-laptop>
	 <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64005 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab1L2JMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 04:12:08 -0500
Received: by vbbfc26 with SMTP id fc26so10108734vbb.19
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 01:12:07 -0800 (PST)
In-Reply-To: <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 d=C3=A9cembre 2011 =C3=A0 22:17 -0800, Stephen Hemminger=
 a =C3=A9crit :
> On Thu, 29 Dec 2011 05:26:00 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Commit 10f6dfcfde (Revert "sch_netem: Remove classful functionality=
")
> > reintroduced classful functionality to netem, but broke basic netem
> > behavior :
> >=20
> > netem uses an t(ime)fifo queue, and store timestamps in skb->cb[]
> >=20
> > If qdisc is changed, time constraints are not respected and other q=
disc
> > can destroy skb->cb[] and block netem at dequeue time.
> >=20
> > Fix this by always using internal tfifo, and optionally attach a ch=
ild
> > qdisc to netem.
> >=20
> > Example of use :
> >=20
> > DEV=3Deth3
> > tc qdisc del dev $DEV root
> > tc qdisc add dev $DEV root handle 30: est 1sec 8sec netem delay 20m=
s 10ms
> > tc qdisc add dev $DEV parent 30:0 sfq
>=20
> Does it work with TBF which is a more useful option?
>=20

Yes :

tc qdisc add dev $DEV root handle 30:0 est 1sec 8sec netem \
	delay 20ms 10ms
tc qdisc add dev $DEV handle 40:0 parent 30:0 tbf \
	burst 20480 limit 20480 mtu 1514 rate 32000bps


qdisc netem 30: root refcnt 18 limit 1000 delay 20.0ms  10.0ms
 Sent 190792 bytes 413 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 18416bit 3pps backlog 0b 0p requeues 0=20
qdisc tbf 40: parent 30: rate 256000bit burst 20Kb/8 mpu 0b lat 0us=20
 Sent 190792 bytes 413 pkt (dropped 6, overlimits 10 requeues 0)=20
 backlog 0b 5p requeues 0=20

> Also, the whole tfifo idea is only to support the wierd idea that
> if doing random delay that packets should get reordered based on the
> results of the random value; it was an behavior some users wanted
> because that is what NISTnet did.

tfifo supports a time ordered queuing, wich mimics some jitter in the
network. This seems quite useful.

I see what you suggest : adding 'time_to_send' in the generic qdisc cb.

But it makes no sense if we attach a reordering qdisc, like SFQ :
A 'high prio' packet will block the whole netem because we'll have to
throttle since this packet time_to_send will be in the future, while
many other elligible packets are in queue.

In the case no jitter is asked to netem, we directly enqueue at the
queue tail with no extra cost, since we need to access last skb in queu=
e
to perform the qdisc_enqueue_tail()

I am sending a v2 because of two lines I inadvertently removed in the c=
ase
we queue the new packet at the head of tfifo. (allowing to bypass the
sch->limit check... I'll send a separate patch to add this check)

Thanks

[PATCH v2 net-next] netem: fix classful handling

Commit 10f6dfcfde (Revert "sch_netem: Remove classful functionality")
reintroduced classful functionality to netem, but broke basic netem
behavior :

netem uses an t(ime)fifo queue, and store timestamps in skb->cb[]

If qdisc is changed, time constraints are not respected and other qdisc
can destroy skb->cb[] and block netem at dequeue time.

=46ix this by always using internal tfifo, and optionally attach a chil=
d
qdisc to netem (or a tree of qdiscs)

Example of use :

DEV=3Deth3
tc qdisc del dev $DEV root
tc qdisc add dev $DEV root handle 30: est 1sec 8sec netem delay 20ms 10=
ms
tc qdisc add dev $DEV handle 40:0 parent 30:0 tbf \
	burst 20480 limit 20480 mtu 1514 rate 32000bps


qdisc netem 30: root refcnt 18 limit 1000 delay 20.0ms  10.0ms
 Sent 190792 bytes 413 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 18416bit 3pps backlog 0b 0p requeues 0=20
qdisc tbf 40: parent 30: rate 256000bit burst 20Kb/8 mpu 0b lat 0us=20
 Sent 190792 bytes 413 pkt (dropped 6, overlimits 10 requeues 0)=20
 backlog 0b 5p requeues 0=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 net/sched/sch_netem.c |  202 ++++++++++++++++------------------------
 1 file changed, 81 insertions(+), 121 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index ffcaa59..1e611cb 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -67,7 +67,11 @@
 */
=20
 struct netem_sched_data {
+	/* internal t(ime)fifo qdisc uses sch->q and sch->limit */
+
+	/* optional qdisc for classful handling (NULL at netem init) */
 	struct Qdisc	*qdisc;
+
 	struct qdisc_watchdog watchdog;
=20
 	psched_tdiff_t latency;
@@ -117,7 +121,9 @@ struct netem_sched_data {
=20
 };
=20
-/* Time stamp put into socket buffer control block */
+/* Time stamp put into socket buffer control block
+ * Only valid when skbs are in our internal t(ime)fifo queue.
+ */
 struct netem_skb_cb {
 	psched_time_t	time_to_send;
 };
@@ -324,6 +330,31 @@ static psched_time_t packet_len_2_sched_time(unsig=
ned int len, struct netem_sche
 	return PSCHED_NS2TICKS(ticks);
 }
=20
+static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
+{
+	struct sk_buff_head *list =3D &sch->q;
+	psched_time_t tnext =3D netem_skb_cb(nskb)->time_to_send;
+	struct sk_buff *skb;
+
+	if (likely(skb_queue_len(list) < sch->limit)) {
+		skb =3D skb_peek_tail(list);
+		/* Optimize for add at tail */
+		if (likely(!skb || tnext >=3D netem_skb_cb(skb)->time_to_send))
+			return qdisc_enqueue_tail(nskb, sch);
+
+		skb_queue_reverse_walk(list, skb) {
+			if (tnext >=3D netem_skb_cb(skb)->time_to_send)
+				break;
+		}
+
+		__skb_queue_after(list, skb, nskb);
+		sch->qstats.backlog +=3D qdisc_pkt_len(nskb);
+		return NET_XMIT_SUCCESS;
+	}
+
+	return qdisc_reshape_fail(nskb, sch);
+}
+
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -399,7 +430,7 @@ static int netem_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
 		now =3D psched_get_time();
=20
 		if (q->rate) {
-			struct sk_buff_head *list =3D &q->qdisc->q;
+			struct sk_buff_head *list =3D &sch->q;
=20
 			delay +=3D packet_len_2_sched_time(skb->len, q);
=20
@@ -417,7 +448,7 @@ static int netem_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
=20
 		cb->time_to_send =3D now + delay;
 		++q->counter;
-		ret =3D qdisc_enqueue(skb, q->qdisc);
+		ret =3D tfifo_enqueue(skb, sch);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
@@ -426,7 +457,7 @@ static int netem_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
 		cb->time_to_send =3D psched_get_time();
 		q->counter =3D 0;
=20
-		__skb_queue_head(&q->qdisc->q, skb);
+		__skb_queue_head(&sch->q, skb);
 		q->qdisc->qstats.backlog +=3D qdisc_pkt_len(skb);
 		q->qdisc->qstats.requeues++;
 		ret =3D NET_XMIT_SUCCESS;
@@ -439,19 +470,20 @@ static int netem_enqueue(struct sk_buff *skb, str=
uct Qdisc *sch)
 		}
 	}
=20
-	sch->q.qlen++;
 	return NET_XMIT_SUCCESS;
 }
=20
 static unsigned int netem_drop(struct Qdisc *sch)
 {
 	struct netem_sched_data *q =3D qdisc_priv(sch);
-	unsigned int len =3D 0;
+	unsigned int len;
=20
-	if (q->qdisc->ops->drop && (len =3D q->qdisc->ops->drop(q->qdisc)) !=3D=
 0) {
-		sch->q.qlen--;
+	len =3D qdisc_queue_drop(sch);
+	if (!len && q->qdisc && q->qdisc->ops->drop)
+	    len =3D q->qdisc->ops->drop(q->qdisc);
+	if (len)
 		sch->qstats.drops++;
-	}
+
 	return len;
 }
=20
@@ -463,16 +495,16 @@ static struct sk_buff *netem_dequeue(struct Qdisc=
 *sch)
 	if (qdisc_is_throttled(sch))
 		return NULL;
=20
-	skb =3D q->qdisc->ops->peek(q->qdisc);
+tfifo_dequeue:
+	skb =3D qdisc_peek_head(sch);
 	if (skb) {
 		const struct netem_skb_cb *cb =3D netem_skb_cb(skb);
-		psched_time_t now =3D psched_get_time();
=20
 		/* if more time remaining? */
-		if (cb->time_to_send <=3D now) {
-			skb =3D qdisc_dequeue_peeked(q->qdisc);
+		if (cb->time_to_send <=3D psched_get_time()) {
+			skb =3D qdisc_dequeue_tail(sch);
 			if (unlikely(!skb))
-				return NULL;
+				goto qdisc_dequeue;
=20
 #ifdef CONFIG_NET_CLS_ACT
 			/*
@@ -483,15 +515,37 @@ static struct sk_buff *netem_dequeue(struct Qdisc=
 *sch)
 				skb->tstamp.tv64 =3D 0;
 #endif
=20
-			sch->q.qlen--;
+			if (q->qdisc) {
+				int err =3D qdisc_enqueue(skb, q->qdisc);
+
+				if (unlikely(err !=3D NET_XMIT_SUCCESS)) {
+					if (net_xmit_drop_count(err)) {
+						sch->qstats.drops++;
+						qdisc_tree_decrease_qlen(sch, 1);
+					}
+				}
+				goto tfifo_dequeue;
+			}
+deliver:
 			qdisc_unthrottled(sch);
 			qdisc_bstats_update(sch, skb);
 			return skb;
 		}
=20
+		if (q->qdisc) {
+			skb =3D q->qdisc->ops->dequeue(q->qdisc);
+			if (skb)
+				goto deliver;
+		}
 		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 	}
=20
+qdisc_dequeue:
+	if (q->qdisc) {
+		skb =3D q->qdisc->ops->dequeue(q->qdisc);
+		if (skb)
+			goto deliver;
+	}
 	return NULL;
 }
=20
@@ -499,8 +553,9 @@ static void netem_reset(struct Qdisc *sch)
 {
 	struct netem_sched_data *q =3D qdisc_priv(sch);
=20
-	qdisc_reset(q->qdisc);
-	sch->q.qlen =3D 0;
+	qdisc_reset_queue(sch);
+	if (q->qdisc)
+		qdisc_reset(q->qdisc);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
=20
@@ -689,11 +744,7 @@ static int netem_change(struct Qdisc *sch, struct =
nlattr *opt)
 	if (ret < 0)
 		return ret;
=20
-	ret =3D fifo_set_limit(q->qdisc, qopt->limit);
-	if (ret) {
-		pr_info("netem: can't set fifo limit\n");
-		return ret;
-	}
+	sch->limit =3D qopt->limit;
=20
 	q->latency =3D qopt->latency;
 	q->jitter =3D qopt->jitter;
@@ -734,88 +785,6 @@ static int netem_change(struct Qdisc *sch, struct =
nlattr *opt)
 	return ret;
 }
=20
-/*
- * Special case version of FIFO queue for use by netem.
- * It queues in order based on timestamps in skb's
- */
-struct fifo_sched_data {
-	u32 limit;
-	psched_time_t oldest;
-};
-
-static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
-{
-	struct fifo_sched_data *q =3D qdisc_priv(sch);
-	struct sk_buff_head *list =3D &sch->q;
-	psched_time_t tnext =3D netem_skb_cb(nskb)->time_to_send;
-	struct sk_buff *skb;
-
-	if (likely(skb_queue_len(list) < q->limit)) {
-		/* Optimize for add at tail */
-		if (likely(skb_queue_empty(list) || tnext >=3D q->oldest)) {
-			q->oldest =3D tnext;
-			return qdisc_enqueue_tail(nskb, sch);
-		}
-
-		skb_queue_reverse_walk(list, skb) {
-			const struct netem_skb_cb *cb =3D netem_skb_cb(skb);
-
-			if (tnext >=3D cb->time_to_send)
-				break;
-		}
-
-		__skb_queue_after(list, skb, nskb);
-
-		sch->qstats.backlog +=3D qdisc_pkt_len(nskb);
-
-		return NET_XMIT_SUCCESS;
-	}
-
-	return qdisc_reshape_fail(nskb, sch);
-}
-
-static int tfifo_init(struct Qdisc *sch, struct nlattr *opt)
-{
-	struct fifo_sched_data *q =3D qdisc_priv(sch);
-
-	if (opt) {
-		struct tc_fifo_qopt *ctl =3D nla_data(opt);
-		if (nla_len(opt) < sizeof(*ctl))
-			return -EINVAL;
-
-		q->limit =3D ctl->limit;
-	} else
-		q->limit =3D max_t(u32, qdisc_dev(sch)->tx_queue_len, 1);
-
-	q->oldest =3D PSCHED_PASTPERFECT;
-	return 0;
-}
-
-static int tfifo_dump(struct Qdisc *sch, struct sk_buff *skb)
-{
-	struct fifo_sched_data *q =3D qdisc_priv(sch);
-	struct tc_fifo_qopt opt =3D { .limit =3D q->limit };
-
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
-	return skb->len;
-
-nla_put_failure:
-	return -1;
-}
-
-static struct Qdisc_ops tfifo_qdisc_ops __read_mostly =3D {
-	.id		=3D	"tfifo",
-	.priv_size	=3D	sizeof(struct fifo_sched_data),
-	.enqueue	=3D	tfifo_enqueue,
-	.dequeue	=3D	qdisc_dequeue_head,
-	.peek		=3D	qdisc_peek_head,
-	.drop		=3D	qdisc_queue_drop,
-	.init		=3D	tfifo_init,
-	.reset		=3D	qdisc_reset_queue,
-	.change		=3D	tfifo_init,
-	.dump		=3D	tfifo_dump,
-};
-
 static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q =3D qdisc_priv(sch);
@@ -827,18 +796,9 @@ static int netem_init(struct Qdisc *sch, struct nl=
attr *opt)
 	qdisc_watchdog_init(&q->watchdog, sch);
=20
 	q->loss_model =3D CLG_RANDOM;
-	q->qdisc =3D qdisc_create_dflt(sch->dev_queue, &tfifo_qdisc_ops,
-				     TC_H_MAKE(sch->handle, 1));
-	if (!q->qdisc) {
-		pr_notice("netem: qdisc create tfifo qdisc failed\n");
-		return -ENOMEM;
-	}
-
 	ret =3D netem_change(sch, opt);
-	if (ret) {
+	if (ret)
 		pr_info("netem: change failed\n");
-		qdisc_destroy(q->qdisc);
-	}
 	return ret;
 }
=20
@@ -847,7 +807,8 @@ static void netem_destroy(struct Qdisc *sch)
 	struct netem_sched_data *q =3D qdisc_priv(sch);
=20
 	qdisc_watchdog_cancel(&q->watchdog);
-	qdisc_destroy(q->qdisc);
+	if (q->qdisc)
+		qdisc_destroy(q->qdisc);
 	dist_free(q->delay_dist);
 }
=20
@@ -951,7 +912,7 @@ static int netem_dump_class(struct Qdisc *sch, unsi=
gned long cl,
 {
 	struct netem_sched_data *q =3D qdisc_priv(sch);
=20
-	if (cl !=3D 1) 	/* only one class */
+	if (cl !=3D 1 || !q->qdisc) 	/* only one class */
 		return -ENOENT;
=20
 	tcm->tcm_handle |=3D TC_H_MIN(1);
@@ -965,14 +926,13 @@ static int netem_graft(struct Qdisc *sch, unsigne=
d long arg, struct Qdisc *new,
 {
 	struct netem_sched_data *q =3D qdisc_priv(sch);
=20
-	if (new =3D=3D NULL)
-		new =3D &noop_qdisc;
-
 	sch_tree_lock(sch);
 	*old =3D q->qdisc;
 	q->qdisc =3D new;
-	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-	qdisc_reset(*old);
+	if (*old) {
+		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+		qdisc_reset(*old);
+	}
 	sch_tree_unlock(sch);
=20
 	return 0;
