From: rama nichanamatlu <rama.nichanamatlu@oracle.com>
Subject: Re: [PATCH] bonding: If IP route look-up to send an ARP fails, mark
 in bonding structure as no ARP sent.
Date: Fri, 22 Nov 2013 00:28:14 -0800
Message-ID: <528F159E.4080706@oracle.com>
References: <528D5980.3040309@oracle.com> <20131121111022.GA30998@redhat.com> <528E6E40.6020201@oracle.com> <17860.1385068379@death.nxdomain> <528EA6A1.5040209@oracle.com> <8059.1385088224@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25358 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754807Ab3KVI2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 03:28:22 -0500
In-Reply-To: <8059.1385088224@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 6:43 PM, Jay Vosburgh wrote:
> rama nichanamatlu <rama.nichanamatlu@oracle.com> wrote:

>> Yes correct. Bonding primary param is set.
>> ex: primary=eth1 and primary_reselect=2.
>> Hence it is expected to be on primary on every reboot.
> 
> 	If I set up a basic bonding configuration like:
> 
Extremely thankful to U for investigating it to this extent.
Need to admit our test requirement here. Reboot test is done 300 times
and requirement is all 300 should see bond intf on primary upon boot.
What is observed is, reboot test never could achieve this until we put
this change.

> [ eth3, eth4 ] -> bond0 -> bond0.66, with primary=eth3 primary_reselect=2
> 
Our config is complex. Here (please ask if not clear):
First niC card  Intel 82599 sr-iov PF0 -> eth0 [dom0]
                                   VF0 -> eth1 [domU] ->
                                                        bond0 -> bond0.1
                                   VF0 -> eth2 [domU] ->
Second niC card Intel 82599 sr-iov PF0 -> eth1 [dom0]

PF = Physical Func
VF = Virtual  Func [are bond slaves]
XEN based OVM [Oracle]

2 arp targets configured.
A lan switch connected to *each* PF hosts a vlan arp target.

AFAIK sr-iov code (can get clarification from Donald/Keller sr-iov
owning team, as we did temp fix of another issue in intel sr-iov driver,
so we are connected) addition of vlan's to sr-iov functions is *as*
simple adding an entry into a table. That is they don't go thru a
re-init like an mtu change. Meaning the intf stays UP during that time.
*But* takes a little while as this table addition is done by PF driver
in dom0 upon request by domU VF driver as there is MBox communication.

> 	Then look at dmesg, I see this sequence:
> 
> 	The bond is set up first, with an arp_ip_target on a VLAN
> destination.  The slaves are added to the bond.
> 
> 	The VLAN interface is configured above the bond, and brought up.
> 
> 	The slaves become link up after autonegotiation, the ARP monitor
> commences, and eth3 is made the active slave.  Even if eth4 is set by
> the bond to be "link status up," eth3 becomes the active slave when it
> becomes "link status up."
> 
> 	What network device are you using for the slaves?  Are they
> virtualized devices of some kind?  My suspicion is that Ethernet
> autonegotiation either does not take place or occurs so quickly that the
> slaves are carrier up before the VLAN is even added.
> 
That is so correct of a guess.
We never saw a link loss message, neither nic driver nor bonding
reporting during vlan addition. Because as carrier is up bond has a
curr_active_slave hence tries to arp but fails as ip_route_output() fails.

> 	Can you check your dmesg output for the sequence of events?  In
> my test, I do not see the slaves go "NIC Link is Up 1000 Mbps Full
> Duplex" until about 3 seconds after the VLAN interface has been
> configured.
> 
so it means bonding driver would not have had a curr_active_slave for
almost 3 secs as none slave would have qualified to become so, hence
bonding never even would attempted to send an arp out.

What we observed is "no route to arp_ip_target" message.
We see 10 of them (5 pairs, as there 2 arp targets and arp interval is
200 msecs) lasting for a 1 sec, then no more error messages. With out
this fix, we would see that bonding failover messages in between those
messages. Eventually when arp'ing is working bonding would be on some
interface, need not be primary.  With this fix, we would not see those
bonding failover messages, and when arp'ing is working bond is on primary.

Requirement of this product being built is to achieve an extremely quick
failover, hence 200 msecs arp interval.

> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
