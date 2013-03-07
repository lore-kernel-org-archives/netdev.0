From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: upgrade to 3.8.1 : BUG Scheduling while atomic in bonding driver:
Date: Thu, 7 Mar 2013 15:59:18 +0100
Message-ID: <CAE3RKNnrDDh1Y_4+NAKuG3-A9qaC-mPXr7e9vefrNHHUUTE=SA@mail.gmail.com>
References: <513063B4.8070604@tlinx.org> <1362155087.15793.54.camel@edumazet-glaptop>
 <51317FCF.1070400@tlinx.org> <51318C5B.60001@tlinx.org> <51382AFE.5080302@linux.vnet.ibm.com>
 <51383C47.7050009@tlinx.org> <513849F8.3090302@linux.vnet.ibm.com>
 <513854E6.9010709@tlinx.org> <513862DA.20704@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linda Walsh <lkml@tlinx.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:62448 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759216Ab3CGO7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 09:59:41 -0500
Received: by mail-wg0-f45.google.com with SMTP id dq12so986753wgb.0
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 06:59:40 -0800 (PST)
In-Reply-To: <513862DA.20704@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 7, 2013 at 10:50 AM, Michael Wang
<wangyun@linux.vnet.ibm.com> wrote:
> On 03/07/2013 04:50 PM, Linda Walsh wrote:
>>
>> I am *not* seeing the bug in 3.8.2 with the 2nd patch applied (in
>> addition to the first)...
>
> So that means bond lock is the reason, nice, but this is really not a
> good fix if we just unlock it...

You're right, we can't unlock bond->lock while in bond_for_each_slave(),
however I think we don't even need that bond_update_speed_duplex() in
bond_miimon_commit() - cause the speed/duplex on interface state change
were already updated via NETDEV_UP/CHANGE event in
bond_slave_netdev_event() - and if not, it's not our fault, but the
driver's that he didn't call the notifiers.

So, maybe something like this would work (any feedback welcome, it's
definitely not the first time we hit the wall with sleeping in
bond_update_speed_duplex):

Subject: [PATCH] bonding: don't call update_speed_duplex() under spinlocks

bond_update_speed_duplex() might sleep while calling underlying slave's
routines. Move it out of atomic context in bond_enslave() and remove it
from bond_miimon_commit() - it was introduced by commit 546add79, however
when the slave interfaces go up/change state it's their responsability to
fire NETDEV_UP/NETDEV_CHANGE events so that bonding can properly update
their speed.

---
 drivers/net/bonding/bond_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7bd068a..c63a33c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1746,6 +1746,8 @@ int bond_enslave(struct net_device *bond_dev,
struct net_device *slave_dev)

 	bond_compute_features(bond);

+	bond_update_speed_duplex(new_slave);
+
 	read_lock(&bond->lock);

 	new_slave->last_arp_rx = jiffies -
@@ -1798,8 +1800,6 @@ int bond_enslave(struct net_device *bond_dev,
struct net_device *slave_dev)
 		new_slave->link == BOND_LINK_DOWN ? "DOWN" :
 			(new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));

-	bond_update_speed_duplex(new_slave);
-
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
 		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
@@ -2373,8 +2373,6 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_set_backup_slave(slave);
 			}

-			bond_update_speed_duplex(slave);
-
 			pr_info("%s: link status definitely up for interface %s, %u Mbps
%s duplex.\n",
 				bond->dev->name, slave->dev->name,
 				slave->speed, slave->duplex ? "full" : "half");
-- 
1.7.1

>
> The better way is to move the cycle wait logical out of the
> bond_update_speed_duplex() IMO, I think we need the folk who work on
> this driver to make the decision ;-)
>
> Regards,
> Michael Wang
>
>>
>>
>> Michael Wang wrote:
>>>
>>>
>>> And both bond_enslave() and bond_mii_monitor() are using bond_update_speed_duplex()
>>> with preempt disabled.
>>>
>>> Along with the changes in bond_enslave(), I think you also need this (untested):
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>> index 11d01d6..9af143a 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -2373,7 +2373,9 @@ static void bond_miimon_commit(struct bonding *bond)
>>>                                 bond_set_backup_slave(slave);
>>>                         }
>>>
>>> +                       read_unlock(&bond->lock);
>>>                         bond_update_speed_duplex(slave);
>>> +                       read_lock(&bond->lock);
>>>
>>>                         pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
>>>                                 bond->dev->name, slave->dev->name,
>>>
>>>
>>> Regards,
>>> Michael Wang
>>>
>>>
>>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Best regards,
Veaceslav Falico
