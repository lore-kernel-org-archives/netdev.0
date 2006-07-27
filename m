From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 26 Jul 2006 22:17:08 -0700 (PDT)
Message-ID: <20060726.221708.123400049.davem@davemloft.net>
References: <20060718081625.GA13830@2ka.mipt.ru>
	<20060718230121.GA31474@ms2.inr.ac.ru>
	<1153966671.6904.71.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11927
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750856AbWG0FQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 01:16:48 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1153966671.6904.71.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 27 Jul 2006 12:17:51 +1000

> On Wed, 2006-07-19 at 03:01 +0400, Alexey Kuznetsov wrote:
> > About locks:
> > 
> > > 	  is completely lockless (there is one irq lock when skb 
> > > is queued/dequeued into netchannels queue in hard/soft irq, 
> > 
> > Equivalent of socket spinlock.
> 
> I don't think they are equivalent.  In channels, this can be split into
> two locks, queue lock and an dequeue lock, which operate independently.
> The socket spinlock cannot.  Moreover, in the case where there is a
> guarantee about IRQs being bound to a single CPU (as Dave's ideas on
> MSI), the queue lock is no longer required.  In the case where there is
> a single reader of the socket (or, as VJ did, the other end is in
> userspace), no dequeue lock is required.

Cost is a very interesting question here.  I guess your main point
is that eventually this lock can be made to go away, whereas
Alexey speaks about the state of Evgivny's specific implementation.

> My feeling is that modern cards will do partial demux for us; whether we
> use netchannels or not, we should use that to accelerate lookup.  Making
> card aim MSI at same CPU for same flow is a start (and as Dave said,
> much less code).  As the next step, having the card give us a cookie
> too, would allow us to explicitly skip first level of lookup.  This
> should allow us to identify which flows are simple enough to be directly
> accelerated (whether by channels or something else): no bonding, raw
> sockets, non-trivial netfilter rules, connection tracking changes, etc.

I read this as "we will be able to get around the problems" but
no specific answer as to "how".  I am an optimist too but I want
to start seeing concrete discussion about the way in which the
problems will be dealt with.

Alexey has some ideas, such as running the netfilter path from the
netchannel consumer socket context.  That is the kind of thing
we need to be talking about.

Robert Olsson is also doing some work involving full flow
classifications using special trie structures in the routing cache
that might be extendable to netchannels.  His trick is to watch for
the FIN shutdown sequence and GC route cache entries for a flow when
this is seen.  This is in order to keep the trie shallow and thus have
a better bound on memory accesses for routing lookups.

We are not a group of mathematicians discussing the tractability of
some problem.  Our interest is practice not theory. :)



