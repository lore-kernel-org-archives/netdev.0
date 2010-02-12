From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: Flooded with bonding: bond0: doing slave updates when interface is down.
Date: Fri, 12 Feb 2010 17:19:50 +0100
Message-ID: <87bpfufmu1.fsf@tac.ki.iif.hu>
References: <87mxzj6eyx.fsf@tac.ki.iif.hu>
	<16013.1265836537@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:55185 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757088Ab0BLQT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 11:19:56 -0500
In-Reply-To: <16013.1265836537@death.nxdomain.ibm.com> (Jay Vosburgh's message
	of "Wed, 10 Feb 2010 13:15:37 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> writes:

> Ferenc Wagner <wferi@niif.hu> wrote:
>
>> On a system running Linux 2.6.32.7 I use the following initramfs script
>> to bring up some interfaces before mounting the root filesystem:
>>
>> [...]
>> modprobe bonding
>> cd /sys/class/net/$BOND/bonding
>> echo active-backup >mode
>> echo +eth0 >slaves
>> echo +eth1 >slaves
>> echo eth0 >primary
>> echo +10.0.0.1 >arp_ip_target
>> echo +10.0.0.2 >arp_ip_target
>> echo 1000 >arp_interval
>> [...]
>>
>> This stuff mostly works as expected, but sometimes I get this on the
>> console:
>>
>> [   27.792746] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
>> [   27.831788] bonding: Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.
>> [   27.935640] bonding: bond0: setting mode to active-backup (1).
>> [   27.970565] bonding: bond0: doing slave updates when interface is down.
>> [   28.010110] bonding: bond0: Adding slave eth0.
>> [   28.036651] bonding bond0: master_dev is not up in bond_enslave
>> [   28.137410] bonding: bond0: Warning: failed to get speed and duplex from eth0, assumed to be 100Mb/sec and Full.
>> [   28.198298] bonding: bond0: making interface eth0 the new active one.
>> [   28.236806] bonding: bond0: first active interface up!
>> [   28.267515] bonding: bond0: enslaving eth0 as an active interface with an up link.
>> [   28.312847] bonding: bond0: doing slave updates when interface is down.
>> [   28.352397] bonding: bond0: doing slave updates when interface is down.
>> [...]
>> [   29.065994] bonding: bond0: doing slave updates when interface is down.
>> [   29.105535] bonding: bond0: doing slave updates when interface is down.
>> [   29.145172] tg3: eth0: Link is up at 1000 Mbps, full duplex.
>> [   29.178990] tg3: eth0: Flow control is off for TX and off for RX.
>> [   29.215415] bonding: bond0: doing slave updates when interface is down.
>> [   29.254956] bonding: bond0: doing slave updates when interface is down.
>> [...]
>> [   78.660009] bonding: bond0: doing slave updates when interface is down.
>> [   78.699825] bonding: bond0: doing slave updates when interface is down.
>> [   78.739373] bonding: bond0: Adding slave eth1.
>> [   78.765914] bonding bond0: master_dev is not up in bond_enslave
>> [   78.817517] tg3 0000:05:01.1: firmware: requesting tigon/tg3_tso.bin
>> [   78.919759] bonding: bond0: Warning: failed to get speed and duplex from eth1, assumed to be 100Mb/sec and Full.
>> [   78.980658] bonding: bond0: enslaving eth1 as a backup interface with an up link.
>> [   79.025492] bonding: bond0: Setting eth0 as primary slave.
>> [   79.058351] bonding: bond0: adding ARP target 10.0.0.1.
>> [   79.089601] bonding: bond0: adding ARP target 10.0.0.2.
>> [   79.120855] bonding: bond0: Setting ARP monitoring interval to 1000.
>>
>> In the end, everything seems to be all right, but this occasional
>> interlude is disturbing and seems to indicate that something isn't quite
>> right.  Which may well be my abuse of the bonding driver, but then
>> please enlighten me, as I'd like to eliminate this 50-second delay from
>> the boot procedure.  I don't mind the couple of "doing slave updates
>> when interface is down" warnings which appear during the normal course
>> of actions, but the above is way too much in my opinion.
>
> The message itself means that you're adding a slave to bonding while
> the bond itself is down.  It's a warning only; the path through the
> function doesn't change when the warning is printed.

Why is the warning printed, btw?  What's wrong with adding a slave to a
bond which is down?

> I would hazard to guess that you're getting zillions of them because
> something is holding rtnl, and the bonding sysfs store function
> conditionally acquires rtnl after printing the warning.  If the rtnl
> acquisition fails, the system call is restarted, and you'll see the
> warning message again.  This rtnl_trylock/restart business is to
> prevent a deadlock during unregister.

Thanks for the explanation.  Is rtnl the shorthand of route netlink?

> I don't know why this repeats for 50-odd seconds, though.  Nothing
> should be holding rtnl for that long.

Forgive me a wild guess: what about the firmware loader?  That uses
sysfs at least, and maybe udev misses the request somehow...

> Do you still get the long delay if you set the bond up prior to adding
> the slaves?  Not necessarily assign an address, just set it
> administratively up (ip link set up dev bond0).

I rebooted a couple of times with this change, and had no problem at
all: no messages, no delay.  However, this issue wasn't reproducible, so
it does not mean too much.  I'll be running with this and yell if I
encounter any delay.  Meanwhile I also upgraded to 2.6.32.8, which I
forgot before running the tests.  I'll recheck with 2.6.32.7 as well.
-- 
Thanks,
Feri.
