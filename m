From: =?iso-8859-1?Q?Andr=E1s_Tak=E1cs?= <linux-kernel@wakoond.hu>
Subject: Re: xfrm warning by mip6d
Date: Wed, 5 Oct 2011 15:32:43 +0200
Message-ID: <34287764-C788-4718-BDD8-8B4DC98FE9F4@wakoond.hu>
References: <4C76ADDE-B534-4C40-BBDA-DCADA5DD347D@wakoond.hu> <1317810803.2473.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52223 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934700Ab1JENcs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 09:32:48 -0400
Received: by bkbzt4 with SMTP id zt4so2139040bkb.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 06:32:47 -0700 (PDT)
In-Reply-To: <1317810803.2473.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the help. I added this two skb_dst_force calls to my kernel =
source, but unfortunately it didn't solved the problem.

I know it's just a warning message, but I would be happy, if I could fi=
x it.

Does anybody have any other idea?


Thank you very much!

Regards,
Andr=E1s Tak=E1cs
http://www.wakoond.hu

On 2011.10.05., at 12:33, Eric Dumazet wrote:

> Le mercredi 05 octobre 2011 =E0 11:22 +0200, Andr=E1s Tak=E1cs a =E9c=
rit :
>=20
> Issue solved by commit 3bc07321ccc236f693ce1b6a8786f0a2e38bb87e
>=20
> Thanks
>=20
>=20
> commit 3bc07321ccc236f693ce1b6a8786f0a2e38bb87e
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Tue Mar 15 21:08:28 2011 +0000
>=20
>    xfrm: Force a dst refcount before entering the xfrm type handlers
>=20
>    Crypto requests might return asynchronous. In this case we leave
>    the rcu protected region, so force a refcount on the skb's
>    destination entry before we enter the xfrm type input/output
>    handlers.
>=20
>    This fixes a crash when a route is deleted whilst sending IPsec
>    data that is transformed by an asynchronous algorithm.
>=20
>    Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>    Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index 872065c..341cd11 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -190,6 +190,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, =
__be32 spi, int encap_type)
> 		XFRM_SKB_CB(skb)->seq.input.low =3D seq;
> 		XFRM_SKB_CB(skb)->seq.input.hi =3D seq_hi;
>=20
> +		skb_dst_force(skb);
> +
> 		nexthdr =3D x->type->input(x, skb);
>=20
> 		if (nexthdr =3D=3D -EINPROGRESS)
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index 1aba03f..8f3f0ee 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -78,6 +78,8 @@ static int xfrm_output_one(struct sk_buff *skb, int=
 err)
>=20
> 		spin_unlock_bh(&x->lock);
>=20
> +		skb_dst_force(skb);
> +
> 		err =3D x->type->output(x, skb);
> 		if (err =3D=3D -EINPROGRESS)
> 			goto out_exit;
>=20
>=20
>=20
