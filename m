From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC 06/12] vti6: Remove dst_entry caching
Date: Mon, 03 Mar 2014 11:58:18 +0100
Message-ID: <5314604A.4050905@6wind.com>
References: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com> <1393583483-12480-7-git-send-email-steffen.klassert@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christophe Gouault <christophe.gouault@6wind.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:38052 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566AbaCCK6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 05:58:30 -0500
Received: by mail-we0-f173.google.com with SMTP id w61so2994378wes.32
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 02:58:29 -0800 (PST)
In-Reply-To: <1393583483-12480-7-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/02/2014 11:31, Steffen Klassert a =C3=A9crit :
> Unlike ip6_tunnel, vti6 can lookup multiple different dst entries,
> dependent of the configured xfrm states. Therefore it does not make
> sense to cache a dst_entry.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/ipv6/ip6_vti.c |   44 +++++++++++++++++++----------------------=
---
>   1 file changed, 19 insertions(+), 25 deletions(-)
>
> diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
> index 8649143..3f337c7 100644
> --- a/net/ipv6/ip6_vti.c
> +++ b/net/ipv6/ip6_vti.c
> @@ -278,7 +278,6 @@ static void vti6_dev_uninit(struct net_device *de=
v)
>   		RCU_INIT_POINTER(ip6n->tnls_wc[0], NULL);
>   	else
>   		vti6_tnl_unlink(ip6n, t);
> -	ip6_tnl_dst_reset(t);
>   	dev_put(dev);
>   }
>
> @@ -356,11 +355,10 @@ vti6_addr_conflict(const struct ip6_tnl *t, con=
st struct ipv6hdr *hdr)
>    **/
>   static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
>   {
> -	struct net *net =3D dev_net(dev);
>   	struct ip6_tnl *t =3D netdev_priv(dev);
>   	struct net_device_stats *stats =3D &t->dev->stats;
> -	struct dst_entry *dst =3D NULL, *ndst =3D NULL;
> -	struct flowi6 fl6;
> +	struct dst_entry *dst =3D skb_dst(skb);
> +	struct flowi fl;
>   	struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
>   	struct net_device *tdev;
>   	int err =3D -1;
> @@ -369,21 +367,19 @@ static int vti6_xmit(struct sk_buff *skb, struc=
t net_device *dev)
>   	    !ip6_tnl_xmit_ctl(t) || vti6_addr_conflict(t, ipv6h))
>   		return err;
>
> -	dst =3D ip6_tnl_dst_check(t);
> -	if (!dst) {
> -		memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
> +	memset(&fl, 0, sizeof(fl));
> +	skb->mark =3D be32_to_cpu(t->parms.o_key);
> +	xfrm_decode_session(skb, &fl, AF_INET6);
>
> -		ndst =3D ip6_route_output(net, NULL, &fl6);
> +	if (!dst)
> +		goto tx_err_link_failure;
>
> -		if (ndst->error)
> -			goto tx_err_link_failure;
> -		ndst =3D xfrm_lookup(net, ndst, flowi6_to_flowi(&fl6), NULL, 0);
> -		if (IS_ERR(ndst)) {
> -			err =3D PTR_ERR(ndst);
> -			ndst =3D NULL;
> -			goto tx_err_link_failure;
> -		}
> -		dst =3D ndst;
> +	dst_hold(dst);
> +	dst =3D xfrm_lookup(t->net, dst, &fl, NULL, 0);
> +	if (IS_ERR(dst)) {
> +		err =3D PTR_ERR(dst);
> +		dst =3D NULL;
> +		goto tx_err_link_failure;
>   	}
>
>   	if (!dst->xfrm || dst->xfrm->props.mode !=3D XFRM_MODE_TUNNEL)
> @@ -399,21 +395,19 @@ static int vti6_xmit(struct sk_buff *skb, struc=
t net_device *dev)
>   	}
>
>
> -	skb_dst_drop(skb);
> -	skb_dst_set_noref(skb, dst);
> +	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
> +	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
> +	skb_dst_set(skb, dst);
> +	skb->dev =3D skb_dst(skb)->dev;
>
>   	ip6tunnel_xmit(skb, dev);
> -	if (ndst) {
> -		dev->mtu =3D dst_mtu(ndst);
> -		ip6_tnl_dst_store(t, ndst);
> -	}
>
>   	return 0;
>   tx_err_link_failure:
>   	stats->tx_carrier_errors++;
>   	dst_link_failure(skb);
>   tx_err_dst_release:
> -	dst_release(ndst);
> +	dst_release(dst);
>   	return err;
>   }
>
> @@ -997,7 +991,7 @@ static int __init vti6_tunnel_init(void)
>   	if (err < 0)
>   		goto out_pernet;
>
> -	err =3D xfrm6_mode_tunnel_input_register(&vti6_handler);
> +	 err =3D xfrm6_mode_tunnel_input_register(&vti6_handler);
There is no difference in this line, except the space after the tab.

>   	if (err < 0) {
>   		pr_err("%s: can't register vti6\n", __func__);
>   		goto out;
>
