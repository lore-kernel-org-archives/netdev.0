From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for loadbalancing too?
Date: Tue, 24 Jul 2012 11:13:49 -0700
Message-ID: <21683.1343153629@death.nxdomain>
References: <500EC5CF.3080400@genband.com> <20120724164220.GA1721@minipsycho.orion>
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>, andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:46849 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261Ab2GXUSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 16:18:23 -0400
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 24 Jul 2012 14:45:30 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 44C71C910BE
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 14:14:02 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6OIDup662193756
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 14:13:57 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6OIDpTQ024398
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 12:13:51 -0600
In-reply-to: <20120724164220.GA1721@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> wrote:

>Tue, Jul 24, 2012 at 05:57:03PM CEST, chris.friesen@genband.com wrote:
>>Hi all,
>>
>>We've been starting to look at bonding VFs from separate physical
>>devices in a guest, but we've run into a problem.
>>
>>The host is bonding the corresponding PFs, and it uses arp
>>monitoring.  What we have found is that any broadcast traffic from
>>the guest (if they enable arp monitoring, for example) will be seen
>>by the internal L2 switch of the NIC and sent up into the host, where
>>the bonding driver will count it as incoming packets and use it to
>>mark the link as good.
>>
>>The only solutions I've been able to come up with are:
>>1) add arp validation for load balancing modes as well as active-backup.
>
>This is my favourite.... No reason to not to turn arp validation on.
>TEAM device (teamd arpping linkwatch) does arp or NSNA validation
>always.

	How does that operate for a load balancing mode?

	For arp validate to function (as it's implemented in bonding),
the arp requests (broadcasts) or the arp replies (unicasts) must be seen
by each slave at regular intervals.  Most load balance systems
(etherchannel or 802.3ad, for example) don't flood the broadcast
requests to all members of a channel group, and the unicast replies only
go to one member.

	This generally results in either only one slave staying up, or
slaves going up and down at odd intervals.  The arp monitor for the load
balance modes is already dependent upon there being a steady stream of
traffic to all slaves, and can be unreliable in low traffic conditions
(because not all slaves receive traffic with sufficient frequency).

	-J

>>2) put all the VMs in VLANs
>>
>>Anyone have any better ideas?

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
