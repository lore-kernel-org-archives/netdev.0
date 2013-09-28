From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: RCUify bond_set_rx_mode()
Date: Sat, 28 Sep 2013 21:18:56 +0200
Message-ID: <1380395936-13429-1-git-send-email-vfalico@redhat.com>
Cc: joe.lawrence@stratus.com, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754558Ab3I1TSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 15:18:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we rely on rtnl locking in bond_set_rx_mode(), however it's not
always the case:

RTNL: assertion failed at drivers/net/bonding/bond_main.c (3391)
...
 [<ffffffff81651ca5>] dump_stack+0x54/0x74
 [<ffffffffa029e717>] bond_set_rx_mode+0xc7/0xd0 [bonding]
 [<ffffffff81553af7>] __dev_set_rx_mode+0x57/0xa0
 [<ffffffff81557ff8>] __dev_mc_add+0x58/0x70
 [<ffffffff81558020>] dev_mc_add+0x10/0x20
 [<ffffffff8161e26e>] igmp6_group_added+0x18e/0x1d0
 [<ffffffff81186f76>] ? kmem_cache_alloc_trace+0x236/0x260
 [<ffffffff8161f80f>] ipv6_dev_mc_inc+0x29f/0x320
 [<ffffffff8161f9e7>] ipv6_sock_mc_join+0x157/0x260
...

Fix this by using RCU primitives.

Reported-by: Joe Lawrence <joe.lawrence@stratus.com>
Tested-by: Joe Lawrence <joe.lawrence@stratus.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d5c3153..996d196 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3393,20 +3393,21 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 	struct list_head *iter;
 	struct slave *slave;
 
-	ASSERT_RTNL();
 
+	rcu_read_lock();
 	if (USES_PRIMARY(bond->params.mode)) {
-		slave = rtnl_dereference(bond->curr_active_slave);
+		slave = rcu_dereference(bond->curr_active_slave);
 		if (slave) {
 			dev_uc_sync(slave->dev, bond_dev);
 			dev_mc_sync(slave->dev, bond_dev);
 		}
 	} else {
-		bond_for_each_slave(bond, slave, iter) {
+		bond_for_each_slave_rcu(bond, slave, iter) {
 			dev_uc_sync_multiple(slave->dev, bond_dev);
 			dev_mc_sync_multiple(slave->dev, bond_dev);
 		}
 	}
+	rcu_read_unlock();
 }
 
 static int bond_neigh_init(struct neighbour *n)
-- 
1.8.4
