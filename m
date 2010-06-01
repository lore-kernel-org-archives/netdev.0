From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and bonding devices
Date: Tue, 01 Jun 2010 11:42:47 -0700
Message-ID: <24059.1275417767@death.nxdomain.ibm.com>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain> <20100527180545.GA2345@sysclose.org> <4BFF2EA5.9090008@redhat.com> <20100528194041.GC2345@sysclose.org> <4C034FA4.5000401@redhat.com> <20100531190820.GA24569@sysclose.org> <4C04D98D.4020509@redhat.com>
Cc: Flavio Leitner <fbl@sysclose.org>, linux-kernel@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:37124 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035Ab0FASmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 14:42:52 -0400
In-reply-to: <4C04D98D.4020509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> wrote:

>On 06/01/10 03:08, Flavio Leitner wrote:
>> On Mon, May 31, 2010 at 01:56:52PM +0800, Cong Wang wrote:
>>> Hi, Flavio,
>>>
>>> Please use the attached patch instead, try to see if it solves
>>> all your problems.
>>
>> I tried and it hangs. No backtraces this time.
>> The bond_change_active_slave() prints before NETDEV_BONDING_FAILOVER
>> notification, so I think it won't work.
>
>Ah, I thought the same.
>
>>
>> Please, correct if I'm wrong, but when a failover happens with your
>> patch applied, the netconsole would be disabled forever even with
>> another healthy slave, right?
>>
>
>Yes, this is an easy solution, because bonding has several modes,
>it is complex to make netpoll work in different modes.

	If I understand correctly, the root cause of the problem with
netconsole and bonding is that bonding is, ultimately, performing
printks with a write lock held, and when netconsole recursively calls
into bonding to send the printk over the netconsole, there is a deadlock
(when the bonding xmit function attempts to acquire the same lock for
read).

	You're trying to avoid the deadlock by shutting off netconsole
(permanently, it looks like) for one problem case: a failover, which
does some printks with a write lock held.

	This doesn't look to me like a complete solution, there are
other cases in bonding that will do printk with write locks held.  I
suspect those will also hang netconsole as things exist today, and won't
be affected by your patch below.

	For example:

	The sysfs functions to set the primary (bonding_store_primary)
or active (bonding_store_active_slave) options: a pr_info is called to
provide a log message of the results.  These could be tested by setting
the primary or active options via sysfs, e.g.,

echo eth0 > /sys/class/net/bond0/bonding/primary
echo eth0 > /sys/class/net/bond0/bonding/active

	If the kernel is defined with DEBUG, there are a few pr_debug
calls within write_locks (bond_del_vlan, for example).

	If the slave's underlying device driver's ndo_vlan_rx_register
or ndo_vlan_rx_kill_vid functions call printk (and it looks like some do
for error cases, e.g., igbvf, ehea, enic), those would also presumably
deadlock (because bonding holds its write_lock when calling the ndo_
vlan functions).

	It also appears that (with the patch below) some nominally
normal usage patterns will immediately disable netconsole.  The one that
comes to mind is if the primary= option is set (to "eth1" for this
example), but that slave not enslaved first (the slaves are added, say,
eth0 then eth1).  In that situation, when the primary slave (eth1 here)
is added, the first thing that will happen is a failover, and that will
disable netconsole.

	Thoughts?

	-J

>Would you like to test the following patch?
>
>Thanks much!
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 5e12462..59ade92 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1109,6 +1109,14 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
> 	if (old_active == new_active)
> 		return;
>
>+	write_unlock_bh(&bond->curr_slave_lock);
>+	read_unlock(&bond->lock);
>+
>+	netdev_bonding_change(bond->dev, NETDEV_BONDING_DESLAVE);
>+
>+	read_lock(&bond->lock);
>+	write_lock_bh(&bond->curr_slave_lock);
>+
> 	if (new_active) {
> 		new_active->jiffies = jiffies;
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
