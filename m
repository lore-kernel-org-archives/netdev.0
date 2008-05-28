From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH RFC] net/bonding: announce fail-over for the active-backup mode
Date: Wed, 28 May 2008 15:19:08 -0700
Message-ID: <12513.1212013148@death>
References: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com> <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33227 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540AbYE1WTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 18:19:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SMLY2T024828
	for <netdev@vger.kernel.org>; Wed, 28 May 2008 18:21:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SMJBU2161690
	for <netdev@vger.kernel.org>; Wed, 28 May 2008 18:19:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SMJAnS010477
	for <netdev@vger.kernel.org>; Wed, 28 May 2008 18:19:10 -0400
In-reply-to: <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>> Enhance bonding to announce fail-over for the active-backup mode through the
>> netdev events notifier chain mechanism. Such an event can be of use for the
>> RDMA CM (communication manager) to let native RDMA ULPs (eg NFS-RDMA, iSER)
>> always be aligned with the IP stack, in the sense that they use the same
>> ports/links as the stack does. More usages can be done to allow monitoring
>> tools based on netlink events be aware to bonding failover.
>>
>> Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
>[...]
>> --- linux-2.6.26-rc2.orig/drivers/net/bonding/bond_main.c	2008-05-13 10:02:22.000000000 +0300
>> +++ linux-2.6.26-rc2/drivers/net/bonding/bond_main.c	2008-05-15 12:29:44.000000000 +0300
>> @@ -1117,6 +1117,7 @@ void bond_change_active_slave(struct bon
>>  			bond->send_grat_arp = 1;
>>  		} else
>>  			bond_send_gratuitous_arp(bond);
>> +		netdev_bonding_change(bond->dev);
>>  	}
>>  }
>[...]
>> --- linux-2.6.26-rc2.orig/net/core/dev.c	2008-05-13 10:02:31.000000000 +0300
>> +++ linux-2.6.26-rc2/net/core/dev.c	2008-05-13 11:50:49.000000000 +0300
>> @@ -956,6 +956,12 @@ void netdev_state_change(struct net_devi
>>  	}
>>  }
>>
>> +void netdev_bonding_change(struct net_device *dev)
>> +{
>> +	call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, dev);
>> +}
>> +EXPORT_SYMBOL(netdev_bonding_change);
>
>Hi Jay,
>
>First, I'll be happy to get a comment from you on the patch.

	I've been away from the office, so I'm just now looking at this.

	Philosophically speaking, I don't see a problem with adding a
notifier like this, but others higher in the food chain may have
thoughts.

	From a technical point of view, however, you'll need a much more
extensive change to deal with the locking requirements, which I'll
describe below.

>Second, bond_change_active_slave() is called on few occasions under write_lock_bh()
>which means it runs in atomic context. I was thinking that it might be better to
>invoke call_netdevice_notifiers() from thread context, since some components may
>need to allocate memory in order to deliver event (eg netlink) and may assume the
>context they are being called is not atomic.

	Yes, this is one of the locking cases that has been slowly
changing.  To make the change you're requesting, I suspect that all of
the remaining callers of bond_change_active_slave will have to be
converted as follows.

	The "proper" locking for calls to bond_change_active_slave is
RTNL, read_lock of bond->lock and write_lock_bh of curr_slave_lock.
Some places in the code still have other locking, and get away with it
due to special knowledge (e.g., bond_release sets the active slave to
NULL, which won't go down any paths that need the special locking).

	The reason for the locking requirements is that there are places
that must release some of these locks to get to the correct locking
context for the notifier calls (which is RTNL and nothing else).  The
main case for this is in bond_alb_handle_active_change, wherein the MAC
addresses of the slaves are moved around.  The dev_set_mac_address
function needs RTNL and nothing else, because it will issue a notifier
call.

	Your case is similar: you want to issue a notifier call during
an active-backup failover, so that notifier call will have to be made
holding RTNL and no other locks.

	I think the most maintainable way to do that is to convert the
remaining callers of bond_change_active_slave to hold the correct set of
locks, and then have bond_change_active_slave drop down to just RTNL at
the appropriate place to make the notifier call.  That may not be as
simple as it sounds, as it may open race windows.

>
>For example I sometimes get the below "scheduling while atomic" warning which points
>on ipoib code, but the stack trace has some netlink calls which allocate skb. I am
>not sure yet what triggers this, however I wanted to check with you and Jeff if/what
>there are some convensions for the context of call_netdevice_notifiers(), thanks.

>bonding: bond0: link status definitely down for interface ib0, disabling it
>bonding: bond0: making interface ib1 the new active one.
>BUG: scheduling while atomic: bond0/14237/0x10000100
>Pid: 14237, comm: bond0 Not tainted 2.6.26-rc3 #4
>
>Call Trace:
> [<ffffffff804777d7>] schedule+0x98/0x57b
> [<ffffffff80277836>] dbg_redzone1+0x16/0x1f
> [<ffffffffa0106f22>] :ib_ipoib:ipoib_start_xmit+0x445/0x459
> [<ffffffff802799c2>] kmem_cache_alloc_node+0x147/0x177
> [<ffffffff8040a939>] __alloc_skb+0x35/0x12b
> [<ffffffff8022c99b>] __cond_resched+0x1c/0x43
> [<ffffffff80477e11>] _cond_resched+0x2d/0x38
> [<ffffffff802798a0>] kmem_cache_alloc_node+0x25/0x177
> [<ffffffff8040a939>] __alloc_skb+0x35/0x12b
> [<ffffffff8041825e>] rtmsg_ifinfo+0x3a/0xd4
> [<ffffffff80418335>] rtnetlink_event+0x3d/0x41
> [<ffffffff8047b925>] notifier_call_chain+0x30/0x54
> [<ffffffffa00a3d4b>] :bonding:bond_select_active_slave+0xb9/0xe8
> [<ffffffffa00a495e>] :bonding:__bond_mii_monitor+0x43a/0x464
> [<ffffffffa00a49e6>] :bonding:bond_mii_monitor+0x5e/0xaa
> [<ffffffffa00a4988>] :bonding:bond_mii_monitor+0x0/0xaa
> [<ffffffff8023d6fa>] run_workqueue+0x7f/0x107
> [<ffffffff8023d782>] worker_thread+0x0/0xef
> [<ffffffff8023d867>] worker_thread+0xe5/0xef
> [<ffffffff8024088f>] autoremove_wake_function+0x0/0x2e
> [<ffffffff8024088f>] autoremove_wake_function+0x0/0x2e
> [<ffffffff8024055a>] kthread+0x3d/0x63
> [<ffffffff8020c068>] child_rip+0xa/0x12
> [<ffffffff8024051d>] kthread+0x0/0x63
> [<ffffffff8020c05e>] child_rip+0x0/0x12

	It's from the call to nlmsg_new (an inline that calls alloc_skb)
in rtmsg_ifinfo, which allocates at GFP_KERNEL.  As I recall, there are
other similar cases, so it's not simply a matter of changing
rtmsg_ifinfo.  The notifier calls have to happen with RTNL and no other
locks.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
