From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V7 3/8] net/bonding: Enable bonding to enslave non ARPHRD_ETHER
Date: Mon, 15 Oct 2007 18:10:44 +0200
Message-ID: <47139104.2070605@voltaire.com>
References: <47138EB7.40703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: jgarzik@pobox.com, fubar@us.ibm.com, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:42081 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756080AbXJOQKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:10:46 -0400
In-Reply-To: <47138EB7.40703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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
---
 drivers/net/bonding/bond_main.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 64bfec3..4f61958 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1238,6 +1238,21 @@ static int bond_compute_features(struct 
 	return 0;
 }
 
+
+static void bond_setup_by_slave(struct net_device *bond_dev,
+				struct net_device *slave_dev)
+{
+	bond_dev->neigh_setup       = slave_dev->neigh_setup;
+
+	bond_dev->type		    = slave_dev->type;
+	bond_dev->hard_header_len   = slave_dev->hard_header_len;
+	bond_dev->addr_len	    = slave_dev->addr_len;
+	bond_dev->header_ops	    = slave_dev->header_ops;
+
+	memcpy(bond_dev->broadcast, slave_dev->broadcast,
+		slave_dev->addr_len);
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1312,6 +1327,25 @@ int bond_enslave(struct net_device *bond
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

