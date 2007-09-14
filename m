From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 05/11] net/bonding: Enable bonding to enslave non ARPHRD_ETHER
Date: Fri, 14 Sep 2007 16:40:24 -0700
Message-ID: <11898132411426-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
 <11898132322950-git-send-email-fubar@us.ibm.com>
 <1189813234208-git-send-email-fubar@us.ibm.com>
 <11898132352341-git-send-email-fubar@us.ibm.com>
 <11898132372856-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:44361 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814AbXINXko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:44 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENehRe014925
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:43 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENehH4532118
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENegoU008698
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:43 -0400
In-Reply-To: <11898132372856-git-send-email-fubar@us.ibm.com>
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

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1afda32..13ec73d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1237,6 +1237,26 @@ static int bond_compute_features(struct bonding *bond)
 	return 0;
 }
 
+
+static void bond_setup_by_slave(struct net_device *bond_dev,
+				struct net_device *slave_dev)
+{
+	bond_dev->hard_header	        = slave_dev->hard_header;
+	bond_dev->rebuild_header        = slave_dev->rebuild_header;
+	bond_dev->hard_header_cache	= slave_dev->hard_header_cache;
+	bond_dev->header_cache_update   = slave_dev->header_cache_update;
+	bond_dev->hard_header_parse	= slave_dev->hard_header_parse;
+
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
@@ -1311,6 +1331,25 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
1.5.2-rc2.GIT

