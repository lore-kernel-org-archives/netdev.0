From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
Date: Sun, 30 Aug 2009 08:54:53 +0200
Message-ID: <4A9A223D.1060406@gmail.com>
References: <20090830062344.6380.16713.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32933 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbZH3Gy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 02:54:59 -0400
In-Reply-To: <20090830062344.6380.16713.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> pfifo_fast_enqueue has this check:
>         if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
>=20
> which allows each band to enqueue upto tx_queue_len skbs for a
> total of 3*tx_queue_len skbs. I am not sure if this was the
> intention of limiting in qdisc.

Yes I noticed that and said to myself :
This was to let high priority packets have their own limit,
independent on fact that low priority packets filled their queue.

>=20
> Patch compiled and 32 simultaneous netperf testing ran fine. Also:
> # tc -s qdisc show dev eth2
> qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1=
 1 1
>  Sent 16835026752 bytes 373116 pkt (dropped 0, overlimits 0 requeues =
25)=20
>  rate 0bit 0pps backlog 0b 0p requeues 25=20
>=20
> (I am taking next week off, so sorry for any delay in responding)
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>=20
>  net/sched/sch_generic.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c	2009-08-30 11:18:23.000000000 +0530
> +++ new/net/sched/sch_generic.c	2009-08-30 11:21:50.000000000 +0530
> @@ -432,11 +432,11 @@ static inline struct sk_buff_head *band2
> =20
>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdi=
sc)
>  {
> -	int band =3D prio2band[skb->priority & TC_PRIO_MAX];
> -	struct pfifo_fast_priv *priv =3D qdisc_priv(qdisc);
> -	struct sk_buff_head *list =3D band2list(priv, band);
> +	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
> +		int band =3D prio2band[skb->priority & TC_PRIO_MAX];
> +		struct pfifo_fast_priv *priv =3D qdisc_priv(qdisc);
> +		struct sk_buff_head *list =3D band2list(priv, band);
> =20
> -	if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
>  		priv->bitmap |=3D (1 << band);
>  		qdisc->q.qlen++;
>  		return __qdisc_enqueue_tail(skb, qdisc, list);

