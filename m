From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 07/17] ipv6: fib: Add in-kernel notifications
 for route add / delete
Date: Wed, 19 Jul 2017 18:53:59 +0300
Message-ID: <20170719155358.GB6078@splinter>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-8-jiri@resnulli.us>
 <2db9b613-3978-52f5-db9d-d3e36742db49@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0080.outbound.protection.outlook.com ([104.47.1.80]:60864
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753731AbdGSPyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 11:54:09 -0400
Content-Disposition: inline
In-Reply-To: <2db9b613-3978-52f5-db9d-d3e36742db49@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 09:38:11AM -0600, David Ahern wrote:
> On 7/19/17 1:02 AM, Jiri Pirko wrote:
> > @@ -879,6 +891,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
> >  		*ins = rt;
> >  		rt->rt6i_node = fn;
> >  		atomic_inc(&rt->rt6i_ref);
> > +		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_ADD,
> > +					  rt);
> >  		if (!info->skip_notify)
> >  			inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
> >  		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
> > @@ -906,6 +920,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
> >  		rt->rt6i_node = fn;
> >  		rt->dst.rt6_next = iter->dst.rt6_next;
> >  		atomic_inc(&rt->rt6i_ref);
> > +		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_REPLACE,
> > +					  rt);
> >  		if (!info->skip_notify)
> >  			inet6_rt_notify(RTM_NEWROUTE, rt, info, NLM_F_REPLACE);
> >  		if (!(fn->fn_flags & RTN_RTINFO)) {
> > @@ -1459,6 +1475,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
> >  
> >  	fib6_purge_rt(rt, fn, net);
> >  
> > +	call_fib6_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, rt);
> >  	if (!info->skip_notify)
> >  		inet6_rt_notify(RTM_DELROUTE, rt, info, 0);
> >  	rt6_release(rt);
> > 
> 
> 
> Why aren't all of the notifier calls under the skip_notify? That flag is
> used to make handling of ipv6 multipath routes on par with ipv4. See
> commit 3b1137fe74829

>From the cover letter:

"Unlike user space notifications for IPv6 multipath routes, the FIB
notification chain notifies these on a per-nexthop basis. This allows us
to keep the common code lean and is also unnecessary, as notifications
are serialized by each table's lock whereas applications maintaining
netlink caches may suffer from concurrent dumps and deletions /
additions of routes."
