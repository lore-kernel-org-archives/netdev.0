From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding: propogate vlan_features to bonding master
Date: Fri, 28 Aug 2009 14:57:49 -0700
Message-ID: <1251496672-14498-2-git-send-email-fubar@us.ibm.com>
References: <1251496672-14498-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:46954 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbZH1V5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 17:57:54 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SLrGkY001181
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:53:16 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SLvrRp191390
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:53 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SLvr5a011613
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:53 -0600
In-Reply-To: <1251496672-14498-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propogate the vlan_features of the slave devices to the bonding
master device, using the same logic as for regular features.

	Tested by Or Gerlitz <ogerlitz@voltaire.com>, who also removed
the debug logic from the original test patch.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4798d30..1aeb36c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1331,6 +1331,7 @@ static int bond_compute_features(struct bonding *bond)
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
 	unsigned long features = bond_dev->features;
+	unsigned long vlan_features = 0;
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
-- 
1.6.0.2

