From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: use a stronger hash for tcp
Date: Thu, 21 Feb 2013 23:43:16 +0100
Message-ID: <20130221224316.GA9671@order.stressinduktion.org>
References: <1361485132.17413.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49302 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab3BUWnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 17:43:18 -0500
Content-Disposition: inline
In-Reply-To: <1361485132.17413.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 02:18:52PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> It looks like its possible to open thousands of TCP IPv6
> sessions on a server, all landing in a single slot of TCP hash
> table. Incoming packets have to lookup sockets in a very
> long list.
> 
> We should hash all bits from foreign IPv6 addresses, using
> a salt and hash mix, not a simple XOR.
> 
> inet6_ehashfn() can also separately use the ports, instead
> of xoring them.

I like this change. Some weeks ago I have looked at the tcp-metrics
cache if the weak ipv6 xor hashes could be used to have negative impact
on servers. Luckily the maximum length of the lists is checked to not
grow beyond 5 entries (after that reclamation kicks in).

With IPv6 this seems to be a new attack scenario with each user having
a /64 they could generate about 2^32 hash colliding ipv6 addresses
(in case of xor hashing) where a full tcp 3whs and shutdown could be made.

Perhaps we should use ipv6_addr_jhash in the destination cache, too, and look
at other uses of ipv6_addr_hash?
