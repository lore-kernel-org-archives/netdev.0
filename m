From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netem: add cell concept to simulate special
 MAC behavior
Date: Sat, 10 Dec 2011 17:43:52 +0100
Message-ID: <1323535432.4016.24.camel@edumazet-laptop>
References: <1323530144-20014-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	Florian Westphal <fw@strlen.de>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38754 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab1LJQn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 11:43:58 -0500
Received: by bkcjm19 with SMTP id jm19so134054bkc.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 08:43:56 -0800 (PST)
In-Reply-To: <1323530144-20014-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 16:15 +0100, Hagen Paul Pfeifer =
a =C3=A9crit :
> So I hope Eric's div/mod concerns are addressed with this version!? ;=
-)

Yes, finaly ;)

But please read two other comments.

> No "hot-path" div/mod operation anymore. tc_netem_rate was introduced=
 in
> current net-next tree so there are no API f*ckups.
>=20
>=20
> From: Hagen Paul Pfeifer <hagen@jauu.net>
>=20
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
> overhead is an additional variable to change the per-cell-overhead
> (e.g.  5 byte header per fragment).
>=20
> Example (5 kbit/s, 20 byte per packet overhead, cell-size 100 byte, p=
er
> cell overhead 5 byte):
>=20
>   tc qdisc add dev eth0 root netem rate 5kbit 20 100 5
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  include/linux/pkt_sched.h |    3 +++
>  net/sched/sch_netem.c     |   33 +++++++++++++++++++++++++++++----
>  2 files changed, 32 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 8786ea7..8daced3 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -502,6 +502,9 @@ struct tc_netem_corrupt {
> =20
>  struct tc_netem_rate {
>  	__u32	rate;	/* byte/s */
> +	__s32	packet_overhead;
> +	__u32	cell_size;
> +	__s32	cell_overhead;

Adding fields in existing structure is convenient, but this means a
previous tc binary wont work anymore.

(because of this line in netem_policy[] :)
[TCA_NETEM_RATE]    =3D { .len =3D sizeof(struct tc_netem_rate) },

I guess netem users are capable to fetch new iproute2 package, but its
worth to mention this in changelog.

>  };
> =20
>  enum {
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index 3bfd733..31ab06e 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -22,6 +22,7 @@
>  #include <linux/skbuff.h>
>  #include <linux/vmalloc.h>
>  #include <linux/rtnetlink.h>
> +#include <linux/reciprocal_div.h>
> =20
>  #include <net/netlink.h>
>  #include <net/pkt_sched.h>
> @@ -80,6 +81,10 @@ struct netem_sched_data {
>  	u32 reorder;
>  	u32 corrupt;
>  	u32 rate;
> +	s32 packet_overhead;
> +	u32 cell_size;
> +	u32 cell_size_reciprocal;
> +	s32 cell_overhead;
> =20
>  	struct crndstate {
>  		u32 last;
> @@ -299,11 +304,23 @@ static psched_tdiff_t tabledist(psched_tdiff_t =
mu, psched_tdiff_t sigma,
>  	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
>  }
> =20
> -static psched_time_t packet_len_2_sched_time(unsigned int len, u32 r=
ate)
> +static psched_time_t packet_len_2_sched_time(unsigned int len, struc=
t netem_sched_data *q)
>  {
> -	u64 ticks =3D (u64)len * NSEC_PER_SEC;
> +	u64 ticks;
> =20
> -	do_div(ticks, rate);
> +	len +=3D q->packet_overhead;
> +
> +	if (q->cell_size) {
> +		u32 cells =3D reciprocal_divide(len, q->cell_size_reciprocal);
> +
> +		if (len > cells * q->cell_size)	/* extra cell needed for remainder=
 */
> +			cells++;
> +		len =3D cells * (q->cell_size + q->cell_overhead);
> +	}
> +
> +	ticks =3D (u64)len * NSEC_PER_SEC;
> +
> +	do_div(ticks, q->rate);
>  	return PSCHED_NS2TICKS(ticks);
>  }
> =20
> @@ -384,7 +401,7 @@ static int netem_enqueue(struct sk_buff *skb, str=
uct Qdisc *sch)
>  		if (q->rate) {
>  			struct sk_buff_head *list =3D &q->qdisc->q;
> =20
> -			delay +=3D packet_len_2_sched_time(skb->len, q->rate);
> +			delay +=3D packet_len_2_sched_time(skb->len, q);
> =20
>  			if (!skb_queue_empty(list)) {
>  				/*
> @@ -568,6 +585,11 @@ static void get_rate(struct Qdisc *sch, const st=
ruct nlattr *attr)
>  	const struct tc_netem_rate *r =3D nla_data(attr);
> =20
>  	q->rate =3D r->rate;
> +	q->packet_overhead =3D r->packet_overhead;
> +	q->cell_size =3D r->cell_size;
> +	q->cell_size_reciprocal =3D reciprocal_value(q->cell_size);

Here you get a crash if cell_size is 0. (divide by 0)


> +	q->cell_size =3D q->cell_size;
> +	q->cell_overhead =3D r->cell_overhead;
>  }
> =20
>  static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr=
)
> @@ -909,6 +931,9 @@ static int netem_dump(struct Qdisc *sch, struct s=
k_buff *skb)
>  	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
> =20
>  	rate.rate =3D q->rate;
> +	rate.packet_overhead =3D q->packet_overhead;
> +	rate.cell_size =3D q->cell_size;
> +	rate.cell_overhead =3D q->cell_overhead;
>  	NLA_PUT(skb, TCA_NETEM_RATE, sizeof(rate), &rate);
> =20
>  	if (dump_loss_model(q, skb) !=3D 0)
