From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Tue, 26 Sep 2006 16:40:31 -0700
Message-ID: <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben>
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:6538 "EHLO e36.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S932433AbWIZXkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:40:36 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8QNeX4t021989
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 19:40:33 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8QNeXRA338170
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 17:40:33 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8QNeXeB015547
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 17:40:33 -0600
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <Pine.LNX.4.64.0609261317460.24189@zuben> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>+	/* XXX set the bond dev type and addr len such that the net core code
>+	* (eg arp_mc_map() in net/ipv4/arp.c) would correctly process multicast
>+	* groups set ***before*** the first enslaveness
>+	*/
>+	bond_dev->type     = bonding_dev_type;
>+	bond_dev->addr_len = bonding_dev_addrlen;

	I've been thinking about this a little bit more.  The system is
understandably not set up to deal with this situation, since normal
devices won't ever change their hardware type.

	You almost want to have some kind of call to induce a reload
from scratch of the multicast filter settings (along with whatever else
might be necessary to alter the hardware type on the fly), to be called
by bonding at the time the first slave is added (since slave adds happen
in user context, and can therefore hold rtnl as required by most of the
multicast address handling code).  That seems less hassle than having to
specify the hardware type and address length at module load time.

	A side effect of this is that bonds would have to be restricted
to consisting only of slaves of one hardware type, since slave changes
(and thus hardware type changes) aren't necessarily restricted to user
context.

	Other random thoughts on how to resolve this include modifying
bonding to accept slaves when the master is down (which would also
require changes to the initscripts that normally configure bonding), so
that the initial setting of the, e.g., 224.0.0.1 multicast hardware
address happens to the already-changed hardware type.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
