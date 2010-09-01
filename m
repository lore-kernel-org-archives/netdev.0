From: Anders Franzen <Anders.Franzen@ericsson.com>
Subject: Re: [RFC]: not possible to do policy routing for next hop on
 tunnels.
Date: Wed, 01 Sep 2010 15:27:39 +0200
Message-ID: <1283347660.14066.27.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
References: <1283343685.14066.24.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
	 <1283345350.2556.265.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:45894 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219Ab0IANYM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 09:24:12 -0400
In-Reply-To: <1283345350.2556.265.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Quick answer!

It seems do exactly what I want.
Is there a corresponding 'fwmark inherit' parameter added to the ip
command somewhere?
Will this patch get it into the kernel?

If you need testing I will do that.

/Anders

On Wed, 2010-09-01 at 14:49 +0200, Eric Dumazet wrote:
> Le mercredi 01 septembre 2010 =C3=A0 14:21 +0200, Anders Franzen a =C3=
=A9crit :
> > If I have multiple routing choices to reach a tunnel end point,
> > I would like to mark different flows with iptables, after the
> > postrouting of the primary route look up, this would put an fwmark =
on
> > the skb. The route would in my case resolve to an ip6_tunnel.
> >=20
> > In the tunnel a secondary route lookup is done to select next hop f=
or
> > the tunnel end point.
> >=20
> > I would like to apply policy routing to the secondary lookup.=20
> >=20
> > This will not work, for two reasons:
> >=20
> > 1. None of the tunnels (ipip, gre, ip6_tunnel) I looked at regards =
the
> > fwmark at the skb, when performing the route lookup.
> >=20
> > 2. ip6_tunnel is keeping a local dst cache, so it will never rerout=
e as
> > long as the current cache is valid.
> >=20
> >=20
> > I wonder if there is a reason for not giving the fwmark at the tunn=
el
> > route for tunnels in general?
> >=20
> > And the local dst cache for ip6_tunnel, is it needed, is not the ro=
uting
> > subsystem keeping some form of internal cache (ip route ls cache).
>=20
> ip6_tunnel (or others) could be extended with a
> IP6_TNL_F_USE_ORIG_FWMARK, and in this case not use/cache the route.
>=20
> untested patch to get the idea :
>=20
> diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
> index acb9ad6..bf22b03 100644
> --- a/include/linux/ip6_tunnel.h
> +++ b/include/linux/ip6_tunnel.h
> @@ -16,6 +16,8 @@
>  #define IP6_TNL_F_MIP6_DEV 0x8
>  /* copy DSCP from the outer packet */
>  #define IP6_TNL_F_RCV_DSCP_COPY 0x10
> +/* copy fwmark from inner packet */
> +#define IP6_TNL_F_USE_ORIG_FWMARK 0x20
> =20
>  struct ip6_tnl_parm {
>  	char name[IFNAMSIZ];	/* name of tunnel device */
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 0fd027f..e31a91f 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -858,7 +858,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
>  	int err =3D -1;
>  	int pkt_len;
> =20
> -	if ((dst =3D ip6_tnl_dst_check(t)) !=3D NULL)
> +	if (!fl->mark && (dst =3D ip6_tnl_dst_check(t)) !=3D NULL)
>  		dst_hold(dst);
>  	else {
>  		dst =3D ip6_route_output(net, NULL, fl);
> @@ -910,7 +910,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
>  		skb =3D new_skb;
>  	}
>  	skb_dst_drop(skb);
> -	skb_dst_set(skb, dst_clone(dst));
> +	skb_dst_set(skb, fl->mark ? dst : dst_clone(dst));
> =20
>  	skb->transport_header =3D skb->network_header;
> =20
> @@ -940,7 +940,9 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
>  		stats->tx_errors++;
>  		stats->tx_aborted_errors++;
>  	}
> -	ip6_tnl_dst_store(t, dst);
> +	if (!fl->mark)
> +		ip6_tnl_dst_store(t, dst);
> +	=09
>  	return 0;
>  tx_err_link_failure:
>  	stats->tx_carrier_errors++;
> @@ -976,6 +978,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
>  	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
>  		fl.fl6_flowlabel |=3D htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
>  					  & IPV6_TCLASS_MASK;
> +	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK))
> +		fl.mark =3D skb->mark;
> =20
>  	err =3D ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
>  	if (err !=3D 0) {
> @@ -1026,7 +1030,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net=
_device *dev)
>  		fl.fl6_flowlabel |=3D (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
>  	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
>  		fl.fl6_flowlabel |=3D (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
> -
> +	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK))
> +		fl.mark =3D skb->mark;
>  	err =3D ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
>  	if (err !=3D 0) {
>  		if (err =3D=3D -EMSGSIZE)
>=20
>=20


