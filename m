From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route
 compare
Date: Thu, 10 Apr 2008 18:01:48 +0900 (JST)
Message-ID: <20080410.180148.120248426.yoshfuji@linux-ipv6.org>
References: <47F1CD83.8090905@cosmosbay.com>
	<20080401130842.579e0ebc@extreme>
	<20080410.015118.103465510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32915 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbYDJJAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 05:00:05 -0400
In-Reply-To: <20080410.015118.103465510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080410.015118.103465510.davem@davemloft.net> (at Thu, 10 Apr 2008 01:51:18 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 1 Apr 2008 13:08:42 -0700
> 
> > The flow fields are all together, and the other parameters are local variables
> > in registers so that compare should be in one cache line.
> > 
> > --- a/net/ipv4/route.c	2008-03-31 17:12:30.000000000 -0700
> > +++ b/net/ipv4/route.c	2008-04-01 13:05:46.000000000 -0700
> > @@ -2079,12 +2079,12 @@ int ip_route_input(struct sk_buff *skb, 
> >  	rcu_read_lock();
> >  	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
> >  	     rth = rcu_dereference(rth->u.dst.rt_next)) {
> > -		if (rth->fl.fl4_dst == daddr &&
> > -		    rth->fl.fl4_src == saddr &&
> > -		    rth->fl.iif == iif &&
> > -		    rth->fl.oif == 0 &&
> > +		if (((rth->fl.fl4_dst ^ daddr) |
> > +		     (rth->fl.fl4_src ^ saddr) |
> > +		     (rth->fl.iif ^ iif) |
> > +		     rth->fl.oif |
> > +		     (rth->fl.fl4_tos ^ tos)) == 0 &&
> >  		    rth->fl.mark == skb->mark &&
> > -		    rth->fl.fl4_tos == tos &&
> >  		    net_eq(dev_net(rth->u.dst.dev), net) &&
> >  		    rth->rt_genid == atomic_read(&rt_genid)) {
> >  			dst_use(&rth->u.dst, jiffies);
> 
> Eric, any objections to this version?

I'm not Eric, but well, I'm now doubting if this is really good.
If the comparision chain is long and it is unlikely to pass all the tests,
it would be better to cut the line.
If we use "or", we need to run through the test, in ayn case.

--yoshfuji
