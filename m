From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 2/5] bonding: alb: clean bond->lock
Date: Fri,  5 Sep 2014 20:16:48 +0200
Message-ID: <1409941011-5494-3-git-send-email-nikolay@redhat.com>
References: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906AbaIESRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 14:17:05 -0400
In-Reply-To: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can remove the lock/unlock as it's no longer necessary since
RTNL should be held while calling bond_alb_set_mac_address().

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_alb.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 73c21e233131..028496205f39 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1775,8 +1775,7 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
  * Set the bond->curr_active_slave to @new_slave and handle
  * mac address swapping and promiscuity changes as needed.
  *
- * If new_slave is NULL, caller must hold curr_slave_lock or
- * bond->lock for write.
+ * If new_slave is NULL, caller must hold curr_slave_lock for write
  *
  * If new_slave is not NULL, caller must hold RTNL, curr_slave_lock
  * for write.  Processing here may sleep, so no other locks may be held.
@@ -1857,12 +1856,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	write_lock_bh(&bond->curr_slave_lock);
 }
 
-/*
- * Called with RTNL
- */
+/* Called with RTNL */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
-	__acquires(&bond->lock)
-	__releases(&bond->lock)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
@@ -1895,14 +1890,12 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	} else {
 		alb_set_slave_mac_addr(curr_active, bond_dev->dev_addr);
 
-		read_lock(&bond->lock);
 		alb_send_learning_packets(curr_active,
 					  bond_dev->dev_addr, false);
 		if (bond->alb_info.rlb_enabled) {
 			/* inform clients mac address has changed */
 			rlb_req_update_slave_clients(bond, curr_active);
 		}
-		read_unlock(&bond->lock);
 	}
 
 	return 0;
-- 
1.9.3
