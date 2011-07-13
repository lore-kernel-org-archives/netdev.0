From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] af-packet: fix - avoid reading stale data
Date: Wed, 13 Jul 2011 03:56:30 +0200
Message-ID: <1310522190.2634.8.camel@edumazet-laptop>
References: <1310521339-1115-1-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, lokechetan@gmail.com
To: Chetan Loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62248 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab1GMB4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 21:56:34 -0400
Received: by wyg8 with SMTP id 8so219914wyg.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 18:56:33 -0700 (PDT)
In-Reply-To: <1310521339-1115-1-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 juillet 2011 =C3=A0 21:42 -0400, Chetan Loke a =C3=A9crit :
> Currently we flush tp_status and then flush the remainder of the head=
er+payload.
> tp_status should be flushed in the end to avoid stale data being read=
 by user-space.
>=20
>=20
> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
> ---
>  net/packet/af_packet.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index d2294ad..f7be71f 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1129,8 +1129,6 @@ static int tpacket_rcv(struct sk_buff *skb, str=
uct net_device *dev,
>  	else
>  		sll->sll_ifindex =3D dev->ifindex;
> =20
> -	__packet_set_status(po, h.raw, status);
> -	smp_mb();
>  #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE =3D=3D 1
>  	{
>  		u8 *start, *end;
> @@ -1140,6 +1138,8 @@ static int tpacket_rcv(struct sk_buff *skb, str=
uct net_device *dev,
>  			flush_dcache_page(pgv_to_page(start));
>  	}
>  #endif
> +	smp_mb();
> +	__packet_set_status(po, h.raw, status);
> =20
>  	sk->sk_data_ready(sk, 0);
> =20

Are you sure we can perform the flush_dcache_page() before smp_mb() ?

I believe we should do one smp_wmb() before __packet_set_status() as
well.



