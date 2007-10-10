From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/9] net/bonding: Enable bonding to enslave non ARPHRD_ETHER
Date: Tue,  9 Oct 2007 19:43:38 -0700
Message-ID: <11919842263810-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
 <11919842261485-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:42107 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbXJJCnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9A2hlwZ002959
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 22:43:47 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hlxv407592
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:47 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hkmq002016
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:47 -0600
In-Reply-To: <11919842261485-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

This patch changes some of the bond netdevice attributes and functions
to be that of the active slave for the case of the enslaved device not being
of ARPHRD_ETHER type. Basically it overrides those setting done by ether_setup(),
which are netdevice **type** dependent and hence might be not appropriate for
devices of other types. It also enforces mutual exclusion on bonding slaves
from dissimilar ether types, as was concluded over the v1 discussion.

IPoIB (see Documentation/infiniband/ipoib.txt) MAC address is made of a 3 bytes
IB QP (Queue Pair) number and 16 bytes IB port GID (Global ID) of the port this
IPoIB device is bounded to. The QP is a resource created by the IB HW and the
GID is an identifier burned into the HCA (i have omitted here some details which
are not important for the bonding RFC).

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 64bfec3..6ae4593 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1238,6 +1238,20 @@ static int bond_compute_features(struct bonding *bond)
 	return 0;
 }
 
+
+static void bond_setup_by_slave(struct net_device *bond_dev,
+				struct net_device *slave_dev)
+{
+	bond_dev->neigh_setup           = slave_dev->neigh_setup;
+
+	bond_dev->type		    = slave_dev->type;
+	bond_dev->hard_header_len   = slave_dev->hard_header_len;
+	bond_dev->addr_len	    = slave_dev->addr_len;
+
+	memcpy(bond_dev->broadcast, slave_dev->broadcast,
+		slave_dev->addr_len);
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1312,6 +1326,25 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_undo_flags;
 	}
 
+	/* set bonding device ether type by slave - bonding netdevices are
+	 * created with ether_setup, so when the slave type is not ARPHRD_ETHER
+	 * there is a need to override some of the type dependent attribs/funcs.
+	 *
+	 * bond ether type mutual exclusion - don't allow slaves of dissimilar
+	 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the same bond
+	 */
+	if (bond->slave_cnt == 0) {
+		if (slave_dev->type != ARPHRD_ETHER)
+			bond_setup_by_slave(bond_dev, slave_dev);
+	} else if (bond_dev->type != slave_dev->type) {
+		printk(KERN_ERR DRV_NAME ": %s ether type (%d) is different "
+			"from other slaves (%d), can not enslave it.\n",
+			slave_dev->name,
+			slave_dev->type, bond_dev->type);
+			res = -EINVAL;
+			goto err_undo_flags;
+	}
+
 	if (slave_dev->set_mac_address == NULL) {
 		printk(KERN_ERR DRV_NAME
 			": %s: Error: The slave device you specified does "
-- 
1.5.3.1

