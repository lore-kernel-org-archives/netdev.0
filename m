From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 1/2] bonding: ensure that the TSO being set on bond master
Date: Wed, 8 Jan 2014 15:28:24 +0800
Message-ID: <52CCFE18.7040606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:19592 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbaAHH2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 02:28:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit b0ce3508(bonding: allow TSO being set on bonding master)
has make the TSO being set for bond dev, but in some situation, if
the slave did not have the NETIF_F_SG features, the bond master will
miss the TSO features in netdev_fix_features because the TSO is
depended on SG. So I have to add SG and TSO features on bond master
together.

The netdev_add_tso_features() was only used for bonding, so I think no
need to export it to netdevice.h.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06c445..8ce67ed 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1045,6 +1045,20 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
+/* Allow TSO being used on stacked device:
+ * Performing the GSO segmentation before last device
+ * is a performance improvement.
+ * The TSO is depended on SG, so add SG and TSO together,
+ * otherwise the netdev_fix_features() may clean the TSO.
+ */
+static netdev_features_t bond_add_tso_features(netdev_features_t features,
+					       netdev_features_t mask)
+{
+	return netdev_increment_features(features,
+					 NETIF_F_ALL_TSO | NETIF_F_SG,
+					 mask);
+}
+
 static netdev_features_t bond_fix_features(struct net_device *dev,
 					   netdev_features_t features)
 {
@@ -1068,7 +1082,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 						     slave->dev->features,
 						     mask);
 	}
-	features = netdev_add_tso_features(features, mask);
+	features = bond_add_tso_features(features, mask);
 
 	return features;
 }
-- 
1.8.0
