From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net v2] ip_tunnels: Use skb-len to PMTU check.
Date: Mon, 1 Jul 2013 09:41:32 +0300
Message-ID: <20130701094132.3019afb4@vostro>
References: <1372660232-12174-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:56042 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab3GAGlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 02:41:24 -0400
Received: by mail-ea0-f181.google.com with SMTP id a15so1847100eae.26
        for <netdev@vger.kernel.org>; Sun, 30 Jun 2013 23:41:23 -0700 (PDT)
In-Reply-To: <1372660232-12174-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Jun 2013 23:30:32 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> In path mtu check, ip header total length works for gre device
> but not for gre-tap device.  Use skb len which is consistent
> for all tunneling types.  This is old bug in gre.
> This also fixes mtu calculation bug introduced by
> commit c54419321455631079c7d (GRE: Refactor GRE tunneling code).
> 
> Reported-by: Timo Teras <timo.teras@iki.fi>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> v1-v2:
>  - Fix pmtu set.
>  - This patch also restructures code which help couple of
>    improvements I have.

Looks good to me. One additional comment below.

> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 7fa8f08..ae5b78c 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -486,6 +486,53 @@ drop:
>  }
>  EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
>  
> +static int tnl_update_pmtu(struct net_device *dev, struct sk_buff
> *skb,
> +			    struct rtable *rt, __be16 df)
> +{
> +	struct ip_tunnel *tunnel = netdev_priv(dev);
> +	int pkt_size = skb->len - tunnel->hlen;
> +	int mtu;
> +
> +	if (df)
> +		mtu = dst_mtu(&rt->dst) - dev->hard_header_len
> +					- sizeof(struct iphdr) -
> tunnel->hlen;
> +	else
> +		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) :
> dev->mtu; +
> +	if (skb_dst(skb))
> +		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL,
> skb, mtu); +

Since mtu can change for skb_dst() only if df is set, would it make
sense to move the whole update_pmtu call inside if (df) {} block?

- Timo
