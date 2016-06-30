From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 12/13] net/mlx5e: Validate BW weight values of ETS
Date: Thu, 30 Jun 2016 17:34:49 +0300
Message-ID: <1467297290-11443-13-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37682 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752320AbcF3OhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:21 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

Valid weight assigned to ETS TClass values are 1-100

Fixes: 08fb1dacdd76 ('net/mlx5e: Support DCBNL IEEE ETS')
Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 8 ++++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index b429591..943b1bd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -145,7 +145,6 @@ struct mlx5e_umr_wqe {
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
-#define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
 #endif
 
 struct mlx5e_params {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index b2db180..c585349 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -96,7 +96,7 @@ static void mlx5e_build_tc_tx_bw(struct ieee_ets *ets, u8 *tc_tx_bw,
 			tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
 			break;
 		case IEEE_8021QAZ_TSA_ETS:
-			tc_tx_bw[i] = ets->tc_tx_bw[i] ?: MLX5E_MIN_BW_ALLOC;
+			tc_tx_bw[i] = ets->tc_tx_bw[i];
 			break;
 		}
 	}
@@ -140,8 +140,12 @@ static int mlx5e_dbcnl_validate_ets(struct ieee_ets *ets)
 
 	/* Validate Bandwidth Sum */
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
-		if (ets->tc_tsa[i] == IEEE_8021QAZ_TSA_ETS)
+		if (ets->tc_tsa[i] == IEEE_8021QAZ_TSA_ETS) {
+			if (!ets->tc_tx_bw[i])
+				return -EINVAL;
+
 			bw_sum += ets->tc_tx_bw[i];
+		}
 	}
 
 	if (bw_sum != 0 && bw_sum != 100)
-- 
2.8.0
