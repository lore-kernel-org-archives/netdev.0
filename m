From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: VIA velocity skb leak.
Date: Thu, 12 Mar 2009 05:45:57 +0100
Message-ID: <49B89385.4090005@cosmosbay.com>
References: <20090312041352.GA6035@redhat.com> <20090311.211706.68465072.davem@davemloft.net> <20090311.212009.51140677.davem@davemloft.net> <20090312043954.GA7132@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48946 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbZCLEqT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 00:46:19 -0400
In-Reply-To: <20090312043954.GA7132@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones a =E9crit :
> On Wed, Mar 11, 2009 at 09:20:09PM -0700, David Miller wrote:
>  > From: David Miller <davem@davemloft.net>
>  > Date: Wed, 11 Mar 2009 21:17:06 -0700 (PDT)
>  >=20
>  > >=20
>  > > velocity_xmit() needs to set 'pktlen =3D skb->len;' after,
>  > > not before, the skb_padto() call.
>  >=20
>  > Actually that won't work since, as you suggest, skb->len
>  > isn't updated by skb_padto().
>  >=20
>  > So the transmit needs something like:
>  >=20
>  > 	pktlen =3D (skb->len > ETH_ZLEN ? : ETH_ZLEN);
>  >=20
>  > velocity_free_tx_buf() needs to make the same calculation
>  > instead of just plain skb->len
>=20
> Something like this ?
> (It looks like the ZERO_COPY_SUPPORT is never enabled anywhere,
>  so I didn't dig into how that works).
>=20
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index c5691fd..cd34dda 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
> @@ -1838,6 +1838,7 @@ static void velocity_free_tx_buf(struct velocit=
y_info *vptr, struct velocity_td_
>  {
>  	struct sk_buff *skb =3D tdinfo->skb;
>  	int i;
> +	int pktlen;
> =20
>  	/*
>  	 *	Don't unmap the pre-allocated tx_bufs
> @@ -1845,10 +1846,11 @@ static void velocity_free_tx_buf(struct veloc=
ity_info *vptr, struct velocity_td_
>  	if (tdinfo->skb_dma) {
> =20
> +		pktlen =3D (skb->len > ETH_ZLEN ? : ETH_ZLEN);

I personally find better to use max(skb->len, ETH_ZLEN) macro, but YMMV=
 ;)

It actually can avoid you a bug ;)


