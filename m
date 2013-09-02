From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 4/5] bonding: drop read_lock in bond_fix_features
Date: Mon,  2 Sep 2013 13:51:41 +0200
Message-ID: <1378122702-28943-5-git-send-email-nikolay@redhat.com>
References: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754791Ab3IBLz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 07:55:26 -0400
In-Reply-To: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're protected by RTNL so nothing can happen and we can safely drop the
read bond->lock.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 486e041..c5ebdc5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1084,18 +1084,16 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 /*---------------------------------- IOCTL ----------------------------------*/
 
 static netdev_features_t bond_fix_features(struct net_device *dev,
-	netdev_features_t features)
+					   netdev_features_t features)
 {
-	struct slave *slave;
 	struct bonding *bond = netdev_priv(dev);
 	netdev_features_t mask;
-
-	read_lock(&bond->lock);
+	struct slave *slave;
 
 	if (list_empty(&bond->slave_list)) {
 		/* Disable adding VLANs to empty bond. But why? --mq */
 		features |= NETIF_F_VLAN_CHALLENGED;
-		goto out;
+		return features;
 	}
 
 	mask = features;
@@ -1109,8 +1107,6 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	}
 	features = netdev_add_tso_features(features, mask);
 
-out:
-	read_unlock(&bond->lock);
 	return features;
 }
 
-- 
1.8.1.4
