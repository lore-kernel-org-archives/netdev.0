From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: Question regarding failure utilizing bonding mode 5
 (balance-tlb)
Date: Fri, 2 Aug 2013 20:16:43 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52ACF959B@SJEXCHMB10.corp.ad.broadcom.com>
References: <1375333968.21294.30.camel@lb-tlvb-yuvalmin.il.broadcom.com>
 <7717.1375412975@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3533 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab3HBUQ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 16:16:59 -0400
In-Reply-To: <7717.1375412975@death.nxdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >We've had reports that load/unload tests using bonding driver in
> >balance-tlb mode over bnx2x interfaces results in loss of traffic.
> 
> 	I've also been looking into what I suspect is the same thing,
> although using bnx2 and not bnx2x.

Makes sense, given that both follow the same paradigms.

> >When the active slave is unloaded, the ifconfig MAC (dev_addr) is
> >swapped between the slaves directly, i.e., without calling the ndo. Once
> >the interface of the previously active slave will be reloaded, it will
> >configure it's HW MAC according to that dev_addr value  (i.e., the
> >bonding driver takes no additional measures to force it's own MAC on the
> >interface when re-loading), causing it to have a configured MAC which
> >differs from the one that is held by the bonding driver.
> 	The part I don't follow is that in bond_enslave, this sequence
> occurs:
> 
> 	1. bond_enslave calls dev_set_mac_address ("the ndo") to program
> the newly added slave with the master's MAC.  The ndo_set_mac_address
> functions for bnx2x and bnx2 both set dev_addr to the new address.
> 
> 	2. bond_enslave calls dev_open, and the driver's open function
> programs the device's MAC to what's in dev_addr, which is now the
> master's MAC address.

I think 'bond_enslave' is called only on initial enslavement - the code 
doesn't  make sense for me otherwise (as it seems the IFF_SLAVE indication
will be removed only when the slave notify of NETDEV_UNREGISTER, i.e., 
when it is rmmoded and not the interface is closed). 

> 
> 	The above is true, unless fail_over_mac is enabled, and that's
> not a valid option for tlb mode.
> 
> 	Also, in theory the bond will reset the slave's MAC address to
> its "permanent" address when it is released from the bond.  The
> "permanent" address is whatever was in dev_addr when the device was
> enslaved.

Again, I think the permanent address is restored only when the bond
releases the slave, which I don't think happens when the slave is unloaded. 

> >As I see it, either:
> >
> >   1. The bonding driver is flawed in balance-tlb mode and should be
> >fixed.
> >
> >   2. bnx2x's behaviour is flawed - it should have some persistent
> >shadow MAC which should contain the last MAC set - either factory value
> >or what was configured by the ndo, and use it instead of dev_addr when
> >configuring the HW MAC.
> >This would probably indicate that other drivers are flawed as well.
> >
> >   3. The test itself is flawed, since user should not unload slave
> >interfaces.
> >
> >What's the correct approach for fixing the issue?
> 
> 	Well, I suspect it's not going to be #2.  Loading and unloading
> slaves ought to work, and I'm willing to believe that bonding is doing
> something odd, but I don't see what it is from the above.
> 
> 	-J
> 
