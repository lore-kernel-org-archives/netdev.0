From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 2/2] bonding: try to enable SG features when adding
 a new, slave
Date: Tue, 14 Jan 2014 17:00:35 +0800
Message-ID: <52D4FCB3.9000408@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:47638 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbaANJBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 04:01:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit b0ce3508(bonding: allow TSO being set on bonding master)
has make the TSO being set for bond dev, but in some situation, if
the slave did not set the NETIF_F_SG features yet, the bond master
will miss the TSO features in netdev_fix_features because the TSO is
depended on SG.

If the slave hw support SG features, but not set yet, I will try to
open it when enslave the dev, better for performance.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4cfe14e..e1044ac 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1083,6 +1083,19 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	return features;
 }
 
+/* If the slave support SG, but not being used yet,
+ * enable the SG features for this slave.
+ */
+static void bond_update_slave_features(struct net_device *dev)
+{
+	if (dev->hw_features & ~dev->features & NETIF_F_SG) {
+		pr_debug("The new dev %s support SG, but not being used yet, enable it\n",
+			 dev->name);
+		dev->wanted_features |= NETIF_F_SG;
+		netdev_update_features(dev);
+	}
+}
+
 #define BOND_VLAN_FEATURES	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
 				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
 				 NETIF_F_HIGHDMA | NETIF_F_LRO)
@@ -1587,6 +1600,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	bond->slave_cnt++;
+	/* Try to enable the SG features for slave dev. */
+	bond_update_slave_features(slave_dev);
 	bond_compute_features(bond);
 	bond_set_carrier(bond);
 
-- 
1.8.0
