From: "Lubashev, Igor" <ilubashe@akamai.com>
Subject: RE: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Mon, 4 Jun 2012 15:04:24 -0400
Message-ID: <83CE6FF8F6C9B2468A618FC2C51267260F3319AFDD@USMBX1.msg.corp.akamai.com>
References: <83CE6FF8F6C9B2468A618FC2C51267260F303CD88B@USMBX1.msg.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Arun Sharma <asharma@fb.com>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([96.6.114.97]:45931 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752391Ab2FDTE1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 15:04:27 -0400
In-Reply-To: <83CE6FF8F6C9B2468A618FC2C51267260F303CD88B@USMBX1.msg.corp.akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David and Eric,

Any news about this?  We definitely have many machines that are experiencing abnormal behavior under ipv6 load.  The machines are healthier when the ipv6 route cache is increased to 64K, but I am afraid this is a band-aid that is hiding the actual problems.

So, could you address the concerns about the code in fib6_age?  I can see three potential problems with it:

1.  The meaning/use of NTF_ROUTER flag is inverted in 3.4

2.  A potential NULL-pointer exception in pre-3.4 versions.  In particular, "rt->rt6i_nexthop" (version 2.6.37) is checked for NULL in (almost?) all cases of referencing that field.  I do not know for sure about "dst_get_neighbour_raw(&rt->dst)" in 3.0.32.

3.   In all cases, an RTF_GATEWAY entry with __refcount > 0 may be garbage collected.  That seems like a wrong thing to do.  Is it?

Thank you!

- Igor


-----Original Message-----
From: Lubashev, Igor 
Sent: Wednesday, May 30, 2012 7:50 PM
To: David Miller; Arun Sharma
Cc: eric.dumazet@gmail.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size

>It's possible that there is a bug somewhere - we didn't get a chance to 
>dig deeper. What we observed is that as we got close to the 4096 limit, 
>some hosts were becoming unreachable. A modest increase in the routing 
>table size made things better.

First of all, we have observed the same thing.

While I am not an expert in this area of the routing code, the function fib6_age in net/ipv6/ip6_fib.c puzzles me.


In kernel version 2.6.37, we have net/ipv6/ip6_fib.c:
static int fib6_age(struct rt6_info *rt, void *arg) {
	unsigned long now = jiffies;

	if (rt->rt6i_flags&RTF_EXPIRES && rt->rt6i_expires) {
		if (time_after(now, rt->rt6i_expires)) {
			RT6_TRACE("expiring %p\n", rt);
			return -1;
		}
		gc_args.more++;
	} else if (rt->rt6i_flags & RTF_CACHE) {
		if (atomic_read(&rt->dst.__refcnt) == 0 &&
		    time_after_eq(now, rt->dst.lastuse + gc_args.timeout)) {
			RT6_TRACE("aging clone %p\n", rt);
			return -1;
		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
			   (!(rt->rt6i_nexthop->flags & NTF_ROUTER))) {
			RT6_TRACE("purging route %p via non-router but gateway\n",
				  rt);
			return -1;
		}
		gc_args.more++;
	}

	return 0;
}


In kernel 3.0.32, we have net/ipv6/ip6_fib.c:
static int fib6_age(struct rt6_info *rt, void *arg) {
	unsigned long now = jiffies;

	if (rt->rt6i_flags&RTF_EXPIRES && rt->rt6i_expires) {
		if (time_after(now, rt->rt6i_expires)) {
			RT6_TRACE("expiring %p\n", rt);
			return -1;
		}
		gc_args.more++;
	} else if (rt->rt6i_flags & RTF_CACHE) {
		if (atomic_read(&rt->dst.__refcnt) == 0 &&
		    time_after_eq(now, rt->dst.lastuse + gc_args.timeout)) {
			RT6_TRACE("aging clone %p\n", rt);
			return -1;
		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
			   (!(dst_get_neighbour_raw(&rt->dst)->flags & NTF_ROUTER))) {
			RT6_TRACE("purging route %p via non-router but gateway\n",
				  rt);
			return -1;
		}
		gc_args.more++;
	}

	return 0;
}


In kernel 3.4, we have net/ipv6/ip6_fib.c:
static int fib6_age(struct rt6_info *rt, void *arg) {
	unsigned long now = jiffies;

	if (rt->rt6i_flags & RTF_EXPIRES && rt->dst.expires) {
		if (time_after(now, rt->dst.expires)) {
			RT6_TRACE("expiring %p\n", rt);
			return -1;
		}
		gc_args.more++;
	} else if (rt->rt6i_flags & RTF_CACHE) {
		if (atomic_read(&rt->dst.__refcnt) == 0 &&
		    time_after_eq(now, rt->dst.lastuse + gc_args.timeout)) {
			RT6_TRACE("aging clone %p\n", rt);
			return -1;
		} else if (rt->rt6i_flags & RTF_GATEWAY) {
			struct neighbour *neigh;
			__u8 neigh_flags = 0;

			neigh = dst_neigh_lookup(&rt->dst, &rt->rt6i_gateway);
			if (neigh) {
				neigh_flags = neigh->flags;
				neigh_release(neigh);
			}
			if (neigh_flags & NTF_ROUTER) {
				RT6_TRACE("purging route %p via non-router but gateway\n",
					  rt);
				return -1;
			}
		}
		gc_args.more++;
	}

	return 0;
}


Do we have the meaning of the NTF_ROUTER flag reversed in kernel 3.4?  Or is the opposite use of that flag a fix for the bug in the previous releases? Or is this a bug in kernel 3.4?

Also, could this remove a Gateway entry, if there is no neighbor entry for it (in any of the version of the code)?  Could this try to deference a null pointer in 3.0.32 version of the code (and any version prior to 3.4)?  In general, is this the right place to remove a gateway route that has __refcnt > 0?

I wish I had more expertise in this area of the code to answer questions and not only to pose them.

Thank you,

- Igor
