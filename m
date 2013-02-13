From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: how to handle bonding failover when using a bridge over the bond?
Date: Tue, 12 Feb 2013 18:30:51 -0600
Message-ID: <511ADEBB.1000701@genband.com>
References: <511ACE16.3080906@genband.com> <32261.1360713746@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og101.obsmtp.com ([64.18.2.155]:60815 "EHLO
	exprod7og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757225Ab3BMAbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:31:25 -0500
In-Reply-To: <32261.1360713746@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2013 06:02 PM, Jay Vosburgh wrote:
> Chris Friesen<chris.friesen@genband.com>  wrote:
>
>> I've got a scenario that seems to be not well handled with the current
>> bonding code in linux, but maybe I'm missing something.
>>
>> I have a physical host with two ethernet links that are bonded together
>> (active/backup).  Each link is connected to a separate L2 switch, which
>> are in turn connected with a crosslink for redundancy.
>>
>> The physical host is running multiple virtual machines each with a virtual
>> adapter.  The virtual adapters and the bond are all bridged together to
>> allow communication between the virtual machines, the host, and the
>> outside world.
>>
>> Now suppose one of the slave links fails. The bond device will failover to
>> the other slave and send out a gratuitous arp on the newly active slave.
>> This will cause the L2 switches to update their lookup tables for the MAC
>> address associated with the bond (so it now points to the newly active
>> slave), but doesn't update the MAC addresses associated with the various
>> virtual machines.  If someone on the network sends a packet to one of the
>> virtual machines, the switch will try to send it over the failed slave.
>
> 	If the link failure is such that there is no carrier on the
> switch port, the switch will drop the forwarding entry for the virtual
> machine's MAC address from that port.  The traffic for the VM's MAC
> would then flood to all ports, presumably including the link to the
> other switch, which wouldn't have a forwarding entry for the MAC, either
> (or it would be the switch link port), and would also flood it to all
> ports, one of which is the correct one.

This makes sense, though it wouldn't cover the case where the link only 
loses carrier in one direction, or if the bond is using arp failover and 
something fails beyond the first hop.

> 	Is this actually failing for you, or is this a thought
> experiment?

It actually failed.  During a customer demo.  :)  From what I understand 
it was a physical link pull, which (based on what you say above) should 
have caused the switch to react appropriately.

I'll see if I can get some more information.  Maybe the switches weren't 
behaving properly or something.

>> What's the recommended solution for this?  The logical solution would seem
>> to be to have something issue GARPs for each virtual machine when the bond
>> device fails over, but there doesn't seem to be any way to register for
>> notification (via rtnetlink for instance) when the bond fails over.  I
>> could monitor for carrier loss, but that wouldn't work for the case where
>> bonding is using arp monitoring.
>
> 	There is a NETDEV_BONDING_FAILOVER notifier that is called for
> active-backup mode when a new active slave is assigned.  The
> rtnetlink_event function is on that chain, and will send an rtnetlink
> message, although I don't see that the actual event is included in the
> message.

If I'm reading this right it will end up sending an RTM_NEWLINK message, 
which seems a bit odd.

> 	The bond doesn't track all of the MACs that go through it, but
> the bridge presumably does, and could respond to the FAILOVER notifier
> with something to notify the switch that the port assignments for the
> various MACs have changed.

That would probably make sense.  I've added the bridging folks, maybe 
they'll have a suggestion how this sort of thing should be handled.

Chris
