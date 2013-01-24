From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH RESEND] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 24 Jan 2013 12:59:30 +0900
Message-ID: <5100B1A2.3000908@linux-ipv6.org>
References: <20130123100248.GB7317@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39292 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752923Ab3AXD7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 22:59:33 -0500
In-Reply-To: <20130123100248.GB7317@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013=E5=B9=B401=E6=9C=8823=E6=97=A5 19:02), Hannes Frederic Sowa wrote=
:
> This patch adds anti-spoofing checks in sit.c as specified in RFC3964
> section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> checks which could easily be implemented with netfilter.
>=20
> Specifically this patch adds following logic (based loosely on the
> pseudocode in RFC3964 section 5.2):
>=20
> if prefix (inner_src_v6) =3D=3D rd6_prefix (2002::/16 is the default)
>         and outer_src_v4 !=3D embedded_ipv4 (inner_src_v6)
>                 drop
> if prefix (inner_dst_v6) =3D=3D rd6_prefix (or 2002::/16 is the defau=
lt)
>         and outer_dst_v4 !=3D embedded_ipv4 (inner_dst_v6)
>                 drop
> accept
>=20
> To accomplish the specified security checks proposed by above RFCs,
> it is still necessary to employ uRPF filters with netfilter. These ne=
w
> checks only kick in if the employed addresses are within the 2002::/1=
6 or
> another range specified by the 6rd-prefix (which defaults to 2002::/1=
6).
>=20
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/sit.c | 29 +++++++++++++++++++++++++++--
>  1 file changed, 27 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index cfba99b..5a09f13 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -73,6 +73,8 @@ static int ipip6_tunnel_init(struct net_device *dev=
);
>  static void ipip6_tunnel_setup(struct net_device *dev);
>  static void ipip6_dev_free(struct net_device *dev);
>  static struct rtnl_link_ops sit_link_ops __read_mostly;
> +static inline __be32 try_6rd(const struct in6_addr *v6dst,
> +			     struct ip_tunnel *tunnel);
> =20
>  static int sit_net_id __read_mostly;
>  struct sit_net {
> @@ -590,6 +592,22 @@ out:
>  	return err;
>  }
> =20
> +static int sit_chk_encap_addr(struct ip_tunnel *tunnel, const __be32=
 *addr,
> +			      const struct in6_addr *addr6)
> +{
> +#ifdef CONFIG_IPV6_SIT_6RD
> +	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
> +			      tunnel->ip6rd.prefixlen) &&
> +	    *addr !=3D try_6rd(addr6, tunnel))
> +		return 0;
> +#else
> +	if (addr6->s6_addr16[0] =3D=3D htons(0x2002) &&
> +	    *addr !=3D try_6rd(addr6, tunnel))
> +		return 0;
> +#endif
> +	return 1;
> +}
> +

I need to do more research.  I am still not convinced
to have such destination check here because the standard
seems silent about it, and we have several basic checks
in standard input path and tunnel search.


Anyway, try_6rd() can do check for prefix as well
but we are doing slightly different thing.
So I think we can introduce new __check_6rd() to
return non-6rd/6to4 addresses.

bool __check_6rd(struct ip_tunnel *tunnel,
		 const struct in6_addr *v6dst,
		 __be32 *v4dst);

If prefix matches, fill *v4dst and return true.
Otherwise, return false.

__be32 __try_6rd()
{
	__be32 dst =3D 0;
	__check_6rd(tunnel, v6dst, &dst);
	return dst;
}

--yoshfuji
