From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) - Problem with ARP monitoring in active backup mode
Date: Fri, 04 Mar 2011 10:18:33 -0800
Message-ID: <19583.1299262713@death>
References: <bug-29712-10286@https.bugzilla.kernel.org/> <20110224145129.f366b59e.akpm@linux-foundation.org> <4D672525.5080609@hp.com> <19879D0AB3081A4B883186484ECC6FC05E780ADF@MPBAGVEX02.corp.mphasis.com> <E351E450E8B9F54684A699D42DC5ADF20C6F1D4A@MPBAGVEX02.corp.mphasis.com> <17444.1298660550@death> <E351E450E8B9F54684A699D42DC5ADF2103267E5@MPBAGVEX02.corp.mphasis.com>
Cc: "Brian Haley" <brian.haley@hp.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: "Harsha R02" <Harsha.R02@mphasis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:45075 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173Ab1CDSSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 13:18:39 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p24I0Jb7005153
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 13:00:19 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4DE4038C803C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2011 13:18:37 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p24IIc23318514
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 13:18:38 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p24IIaER008371
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 15:18:38 -0300
In-reply-to: <E351E450E8B9F54684A699D42DC5ADF2103267E5@MPBAGVEX02.corp.mphasis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harsha R02 <Harsha.R02@mphasis.com> wrote:

>We found that the patch that is presented here has some issues and we
>cannot go with this solution.
>
>In function "bond_ab_arp_probe" in addition to sending arp probes for
>the currently active slave we should also 
>be sending arp probes for the primary_slave if the link status of the
>primary slave is up correct ?
>
>I have made changes as below :
>
>static void bond_ab_arp_probe(struct bonding *bond)
>{
>        struct slave *slave;
>        int i;
>
>        read_lock(&bond->curr_slave_lock);
>
>        if (bond->current_arp_slave && bond->curr_active_slave)
>                pr_info(DRV_NAME "PROBE: c_arp %s && cas %s BAD\n",
>                       bond->current_arp_slave->dev->name,
>                       bond->curr_active_slave->dev->name);
>
>        if (bond->curr_active_slave) {
>+                if((bond->curr_active_slave != bond->primary_slave) &&
>+                   (IS_UP(bond->primary_slave->dev))) {
>+                    bond_arp_send_all(bond, bond->primary_slave);
>+                }
>                bond_arp_send_all(bond, bond->curr_active_slave);
>                read_unlock(&bond->curr_slave_lock);

	No, we can't do this; if we send ARP probes out from an inactive
slave (which the primary would be at this point) it will confuse
switches that snoop traffic to determine the switch port's MAC addresses
(the switches will believe that the "primary" slave is the port to use
to reach the bond's MAC address).

	I think your problem is that your configuration (two systems,
back to back, no switch) is not a configuration the ARP monitor is
designed to work with.

	The ARP monitor determines the availability of backup slaves
based on traffic received by the backup slaves.  The usual source of
this traffic is the ARP broadcast requests being sent out the active
slave and then forwarded by the switch to all switch ports, including
the backup slave's port.  I'm guessing that your system isn't forwarding
these packets like a switch would, and so the primary slave isn't seeing
any incoming packets at all.

	If your primary slave (which is an inactive slave at the moment)
is not receiving traffic, bonding will never believe it is available.

	I've never experimented with using the ARP monitor in a
back-to-back confguration; I'm thinking through how the ARP monitor
functions, and I'm not sure it can be reliable when set up like this.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
