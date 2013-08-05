From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: remove locking from bond_set_rx_mode()
Date: Mon,  5 Aug 2013 14:56:06 +0200
Message-ID: <1375707366-6762-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339Ab3HEM4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 08:56:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're already protected by RTNL lock, so nothing can happen to bond/its
slaves, and thus the locking is useless here (both bond->lock and
bond->curr_active_slave).

Also, add ASSERT_RTNL() both to bond_set_rx_mode() and bond_hw_addr_swap()
to catch possible uses of it without RTNL locking.

This patch also saves us from a lockdep false-positive in
bond_set_rx_mode() vs bond_hw_addr_swap().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 476df7d..77501d4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -776,6 +776,8 @@ static void bond_hw_addr_flush(struct net_device *bond_dev,
 static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
 			      struct slave *old_active)
 {
+	ASSERT_RTNL();
+
 	if (old_active) {
 		if (bond->dev->flags & IFF_PROMISC)
 			dev_set_promiscuity(old_active->dev, -1);
@@ -3571,24 +3573,20 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 
-	read_lock(&bond->lock);
+	ASSERT_RTNL();
 
 	if (USES_PRIMARY(bond->params.mode)) {
-		read_lock(&bond->curr_slave_lock);
-		slave = bond->curr_active_slave;
+		slave = rtnl_dereference(bond->curr_active_slave);
 		if (slave) {
 			dev_uc_sync(slave->dev, bond_dev);
 			dev_mc_sync(slave->dev, bond_dev);
 		}
-		read_unlock(&bond->curr_slave_lock);
 	} else {
 		bond_for_each_slave(bond, slave) {
 			dev_uc_sync_multiple(slave->dev, bond_dev);
 			dev_mc_sync_multiple(slave->dev, bond_dev);
 		}
 	}
-
-	read_unlock(&bond->lock);
 }
 
 static int bond_neigh_init(struct neighbour *n)
-- 
1.7.1
