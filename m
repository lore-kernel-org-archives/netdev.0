From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4 routing: Fixes to allow route cache entries to
	work when route caching is disabled
Date: Mon, 22 Jun 2009 13:03:27 -0400
Message-ID: <20090622170327.GA14673@hmsreliant.think-freely.org>
References: <20090622152314.GB14359@hmsreliant.think-freely.org> <20090622165145.GA2737@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, mbizon@freebox.fr
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40017 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbZFVRDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 13:03:35 -0400
Content-Disposition: inline
In-Reply-To: <20090622165145.GA2737@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 06:51:45PM +0200, Jarek Poplawski wrote:
> On Mon, Jun 22, 2009 at 11:23:14AM -0400, Neil Horman wrote:
> > Hey all-
> > 	As we've been discussing recently, There are a few bugs with routing if
> > we exceed our route cache rebuild count, and subsequently disable route caching.
> > An oops was reported to me, which has been subsequently fixed, and then
> > subsequently a route cache leak and failure to forward frames was reported to me
> > when rt_caching returns false.  I've reproduced these on a local system, and
> > tracked down the cause.  This patch fixes both of these problems for me on my
> > test system.
> > 
> > 
> >     Ensure that route cache entries are usable and reclaimable when caching is off
> >     
> >     When route caching is disabled (rt_caching returns false), We still use route
> >     cache entries that are created and passed into rt_intern_hash once.  These
> >     routes need to be made usable for the one call path that holds a reference to
> >     them, and they need to be reclaimed when they're finished with their use.  To be
> >     made usable, they need to be associated with a neighbor table entry (which they
> >     currently are not), otherwise iproute_finish2 just discards the packet, since we
> >     don't know which L2 peer to send the packet to.  To do this binding, we need to
> >     follow the path a bit higher up in rt_intern_hash, which calls
> >     arp_bind_neighbour, but not assign the route entry to the hash table.
> >     Currently, if caching is off, we simply assign the route to the rp pointer and
> >     are reutrn success.  This patch associates us with a neighbor entry first.
> >     
> >     Secondly, we need to make sure that any single use routes like this are known to
> >     the garbage collector when caching is off.  If caching is off, and we try to
> >     hash in a route, it will leak when its refcount reaches zero.  To avoid this,
> >     this patch calls rt_free on the route cache entry passed into rt_intern_hash.
> >     This places us on the gc list for the route cache garbage collector, so that
> >     when its refcount reaches zero, it will be reclaimed (Thanks to Alexey for this
> >     suggestion).
> >     
> >     I've tested this on a local system here, and with these patches in place, I'm
> >     able to maintain routed connectivity to remote systems, even if I set
> >     /proc/sys/net/ipv4/rt_cache_rebuild_count to -1, which forces rt_caching to
> >     return false.
> >     
> >     Best
> >     Neil
> >     
> >     Signed-off-by: Neil Horman <nhorman@redhat.com>
> >     Reported-by: Jarek Poplawski <jarkao2@gmail.com>
> >     Reported-by: Maxime Bizon <mbizon@freebox.fr>
> > 
> > 
> >  route.c |   44 ++++++++++++++++++++++++++------------------
> >  1 file changed, 26 insertions(+), 18 deletions(-)
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 65b3a8b..4b21513 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1076,6 +1076,7 @@ static int rt_intern_hash(unsigned hash, struct rtable *rt,
> >  	u32 		min_score;
> >  	int		chain_length;
> >  	int attempts = !in_softirq();
> > +	int caching = rt_caching(dev_net(rt->u.dst.dev));
> >  
> >  restart:
> >  	chain_length = 0;
> > @@ -1084,7 +1085,7 @@ restart:
> >  	candp = NULL;
> >  	now = jiffies;
> >  
> > -	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> > +	if (!caching) {
> >  		/*
> >  		 * If we're not caching, just tell the caller we
> >  		 * were successful and don't touch the route.  The
> > @@ -1093,8 +1094,12 @@ restart:
> >  		 * If we drop it here, the callers have no way to resolve routes
> >  		 * when we're not caching.  Instead, just point *rp at rt, so
> >  		 * the caller gets a single use out of the route
> > +		 * Note that we do rt_free on this new route entry, so that
> > +		 * once its refcount hits zero, we are still able to reap it
> > +		 * (Thanks Alexey)
> 
> I hope Alexey Dobriyan won't be confused... 
> 
> >  		 */
> > -		goto report_and_exit;
> > +		rt_free(rt);
> 
> To save some coulds & woulds in the future I'd(!) prefer here
> dst_free() yet.
Not sure I see the advantage.  The path winds up being the same regardless, the
typing matches up with the rt_free call, and by using the RCU path we are given
the possibility to batch a bunch of spinlocks in the cache at an RCU quiesence
point.


> 
> > +		goto skip_hashing;
> 
> Aren't we jumping over a spin_lock here?
> 
We are jumping over a spinlock, both the acquire and release, which is exactly
what we want, since when rt_caching returns false, we're not adding the route
cache entry into the hash table, which is what that lock protects.

Neil

