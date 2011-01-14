From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.8)
Date: Fri, 14 Jan 2011 04:29:53 +0100
Message-ID: <1294975793.3403.117.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop>  <20110113153436.70d3c0a3@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46371 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab1AND36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 22:29:58 -0500
Received: by wyb28 with SMTP id 28so2434757wyb.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 19:29:57 -0800 (PST)
In-Reply-To: <20110113153436.70d3c0a3@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 15:34 -0800, Stephen Hemminger a =C3=A9=
crit :
> CHOKe ("CHOose and Kill" or "CHOose and Keep") is an alternative
> packet scheduler based on the Random Exponential Drop (RED) algorithm=
=2E
>=20
> The core idea is:
>   For every packet arrival:
>   	Calculate Qave
> 	if (Qave < minth)=20
> 	     Queue the new packet
> 	else=20
> 	     Select randomly a packet from the queue=20
> 	     if (both packets from same flow)
> 	     then Drop both the packets
> 	     else if (Qave > maxth)
> 	          Drop packet
> 	     else
> 	       	  Admit packet with probability P (same as RED)
>=20
> See also:
>   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a statele=
ss active
>    queue management scheme for approximating fair bandwidth allocatio=
n",=20
>   Proceeding of INFOCOM'2000, March 2000.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> 0.8 change queue length and holes account.
>     keep sch->q.qlen updated, and holes counter not needed.
>=20
> ---
>  net/sched/Kconfig     |   11 +
>  net/sched/Makefile    |    1=20
>  net/sched/sch_choke.c |  536 +++++++++++++++++++++++++++++++++++++++=
+++++++++++
>  3 files changed, 548 insertions(+)
>=20

Hi Stephen

Your diffstat was an old one, here the right one.

 include/linux/pkt_sched.h |   29 +
 net/sched/Kconfig         |   11=20
 net/sched/Makefile        |    1=20
 net/sched/sch_choke.c     |  552 ++++++++++++++++++++++++++++++++++++


I tested v8 and found several serious problems, please find a diff of m=
y
latest changes :

- wrong oskb/skb used in choke_enqueue()
- choke_zap_head_holes() is called from choke_dequeue() and crash if we
dequeued last packet. (!!!)
- out of bound access in choke_zap_tail_holes()
- choke_dequeue() can be shorter
- choke_change() must dequeue/drop in excess packets or risk new array
overfill (if we reduce queue limit by tc qdisc change ...)
- inline is not needed, space errors in include file

Thanks !

 include/linux/pkt_sched.h |    8 +++---
 net/sched/sch_choke.c     |   43 ++++++++++++++++++++++--------------
 2 files changed, 31 insertions(+), 20 deletions(-)

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
index 136d4e5..c710c57 100644
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
@@ -99,13 +99,13 @@ static struct sk_buff *choke_peek_random(struct Qdi=
sc *sch,
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
@@ -113,20 +113,21 @@ static inline int use_harddrop(const struct choke=
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
@@ -145,7 +146,7 @@ static void choke_drop_by_idx(struct choke_sched_da=
ta *q, unsigned int idx)
    2. fast internal classification
    3. use TC filter based classification
 */
-static inline unsigned int choke_classify(struct sk_buff *skb,
+static unsigned int choke_classify(struct sk_buff *skb,
 					  struct Qdisc *sch, int *qerr)
=20
 {
@@ -218,7 +219,7 @@ static int choke_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
 			/* Drop both packets */
 			q->stats.matched++;
 			choke_drop_by_idx(q, idx);
-			sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+			sch->qstats.backlog -=3D qdisc_pkt_len(oskb);
 			--sch->q.qlen;
 			qdisc_drop(oskb, sch);
 			goto congestion_drop;
@@ -285,8 +286,7 @@ static struct sk_buff *choke_dequeue(struct Qdisc *=
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
@@ -371,12 +371,23 @@ static int choke_change(struct Qdisc *sch, struct=
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


