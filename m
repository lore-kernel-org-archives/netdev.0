From: "Lubashev, Igor" <ilubashe@akamai.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Wed, 30 May 2012 19:50:15 -0400
Message-ID: <83CE6FF8F6C9B2468A618FC2C51267260F303CD88B@USMBX1.msg.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>It's possible that there is a bug somewhere - we didn't get a chance to 
>dig deeper. What we observed is that as we got close to the 4096 limit, 
>some hosts were becoming unreachable. A modest increase in the routing 
>table size made things better.

First of all, we have observed the same thing.

While I am not an expert in this area of the routing code, the function fib6_age in net/ipv6/ip6_fib.c puzzles me.


In kernel version 2.7.2.0.3, we have net/ipv6/ip6_fib.c:
static int fib6_age(struct rt6_info *rt, void *arg)
{
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
static int fib6_age(struct rt6_info *rt, void *arg)
{
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
static int fib6_age(struct rt6_info *rt, void *arg)
{
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
