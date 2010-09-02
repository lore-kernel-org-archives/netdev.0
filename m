From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 2 Sep 2010 11:02:12 +0000
Message-ID: <20100902110212.GB8775@ff.dom.local>
References: <20100830.095012.233695092.davem@davemloft.net> <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local> <20100901.145151.93454549.davem@davemloft.net> <20100902083327.GA6246@ff.dom.local> <1283419909.2454.137.camel@edumazet-laptop> <20100902095502.GA8775@ff.dom.local> <1283424105.2454.311.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36811 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab0IBLCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 07:02:21 -0400
Received: by bwz11 with SMTP id 11so448481bwz.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 04:02:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283424105.2454.311.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 12:41:45PM +0200, Eric Dumazet wrote:
> Le jeudi 02 septembre 2010 ?? 09:55 +0000, Jarek Poplawski a =E9crit =
:
>=20
> >=20
> > Exactly, but there is no "a single napi --> device mapping". And sk=
y2
> > uses the same model. So, there is only a question of cost of this t=
est,
> > and a question of probability of gro errors on collisions without s=
uch
> > a test in normal use. (And if gro can never do such errors for othe=
r
> > reasons?)
>=20
> Two vlans might carry packets in different domains, with a clash of I=
P
> space and TCP flows. Even with a probability of 0.000000001%, we cann=
ot
> ever merge two packets of different domains. Really !

Hmm... But there is only a question of sky2 and this test in
__napi_gro_receive().

>=20
> napi->dev is not used in GRO path, as mentioned earlier,
> but in napi_get_frags(), while not needed.
>=20
> To make this very clear, I suggest following patch :

But where this skb gets its skb->dev now?

Jarek P.

>=20
> [PATCH net-next-2.6] gro: remove use of napi->dev
>=20
> Only use of napi->dev in GRO stack is the one found in napi_get_frags=
()
>=20
> We can remove it and use a plain dev_alloc_skb() call.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/dev.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d8c43e7..607057a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3248,9 +3248,11 @@ struct sk_buff *napi_get_frags(struct napi_str=
uct *napi)
>  	struct sk_buff *skb =3D napi->skb;
> =20
>  	if (!skb) {
> -		skb =3D netdev_alloc_skb_ip_align(napi->dev, GRO_MAX_HEAD);
> -		if (skb)
> +		skb =3D dev_alloc_skb(GRO_MAX_HEAD + NET_IP_ALIGN);
> +		if (skb) {
> +			skb_reserve(skb, NET_IP_ALIGN);
>  			napi->skb =3D skb;
> +		}
>  	}
>  	return skb;
>  }
>=20
>=20
