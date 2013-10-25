From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] ipv6: ip6_dst_check needs to check for expired
 dst_entries
Date: Fri, 25 Oct 2013 19:27:54 -0400 (EDT)
Message-ID: <20131025.192754.2262366143114667976.davem@davemloft.net>
References: <20131024054824.GA15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgunderson@bigfoot.com, valentyn@blub.net,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558Ab3JYX1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:27:55 -0400
In-Reply-To: <20131024054824.GA15744@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 24 Oct 2013 07:48:24 +0200

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

Applied and queued up for -stable.
