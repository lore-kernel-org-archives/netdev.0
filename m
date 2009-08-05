From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH, RFC] bonding: prevent outgoing packets on inactive slaves
Date: Wed, 05 Aug 2009 10:01:16 -0700
Message-ID: <24645.1249491676@death.nxdomain.ibm.com>
References: <20090805162429.GD16093@midget.suse.cz>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:60534 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934703AbZHERBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 13:01:20 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n75GuXYe001291
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2009 10:56:33 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n75H1KaE043874
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2009 11:01:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n75H1JG5022815
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2009 11:01:20 -0600
In-reply-to: <20090805162429.GD16093@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>Applications exist that broadcast/multicast packets on all
>devices in the system (e.g. avahi-mdns).
>
>When a device is an inactive slave of a bond in active-backup
>mode, its MAC address may be set identical to other divecies in
>the bond. The broadcast/multicast packets may then confuse
>switches to direct packets to the inactive slave, rather than the
>active one.
>
>This patch makes sure the TX queues on inactive slaves are
>deactivated.
>
>Signed-off-by: Jiri Bohac <jbohac@suse.cz>

	I'd love to include this patch; many times I've tracked down
"bonding" problems to some errant dingus confusing the switch, but I
think this patch will break some things, and therefore has to be a NAK.

	Specifically, I suspect this will break users of some protocols
that intentionally (and legitimately) bind directly to the slave
underneath bonding, LLDP for one.  I'm fairly sure there are such users,
because the inactive slave rx path was changed last year to permit
explicit binds to the inactive slaves to receive packets that normally
would be dropped:

commit 0d7a3681232f545c6a59f77e60f7667673ef0e93
Author: Joe Eykholt <jre@nuovasystems.com>
Date:   Wed Jul 2 18:22:01 2008 -0700

    net/core: Allow certain receives on inactive slave.
    
    Allow a packet_type that specifies the exact device to receive
    even on an inactive bonding slave devices.  This is important for some
    L2 protocols such as LLDP and FCoE.  This can eventually be used
    for the bonding special cases as well.
    
    Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

	The fact that they're receiving on the inactive slave suggests
that there may be transmits on the same slave, and a quick read of the
LLDP spec seems to agree.  I'm also unsure of exactly how FCoE operates
in this regard (whether it does anything that will break due to this
patch).

	Anybody have better information about LLDP or FCoE?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
