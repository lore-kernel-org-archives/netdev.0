From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 5/5] bonding: drop read_lock in bond_compute_features
Date: Mon,  2 Sep 2013 13:51:42 +0200
Message-ID: <1378122702-28943-6-git-send-email-nikolay@redhat.com>
References: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757988Ab3IBLz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 07:55:27 -0400
In-Reply-To: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_compute_features is always called with RTNL held, so we can safely
drop the read bond->lock.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c5ebdc5..39e5b1c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1116,15 +1116,13 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 
 static void bond_compute_features(struct bonding *bond)
 {
-	struct slave *slave;
-	struct net_device *bond_dev = bond->dev;
+	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
 	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
 	unsigned short max_hard_header_len = ETH_HLEN;
 	unsigned int gso_max_size = GSO_MAX_SIZE;
+	struct net_device *bond_dev = bond->dev;
 	u16 gso_max_segs = GSO_MAX_SEGS;
-	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
-
-	read_lock(&bond->lock);
+	struct slave *slave;
 
 	if (list_empty(&bond->slave_list))
 		goto done;
@@ -1150,8 +1148,6 @@ done:
 	flags = bond_dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
 	bond_dev->priv_flags = flags | dst_release_flag;
 
-	read_unlock(&bond->lock);
-
 	netdev_change_features(bond_dev);
 }
 
-- 
1.8.1.4
