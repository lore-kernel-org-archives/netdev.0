From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.4)
Date: Tue, 11 Jan 2011 01:00:31 +0100
Message-ID: <1294704031.4148.2.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam> <1294667210.3491.7.camel@edumazet-laptop>
	 <20110110154414.53f33916@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788Ab1AKAAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:00:35 -0500
Received: by wyb28 with SMTP id 28so19940267wyb.19
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 16:00:34 -0800 (PST)
In-Reply-To: <20110110154414.53f33916@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 janvier 2011 =C3=A0 15:44 -0800, Stephen Hemminger a =C3=A9=
crit :
> This implements the CHOKe packet scheduler based on the existing
> Linux RED scheduler based on the algorithm described in the paper.
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
>   Proceeding of INFOCOM'2000, March 2000.=20
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

You beat me, I found the bug I had  in _change()


> +
> +static int choke_change(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct choke_sched_data *q =3D qdisc_priv(sch);
> +	struct nlattr *tb[TCA_RED_MAX + 1];
> +	struct tc_red_qopt *ctl;
> +	int err;
> +	struct sk_buff **old =3D NULL;
> +	unsigned int mask;
> +
> +	if (opt =3D=3D NULL)
> +		return -EINVAL;
> +
> +	err =3D nla_parse_nested(tb, TCA_RED_MAX, opt, choke_policy);
> +	if (err < 0)
> +		return err;
> +
> +	if (tb[TCA_RED_PARMS] =3D=3D NULL ||
> +	    tb[TCA_RED_STAB] =3D=3D NULL)
> +		return -EINVAL;
> +
> +	ctl =3D nla_data(tb[TCA_RED_PARMS]);
> +
> +	mask =3D roundup_pow_of_two(ctl->limit + 1) - 1;
> +	if (mask !=3D q->tab_mask) {
> +		struct sk_buff **ntab =3D kcalloc(mask + 1, sizeof(struct sk_buff =
*),
> +						GFP_KERNEL);
> +		if (!ntab)
> +			ntab =3D vzalloc((mask + 1) * sizeof(struct sk_buff *));
> +		if (!ntab)
> +			return -ENOMEM;
> +		sch_tree_lock(sch);
> +		old =3D q->tab;
> +		if (old) {
> +			unsigned int tail =3D 0;
> +
> +			while (q->head !=3D q->tail) {
> +				ntab[tail++] =3D q->tab[q->head];
> +				q->head =3D (q->head + 1) & q->tab_mask;
> +			}
> +			q->head =3D 0;
> +			q->tail =3D tail;
> +		}
> +		q->tab_mask =3D mask;

Here we missed :

		q->tab =3D ntab;

> +		q->holes =3D 0;
> +	} else
> +		sch_tree_lock(sch);
> +	q->flags =3D ctl->flags;
> +	q->limit =3D ctl->limit;
> +
> +	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
> +		      ctl->Plog, ctl->Scell_log,
> +		      nla_data(tb[TCA_RED_STAB]));
> +
> +	if (q->head =3D=3D q->tail)
> +		red_end_of_idle_period(&q->parms);
> +
> +	sch_tree_unlock(sch);
> +	choke_free(old);
> +	return 0;
> +}
> +


