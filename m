From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: select current active slave when enslaving device
	for mode tlb and alb
Date: Wed, 25 Mar 2009 16:50:23 +0100
Message-ID: <20090325155022.GJ3437@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60711 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758911AbZCYPui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 11:50:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I've hit an issue on my system when I've been using RealTek RTL8139D cards in
bonding interface in mode balancing-alb. When I enslave a card, the current
active slave (bond->curr_active_slave) is not set and the link is therefore
not functional.

----
# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: adaptive load balancing
Primary Slave: None
Currently Active Slave: None
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:1f:1f:01:2f:22
----

The thing that gets it right is when I unplug the cable and then I put it back
into the NIC. Then the current active slave is set to eth1 and link is working
just fine. Here is dmesg log with bonding DEBUG messages turned on:
----
ADDRCONF(NETDEV_UP): bond0: link is not ready
event_dev: bond0, event: 1
IFF_MASTER
event_dev: bond0, event: 8
IFF_MASTER
bond_ioctl: master=bond0, cmd=35216
slave_dev=cac5d800: 
slave_dev->name=eth1: 
eth1: ! NETIF_F_VLAN_CHALLENGED
event_dev: eth1, event: 8
eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
event_dev: eth1, event: 1
event_dev: eth1, event: 8
IFF_SLAVE
Initial state of slave_dev is BOND_LINK_UP
bonding: bond0: enslaving eth1 as an active interface with an up link.
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
event_dev: bond0, event: 4
IFF_MASTER
bond0: no IPv6 routers present

<<<<cable unplug>>>>

eth1: link down
event_dev: eth1, event: 4
IFF_SLAVE
bonding: bond0: link status definitely down for interface eth1, disabling it
event_dev: bond0, event: 4
IFF_MASTER

<<<<cable plug>>>>

eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
event_dev: eth1, event: 4
IFF_SLAVE
bonding: bond0: link status definitely up for interface eth1.
bonding: bond0: making interface eth1 the new active one.
event_dev: eth1, event: 8
IFF_SLAVE
event_dev: eth1, event: 8
IFF_SLAVE
bonding: bond0: first active interface up!
event_dev: bond0, event: 4
IFF_MASTER
----

The current active slave is set by calling bond_select_active_slave() function
from bond_miimon_commit() function when the slave (eth1) link goes to state up.

I also tested this on other machine with Broadcom NetXtreme II BCM5708
1000Base-T NIC and there all works fine. The thing is that this adapter is down
and goes up after few seconds after it is enslaved.

This patch calls bond_select_active_slave() in bond_enslave() function for modes
alb and tlb and makes sure that the current active slave is set up properly even
when the slave state is already up. Tested on both systems, works fine.

Notice: The same problem can maybe also occrur in mode 8023AD but I'm unable to
test that.

Jirka


Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bonding/bond_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e0578fe..ba64666 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1710,6 +1710,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	case BOND_MODE_ALB:
 		new_slave->state = BOND_STATE_ACTIVE;
 		bond_set_slave_inactive_flags(new_slave);
+		bond_select_active_slave(bond);
 		break;
 	default:
 		pr_debug("This slave is always active in trunk mode\n");
