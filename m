From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Fri, 28 Sep 2007 21:47:37 -0700 (PDT)
Message-ID: <20070928.214737.120464821.davem@davemloft.net>
References: <46FD0117.9030407@hitachi.com>
	<E1IbSt7-000091-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satoshi.oshima.fk@hitachi.com, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, haoki@redhat.com, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41535
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751676AbXI2Ern (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 00:47:43 -0400
In-Reply-To: <E1IbSt7-000091-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 29 Sep 2007 11:21:05 +0800

> Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> wrote:
> >
> > In such case, from 300 to 500MB memory consumption will
> > be fatal. Users can easily open 1000 sockets per process
> > under default ulimit. If such sockets hold messages but
> > user processes don't receive it. Almost all slab will
> > be occupied by sk_buff.
> 
> Well the solution to that is to have a per-user limit rather
> than a system-wide limit.  Otherwise any user can stop system
> daemons from using UDP.

Per-user limits are not necessarily the answer.

There are two things we (might) need to guard against, one local and
one remote.

Originally the TCP global memory accounting was added to handle remote
issues.  You could really make apache do stupid things without it.
Open up a ton of connections to a web server, request a ton of
data, don't read any of it.

When we get into the red zone, we purge out of order queues and other
packet allocations that are expendable.  Legitimate active connections
can thus make progress and allocate packets.  More importantly the
amount of memory usable by TCP sockets is bounded by some limit.

But this limit is arbitrary and easily wrong.  If my system is just
sending one static file to hundreds of thousands of clients, well
then using %99 of RAM for socket buffer memory is just fine.  That
is not how the global accounting works, unfortunately.  It doesn't
know what's happening, it doesn't "respond" to any stimulus to
control memory use.  It just understands it's local state and it's
local limits.  It's a very poor way to handle the problem.

If you do a per-user limit, apache would basically just stop at that
redzone point.  In some sense making the attack more effective because
then it's trivial to shut down an entire web server this way.

In my opinion this stuff needs to be reinvestigated more deeply.  In
fact I think the stuff we have for TCP is insufficient and/or
ineffective.

Furthermore, the fact that there is even the slightest urge to
duplicate this for UDP should be a big red flag that we need a better
solution.

The fact is that the networking does not participate with the rest
of the system wrt. memory pressure callbacks.  That's the problem.

I've mentioned before that things like the routing cache should
register trimming callbacks just like the dcache and inode cache
already do.

I see no valid argument against doing something similar for sockets.
Such a register_shrinker() handler for TCP could, for example, look
for TCP flows which haven't made forward progress in more than a
certain amount of time and attempt to trim SKB memory from them.

A shrinker callback could also be used to adjust any global socket
memory limit scheme we might have.  Set the limit real high initially,
but then scale it back if we get a lot of shrinker calls.

UDP and other datagram sockets are troublesome because the memory
gets wholly tied up immediately during the send call and it's not
easy to liberate anything.  The nice part about datagram sockets,
however, is that they make forward progress quickly and their
memory is liberated as soon as the device transmits the packet.
They don't have to wait for ACKs, windows openning up, or anything
like that to happen.

To be honest I don't even think UDP is much of a real problem for this
reason.
