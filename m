From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Fri, 02 Aug 2013 08:49:18 -0700
Message-ID: <10459.1375458558@death.nxdomain>
References: <20130801121142.GA444@www.manty.net> <51FB9EE5.3040907@redhat.com>
Cc: Santiago Garcia Mantinan <manty@manty.net>, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:34742 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828Ab3HBPta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 11:49:30 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 2 Aug 2013 11:49:29 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 211B76E8044
	for <netdev@vger.kernel.org>; Fri,  2 Aug 2013 11:49:17 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r72FnL2P098146
	for <netdev@vger.kernel.org>; Fri, 2 Aug 2013 11:49:21 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r72FnLMf020871
	for <netdev@vger.kernel.org>; Fri, 2 Aug 2013 11:49:21 -0400
In-reply-to: <51FB9EE5.3040907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>On 08/01/2013 02:11 PM, Santiago Garcia Mantinan wrote:
>> Hi!
>> 
>> I'm trying to setup a bond of a couple of vlans, these vlans are different
>> paths to an upstream switch from a local switch.  I want to do arp
>> monitoring of the link in order for the bonding interface to know which path
>> is ok and wich one is broken.  If I set it up using arp monitoring and
>> without using vlans it works ok, it also works if I set it up using vlans
>> but without arp monitoring, so the broken setup seems to be with bonding +
>> arp monitoring + vlans. Here is a schema:
>> 
>>  -------------
>> |Remote Switch|
>>  -------------
>>    |      |
>>    P      P
>>    A      A
>>    T      T
>>    H      H
>>    1      2
>>    |      |
>>  ------------
>> |Local switch|
>>  ------------
>>       |
>>       | VLAN for PATH1
>>       | VLAN for PATH2
>>       |
>>  Linux machine
>> 
>> The broken setup seems to work but arp monitoring makes it loose the logical
>> link from time to time, thus changing to other slave if available.  What I
>> saw when monitoring this with tcpdump is that all the arp requests were
>> going out and that all the replies where coming in, so acording to the
>> traffic seen on tcpdump the link should have been stable, but
>> /proc/net/bonding/bond0 showed the link failures increasing and when testing
>> with just a vlan interface I was loosing ping when the link was going down.
>> 
>> I've tried this on Debian wheezy with its 3.2.46 kernel and also the 3.10.3
>> version in unstable, the tests where done on a couple of machines using a 32
>> bits kernel with different nics (r8169 and skge).
>> 
>> I created a small lab to replicate the problem, on this setup I avoided all
>> the switching and I directly connected the machine with bonding to another
>> Linux on which I just had eth0.1002 configured with ip 192.168.1.1, the
>> results where the same as in the full scenario, link on the bonding slave
>> was going down from time to time.
>> 
>> This is the setup on the bonding interface.
>> 
>> auto bond0
>> iface bond0 inet static
>>         address 192.168.1.2
>>         netmask 255.255.255.0
>>         bond-slaves eth0.1002
>>         bond-mode active-backup
>>         bond-arp_validate 0
>>         bond-arp_interval 5000
>>         bond-arp_ip_target 192.168.1.1
>>         pre-up ip link set eth0 up || true
>>         pre-up ip link add link eth0 name eth0.1002 type vlan id 1002 || true
>>         down ip link delete eth0.1002 || true
>> 
>I believe that it is because dev_trans_start() returns 0 for 8021q devices and
>so the calculations if the slave has transmitted are wrong, and the flip-flop
>happens.
>Please try the attached patch, it should resolve your issue (basically it gets
>the dev_trans_start of the vlan's underlying device if a vlan is found).
>
>The patch is against Linus' tree.
>
>Cheers,
> Nik
>
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 07f257d4..6aac0ae 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -665,6 +665,16 @@ static int bond_check_dev_link(struct bonding *bond,
> 	return reporting ? -1 : BMSR_LSTATUS;
> }
>
>+static unsigned long bond_dev_trans_start(struct net_device *dev)
>+{
>+        struct net_device *real_dev = dev;
>+
>+        if (dev->priv_flags & IFF_802_1Q_VLAN)
>+                real_dev = vlan_dev_real_dev(dev);
>+
>+        return dev_trans_start(real_dev);
>+}

	Should this handle nested VLANs?  E.g.,

static unsigned long bond_dev_trans_start(struct net_device *dev)
{
	while (dev->priv_flags & IFF_802_1Q_VLAN)
		dev = vlan_dev_real_dev(dev);

        return dev_trans_start(dev);
}

	Also, this (ARP monitoring of a VLAN slave) has likely never
worked, and therefore this change should be considered for -stable.

	-J

>+
> /*----------------------------- Multicast list ------------------------------*/
>
> /*
>@@ -2750,7 +2760,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
> 	 *       so it can wait
> 	 */
> 	bond_for_each_slave(bond, slave, i) {
>-		unsigned long trans_start = dev_trans_start(slave->dev);
>+		unsigned long trans_start = bond_dev_trans_start(slave->dev);
>
> 		if (slave->link != BOND_LINK_UP) {
> 			if (time_in_range(jiffies,
>@@ -2912,7 +2922,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
> 		 * - (more than 2*delta since receive AND
> 		 *    the bond has an IP address)
> 		 */
>-		trans_start = dev_trans_start(slave->dev);
>+		trans_start = bond_dev_trans_start(slave->dev);
> 		if (bond_is_active_slave(slave) &&
> 		    (!time_in_range(jiffies,
> 			trans_start - delta_in_ticks,
>@@ -2947,7 +2957,7 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
> 			continue;
>
> 		case BOND_LINK_UP:
>-			trans_start = dev_trans_start(slave->dev);
>+			trans_start = bond_dev_trans_start(slave->dev);
> 			if ((!bond->curr_active_slave &&
> 			     time_in_range(jiffies,
> 					   trans_start - delta_in_ticks,

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
