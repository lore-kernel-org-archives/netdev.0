From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: factorize qdisc stats handling
Date: Sun, 09 Jan 2011 19:30:54 +0100
Message-ID: <1294597854.2709.850.camel@edumazet-laptop>
References: <20110106195614.20dbc402@nehalam>
	 <AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
	 <20110107200234.3f5e7ff8@nehalam>
	 <1294478789.2709.79.camel@edumazet-laptop>
	 <20110109095735.5241e755@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev@vger.kernel.org, Luigi Rizzo <rizzo@iet.unipi.it>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57740 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237Ab1AIS6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 13:58:06 -0500
Received: by wwi17 with SMTP id 17so983853wwi.1
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 10:58:04 -0800 (PST)
In-Reply-To: <20110109095735.5241e755@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 09 janvier 2011 =C3=A0 09:57 -0800, Stephen Hemminger a =C3=
=A9crit :
> On Sat, 08 Jan 2011 10:26:29 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > +static inline void bstats_update(struct gnet_stats_basic_packed *b=
stats,
> > +				 struct sk_buff *skb)
> > +{
> > +	bstats->bytes +=3D qdisc_pkt_len(skb);
> > +	bstats->packets +=3D skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs =
: 1;
> > +}
> > +
> > +static inline void qdisc_bstats_update(struct Qdisc *sch, struct s=
k_buff *skb)
> >  {
> > -	sch->bstats.bytes +=3D len;
> > -	sch->bstats.packets++;
> > +	bstats_update(&sch->bstats, skb);
> >  }
>=20
> Minor nit. I prefer to show that skb is not modified.
>=20
> static inline void bstats_update(struct gnet_stats_basic_packed *bsta=
ts,
> 				 const struct sk_buff *skb)
>=20
> static inline void qdisc_bstats_update(struct Qdisc *sch, const struc=
t sk_buff *skb)
>=20

Right, qdisc_pkt_len() must also be constified

Here is v2, with Jarek remark addressed too :)

My next plan is to make stab handler RCU safe so that
qdisc_calculate_pkt_len() call can be done before locking qdisc
(and TCQ_F_CAN_BYPASS can be used even if a stab is setup)

Thanks

[PATCH v2] net_sched: factorize qdisc stats handling

HTB takes into account skb is segmented in stats updates.
Generalize this to all schedulers.

They should use qdisc_bstats_update() helper instead of manipulating
bstats.bytes and bstats.packets

Add bstats_update() helper too for classes that use
gnet_stats_basic_packed fields.

Note : Right now, TCQ_F_CAN_BYPASS shortcurt can be taken only if no
stab is setup on qdisc.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: constify some methods, and make sure qdisc_skb_cb(skb)->pkt_len is
set in the TCQ_F_CAN_BYPASS shortcut in __dev_xmit_skb()

 include/net/sch_generic.h |   20 ++++++++++++++------
 net/core/dev.c            |    5 ++++-
 net/sched/act_csum.c      |    3 +--
 net/sched/act_ipt.c       |    3 +--
 net/sched/act_mirred.c    |    3 +--
 net/sched/act_nat.c       |    3 +--
 net/sched/act_pedit.c     |    3 +--
 net/sched/act_police.c    |    3 +--
 net/sched/act_simple.c    |    3 +--
 net/sched/act_skbedit.c   |    3 +--
 net/sched/sch_atm.c       |    6 ++----
 net/sched/sch_cbq.c       |    6 ++----
 net/sched/sch_drr.c       |    8 ++------
 net/sched/sch_dsmark.c    |    3 +--
 net/sched/sch_hfsc.c      |    6 ++----
 net/sched/sch_htb.c       |   17 ++++++-----------
 net/sched/sch_ingress.c   |    3 +--
 net/sched/sch_multiq.c    |    3 +--
 net/sched/sch_netem.c     |    6 ++----
 net/sched/sch_prio.c      |    3 +--
 net/sched/sch_red.c       |    3 +--
 net/sched/sch_sfq.c       |    3 +--
 net/sched/sch_tbf.c       |    3 +--
 net/sched/sch_teql.c      |    3 +--
 24 files changed, 50 insertions(+), 72 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 0af57eb..e9eee99 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -207,7 +207,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 	return q->q.qlen;
 }
=20
-static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
+static inline struct qdisc_skb_cb *qdisc_skb_cb(const struct sk_buff *=
skb)
 {
 	return (struct qdisc_skb_cb *)skb->cb;
 }
