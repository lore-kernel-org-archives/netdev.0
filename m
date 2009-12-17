From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() ->
 cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 21:56:17 +0100
Message-ID: <20091217205617.GB2578@ami.dom.local>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
 <20091217074930.GA6779@ff.dom.local>
 <20091217133644.GD8654@ff.dom.local>
 <1261060259.10356.112.camel@johannes.local>
 <11218.1261066373@death.nxdomain.ibm.com>
 <20091217184017.GA2578@ami.dom.local>
 <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com>
 <29926.1261078662@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Laurent Chavey <chavey@google.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:65029 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbZLQU4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:56:50 -0500
Received: by fxm21 with SMTP id 21so2291006fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 12:56:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <29926.1261078662@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 11:37:42AM -0800, Jay Vosburgh wrote:
> Laurent Chavey <chavey@google.com> wrote:
> 
> >one instance that could be a problem
> >
> >__exit bonding_exit(void)
> >    bond_free_all()
> >      	bond_work_cancel_all(bond);
> >        unregister_netdevice(bond_dev)
> >
> >could the above result in an invalid pointer when trying
> >to use bond-> in one of the timer CB ?
> 
> 	The bonding teardown logic was reworked in October, and there is
> no longer a bond_free_all in the current mainline.  What kernel are you
> looking at?
> 
> 	The bond_close function will stop the various work items, and
> the ndo_uninit (bond_uninit) will call bond_work_cancel_all as well.
> 
> 	Actually, on looking at it (it being current mainline),
> bond_uninit might need some kind of logic to wait and insure that all
> timers have completed before returning.  It comes from unregister, so
> the next thing that happens after it returns is that the memory will be
> freed (via netdev_run_todo, during rtnl_unlock, if I'm following it
> correctly).
> 
> 	The bond_uninit function is called under RTNL, though, so the
> timer functions (bond_mii_monitor, et al) may need additional checks for
> kill_timers to insure they don't attempt to acquire RTNL if a cancel is
> pending.
> 
> 	That's kind of tricky itself, since the lock ordering requires
> RTNL to be acquired first, so there's no way for bond_mii_monitor (et
> al) to check for kill_timers prior to already having RTNL (because the
> function acquires RTNL conditionally, only if needed; to do that, it
> unlocks the bond lock, then acquires RTNL, then re-locks the bond lock).
> 
> 	So, the lock dance to acquire RTNL in bond_mii_monitor (et al)
> would need some trickery, perhaps a rtnl_trylock loop, that checks
> kill_timers each time the trylock fails, e.g.,
> 
> 	if (bond_miimon_inspect(bond)) {
> 		read_unlock(&bond->lock);
> 		while (!rtnl_trylock) {
> 			read_lock(&bond->lock);
> 			if (bond->kill_timers)
> 				goto out;
> 			read_unlock(&bond->lock);
> 			/* msleep ? */
> 		}
> 
> 		bond_miimon_commit(bond);
> 		[...]
> 
> 	So, with the above (and similar changes to the other delayed
> work functions, and a big honkin' comment somewhere to explain this), I
> suspect that bond_work_cancel_all could use the _sync variant to cancel
> the work, as long as kill_timers is set before the cancel_sync is
> called.
> 
> 	Am I missing anything?  Does this seem rational?

It seems OK to me ...if there is nothing better ;-) But such endless
loops are tricky (they omit lockdep, plus can hide some hidden
dependancies between different tasks, even in the future). If it's
possible we could consider a limited loop with re-arming on failure;
then cancel_delayed_work_sync() (with its standard logic) could be
used everywhere, and kill_timers might be useless too (if there is no
re-arming between different works).

Jarek P.
