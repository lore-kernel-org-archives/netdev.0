From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6] bonding: Fix updating of speed/duplex changes
Date: Fri, 06 Mar 2009 15:27:33 -0800
Message-ID: <3038.1236382053@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:49416 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999AbZCFX1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2009 18:27:32 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n26NInr7002168
	for <netdev@vger.kernel.org>; Fri, 6 Mar 2009 18:18:49 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n26NRSLL196168
	for <netdev@vger.kernel.org>; Fri, 6 Mar 2009 18:27:28 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n26NRR0t007463
	for <netdev@vger.kernel.org>; Fri, 6 Mar 2009 18:27:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	This patch corrects an omission from the following commit:

commit f0c76d61779b153dbfb955db3f144c62d02173c2
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Jul 2 18:21:58 2008 -0700

    bonding: refactor mii monitor

	The un-refactored code checked the link speed and duplex of
every slave on every pass; the refactored code did not do so.

	The 802.3ad and balance-alb/tlb modes utilize the speed and
duplex information, and require it to be kept up to date.  This patch
adds a notifier check to perform the appropriate updating when the slave
device speed changes.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bfe1ed8..dce3cf9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3545,11 +3545,26 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 		}
 		break;
 	case NETDEV_CHANGE:
-		/*
-		 * TODO: is this what we get if somebody
-		 * sets up a hierarchical bond, then rmmod's
-		 * one of the slave bonding devices?
-		 */
+		if (bond->params.mode == BOND_MODE_8023AD || bond_is_lb(bond)) {
+			struct slave *slave;
+
+			slave = bond_get_slave_by_dev(bond, slave_dev);
+			if (slave) {
+				u16 old_speed = slave->speed;
+				u16 old_duplex = slave->duplex;
+
+				bond_update_speed_duplex(slave);
+
+				if (bond_is_lb(bond))
+					break;
+
+				if (old_speed != slave->speed)
+					bond_3ad_adapter_speed_changed(slave);
+				if (old_duplex != slave->duplex)
+					bond_3ad_adapter_duplex_changed(slave);
+			}
+		}
+
 		break;
 	case NETDEV_DOWN:
 		/*
-- 
1.6.0.2

