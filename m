From: Laurent Chavey <chavey@google.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() ->
	cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 13:25:06 -0800
Message-ID: <97949e3e0912171325n12b4749dof2612391a71e74d9@mail.gmail.com>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
	<20091217074930.GA6779@ff.dom.local> <20091217133644.GD8654@ff.dom.local>
	<1261060259.10356.112.camel@johannes.local> <11218.1261066373@death.nxdomain.ibm.com>
	<20091217184017.GA2578@ami.dom.local> <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com>
	<29926.1261078662@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:38340 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765360AbZLQVZa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:25:30 -0500
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id nBHLPSmh032428
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:25:29 -0800
Received: from pwj16 (pwj16.prod.google.com [10.241.219.80])
	by kpbe14.cbf.corp.google.com with ESMTP id nBHLPQ4P021540
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:25:27 -0800
Received: by pwj16 with SMTP id 16so1823566pwj.5
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:25:26 -0800 (PST)
In-Reply-To: <29926.1261078662@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 11:37 AM, Jay Vosburgh <fubar@us.ibm.com> wrote=
:
> Laurent Chavey <chavey@google.com> wrote:
>
>>one instance that could be a problem
>>
>>__exit bonding_exit(void)
>> =A0 =A0bond_free_all()
>> =A0 =A0 =A0 bond_work_cancel_all(bond);
>> =A0 =A0 =A0 =A0unregister_netdevice(bond_dev)
>>
>>could the above result in an invalid pointer when trying
>>to use bond-> in one of the timer CB ?
>
> =A0 =A0 =A0 =A0The bonding teardown logic was reworked in October, an=
d there is
> no longer a bond_free_all in the current mainline. =A0What kernel are=
 you
> looking at?
not mainline :-), switched to mainline, see it as you do. thx

>
> =A0 =A0 =A0 =A0The bond_close function will stop the various work ite=
ms, and
> the ndo_uninit (bond_uninit) will call bond_work_cancel_all as well.
>
> =A0 =A0 =A0 =A0Actually, on looking at it (it being current mainline)=
,
> bond_uninit might need some kind of logic to wait and insure that all
> timers have completed before returning. =A0It comes from unregister, =
so
> the next thing that happens after it returns is that the memory will =
be
> freed (via netdev_run_todo, during rtnl_unlock, if I'm following it
> correctly).
>
> =A0 =A0 =A0 =A0The bond_uninit function is called under RTNL, though,=
 so the
> timer functions (bond_mii_monitor, et al) may need additional checks =
for
> kill_timers to insure they don't attempt to acquire RTNL if a cancel =
is
> pending.
>
> =A0 =A0 =A0 =A0That's kind of tricky itself, since the lock ordering =
requires
> RTNL to be acquired first, so there's no way for bond_mii_monitor (et
> al) to check for kill_timers prior to already having RTNL (because th=
e
> function acquires RTNL conditionally, only if needed; to do that, it
> unlocks the bond lock, then acquires RTNL, then re-locks the bond loc=
k).
>
> =A0 =A0 =A0 =A0So, the lock dance to acquire RTNL in bond_mii_monitor=
 (et al)
> would need some trickery, perhaps a rtnl_trylock loop, that checks
> kill_timers each time the trylock fails, e.g.,
>
> =A0 =A0 =A0 =A0if (bond_miimon_inspect(bond)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_unlock(&bond->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (!rtnl_trylock) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_lock(&bond->lock)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (bond->kill_timers)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto o=
ut;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_unlock(&bond->loc=
k);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* msleep ? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond_miimon_commit(bond);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[...]
>
> =A0 =A0 =A0 =A0So, with the above (and similar changes to the other d=
elayed
> work functions, and a big honkin' comment somewhere to explain this),=
 I
> suspect that bond_work_cancel_all could use the _sync variant to canc=
el
> the work, as long as kill_timers is set before the cancel_sync is
> called.
>
> =A0 =A0 =A0 =A0Am I missing anything? =A0Does this seem rational?
>
yes it does. the _sync variant should cover the hole.


>>On Thu, Dec 17, 2009 at 10:40 AM, Jarek Poplawski <jarkao2@gmail.com>=
 wrote:
>>> On Thu, Dec 17, 2009 at 08:12:53AM -0800, Jay Vosburgh wrote:
>>>> =A0 =A0 =A0 There's already logic in the monitors (bond_mii_monito=
r, et al)
>>>> to check a sentinel (kill_timers) and do nothing (not acquire rtnl=
) and
>>>> return.
>>>
>>> Btw, this check should be repeated if bond->lock is given back and
>>> re-acquired. I can't see these kill_timers used in bond_sysfs.c tho=
ugh.
>
> =A0 =A0 =A0 =A0Yes, this is true, and I think that doing this in the =
above
> manner may eliminate the problem.
>
>>>> =A0 =A0 =A0 What exactly is the nature of the race that doing canc=
el..sync
>>>> is fixing? =A0The bond_close function sets kill_timers prior to ca=
lling
>>>> the cancel functions, so the monitor function might run once, but =
it
>>>> should do nothing.
>>>
>>> I guess there is a problem with destructions, but I hope Mikhail wi=
ll
>>> give more details.
>
> =A0 =A0 =A0 =A0-J
>
> ---
> =A0 =A0 =A0 =A0-Jay Vosburgh, IBM Linux Technology Center, fubar@us.i=
bm.com
>
