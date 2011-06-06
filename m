From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCHv2] ipv6: implementation of reverse path filtering
Date: Mon, 06 Jun 2011 20:18:27 +0200
Message-ID: <1307384307.3098.92.camel@edumazet-laptop>
References: <1307362957.3098.7.camel@edumazet-laptop>
	 <1307382805-5753-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64912 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841Ab1FFSSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 14:18:31 -0400
Received: by wwa36 with SMTP id 36so4094768wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 11:18:29 -0700 (PDT)
In-Reply-To: <1307382805-5753-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 19:53 +0200, Eric Leblond a =C3=A9crit :
> This patch provides a basic implementation of reverse path filtering
> for IPv6. Functionnality can be activatedor desactivated through an
> rp_filter entry similar to the IPv4 one.
>=20
> The functionnality is disabled by default for backward compatibility
> but should be enable on all IPv6 routers/firewalls for security reaso=
n.
>=20
> This implementation is heavily based on the patch Denis Semmau propos=
ed
> in 2006.
>=20
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>  include/linux/ipv6.h   |    2 ++
>  include/linux/sysctl.h |    1 +
>  net/ipv6/addrconf.c    |   10 ++++++++++
>  net/ipv6/ip6_output.c  |   35 +++++++++++++++++++++++++++++++++++
>  4 files changed, 48 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 0c99776..6b61869 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -172,6 +172,7 @@ struct ipv6_devconf {
>  	__s32		disable_ipv6;
>  	__s32		accept_dad;
>  	__s32		force_tllao;
> +	__s32		rp_filter;
>  	void		*sysctl;
>  };
> =20
> @@ -213,6 +214,7 @@ enum {
>  	DEVCONF_DISABLE_IPV6,
>  	DEVCONF_ACCEPT_DAD,
>  	DEVCONF_FORCE_TLLAO,
> +	DEVCONF_RP_FILTER,
>  	DEVCONF_MAX
>  };
> =20
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 11684d9..bdcb7f8 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -568,6 +568,7 @@ enum {
>  	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=3D22,
>  	NET_IPV6_PROXY_NDP=3D23,
>  	NET_IPV6_ACCEPT_SOURCE_ROUTE=3D25,
> +	NET_IPV6_RP_FILTER=3D26,


not needed ?

>  	__NET_IPV6_MAX
>  };
> =20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 498b927..ba1c574 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -196,6 +196,7 @@ static struct ipv6_devconf ipv6_devconf __read_mo=
stly =3D {
>  	.accept_source_route	=3D 0,	/* we do not accept RH0 by default. */
>  	.disable_ipv6		=3D 0,
>  	.accept_dad		=3D 1,
> +	.rp_filter		=3D 0,
>  };
> =20
>  static struct ipv6_devconf ipv6_devconf_dflt __read_mostly =3D {
> @@ -230,6 +231,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __re=
ad_mostly =3D {
>  	.accept_source_route	=3D 0,	/* we do not accept RH0 by default. */
>  	.disable_ipv6		=3D 0,
>  	.accept_dad		=3D 1,
> +	.rp_filter		=3D 0,
>  };
> =20
>  /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
> @@ -3805,6 +3807,7 @@ static inline void ipv6_store_devconf(struct ip=
v6_devconf *cnf,
>  	array[DEVCONF_DISABLE_IPV6] =3D cnf->disable_ipv6;
>  	array[DEVCONF_ACCEPT_DAD] =3D cnf->accept_dad;
>  	array[DEVCONF_FORCE_TLLAO] =3D cnf->force_tllao;
> +	array[DEVCONF_RP_FILTER] =3D cnf->rp_filter;
>  }
> =20
>  static inline size_t inet6_ifla6_size(void)
> @@ -4459,6 +4462,13 @@ static struct addrconf_sysctl_table
>  			.proc_handler   =3D proc_dointvec
>  		},
>  		{
> +			.procname       =3D "rp_filter",
> +			.data           =3D &ipv6_devconf.rp_filter,
> +			.maxlen         =3D sizeof(int),
> +			.mode           =3D 0644,
> +			.proc_handler   =3D proc_dointvec
> +		},
> +		{
>  			/* sentinel */
>  		}
>  	},
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 9d4b165..ad8f351 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -374,6 +374,22 @@ static int ip6_forward_proxy_check(struct sk_buf=
f *skb)
>  	return 0;
>  }
> =20
> +static int rt6_validate_source(struct sk_buff *skb, char mode)
> +{
> +	struct rt6_info *rt;
> +	struct ipv6hdr *hdr =3D ipv6_hdr(skb);
> +	if (mode =3D=3D 0)
> +		return 0;
> +	rt =3D rt6_lookup(dev_net(skb->dev), &hdr->saddr, NULL, 0, 0);
> +	if (rt !=3D NULL) {

	route leak ?  you need dst_release(&rt->dst); [ and/or rcu ;) ]

> +		if ((mode >=3D 2) && rt->rt6i_idev->dev)
> +			return 0;
> +		if ((mode =3D=3D 1) && (rt->rt6i_idev->dev =3D=3D skb->dev))
> +			return 0;
> +	}
> +	return -1;
> +}
> +



