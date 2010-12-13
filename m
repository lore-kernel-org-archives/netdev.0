From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [RFC PATCH 0/2] bonding: generic netlink, multi-link mode
Date: Mon, 13 Dec 2010 14:07:33 -0800
Message-ID: <1292278055-2842-1-git-send-email-fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:38637 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757850Ab0LMWHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 17:07:43 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBDLxQ2D025448
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 16:59:28 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3DF6B728047
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 17:07:42 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBDM7f7F356082
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 17:07:42 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBDM7fcd022508
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:07:41 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	These patches add support to bonding for generic netlink and a new
multi-link mode.  At the moment, I'm looking primarily for discussion
about the generic netlink and implementation of multi-link.

	First, in patch 1, is a generic netlink infrastructure for
bonding.  This patch provides a "get mode" command and a "slave link state
change" asychnronous notification via a netlink multicast group.  One long
term goal is to have bonding be controlled via netlink, both for
administrative purposes (add / remove slaves, etc) and policy (slave A is
better than slave B).  I'd appreciate feedback from netlink savvy folks as
to whether this is the appropriate starting point.

	Second, in patch 2, is the multi-link kernel code itself, which is
at present a work in progress.  Here, I'm primarily looking for comments
regarding the control interface for this mode.

	As implemented, this is a new mode to bonding, controlled via
generic netlink commands from a user space daemon.  Slave assignment for
outgoing traffic is handled directly by bonding (the mapping table used by
multi-link is within bonding itself, and the usual transmit hash policy is
applied to the set of slaves allowable for a given destination).

	In some private discussion with Andy, he suggested that this would
be better if it utilized the recently added queue mapping facility within
bonding, and then having the queue (and thus slave) assignments performed
at the qdisc level (via a tc filter) instead of within bonding itself.
This, I believe, would require a new tc filter that implements the ability
to set a skb queue_mapping in a hash (of protocol data in the packet) or
round robin fashion.  In this case, the tc filter would also incorporate
all of the netlink functionality for communicating with the user space
daemon (to permit the mappings to be updated).

	Thoughts?

	Lastly, a description of the multi-link system itself.  This is a
reimplementation of a load balancing scheme that has been available on AIX
for some time.  It operates essentially as a load balancer by subnet, with
a UDP-based protocol to exchange multi-link topology information between
participating systems.  Hosts participating in multi-link have IP
addresses in a separate subnet.  Interfaces enslaved to multi-link do not
lose their assigned IP address information, and may also operate
separately from multi-link.

	One notable feature is that multi-link provides load balancing
facilities for network devices that cannot change their MAC address, such
as Infiniband.

	For example, given two systems as follows:

host A:
bond0		10.88.0.1/16
slave eth0	10.0.0.1/16
slave eth1	10.1.0.1/16
slave eth2	10.2.0.1/16

host B:
bond0		10.88.0.2/16
slave eth0	10.0.0.2/16
slave eth1	10.1.0.2/16
slave eth2	10.2.0.2/16

	in this case, host A's bond0 running multi-link would load balance
traffic from 10.88.0.1 to 10.88.0.2 across eth0, eth1 and eth2.  The user
space daemon negotiates the link set to use with other participating
hosts, and communicates that to the multi-link implementation.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

