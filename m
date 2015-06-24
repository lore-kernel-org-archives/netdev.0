From: Matan Barak <matanb@mellanox.com>
Subject: [PATCH for-next V6 03/10] net/bonding: Export bond_option_active_slave_get_rcu
Date: Wed, 24 Jun 2015 15:59:19 +0300
Message-ID: <1435150766-6803-4-git-send-email-matanb@mellanox.com>
References: <1435150766-6803-1-git-send-email-matanb@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Moni Shoua <monis@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Matan Barak <matanb@mellanox.com>, netdev@vger.kernel.org
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42539 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752243AbbFXNA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 09:00:27 -0400
In-Reply-To: <1435150766-6803-1-git-send-email-matanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some consumers of the netdev events API would like to know who is the
active slave when a NETDEV_CHANGEUPPER or NETDEV_BONDING_FAILOVER
events occur. For example, when managing RoCE GIDs, GIDs based on the
bond's ips should only be set on the port which corresponds to active
slave netdevice.

Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 drivers/net/bonding/bond_options.c | 13 -------------
 include/net/bonding.h              |  7 +++++++
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 4df2894..c4fe29a8 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -689,19 +689,6 @@ static int bond_option_mode_set(struct bonding *bond,
 	return 0;
 }
 
-static struct net_device *__bond_option_active_slave_get(struct bonding *bond,
-							 struct slave *slave)
-{
-	return bond_uses_primary(bond) && slave ? slave->dev : NULL;
-}
-
-struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond)
-{
-	struct slave *slave = rcu_dereference(bond->curr_active_slave);
-
-	return __bond_option_active_slave_get(bond, slave);
-}
-
 static int bond_option_active_slave_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 78ed135..81a94ed 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -307,6 +307,13 @@ static inline bool bond_uses_primary(struct bonding *bond)
 	return bond_mode_uses_primary(BOND_MODE(bond));
 }
 
+static inline struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond)
+{
+	struct slave *slave = rcu_dereference(bond->curr_active_slave);
+
+	return bond_uses_primary(bond) && slave ? slave->dev : NULL;
+}
+
 static inline bool bond_slave_is_up(struct slave *slave)
 {
 	return netif_running(slave->dev) && netif_carrier_ok(slave->dev);
-- 
2.1.0

Cc: netdev@vger.kernel.org
