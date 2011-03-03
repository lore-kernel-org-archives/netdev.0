From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v3)
Date: Thu, 03 Mar 2011 23:28:53 +0100
Message-ID: <1299191333.2547.12.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <1299168235.2983.116.camel@edumazet-laptop>
	 <20110303084839.3ae312ed@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62329 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758714Ab1CCW27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 17:28:59 -0500
Received: by bwz15 with SMTP id 15so1611340bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 14:28:57 -0800 (PST)
In-Reply-To: <20110303084839.3ae312ed@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 08:48 -0800, Stephen Hemminger a =C3=A9cri=
t :
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up.  Thanks to Eric Dumazet for doing the testing and
> finding bugs.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> v3 - bug fixes found by Eric
>=20
>  include/linux/pkt_sched.h |   15=20
>  net/sched/Kconfig         |   11=20
>  net/sched/Makefile        |    1=20
>  net/sched/sch_qfq.c       | 1125 +++++++++++++++++++++++++++++++++++=
+++++++++++
>  4 files changed, 1152 insertions(+)
>=20


Hmm... please compile before sending your patches ;)

You used sched_priv(sch) calls instead of qdisc_priv(sch)

> +}
> +
> +static void qfq_destroy_class(struct Qdisc *sch, struct qfq_class *c=
l)
> +{
> +	struct qfq_sched *q =3D sched_priv(sch);

	q =3D qdisc_priv(sch);

> +
> +	if (cl->inv_w) {
> +		q->wsum -=3D ONE_FP / cl->inv_w;
> +		cl->inv_w =3D 0;
> +	}
> +
> +	gen_kill_estimator(&cl->bstats, &cl->rate_est);
> +	qdisc_destroy(cl->qdisc);
> +	kfree(cl);
> +}

> +
> +static void qfq_qlen_notify(struct Qdisc *sch, unsigned long arg)
> +{
> +	struct qfq_sched *q =3D sched_priv(sch);

	q =3D qdisc_priv(sch);

> +	struct qfq_class *cl =3D (struct qfq_class *)arg;
> +
> +	if (cl->qdisc->q.qlen =3D=3D 0)
> +		qfq_deactivate_class(q, cl, NULL);
> +}
> +



> +static void qfq_reset_qdisc(struct Qdisc *sch)
> +{
> +	struct qfq_sched *q =3D qdisc_priv(sch);
> +	struct qfq_group *grp;
> +	struct qfq_class *cl, **pp;
> +	struct hlist_node *n;
> +	unsigned int i, j;
> +
> +	for (i =3D 0; i <=3D QFQ_MAX_INDEX; i++) {
> +		grp =3D &q->groups[i];
> +		for (j =3D 0; j < QFQ_MAX_SLOTS; j++) {
> +			for (pp =3D &grp->slots[j]; *pp; pp =3D &(*pp)->next) {
> +				cl =3D *pp;
> +				if (cl->qdisc->q.qlen)
> +					qfq_deactivate_class(q, cl, pp);


Here there is the problem of *pp =3D cl->next (possibly NULL)

		maybe use

	for (pp =3D &grp->slots[j]; (cl =3D *pp) !=3D NULL;) {
		if (cl->qdisc->q.len)
			qfq_deactivate_class(...);
		else
			pp =3D &cl->next;
	}


> +			}
> +		}
> +	}
> +
> +	for (i =3D 0; i < q->clhash.hashsize; i++) {
> +		hlist_for_each_entry(cl, n, &q->clhash.hash[i], common.hnode)
> +			qdisc_reset(cl->qdisc);
> +	}
> +	sch->q.qlen =3D 0;
> +}
> +



