From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] IPoIB: Stop lying about hard_header_len and use skb->cb
 to stash LL addresses
Date: Wed, 8 Feb 2012 16:28:47 +0200
Message-ID: <4F32869F.3090605@mellanox.com>
References: <CAG4TOxP2iEgT64L8vAR6P139U-HyHSxU8gdWw+cLsDwWSGkrwA@mail.gmail.com>  <1328662281-16256-1-git-send-email-roland@kernel.org>  <1828884A29C6694DAF28B7E6B8A82373374C1C26@ORSMSX101.amr.corp.intel.com> <1328687424.4736.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Hefty, Sean" <sean.hefty@intel.com>,
	David Miller <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"shlomop@mellanox.com" <shlomop@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:45810 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753663Ab2BHOeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 09:34:17 -0500
In-Reply-To: <1328687424.4736.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/2012 9:50 AM, Eric Dumazet wrote:
> Le mercredi 08 f=C3=A9vrier 2012 =C3=A0 07:29 +0000, Hefty, Sean a =C3=
=A9crit :
>> I tested this with Dave's patch and Eric's first patch against Linus=
' latest tree 3.3-rc2+, and things look good so far.
>>
>
> Thanks for testing, I'll resend my (updated) patch today.

same here, I used Roland's patch on top of net-next plus the below patc=
h=20
and got GRO to aggregate okay,
great doing! Eric, could you please post your work to Dave after=20
Roland's patch is applied?

Or.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index f124947..9b8e2fa 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3491,14 +3491,20 @@ static inline gro_result_t
>  __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
>  {
>         struct sk_buff *p;
> +       unsigned int maclen =3D skb->dev->hard_header_len;
>
>         for (p =3D napi->gro_list; p; p =3D p->next) {
>                 unsigned long diffs;
>
>                 diffs =3D (unsigned long)p->dev ^ (unsigned long)skb-=
>dev;
>                 diffs |=3D p->vlan_tci ^ skb->vlan_tci;
> -               diffs |=3D compare_ether_header(skb_mac_header(p),
> -                                             skb_gro_mac_header(skb)=
);
> +               if (maclen =3D=3D ETH_HLEN)
> +                       diffs |=3D compare_ether_header(skb_mac_heade=
r(p),
> +                                                    =20
> skb_gro_mac_header(skb));
> +               else if (!diffs)
> +                       diffs =3D memcmp(skb_mac_header(p),
> +                                       skb_gro_mac_header(skb),
> +                                       maclen);
>                 NAPI_GRO_CB(p)->same_flow =3D !diffs;
>                 NAPI_GRO_CB(p)->flush =3D 0;
>         }
