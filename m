From: Duan Jiong <djduanjiong@gmail.com>
Subject: Re: [PATCH ] ip6tnl: do route updating for redirect in ip6_tnl_err()
Date: Thu, 19 Sep 2013 01:17:27 +0800
Message-ID: <5239E027.9080507@gmail.com>
References: <5239970F.8000105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:39344 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812Ab3IRRRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 13:17:36 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so7240152pbb.5
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 10:17:35 -0700 (PDT)
In-Reply-To: <5239970F.8000105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2013/9/18 20:05, Duan Jiong =D0=B4=B5=C0:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>
> After the ip6_tnl_err() is called, the rel_msg is assigned
> to 0, and the ip4ip6_err()will return directly, the instruction
> below will not be executed.
>
> In rfc2473, we can know that the tunnel ICMP redirect
> message should not be reported to the source of the
> original packet, so we can handle it in ip4ip6_err().
>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/ipv6/ip6_tunnel.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 2d8f482..35c4b70 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -529,6 +529,9 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, st=
ruct inet6_skb_parm *opt,
>  			rel_msg =3D 1;
>  		}
>  		break;
> +	case NDISC_REDIRECT:
> +		ip6_redirect(skb, net, 0, 0);
sorry, it should be

ip6_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0);
> +		break;
>  	}
> =20
>  	*type =3D rel_type;
> @@ -576,9 +579,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_=
parm *opt,
>  		rel_type =3D ICMP_DEST_UNREACH;
>  		rel_code =3D ICMP_FRAG_NEEDED;
>  		break;
> -	case NDISC_REDIRECT:
> -		rel_type =3D ICMP_REDIRECT;
> -		rel_code =3D ICMP_REDIR_HOST;
>  	default:
>  		return 0;
>  	}
> @@ -637,8 +637,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_=
parm *opt,
> =20
>  		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_inf=
o);
>  	}
> -	if (rel_type =3D=3D ICMP_REDIRECT)
> -		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
> =20
>  	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
> =20
