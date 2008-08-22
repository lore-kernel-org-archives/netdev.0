From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Fri, 22 Aug 2008 09:43:42 -0400
Message-ID: <1219412622.4672.34.camel@localhost>
References: <20080721164306.GA13131@gondor.apana.org.au>
	 <20080721.095124.89249903.davem@davemloft.net>
	 <20080721170233.GA13417@gondor.apana.org.au>
	 <20080721.100821.38432201.davem@davemloft.net>
	 <20080721171141.GA13573@gondor.apana.org.au>
	 <20080822065655.GA18471@gondor.apana.org.au>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080822065655.GA18471-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-22-08 at 16:56 +1000, Herbert Xu wrote:
> On Tue, Jul 22, 2008 at 01:11:41AM +0800, Herbert Xu wrote:
> > On Mon, Jul 21, 2008 at 10:08:21AM -0700, David Miller wrote:

> I haven't had a chance to do the test yet but I've just had an
> idea of how we can get the best of both worlds.
> 
> The problem with always directing traffic based on the CPU alone
> is that processes move around and we don't want to introduce packet
> reordering because to that.

Assuming multi-rx queues with configurable MSI or otherwise to map
to a receive processor, then in the case of routing/bridging or
otherfavoriteformofforwarding:
If you tie static filters to a specific cpu that will always work.
So no reordering there.
Local traffic i can see migration/reordering happening.

> The problem with hashing based on packet headers alone is that
> it doesn't take CPU affinity into account at all so we may end
> up with a situation where one thread out of a thread pool (e.g.,
> a web server) has n sockets which are hashed to n different
> queues.

Indeed. In the forwarding case, the problem is not reordering rather
all flows will always end up in the same cpu. So if you may end up
just overloading one cpu while the other 1023 stayed idle.
My earlier statement was you could cook traffic scenarios where all
1024 are being fully utilized (the operative term is "cook");->

> So here's the idea, we determine the tx queue for a flow based
> on the CPU on which we saw its first packet.  Once we have decided
> on a queue we store that in a dst object (see below).  This
> ensures that all subsequent packets of that flow ends up in
> the same queue so there is no reordering.  It also avoids the
> problem where traffic genreated by one CPU gets scattered across
> queues.

Wont work with static multi-rx nic; iirc, changing those filters is
_expensive_. so you want it to stay static.

cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
