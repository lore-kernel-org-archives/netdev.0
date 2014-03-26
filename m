From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: move DAD and addrconf_verify processing to workqueue
Date: Wed, 26 Mar 2014 01:00:52 +0100
Message-ID: <20140326000052.GD22086@order.stressinduktion.org>
References: <20140317161853.2e880469@nehalam.linuxnetplumber.net> <20140323020351.GA3984@order.stressinduktion.org> <20140325080301.GA22086@order.stressinduktion.org> <20140325142004.7507d310@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59677 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbaCZAAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 20:00:54 -0400
Content-Disposition: inline
In-Reply-To: <20140325142004.7507d310@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 02:20:04PM -0700, Stephen Hemminger wrote:
> On Tue, 25 Mar 2014 09:03:01 +0100
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> >  
> > -static void addrconf_verify(unsigned long foo)
> > +static void addrconf_verify_rtnl(void)
> >  {
> >  	unsigned long now, next, next_sec, next_sched;
> >  	struct inet6_ifaddr *ifp;
> >  	int i;
> >  
> > +	ASSERT_RTNL();
> > +
> >  	rcu_read_lock_bh();
> >  	spin_lock(&addrconf_verify_lock);
> 
> Since RTNL is now held in addrconf_verify(), is addrconf_verify_lock is not needed.

Yes, I overlooked that, thanks!

> Since RTNL is held, rcu is not needed either.

It might be possible if we add other rtnl lock invocations to the dad
process, but because rcu is much more lightweight, I would leave it as is:

ipv6_del_addr removes elements from inet6_addr_lst without holding RTNL but
only synchronizes on addrconf_hash_lock. In this constellation RCU is still
needed.

> Also, I would skip the wrapper (addrconf_verify_rtnl) and just
> put it all in addrconf_verify_work

I preferred to have the addrconf_verify invocations inline and not deferred if
we e.g. do cleanups from user space to not have any races because of not yet
deleted addresses. I would also prefer to leave this as is, ok?

Will send v2, thanks!
