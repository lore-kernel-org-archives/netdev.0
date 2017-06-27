From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 16/16] net/mlx5e: IPSec, Add IPSec ethtool stats
Date: Tue, 27 Jun 2017 17:28:56 +0300
Message-ID: <20170627142856.9448-17-saeedm@mellanox.com>
References: <20170627142856.9448-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50693 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752317AbdF0Oai (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:30:38 -0400
In-Reply-To: <20170627142856.9448-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Add Innova IPSec SBU counters to the ethtool -S stats.
Add IPSec offload error counters to the ethtool -S stats.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Reviewed-by: Boris Pismenny <borisp@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +-
 .../ethernet/mellanox/mlx5/core/en_accel/ipsec.h   |  43 +++++++
 .../mellanox/mlx5/core/en_accel/ipsec_stats.c      | 133 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   4 +-
 5 files changed, 190 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_stats.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 23cb8ba91e6f..ca367445f864 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -20,4 +20,5 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib/ipoib.o ipoib/ethtool.o
 
-mlx5_core-$(CONFIG_MLX5_EN_IPSEC) += en_accel/ipsec.o en_accel/ipsec_rxtx.o
+mlx5_core-$(CONFIG_MLX5_EN_IPSEC) += en_accel/ipsec.o en_accel/ipsec_rxtx.o \
+		en_accel/ipsec_stats.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.h b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.h
index ffc90b3c6ac7..56e00baf16cc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.h
@@ -57,12 +57,30 @@ struct mlx5e_ipsec_sw_stats {
 	atomic64_t ipsec_tx_drop_metadata;
 };
 
+struct mlx5e_ipsec_stats {
+	u64 ipsec_dec_in_packets;
+	u64 ipsec_dec_out_packets;
+	u64 ipsec_dec_bypass_packets;
+	u64 ipsec_enc_in_packets;
+	u64 ipsec_enc_out_packets;
+	u64 ipsec_enc_bypass_packets;
+	u64 ipsec_dec_drop_packets;
+	u64 ipsec_dec_auth_fail_packets;
+	u64 ipsec_enc_drop_packets;
+	u64 ipsec_add_sa_success;
+	u64 ipsec_add_sa_fail;
+	u64 ipsec_del_sa_success;
+	u64 ipsec_del_sa_fail;
+	u64 ipsec_cmd_drop;
+};
+
 struct mlx5e_ipsec {
 	struct mlx5e_priv *en_priv;
 	DECLARE_HASHTABLE(sadb_rx, MLX5E_IPSEC_SADB_RX_BITS);
 	spinlock_t sadb_rx_lock; /* Protects sadb_rx and halloc */
 	struct ida halloc;
 	struct mlx5e_ipsec_sw_stats sw_stats;
+	struct mlx5e_ipsec_stats stats;
 };
 
 void mlx5e_ipsec_build_inverse_table(void);
@@ -70,6 +88,11 @@ int mlx5e_ipsec_init(struct mlx5e_priv *priv);
 void mlx5e_ipsec_cleanup(struct mlx5e_priv *priv);
 void mlx5e_ipsec_build_netdev(struct mlx5e_priv *priv);
 
+int mlx5e_ipsec_get_count(struct mlx5e_priv *priv);
+int mlx5e_ipsec_get_strings(struct mlx5e_priv *priv, uint8_t *data);
+void mlx5e_ipsec_update_stats(struct mlx5e_priv *priv);
+int mlx5e_ipsec_get_stats(struct mlx5e_priv *priv, u64 *data);
+
 struct xfrm_state *mlx5e_ipsec_sadb_rx_lookup(struct mlx5e_ipsec *dev,
 					      unsigned int handle);
 
@@ -92,6 +115,26 @@ static inline void mlx5e_ipsec_build_netdev(struct mlx5e_priv *priv)
 {
 }
 
+static inline int mlx5e_ipsec_get_count(struct mlx5e_priv *priv)
+{
+	return 0;
+}
+
+static inline int mlx5e_ipsec_get_strings(struct mlx5e_priv *priv,
+					  uint8_t *data)
+{
+	return 0;
+}
+
+static inline void mlx5e_ipsec_update_stats(struct mlx5e_priv *priv)
+{
+}
+
+static inline int mlx5e_ipsec_get_stats(struct mlx5e_priv *priv, u64 *data)
+{
+	return 0;
+}
+
 #endif
 
 #endif	/* __MLX5E_IPSEC_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_stats.c b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_stats.c
new file mode 100644
index 000000000000..6fea59223dc4
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_stats.c
@@ -0,0 +1,133 @@
+/*
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/ethtool.h>
+#include <net/sock.h>
+
+#include "en.h"
+#include "accel/ipsec.h"
+#include "fpga/sdk.h"
+#include "en_accel/ipsec.h"
+
+static const struct counter_desc mlx5e_ipsec_hw_stats_desc[] = {
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_dec_in_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_dec_out_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_dec_bypass_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_enc_in_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_enc_out_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_enc_bypass_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_dec_drop_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_dec_auth_fail_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_enc_drop_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_add_sa_success) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_add_sa_fail) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_del_sa_success) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_del_sa_fail) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_stats, ipsec_cmd_drop) },
+};
+
+static const struct counter_desc mlx5e_ipsec_sw_stats_desc[] = {
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_rx_drop_sp_alloc) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_rx_drop_sadb_miss) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_rx_drop_syndrome) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_tx_drop_bundle) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_tx_drop_no_state) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_tx_drop_not_ip) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_tx_drop_trailer) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_ipsec_sw_stats, ipsec_tx_drop_metadata) },
+};
+
+#define MLX5E_READ_CTR_ATOMIC64(ptr, dsc, i) \
+	atomic64_read((atomic64_t *)((char *)(ptr) + (dsc)[i].offset))
+
+#define NUM_IPSEC_HW_COUNTERS ARRAY_SIZE(mlx5e_ipsec_hw_stats_desc)
+#define NUM_IPSEC_SW_COUNTERS ARRAY_SIZE(mlx5e_ipsec_sw_stats_desc)
+
+#define NUM_IPSEC_COUNTERS (NUM_IPSEC_HW_COUNTERS + NUM_IPSEC_SW_COUNTERS)
+
+int mlx5e_ipsec_get_count(struct mlx5e_priv *priv)
+{
+	if (!priv->ipsec)
+		return 0;
+
+	return NUM_IPSEC_COUNTERS;
+}
+
+int mlx5e_ipsec_get_strings(struct mlx5e_priv *priv, uint8_t *data)
+{
+	unsigned int i, idx = 0;
+
+	if (!priv->ipsec)
+		return 0;
+
+	for (i = 0; i < NUM_IPSEC_HW_COUNTERS; i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		       mlx5e_ipsec_hw_stats_desc[i].format);
+
+	for (i = 0; i < NUM_IPSEC_SW_COUNTERS; i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		       mlx5e_ipsec_sw_stats_desc[i].format);
+
+	return NUM_IPSEC_COUNTERS;
+}
+
+void mlx5e_ipsec_update_stats(struct mlx5e_priv *priv)
+{
+	int ret;
+
+	if (!priv->ipsec)
+		return;
+
+	ret = mlx5_accel_ipsec_counters_read(priv->mdev, (u64 *)&priv->ipsec->stats,
+					     NUM_IPSEC_HW_COUNTERS);
+	if (ret)
+		memset(&priv->ipsec->stats, 0, sizeof(priv->ipsec->stats));
+}
+
+int mlx5e_ipsec_get_stats(struct mlx5e_priv *priv, u64 *data)
+{
+	int i, idx = 0;
+
+	if (!priv->ipsec)
+		return 0;
+
+	for (i = 0; i < NUM_IPSEC_HW_COUNTERS; i++)
+		data[idx++] = MLX5E_READ_CTR64_CPU(&priv->ipsec->stats,
+						   mlx5e_ipsec_hw_stats_desc, i);
+
+	for (i = 0; i < NUM_IPSEC_SW_COUNTERS; i++)
+		data[idx++] = MLX5E_READ_CTR_ATOMIC64(&priv->ipsec->sw_stats,
+						      mlx5e_ipsec_sw_stats_desc, i);
+
+	return NUM_IPSEC_COUNTERS;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 16b1e96a7050..917fade5f5d5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -31,6 +31,7 @@
  */
 
 #include "en.h"
+#include "en_accel/ipsec.h"
 
 void mlx5e_ethtool_get_drvinfo(struct mlx5e_priv *priv,
 			       struct ethtool_drvinfo *drvinfo)
@@ -186,7 +187,8 @@ int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset)
 		       MLX5E_NUM_SQ_STATS(priv) +
 		       MLX5E_NUM_PFC_COUNTERS(priv) +
 		       ARRAY_SIZE(mlx5e_pme_status_desc) +
