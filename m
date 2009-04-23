From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: zero features for a vlan over bond / vlan features
Date: Thu, 23 Apr 2009 16:47:41 -0700
Message-ID: <24949.1240530461@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0904061556140.32757@zuben.voltaire.com> <6223.1239113811@death.nxdomain.ibm.com> <49E73C94.5030009@Voltaire.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:48370 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbZDWXrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 19:47:37 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NNg8qW003734
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 17:42:08 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NNlbxj071986
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 17:47:37 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NNlah8013405
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 17:47:37 -0600
In-reply-to: <49E73C94.5030009@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>Jay Vosburgh wrote:
>> The features system now has a dev->vlan_features that lists the
>> features that will work through a vlan; bond_compute_features isn't
>> using netdev_increment/fix_features to additionally compute the vlan_features, 
>> so that's ending up always empty even if the underlying device supports vlan passthrough.
>> I'm working on a patch; I'll see what I can come up with.  
>
>Great, I will be happy to test the patch once you have it...

	Ok, here's a patch, but I'm not sure it's the right patch.

	I'm not entirely sure if the vlan_features should be amassed as
the regular features are, or if it should be a strict subset
(slave0->vlan_features & slave1->vlan_features, etc).  This patch does
the former, collecting the vlan_features in a manner analagous to the
regular features.

	This is strictly a test patch, it's still got printks and such
in it.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 99610f3..967c5b6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1341,6 +1341,7 @@ static int bond_compute_features(struct bonding *bond)
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
 	unsigned long features = bond_dev->features;
+	unsigned long vlan_features = 0;
 	unsigned short max_hard_header_len = max((u16)ETH_HLEN,
 						bond_dev->hard_header_len);
 	int i;
@@ -1352,11 +1353,18 @@ static int bond_compute_features(struct bonding *bond)
 		goto done;
 
 	features &= ~NETIF_F_ONE_FOR_ALL;
-
+	vlan_features = bond->first_slave->dev->vlan_features;
+	printk("vf %lx\n", vlan_features);
 	bond_for_each_slave(bond, slave, i) {
 		features = netdev_increment_features(features,
 						     slave->dev->features,
 						     NETIF_F_ONE_FOR_ALL);
+		vlan_features = netdev_increment_features(vlan_features,
+						  slave->dev->vlan_features,
+							  NETIF_F_ONE_FOR_ALL);
+		printk("slave %s (f %lx vf %lx) new f %lx vf %lx\n",
+		       slave->dev->name, slave->dev->features,
+		       slave->dev->vlan_features, features, vlan_features);
 		if (slave->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len = slave->dev->hard_header_len;
 	}
@@ -1364,6 +1372,8 @@ static int bond_compute_features(struct bonding *bond)
 done:
 	features |= (bond_dev->features & BOND_VLAN_FEATURES);
 	bond_dev->features = netdev_fix_features(features, NULL);
+	bond_dev->vlan_features = netdev_fix_features(vlan_features, NULL);
+	printk("bd->vf %lx\n", bond_dev->vlan_features);
 	bond_dev->hard_header_len = max_hard_header_len;
 
 	return 0;


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
