From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [net-2.6.22] [TCP]: Fix linkage errors.
Date: Tue, 24 Apr 2007 17:53:24 +0200
Message-ID: <20070424155324.GL3468@stusta.de>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@osdl.org, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:32831 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754227AbXDXPxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 11:53:16 -0400
Content-Disposition: inline
In-Reply-To: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 12:17:43AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Recent ktime_t changes had introduced linkage errors.
>=20
> | WARNING: "__divdi3" [net/ipv4/tcp_veno.ko] undefined!
> | WARNING: "__divdi3" [net/ipv4/tcp_vegas.ko] undefined!
> | WARNING: "__divdi3" [net/ipv4/tcp_lp.ko] undefined!
> | WARNING: "__divdi3" [net/ipv4/tcp_illinois.ko] undefined!
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> ---
> diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
> index 8e31659..0cec615 100644
> --- a/net/ipv4/tcp_illinois.c
> +++ b/net/ipv4/tcp_illinois.c
> @@ -87,10 +87,12 @@ static void tcp_illinois_acked(struct sock *sk, u=
32 pkts_acked, ktime_t last)
>  {
>  	struct illinois *ca =3D inet_csk_ca(sk);
>  	u32 rtt;
> +	struct timeval tv;
> =20
>  	ca->acked =3D pkts_acked;
> =20
> -	rtt =3D ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
> +	tv =3D ktime_to_timeval(net_timedelta(last));
> +	rtt =3D tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
> =20
>  	/* ignore bogus values, this prevents wraparound in alpha math */
>  	if (rtt > RTT_MAX)
>...

Couldn't this be better solved by adding something like the following=20
to include/linux/ktime.h ?

static inline s64 ktime_to_us(const ktime_t kt)
{
   return (s64) kt.tv.sec * USEC_PER_SEC + kt.tv.nsec / NSEC_PER_USEC;
}

cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

