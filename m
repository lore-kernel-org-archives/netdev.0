From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH v2] ipv6: fix handling of blackhole and prohibit routes
Date: Wed, 05 Sep 2012 12:03:37 +0200
Message-ID: <50472379.10608@6wind.com>
References: <20120904.155836.51164588359279575.davem@davemloft.net> <1346844858-3210-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56777 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758429Ab2IEKDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 06:03:41 -0400
Received: by eekc1 with SMTP id c1so129156eek.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 03:03:40 -0700 (PDT)
In-Reply-To: <1346844858-3210-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please, forget this patch, it's a wrong version.
Sorry for that.


Regards,
Nicolas

Le 05/09/2012 13:34, Nicolas Dichtel a =C3=A9crit :
> When adding a blackhole or a prohibit route, they were handling like =
classic
> routes. Moreover, it was only possible to add this kind of routes by =
specifying
> an interface.
>
> Bug already reported here:
>    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D498498
>
> Before the patch:
>    $ ip route add blackhole 2001::1/128
>    RTNETLINK answers: No such device
>    $ ip route add blackhole 2001::1/128 dev eth0
>    $ ip -6 route | grep 2001
>    2001::1 dev eth0  metric 1024
>
> After:
>    $ ip route add blackhole 2001::1/128
>    $ ip -6 route | grep 2001
>    blackhole 2001::1 dev lo  metric 1024  error -22
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   include/net/ip6_fib.h |  1 +
>   net/ipv6/route.c      | 32 ++++++++++++++++++++++++++++----
>   2 files changed, 29 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> index 0fedbd8..cd64cf3 100644
> --- a/include/net/ip6_fib.h
> +++ b/include/net/ip6_fib.h
> @@ -37,6 +37,7 @@ struct fib6_config {
>   	int		fc_ifindex;
>   	u32		fc_flags;
>   	u32		fc_protocol;
> +	u32		fc_type;	/* only 8 bits are used */
>
>   	struct in6_addr	fc_dst;
>   	struct in6_addr	fc_src;
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 8e80fd2..5642fb5 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1463,8 +1463,18 @@ int ip6_route_add(struct fib6_config *cfg)
>   		}
>   		rt->dst.output =3D ip6_pkt_discard_out;
>   		rt->dst.input =3D ip6_pkt_discard;
> -		rt->dst.error =3D -ENETUNREACH;
>   		rt->rt6i_flags =3D RTF_REJECT|RTF_NONEXTHOP;
> +		switch (cfg->fc_type) {
> +		case RTM_BLACKHOLE:
> +			rt->dst.error =3D -EINVAL;
> +			break;
> +		case RTM_PROHIBIT:
> +			rt->dst.error =3D -EACCES;
> +			break;
> +		default:
> +			rt->dst.error =3D -ENETUNREACH;
> +			break;
> +		}
>   		goto install_route;
>   	}
>
> @@ -2261,8 +2271,11 @@ static int rtm_to_fib6_config(struct sk_buff *=
skb, struct nlmsghdr *nlh,
>   	cfg->fc_src_len =3D rtm->rtm_src_len;
>   	cfg->fc_flags =3D RTF_UP;
>   	cfg->fc_protocol =3D rtm->rtm_protocol;
> +	cfg->type =3D rtm->rtm_type;
>
> -	if (rtm->rtm_type =3D=3D RTN_UNREACHABLE)
> +	if (rtm->rtm_type =3D=3D RTN_UNREACHABLE ||
> +	    rtm->rtm_type =3D=3D RTN_BLACKHOLE ||
> +	    rtm->rtm_type =3D=3D RTN_PROHIBIT)
>   		cfg->fc_flags |=3D RTF_REJECT;
>
>   	if (rtm->rtm_type =3D=3D RTN_LOCAL)
> @@ -2391,8 +2404,19 @@ static int rt6_fill_node(struct net *net,
>   	rtm->rtm_table =3D table;
>   	if (nla_put_u32(skb, RTA_TABLE, table))
>   		goto nla_put_failure;
> -	if (rt->rt6i_flags & RTF_REJECT)
> -		rtm->rtm_type =3D RTN_UNREACHABLE;
> +	if (rt->rt6i_flags & RTF_REJECT) {
> +		switch (rt->dst.error) {
> +		case -EINVAL:
> +			rtm->rtm_type =3D RTN_BLACKHOLE;
> +			break;
> +		case -EACCES:
> +			rtm->rtm_type =3D RTN_PROHIBIT;
> +			break;
> +		default:
> +			rtm->rtm_type =3D RTN_UNREACHABLE;
> +			break;
> +		}
> +	}
>   	else if (rt->rt6i_flags & RTF_LOCAL)
>   		rtm->rtm_type =3D RTN_LOCAL;
>   	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
>

--=20
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 10
=46ax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
www.6wind.com
Twitter: http://twitter.com/6windsoftware
Join the Multicore Packet Processing Forum: www.multicorepacketprocessi=
ng.com

Ce courriel ainsi que toutes les pi=C3=A8ces jointes, est uniquement de=
stin=C3=A9 =C3=A0 son ou=20
ses destinataires. Il contient des informations confidentielles qui son=
t la=20
propri=C3=A9t=C3=A9 de 6WIND. Toute r=C3=A9v=C3=A9lation, distribution =
ou copie des informations=20
qu'il contient est strictement interdite. Si vous avez re=C3=A7u ce mes=
sage par=20
erreur, veuillez imm=C3=A9diatement le signaler =C3=A0 l'=C3=A9metteur =
et d=C3=A9truire toutes les=20
donn=C3=A9es re=C3=A7ues.

This e-mail message, including any attachments, is for the sole use of =
the=20
intended recipient(s) and contains information that is confidential and=
=20
proprietary to 6WIND. All unauthorized review, use, disclosure or distr=
ibution=20
is prohibited. If you are not the intended recipient, please contact th=
e sender=20
by reply e-mail and destroy all copies of the original message.
