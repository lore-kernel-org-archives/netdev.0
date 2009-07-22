From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6] bonding: propogate vlan_features to bonding master
Date: Wed, 22 Jul 2009 14:34:20 -0700
Message-ID: <3463.1248298460@death.nxdomain.ibm.com>
References: <24949.1240530461@death.nxdomain.ibm.com> <4A2CDB16.9030000@Voltaire.com> <4A642600.2010501@voltaire.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:44312 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbZGVVeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 17:34:20 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6MLXZtt022546
	for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 17:33:35 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6MLYJ9K225248
	for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 17:34:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6MLVgAw005457
	for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 17:31:42 -0400
In-reply-to: <4A642600.2010501@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Propogate the vlan_features of the slave devices to the bonding
master device, using the same logic as for regular features.

	Tested by Or Gerlitz <ogerlitz@voltaire.com>, who also removed
the debug logic from the original test patch.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3bf0cc6..5a8b882 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1331,6 +1331,7 @@ static int bond_compute_features(struct bonding *bond)
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
 	unsigned long features = bond_dev->features;
+	unsigned long vlan_features;
 	unsigned short max_hard_header_len = max((u16)ETH_HLEN,
 						bond_dev->hard_header_len);
 	int i;
@@ -1343,10 +1344,14 @@ static int bond_compute_features(struct bonding *bond)
 
 	features &= ~NETIF_F_ONE_FOR_ALL;
 
+	vlan_features = bond->first_slave->dev->vlan_features;
 	bond_for_each_slave(bond, slave, i) {
 		features = netdev_increment_features(features,
 						     slave->dev->features,
 						     NETIF_F_ONE_FOR_ALL);
+		vlan_features = netdev_increment_features(vlan_features,
+							slave->dev->vlan_features,
+							NETIF_F_ONE_FOR_ALL);
 		if (slave->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len = slave->dev->hard_header_len;
 	}
@@ -1354,6 +1359,7 @@ static int bond_compute_features(struct bonding *bond)
 done:
 	features |= (bond_dev->features & BOND_VLAN_FEATURES);
 	bond_dev->features = netdev_fix_features(features, NULL);
+	bond_dev->vlan_features = netdev_fix_features(vlan_features, NULL);
 	bond_dev->hard_header_len = max_hard_header_len;
 
 	return 0;
