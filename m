From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/7] tcp_cubic: fix clock dependency
Date: Mon, 14 Mar 2011 19:51:19 +0100
Message-ID: <1300128679.3423.167.camel@edumazet-laptop>
References: <20110314175211.788224699@vyatta.com>
	 <20110314175439.564307922@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37693 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab1CNSwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 14:52:31 -0400
Received: by fxm17 with SMTP id 17so3221761fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 11:52:30 -0700 (PDT)
In-Reply-To: <20110314175439.564307922@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 10:52 -0700, Stephen Hemminger a =C3=A9cri=
t :
> pi=C3=A8ce jointe document texte brut (tcp-cubic-minrtt.patch)
> The hystart code was written with assumption that HZ=3D1000.
> Replace the use of jiffies with bictcp_clock as a millisecond
> real time clock.=20
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Reported-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>
>=20
> --- a/net/ipv4/tcp_cubic.c	2011-03-14 08:19:18.000000000 -0700
> +++ b/net/ipv4/tcp_cubic.c	2011-03-14 08:22:42.486690594 -0700
> @@ -88,7 +88,7 @@ struct bictcp {
>  	u32	last_time;	/* time when updated last_cwnd */
>  	u32	bic_origin_point;/* origin point of bic function */
>  	u32	bic_K;		/* time to origin point from the beginning of the curre=
nt epoch */
> -	u32	delay_min;	/* min delay */
> +	u32	delay_min;	/* min delay (msec << 3) */
>  	u32	epoch_start;	/* beginning of an epoch */
>  	u32	ack_cnt;	/* number of acks */
>  	u32	tcp_cwnd;	/* estimated tcp cwnd */
> @@ -98,7 +98,7 @@ struct bictcp {
>  	u8	found;		/* the exit point is found? */
>  	u32	round_start;	/* beginning of each round */
>  	u32	end_seq;	/* end_seq of the round */
> -	u32	last_jiffies;	/* last time when the ACK spacing is close */
> +	u32	last_ack;	/* last time when the ACK spacing is close */
>  	u32	curr_rtt;	/* the minimum rtt of current round */
>  };
> =20
> @@ -119,12 +119,21 @@ static inline void bictcp_reset(struct b
>  	ca->found =3D 0;
>  }
> =20
> +static inline u32 bictcp_clock(void)
> +{
> +#if HZ < 1000
> +	return ktime_to_ms(ktime_get_real());

Small point : This can be changed if date/time is changed

Maybe use monotonic time (aka ktime_get_ts()) ?



