From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 1/5] bonding: mc addresses don't get deleted on enslave failure
Date: Thu, 18 Apr 2013 16:34:53 +0200
Message-ID: <1366295697-31037-2-git-send-email-nikolay@redhat.com>
References: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965340Ab3DROh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 10:37:58 -0400
In-Reply-To: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dev_mc_del after err_detach as that's the first error path
after they're added. The main issue is the mc addresses' refcount
which only gets bumped up.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a61a760..dc0153b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1523,6 +1523,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	struct sockaddr addr;
 	int link_reporting;
 	int res = 0;
+	u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
 	if (!bond->params.use_carrier &&
 	    slave_dev->ethtool_ops->get_link == NULL &&
@@ -1726,12 +1727,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		netif_addr_unlock_bh(bond_dev);
 	}
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD)
 		/* add lacpdu mc addr to mc list */
-		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
-
 		dev_mc_add(slave_dev, lacpdu_multicast);
-	}
 
 	bond_add_vlans_on_slave(bond, slave_dev);
 
@@ -1901,6 +1899,11 @@ err_dest_symlinks:
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
 
 err_detach:
+	if (!USES_PRIMARY(bond->params.mode)) {
+		netif_addr_lock_bh(bond_dev);
+		bond_mc_list_flush(bond_dev, slave_dev);
+		netif_addr_unlock_bh(bond_dev);
+	}
 	write_lock_bh(&bond->lock);
 	bond_detach_slave(bond, new_slave);
 	write_unlock_bh(&bond->lock);
-- 
1.8.1.4
