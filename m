From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [E1000-devel] discussion questions: SR-IOV, virtualization, and bonding
Date: Thu, 02 Aug 2012 16:01:31 -0700
Message-ID: <20421.1343948491@death.nxdomain>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain> <501AFEAD.10001@genband.com> <501B0037.1010804@genband.com>
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45882 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758Ab2HBXBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 19:01:41 -0400
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 2 Aug 2012 19:01:40 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 5FC4E38C803A
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2012 19:01:35 -0400 (EDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q72N1Y0e043904
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2012 19:01:34 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q72N1WUJ001469
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2012 17:01:33 -0600
In-reply-to: <501B0037.1010804@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> wrote:

>On 08/02/2012 04:26 PM, Chris Friesen wrote:
>> On 08/02/2012 02:30 PM, Jay Vosburgh wrote:
>
>>> The best long term solution is to have a user space API that
>>> provides link state input to bonding on a per-slave basis, and then some
>>> user space entity can perform whatever link monitoring method is
>>> appropriate (e.g., LLDP) and pass the results to bonding.
>>
>> I think this has potential. This requires a virtual communication
>> channel between guest/host if we want the host to be able to influence
>> the guest's choice of active link, but I think that's not unreasonable.

	Not necessarily, if something like LLDP runs across the virtual
link between the guest and slave, then the guest will notice when the
link goes down (although perhaps not very quickly).  I'm pretty sure the
infrastructure to make LLDP work on inactive slaves is already there; as
I recall, the "no wildcard" or "deliver exact" business in the receive
path is at least partially for LLDP.

	Still, though, isn't "influence the guest's choice" pretty much
satisified by having the VF interface go carrier down in the guest when
the host wants it to?  Or are you thinking about more fine grained than
that?

>> Actually, couldn't we do this now? Turn off miimon and arpmon, then just
>> have the userspace thing write to /sys/class/net/bondX/bonding/active_slave

	That might work for active-backup mode, yes, although it may not
handle the case when all slaves have failed if "failed" does not include
the slave being carrier down.  It's not quite the same thing as input to
the link monitoring logic.

>Hmm...looks like the bonding code requires either miimon or arpmon.  I
>wonder if setting miimon to INT_MAX might work, at least for some bonding
>modes.

	Not true; it's legal to leave miimon and arp_interval set to 0.
Older versions of bonding will whine about it, but let you do it; in
mainline, it's a debug message you have to choose to turn on (because
current versions of initscripts, et al, create the bond first, and then
set those options, so it tended to whine all the time).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
