From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Question regarding failure utilizing bonding mode 5 (balance-tlb)
Date: Fri, 02 Aug 2013 13:53:28 -0700
Message-ID: <12779.1375476808@death.nxdomain>
References: <1375333968.21294.30.camel@lb-tlvb-yuvalmin.il.broadcom.com> <7717.1375412975@death.nxdomain> <979A8436335E3744ADCD3A9F2A2B68A52ACF959B@SJEXCHMB10.corp.ad.broadcom.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>
To: "Yuval Mintz" <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:53584 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670Ab3HBUxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 16:53:36 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 2 Aug 2013 16:53:35 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D320538C8027
	for <netdev@vger.kernel.org>; Fri,  2 Aug 2013 16:53:30 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r72KrUfj29687850
	for <netdev@vger.kernel.org>; Fri, 2 Aug 2013 16:53:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r72KrTaK020762
	for <netdev@vger.kernel.org>; Fri, 2 Aug 2013 16:53:30 -0400
In-reply-to: <979A8436335E3744ADCD3A9F2A2B68A52ACF959B@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval Mintz <yuvalmin@broadcom.com> wrote:

>> >We've had reports that load/unload tests using bonding driver in
>> >balance-tlb mode over bnx2x interfaces results in loss of traffic.
>> 
>> 	I've also been looking into what I suspect is the same thing,
>> although using bnx2 and not bnx2x.
>
>Makes sense, given that both follow the same paradigms.
>
>> >When the active slave is unloaded, the ifconfig MAC (dev_addr) is
>> >swapped between the slaves directly, i.e., without calling the ndo. Once
>> >the interface of the previously active slave will be reloaded, it will
>> >configure it's HW MAC according to that dev_addr value  (i.e., the
>> >bonding driver takes no additional measures to force it's own MAC on the
>> >interface when re-loading), causing it to have a configured MAC which
>> >differs from the one that is held by the bonding driver.
>> 	The part I don't follow is that in bond_enslave, this sequence
>> occurs:
>> 
>> 	1. bond_enslave calls dev_set_mac_address ("the ndo") to program
>> the newly added slave with the master's MAC.  The ndo_set_mac_address
>> functions for bnx2x and bnx2 both set dev_addr to the new address.
>> 
>> 	2. bond_enslave calls dev_open, and the driver's open function
>> programs the device's MAC to what's in dev_addr, which is now the
>> master's MAC address.
>
>I think 'bond_enslave' is called only on initial enslavement - the code 
>doesn't  make sense for me otherwise (as it seems the IFF_SLAVE indication
>will be removed only when the slave notify of NETDEV_UNREGISTER, i.e., 
>when it is rmmoded and not the interface is closed). 
>> 
>> 	The above is true, unless fail_over_mac is enabled, and that's
>> not a valid option for tlb mode.
>> 
>> 	Also, in theory the bond will reset the slave's MAC address to
>> its "permanent" address when it is released from the bond.  The
>> "permanent" address is whatever was in dev_addr when the device was
>> enslaved.
>
>Again, I think the permanent address is restored only when the bond
>releases the slave, which I don't think happens when the slave is unloaded. 

	Ah, ok, I was understanding "unloaded" to mean "remove from the
bond."  I think you actually mean "set administratively down," e.g., "ip
link set dev slave down" or the like.  I don't think mere loss of
carrier would trigger the sequence of events, because that won't go
through a dev_close / dev_open cycle.

	Doing that (an admin down / up bounce) would, indeed, cause a
failover, but the bond will not reprogram the MAC on the slave (it
presumes that a fail / recovery will not disrupt the MAC address, which
is apparently not true in this instance).

	I'll have to look at the code a bit, but for now can you confirm
that what you actually mean is, essentially:

	Given a bond0 with two slaves, eth0 and eth1, in tlb mode, eth0
being the active,

	1) "ip link set dev eth0 down" which will fail over to eth1
		(swapping the contents of their dev_addr fields).

	2) "ip link set dev eth0 up" eth0 comes back up, reprograms its
		MAC to the wrong thing (what was in dev_addr).

	3) repeat steps 1 and 2 for eth1

	Is this correct?

>> >As I see it, either:
>> >
>> >   1. The bonding driver is flawed in balance-tlb mode and should be
>> >fixed.
>> >
>> >   2. bnx2x's behaviour is flawed - it should have some persistent
>> >shadow MAC which should contain the last MAC set - either factory value
>> >or what was configured by the ndo, and use it instead of dev_addr when
>> >configuring the HW MAC.
>> >This would probably indicate that other drivers are flawed as well.
>> >
>> >   3. The test itself is flawed, since user should not unload slave
>> >interfaces.
>> >
>> >What's the correct approach for fixing the issue?
>> 
>> 	Well, I suspect it's not going to be #2.  Loading and unloading
>> slaves ought to work, and I'm willing to believe that bonding is doing
>> something odd, but I don't see what it is from the above.

	I think my above statement is still true, but fixing this may be
a bit trickier, or may be a "best effort" type of thing.  One reason is
that, nominally, the tlb mode does not require that the device be able
to change (meaning the ndo call to reprogram) its MAC while open.

	This may not really be a meaningful restriction now, but when
the code was written, not every device / driver could change MAC while
open.  I'm unsure if there are current users that rely on this.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
