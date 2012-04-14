From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: start slaves with link down for ARP monitor
Date: Fri, 13 Apr 2012 22:21:17 -0700
Message-ID: <9048.1334380877@death.nxdomain>
References: <94e5ccf29d92f9a4b815f895b6bb8d9f326566cb.1334256203.git.mkubecek@suse.cz> <20120414015319.11e196d4@asterix.rh>
Cc: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:40427 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302Ab2DNFVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 01:21:24 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 13 Apr 2012 23:21:23 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 72BD81FF0038
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 23:21:19 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3E5LK15184368
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 23:21:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3E5LJlU009914
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 23:21:20 -0600
In-reply-to: <20120414015319.11e196d4@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flavio Leitner <fbl@redhat.com> wrote:

>On Thu, 12 Apr 2012 20:38:09 +0200
>Michal Kubecek <mkubecek@suse.cz> wrote:
>
>> Initialize slave device link state as down if ARP monitor
>> is active. Also shift initial value of its last_arp_tx so that
>> it doesn't immediately cause fake detection of "up" state.
>> 
>> When ARP monitoring is used, initializing the slave device with
>> up link state can cause ARP monitor to detect link failure
>> before the device is really up (with igb driver, this can take
>> more than two seconds).
>> 
>> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
>> ---
>> 
>> When MII monitoring is active for a bond, initial link state of slaves
>> is set according to real link state of the corresponding device,
>> otherwise it is always set to UP. This makes sense if no monitoring is
>> active but with ARP monitoring, it can lead to situations like this:
>> 
>> [ 1280.431383] bonding: bond0: setting mode to active-backup (1).
>> [ 1280.443305] bonding: bond0: adding ARP target 10.11.0.8.
>> [ 1280.454079] bonding: bond0: setting arp_validate to all (3).
>> [ 1280.465561] bonding: bond0: Setting ARP monitoring interval to 500.
>> [ 1280.480366] ADDRCONF(NETDEV_UP): bond0: link is not ready
>> [ 1280.491471] bonding: bond0: Adding slave eth1.
>> [ 1280.584158] bonding: bond0: making interface eth1 the new active one.
>> [ 1280.597274] bonding: bond0: first active interface up!
>> [ 1280.607675] bonding: bond0: enslaving eth1 as an active interface with an up link.
>> [ 1280.623567] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
>> [ 1280.635511] bonding: bond0: Adding slave eth2.
>> [ 1280.726423] bonding: bond0: enslaving eth2 as a backup interface with an up link.
>> [ 1281.976030] bonding: bond0: link status definitely down for interface eth1, disabling it
>> [ 1281.992350] bonding: bond0: making interface eth2 the new active one.
>> [ 1282.639276] igb: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
>> [ 1283.002282] bonding: bond0: link status definitely down for interface eth2, disabling it
>> [ 1283.018713] bonding: bond0: now running without any active interface !
>> [ 1283.529415] bonding: bond0: link status definitely up for interface eth1.
>> [ 1283.543075] bonding: bond0: making interface eth1 the new active one.
>> [ 1283.556614] bonding: bond0: first active interface up!
>> 
>> Here eth1 is enslaved with link state UP but before the device is really
>> UP, ARP monitor detects it is actually down (it takes more than two
>> seconds and arp_interval was set to 500). This causes a spurious failure
>> in logs and in statistics.
>> 
>> I propose to initialize slaves with DOWN link state if ARP monitor is
>> active so that the ARP monitor can switch it to UP when appropriate.
>> This also requires adjusting the initial value of last_arp_rx as setting
>> it to current jiffies would pretend a packet arrived when slave was
>> initialized, leading to DOWN -> UP -> DOWN -> UP sequence.
>> 
>> ---
>>  drivers/net/bonding/bond_main.c |   36 ++++++++++++++++++++++--------------
>>  1 files changed, 22 insertions(+), 14 deletions(-)
>> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 62d2409..c1eda74 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1727,6 +1727,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>  	read_lock(&bond->lock);
>>  
>>  	new_slave->last_arp_rx = jiffies;
>> +	if (bond->params.arp_interval)
>> +		new_slave->last_arp_rx -=
>> +			(msecs_to_jiffies(bond->params.arp_interval) + 1);
>
>
>I don't see the point of checking bond->params.arp_interval.
>Why not simply:
>
>- 	new_slave->last_arp_rx = jiffies;
>+	/* put it behind to avoid fake initial link up detection */
>+	new_slave->last_arp_rx = jiffies -
>+		 (msecs_to_jiffies(bond->params.arp_interval) + 1);
>
>Other than that, works here.

	Agreed.

	There's a couple of other coding style things further down in
the patch as well:

+			if (bond->params.updelay) {
+				new_slave->link = BOND_LINK_BACK;
+				new_slave->delay = bond->params.updelay;
+			} else
+				new_slave->link = BOND_LINK_UP;
+		} else

	Add braces around the else clauses.

+			new_slave->link = BOND_LINK_DOWN;
 	}
+	else if (bond->params.arp_interval)

	Combine the prior two lines into one line.

+		new_slave->link = BOND_LINK_DOWN;
+	else
+		new_slave->link = BOND_LINK_UP;
+
+	if (new_slave->link != BOND_LINK_DOWN)
+		new_slave->jiffies = jiffies;
+	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
+		new_slave->link == BOND_LINK_DOWN ? "DOWN" :
+			(new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));


	The functional part I'm not sure about yet is if the this will
cause slave devices with fast autoneg to wait for an ARP monitor cycle
before going link up according to ARP monitor.

	I think this may work better if the initial slave state is set
to whatever netif_carrier_ok() says, instead of unconditionally up or
down.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