-		       ARRAY_SIZE(mlx5e_pme_error_desc);
+		       ARRAY_SIZE(mlx5e_pme_error_desc) +
+		       mlx5e_ipsec_get_count(priv);
 
 	case ETH_SS_PRIV_FLAGS:
 		return ARRAY_SIZE(mlx5e_priv_flags);
@@ -275,6 +277,9 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_error_desc); i++)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN, mlx5e_pme_error_desc[i].format);
 
+	/* IPSec counters */
+	idx += mlx5e_ipsec_get_strings(priv, data + idx * ETH_GSTRING_LEN);
+
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
@@ -403,6 +408,9 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.error_counters,
 						   mlx5e_pme_error_desc, i);
 
+	/* IPSec counters */
+	idx += mlx5e_ipsec_get_stats(priv, data + idx);
+
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a037bd7edb46..a09b11f467a4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -331,8 +331,10 @@ static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
 
 void mlx5e_update_stats(struct mlx5e_priv *priv, bool full)
 {
-	if (full)
+	if (full) {
 		mlx5e_update_pcie_counters(priv);
+		mlx5e_ipsec_update_stats(priv);
+	}
 	mlx5e_update_pport_counters(priv, full);
 	mlx5e_update_vport_counters(priv);
 	mlx5e_update_q_counter(priv);
-- 
2.11.0
