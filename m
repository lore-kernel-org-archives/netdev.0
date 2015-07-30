From: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V7 03/10] net/bonding: Export bond_option_active_slave_get_rcu
Date: Thu, 30 Jul 2015 18:33:24 +0300
Message-ID: <1438270411-17648-4-git-send-email-matanb@mellanox.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Somnath Kotur <Somnath.Kotur-idTK6quXuVSLFuii7jzJGg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1438270411-17648-1-git-send-email-matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some consumers of the netdev events API would like to know who is the
active slave when a NETDEV_CHANGEUPPER or NETDEV_BONDING_FAILOVER
events occur. For example, when managing RoCE GIDs, GIDs based on the
bond's ips should only be set on the port which corresponds to active
slave netdevice.

Signed-off-by: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/bonding/bond_options.c | 13 -------------
 include/net/bonding.h              |  7 +++++++
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index e9c624d..28bd005 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -730,19 +730,6 @@ static int bond_option_mode_set(struct bonding *bond,
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
index 20defc0..c1740a2 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -310,6 +310,13 @@ static inline bool bond_uses_primary(struct bonding *bond)
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

Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
