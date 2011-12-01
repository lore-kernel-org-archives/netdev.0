From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Thu, 01 Dec 2011 04:30:25 +0100
Message-ID: <1322710225.2577.1.camel@edumazet-laptop>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
	 <1322691627-20551-2-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56908 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab1LADaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:30:30 -0500
Received: by eaak14 with SMTP id k14so1573974eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:30:29 -0800 (PST)
In-Reply-To: <1322691627-20551-2-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 23:20 +0100, Hagen Paul Pfeifer a =C3=
=A9crit :
> This extension can be used to simulate special link layer
> characteristics. Simulate because packet data is not modified, only t=
he
> calculation base is changed to delay a packet based on the original
> packet size and artificial cell information.
>=20
> packet_overhead can be used to simulate a link layer header compressi=
on
> scheme (e.g. set packet_overhead to -20) or with a positive
> packet_overhead value an additional MAC header can be simulated. It i=
s
> also possible to "replace" the 14 byte Ethernet header with something
> else.
>=20
> cell_size and cell_overhead can be used to simulate link layer scheme=
s,
> based on cells, like some TDMA schemes. Another application area are =
MAC
> schemes using a link layer fragmentation with a (small) header each.
> Cell size is the maximum amount of data bytes within one cell. Cell
> overhead is an additional variable to change the per-cell-overhead (e=
=2Eg.
> 5 byte header per fragment).
>=20
> Example (5 kbit/s, 20 byte per packet overhead, cell-size 100 byte, p=
er
> cell overhead 5 byte):
>=20
> 	tc qdisc add dev eth0 root netem rate 5kbit 20 100 5
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>=20
> The actual version of packet_len_2_sched_time() address Eric's div/mo=
d
> instruction concerns. I benchmarked the version in the patch with the
> following version:
>=20
>=20
> 	if (q->cell_size) {
> 		u32 mod_carry =3D len % q->cell_size;
> 		u32 cells     =3D len / q->cell_size;
> 		if (mod_carry)
> 			mod_carry =3D (len > q->cell_size || !cells) ?
> 				q->cell_size - mod_carry : len - mod_carry;
>=20
> 		if (q->cell_overhead) {
> 			if (mod_carry)
> 				++cells;
> 			len +=3D cells * q->cell_overhead;
> 		}
> 		len +=3D mod_carry;
> 	}
> 	return len;
>=20
>=20
> The patch version is a little bit faster for "all" packet sizes. For =
common
> cases (e.g. max. 1000 byte packets, cellsize 100 byte, the patch vers=
ion
> exhibit significant improvements). IMHO the actual version is also mo=
re
> understandable. Replace div and mod by do_div() was not that successf=
ul.
>=20
>=20
>  include/linux/pkt_sched.h |    3 +++
>  net/sched/sch_netem.c     |   32 +++++++++++++++++++++++++++++---
>  2 files changed, 32 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 26c37ca..63845cf 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -498,6 +498,9 @@ struct tc_netem_corrupt {
> =20
>  struct tc_netem_rate {
>  	__u32	rate;	/* byte/s */
> +	__s32   packet_overhead;
> +	__u32   cell_size;
> +	__s32   cell_overhead;
>  };
> =20
>  enum {
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index 9b7af9f..bcd2b3f 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -80,6 +80,9 @@ struct netem_sched_data {
>  	u32 reorder;
>  	u32 corrupt;
>  	u32 rate;
> +	s32 packet_overhead;
> +	u32 cell_size;
> +	s32 cell_overhead;
> =20
>  	struct crndstate {
>  		u32 last;
> @@ -299,9 +302,26 @@ static psched_tdiff_t tabledist(psched_tdiff_t m=
u, psched_tdiff_t sigma,
>  	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
>  }
> =20
> -static psched_time_t packet_len_2_sched_time(unsigned int len, u32 r=
ate)
> +static psched_time_t packet_len_2_sched_time(unsigned int len,
> +					     struct netem_sched_data *q)
>  {
> -	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / rate);
> +	u32 cells =3D 0;
> +	u32 datalen;
> +
> +	len +=3D q->packet_overhead;
> +
> +	if (q->cell_size) {
> +		for (datalen =3D len; datalen >  q->cell_size; datalen -=3D q->cel=
l_size)
> +			cells++;

Oh well.. you can exit this loop with data len =3D q->cell_size


Hmm, take a look at reciprocal divide ...

(include/linux/reciprocal_div.h)


Instead of :

u32 cells     =3D len / q->cell_size;

You set once q->cell_size_reciprocal =3D reciprocal_value(q->cell_size)=
;
(in Qdisc init)

Then you do :

cells =3D reciprocal_divide(len, q->cell_size_reciprocal);

Thats a multiply instead of a divide. On many cpus thats a lot faster.

Think about a super packet (TSO) of 65000 bytes and cell_size=3D64

> +
> +		if (q->cell_overhead)
> +			len +=3D cells * q->cell_overhead;
> +
> +		if (datalen)
> +			len +=3D (q->cell_size - datalen);
> +	}
> +
> +	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / q->rate);
>  }
> =20
>  /*
> @@ -381,7 +401,7 @@ static int netem_enqueue(struct sk_buff *skb, str=
uct Qdisc *sch)
>  		if (q->rate) {
>  			struct sk_buff_head *list =3D &q->qdisc->q;
> =20
> -			delay +=3D packet_len_2_sched_time(skb->len, q->rate);
> +			delay +=3D packet_len_2_sched_time(skb->len, q);
> =20
>  			if (!skb_queue_empty(list)) {
>  				/*
> @@ -565,6 +585,9 @@ static void get_rate(struct Qdisc *sch, const str=
uct nlattr *attr)
>  	const struct tc_netem_rate *r =3D nla_data(attr);
> =20
>  	q->rate =3D r->rate;
> +	q->packet_overhead =3D r->packet_overhead;
> +	q->cell_size       =3D r->cell_size;
> +	q->cell_overhead   =3D r->cell_overhead;
>  }
> =20
>  static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr=
)
> @@ -906,6 +929,9 @@ static int netem_dump(struct Qdisc *sch, struct s=
k_buff *skb)
>  	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
> =20
>  	rate.rate =3D q->rate;
> +	rate.packet_overhead =3D q->packet_overhead;
> +	rate.cell_size       =3D q->cell_size;
> +	rate.cell_overhead   =3D q->cell_overhead;
>  	NLA_PUT(skb, TCA_NETEM_RATE, sizeof(rate), &rate);
> =20
>  	if (dump_loss_model(q, skb) !=3D 0)
