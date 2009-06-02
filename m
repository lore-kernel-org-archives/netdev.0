From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/8] mlx4_en: Moved all module parameters handling to en_main.c
Date: Tue, 02 Jun 2009 12:20:18 +0300
Message-ID: <4A24EED2.9080005@mellanox.co.il>
References: <4A0AB34A.10100@mellanox.co.il><4A1948D7.8010504@mellanox.co.il><4A1A57AA.1080209@mellanox.co.il> <20090525.014435.203274473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:44494 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759393AbZFBI3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:29:37 -0400
In-Reply-To: <20090525.014435.203274473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

en_params.c file now only handles Ethtool functionality

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c   |   54 +++++++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/en_params.c |   58 ------------------------------------------
 drivers/net/mlx4/mlx4_en.h   |    2 -
 3 files changed, 54 insertions(+), 60 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 510633f..23955d8 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -51,6 +51,60 @@ static const char mlx4_en_version[] =
 	DRV_NAME ": Mellanox ConnectX HCA Ethernet driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
 
+#define MLX4_EN_PARM_INT(X, def_val, desc) \
+	static unsigned int X = def_val;\
+	module_param(X , uint, 0444); \
+	MODULE_PARM_DESC(X, desc);
+
+
+/*
+ * Device scope module parameters
+ */
+
+
+/* Use a XOR rathern than Toeplitz hash function for RSS */
+MLX4_EN_PARM_INT(rss_xor, 0, "Use XOR hash function for RSS");
+
+/* RSS hash type mask - default to <saddr, daddr, sport, dport> */
+MLX4_EN_PARM_INT(rss_mask, 0xf, "RSS hash type bitmask");
+
+/* Number of LRO sessions per Rx ring (rounded up to a power of two) */
+MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
+		 "Number of LRO sessions per ring or disabled (0)");
+
+/* Priority pausing */
+MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
+			   " Per priority bit mask");
+MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
+			   " Per priority bit mask");
+
+static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
+{
+	struct mlx4_en_profile *params = &mdev->profile;
+	int i;
+
+	params->rss_xor = (rss_xor != 0);
+	params->rss_mask = rss_mask & 0x1f;
+	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
+	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
+		params->prof[i].rx_pause = 1;
+		params->prof[i].rx_ppp = pfcrx;
+		params->prof[i].tx_pause = 1;
+		params->prof[i].tx_ppp = pfctx;
+		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
+		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
+	}
+	if (pfcrx || pfctx) {
+		params->prof[1].tx_ring_num = MLX4_EN_TX_RING_NUM;
+		params->prof[2].tx_ring_num = MLX4_EN_TX_RING_NUM;
+	} else {
+		params->prof[1].tx_ring_num = 1;
+		params->prof[2].tx_ring_num = 1;
+	}
+
+	return 0;
+}
+
 static void mlx4_en_event(struct mlx4_dev *dev, void *endev_ptr,
 			  enum mlx4_dev_event event, int port)
 {
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index 3290fec..91d8116 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -38,64 +38,6 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
-#define MLX4_EN_PARM_INT(X, def_val, desc) \
-	static unsigned int X = def_val;\
-	module_param(X , uint, 0444); \
-	MODULE_PARM_DESC(X, desc);
-
-
-/*
- * Device scope module parameters
- */
-
-
-/* Use a XOR rathern than Toeplitz hash function for RSS */
-MLX4_EN_PARM_INT(rss_xor, 0, "Use XOR hash function for RSS");
-
-/* RSS hash type mask - default to <saddr, daddr, sport, dport> */
-MLX4_EN_PARM_INT(rss_mask, 0xf, "RSS hash type bitmask");
-
-/* Number of LRO sessions per Rx ring (rounded up to a power of two) */
-MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
-		 "Number of LRO sessions per ring or disabled (0)");
-
-/* Priority pausing */
-MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
-			   " Per priority bit mask");
-MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
-			   " Per priority bit mask");
-
-int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
-{
-	struct mlx4_en_profile *params = &mdev->profile;
-	int i;
-
-	params->rss_xor = (rss_xor != 0);
-	params->rss_mask = rss_mask & 0x1f;
-	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
-	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
-		params->prof[i].rx_pause = 1;
-		params->prof[i].rx_ppp = pfcrx;
-		params->prof[i].tx_pause = 1;
-		params->prof[i].tx_ppp = pfctx;
-		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
-		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
-	}
-	if (pfcrx || pfctx) {
-		params->prof[1].tx_ring_num = MLX4_EN_TX_RING_NUM;
-		params->prof[2].tx_ring_num = MLX4_EN_TX_RING_NUM;
-	} else {
-		params->prof[1].tx_ring_num = 1;
-		params->prof[2].tx_ring_num = 1;
-	}
-
-	return 0;
-}
-
-
-/*
- * Ethtool support
- */
 
 static void mlx4_en_update_lro_stats(struct mlx4_en_priv *priv)
 {
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index c92b382..174ae86 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -516,8 +516,6 @@ void mlx4_en_stop_port(struct net_device *dev);
 void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
 
-int mlx4_en_get_profile(struct mlx4_en_dev *mdev);
-
 int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		      int entries, int ring, enum cq_type mode);
 void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
-- 
1.6.0


