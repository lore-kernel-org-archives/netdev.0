From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] ipv6: ip6_dst_check needs to check for expired
 dst_entries
Date: Wed, 23 Oct 2013 23:40:56 -0700
Message-ID: <1382596856.7572.43.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131024054824.GA15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgunderson@bigfoot.com, valentyn@blub.net,
	yoshfuji@linux-ipv6.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:35293 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab3JXGlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 02:41:00 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so928506eaj.26
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 23:40:59 -0700 (PDT)
In-Reply-To: <20131024054824.GA15744@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 07:48 +0200, Hannes Frederic Sowa wrote:
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

Excellent, thanks a lot !

Reviewed-by: Eric Dumazet <edumazet@google.com>
