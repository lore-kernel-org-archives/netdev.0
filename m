From: Valentijn Sessink <valentyn@blub.net>
Subject: Re: [PATCH net 2/2] ipv6: ip6_dst_check needs to check for expired
 dst_entries
Date: Thu, 24 Oct 2013 09:49:07 +0200
Message-ID: <5268D0F3.3080904@blub.net>
References: <20131024054824.GA15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([144.76.204.185]:37675 "EHLO
	filter.openoffice.nl" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754035Ab3JXH6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 03:58:42 -0400
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id 411D9800D9
	for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 09:48:57 +0200 (CEST)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (filter.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id niEcfjsH1DRC for <netdev@vger.kernel.org>;
	Thu, 24 Oct 2013 09:48:55 +0200 (CEST)
Received: from blub.net (unknown [IPv6:2001:7b8:1529:0:5054:ff:fe70:c2c4])
	by filter.openoffice.nl (Postfix) with ESMTP id 3E087800D8
	for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 09:48:55 +0200 (CEST)
Received: from [IPv6:2001:1af8:ff03:3:219:66ff:fe26:6dd] (unknown [IPv6:2001:1af8:ff03:3:219:66ff:fe26:6dd])
	by blub.net (Postfix) with ESMTPSA id EA42A30013B
	for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 09:48:54 +0200 (CEST)
In-Reply-To: <20131024054824.GA15744@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24-10-13 07:48, Hannes Frederic Sowa wrote:
> On receiving a packet too big icmp error we check if our current cached
> dst_entry in the socket is still valid. This validation check did not
> care about the expiration of the (cached) route.
> 
> The error path I traced down:
> The socket receives a packet too big mtu notification. It still has a
> valid dst_entry and thus issues the ip6_rt_pmtu_update on this dst_entry,
> setting RTF_EXPIRE and updates the dst.expiration value (which could
> fail because of not up-to-date expiration values, see previous patch).
> 
> In some seldom cases we race with a) the ip6_fib gc or b) another routing
> lookup which would result in a recreation of the cached rt6_info from its
> parent non-cached rt6_info. While copying the rt6_info we reinitialize the
> metrics store by copying it over from the parent thus invalidating the
> just installed pmtu update (both dsts use the same key to the inetpeer
> storage). The dst_entry with the just invalidated metrics data would
> just get its RTF_EXPIRES flag cleared and would continue to stay valid
> for the socket.
> 
> We should have not issued the pmtu update on the already expired dst_entry
> in the first placed. By checking the expiration on the dst entry and
> doing a relookup in case it is out of date we close the race because
> we would install a new rt6_info into the fib before we issue the pmtu
> update, thus closing this race.
> 
> Not reliably updating the dst.expire value was fixed by the patch "ipv6:
> reset dst.expires value when clearing expire flag".
> 
> Reported-by: Steinar H. Gunderson <sgunderson@bigfoot.com>
> Reported-by: Valentijn Sessink <valentyn@blub.net>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> I would propose this patch for -stable.
> 
>  net/ipv6/route.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f54e3a1..04e17b3 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1087,10 +1087,13 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
>  	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
>  		return NULL;
>  
> -	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
> -		return dst;
> +	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
> +		return NULL;
>  
> -	return NULL;
> +	if (rt6_check_expired(rt))
> +		return NULL;
> +
> +	return dst;
>  }
>  
>  static struct dst_entry *ip6_negative_advice(struct dst_entry *dst)

Tested-by: Valentijn Sessink <valentyn@blub.net>
