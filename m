From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 8/9] net/mlx5: Add error prints when validate ETS failed
Date: Mon, 29 Aug 2016 01:13:49 +0300
Message-ID: <1472422430-21583-9-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53049 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756151AbcH1WOe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:34 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Upon set ETS failure due to user invalid input, add error prints to
specify the exact error to the user.

Fixes: cdcf11212b22 ('net/mlx5e: Validate BW weight values of ETS')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index caa9a3c..762af16 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -127,29 +127,40 @@ int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets)
 	return mlx5_set_port_tc_bw_alloc(mdev, tc_tx_bw);
 }
 
-static int mlx5e_dbcnl_validate_ets(struct ieee_ets *ets)
+static int mlx5e_dbcnl_validate_ets(struct net_device *netdev,
+				    struct ieee_ets *ets)
 {
 	int bw_sum = 0;
 	int i;
 
 	/* Validate Priority */
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
-		if (ets->prio_tc[i] >= MLX5E_MAX_PRIORITY)
+		if (ets->prio_tc[i] >= MLX5E_MAX_PRIORITY) {
+			netdev_err(netdev,
+				   "Failed to validate ETS: priority value greater than max(%d)\n",
+				    MLX5E_MAX_PRIORITY);
 			return -EINVAL;
+		}
 	}
 
 	/* Validate Bandwidth Sum */
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
 		if (ets->tc_tsa[i] == IEEE_8021QAZ_TSA_ETS) {
-			if (!ets->tc_tx_bw[i])
+			if (!ets->tc_tx_bw[i]) {
+				netdev_err(netdev,
+					   "Failed to validate ETS: BW 0 is illegal\n");
 				return -EINVAL;
+			}
 
 			bw_sum += ets->tc_tx_bw[i];
 		}
 	}
 
-	if (bw_sum != 0 && bw_sum != 100)
+	if (bw_sum != 0 && bw_sum != 100) {
+		netdev_err(netdev,
+			   "Failed to validate ETS: BW sum is illegal\n");
 		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -159,7 +170,7 @@ static int mlx5e_dcbnl_ieee_setets(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
 
-	err = mlx5e_dbcnl_validate_ets(ets);
+	err = mlx5e_dbcnl_validate_ets(netdev, ets);
 	if (err)
 		return err;
 
-- 
2.7.4
