From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
	bonding devices
Date: Mon, 7 Jun 2010 09:03:57 -0400
Message-ID: <20100607130357.GN7497@gospo.rdu.redhat.com>
References: <20100527180545.GA2345@sysclose.org> <4BFF2EA5.9090008@redhat.com> <20100528194041.GC2345@sysclose.org> <4C034FA4.5000401@redhat.com> <20100531190820.GA24569@sysclose.org> <4C04D98D.4020509@redhat.com> <24059.1275417767@death.nxdomain.ibm.com> <4C062CBD.7090906@redhat.com> <20100604191841.GM7497@gospo.rdu.redhat.com> <4C0CC29D.9070507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Flavio Leitner <fbl@sysclose.org>,
	linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab0FGNE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 09:04:29 -0400
Content-Disposition: inline
In-Reply-To: <4C0CC29D.9070507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 07, 2010 at 05:57:49PM +0800, Cong Wang wrote:
> On 06/05/10 03:18, Andy Gospodarek wrote:
>> On Wed, Jun 02, 2010 at 06:04:45PM +0800, Cong Wang wrote:
>>> On 06/02/10 02:42, Jay Vosburgh wrote:
>>>> Cong Wang<amwang@redhat.com>   wrote:
>>>>
>>>>> On 06/01/10 03:08, Flavio Leitner wrote:
>>>>>> On Mon, May 31, 2010 at 01:56:52PM +0800, Cong Wang wrote:
>>>>>>> Hi, Flavio,
>>>>>>>
>>>>>>> Please use the attached patch instead, try to see if it solves
>>>>>>> all your problems.
>>>>>>
>>>>>> I tried and it hangs. No backtraces this time.
>>>>>> The bond_change_active_slave() prints before NETDEV_BONDING_FAILOVER
>>>>>> notification, so I think it won't work.
>>>>>
>>>>> Ah, I thought the same.
>>>>>
>>>>>>
>>>>>> Please, correct if I'm wrong, but when a failover happens with your
>>>>>> patch applied, the netconsole would be disabled forever even with
>>>>>> another healthy slave, right?
>>>>>>
>>>>>
>>>>> Yes, this is an easy solution, because bonding has several modes,
>>>>> it is complex to make netpoll work in different modes.
>>>>
>>>> 	If I understand correctly, the root cause of the problem with
>>>> netconsole and bonding is that bonding is, ultimately, performing
>>>> printks with a write lock held, and when netconsole recursively calls
>>>> into bonding to send the printk over the netconsole, there is a deadlock
>>>> (when the bonding xmit function attempts to acquire the same lock for
>>>> read).
>>>
>>>
>>> Yes.
>>>
>>>>
>>>> 	You're trying to avoid the deadlock by shutting off netconsole
>>>> (permanently, it looks like) for one problem case: a failover, which
>>>> does some printks with a write lock held.
>>>>
>>>> 	This doesn't look to me like a complete solution, there are
>>>> other cases in bonding that will do printk with write locks held.  I
>>>> suspect those will also hang netconsole as things exist today, and won't
>>>> be affected by your patch below.
>>>
>>>
>>> I can expect that, bonding modes are complex.
>>>
>>>>
>>>> 	For example:
>>>>
>>>> 	The sysfs functions to set the primary (bonding_store_primary)
>>>> or active (bonding_store_active_slave) options: a pr_info is called to
>>>> provide a log message of the results.  These could be tested by setting
>>>> the primary or active options via sysfs, e.g.,
>>>>
>>>> echo eth0>   /sys/class/net/bond0/bonding/primary
>>>> echo eth0>   /sys/class/net/bond0/bonding/active
>>>>
>>>> 	If the kernel is defined with DEBUG, there are a few pr_debug
>>>> calls within write_locks (bond_del_vlan, for example).
>>>>
>>>> 	If the slave's underlying device driver's ndo_vlan_rx_register
>>>> or ndo_vlan_rx_kill_vid functions call printk (and it looks like some do
>>>> for error cases, e.g., igbvf, ehea, enic), those would also presumably
>>>> deadlock (because bonding holds its write_lock when calling the ndo_
>>>> vlan functions).
>>>>
>>>> 	It also appears that (with the patch below) some nominally
>>>> normal usage patterns will immediately disable netconsole.  The one that
>>>> comes to mind is if the primary= option is set (to "eth1" for this
>>>> example), but that slave not enslaved first (the slaves are added, say,
>>>> eth0 then eth1).  In that situation, when the primary slave (eth1 here)
>>>> is added, the first thing that will happen is a failover, and that will
>>>> disable netconsole.
>>>>
>>>
>>> Thanks for your detailed explanation!
>>>
>>> This is why I said bonding is complex. I guess we would have to adjust
>>> netpoll code for different bonding cases, one solution seems not fix all.
>>> I am not sure how much work to do, since I am not familiar with bonding
>>> code. Maybe Andy can help?
>>>
>>
>> Sorry I've been silent until now.  This does seem quite similar to a
>> problem I've previously encountered when dealing with bonding+netpoll on
>> some old 2.6.9-based kernels.  There is no guarantee the methods used
>> there will apply here, but I'll talk about them anyway.
>>
>> As Flavio noticed, recursive calls into the bond transmit routines were
>> not a good idea.  I discovered the same and worked around this issue by
>> checking to see if we could take the bond->lock for writing before
>> continuing.  If we could not get, I wanted to signal that this should be
>> queued for transmission later.  Based on the flow of netpoll_send_skb
>> (or possibly for another reason that is escaping me right now) I added
>> one of these checks in bond_poll_controller too.  These aren't the
>> prettiest fixes, but seemed to work well for me when I did this work in
>> the past.  I realize the differences are not that great compared to some
>> of the patches posted by Flavio, but I think they are worth trying.
>
>
> Hmm, I still feel like this way is ugly, although it may work.
> I guess David doesn't like it either.
>

