From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 2/2] net: ip, ipv6: handle gso skbs in forwarding
 path
Date: Sun, 26 Jan 2014 22:42:45 -0800 (PST)
Message-ID: <20140126.224245.1526907151535623187.davem@davemloft.net>
References: <1390730297-10725-1-git-send-email-fw@strlen.de>
	<1390730297-10725-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaA0Gmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 01:42:46 -0500
In-Reply-To: <1390730297-10725-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 26 Jan 2014 10:58:17 +0100

> +static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
> +{
> +	unsigned len;
> +
> +	if (skb->len <= mtu || skb->local_df)
> +		return false;
> +
> +	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
> +		return false;
> +
> +	return true;
> +}

Unused local variable 'len'.  Please scan the compiler output for at
least the *.c files you touch, it warns about this case.  Also, you
should always explicitly use "unsigned int" as the type instead of
just plain "unsigned".

> @@ -88,8 +147,7 @@ int ip_forward(struct sk_buff *skb)
>  	if (opt->is_strictroute && rt->rt_uses_gateway)
>  		goto sr_failed;
>  
> -	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
> -		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
> +	if (!ip_may_fragment(skb) && ip_exceeds_mtu(skb, dst_mtu(&rt->dst))) {
>  		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
>  		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  			  htonl(dst_mtu(&rt->dst)));

This hunk rejects, the test here looks a lot different in the current
tree.
