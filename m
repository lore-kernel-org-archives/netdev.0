From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Sat, 20 Jun 2009 13:11:16 -0400
Message-ID: <20090620171116.GA24515@localhost.localdomain>
References: <20090619171814.GE18237@hmsreliant.think-freely.org> <4A3CD7EC.2040904@gmail.com> <4A3D10BD.3050301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mbizon@freebox.fr, dada1@cosmosbay.com,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36779 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753518AbZFTRLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 13:11:19 -0400
Content-Disposition: inline
In-Reply-To: <4A3D10BD.3050301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2009 at 06:39:25PM +0200, Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 06/20/2009 02:37 PM:
> 
> > Neil Horman wrote, On 06/19/2009 07:18 PM:
> > 
> >> Don't drop route if we're not caching	
> 
> ...
> 
> >>  route.c |   14 ++++++++++++--
> >>  1 file changed, 12 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> >> index cd76b3c..65b3a8b 100644
> >> --- a/net/ipv4/route.c
> >> +++ b/net/ipv4/route.c
> >> @@ -1085,8 +1085,16 @@ restart:
> >>  	now = jiffies;
> >>  
> >>  	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> >> -		rt_drop(rt);
> 
> 
> One more question: if this rt is assigned to an skb, there is only
> skb_dst_drop() in kfree_skb(), but it seems we skip rt_free() part,
> or I miss something?
> 
no, you're right.  That actually seems to be more general problem, independent
of the one I just fixed.  As I understand it, skb_dst_drop is intended to
release the reference on a route cache entry that it grabbed previously, but
specifically avoids going throught the free path that rt_drop implements
(ostensibly so that the garbage collector will clean it up later from the route
cache).  With the recent work that lets us disable the garbage collector
entirely, and simply not cache, this path seems like it will leak routes if an
skb holds the last reference to a route cache entry.  What we likely need to do
is enhance rt_caching to return true in the event that the garbage collector is
off or if the cache has been attacked (rebuilt too many times).  Then we need to
export that function and check it in skb_dst_drop, calling call_rcu_bh to free
the dst entry if rt_caching is false, and the dst entries refcnt is zero (or
something like that).  I'll look into this further and address it in a separate
thread.  Thanks, and good catch!
Neil

> Jarek P.
> 
> >> -		return 0;
> >> +		/*
> >> +		 * If we're not caching, just tell the caller we
> >> +		 * were successful and don't touch the route.  The
> >> +		 * caller hold the sole reference to the cache entry, and
> >> +		 * it will be released when the caller is done with it.
> >> +		 * If we drop it here, the callers have no way to resolve routes
> >> +		 * when we're not caching.  Instead, just point *rp at rt, so
> >> +		 * the caller gets a single use out of the route
> >> +		 */
> >> +		goto report_and_exit;
> >>  	}
> >>  
> >>  	rthp = &rt_hash_table[hash].chain;
> >> @@ -1217,6 +1225,8 @@ restart:
> >>  	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
> >>  
> >>  	spin_unlock_bh(rt_hash_lock_addr(hash));
> >> +
> >> +report_and_exit:
> >>  	if (rp)
> >>  		*rp = rt;
> >>  	else
> 
> 
> 
