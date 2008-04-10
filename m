From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route
 compare
Date: Thu, 10 Apr 2008 03:56:18 -0700 (PDT)
Message-ID: <20080410.035618.217931997.davem@davemloft.net>
References: <20080401130842.579e0ebc@extreme>
	<20080410.015118.103465510.davem@davemloft.net>
	<20080410.180148.120248426.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754726AbYDJK4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 06:56:18 -0400
In-Reply-To: <20080410.180148.120248426.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 10 Apr 2008 18:01:48 +0900 (JST)

> In article <20080410.015118.103465510.davem@davemloft.net> (at Thu, 10 Apr 2008 01:51:18 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Tue, 1 Apr 2008 13:08:42 -0700
> > 
> > > The flow fields are all together, and the other parameters are local variables
> > > in registers so that compare should be in one cache line.
> > > 
> > > --- a/net/ipv4/route.c	2008-03-31 17:12:30.000000000 -0700
> > > +++ b/net/ipv4/route.c	2008-04-01 13:05:46.000000000 -0700
> > > @@ -2079,12 +2079,12 @@ int ip_route_input(struct sk_buff *skb, 
> > >  	rcu_read_lock();
> > >  	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
> > >  	     rth = rcu_dereference(rth->u.dst.rt_next)) {
> > > -		if (rth->fl.fl4_dst == daddr &&
> > > -		    rth->fl.fl4_src == saddr &&
> > > -		    rth->fl.iif == iif &&
> > > -		    rth->fl.oif == 0 &&
> > > +		if (((rth->fl.fl4_dst ^ daddr) |
> > > +		     (rth->fl.fl4_src ^ saddr) |
> > > +		     (rth->fl.iif ^ iif) |
> > > +		     rth->fl.oif |
> > > +		     (rth->fl.fl4_tos ^ tos)) == 0 &&
> > >  		    rth->fl.mark == skb->mark &&
> > > -		    rth->fl.fl4_tos == tos &&
> > >  		    net_eq(dev_net(rth->u.dst.dev), net) &&
> > >  		    rth->rt_genid == atomic_read(&rt_genid)) {
> > >  			dst_use(&rth->u.dst, jiffies);
> > 
> > Eric, any objections to this version?
> 
> I'm not Eric, but well, I'm now doubting if this is really good.
> If the comparision chain is long and it is unlikely to pass all the tests,
> it would be better to cut the line.
> If we use "or", we need to run through the test, in ayn case.

Actually the case you mention it is part of the incentive for
this change.

Branch prediction fares very poorly in such cases, and
therefore it is better to mispredict one branch over
all the data items in the same cache line than any one
of several such branches.  The above new sequence gets
emitted by the compiler as several integer operations and
one branch.  As long as all the data items are in the
same cacheline, this is optimal.

We made such a change for ethernet address comparisons a
few years ago.  At the time Eric showed that it mattered
a lot for Athlon processors.
