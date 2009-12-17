From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() -> cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 11:37:42 -0800
Message-ID: <29926.1261078662@death.nxdomain.ibm.com>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com> <20091217074930.GA6779@ff.dom.local> <20091217133644.GD8654@ff.dom.local> <1261060259.10356.112.camel@johannes.local> <11218.1261066373@death.nxdomain.ibm.com> <20091217184017.GA2578@ami.dom.local> <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55067 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965453AbZLQTiU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 14:38:20 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBHJPZC1012673
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 12:25:35 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHJbvcX108606
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 12:38:00 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHJbtoE024057
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 12:37:56 -0700
In-reply-to: <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Chavey <chavey@google.com> wrote:

>one instance that could be a problem
>
>__exit bonding_exit(void)
>    bond_free_all()
>      	bond_work_cancel_all(bond);
>        unregister_netdevice(bond_dev)
>
>could the above result in an invalid pointer when trying
>to use bond-> in one of the timer CB ?

	The bonding teardown logic was reworked in October, and there is
no longer a bond_free_all in the current mainline.  What kernel are you
looking at?

	The bond_close function will stop the various work items, and
the ndo_uninit (bond_uninit) will call bond_work_cancel_all as well.

	Actually, on looking at it (it being current mainline),
bond_uninit might need some kind of logic to wait and insure that all
timers have completed before returning.  It comes from unregister, so
the next thing that happens after it returns is that the memory will be
freed (via netdev_run_todo, during rtnl_unlock, if I'm following it
correctly).

	The bond_uninit function is called under RTNL, though, so the
timer functions (bond_mii_monitor, et al) may need additional checks fo=
r
kill_timers to insure they don't attempt to acquire RTNL if a cancel is
pending.

	That's kind of tricky itself, since the lock ordering requires
RTNL to be acquired first, so there's no way for bond_mii_monitor (et
al) to check for kill_timers prior to already having RTNL (because the
function acquires RTNL conditionally, only if needed; to do that, it
unlocks the bond lock, then acquires RTNL, then re-locks the bond lock)=
=2E

	So, the lock dance to acquire RTNL in bond_mii_monitor (et al)
would need some trickery, perhaps a rtnl_trylock loop, that checks
kill_timers each time the trylock fails, e.g.,

	if (bond_miimon_inspect(bond)) {
		read_unlock(&bond->lock);
		while (!rtnl_trylock) {
			read_lock(&bond->lock);
			if (bond->kill_timers)
				goto out;
			read_unlock(&bond->lock);
			/* msleep ? */
		}

		bond_miimon_commit(bond);
		[...]

	So, with the above (and similar changes to the other delayed
work functions, and a big honkin' comment somewhere to explain this), I
suspect that bond_work_cancel_all could use the _sync variant to cancel
the work, as long as kill_timers is set before the cancel_sync is
called.

	Am I missing anything?  Does this seem rational?

>On Thu, Dec 17, 2009 at 10:40 AM, Jarek Poplawski <jarkao2@gmail.com> =
wrote:
>> On Thu, Dec 17, 2009 at 08:12:53AM -0800, Jay Vosburgh wrote:
>>> =C2=A0 =C2=A0 =C2=A0 There's already logic in the monitors (bond_mi=
i_monitor, et al)
>>> to check a sentinel (kill_timers) and do nothing (not acquire rtnl)=
 and
>>> return.
>>
>> Btw, this check should be repeated if bond->lock is given back and
>> re-acquired. I can't see these kill_timers used in bond_sysfs.c thou=
gh.

	Yes, this is true, and I think that doing this in the above
manner may eliminate the problem.

>>> =C2=A0 =C2=A0 =C2=A0 What exactly is the nature of the race that do=
ing cancel..sync
>>> is fixing? =C2=A0The bond_close function sets kill_timers prior to =
calling
>>> the cancel functions, so the monitor function might run once, but i=
t
>>> should do nothing.
>>
>> I guess there is a problem with destructions, but I hope Mikhail wil=
l
>> give more details.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
