From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: TODO list before feature freeze
Date: 29 Jul 2002 19:12:31 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1027962751.12630.92.camel@tux>
References: <20020729131239.A5183@wotan.suse.de>
	<Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>
	<20020729135615.A20412@wotan.suse.de> <1027957218.12610.71.camel@tux>
	<20020729181501.C570@oknodo.bof.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, jamal <hadi@cyberus.ca>,
   Rusty Russell <rusty@rustcorp.com.au>,
   Netfilter-devel <netfilter-devel@lists.netfilter.org>, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Patrick Schaaf <bof@bof.de>
In-Reply-To: <20020729181501.C570@oknodo.bof.de>
List-Id: netdev.vger.kernel.org

On Mon, 2002-07-29 at 18:15, Patrick Schaaf wrote:


> > Martin Josefsson wrote:
> > I think the list_heads are used for only one thing currently, for the
> > early eviction in case of overload,
> 
> Don't forget the nonscanning list_del(), called whenever a conntrack
> is unhashed at it's death. However, with a suitable bucket number,
> i.e. low chain lengths, the scan on conntrack removal would be OK.

Oh I forgot about that.
 
> The early_drop() scanning, if it wants to work backward, may as well
> work forward, keeping a "last unreplied found" pointer, and returning
> that when falling off the single list end.
> 
> Thus, I also think that the list could be simple.

The comment says that we are scanning backwards but the code says we are
scanning forward without keeping a "last unreplied found" pointer, we
just return the first unreplied found.

So going to a single linked list and adding that would probably be
better than the current behaviour.
 
> > I know I've had plans on rewriting the locking in conntrack which is
> > quite frankly horrible, one giant rwlock used for almost everything
> > (including the hashtable).
> 
> I'd like to see lockmeter statistics before this change. When you split
> the one lock into a sectored lock: each conntrack is hashed twice, so
> you need to be careful with lock order when adding or removing.
> (well, there is another possibility, but I won't go into that now)

The main reason is that I'd like conntrack to hold up better under
attacks. I'll see if I can produce some lockmeter statistics later this
week.
 
> > One idea that has come to mind is using RCU
> 
> I don't see RCU solving hash link list update problems. Care to explain
> how that would work?

Have you seen the rtcache RCU patch? it almost halved the time spent
doing the lookups because of no lock bouncing between cpu's. But RCU is
best suited for things that can tolerate stale data on reads, something
which we can not. I've spoken to Hana Linder who is one of the RCU
people and she said that the dcache RCU patch uses some techniques to
solve this as the dcache can't tolerate stale data either.

I havn't investigated this yet but it got my attention.

But the fact is that not many routers are SMP machines.
Maybe it could help some very busy SMP servers?

> > And this eviction which occurs at overload needs to be redone, we can't
> > go around dropping one unreplied connection at a time, we need
> > gang-eviction of unreplied connections.
> 
> I propose to put them all on a seperate LRU list, and reap the oldest.

I proposed this as well and then James Morris shot me down :)

What about the case where someone tries to DoS a specific chain?

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
