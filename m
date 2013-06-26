From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 2/3] bonding: remove unnecessary dev_addr_from_first member
Date: Wed, 26 Jun 2013 17:13:38 +0200
Message-ID: <1372259619-32430-3-git-send-email-nikolay@redhat.com>
References: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780Ab3FZPRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 11:17:49 -0400
In-Reply-To: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In struct bonding there's a member called dev_addr_from_first which is
used to denote when the bond dev should clone the first slave's MAC
address but since we have netdev's addr_assign_type variable that is not
necessary. We clone the first slave's MAC each time we have a random MAC
set to the bond device. This has the nice side-effect of also fixing an
inconsistency - when the MAC address of the bond dev is set after its
creation, but prior to having slaves, it's not kept and the first slave's
MAC is cloned. The only way to keep the MAC was to create the bond device
with the MAC address set (e.g. through ip link). In all cases if the
bond device is left without any slaves - its MAC gets reset to a random
one as before.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 7 ++-----
 drivers/net/bonding/bonding.h   | 1 -
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2e8b9f1..0da3c12 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1596,7 +1596,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (bond->slave_cnt == 0 && bond->dev_addr_from_first)
+	if (!bond->slave_cnt && bond->dev->addr_assign_type == NET_ADDR_RANDOM)
 		bond_set_dev_addr(bond->dev, slave_dev);
 
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
@@ -2041,7 +2041,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (bond->slave_cnt == 0) {
 		bond_set_carrier(bond);
 		eth_hw_addr_random(bond_dev);
-		bond->dev_addr_from_first = true;
 
 		if (bond_vlan_used(bond)) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
@@ -4800,10 +4799,8 @@ static int bond_init(struct net_device *bond_dev)
 
 	/* Ensure valid dev_addr */
 	if (is_zero_ether_addr(bond_dev->dev_addr) &&
-	    bond_dev->addr_assign_type == NET_ADDR_PERM) {
+	    bond_dev->addr_assign_type == NET_ADDR_PERM)
 		eth_hw_addr_random(bond_dev);
-		bond->dev_addr_from_first = true;
-	}
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c6c8d03..42d1c65 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -248,7 +248,6 @@ struct bonding {
 	/* debugging support via debugfs */
 	struct	 dentry *debug_dir;
 #endif /* CONFIG_DEBUG_FS */
-	bool	dev_addr_from_first;
 };
 
 static inline bool bond_vlan_used(struct bonding *bond)
-- 
1.8.1.4
