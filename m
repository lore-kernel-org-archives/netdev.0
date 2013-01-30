From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 08/11] net/mlx4_core: Use firmware driven flow steering hash mode
Date: Wed, 30 Jan 2013 12:34:24 +0200
Message-ID: <1359542067-10760-9-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:56599 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754358Ab3A3Ket (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:49 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The Firmware dynamically changes flow steering hash configuration from covering
L2 only to "full" L2/L3/L4 mode needed.  The dynamic change allows the driver
to set hard coded hash configuration which is changed by the firmware from L2
to L2/L3/L4 when attaching the first L3/L4 flow steering rule and back to L2
when there are no more such rules.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    1 -
 drivers/net/ethernet/mellanox/mlx4/main.c |   16 ----------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    5 -----
 4 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 8b3d051..91acf71 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1287,14 +1287,14 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 		/* Enable Ethernet flow steering
 		 * with udp unicast and tcp unicast
 		 */
-		MLX4_PUT(inbox, param->fs_hash_enable_bits,
+		MLX4_PUT(inbox, (u8) (MLX4_FS_UDP_UC_EN | MLX4_FS_TCP_UC_EN),
 			 INIT_HCA_FS_ETH_BITS_OFFSET);
 		MLX4_PUT(inbox, (u16) MLX4_FS_NUM_OF_L2_ADDR,
 			 INIT_HCA_FS_ETH_NUM_ADDRS_OFFSET);
 		/* Enable IPoIB flow steering
 		 * with udp unicast and tcp unicast
 		 */
-		MLX4_PUT(inbox, param->fs_hash_enable_bits,
+		MLX4_PUT(inbox, (u8) (MLX4_FS_UDP_UC_EN | MLX4_FS_TCP_UC_EN),
 			 INIT_HCA_FS_IB_BITS_OFFSET);
 		MLX4_PUT(inbox, (u16) MLX4_FS_NUM_OF_L2_ADDR,
 			 INIT_HCA_FS_IB_NUM_ADDRS_OFFSET);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index dbf2f69..3af33ff 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -171,7 +171,6 @@ struct mlx4_init_hca_param {
 	u8  log_mpt_sz;
 	u8  log_uar_sz;
 	u8  uar_page_sz; /* log pg sz in 4k chunks */
-	u8  fs_hash_enable_bits;
 	u8  steering_mode; /* for QUERY_HCA */
 	u64 dev_cap_enabled;
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index f1ee52d..e38c6b2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1415,22 +1415,6 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		if (mlx4_is_master(dev))
 			mlx4_parav_master_pf_caps(dev);
 
-		priv->fs_hash_mode = MLX4_FS_L2_HASH;
-
-		switch (priv->fs_hash_mode) {
-		case MLX4_FS_L2_HASH:
-			init_hca.fs_hash_enable_bits = 0;
-			break;
-
-		case MLX4_FS_L2_L3_L4_HASH:
-			/* Enable flow steering with
-			 * udp unicast and tcp unicast
-			 */
-			init_hca.fs_hash_enable_bits =
-				MLX4_FS_UDP_UC_EN | MLX4_FS_TCP_UC_EN;
-			break;
-		}
-
 		profile = default_profile;
 		if (dev->caps.steering_mode ==
 		    MLX4_STEERING_MODE_DEVICE_MANAGED)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 3263848..172daaa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -60,11 +60,6 @@
 #define MLX4_FS_MGM_LOG_ENTRY_SIZE	7
 #define MLX4_FS_NUM_MCG			(1 << 17)
 
-enum {
-	MLX4_FS_L2_HASH = 0,
-	MLX4_FS_L2_L3_L4_HASH,
-};
-
 #define MLX4_NUM_UP		8
 #define MLX4_NUM_TC		8
 #define MLX4_RATELIMIT_UNITS 3 /* 100 Mbps */
-- 
1.7.8.2
