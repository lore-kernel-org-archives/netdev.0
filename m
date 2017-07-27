From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 02/14] net/mlx5: Consider tx_enabled in all modes on remap
Date: Thu, 27 Jul 2017 13:25:20 +0300
Message-ID: <20170727102532.2317-3-saeedm@mellanox.com>
References: <20170727102532.2317-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Aviv Heller <avivh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44934 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751028AbdG0K1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:27:13 -0400
In-Reply-To: <20170727102532.2317-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

The tx_enabled lag event field is used to determine whether a slave is
active.
Current logic uses this value only if the mode is active-backup.

However, LACP mode, although considered a load balancing mode, can mark
a slave as inactive in certain situations (e.g., LACP timeout).

This fix takes the tx_enabled value into account when remapping, with
no respect to the LAG mode (this should not affect the behavior in XOR
mode, since in this mode both slaves are marked as active).

Fixes: 7907f23adc18 (net/mlx5: Implement RoCE LAG feature)
Signed-off-by: Aviv Heller <avivh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/lag.c | 26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index a3a836bdcfd2..654b02e7d1aa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -162,21 +162,17 @@ static bool mlx5_lag_is_bonded(struct mlx5_lag *ldev)
 static void mlx5_infer_tx_affinity_mapping(struct lag_tracker *tracker,
 					   u8 *port1, u8 *port2)
 {
-	if (tracker->tx_type == NETDEV_LAG_TX_TYPE_ACTIVEBACKUP) {
-		if (tracker->netdev_state[0].tx_enabled) {
-			*port1 = 1;
-			*port2 = 1;
-		} else {
-			*port1 = 2;
-			*port2 = 2;
-		}
-	} else {
-		*port1 = 1;
-		*port2 = 2;
-		if (!tracker->netdev_state[0].link_up)
-			*port1 = 2;
-		else if (!tracker->netdev_state[1].link_up)
-			*port2 = 1;
+	*port1 = 1;
+	*port2 = 2;
+	if (!tracker->netdev_state[0].tx_enabled ||
+	    !tracker->netdev_state[0].link_up) {
+		*port1 = 2;
+		return;
+	}
+
+	if (!tracker->netdev_state[1].tx_enabled ||
+	    !tracker->netdev_state[1].link_up) {
+		*port2 = 1;
 	}
 }
 
-- 
2.13.0
