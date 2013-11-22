From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: If IP route look-up to send an ARP fails, mark in bonding structure as no ARP sent.
Date: Thu, 21 Nov 2013 18:43:44 -0800
Message-ID: <8059.1385088224@death.nxdomain>
References: <528D5980.3040309@oracle.com> <20131121111022.GA30998@redhat.com> <528E6E40.6020201@oracle.com> <17860.1385068379@death.nxdomain> <528EA6A1.5040209@oracle.com>
Cc: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
To: rama nichanamatlu <rama.nichanamatlu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:53000 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061Ab3KVCnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 21:43:50 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 21 Nov 2013 19:43:50 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id BE03E1FF001F
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 19:43:28 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAM0g0Dg40894664
	for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 01:42:00 +0100
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAM2hkOO015242
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 19:43:47 -0700
In-reply-to: <528EA6A1.5040209@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rama nichanamatlu <rama.nichanamatlu@oracle.com> wrote:

>On 11/21/2013 1:12 PM, Jay Vosburgh wrote:
>> rama nichanamatlu <rama.nichanamatlu@oracle.com> wrote:
>> 
>>> On 11/21/2013 3:10 AM, Veaceslav Falico wrote:
>>>> On Wed, Nov 20, 2013 at 04:53:20PM -0800, rama nichanamatlu wrote:
>>>>> During the creation of VLAN's atop bonding the underlying interfaces
>>>>> are made part of VLAN's, and at the same bonding driver gets aware
>>>>> that VLAN's exists above it and hence would consult IP routing for
>>>>> every ARP to  be sent to determine the route which tells bonding
>>>>> driver the correct VLAN tag to attach to the outgoing ARP packet. But,
>>>>> during the VLAN creation when vlan driver puts the underlying
>>>>> interface into default vlan and then actual vlan, in-between this if
>>>>> bonding driver consults the IP for a route, IP fails to provide a
>>>>> correct route and upon which bonding driver drops the ARP packet. ARP
>>>>> monitor when it
>>>>> comes around next time, sees no ARP response and fails-over to the
>>>>> next available slave. Consulting for a IP route,
>>>>> ip_route_output(),happens in bond_arp_send_all().
>>>>
>>>> bonding works as expected - nothing to fix here. And even as a
>>>> workaround/hack - I'm not sure we need that to suppress one failover *only*
>>>> when vlan is added on top.
>>>>
>>>>>
>>> Thank U.
>>> With *out* this change our systems failed system testing, to
>>> consistently be on designated primary interface on *every* single
>>> reboot. With this change the behavior was as expected even after a few
>>> thousand reboots & System testing could move to next level catching an
>>> another bug in sr-iov :). And Without, the outcome was less predictable
>>> after a reboot and bonding was on a different slave each time.
>>> -Rama
>> 
>> 	By "designated primary" you mean the bonding primary option,
>> correct?  
>Yes correct. Bonding primary param is set.
>ex: primary=eth1 and primary_reselect=2.
>Hence it is expected to be on primary on every reboot.

	If I set up a basic bonding configuration like:

[ eth3, eth4 ] -> bond0 -> bond0.66, with primary=eth3 primary_reselect=2

	Then look at dmesg, I see this sequence:

	The bond is set up first, with an arp_ip_target on a VLAN
destination.  The slaves are added to the bond.

	The VLAN interface is configured above the bond, and brought up.

	The slaves become link up after autonegotiation, the ARP monitor
commences, and eth3 is made the active slave.  Even if eth4 is set by
the bond to be "link status up," eth3 becomes the active slave when it
becomes "link status up."

	What network device are you using for the slaves?  Are they
virtualized devices of some kind?  My suspicion is that Ethernet
autonegotiation either does not take place or occurs so quickly that the
slaves are carrier up before the VLAN is even added.

	Can you check your dmesg output for the sequence of events?  In
my test, I do not see the slaves go "NIC Link is Up 1000 Mbps Full
Duplex" until about 3 seconds after the VLAN interface has been
configured.


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
