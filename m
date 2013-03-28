From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 11:23:56 -0700
Message-ID: <20130328182356.GE3337@linux.vnet.ibm.com>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
 <1364478265.15753.42.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Balakumaran Kannan <kumaran.4353@gmail.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:41766 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab3C1SZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:25:24 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 28 Mar 2013 12:25:23 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1A17D1FF004C
	for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 12:19:05 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2SIO03H376582
	for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 12:24:01 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2SIQd1N026889
	for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 12:26:41 -0600
Content-Disposition: inline
In-Reply-To: <1364478265.15753.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 06:44:25AM -0700, Eric Dumazet wrote:
> On Thu, 2013-03-28 at 18:57 +0530, Balakumaran Kannan wrote:
> > IPv6 Routing table becomes broken once we do ifdown, ifup of the loopback(lo)
> > interface. After down-up, routes of other interface's IPv6 addresses through
> > 'lo' are lost.
> > 
> 
> >  	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
> > +
> > +	/* Add routes to other interface's IPv6 addresses */
> > +	rcu_read_lock();
> > +	for_each_netdev_rcu(dev_net(dev), sp_dev) {
> > +
> 
> We hold RTNL at this point, so why use RCU at all, and adding potential
> long latencies ?
> 
> Just use for_each_netdev()
> 
> This way, a preemption is still allowed.

Agreed, there is no point in using RCU when it is not needed.

That said...

Since v3.1, in CONFIG_PREEMPT=y kernels, rcu_read_lock() does not
disable preemption.  In CONFIG_PREEMPT=n kernels, rcu_read_lock() does
disable preemption, but to no effect because preemption is already
disabled anyway.

The net effect is that rcu_read_lock() has no effect on preemption.

							Thanx, Paul

> Also, I am not sure we need ipv6_find_idev()
> 
> __in6_dev_get() should be OK.
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
