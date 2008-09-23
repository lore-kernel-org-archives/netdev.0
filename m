From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: dhcp/bonding interaction question
Date: Tue, 23 Sep 2008 09:42:31 -0700
Message-ID: <6323.1222188151@death.nxdomain.ibm.com>
References: <48D90A30.8000701@nortel.com>
Cc: netdev@vger.kernel.org
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:44511 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbYIWQmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 12:42:52 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8NGgo8b030691
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 12:42:50 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8NGgnNa1945756
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 12:42:49 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8NGgmGW001111
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 10:42:48 -0600
In-reply-to: <48D90A30.8000701@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <cfriesen@nortel.com> wrote:

>We've got a boot server configured with two bonded links using the XOR tx
>mode.  Another board comes up.  It's got two links which will eventually
>be bonded.  It issues a DHCP request to the server over one of the links,
>which arrives on one of the bonded slaves.  The server sends a reply, but
>the XOR results in the packet being sent back via the other slave.  On the
>booting blade the xid in the packet doesn't match the xid for the device
>on which the packet was received, so the packet is dropped.

	Presumably the blade is matching xid on a per-interface basis.

	I'm guessing your problem is really due to the nature of the
intra-chassis network on the blade system.  If it's like the ones I'm
familiar with (eth0 of all blades to a single switch, eth1 of all blades
to a different switch, etc), then you can't configure the switches into
an etherchannel group as can be done with the usual configuration
(multiple ports on one switch).  If the other blades in the chassis
aren't also configured for etherchannel (balance-xor is an etherchannel
compatible mode), then they'll see the same MAC arriving on multiple
interfaces and not really be prepared to deal with it.

>What's the proper solution here?  Should dhcpd be forcing reply packets
>out the slave on which the packet was received?

	Why is the blade issuing DHCP before the bond is configured?

	I'm unsure as to whether dhcpd should force replies as
suggested, but recent changes to bonding/net core would probably permit
dhcpd to run directly on the slave (it might need tweaking, I'm not
sure) and accomplish that result.  I don't think it would work on older
versions of bonding, since there's no way to tell which slave a packet
arrived on.

	In that case, dhcpd would have to run on all slaves, since a
bond that uses DHCP for its address assignment might use any of its
interfaces to issue the request, and it would accept a response on any
interface.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
