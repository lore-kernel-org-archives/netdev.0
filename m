From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/6] net/mlx4_en: Fix set port ratelimit for 40GE
Date: Tue,  8 Jul 2014 11:25:19 +0300
Message-ID: <1404807924-29038-2-git-send-email-amirv@mellanox.com>
References: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Sagi Grimberg <sagig@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47656 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753212AbaGHI00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:26:26 -0400
In-Reply-To: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

In 40GE we can't use the default bw units for set ratelimit (100 Mbps)
since the max is 255*100 Mbps = 25 Gbps (not suited for 40GE), thus we need 1 Gbps units.
But for 10GE 1 Gbps units might be too bruit so we use the following solution.

For user set ratelimit <= 25 Gbps:
        use 100 Mbps units * user_ratelimit (* 10).

For user set ratelimit > 25 Gbps:
        use 1 Gbps units * user_ratelimit.

For user set unlimited ratelimit (0 Gbps):
        use 1 Gbps units * MAX_RATELIMIT_DEFAULT (57)

Note: any value > 58 will damage the FW ratelimit computation, so we allow
      a max and any higher value will be pulled down to 57.


Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  5 -----
 drivers/net/ethernet/mellanox/mlx4/port.c | 22 +++++++++++++++++-----
 include/linux/mlx4/device.h               | 11 +++++++++++
 3 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 1d8af73..13fbcd0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -62,11 +62,6 @@
 
 #define INIT_HCA_TPT_MW_ENABLE          (1 << 7)
 
-#define MLX4_NUM_UP		8
-#define MLX4_NUM_TC		8
-#define MLX4_RATELIMIT_UNITS 3 /* 100 Mbps */
-#define MLX4_RATELIMIT_DEFAULT 0xffff
-
 struct mlx4_set_port_prio2tc_context {
 	u8 prio2tc[4];
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 7ab9717..5d76a60 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -1051,14 +1051,26 @@ int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 
 	for (i = 0; i < MLX4_NUM_TC; i++) {
 		struct mlx4_port_scheduler_tc_cfg_be *tc = &context->tc[i];
-		u16 r = ratelimit && ratelimit[i] ? ratelimit[i] :
-			MLX4_RATELIMIT_DEFAULT;
+		u16 r;
+
+		if (ratelimit && ratelimit[i]) {
+			if (ratelimit[i] <= MLX4_MAX_100M_UNITS_VAL) {
+				r = ratelimit[i];
+				tc->max_bw_units =
+					htons(MLX4_RATELIMIT_100M_UNITS);
+			} else {
+				r = ratelimit[i]/10;
+				tc->max_bw_units =
+					htons(MLX4_RATELIMIT_1G_UNITS);
+			}
+			tc->max_bw_value = htons(r);
+		} else {
+			tc->max_bw_value = htons(MLX4_RATELIMIT_DEFAULT);
+			tc->max_bw_units = htons(MLX4_RATELIMIT_1G_UNITS);
+		}
 
 		tc->pg = htons(pg[i]);
 		tc->bw_precentage = htons(tc_tx_bw[i]);
-
-		tc->max_bw_units = htons(MLX4_RATELIMIT_UNITS);
-		tc->max_bw_value = htons(r);
 	}
 
 	in_mod = MLX4_SET_PORT_SCHEDULER << 8 | port;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b12f4bb..db0aef3 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -48,6 +48,17 @@
 #define MSIX_LEGACY_SZ		4
 #define MIN_MSIX_P_PORT		5
 
+#define MLX4_NUM_UP			8
+#define MLX4_NUM_TC			8
+#define MLX4_MAX_100M_UNITS_VAL		255	/*
+						 * work around: can't set values
+						 * greater then this value when
+						 * using 100 Mbps units.
+						 */
+#define MLX4_RATELIMIT_100M_UNITS	3	/* 100 Mbps */
+#define MLX4_RATELIMIT_1G_UNITS		4	/* 1 Gbps */
+#define MLX4_RATELIMIT_DEFAULT		0x00ff
+
 #define MLX4_ROCE_MAX_GIDS	128
 #define MLX4_ROCE_PF_GIDS	16
 
-- 
1.8.3.4
