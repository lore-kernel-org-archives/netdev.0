From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 7/7] net/ipv4: add dst cache support for gre
 lwtunnels
Date: Thu, 11 Feb 2016 15:59:25 +0300
Message-ID: <56BC85AD.4080408@cogentembedded.com>
References: <cover.1455184959.git.pabeni@redhat.com>
 <5ec1726778a0bb0e2e3768641d057595296cca56.1455184959.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34955 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbcBKM72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 07:59:28 -0500
Received: by mail-lf0-f47.google.com with SMTP id l143so31035799lfe.2
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 04:59:28 -0800 (PST)
In-Reply-To: <5ec1726778a0bb0e2e3768641d057595296cca56.1455184959.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/11/2016 1:12 PM, Paolo Abeni wrote:

> In case of UDP traffic with datagram length below MTU this
> give about 4% performance increase

    Gives.

> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>   net/ipv4/ip_gre.c | 17 ++++++++++++++---
>   1 file changed, 14 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 7c51c4e..be6f3f6 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -524,6 +524,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
>   	int tunnel_hlen;
>   	__be16 df, flags;
>   	int err;
> +	bool use_cache;

    DaveM prefers the declarations "sorted" from longest to shortest.

>
>   	tun_info = skb_tunnel_info(skb);
>   	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
> @@ -531,9 +532,19 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
>   		goto err_free_skb;
>
>   	key = &tun_info->key;
> -	rt = gre_get_rt(skb, dev, &fl, key);
> -	if (IS_ERR(rt))
> -		goto err_free_skb;
> +
> +	use_cache = !skb->mark && tun_info->dst_cache;
> +	rt = use_cache ? dst_cache_get_ip4(tun_info->dst_cache, &fl.saddr) :
> +			 NULL;
> +

    Empty line hardly needed here.

> +	if (!rt) {
> +		rt = gre_get_rt(skb, dev, &fl, key);
> +		if (IS_ERR(rt))
> +			goto err_free_skb;
> +		if (use_cache)
> +			dst_cache_set_ip4(tun_info->dst_cache, &rt->dst,
> +					  fl.saddr);
> +	}
>
>   	tunnel_hlen = ip_gre_calc_hlen(key->tun_flags);
>

MBR, Sergei
