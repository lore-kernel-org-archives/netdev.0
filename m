From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V5 5/11] net/bonding: Enable bonding to enslave non ARPHRD_ETHER
Date: Thu, 20 Sep 2007 16:06:34 +0200
Message-ID: <46F27E6A.5000101@voltaire.com>
References: <46F27692.3070404@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: OpenFabrics General <general@lists.openfabrics.org>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:25766 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754851AbXITOGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 10:06:36 -0400
In-Reply-To: <46F27692.3070404@voltaire.com>
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
 drivers/net/bonding/bond_main.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-15 10:08:59.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-15 10:54:13.424688411 +0300
@@ -1237,6 +1237,26 @@ static int bond_compute_features(struct 
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
@@ -1311,6 +1331,25 @@ int bond_enslave(struct net_device *bond
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

