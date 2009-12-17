From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() -> cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 13:40:29 -0800
Message-ID: <9587.1261086029@death.nxdomain.ibm.com>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com> <20091217074930.GA6779@ff.dom.local> <20091217133644.GD8654@ff.dom.local> <1261060259.10356.112.camel@johannes.local> <11218.1261066373@death.nxdomain.ibm.com> <20091217184017.GA2578@ami.dom.local> <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com> <29926.1261078662@death.nxdomain.ibm.com> <20091217205617.GB2578@ami.dom.local>
Cc: Laurent Chavey <chavey@google.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33049 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765377AbZLQVkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 16:40:45 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBHLaLw7001739
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 16:36:21 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHLeiiJ129658
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 16:40:44 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHLehlM021523
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:40:44 -0200
In-reply-to: <20091217205617.GB2578@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:

>On Thu, Dec 17, 2009 at 11:37:42AM -0800, Jay Vosburgh wrote:
>> Laurent Chavey <chavey@google.com> wrote:
>> 
>> >one instance that could be a problem
>> >
>> >__exit bonding_exit(void)
>> >    bond_free_all()
>> >      	bond_work_cancel_all(bond);
>> >        unregister_netdevice(bond_dev)
>> >
>> >could the above result in an invalid pointer when trying
>> >to use bond-> in one of the timer CB ?
>> 
>> 	The bonding teardown logic was reworked in October, and there is
>> no longer a bond_free_all in the current mainline.  What kernel are you
>> looking at?
>> 
>> 	The bond_close function will stop the various work items, and
>> the ndo_uninit (bond_uninit) will call bond_work_cancel_all as well.
>> 
>> 	Actually, on looking at it (it being current mainline),
>> bond_uninit might need some kind of logic to wait and insure that all
>> timers have completed before returning.  It comes from unregister, so
>> the next thing that happens after it returns is that the memory will be
>> freed (via netdev_run_todo, during rtnl_unlock, if I'm following it
>> correctly).
>> 
>> 	The bond_uninit function is called under RTNL, though, so the
>> timer functions (bond_mii_monitor, et al) may need additional checks for
>> kill_timers to insure they don't attempt to acquire RTNL if a cancel is
>> pending.
>> 
>> 	That's kind of tricky itself, since the lock ordering requires
>> RTNL to be acquired first, so there's no way for bond_mii_monitor (et
>> al) to check for kill_timers prior to already having RTNL (because the
>> function acquires RTNL conditionally, only if needed; to do that, it
>> unlocks the bond lock, then acquires RTNL, then re-locks the bond lock).
>> 
>> 	So, the lock dance to acquire RTNL in bond_mii_monitor (et al)
>> would need some trickery, perhaps a rtnl_trylock loop, that checks
>> kill_timers each time the trylock fails, e.g.,
>> 
>> 	if (bond_miimon_inspect(bond)) {
>> 		read_unlock(&bond->lock);
>> 		while (!rtnl_trylock) {
>> 			read_lock(&bond->lock);
>> 			if (bond->kill_timers)
>> 				goto out;
>> 			read_unlock(&bond->lock);
>> 			/* msleep ? */
>> 		}
>> 
>> 		bond_miimon_commit(bond);
>> 		[...]
>> 
>> 	So, with the above (and similar changes to the other delayed
>> work functions, and a big honkin' comment somewhere to explain this), I
>> suspect that bond_work_cancel_all could use the _sync variant to cancel
>> the work, as long as kill_timers is set before the cancel_sync is
>> called.
>> 
>> 	Am I missing anything?  Does this seem rational?
>
>It seems OK to me ...if there is nothing better ;-) But such endless
>loops are tricky (they omit lockdep, plus can hide some hidden
>dependancies between different tasks, even in the future). If it's
>possible we could consider a limited loop with re-arming on failure;
>then cancel_delayed_work_sync() (with its standard logic) could be
>used everywhere, and kill_timers might be useless too (if there is no
>re-arming between different works).

	A less evil alternative would be to punt and reschedule the work
if the rtnl_trylock failed, e.g.,

	if (bond_miimon_inspect(bond)) {
		read_unlock(&bond->lock);
		if (!rtnl_trylock()) {
			queue_work(...);
			return;
		}

		read_lock(&bond->lock);

		bond_miimon_commit(bond);
		[...]

	I'm not sure what the usual contention level on rtnl is (and,
therefore, how often this will punt for the normal case that's not the
race we're trying to avoid here).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