@@ -394,7 +394,7 @@ static inline bool qdisc_tx_is_noop(const struct ne=
t_device *dev)
 	return true;
 }
=20
-static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
+static inline unsigned int qdisc_pkt_len(const struct sk_buff *skb)
 {
 	return qdisc_skb_cb(skb)->pkt_len;
 }
@@ -426,10 +426,18 @@ static inline int qdisc_enqueue_root(struct sk_bu=
ff *skb, struct Qdisc *sch)
 	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
 }
=20
-static inline void __qdisc_update_bstats(struct Qdisc *sch, unsigned i=
nt len)
+
+static inline void bstats_update(struct gnet_stats_basic_packed *bstat=
s,
+				 const struct sk_buff *skb)
+{
+	bstats->bytes +=3D qdisc_pkt_len(skb);
+	bstats->packets +=3D skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
+}
+
+static inline void qdisc_bstats_update(struct Qdisc *sch,
+				       const struct sk_buff *skb)
 {
-	sch->bstats.bytes +=3D len;
-	sch->bstats.packets++;
+	bstats_update(&sch->bstats, skb);
 }
=20
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdi=
sc *sch,
@@ -437,7 +445,7 @@ static inline int __qdisc_enqueue_tail(struct sk_bu=
ff *skb, struct Qdisc *sch,
 {
 	__skb_queue_tail(list, skb);
 	sch->qstats.backlog +=3D qdisc_pkt_len(skb);
-	__qdisc_update_bstats(sch, qdisc_pkt_len(skb));
+	qdisc_bstats_update(sch, skb);
=20
 	return NET_XMIT_SUCCESS;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index a215269..98248f6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2301,7 +2301,10 @@ static inline int __dev_xmit_skb(struct sk_buff =
*skb, struct Qdisc *q,
 		 */
 		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
 			skb_dst_force(skb);
-		__qdisc_update_bstats(q, skb->len);
+
+		qdisc_skb_cb(skb)->pkt_len =3D skb->len;
+		qdisc_bstats_update(q, skb);
+
 		if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
 			if (unlikely(contended)) {
 				spin_unlock(&q->busylock);
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 67dc7ce..83ddfc0 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -508,8 +508,7 @@ static int tcf_csum(struct sk_buff *skb,
=20
 	spin_lock(&p->tcf_lock);
 	p->tcf_tm.lastuse =3D jiffies;
-	p->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	p->tcf_bstats.packets++;
+	bstats_update(&p->tcf_bstats, skb);
 	action =3D p->tcf_action;
 	update_flags =3D p->update_flags;
 	spin_unlock(&p->tcf_lock);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 8daef96..c2a7c20 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -209,8 +209,7 @@ static int tcf_ipt(struct sk_buff *skb, struct tc_a=
ction *a,
 	spin_lock(&ipt->tcf_lock);
=20
 	ipt->tcf_tm.lastuse =3D jiffies;
-	ipt->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	ipt->tcf_bstats.packets++;
+	bstats_update(&ipt->tcf_bstats, skb);
=20
 	/* yes, we have to worry about both in and out dev
 	 worry later - danger - this API seems to have changed
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 0c311be..d765067 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -165,8 +165,7 @@ static int tcf_mirred(struct sk_buff *skb, struct t=
c_action *a,
=20
 	spin_lock(&m->tcf_lock);
 	m->tcf_tm.lastuse =3D jiffies;
-	m->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	m->tcf_bstats.packets++;
+	bstats_update(&m->tcf_bstats, skb);
=20
 	dev =3D m->tcfm_dev;
 	if (!dev) {
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 186eb83..178a4bd 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -125,8 +125,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_a=
ction *a,
 	egress =3D p->flags & TCA_NAT_FLAG_EGRESS;
 	action =3D p->tcf_action;
=20
-	p->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	p->tcf_bstats.packets++;
+	bstats_update(&p->tcf_bstats, skb);
=20
 	spin_unlock(&p->tcf_lock);
=20
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index a0593c9..445bef7 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -187,8 +187,7 @@ static int tcf_pedit(struct sk_buff *skb, struct tc=
_action *a,
 bad:
 	p->tcf_qstats.overlimits++;
 done:
-	p->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	p->tcf_bstats.packets++;
+	bstats_update(&p->tcf_bstats, skb);
 	spin_unlock(&p->tcf_lock);
 	return p->tcf_action;
 }
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 7ebf743..e2f08b1 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -298,8 +298,7 @@ static int tcf_act_police(struct sk_buff *skb, stru=
ct tc_action *a,
=20
 	spin_lock(&police->tcf_lock);
=20
-	police->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	police->tcf_bstats.packets++;
+	bstats_update(&police->tcf_bstats, skb);
=20
 	if (police->tcfp_ewma_rate &&
 	    police->tcf_rate_est.bps >=3D police->tcfp_ewma_rate) {
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 97e84f3..7287cff 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -42,8 +42,7 @@ static int tcf_simp(struct sk_buff *skb, struct tc_ac=
tion *a, struct tcf_result
=20
 	spin_lock(&d->tcf_lock);
 	d->tcf_tm.lastuse =3D jiffies;
-	d->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	d->tcf_bstats.packets++;
+	bstats_update(&d->tcf_bstats, skb);
=20
 	/* print policy string followed by _ then packet count
 	 * Example if this was the 3rd packet and the string was "hello"
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 66cbf4e..836f5fe 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -46,8 +46,7 @@ static int tcf_skbedit(struct sk_buff *skb, struct tc=
_action *a,
=20
 	spin_lock(&d->tcf_lock);
 	d->tcf_tm.lastuse =3D jiffies;
-	d->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
-	d->tcf_bstats.packets++;
+	bstats_update(&d->tcf_bstats, skb);
=20
 	if (d->flags & SKBEDIT_F_PRIORITY)
 		skb->priority =3D d->priority;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 2825407..943d733 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -422,10 +422,8 @@ drop: __maybe_unused
 		}
 		return ret;
 	}
-	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-	sch->bstats.packets++;
-	flow->bstats.bytes +=3D qdisc_pkt_len(skb);
-	flow->bstats.packets++;
+	qdisc_bstats_update(sch, skb);
+	bstats_update(&flow->bstats, skb);
 	/*
 	 * Okay, this may seem weird. We pretend we've dropped the packet if
 	 * it goes via ATM. The reason for this is that the outer qdisc
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index eb76315..c80d1c2 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -390,8 +390,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	ret =3D qdisc_enqueue(skb, cl->q);
 	if (ret =3D=3D NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
-		sch->bstats.packets++;
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
+		qdisc_bstats_update(sch, skb);
 		cbq_mark_toplevel(q, cl);
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
@@ -650,8 +649,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, st=
ruct Qdisc *child)
 		ret =3D qdisc_enqueue(skb, cl->q);
 		if (ret =3D=3D NET_XMIT_SUCCESS) {
 			sch->q.qlen++;
-			sch->bstats.packets++;
-			sch->bstats.bytes +=3D qdisc_pkt_len(skb);
+			qdisc_bstats_update(sch, skb);
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
 			return 0;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index aa8b531..de55e64 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -351,7 +351,6 @@ static int drr_enqueue(struct sk_buff *skb, struct =
Qdisc *sch)
 {
 	struct drr_sched *q =3D qdisc_priv(sch);
 	struct drr_class *cl;
-	unsigned int len;
 	int err;
=20
 	cl =3D drr_classify(skb, sch, &err);
@@ -362,7 +361,6 @@ static int drr_enqueue(struct sk_buff *skb, struct =
Qdisc *sch)
 		return err;
 	}
=20
-	len =3D qdisc_pkt_len(skb);
 	err =3D qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err !=3D NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
@@ -377,10 +375,8 @@ static int drr_enqueue(struct sk_buff *skb, struct=
 Qdisc *sch)
 		cl->deficit =3D cl->quantum;
 	}
=20
-	cl->bstats.packets++;
-	cl->bstats.bytes +=3D len;
-	sch->bstats.packets++;
-	sch->bstats.bytes +=3D len;
+	bstats_update(&cl->bstats, skb);
+	qdisc_bstats_update(sch, skb);
=20
 	sch->q.qlen++;
 	return err;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 1d295d6..60f4bdd 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -260,8 +260,7 @@ static int dsmark_enqueue(struct sk_buff *skb, stru=
ct Qdisc *sch)
 		return err;
 	}
=20
-	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-	sch->bstats.packets++;
+	qdisc_bstats_update(sch, skb);
 	sch->q.qlen++;
=20
 	return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 069c62b..2e45791 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1599,10 +1599,8 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *=
sch)
 	if (cl->qdisc->q.qlen =3D=3D 1)
 		set_active(cl, qdisc_pkt_len(skb));
=20
-	cl->bstats.packets++;
-	cl->bstats.bytes +=3D qdisc_pkt_len(skb);
-	sch->bstats.packets++;
-	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
+	bstats_update(&cl->bstats, skb);
+	qdisc_bstats_update(sch, skb);
 	sch->q.qlen++;
=20
 	return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 01b519d..984c1b0 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -569,15 +569,12 @@ static int htb_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
 		}
 		return ret;
 	} else {
-		cl->bstats.packets +=3D
-			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes +=3D qdisc_pkt_len(skb);
+		bstats_update(&cl->bstats, skb);
 		htb_activate(q, cl);
 	}
=20
 	sch->q.qlen++;
-	sch->bstats.packets +=3D skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
+	qdisc_bstats_update(sch, skb);
 	return NET_XMIT_SUCCESS;
 }
=20
@@ -648,12 +645,10 @@ static void htb_charge_class(struct htb_sched *q,=
 struct htb_class *cl,
 				htb_add_to_wait_tree(q, cl, diff);
 		}
=20
-		/* update byte stats except for leaves which are already updated */
-		if (cl->level) {
-			cl->bstats.bytes +=3D bytes;
-			cl->bstats.packets +=3D skb_is_gso(skb)?
-					skb_shinfo(skb)->gso_segs:1;
-		}
+		/* update basic stats except for leaves which are already updated */
+		if (cl->level)
+			bstats_update(&cl->bstats, skb);
+
 		cl =3D cl->parent;
 	}
 }
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index f10e34a..bce1665 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -63,8 +63,7 @@ static int ingress_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
=20
 	result =3D tc_classify(skb, p->filter_list, &res);
=20
-	sch->bstats.packets++;
-	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
+	qdisc_bstats_update(sch, skb);
 	switch (result) {
 	case TC_ACT_SHOT:
 		result =3D TC_ACT_SHOT;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 32690de..21f13da 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -83,8 +83,7 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch=
)
=20
 	ret =3D qdisc_enqueue(skb, qdisc);
 	if (ret =3D=3D NET_XMIT_SUCCESS) {
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-		sch->bstats.packets++;
+		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index e5593c0..1c4bce8 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -240,8 +240,7 @@ static int netem_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
=20
 	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-		sch->bstats.packets++;
+		qdisc_bstats_update(sch, skb);
 	} else if (net_xmit_drop_count(ret)) {
 		sch->qstats.drops++;
 	}
@@ -477,8 +476,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, stru=
ct Qdisc *sch)
 		__skb_queue_after(list, skb, nskb);
=20
 		sch->qstats.backlog +=3D qdisc_pkt_len(nskb);
-		sch->bstats.bytes +=3D qdisc_pkt_len(nskb);
-		sch->bstats.packets++;
+		qdisc_bstats_update(sch, nskb);
=20
 		return NET_XMIT_SUCCESS;
 	}
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index b1c95bc..966158d 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -84,8 +84,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
=20
 	ret =3D qdisc_enqueue(skb, qdisc);
 	if (ret =3D=3D NET_XMIT_SUCCESS) {
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-		sch->bstats.packets++;
+		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index a67ba3c..a6009c5 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -94,8 +94,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qd=
isc* sch)
=20
 	ret =3D qdisc_enqueue(skb, child);
 	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-		sch->bstats.packets++;
+		qdisc_bstats_update(sch, skb);
 		sch->q.qlen++;
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.pdrop++;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d54ac94..239ec53 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -403,8 +403,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		slot->allot =3D q->scaled_quantum;
 	}
 	if (++sch->q.qlen <=3D q->limit) {
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-		sch->bstats.packets++;
+		qdisc_bstats_update(sch, skb);
 		return NET_XMIT_SUCCESS;
 	}
=20
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 641a30d..77565e7 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -134,8 +134,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct =
Qdisc* sch)
 	}
=20
 	sch->q.qlen++;
-	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-	sch->bstats.packets++;
+	qdisc_bstats_update(sch, skb);
 	return NET_XMIT_SUCCESS;
 }
=20
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 106479a..af9360d 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -83,8 +83,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
=20
 	if (q->q.qlen < dev->tx_queue_len) {
 		__skb_queue_tail(&q->q, skb);
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-		sch->bstats.packets++;
+		qdisc_bstats_update(sch, skb);
 		return NET_XMIT_SUCCESS;
 	}
=20


