From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for loadbalancing too?
Date: Tue, 24 Jul 2012 13:49:35 -0700
Message-ID: <24104.1343162975@death.nxdomain>
References: <500EC5CF.3080400@genband.com> <20120724164220.GA1721@minipsycho.orion> <21683.1343153629@death.nxdomain> <500F032D.3070104@genband.com>
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	andy@greyhouse.net
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:49837 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467Ab2GXUuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:50:18 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 24 Jul 2012 14:50:18 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5CBB53E40039
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 20:50:12 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6OKndLE226802
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 14:49:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6OKnb0r016937
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 14:49:38 -0600
In-reply-to: <500F032D.3070104@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> wrote:

>On 07/24/2012 12:13 PM, Jay Vosburgh wrote:
>> Jiri Pirko<jiri@resnulli.us>  wrote:
>>
>>> Tue, Jul 24, 2012 at 05:57:03PM CEST, chris.friesen@genband.com wrote:
>>>> Hi all,
>>>>
>>>> We've been starting to look at bonding VFs from separate physical
>>>> devices in a guest, but we've run into a problem.
>>>>
>>>> The host is bonding the corresponding PFs, and it uses arp
>>>> monitoring.  What we have found is that any broadcast traffic from
>>>> the guest (if they enable arp monitoring, for example) will be seen
>>>> by the internal L2 switch of the NIC and sent up into the host, where
>>>> the bonding driver will count it as incoming packets and use it to
>>>> mark the link as good.
>>>>
>>>> The only solutions I've been able to come up with are:
>>>> 1) add arp validation for load balancing modes as well as active-backup.
>>> This is my favourite.... No reason to not to turn arp validation on.
>>> TEAM device (teamd arpping linkwatch) does arp or NSNA validation
>>> always.
>> 	How does that operate for a load balancing mode?
>>
>> 	For arp validate to function (as it's implemented in bonding),
>> the arp requests (broadcasts) or the arp replies (unicasts) must be seen
>> by each slave at regular intervals.  Most load balance systems
>> (etherchannel or 802.3ad, for example) don't flood the broadcast
>> requests to all members of a channel group, and the unicast replies only
>> go to one member.
>>
>> 	This generally results in either only one slave staying up, or
>> slaves going up and down at odd intervals.  The arp monitor for the load
>> balance modes is already dependent upon there being a steady stream of
>> traffic to all slaves, and can be unreliable in low traffic conditions
>> (because not all slaves receive traffic with sufficient frequency).
>
>In loadbalance mode wouldn't it just work similar to active-backup?  If
>it's a reply then verify that it came from the arp target, if it's a
>request then check to see if it came from one of the other slaves.

	The problem isn't verifying the requests or replies, it's that
the ARP packets are not distributed across all slaves (because the
switch ports are in a channel group / aggregator), so some slaves do not
receive any ARPs.

	The bond sends the ARP request as a broadcast.  For
active-backup, this ends up at the inactive slaves because the switch
sends the broadcast to all ports.  For a loadbalance mode, the switch
won't send the broadcast ARP to the other slaves, because all the slaves
are in a channel group or lacp aggregator, which is treated by the
switch as effectively a single switch port for this case.

	Similarly, the ARP replies are unicast, and the switch will send
those unicast replies to only one member of the channel group or
aggregator.  The choice there is usually a hash of some kind, so
generally only one slave will receive the replies.

>In our case we have control over the L2 switches involved so we ensure
>that the broadcast arp request is sent to all the other slaves, while the
>reply comes back to the sender.  I think we still have a window where you
>could have a device with a faulty tx but functional rx and never detect
>the problem in the monitor.

	You can set up -xor or -rr mode against a switch without setting
up a channel group on the switch, but that has the down side that any
incoming broadcast or multicast packet may be received multiple times
(one copy per slave).  Some switches will also disable ports (due to MAC
flapping) or complain about seeing the same MAC address on multiple
ports for this case.  This also will not load balance incoming traffic
to the bond very well.

>On 07/24/2012 02:18 PM, Chris Friesen wrote:
>> A more general solution might be to have the device driver also track
>> the time of the last incoming packet that came from the external network
>> (rather than a VF) and having the bond driver ignore those packets for
>> the purpose of link health.  Doing this efficiently would likely require
>> some kind of hardware support though--as an example the 82599 seems to
>> support this with the "LB" bit in the rx descriptor.
>
>That should of course be reversed.  We want the bond driver to only use
>the packets from the external network for the purpose of link health.
>
>Does anyone other than bonding actually care about dev->last_rx?  If not
>then we could just change the drivers to only set it for external packets.

	I believe bonding is the main user of last_rx (a search shows a
couple of drivers using it internally).  For bonding use, in current
mainline last_rx is set by bonding itself, not in the network device
driver.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