Notice how I referred to it as a work-around? :)

It certainly isn't a great way to resolve the issue, but I wanted to
offer my opinon on the issue since you asked.

> Anyway, Flavio, could you try the following patch as well?
>
> Thanks a lot!
>
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index ef60244..d7b9b99 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1290,6 +1290,12 @@ static bool slaves_support_netpoll(struct net_device *bond_dev)
>>   static void bond_poll_controller(struct net_device *bond_dev)
>>   {
>>   	struct net_device *dev = bond_dev->npinfo->netpoll->real_dev;
>> +	struct bonding *bond = netdev_priv(bond_dev);
>> +
>> +	if (!write_trylock(&bond->lock))
>> +		return;
>> +	write_unlock(&bond->lock);
>> +
>>   	if (dev != bond_dev)
>>   		netpoll_poll_dev(dev);
>>   }
>> @@ -4418,7 +4424,11 @@ static void bond_set_xmit_hash_policy(struct bonding *bond)
>>
>>   static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   {
>> -	const struct bonding *bond = netdev_priv(dev);
>> +	struct bonding *bond = netdev_priv(dev);
>> +
>> +	if (!write_trylock(&bond->lock))
>> +		return NETDEV_TX_BUSY;
>> +	write_unlock(&bond->lock);
>>
>>   	switch (bond->params.mode) {
>>   	case BOND_MODE_ROUNDROBIN:
>>
>> The other key to all of this is to make sure that queuing is done
>> correctly now that we expect to queue these frames and have them sent at
>> some point when there is a member of the bond that is actually capable
>> of sending them out.
>>
>> The new style of sending queued skbs in a workqueue is much better than
>> what was done in the 2.6.9 timeframe, but careful attention should still
>> be paid to txq lock and which processor is the owner.  Returning
>> something other than NETDEV_TX_OK from bond_start_xmit and checking for
>> locks being held there should also help with any deadlocks that show up
>> while running in queue_process (though they would not be recursive).
>>
>> I'm not in a good spot to test this right now, but I can take a look at
>> next week and we can try and track down any of the other deadlocks that
>> currently exist as I suspect this will not resolve all of the issues.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
