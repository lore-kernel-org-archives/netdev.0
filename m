From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Mon, 10 Mar 2014 14:15:10 +0100
Message-ID: <20140310131510.GB27052@unicorn.suse.cz>
References: <20140308080616.GB5493@order.stressinduktion.org>
 <20140309.202658.205858191881011540.davem@davemloft.net>
 <20140310005220.GD5493@order.stressinduktion.org>
 <20140310.010313.703650662340510015.davem@davemloft.net>
 <20140310081533.GA27052@unicorn.suse.cz>
 <20140310120016.GH5493@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60773 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229AbaCJNPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 09:15:13 -0400
Content-Disposition: inline
In-Reply-To: <20140310120016.GH5493@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 01:00:16PM +0100, Hannes Frederic Sowa wrote:
> On Mon, Mar 10, 2014 at 09:15:33AM +0100, Michal Kubecek wrote:
> > On Mon, Mar 10, 2014 at 01:03:13AM -0400, David Miller wrote:
> > > @@ -743,6 +743,30 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
> > >  		BUG_ON(rt6i_nsiblings != rt->rt6i_nsiblings);
> > >  	}
> > >  
> > > +	if (mx) {
> > > +		struct nlattr *nla;
> > > +		bool was_writable;
> > > +		int remaining;
> > > +		u32 *mp;
> > > +
> > > +		was_writable = !dst_metrics_read_only(&rt->dst);
> > > +		mp = dst_metrics_write_ptr(&rt->dst);
> > > +
> > > +		if (was_writable)
> > > +			memset(mp, 0, RTAX_MAX * sizeof(u32));
> > > +
> > > +		nla_for_each_attr(nla, mx, mx_len, remaining) {
> > > +			int type = nla_type(nla);
> > > +
> > > +			if (type) {
> > > +				if (type > RTAX_MAX)
> > > +					return -EINVAL;
> > > +
> > > +				mp[type - 1] = nla_get_u32(nla);
> > > +			}
> > > +		}
> > > +	}
> > > +
> > >  	/*
> > >  	 *	insert node
> > >  	 */
> > 
> > This is too early. After this point, the insertion can still fail if
> > (!found && !add) (i.e. when trying to modify a non-existent route with
> > "ip route change").
> 
> Yep, but we can make this a static function to ip6_fib.c and call it from the
> code points you already proposed in your original patch?

Yes, this sounds like the best option.

> The reason why I liked David's proposal is that it removes the ambiguity
> when looking up the inetpeer (we only get the inetpeer if we are sure
> a new route is added). I don't mind the kzalloc that much. The only
> overhead it produces would be if a user inserts a route for a /128 target
> and specifies metrics.

Right, I didn't realize that.

> > Or rather get a null pointer dereference in 
> > fib6_add_rt2node() as dst_metrics_write_ptr() would return NULL. An 
> > alternative solution (and perhaps a more suitable one) would be to 
> > allocate the block in ip6_cow_metrics() instead of returning NULL.
> 
> I am not sure of the advantage here. If this patch targets net I would
> like to keep the changes a bit more straightforward. In case it gives
> a nice advantage, maybe another patch for net-next? Haven't had a close look
> on that yet.

Agreed. It would only delay the allocation for non-DST_HOST routes to
the point we are sure we need it; on the other hand, it would require
reorganizing the ip6_cow_metrics() code so I guess it can wait for
net-next (if at all).

                                                       Michal Kubecek
