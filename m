From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: RCUify bond_set_rx_mode()
Date: Mon,  5 Aug 2013 11:26:16 +0200
Message-ID: <1375694776-3429-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65268 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab3HEJZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 05:25:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we might easily deadlock with bond_set_rx_mode() and
bond_hw_addr_swap(). bond_set_rx_mode() is called via dev_set_rx_mode(),
which already holds the netif_addr_lock_bh(bond), and inside it takes the
bond->curr_active_slave lock, while bond_hw_addr_swap() is called with
bond->curr_active_slave lock held and then takes netif_addr_lock_bh(bond),
which results in deadlock.

CPU0                    CPU1
----                    ----
lock(&bonding_netdev_addr_lock_key);
			lock(&bond->curr_slave_lock);
			lock(&bonding_netdev_addr_lock_key);
lock(&bond->curr_slave_lock);

Fix this by using the RCU primites in bond_set_rx_mode(). We're safe wrt
racing of dev_?c_(un)sync() because we hold
lock(&bonding_netdev_addr_lock_key), and thus nobody will be able to modify
these lists before we finish.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 476df7d..fdc01c6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3571,24 +3571,22 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 
-	read_lock(&bond->lock);
+	rcu_read_lock();
 
 	if (USES_PRIMARY(bond->params.mode)) {
-		read_lock(&bond->curr_slave_lock);
-		slave = bond->curr_active_slave;
+		slave = rcu_dereference(bond->curr_active_slave);
 		if (slave) {
 			dev_uc_sync(slave->dev, bond_dev);
 			dev_mc_sync(slave->dev, bond_dev);
 		}
-		read_unlock(&bond->curr_slave_lock);
 	} else {
-		bond_for_each_slave(bond, slave) {
+		bond_for_each_slave_rcu(bond, slave) {
 			dev_uc_sync_multiple(slave->dev, bond_dev);
 			dev_mc_sync_multiple(slave->dev, bond_dev);
 		}
 	}
 
-	read_unlock(&bond->lock);
+	rcu_read_unlock();
 }
 
 static int bond_neigh_init(struct neighbour *n)
-- 
1.7.1
