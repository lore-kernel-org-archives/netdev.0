From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: how to handle bonding failover when using a bridge over the bond?
Date: Tue, 12 Feb 2013 16:02:26 -0800
Message-ID: <32261.1360713746@death.nxdomain>
References: <511ACE16.3080906@genband.com>
Cc: bonding-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:38141 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441Ab3BMACf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:02:35 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 12 Feb 2013 17:02:34 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D218E6E8020
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 19:02:27 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1D02Shx296296
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 19:02:29 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1D02ScN024045
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 17:02:28 -0700
In-reply-to: <511ACE16.3080906@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> wrote:

>I've got a scenario that seems to be not well handled with the current
>bonding code in linux, but maybe I'm missing something.
>
>I have a physical host with two ethernet links that are bonded together
>(active/backup).  Each link is connected to a separate L2 switch, which
>are in turn connected with a crosslink for redundancy.
>
>The physical host is running multiple virtual machines each with a virtual
>adapter.  The virtual adapters and the bond are all bridged together to
>allow communication between the virtual machines, the host, and the
>outside world.
>
>Now suppose one of the slave links fails. The bond device will failover to
>the other slave and send out a gratuitous arp on the newly active slave.
>This will cause the L2 switches to update their lookup tables for the MAC
>address associated with the bond (so it now points to the newly active
>slave), but doesn't update the MAC addresses associated with the various
>virtual machines.  If someone on the network sends a packet to one of the
>virtual machines, the switch will try to send it over the failed slave.

	If the link failure is such that there is no carrier on the
switch port, the switch will drop the forwarding entry for the virtual
machine's MAC address from that port.  The traffic for the VM's MAC
would then flood to all ports, presumably including the link to the
other switch, which wouldn't have a forwarding entry for the MAC, either
(or it would be the switch link port), and would also flood it to all
ports, one of which is the correct one.

	Now, I'm speculating a bit here, as I have not traced out
exactly how this works.  I have discussed bonding failover with people
here who have systems set up in the manner you describe (and did some
testing), and it appears to be working for them.

	On the other hand, something like a manual change of active
slave won't bring down the carrier of the previously-active slave, and
in that case there might be a problem with traffic destined for one of
the VMs, until the VM sends something that makes it to the new switch.

	Is this actually failing for you, or is this a thought
experiment?

>What's the recommended solution for this?  The logical solution would seem
>to be to have something issue GARPs for each virtual machine when the bond
>device fails over, but there doesn't seem to be any way to register for
>notification (via rtnetlink for instance) when the bond fails over.  I
>could monitor for carrier loss, but that wouldn't work for the case where
>bonding is using arp monitoring.

	There is a NETDEV_BONDING_FAILOVER notifier that is called for
active-backup mode when a new active slave is assigned.  The
rtnetlink_event function is on that chain, and will send an rtnetlink
message, although I don't see that the actual event is included in the
message.

	The bond doesn't track all of the MACs that go through it, but
the bridge presumably does, and could respond to the FAILOVER notifier
with something to notify the switch that the port assignments for the
various MACs have changed.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
