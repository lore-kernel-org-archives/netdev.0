From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: add additional lock to qdisc to increase throughput
Date: Fri, 21 May 2010 17:08:00 +0200
Message-ID: <1274454480.2439.418.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48225 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627Ab0EUPIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 11:08:07 -0400
Received: by fxm5 with SMTP id 5so937660fxm.19
        for <netdev@vger.kernel.org>; Fri, 21 May 2010 08:08:04 -0700 (PDT)
In-Reply-To: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 13:25 -0700, Alexander Duyck a =C3=A9crit =
:
> The qdisc layer shows a significant issue when you start transmitting=
 from
> multiple CPUs.  The issue is that the transmit rate drops significant=
ly, and I
> believe it is due to the fact that the spinlock is shared between the=
 1
> dequeue, and n-1 enqueue cpu threads.  In order to improve this situa=
tion I am
> adding one additional lock which will need to be obtained during the =
enqueue
> portion of the path.  This essentially allows sch_direct_xmit to jump=
 to
> near the head of the line when attempting to obtain the lock after
> completing a transmit.
>=20
> Running the script below I saw an increase from 200K packets per seco=
nd to
> 1.07M packets per second as a result of this patch.
>=20
> for j in `seq 0 15`; do
> 	for i in `seq 0 7`; do
> 		netperf -H <ip> -t UDP_STREAM -l 600 -N -T $i -- -m 6 &
> 	done
> done
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>=20
>  include/net/sch_generic.h |    3 ++-
>  net/core/dev.c            |    7 ++++++-
>  net/sched/sch_generic.c   |    1 +
>  3 files changed, 9 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 67dc08e..f5088a9 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -51,7 +51,6 @@ struct Qdisc {
>  	struct list_head	list;
>  	u32			handle;
>  	u32			parent;
> -	atomic_t		refcnt;
>  	struct gnet_stats_rate_est	rate_est;
>  	int			(*reshape_fail)(struct sk_buff *skb,
>  					struct Qdisc *q);
> @@ -65,6 +64,8 @@ struct Qdisc {
>  	struct netdev_queue	*dev_queue;
>  	struct Qdisc		*next_sched;
> =20
> +	atomic_t		refcnt;
> +	spinlock_t		enqueue_lock;
>  	struct sk_buff		*gso_skb;
>  	/*
>  	 * For performance sake on SMP, we put highly modified fields at th=
e end
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a03aab4..8a2d508 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2006,8 +2006,10 @@ static inline int __dev_xmit_skb(struct sk_buf=
f *skb, struct Qdisc *q,
>  	spinlock_t *root_lock =3D qdisc_lock(q);
>  	int rc;
> =20
> +	spin_lock(&q->enqueue_lock);
>  	spin_lock(root_lock);
>  	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> +		spin_unlock(&q->enqueue_lock);
>  		kfree_skb(skb);
>  		rc =3D NET_XMIT_DROP;
>  	} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
> @@ -2018,7 +2020,9 @@ static inline int __dev_xmit_skb(struct sk_buff=
 *skb, struct Qdisc *q,
>  		 * xmit the skb directly.
>  		 */
>  		__qdisc_update_bstats(q, skb->len);
> -		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
> +		spin_unlock(&q->enqueue_lock);
> +		rc =3D sch_direct_xmit(skb, q, dev, txq, root_lock);
> +		if (rc)
>  			__qdisc_run(q);
>  		else
>  			clear_bit(__QDISC_STATE_RUNNING, &q->state);
> @@ -2026,6 +2030,7 @@ static inline int __dev_xmit_skb(struct sk_buff=
 *skb, struct Qdisc *q,
>  		rc =3D NET_XMIT_SUCCESS;
>  	} else {
>  		rc =3D qdisc_enqueue_root(skb, q);
> +		spin_unlock(&q->enqueue_lock);
>  		qdisc_run(q);
>  	}
>  	spin_unlock(root_lock);
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 5173c1e..4b5e125 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -538,6 +538,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *de=
v_queue,
>  	sch =3D (struct Qdisc *) QDISC_ALIGN((unsigned long) p);
>  	sch->padded =3D (char *) sch - (char *) p;
> =20
> +	spin_lock_init(&sch->enqueue_lock);
>  	INIT_LIST_HEAD(&sch->list);
>  	skb_queue_head_init(&sch->q);
>  	sch->ops =3D ops;
>=20

Hi Alexander

What about following patch instead, adding an heuristic to avoid an
extra atomic operation in fast path ?

I also try to release the 'busylock' after the main lock to favor the
worker as much as possible. It must be released before main lock only
before a call to __qdisc_run()

Another refinement would be to make the spinning done outside of BH
disabled context, because we currently delay TX completion (if NAPI is
used by driver) that can make room in device TX ring buffer. This would
allow cpus to process incoming traffic too...

Thanks

[PATCH] net: add additional lock to qdisc to increase throughput

When many cpus compete for sending frames on a given qdisc, the qdisc
spinlock suffers from very high contention.

The cpu owning __QDISC_STATE_RUNNING bit has same priority to acquire
the lock, and cannot dequeue packets fast enough, since it must wait fo=
r
this lock for each dequeued packet.

One solution to this problem is to force all cpus spinning on a second
lock before trying to get the main lock, when/if they see
__QDISC_STATE_RUNNING already set.

The owning cpu then compete with at most one other cpu for the main
lock, allowing for higher dequeueing rate.

Based on a previous patch from Alexander Duyck. I added the heuristic t=
o
avoid the atomic in fast path, and put the new lock far away from the
cache line used by the dequeue worker. Also try to release the busylock
lock as late as possible.

Tests with following script gave a boost from ~50.000 pps to ~600.000
pps on a dual quad core machine (E5450 @3.00GHz), tg3 driver.
(A single netperf flow can reach ~800.000 pps on this platform)

for j in `seq 0 3`; do
  for i in `seq 0 7`; do
    netperf -H 192.168.0.1 -t UDP_STREAM -l 60 -N -T $i -- -m 6 &
  done
done


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sch_generic.h |    3 ++-
 net/core/dev.c            |   29 +++++++++++++++++++++++++----
 net/sched/sch_generic.c   |    1 +
 3 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 03ca5d8..2d55649 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -73,7 +73,8 @@ struct Qdisc {
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue	qstats;
-	struct rcu_head     rcu_head;
+	struct rcu_head		rcu_head;
+	spinlock_t		busylock;
 };
=20
 struct Qdisc_class_ops {
diff --git a/net/core/dev.c b/net/core/dev.c
index 6c82065..1b313eb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2040,6 +2040,16 @@ static inline int __dev_xmit_skb(struct sk_buff =
*skb, struct Qdisc *q,
 {
 	spinlock_t *root_lock =3D qdisc_lock(q);
 	int rc;
+	bool contended =3D test_bit(__QDISC_STATE_RUNNING, &q->state);
+
+	/*
+	 * Heuristic to force contended enqueues to serialize on a
+	 * separate lock before trying to get qdisc main lock.
+	 * This permits __QDISC_STATE_RUNNING owner to get the lock more ofte=
n
+	 * and dequeue packets faster.
+	 */
+	if (unlikely(contended))
+		spin_lock(&q->busylock);
=20
 	spin_lock(root_lock);
 	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
@@ -2055,19 +2065,30 @@ static inline int __dev_xmit_skb(struct sk_buff=
 *skb, struct Qdisc *q,
 		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
 			skb_dst_force(skb);
 		__qdisc_update_bstats(q, skb->len);
-		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
+		if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
+			if (unlikely(contended)) {
+				spin_unlock(&q->busylock);
+				contended =3D false;
+			}
 			__qdisc_run(q);
-		else
+		} else
 			clear_bit(__QDISC_STATE_RUNNING, &q->state);
=20
 		rc =3D NET_XMIT_SUCCESS;
 	} else {
 		skb_dst_force(skb);
 		rc =3D qdisc_enqueue_root(skb, q);
-		qdisc_run(q);
+		if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
+			if (unlikely(contended)) {
+				spin_unlock(&q->busylock);
+				contended =3D false;
+			}
+			__qdisc_run(q);
+		}
 	}
 	spin_unlock(root_lock);
-
+	if (unlikely(contended))
+		spin_unlock(&q->busylock);
 	return rc;
 }
=20
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a63029e..0a44290 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -543,6 +543,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_=
queue,
=20
 	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
+	spin_lock_init(&sch->busylock);
 	sch->ops =3D ops;
 	sch->enqueue =3D ops->enqueue;
 	sch->dequeue =3D ops->dequeue;



