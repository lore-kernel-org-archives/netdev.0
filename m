From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Question regarding failure utilizing bonding mode 5 (balance-tlb)
Date: Thu, 01 Aug 2013 20:09:35 -0700
Message-ID: <7717.1375412975@death.nxdomain>
References: <1375333968.21294.30.camel@lb-tlvb-yuvalmin.il.broadcom.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>
To: "Yuval Mintz" <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40005 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab3HBDJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 23:09:39 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 1 Aug 2013 21:09:38 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 973541FF001E
	for <netdev@vger.kernel.org>; Thu,  1 Aug 2013 21:04:13 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7239aBq167524
	for <netdev@vger.kernel.org>; Thu, 1 Aug 2013 21:09:36 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7239aSr010762
	for <netdev@vger.kernel.org>; Thu, 1 Aug 2013 21:09:36 -0600
In-reply-to: <1375333968.21294.30.camel@lb-tlvb-yuvalmin.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval Mintz <yuvalmin@broadcom.com> wrote:

>We've had reports that load/unload tests using bonding driver in
>balance-tlb mode over bnx2x interfaces results in loss of traffic.

	I've also been looking into what I suspect is the same thing,
although using bnx2 and not bnx2x.

>When investigating, we've found out that the bonding driver uses the ndo
>(ndo_change_mac_addr()) during ifenslave to override the slaves' HW MAC
>address. It then directly goes and changes the slaves netdevices'
>dev_addr so that each network interface would posses a distinguish MAC
>address (as seen in ifconfig), while the FW/HW of both interfaces is
>still configured by the MAC passed by the ndo.

	Yes.

>When the active slave is unloaded, the ifconfig MAC (dev_addr) is
>swapped between the slaves directly, i.e., without calling the ndo. Once
>the interface of the previously active slave will be reloaded, it will
>configure it's HW MAC according to that dev_addr value  (i.e., the
>bonding driver takes no additional measures to force it's own MAC on the
>interface when re-loading), causing it to have a configured MAC which
>differs from the one that is held by the bonding driver.

	I'm not sure I follow this part, looking at the code.
Basically, and correct me if I'm missing something, what you're
describing is this:

	1. Add and remove some slaves until the removed slave ends up
with dev_addr set to something stale (not it's nominal permanent
hardware address).

	2. Enslave that device, bond_enslave calls dev_open, and the
driver's open function programs the device's MAC to what's in dev_addr

	The part I don't follow is that in bond_enslave, this sequence
occurs:

	1. bond_enslave calls dev_set_mac_address ("the ndo") to program
the newly added slave with the master's MAC.  The ndo_set_mac_address
functions for bnx2x and bnx2 both set dev_addr to the new address.

	2. bond_enslave calls dev_open, and the driver's open function
programs the device's MAC to what's in dev_addr, which is now the
master's MAC address.

	The above is true, unless fail_over_mac is enabled, and that's
not a valid option for tlb mode.  

	Also, in theory the bond will reset the slave's MAC address to
its "permanent" address when it is released from the bond.  The
"permanent" address is whatever was in dev_addr when the device was
enslaved.

	Am I misunderstanding something here?

>If this is done an additional time (on the newly active slave), both
>slave devices will be configured to a MAC which differs from the one
>held by the bond interface (i.e., the bond interface holds the MAC of
>the original active slave, while both interfaces configured the MAC of
>the original inactive slave). This obviously prevents any traffic from
>being successfully sent/received.

	Now, this part does explain the end result that we see as well,
although it's been more random here (we did not have a specific recipe
to induce it, so I'll be trying out yours as soon as I can).  The device
can TX just fine, but all incoming traffic is dropped.  Placing the
device into promiscuous mode works around the problem for as long as
promisc is enabled.

>bnx2x uses dev_addr directly for MAC configuration, which I think is the
>default behaviour for most network drivers - ixgbe has a shadow value
>which it uses instead, but I think that's the exception and not the
>rule.
>
>As I see it, either:
>
>   1. The bonding driver is flawed in balance-tlb mode and should be
>fixed.
>
>   2. bnx2x's behaviour is flawed - it should have some persistent
>shadow MAC which should contain the last MAC set - either factory value
>or what was configured by the ndo, and use it instead of dev_addr when
>configuring the HW MAC.
>This would probably indicate that other drivers are flawed as well.
>
>   3. The test itself is flawed, since user should not unload slave
>interfaces.
>
>What's the correct approach for fixing the issue?

	Well, I suspect it's not going to be #2.  Loading and unloading
slaves ought to work, and I'm willing to believe that bonding is doing
something odd, but I don't see what it is from the above.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
