From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.8)
Date: Fri, 14 Jan 2011 04:58:18 +0100
Message-ID: <1294977498.3403.127.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop>  <20110113153436.70d3c0a3@s6510>
	 <1294975793.3403.117.camel@edumazet-laptop>
	 <1294976067.3403.118.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49072 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757115Ab1AND6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 22:58:24 -0500
Received: by wwa36 with SMTP id 36so2582358wwa.1
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 19:58:23 -0800 (PST)
In-Reply-To: <1294976067.3403.118.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 04:34 +0100, Eric Dumazet a =C3=A9cr=
it :

> Hmm, please wait a bit, I had another crash when I stopped my
> bench/stress

I am not sure p->qavg is correctly computed.

Crash happened because choke_peek_random() was called while no packet
was in queue.

With my params (min=3D10833 max=3D32500 burst=3D18055 limit=3D130000) t=
his
implies qavg was very big while qlen=3D=3D0 !

qdisc choke 11: dev ifb0 parent 1:11 limit 130000b min 10833b max 32500=
b ewma 13 Plog 21 Scell_log 30
 Sent 200857857 bytes 365183 pkt (dropped 1010937, overlimits 557577 re=
queues 0)=20
 rate 32253Kbit 7330pps backlog 17875996b 32505p requeues 0=20
  marked 0 early 557577 pdrop 0 other 0 matched 226680


Here is latest diff :

 include/linux/pkt_sched.h |    8 +++----
 net/sched/sch_choke.c     |   50 +++++++++++++++++++++++++++++--------=
---------
 2 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 83bac92..498c798 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -269,10 +269,10 @@ struct tc_choke_qopt {
 };
=20
 struct tc_choke_xstats {
-	__u32           early;          /* Early drops */
-	__u32           pdrop;          /* Drops due to queue limits */
-	__u32           other;          /* Drops due to drop() calls */
-	__u32           marked;         /* Marked packets */
+	__u32		early;          /* Early drops */
+	__u32		pdrop;          /* Drops due to queue limits */
+	__u32		other;          /* Drops due to drop() calls */
+	__u32		marked;         /* Marked packets */
 	__u32		matched;	/* Drops due to flow match */
 };
=20
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 136d4e5..2f94dad 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -74,7 +74,7 @@ struct choke_sched_data {
 };
=20
 /* deliver a random number between 0 and N - 1 */
-static inline u32 random_N(unsigned int N)
+static u32 random_N(unsigned int N)
 {
 	return reciprocal_divide(random32(), N);
 }
@@ -94,18 +94,20 @@ static struct sk_buff *choke_peek_random(struct Qdi=
sc *sch,
 			return skb;
 	} while (--retrys > 0);
=20
-	/* queue is has lots of holes use the head which is known to exist */
+	/* queue is has lots of holes use the head which is known to exist
+	 * Note : result can still be NULL if q->head =3D=3D q->tail
+	 */
 	return q->tab[*pidx =3D q->head];
 }
=20
 /* Is ECN parameter configured */
-static inline int use_ecn(const struct choke_sched_data *q)
+static int use_ecn(const struct choke_sched_data *q)
 {
 	return q->flags & TC_RED_ECN;
 }
=20
 /* Should packets over max just be dropped (versus marked) */
-static inline int use_harddrop(const struct choke_sched_data *q)
+static int use_harddrop(const struct choke_sched_data *q)
 {
 	return q->flags & TC_RED_HARDDROP;
 }
@@ -113,20 +115,21 @@ static inline int use_harddrop(const struct choke=
_sched_data *q)
 /* Move head pointer forward to skip over holes */
 static void choke_zap_head_holes(struct choke_sched_data *q)
 {
-	while (q->tab[q->head] =3D=3D NULL) {
+	do {
 		q->head =3D (q->head + 1) & q->tab_mask;
-
-		BUG_ON(q->head =3D=3D q->tail);
-	}
+		if (q->head =3D=3D q->tail)
+			break;
+	} while (q->tab[q->head] =3D=3D NULL);
 }
=20
 /* Move tail pointer backwards to reuse holes */
 static void choke_zap_tail_holes(struct choke_sched_data *q)
 {
-	while (q->tab[q->tail - 1] =3D=3D NULL) {
+	do {
 		q->tail =3D (q->tail - 1) & q->tab_mask;
-		BUG_ON(q->head =3D=3D q->tail);
-	}
+		if (q->head =3D=3D q->tail)
+			break;
+	} while (q->tab[q->tail] =3D=3D NULL);
 }
=20
 /* Drop packet from queue array by creating a "hole" */
@@ -145,7 +148,7 @@ static void choke_drop_by_idx(struct choke_sched_da=
ta *q, unsigned int idx)
    2. fast internal classification
    3. use TC filter based classification
 */
-static inline unsigned int choke_classify(struct sk_buff *skb,
+static unsigned int choke_classify(struct sk_buff *skb,
 					  struct Qdisc *sch, int *qerr)
=20
 {
@@ -214,11 +217,12 @@ static int choke_enqueue(struct sk_buff *skb, str=
uct Qdisc *sch)
 		oskb =3D choke_peek_random(sch, &idx);
=20
 		/* Both packets from same flow ? */
-		if (*(unsigned int *)(qdisc_skb_cb(oskb)->data) =3D=3D hash) {
+		if (oskb &&
+		    *(unsigned int *)(qdisc_skb_cb(oskb)->data) =3D=3D hash) {
 			/* Drop both packets */
 			q->stats.matched++;
 			choke_drop_by_idx(q, idx);
-			sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+			sch->qstats.backlog -=3D qdisc_pkt_len(oskb);
 			--sch->q.qlen;
 			qdisc_drop(oskb, sch);
 			goto congestion_drop;
@@ -285,8 +289,7 @@ static struct sk_buff *choke_dequeue(struct Qdisc *=
sch)
 	}
=20
 	skb =3D q->tab[q->head];
-	q->tab[q->head] =3D NULL; /* not really needed */
-	q->head =3D (q->head + 1) & q->tab_mask;
+	q->tab[q->head] =3D NULL;
 	choke_zap_head_holes(q);
 	--sch->q.qlen;
 	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
@@ -371,12 +374,23 @@ static int choke_change(struct Qdisc *sch, struct=
 nlattr *opt)
 		sch_tree_lock(sch);
 		old =3D q->tab;
 		if (old) {
-			unsigned int tail =3D 0;
+			unsigned int oqlen =3D sch->q.qlen, tail =3D 0;
=20
 			while (q->head !=3D q->tail) {
-				ntab[tail++] =3D q->tab[q->head];
+				struct sk_buff *skb =3D q->tab[q->head];
+
 				q->head =3D (q->head + 1) & q->tab_mask;
+				if (!skb)
+					continue;
+				if (tail < mask) {
+					ntab[tail++] =3D skb;
+					continue;
+				}
+				sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+				--sch->q.qlen;
+				qdisc_drop(skb, sch);
 			}
+			qdisc_tree_decrease_qlen(sch, oqlen - sch->q.qlen);
 			q->head =3D 0;
 			q->tail =3D tail;
 		}


