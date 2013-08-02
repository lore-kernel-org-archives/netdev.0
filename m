From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Fri, 02 Aug 2013 18:13:23 +0200
Message-ID: <51FBDAA3.3060508@redhat.com>
References: <20130801121142.GA444@www.manty.net> <51FB9EE5.3040907@redhat.com> <10459.1375458558@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Santiago Garcia Mantinan <manty@manty.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517Ab3HBQNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 12:13:55 -0400
In-Reply-To: <10459.1375458558@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2013 05:49 PM, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> On 08/01/2013 02:11 PM, Santiago Garcia Mantinan wrote:
>>> Hi!
>>>
>>> I'm trying to setup a bond of a couple of vlans, these vlans are different
>>> paths to an upstream switch from a local switch.  I want to do arp
>>> monitoring of the link in order for the bonding interface to know which path
>>> is ok and wich one is broken.  If I set it up using arp monitoring and
>>> without using vlans it works ok, it also works if I set it up using vlans
>>> but without arp monitoring, so the broken setup seems to be with bonding +
>>> arp monitoring + vlans. Here is a schema:
>>>
>>>  -------------
>>> |Remote Switch|
>>>  -------------
>>>    |      |
>>>    P      P
>>>    A      A
>>>    T      T
>>>    H      H
>>>    1      2
>>>    |      |
>>>  ------------
>>> |Local switch|
>>>  ------------
>>>       |
>>>       | VLAN for PATH1
>>>       | VLAN for PATH2
>>>       |
>>>  Linux machine
>>>
>>> The broken setup seems to work but arp monitoring makes it loose the logical
>>> link from time to time, thus changing to other slave if available.  What I
>>> saw when monitoring this with tcpdump is that all the arp requests were
>>> going out and that all the replies where coming in, so acording to the
>>> traffic seen on tcpdump the link should have been stable, but
>>> /proc/net/bonding/bond0 showed the link failures increasing and when testing
>>> with just a vlan interface I was loosing ping when the link was going down.
>>>
>>> I've tried this on Debian wheezy with its 3.2.46 kernel and also the 3.10.3
>>> version in unstable, the tests where done on a couple of machines using a 32
>>> bits kernel with different nics (r8169 and skge).
>>>
>>> I created a small lab to replicate the problem, on this setup I avoided all
>>> the switching and I directly connected the machine with bonding to another
>>> Linux on which I just had eth0.1002 configured with ip 192.168.1.1, the
>>> results where the same as in the full scenario, link on the bonding slave
>>> was going down from time to time.
>>>
>>> This is the setup on the bonding interface.
>>>
>>> auto bond0
>>> iface bond0 inet static
>>>         address 192.168.1.2
>>>         netmask 255.255.255.0
>>>         bond-slaves eth0.1002
>>>         bond-mode active-backup
>>>         bond-arp_validate 0
>>>         bond-arp_interval 5000
>>>         bond-arp_ip_target 192.168.1.1
>>>         pre-up ip link set eth0 up || true
>>>         pre-up ip link add link eth0 name eth0.1002 type vlan id 1002 || true
>>>         down ip link delete eth0.1002 || true
>>>
>> I believe that it is because dev_trans_start() returns 0 for 8021q devices and
>> so the calculations if the slave has transmitted are wrong, and the flip-flop
>> happens.
>> Please try the attached patch, it should resolve your issue (basically it gets
>> the dev_trans_start of the vlan's underlying device if a vlan is found).
>>
>> The patch is against Linus' tree.
>>
>> Cheers,
>> Nik
>>
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 07f257d4..6aac0ae 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -665,6 +665,16 @@ static int bond_check_dev_link(struct bonding *bond,
>> 	return reporting ? -1 : BMSR_LSTATUS;
>> }
>>
>> +static unsigned long bond_dev_trans_start(struct net_device *dev)
>> +{
>> +        struct net_device *real_dev = dev;
>> +
>> +        if (dev->priv_flags & IFF_802_1Q_VLAN)
>> +                real_dev = vlan_dev_real_dev(dev);
>> +
>> +        return dev_trans_start(real_dev);
>> +}
> 
> 	Should this handle nested VLANs?  E.g.,
> 
> static unsigned long bond_dev_trans_start(struct net_device *dev)
> {
> 	while (dev->priv_flags & IFF_802_1Q_VLAN)
> 		dev = vlan_dev_real_dev(dev);
> 
>         return dev_trans_start(dev);
> }
> 
> 	Also, this (ARP monitoring of a VLAN slave) has likely never
> worked, and therefore this change should be considered for -stable.
> 
> 	-J
> 
Yes, it should :-)
Thanks Jay, I'll re-submit it as a proper patch for -net in a bit.

Nik
