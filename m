From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v7 3/3] geneve: add IPv6 bits to geneve_fill_metadata_dst
Date: Tue, 27 Oct 2015 15:48:12 +0300
Message-ID: <562F728C.6030201@cogentembedded.com>
References: <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
 <1445893306-31225-1-git-send-email-linville@tuxdriver.com>
 <1445893306-31225-3-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:35500 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbJ0MsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 08:48:15 -0400
Received: by lbbes7 with SMTP id es7so62596812lbb.2
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 05:48:13 -0700 (PDT)
In-Reply-To: <1445893306-31225-3-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/27/2015 12:01 AM, John W. Linville wrote:

> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> v7 -- initial version (numbered to match earlier patches in series)
>
>   drivers/net/geneve.c | 28 +++++++++++++++++++++-------
>   1 file changed, 21 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 44e724508c55..be532d7b879d 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -1006,16 +1006,30 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
>   	struct geneve_dev *geneve = netdev_priv(dev);
>   	struct rtable *rt;
>   	struct flowi4 fl4;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	struct dst_entry *dst;
> +	struct flowi6 fl6;
> +#endif
>
> -	if (ip_tunnel_info_af(info) != AF_INET)
> -		return -EINVAL;
> +	if (ip_tunnel_info_af(info) == AF_INET) {
> +		rt = geneve_get_v4_rt(skb, dev, &fl4, info);
> +		if (IS_ERR(rt))
> +			return PTR_ERR(rt);
>
> -	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
> -	if (IS_ERR(rt))
> -		return PTR_ERR(rt);
> +		ip_rt_put(rt);
> +		info->key.u.ipv4.src = fl4.saddr;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	} else if (ip_tunnel_info_af(info) == AF_INET6) {
> +		dst = geneve_get_v6_dst(skb, dev, &fl6, info);
> +		if (IS_ERR(dst))
> +			return PTR_ERR(dst);
> +
> +		dst_release(dst);
> +		info->key.u.ipv6.src = fl6.saddr;
> +#endif
> +	} else
> +		return -EINVAL;

    You need {} on this branch too, according to Documentation/CodingStyle.

MBR, Sergei
