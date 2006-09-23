From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 5/10] bonding: Handle large hard_header_len
Date: Fri, 22 Sep 2006 21:53:39 -0700
Message-ID: <200609230453.k8N4rdZt028365@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:27863 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750986AbWIWExl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 00:53:41 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4rfpA006399
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:53:41 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4reAY301086
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:53:40 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4ren0008356
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:53:40 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The bonding driver fails to adjust its hard_header_len when enslaving
interfaces.  Whenever an interface with a hard_header_len greater than the
ETH_HLEN default is enslaved, the potential for an oops exists, and if the
oops happens while responding to an arp request, for example, the system
panics.  GIANFAR devices may use an extended hard_header for VLAN or
hardware checksumming.  Enslaving such a device and then transmitting over
it causes a kernel panic.

Patch modified from submitter's original, but submitter agreed with this
patch in private email.

Signed-off-by: Mark Huth <mhuth@mvista.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


--- netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 14:46:07	1.3
+++ netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 15:47:27	1.4
@@ -1211,10 +1211,14 @@ static int bond_compute_features(struct 
 	unsigned long features = BOND_INTERSECT_FEATURES;
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
+	unsigned short max_hard_header_len = ETH_HLEN;
 	int i;
 
-	bond_for_each_slave(bond, slave, i)
+	bond_for_each_slave(bond, slave, i) {
 		features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
+		if (slave->dev->hard_header_len > max_hard_header_len)
+			max_hard_header_len = slave->dev->hard_header_len;
+	}
 
 	if ((features & NETIF_F_SG) && 
 	    !(features & NETIF_F_ALL_CSUM))
@@ -1232,6 +1236,7 @@ static int bond_compute_features(struct 
 
 	features |= (bond_dev->features & ~BOND_INTERSECT_FEATURES);
 	bond_dev->features = features;
+	bond_dev->hard_header_len = max_hard_header_len;
 
 	return 0;
 }

