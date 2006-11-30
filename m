From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC][PATCH V2 1/3] enable bonding to enslave non ARPHRD_ETHER
 netdevices
Date: Thu, 30 Nov 2006 12:57:15 +0200 (IST)
Message-ID: <Pine.LNX.4.64.0611301256530.26156@zuben>
References: <Pine.LNX.4.64.0611301256130.26156@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: openib-general@openib.org, Roland Dreier <rdreier@cisco.com>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:56794 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1759239AbWK3K5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 05:57:16 -0500
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0611301256130.26156@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

Index: net-2.6.20/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.20.orig/drivers/net/bonding/bond_main.c	2006-11-30 10:54:23.000000000 +0200
+++ net-2.6.20/drivers/net/bonding/bond_main.c	2006-11-30 11:53:06.000000000 +0200
@@ -1252,6 +1252,24 @@ static int bond_compute_features(struct
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
@@ -1326,6 +1344,24 @@ int bond_enslave(struct net_device *bond
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
+		printk(KERN_ERR DRV_NAME ": %s ether type (%d) is different from "
+			"other slaves (%d), can not enslave it.\n", slave_dev->name,
+			slave_dev->type, bond_dev->type);
+			res = -EINVAL;
+			goto err_undo_flags;
+	}
+
 	if (slave_dev->set_mac_address == NULL) {
 		printk(KERN_ERR DRV_NAME
 			": %s: Error: The slave device you specified does "
Index: net-2.6.20/drivers/net/bonding/bonding.h
===================================================================
--- net-2.6.20.orig/drivers/net/bonding/bonding.h	2006-11-30 10:54:23.000000000 +0200
+++ net-2.6.20/drivers/net/bonding/bonding.h	2006-11-30 10:58:10.000000000 +0200
@@ -201,6 +201,7 @@ struct bonding {
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
+	s8       do_set_mac_addr;
 };

 /**

