From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: make TCP preemptible
Date: Thu, 28 Apr 2016 10:51:56 -0700
Message-ID: <20160428175154.GA83737@ast-mbp.thefacebook.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
 <20160428172320.GA83199@ast-mbp.thefacebook.com>
 <1461865270.5535.109.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35609 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbcD1RwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 13:52:02 -0400
Received: by mail-pf0-f173.google.com with SMTP id 77so3958469pfv.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 10:52:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1461865270.5535.109.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 10:41:10AM -0700, Eric Dumazet wrote:
> On Thu, 2016-04-28 at 10:23 -0700, Alexei Starovoitov wrote:
> > On Wed, Apr 27, 2016 at 10:25:46PM -0700, Eric Dumazet wrote:
> > > Most of TCP stack assumed it was running from BH handler.
> > > 
> > > This is great for most things, as TCP behavior is very sensitive
> > > to scheduling artifacts.
> > > 
> > > However, the prequeue and backlog processing are problematic,
> > > as they need to be flushed with BH being blocked.
> > > 
> > > To cope with modern needs, TCP sockets have big sk_rcvbuf values,
> > > in the order of 16 MB.
> > > This means that backlog can hold thousands of packets, and things
> > > like TCP coalescing or collapsing on this amount of packets can
> > > lead to insane latency spikes, since BH are blocked for too long.
> > > 
> > > It is time to make UDP/TCP stacks preemptible.
> > > 
> > > Note that fast path still runs from BH handler.
> > 
> > this looks pretty awesome.
> 
> Yes, I am pretty excited ;)
> 
> > the change will make the backlog run in bh enabled, so that one
> > large flow reciever will not penalize the rest of the system, right?
> 
> Not only large flows, but flows with losses/reorders.
> Typically many flows are in this case when a congestion collapse
> happens.
> 
> 
> 
> > but you're saying that prequeue is also expensive, but not touched
> > by this patchset? was it addressed by your eariler patch?
> > Or more work still tbd?
> 
> prequeue is handled by "[2/6] tcp: do not block bh during prequeue
> processing"

got it. It applies to both v4 and v6, right?

> Note that I also sent a patch earlier (("tcp: give prequeue mode some
> care")) to control max size of prequeue to 32 packets.
> 
> > I'm just trying to understand more about tcp stack.
> > 
> Sure ;)
> 
> I also have a patch to add scheduling point in sendmsg() (ie : draining
> the backlog if not empty) for each new skb added to the write queue.
> 
> Since each skb is about 64KB (with GSO/TSO), it means an application no
> longer will hold the socket lock too long, even when doing a
> write()/sendmsg() of say 8 MB at once ;)

that would be awesome. I think map/reduce type jobs typically
do large sendmsg, so it should help p99 latency.
