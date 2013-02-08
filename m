From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: cleanup sparse warnings
Date: Thu, 07 Feb 2013 19:25:33 -0800
Message-ID: <1360293933.28557.92.camel@edumazet-glaptop>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
	 <1360252376.28557.52.camel@edumazet-glaptop>
	 <20130207183725.GE2379@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:50730 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392Ab3BHDZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 22:25:43 -0500
Received: by mail-ie0-f180.google.com with SMTP id bn7so4434871ieb.39
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 19:25:42 -0800 (PST)
In-Reply-To: <20130207183725.GE2379@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-07 at 13:37 -0500, Neil Horman wrote:
> On Thu, Feb 07, 2013 at 07:52:56AM -0800, Eric Dumazet wrote:
> > On Thu, 2013-02-07 at 09:56 -0500, Neil Horman wrote:
> > > With my recent commit I introduced two sparse warnings.  Looking closer there
> > > were a few more in the same file, so I fixed them all up.  Basic rcu pointer
> > > dereferencing suff
> > 
> > > -	npinfo = np->dev->npinfo;
> > > +	/* rtnl_dereference would be preferable here but
> > > +	 * rcu_cleanup_netpoll path can put us in here safely without
> > > +	 * holding the rtnl, so plain rcu_dereference it is
> > > +	 */
> > > +	npinfo = rcu_dereference(np->dev->npinfo);
> > >  	if (!npinfo)
> > >  		return;
> > >  
> > 
> > Are you sure it wont trigger a LOCKDEP complain (CONFIG_PROVE_RCU=y) ?
> > 
> Hm, looking at it, you're probably right.  We're not holding the rcu_read_lock,
> and I'd forgotten that rcu_dereference implicitly checks that rcu_read_lock is
> held.  I guess, since the only paths that we get here on are in a bh rcu
> quiescence point or with the rtnl held we should probably make this:
> 
> rcu_dereference_protected(np->dev->npinfo, rtnl_locked() || in_interrupt());
> 
> Although, thinking about this further somewhat begs the question as to how we
> prevent one context from calling __netpoll_cleanup in a path holding rtnl, while
> in parallel calling __netpoll_cleanup from the rcu callback.  That might not be
> a huge deal as __netpoll_cleanup uses spinlocks to do list modification, and an
> atomic_dec_and_test to gate the free, but it still seems ugly.
> 
> What do you think?

I think you could use 

 rcu_dereference_check(p, lockdep_rtnl_is_held() || something)
