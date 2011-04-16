From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next-2.6 3/3] bonding,ipv4,ipv6,vlan: Handle NETDEV_BONDING_FAILOVER
 like NETDEV_NOTIFY_PEERS
Date: Fri, 15 Apr 2011 21:51:35 -0400
Message-ID: <4DA8F627.5090109@hp.com>
References: <1302911271.2845.41.camel@bwh-desktop> <22334.1302913805@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:15061 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322Ab1DPBvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 21:51:39 -0400
In-Reply-To: <22334.1302913805@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2011 08:30 PM, Jay Vosburgh wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
>> It is undesirable for the bonding driver to be poking into higher
>> level protocols, and notifiers provide a way to avoid that.  This does
>> mean removing the ability to configure reptitition of gratuitous ARPs
>> and unsolicited NAs.
> 
> 	In principle I think this is a good thing (getting rid of some
> of those dependencies, duplicated code, etc).
> 
> 	However, the removal of the multiple grat ARP and NAs may be an
> issue for some users.  I don't know that we can just remove this (along
> with its API) without going through the feature removal process.

Right, I don't know how many people are using these, they might not be
happy, especially since specifying an unknown parameter will cause a
module load to fail:

--> modprobe bonding foobar=27
FATAL: Error inserting bonding (/lib/modules/2.6.32-31-generic/kernel/drivers/net/bonding/bonding.ko): Unknown symbol in module, or unknown parameter (see dmesg)

When these params are stuffed in /etc/modprobe.d/options, a reboot to
a kernel without them will cause some swearing :)

BTW, if this is accepted you need to update the documentation as well.

> 	As I recall, the multiple gratuitous ARP stuff was added for
> Infiniband, because it is dependent on the grat ARP for a smooth
> failover.
> 
> 	There is also currently logic to check the linkwatch link state
> to wait for the link to go up prior to sending a grat ARP; this is also
> for IB.
> 
> 	Brian Haley added the unsolicited NAs; I've added him to the cc
> so perhaps he (or somebody else) can comment on the necessity of keeping
> the ability to send multiple NAs.

I added it because in an IPv6-only environment I was seeing really long
failover times on bonds.  I believe this was a customer-reported issue, so
there *might* be someone setting it, but I think my testing always showed
one was enough to wake-up the switch.

Is it useful to call netdev_bonding_change() multiple times from within
bond_change_active_slave(), like MAX(arp, na) times?

One comment below...

>> -/*
>> - * Kick out a gratuitous ARP for an IP on the bonding master plus one
>> - * for each VLAN above us.
>> - *
>> - * Caller must hold curr_slave_lock for read or better
>> - */
>> -static void bond_send_gratuitous_arp(struct bonding *bond)
>> -{
>> -	struct slave *slave = bond->curr_active_slave;
>> -	struct vlan_entry *vlan;
>> -	struct net_device *vlan_dev;
>> -
>> -	pr_debug("bond_send_grat_arp: bond %s slave %s\n",
>> -		 bond->dev->name, slave ? slave->dev->name : "NULL");
>> -
>> -	if (!slave || !bond->send_grat_arp ||
>> -	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
>> -		return;
>> -
>> -	bond->send_grat_arp--;
>> -
>> -	if (bond->master_ip) {
>> -		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
>> -				bond->master_ip, 0);
>> -	}
>> -
>> -	if (!bond->vlgrp)
>> -		return;
>> -
>> -	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>> -		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
>> -		if (vlan->vlan_ip) {
>> -			bond_arp_send(slave->dev, ARPOP_REPLY, vlan->vlan_ip,
>> -				      vlan->vlan_ip, vlan->vlan_id);
>> -		}
>> -	}
>> -}

Does your change also cover this case with multiple VLAN IDs?  Is that covered in
the vlan.c code below?

>> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>> index b2ff70f..969e700 100644
>> --- a/net/8021q/vlan.c
>> +++ b/net/8021q/vlan.c
>> @@ -501,13 +501,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
>> 		return NOTIFY_BAD;
>>
>> 	case NETDEV_NOTIFY_PEERS:
>> +	case NETDEV_BONDING_FAILOVER:
>> 		/* Propagate to vlan devices */
>> 		for (i = 0; i < VLAN_N_VID; i++) {
>> 			vlandev = vlan_group_get_device(grp, i);
>> 			if (!vlandev)
>> 				continue;
>>
>> -			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, vlandev);
>> +			call_netdevice_notifiers(event, vlandev);
>> 		}
>> 		break;
>> 	}

Thanks,

-Brian
