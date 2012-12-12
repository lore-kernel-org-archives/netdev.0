From: Duan Jiong <djduanjiong@gmail.com>
Subject: Re: [PATCH] ipv6: fix the bug when propagating Redirect Message
Date: Wed, 12 Dec 2012 19:09:51 +0800
Message-ID: <50C865FF.7030209@gmail.com>
References: <5086B721.1090905@gmail.com> <20121024045410.GF27385@secunet.com> <50C72DEC.1000008@gmail.com> <20121211134514.GE18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:32928 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab2LLLJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 06:09:59 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so471282pbc.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 03:09:59 -0800 (PST)
In-Reply-To: <20121211134514.GE18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012/12/11 21:45, Steffen Klassert =E5=86=99=E9=81=93:
> On Tue, Dec 11, 2012 at 08:58:20PM +0800, Duan Jiong wrote:
>>
>> Just like you said, i try to use ndisc_parse_options() to instead
>> of the loop, but i find the skb->data can't be changed in function
>> ndisc_parse_options() due to lack of  arguments. So i think it is
>> better to continue to use the loop. How do you think this?
>>
>=20
> You can change the data pointer after ndisc_parse_options().
> Something like the (untested) patch below should do it.
>=20
>  include/net/ndisc.h |    7 +++++++
>  net/ipv6/ndisc.c    |   20 ++++++++++++++++++++
>  2 files changed, 27 insertions(+)
>=20
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 980d263..c17bccd 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -78,6 +78,13 @@ struct ra_msg {
>  	__be32			retrans_timer;
>  };
> =20
> +struct rd_msg {
> +        struct icmp6hdr	icmph;
> +        struct in6_addr	target;
> +        struct in6_addr	dest;
> +	__u8		opt[0];
> +};
> +
>  struct nd_opt_hdr {
>  	__u8		nd_opt_type;
>  	__u8		nd_opt_len;
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 2edce30..9afd23f 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1333,6 +1333,12 @@ out:
> =20
>  static void ndisc_redirect_rcv(struct sk_buff *skb)
>  {
> +	u8 *hdr;
> +	struct ndisc_options ndopts;
> +	struct rd_msg *msg =3D (struct rd_msg *) skb_transport_header(skb);
> +	u32 ndoptlen =3D skb->tail - (skb->transport_header +
> +				    offsetof(struct rd_msg, opt));
> +
>  #ifdef CONFIG_IPV6_NDISC_NODETYPE
>  	switch (skb->ndisc_nodetype) {
>  	case NDISC_NODETYPE_HOST:
> @@ -1349,6 +1355,20 @@ static void ndisc_redirect_rcv(struct sk_buff =
*skb)
>  		return;
>  	}
> =20
> +	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
> +		ND_PRINTK(2, warn, "Redirect: invalid ND options\n");
> +		return;
> +	}
> +
> +	if (!ndopts.nd_opts_rh)
> +		return;
> +
> +	hdr =3D (u8 *) ndopts.nd_opts_rh;
> +	hdr +=3D 8;
> +
> +	if (!pskb_pull(skb, hdr - skb_transport_header(skb)))
> +		return;
> +
>  	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
>  }
> =20
>=20
Thanks for you help. I will test it.
