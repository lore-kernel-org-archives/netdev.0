From: David Miller <davem@davemloft.net>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 26 Jun 2013 15:15:34 -0700 (PDT)
Message-ID: <20130626.151534.2092603828301381561.davem@davemloft.net>
References: <1372238996.3301.149.camel@edumazet-glaptop>
	<1372245307.3301.171.camel@edumazet-glaptop>
	<20130626130748.GC20081@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davej@redhat.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab3FZWPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:15:37 -0400
In-Reply-To: <20130626130748.GC20081@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 26 Jun 2013 15:07:48 +0200

> On Wed, Jun 26, 2013 at 04:15:07AM -0700, Eric Dumazet wrote:
>> Following patch fixes the problem for me :
> 
> Cool, thanks Eric!
> 
>> [PATCH] ipv6: ip6_sk_dst_check() must not assume ipv6 dst
>> 
>> It's possible to use AF_INET6 sockets and to connect to an IPv4
>> destination. After this, socket dst cache is a pointer to a rtable,
>> not rt6_info.
> 
> That was my hunch, too. I was unsure where we should destroy the lingering dst.
> 
>> ip6_sk_dst_check() should check the socket dst cache is IPv6, or else
>> various corruptions/crashes can happen.
>> 
>> Dave Jones can reproduce immediate crash with 
>> trinity -q -l off -n -c sendmsg -c connect
>> 
>> With help from Hannes Frederic Sowa
>> 
>> Reported-by: Dave Jones <davej@redhat.com>
>> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Patch looks good. It also fixes some panics I have seen down lower in
> the netfilter ipv6 code I saw while testing, which I thought may be a
> different issue.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Ok, so the issue can only happen if we switch between using an
ipv4 and an ipv6 binding on an ipv6 socket.  Usually if the sockaddr
specified for udp6_sendmsg() is ipv4, we'd go straight to udp_sendmsg().
But if it's ipv4 bound initially, then we get a udp6_sendmsg() with
an ipv6 address, we hit this problem.

Applied and queued up for -stable, thanks!
