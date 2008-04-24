From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: bonding netdev events
Date: Thu, 24 Apr 2008 18:07:10 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0804241727070.15579@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sean Hefty <sean.hefty@intel.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:45914 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753623AbYDXPHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:07:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

I'd like to hear your opinion on adding bonding related netdev events to be delivered
through the netdevice notifier chain mechanism of include/linux/notifier.h

The need I am dealing with arises from a situation where bonding under active-backup
mode does a "fail-back" to the primary slave device and this should be noted by an
entity outside the bonding driver.

The context is high-availability for drivers such as rNFS and iSER which use the rdma
communication manager (rdma_cm, include/rdma/{ib_addr.h, rdma_cm.h}. The address resolution
service of the rdma cm is based on IP semantics and uses ARP and the device associated with the
resulted neighbour to resolve the RDMA devices/addresses (eg IB GIDs) to use for the connection.
When this is combined with bonding (eg bond0 enslaves ib0 and ib1), the rdma connection is
established through the device associated with the active slave. When some failure occurs, bonding
does fail-over and in parallel the hw rdma connection gets broken. So when the app attempts to
reconnect the rdma cm address resolution (ARP) goes through the new slave and we are done.

Under some occasions the primary option (explained in Documentation/networking/bonding.txt
for those who are not familiar with it) should be applied also to rdma connections. That is, if
possible, the user want the connection to be established over a primary link, meaning that if bonding
does "fail back" to the primary slave, same should go for the rdma connection. Currently, bonding
does this failback, but since the "secondary" link is perfectly fine the rdma connection stays on it.

A quite simple way I was thinking off, is have the rdma cm register to get netdev events, and
have bonding announce the failback through event, say it delivers NETDEV_BONDING_FAILBACK_PRIMARY
where the rdma cm can now act on it.


Or
