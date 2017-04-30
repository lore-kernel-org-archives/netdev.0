From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/15] net/mlx5e: Act on delay probe time updates
Date: Sun, 30 Apr 2017 16:20:11 +0300
Message-ID: <20170430132016.27012-11-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46780 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932472AbdD3NU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:29 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The user can change delay_first_probe_time parameter through sysctl.
Listen to NETEVENT_DELAY_PROBE_TIME_UPDATE notifications and update the
intervals for updating the neighbours 'used' value periodic task and
for flow HW counters query periodic task.
Both of the intervals will be update only in case the new delay prob
time value is lower the current interval.

Since the driver saves only one min interval value and not per device,
the users will be able to set lower interval value for updating
neighbour 'used' value periodic task but they won't be able to schedule
a higher interval for this periodic task.
The used interval for scheduling neighbour 'used' value periodic task is
the minimal delay prob time parameter ever seen by the driver.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 39 ++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index af61b10b85bf..79462c0368a0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -358,7 +358,9 @@ static int mlx5e_rep_netevent_event(struct notifier_block *nb,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_neigh_hash_entry *nhe = NULL;
 	struct mlx5e_neigh m_neigh = {};
+	struct neigh_parms *p;
 	struct neighbour *n;
+	bool found = false;
 
 	switch (event) {
 	case NETEVENT_NEIGH_UPDATE:
@@ -403,6 +405,43 @@ static int mlx5e_rep_netevent_event(struct notifier_block *nb,
 		}
 		spin_unlock_bh(&neigh_update->encap_lock);
 		break;
+
+	case NETEVENT_DELAY_PROBE_TIME_UPDATE:
+		p = ptr;
+
+		/* We check the device is present since we don't care about
+		 * changes in the default table, we only care about changes
+		 * done per device delay prob time parameter.
+		 */
+#if IS_ENABLED(CONFIG_IPV6)
+		if (!p->dev || (p->tbl != ipv6_stub->nd_tbl && p->tbl != &arp_tbl))
+#else
+		if (!p->dev || p->tbl != &arp_tbl)
+#endif
+			return NOTIFY_DONE;
+
+		/* We are in atomic context and can't take RTNL mutex,
+		 * so use spin_lock_bh to walk the neigh list and look for
+		 * the relevant device. bh is used since netevent can be
+		 * called from a softirq context.
+		 */
+		spin_lock_bh(&neigh_update->encap_lock);
+		list_for_each_entry(nhe, &neigh_update->neigh_list, neigh_list) {
+			if (p->dev == nhe->m_neigh.dev) {
+				found = true;
+				break;
+			}
+		}
+		spin_unlock_bh(&neigh_update->encap_lock);
+		if (!found)
+			return NOTIFY_DONE;
+
+		neigh_update->min_interval = min_t(unsigned long,
+						   NEIGH_VAR(p, DELAY_PROBE_TIME),
+						   neigh_update->min_interval);
+		mlx5_fc_update_sampling_interval(priv->mdev,
+						 neigh_update->min_interval);
+		break;
 	}
 	return NOTIFY_DONE;
 }
-- 
2.11.0
