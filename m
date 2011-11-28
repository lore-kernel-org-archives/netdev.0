From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Tue, 29 Nov 2011 00:01:07 +0100
Message-ID: <1322521267.2970.43.camel@edumazet-laptop>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
	 <1322187773-27768-1-git-send-email-hagen@jauu.net>
	 <1322187773-27768-2-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62550 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab1K1XBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 18:01:12 -0500
Received: by eaak14 with SMTP id k14so2332504eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 15:01:11 -0800 (PST)
In-Reply-To: <1322187773-27768-2-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 novembre 2011 =C3=A0 03:22 +0100, Hagen Paul Pfeifer a =C3=
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
> Example (5 kbit/s, 20 byte per packet overhead, cellsize 100 byte, pe=
r
> cell overhead 5 byte):
>=20
> 	tc qdisc add dev eth0 root netem rate 5kbit 20 100 5
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>  include/linux/pkt_sched.h |    3 +++
>  net/sched/sch_netem.c     |   30 +++++++++++++++++++++++++++---
>  2 files changed, 30 insertions(+), 3 deletions(-)
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
> index 9b7af9f..11ca527 100644
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
> @@ -299,9 +302,24 @@ static psched_tdiff_t tabledist(psched_tdiff_t m=
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
> +	len +=3D q->packet_overhead;
> +
> +	if (q->cell_size) {
> +		u32 carry =3D len % q->cell_size;
> +		len +=3D carry;

I dont understand this part  (len +=3D carry;)

Also you use a lot of divides... Probably OK for netem...

> +
> +		if (q->cell_overhead) {
> +			u32 cells =3D len / q->cell_size;
> +			if (carry)
> +				cells +=3D 1;
> +			len +=3D cells * q->cell_overhead;
> +		}
> +	}
> +
> +	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / q->rate);
>  }
