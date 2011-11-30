From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_red: fix red_calc_qavg_from_idle_time
Date: Wed, 30 Nov 2011 22:40:13 +0100
Message-ID: <1322689213.2602.18.camel@edumazet-laptop>
References: <1322688891.2602.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David =?ISO-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46486 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab1K3VkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 16:40:21 -0500
Received: by eeuu47 with SMTP id u47so668090eeu.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 13:40:20 -0800 (PST)
In-Reply-To: <1322688891.2602.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 22:34 +0100, Eric Dumazet a =C3=A9c=
rit :
> Since commit a4a710c4a7490587 (pkt_sched: Change PSCHED_SHIFT from 10=
 to
> 6) it seems [G]RED are broken in red_calc_qavg_from_idle_time()
>=20
> This function computes a delay in us units, but this delay is now 16
> times bigger than real delay, so the final qavg result is wrong...
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> Maybe we should use native kernel time services in red ?
> (ktime_get(), ktime_us_delta())
>=20
>  include/net/pkt_sched.h |    1 +
>  include/net/red.h       |    2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> index fffdc60..c719d9b 100644
> --- a/include/net/pkt_sched.h
> +++ b/include/net/pkt_sched.h
> @@ -43,6 +43,7 @@ typedef long	psched_tdiff_t;
>  /* Avoid doing 64 bit divide */
>  #define PSCHED_SHIFT			6
>  #define PSCHED_TICKS2NS(x)		((s64)(x) << PSCHED_SHIFT)
> +#define PSCHED_TICKS2US(x)		(PSCHED_TICKS2NS(x) >> 10) /* approximat=
e 1000 by 1024 */
>  #define PSCHED_NS2TICKS(x)		((x) >> PSCHED_SHIFT)
> =20
>  #define PSCHED_TICKS_PER_SEC		PSCHED_NS2TICKS(NSEC_PER_SEC)
> diff --git a/include/net/red.h b/include/net/red.h
> index 3319f16..a413638 100644
> --- a/include/net/red.h
> +++ b/include/net/red.h
> @@ -175,7 +175,7 @@ static inline unsigned long red_calc_qavg_from_id=
le_time(struct red_parms *p)
>  	int  shift;
> =20
>  	now =3D psched_get_time();
> -	us_idle =3D psched_tdiff_bounded(now, p->qidlestart, p->Scell_max);
> +	us_idle =3D PSCHED_TICKS2US(psched_tdiff_bounded(now, p->qidlestart=
, p->Scell_max));

Hmm, this is not correct the bound should be applied on the us result,
not on tick I presume (one tick =3D=3D 64ns)

I'll test another patch.
