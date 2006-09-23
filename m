From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 6/10] bonding: Add priv_flag to avoid event mishandling
Date: Fri, 22 Sep 2006 21:54:10 -0700
Message-ID: <200609230454.k8N4sAZt028652@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:55259 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750989AbWIWEyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 00:54:12 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4sHpi021877
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:54:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4sBKv275756
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:54:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4sBsK015265
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:54:11 -0400
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add priv_flag to specifically identify bonding-involved devices.  Needed
because IFF_MASTER is an unreliable identifier (vlan interfaces above bonding
will inherit IFF_MASTER).  Misidentification of devices would cause
notifier events for other devices to be erroneously processed by bonding,
causing various havoc.

Bug discovered by Martin Papik <martin.papik@ipsec.info>; this patch is
modified from his original.

Signed-off-by: Martin Papik <martin.papik@ipsec.info>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

--- netdev-2.6.git-upstream/include/linux/if.h	2006/08/26 17:23:42	1.1
+++ netdev-2.6.git-upstream/include/linux/if.h	2006/08/26 17:24:23	1.2
@@ -59,6 +59,7 @@
 #define IFF_SLAVE_INACTIVE	0x4	/* bonding slave not the curr. active */
 #define IFF_MASTER_8023AD	0x8	/* bonding master, 802.3ad. 	*/
 #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
+#define IFF_BONDING	0x20		/* bonding master or slave	*/
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
--- netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 15:47:27	1.4
+++ netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/26 17:24:41	1.5
@@ -1371,6 +1371,7 @@ int bond_enslave(struct net_device *bond
 	}
 
 	new_slave->dev = slave_dev;
+	slave_dev->priv_flags |= IFF_BONDING;
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
@@ -1784,7 +1785,7 @@ int bond_release(struct net_device *bond
 	dev_set_mac_address(slave_dev, &addr);
 
 	slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
-				   IFF_SLAVE_INACTIVE);
+				   IFF_SLAVE_INACTIVE | IFF_BONDING);
 
 	kfree(slave);
 
@@ -3216,6 +3217,9 @@ static int bond_netdev_event(struct noti
 		(event_dev ? event_dev->name : "None"),
 		event);
 
+	if (!(event_dev->priv_flags & IFF_BONDING))
+		return NOTIFY_DONE;
+
 	if (event_dev->flags & IFF_MASTER) {
 		dprintk("IFF_MASTER\n");
 		return bond_master_netdev_event(event, event_dev);
@@ -4185,6 +4189,7 @@ static int bond_init(struct net_device *
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
+	bond_dev->priv_flags |= IFF_BONDING;
 
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an

