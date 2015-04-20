From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 04/10] ipv6: Only create RTF_CACHE routes after
 encountering pmtu exception
Date: Mon, 20 Apr 2015 14:27:29 -0400 (EDT)
Message-ID: <20150420.142729.802138559230125552.davem@davemloft.net>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
	<1428717253-1006248-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbDTS1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 14:27:31 -0400
In-Reply-To: <1428717253-1006248-5-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 10 Apr 2015 18:54:07 -0700

> @@ -1171,8 +1170,15 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
>  	fl6.flowlabel = ip6_flowinfo(iph);
>  
>  	dst = ip6_route_output(net, NULL, &fl6);
> -	if (!dst->error)
> +	if (!dst->error) {
> +		unsigned char *outer_network_header = skb_network_header(skb);
> +		int offset;
> +
> +		skb_reset_network_header(skb);
> +		offset = outer_network_header - skb_network_header(skb);
>  		ip6_rt_update_pmtu(dst, NULL, skb, ntohl(mtu));
> +		skb_set_network_header(skb, offset);
> +	}

I seriously object to adjusting then restoring the location of the SKB
network header in this kind of code path.

Instead, adjust the interfaces to the code doing the packet header
inspection so that it can accomodate an offset or something like that
instead.
