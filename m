From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: zero features for a vlan over bond / vlan features
Date: Mon, 08 Jun 2009 12:34:14 +0300
Message-ID: <4A2CDB16.9030000@Voltaire.com>
References: <24949.1240530461@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:19604 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752966AbZFHJeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 05:34:23 -0400
In-Reply-To: <24949.1240530461@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
>>> The features system now has a dev->vlan_features that lists the
>>> features that will work through a vlan; bond_compute_features isn't
>>> using netdev_increment/fix_features to additionally compute the vlan_features, so
>>> that's ending up always empty even if the underlying device supports vlan passthrough

> Ok, here's a patch, but I'm not sure it's the right patch.
> I'm not entirely sure if the vlan_features should be amassed as
> the regular features are, or if it should be a strict subset
> (slave0->vlan_features & slave1->vlan_features, etc).  This patch does the
> former, collecting the vlan_features in a manner analogous to the regular features.

Jay, 

I have tested with your patch and indeed now, vlan-over-bond (e.g bond0.4001) advertises features to the stack wheres before it didn't. Below is the patch you sent with the debugging prints removed and my signature added, I would be happy if you set the change-log && your signature and push it further to Dave. I'm also find if you prefer that I'll do that.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

Index: net-next-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/bonding/bond_main.c
+++ net-next-2.6/drivers/net/bonding/bond_main.c
@@ -1339,6 +1339,7 @@ static int bond_compute_features(struct 
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
 	unsigned long features = bond_dev->features;
+	unsigned long vlan_features = 0;
 	unsigned short max_hard_header_len = max((u16)ETH_HLEN,
 						bond_dev->hard_header_len);
 	int i;
@@ -1351,10 +1352,14 @@ static int bond_compute_features(struct 
 
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
@@ -1362,6 +1367,7 @@ static int bond_compute_features(struct 
 done:
 	features |= (bond_dev->features & BOND_VLAN_FEATURES);
 	bond_dev->features = netdev_fix_features(features, NULL);
+	bond_dev->vlan_features = netdev_fix_features(vlan_features, NULL);
 	bond_dev->hard_header_len = max_hard_header_len;
 
 	return 0;
