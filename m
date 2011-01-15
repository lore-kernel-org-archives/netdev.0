From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.9)
Date: Sat, 15 Jan 2011 08:45:42 +0100
Message-ID: <1295077542.3977.20.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510>
	 <4D305598.1010207@trash.net> <4D3055C2.3060807@trash.net>
	 <1295015043.3937.20.camel@edumazet-laptop>
	 <20110114154521.54cc8ef5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51312 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986Ab1AOHpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 02:45:50 -0500
Received: by wwa36 with SMTP id 36so3805781wwa.1
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 23:45:48 -0800 (PST)
In-Reply-To: <20110114154521.54cc8ef5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 15:45 -0800, Stephen Hemminger a =C3=
=A9crit :
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
> 	       	  Admit packet with proability p (same as RED)
>=20
> See also:
>   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a statele=
ss active
>    queue management scheme for approximating fair bandwidth allocatio=
n",=20
>   Proceeding of INFOCOM'2000, March 2000.
>=20
> Help from:
>      Eric Dumazet <eric.dumazet@gmail.com>
>      Patrick McHardy <kaber@trash.net>
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> This version is based on net-next, and assumes Eric's patch for
> corrected bstats is already applied.
>=20
> 0.9 incorporate patches from Patrick/Eric
>     rework the peek_random and drop code to simplify and fix bug wher=
e
>     random_N needs to called with full length (including holes).

Nice catch, I now have more "matched" counts after my test :

qdisc choke 11: parent 1:11 limit 130000b min 10833b max 32500b ewma 13=
 Plog 21 Scell_log 30
 Sent 93944198 bytes 170889 pkt (dropped 829140, overlimits 436686 requ=
eues 0)=20
 rate 48bit 0pps backlog 0b 0p requeues 0=20
  marked 0 early 436686 pdrop 0 other 0 matched 196227

You missed the qdisc_bstats_update() move from enqueue() to dequeue()

And some minor CodingStyle / checkpatch.pl changes, here is my
latest diff on top of 0.9

I believe you can release v1 :)

Thanks !

 net/sched/sch_choke.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 55eeb7d..a7605a0 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -20,7 +20,7 @@
 #include <net/red.h>
=20
 /*	CHOKe stateless AQM for fair bandwidth allocation
-        =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
=20
    CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
    unresponsive flows) is a variant of RED that penalizes misbehaving =
flows but
@@ -137,10 +137,10 @@ static void choke_drop_by_idx(struct Qdisc *sch, =
unsigned int idx)
 }
=20
 /* Classify flow using either:
-   1. pre-existing classification result in skb
-   2. fast internal classification
-   3. use TC filter based classification
-*/
+ * 1. pre-existing classification result in skb
+ * 2. fast internal classification (rxhash)
+ * 3. use TC filter based classification
+ */
 static unsigned int choke_classify(struct sk_buff *skb,
 				   struct Qdisc *sch, int *qerr)
=20
@@ -176,10 +176,9 @@ static unsigned int choke_classify(struct sk_buff =
*skb,
 }
=20
 /* Select a packet at random from the queue and return flow classifica=
tion
-   returns 0 if queue empty
+ * returns 0 if queue empty
  */
-static unsigned int choke_peek_random(struct Qdisc *sch,
-				      unsigned int *pidx)
+static unsigned int choke_peek_random(struct Qdisc *sch, unsigned int =
*pidx)
 {
 	struct choke_sched_data *q =3D qdisc_priv(sch);
 	const struct sk_buff *skb;
@@ -229,9 +228,9 @@ static int choke_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
 		red_end_of_idle_period(p);
=20
 	/* Is queue small? */
-	if (p->qavg <=3D p->qth_min)
+	if (p->qavg <=3D p->qth_min) {
 		p->qcount =3D -1;
-	else {
+	} else {
 		unsigned int idx;
=20
 		/* Draw a packet at random from queue and compare flow */
@@ -266,8 +265,9 @@ static int choke_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
=20
 				q->stats.prob_mark++;
 			}
-		} else
+		} else {
 			p->qR =3D red_random(p);
+		}
 	}
=20
 	/* Admit new packet */
@@ -276,7 +276,6 @@ static int choke_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
 		q->tail =3D (q->tail + 1) & q->tab_mask;
 		++sch->q.qlen;
 		sch->qstats.backlog +=3D qdisc_pkt_len(skb);
-		qdisc_bstats_update(sch, skb);
 		return NET_XMIT_SUCCESS;
 	}
=20
@@ -306,6 +305,7 @@ static struct sk_buff *choke_dequeue(struct Qdisc *=
sch)
 	choke_zap_head_holes(q);
 	--sch->q.qlen;
 	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+	qdisc_bstats_update(sch, skb);
=20
 	return skb;
 }
@@ -316,9 +316,9 @@ static unsigned int choke_drop(struct Qdisc *sch)
 	unsigned int len;
=20
 	len =3D qdisc_queue_drop(sch);
-	if (len > 0)
+	if (len > 0) {
 		q->stats.other++;
-	else {
+	} else {
 		if (!red_is_idling(&q->parms))
 			red_start_of_idle_period(&q->parms);
 	}
@@ -326,7 +326,7 @@ static unsigned int choke_drop(struct Qdisc *sch)
 	return len;
 }
=20
-static void choke_reset(struct Qdisc* sch)
+static void choke_reset(struct Qdisc *sch)
 {
 	struct choke_sched_data *q =3D qdisc_priv(sch);
=20
@@ -410,8 +410,9 @@ static int choke_change(struct Qdisc *sch, struct n=
lattr *opt)
=20
 		q->tab_mask =3D mask;
 		q->tab =3D ntab;
-	} else
+	} else {
 		sch_tree_lock(sch);
+	}
=20
 	q->flags =3D ctl->flags;
 	q->limit =3D ctl->limit;
@@ -428,7 +429,7 @@ static int choke_change(struct Qdisc *sch, struct n=
lattr *opt)
 	return 0;
 }
=20
-static int choke_init(struct Qdisc* sch, struct nlattr *opt)
+static int choke_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	return choke_change(sch, opt);
 }


