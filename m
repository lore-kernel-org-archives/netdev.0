From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Wed, 16 Mar 2016 19:53:41 -0400 (EDT)
Message-ID: <20160316.195341.68257764618999441.davem@davemloft.net>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935223AbcCPXxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 19:53:43 -0400
In-Reply-To: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Mon, 14 Mar 2016 13:59:47 -0700

> From: Wei Wang <weiwan@google.com>
> 
> When ICMPV6_PKT_TOOBIG message is received by a connected UDP socket,
> the new mtu value is not properly updated in the dst_entry associated
> with the socket.
> This leads to the issue that the mtu value returned by getsockopt(sockfd,
> IPPROTO_IPV6, IPV6_MTU, ...) is wrong.
> The fix is to update sk->sk_dst_cache and other corresponding fields
> when a new routing cache is allocated for the new pmtu in UDP connected
> socket case.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>

Wait a second:

>  		if (nrt6) {
>  			rt6_do_update_pmtu(nrt6, mtu);
> -
> -			/* ip6_ins_rt(nrt6) will bump the
> -			 * rt6->rt6i_node->fn_sernum
> -			 * which will fail the next rt6_check() and
> -			 * invalidate the sk->sk_dst_cache.
> -			 */
> +			if (sk)
> +				ip6_dst_store(sk, &nrt6->dst, daddr, saddr);
>  			ip6_ins_rt(nrt6);
>  		}
>  	}

I still haven't seen a satisfactory answer as to why the as-designed
invalidation mechanism using fn_sernum is not working.

If that's broken, then a lot of other things won't work properly
either.

I've read the ip6_ins_rt() code path several times, and it always
increments the serial number, and therefore the next dst->check() call
(which every cached route usage should invoke) should invalide
this socket's route and lookup the new one.

Why does this not work?
