From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 02 Mar 2011 16:53:32 +0100
Message-ID: <1299081212.2920.14.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54270 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab1CBPxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 10:53:37 -0500
Received: by fxm17 with SMTP id 17so113843fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 07:53:36 -0800 (PST)
In-Reply-To: <20110228171738.2cc8c9a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 17:17 -0800, Stephen Hemminger a =C3=
=A9crit :
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up and tested it. All bugs are mine.



Here is my crash analysis :

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

Here, if we deactivated last class in chain, *pp is NULL, but

pp =3D &(*pp)->next  put 0x50 (on 64bit arches) in pp, so we crash ...





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



