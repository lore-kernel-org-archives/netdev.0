From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v3.1)
Date: Fri, 04 Mar 2011 00:12:55 +0100
Message-ID: <1299193975.2547.16.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <1299168235.2983.116.camel@edumazet-laptop>
	 <20110303084839.3ae312ed@nehalam>
	 <1299191333.2547.12.camel@edumazet-laptop>
	 <20110303145947.44209d0a@nehalam>  <20110303150214.433a357d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53574 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759081Ab1CCXNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 18:13:00 -0500
Received: by wyg36 with SMTP id 36so1597193wyg.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 15:12:59 -0800 (PST)
In-Reply-To: <20110303150214.433a357d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 15:02 -0800, Stephen Hemminger a =C3=A9cri=
t :
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up.  Thanks to Eric Dumazet for doing the testing and
> finding bugs.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Oh well, did you read my previous mail ?



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


