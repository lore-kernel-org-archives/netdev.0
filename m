From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Fixed up ipsec packet be re-routing issue
Date: Thu, 22 May 2014 12:12:15 -0400 (EDT)
Message-ID: <20140522.121215.16105419184813584.davem@davemloft.net>
References: <1400742346-24727-1-git-send-email-huizhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	nickcave.zhang@gmail.com
To: huizhang@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbaEVQMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 12:12:18 -0400
In-Reply-To: <1400742346-24727-1-git-send-email-huizhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: huizhang <huizhang@marvell.com>
Date: Thu, 22 May 2014 15:05:46 +0800

> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index 5f8e128..869b68b 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -134,6 +134,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
>  	const struct ipv6hdr *hdr = ipv6_hdr(skb);
>  	struct ipv6_opt_hdr *exthdr;
>  	const unsigned char *nh = skb_network_header(skb);
> +	if(IP6CB(skb)->nhoff==0)
> +		IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
>  	u8 nexthdr = nh[IP6CB(skb)->nhoff];
>  	int oif = 0;

Never put actual statements in the middle of a series of variable
declarations.

Also, it would probably be better to do this assignment in
__ip_local_out().

That's the bug, we only set nhoff in the input paths, we need
to set it in the output paths too if reaching _decode_session6
is possible for output packets.
