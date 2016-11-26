From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 07/10] net/mlx5e: Add support for ethtool self diagnostics test
Date: Sat, 26 Nov 2016 16:18:31 +0200
Message-ID: <1480169914-22347-8-git-send-email-saeedm@mellanox.com>
References: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41833 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751539AbcKZOTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 09:19:31 -0500
In-Reply-To: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

The self diagnostics test implementaion include the following features:
1. Link Test: Check that link is in up state.
2. Speed Test: Check that link was negotiated correctly.
3. Health Test: Check the device health.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   5 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   8 +-
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  | 126 +++++++++++++++++++++
 4 files changed, 139 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 0343725..9f43beb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -8,6 +8,6 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o
+		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 6c954cd..f7bb4a7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -167,6 +167,8 @@ struct mlx5e_umr_wqe {
 	struct mlx5_wqe_data_seg       data;
 };
 
+extern const char mlx5e_self_tests[][ETH_GSTRING_LEN];
+
 static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] = {
 	"rx_cqe_moder",
 };
@@ -754,6 +756,9 @@ int mlx5e_create_flow_steering(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_steering(struct mlx5e_priv *priv);
 void mlx5e_init_l2_addr(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_table(struct mlx5e_flow_table *ft);
+int mlx5e_self_test_num(struct mlx5e_priv *priv);
+void mlx5e_self_test(struct net_device *ndev, struct ethtool_test *etest,
+		     u64 *buf);
 int mlx5e_ethtool_get_flow(struct mlx5e_priv *priv, struct ethtool_rxnfc *info,
 			   int location);
 int mlx5e_ethtool_get_all_flows(struct mlx5e_priv *priv,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 9ea7b37..839c4e9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -180,6 +180,8 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 
 	case ETH_SS_PRIV_FLAGS:
 		return ARRAY_SIZE(mlx5e_priv_flags);
+	case ETH_SS_TEST:
+		return mlx5e_self_test_num(priv);
 	/* fallthrough */
 	default:
 		return -EOPNOTSUPP;
@@ -286,6 +288,9 @@ static void mlx5e_get_strings(struct net_device *dev,
 		break;
 
 	case ETH_SS_TEST:
+		for (i = 0; i < mlx5e_self_test_num(priv); i++)
+			strcpy(data + i * ETH_GSTRING_LEN,
+			       mlx5e_self_tests[i]);
 		break;
 
 	case ETH_SS_STATS:
@@ -1573,5 +1578,6 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_module_info   = mlx5e_get_module_info,
 	.get_module_eeprom = mlx5e_get_module_eeprom,
 	.get_priv_flags    = mlx5e_get_priv_flags,
-	.set_priv_flags    = mlx5e_set_priv_flags
+	.set_priv_flags    = mlx5e_set_priv_flags,
+	.self_test         = mlx5e_self_test,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
new file mode 100644
index 0000000..a25dfc5
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -0,0 +1,126 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies, Ltd.  All rights reserved.
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
+ */
+
+#include "en.h"
+
+enum {
+	MLX5E_ST_LINK_STATE,
+	MLX5E_ST_LINK_SPEED,
+	MLX5E_ST_HEALTH_INFO,
+	MLX5E_ST_NUM,
+};
+
+const char mlx5e_self_tests[MLX5E_ST_NUM][ETH_GSTRING_LEN] = {
+	"Link Test",
+	"Speed Test",
+	"Health Test",
+};
+
+int mlx5e_self_test_num(struct mlx5e_priv *priv)
+{
+	return ARRAY_SIZE(mlx5e_self_tests);
+}
+
+static int mlx5e_test_health_info(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_health *health = &priv->mdev->priv.health;
+
+	return health->sick ? 1 : 0;
+}
+
+static int mlx5e_test_link_state(struct mlx5e_priv *priv)
+{
+	u8 port_state;
+
+	if (!netif_carrier_ok(priv->netdev))
+		return 1;
+
+	port_state = mlx5_query_vport_state(priv->mdev, MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT, 0);
+	return port_state == VPORT_STATE_UP ? 0 : 1;
+}
+
+static int mlx5e_test_link_speed(struct mlx5e_priv *priv)
+{
+	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
+	u32 eth_proto_oper;
+	int i;
+
+	if (!netif_carrier_ok(priv->netdev))
+		return 1;
+
+	if (mlx5_query_port_ptys(priv->mdev, out, sizeof(out), MLX5_PTYS_EN, 1))
+		return 1;
+
+	eth_proto_oper = MLX5_GET(ptys_reg, out, eth_proto_oper);
+	for (i = 0; i < MLX5E_LINK_MODES_NUMBER; i++) {
+		if (eth_proto_oper & MLX5E_PROT_MASK(i))
+			return 0;
+	}
+	return 1;
+}
+
+int (*mlx5e_st_func[MLX5E_ST_NUM])(struct mlx5e_priv *) = {
+	mlx5e_test_link_state,
+	mlx5e_test_link_speed,
+	mlx5e_test_health_info,
+};
+
+void mlx5e_self_test(struct net_device *ndev, struct ethtool_test *etest,
+		     u64 *buf)
+{
+	struct mlx5e_priv *priv = netdev_priv(ndev);
+	int i;
+
+	memset(buf, 0, sizeof(u64) * MLX5E_ST_NUM);
+
+	mutex_lock(&priv->state_lock);
+	netdev_info(ndev, "Self test begin..\n");
+
+	for (i = 0; i < MLX5E_ST_NUM; i++) {
+		netdev_info(ndev, "\t[%d] %s start..\n",
+			    i, mlx5e_self_tests[i]);
+		buf[i] = mlx5e_st_func[i](priv);
+		netdev_info(ndev, "\t[%d] %s end: result(%lld)\n",
+			    i, mlx5e_self_tests[i], buf[i]);
+	}
+
+	mutex_unlock(&priv->state_lock);
+
+	for (i = 0; i < MLX5E_ST_NUM; i++) {
+		if (buf[i]) {
+			etest->flags |= ETH_TEST_FL_FAILED;
+			break;
+		}
+	}
+	netdev_info(ndev, "Self test out: status flags(0x%x)\n",
+		    etest->flags);
+}
-- 
2.7.4
