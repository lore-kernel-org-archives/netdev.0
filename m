From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 06:31:11 +0200
Message-ID: <1340080271.7491.2187.camel@edumazet-glaptop>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
	 <1340078846.7491.2127.camel@edumazet-glaptop>
	 <20120618.211539.105938285016510975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60344 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab2FSEbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:31:15 -0400
Received: by eaak11 with SMTP id k11so1806762eaa.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:31:14 -0700 (PDT)
In-Reply-To: <20120618.211539.105938285016510975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 21:15 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > This reminds the idea of having seperate dst per tcp socket, to remove
> > the dst refcnt contention as well.
> 
> I'm leery of this.
> 
> We're going to move towards having dst entries more strongly shared
> as we move to remove the routing cache.
> 
> In fact I have another short-term change planned that adjusts which
> keys the routing cache uses based upon what kinds of keys are actually
> active in the current FIB rule configuration.
> 
> I think we want to encourage sharing and make the route footprint
> smaller rather than expanding it's size artificually on even the
> socket level.
> 
> If you really care about this refcount problem, then it's another
> reason to never orphan socket sourced packets.  Then we wouldn't need
> to ever refcount the route just to send a packet, we'd just use the
> implicit reference held by the socket instead.  Socket route releasing
> would be held back by the presence of any packets in the socket send
> queue.  If we have to reset the dst mis-lifetime due to route flushes,
> we'd need to use a specific packet as a sequence point.
> 
> That to me sounds like a more reasonable approach than just making
> more and more routes.

We already don't touch dst refcnt on TCP xmit path, unless packet is
parked in Qdisc queue...

But with BQL this is becoming less effective.
