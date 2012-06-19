From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 21:15:39 -0700 (PDT)
Message-ID: <20120618.211539.105938285016510975.davem@davemloft.net>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
	<1340078846.7491.2127.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab2FSEPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:15:40 -0400
In-Reply-To: <1340078846.7491.2127.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Jun 2012 06:07:26 +0200

> On Mon, 2012-06-18 at 19:40 -0700, David Miller wrote:
>> You know you want it.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Yeah, very good idea David ;)
> 
> needs some polishing of course.

Such as?  IPv6 support?

> This reminds the idea of having seperate dst per tcp socket, to remove
> the dst refcnt contention as well.

I'm leery of this.

We're going to move towards having dst entries more strongly shared
as we move to remove the routing cache.

In fact I have another short-term change planned that adjusts which
keys the routing cache uses based upon what kinds of keys are actually
active in the current FIB rule configuration.

I think we want to encourage sharing and make the route footprint
smaller rather than expanding it's size artificually on even the
socket level.

If you really care about this refcount problem, then it's another
reason to never orphan socket sourced packets.  Then we wouldn't need
to ever refcount the route just to send a packet, we'd just use the
implicit reference held by the socket instead.  Socket route releasing
would be held back by the presence of any packets in the socket send
queue.  If we have to reset the dst mis-lifetime due to route flushes,
we'd need to use a specific packet as a sequence point.

That to me sounds like a more reasonable approach than just making
more and more routes.
