From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Mon, 22 Feb 2016 18:17:26 +0200
Message-ID: <1456157854-12750-5-git-send-email-saeedm@mellanox.com>
References: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	John Fastabend <john.fastabend@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42353 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751569AbcBVQTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 11:19:09 -0500
In-Reply-To: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support the ndo_setup_tc callback and the needed methods
for multi TC/UP support, and removed the default_vlan_prio
from mlx5e_priv which is always 0, it was replaced with
hardcoded "0" in the new select queue method.

For that we now create MAX_NUM_TC num of TISs (one per prio)
on netdevice creation instead of priv->params.num_tc which
was always 1.

So far each channel had a single TXQ, Now each channel has a
TXQ per TC (Traffic Class).

Added en_dcbnl.c which implements the set/get DCBNL IEEE ETS,
set/get dcbx and registers the mlx5e dcbnl ops.

We still use the kernel's default TXQ selection method to select the
channel to transmit through but now we use our own method to select
the TXQ inside the channel based on VLAN priority.

In mlx5, as opposed to mlx4, tc group N gets lower priority than
tc group N+1.

CC: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Rana Shahout <ranas@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   12 ++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    3 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   15 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |  190 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  104 ++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |    8 +-
 6 files changed, 317 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index c503ea0..1cf722e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -19,3 +19,15 @@ config MLX5_CORE_EN
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
 	  Ethernet and Infiniband support in ConnectX-4 are currently mutually
 	  exclusive.
+
+config MLX5_CORE_EN_DCB
+	bool "Data Center Bridging (DCB) Support"
+	default y
+	depends on MLX5_CORE_EN && DCB
+	---help---
+	  Say Y here if you want to use Data Center Bridging (DCB) in the
+	  driver.
+	  If set to N, will not be able to configure QoS and ratelimit attributes.
+	  This flag is depended on the kernel's DCB support.
+
+	  If unsure, set to Y
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 01c0256..1a82e23 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -3,6 +3,9 @@ obj-$(CONFIG_MLX5_CORE)		+= mlx5_core.o
 mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o   \
 		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o
+
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
 		en_txrx.o en_clock.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 15f6cdb..dfbc4e5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -70,6 +70,11 @@
 
 #define MLX5E_NUM_MAIN_GROUPS 9
 
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+#define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
+#define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
+#endif
+
 static const char vport_strings[][ETH_GSTRING_LEN] = {
 	/* vport statistics */
 	"rx_packets",
@@ -273,7 +278,6 @@ struct mlx5e_params {
 	u8  log_sq_size;
 	u8  log_rq_size;
 	u16 num_channels;
-	u8  default_vlan_prio;
 	u8  num_tc;
 	u16 rx_cq_moderation_usec;
 	u16 rx_cq_moderation_pkts;
@@ -286,6 +290,9 @@ struct mlx5e_params {
 	u8  rss_hfunc;
 	u8  toeplitz_hash_key[40];
 	u32 indirection_rqt[MLX5E_INDIR_RQT_SIZE];
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+	struct ieee_ets ets;
+#endif
 };
 
 struct mlx5e_tstamp {
@@ -506,7 +513,6 @@ struct mlx5e_flow_tables {
 
 struct mlx5e_priv {
 	/* priv data path fields - start */
-	int                        default_vlan_prio;
 	struct mlx5e_sq            **txq_to_sq_map;
 	int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
 	/* priv data path fields - end */
@@ -666,4 +672,9 @@ static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
 }
 
 extern const struct ethtool_ops mlx5e_ethtool_ops;
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+extern const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops;
+int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets);
+#endif
+
 u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
new file mode 100644
index 0000000..4f097da
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -0,0 +1,190 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
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
+#include <linux/device.h>
+#include <linux/netdevice.h>
+#include "en.h"
+
+#define MLX5E_MAX_PRIORITY 8
+
+static int mlx5e_dcbnl_ieee_getets(struct net_device *netdev,
+				   struct ieee_ets *ets)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (!MLX5_CAP_GEN(priv->mdev, ets))
+		return -ENOTSUPP;
+
+	memcpy(ets, &priv->params.ets, sizeof(*ets));
+	return 0;
+}
+
+enum {
+	MLX5E_VENDOR_TC_GROUP_NUM = 7,
+	MLX5E_ETS_TC_GROUP_NUM    = 0,
+};
+
+static void mlx5e_build_tc_group(struct ieee_ets *ets, u8 *tc_group, int max_tc)
+{
+	bool any_tc_mapped_to_ets = false;
+	int strict_group;
+	int i;
+
+	for (i = 0; i <= max_tc; i++)
+		if (ets->tc_tsa[i] == IEEE_8021QAZ_TSA_ETS)
+			any_tc_mapped_to_ets = true;
+
+	strict_group = any_tc_mapped_to_ets ? 1 : 0;
+
+	for (i = 0; i <= max_tc; i++) {
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_VENDOR:
+			tc_group[i] = MLX5E_VENDOR_TC_GROUP_NUM;
+			break;
+		case IEEE_8021QAZ_TSA_STRICT:
+			tc_group[i] = strict_group++;
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			tc_group[i] = MLX5E_ETS_TC_GROUP_NUM;
+			break;
+		}
+	}
+}
+
+static void mlx5e_build_tc_tx_bw(struct ieee_ets *ets, u8 *tc_tx_bw,
+				 u8 *tc_group, int max_tc)
+{
+	int i;
+
+	for (i = 0; i <= max_tc; i++) {
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_VENDOR:
+			tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
+			break;
+		case IEEE_8021QAZ_TSA_STRICT:
+			tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			tc_tx_bw[i] = ets->tc_tx_bw[i] ?: MLX5E_MIN_BW_ALLOC;
+			break;
+		}
+	}
+}
+
+int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u8 tc_tx_bw[IEEE_8021QAZ_MAX_TCS];
+	u8 tc_group[IEEE_8021QAZ_MAX_TCS];
+	int max_tc = mlx5_max_tc(mdev);
+	int err;
+
+	if (!MLX5_CAP_GEN(mdev, ets))
+		return -ENOTSUPP;
+
+	mlx5e_build_tc_group(ets, tc_group, max_tc);
+	mlx5e_build_tc_tx_bw(ets, tc_tx_bw, tc_group, max_tc);
+
+	err = mlx5_set_port_prio_tc(mdev, ets->prio_tc);
+	if (err)
+		return err;
+
+	err = mlx5_set_port_tc_group(mdev, tc_group);
+	if (err)
+		return err;
+
+	return mlx5_set_port_tc_bw_alloc(mdev, tc_tx_bw);
+}
+
+static int mlx5e_dbcnl_validate_ets(struct ieee_ets *ets)
+{
+	int bw_sum = 0;
+	int i;
+
+	/* Validate Priority */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		if (ets->prio_tc[i] >= MLX5E_MAX_PRIORITY)
+			return -EINVAL;
+	}
+
+	/* Validate Bandwidth Sum */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		if (ets->tc_tsa[i] == IEEE_8021QAZ_TSA_ETS)
+			bw_sum += ets->tc_tx_bw[i];
+	}
+
+	if (bw_sum != 0 && bw_sum != 100)
+		return -EINVAL;
+	return 0;
+}
+
+static int mlx5e_dcbnl_ieee_setets(struct net_device *netdev,
+				   struct ieee_ets *ets)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err;
+
+	err = mlx5e_dbcnl_validate_ets(ets);
+	if (err)
+		return err;
+
+	err = mlx5e_dcbnl_ieee_setets_core(priv, ets);
+	if (err)
+		return err;
+
+	memcpy(&priv->params.ets, ets, sizeof(*ets));
+	priv->params.ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
+
+	return 0;
+}
+
+static u8 mlx5e_dcbnl_getdcbx(struct net_device *dev)
+{
+	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
+}
+
+static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
+{
+	if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
+	    (mode & DCB_CAP_DCBX_VER_CEE) ||
+	    !(mode & DCB_CAP_DCBX_VER_IEEE) ||
+	    !(mode & DCB_CAP_DCBX_HOST))
+		return 1;
+
+	return 0;
+}
+
+const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops = {
+	.ieee_getets	= mlx5e_dcbnl_ieee_getets,
+	.ieee_setets	= mlx5e_dcbnl_ieee_setets,
+	.getdcbx	= mlx5e_dcbnl_getdcbx,
+	.setdcbx	= mlx5e_dcbnl_setdcbx,
+};
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d4e1c30..704d75c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1400,6 +1400,24 @@ static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
 	return 0;
 }
 
+static void mlx5e_netdev_set_tcs(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int nch = priv->params.num_channels;
+	int ntc = priv->params.num_tc;
+	int tc;
+
+	netdev_reset_tc(netdev);
+
+	if (ntc == 1)
+		return;
+
+	netdev_set_num_tc(netdev, ntc);
+
+	for (tc = 0; tc < ntc; tc++)
+		netdev_set_tc_queue(netdev, tc, nch, tc * nch);
+}
+
 int mlx5e_open_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -1408,6 +1426,8 @@ int mlx5e_open_locked(struct net_device *netdev)
 
 	set_bit(MLX5E_STATE_OPENED, &priv->state);
 
+	mlx5e_netdev_set_tcs(netdev);
+
 	num_txqs = priv->params.num_channels * priv->params.num_tc;
 	netif_set_real_num_tx_queues(netdev, num_txqs);
 	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
@@ -1602,7 +1622,7 @@ static int mlx5e_create_tis(struct mlx5e_priv *priv, int tc)
 
 	memset(in, 0, sizeof(in));
 
-	MLX5_SET(tisc, tisc, prio,  tc);
+	MLX5_SET(tisc, tisc, prio, tc << 1);
 	MLX5_SET(tisc, tisc, transport_domain, priv->tdn);
 
 	return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
@@ -1618,7 +1638,7 @@ static int mlx5e_create_tises(struct mlx5e_priv *priv)
 	int err;
 	int tc;
 
-	for (tc = 0; tc < priv->params.num_tc; tc++) {
+	for (tc = 0; tc < MLX5E_MAX_NUM_TC; tc++) {
 		err = mlx5e_create_tis(priv, tc);
 		if (err)
 			goto err_close_tises;
@@ -1637,7 +1657,7 @@ static void mlx5e_destroy_tises(struct mlx5e_priv *priv)
 {
 	int tc;
 
-	for (tc = 0; tc < priv->params.num_tc; tc++)
+	for (tc = 0; tc < MLX5E_MAX_NUM_TC; tc++)
 		mlx5e_destroy_tis(priv, tc);
 }
 
@@ -1824,6 +1844,40 @@ static void mlx5e_destroy_tirs(struct mlx5e_priv *priv)
 		mlx5e_destroy_tir(priv, i);
 }
 
+static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	bool was_opened;
+	int err = 0;
+
+	if (tc && tc != MLX5E_MAX_NUM_TC)
+		return -EINVAL;
+
+	mutex_lock(&priv->state_lock);
+
+	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	if (was_opened)
+		mlx5e_close_locked(priv->netdev);
+
+	priv->params.num_tc = tc ? tc : 1;
+
+	if (was_opened)
+		err = mlx5e_open_locked(priv->netdev);
+
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
+static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
+			      __be16 proto, struct tc_to_netdev *tc)
+{
+	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+		return -EINVAL;
+
+	return mlx5e_setup_tc(dev, tc->tc);
+}
+
 static struct rtnl_link_stats64 *
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
@@ -2028,6 +2082,8 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
+	.ndo_setup_tc            = mlx5e_ndo_setup_tc,
+	.ndo_select_queue        = mlx5e_select_queue,
 	.ndo_get_stats64         = mlx5e_get_stats,
 	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
 	.ndo_set_mac_address     = mlx5e_set_mac,
@@ -2042,6 +2098,8 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
+	.ndo_setup_tc            = mlx5e_ndo_setup_tc,
+	.ndo_select_queue        = mlx5e_select_queue,
 	.ndo_get_stats64         = mlx5e_get_stats,
 	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
 	.ndo_set_mac_address     = mlx5e_set_mac,
@@ -2089,6 +2147,24 @@ u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
 	       2 /*sizeof(mlx5e_tx_wqe.inline_hdr_start)*/;
 }
 
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+static void mlx5e_ets_init(struct mlx5e_priv *priv)
+{
+	int i;
+
+	priv->params.ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
+	for (i = 0; i < priv->params.ets.ets_cap; i++) {
+		priv->params.ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
+		priv->params.ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
+		priv->params.ets.prio_tc[i] = i;
+	}
+
+	/* tclass[prio=0]=1, tclass[prio=1]=0, tclass[prio=i]=i (for i>1) */
+	priv->params.ets.prio_tc[0] = 1;
+	priv->params.ets.prio_tc[1] = 0;
+}
+#endif
+
 static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    struct net_device *netdev,
 				    int num_channels)
@@ -2112,7 +2188,6 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.min_rx_wqes           =
 		MLX5E_PARAMS_DEFAULT_MIN_RX_WQES;
 	priv->params.num_tc                = 1;
-	priv->params.default_vlan_prio     = 0;
 	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
 
 	netdev_rss_key_fill(priv->params.toeplitz_hash_key,
@@ -2127,7 +2202,10 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->mdev                         = mdev;
 	priv->netdev                       = netdev;
 	priv->params.num_channels          = num_channels;
-	priv->default_vlan_prio            = priv->params.default_vlan_prio;
+
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+	mlx5e_ets_init(priv);
+#endif
 
 	spin_lock_init(&priv->async_events_spinlock);
 	mutex_init(&priv->state_lock);
@@ -2156,10 +2234,14 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 
 	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
 		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
-	else
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+		netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
+#endif
+	} else {
 		netdev->netdev_ops = &mlx5e_netdev_ops_basic;
+	}
 
 	netdev->watchdog_timeo    = 15 * HZ;
 
@@ -2228,7 +2310,9 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	if (mlx5e_check_required_hca_cap(mdev))
 		return NULL;
 
-	netdev = alloc_etherdev_mqs(sizeof(struct mlx5e_priv), nch, nch);
+	netdev = alloc_etherdev_mqs(sizeof(struct mlx5e_priv),
+				    nch * MLX5E_MAX_NUM_TC,
+				    nch);
 	if (!netdev) {
 		mlx5_core_err(mdev, "alloc_etherdev_mqs() failed\n");
 		return NULL;
@@ -2303,6 +2387,10 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	mlx5e_init_eth_addr(priv);
 
+#ifdef CONFIG_MLX5_CORE_EN_DCB
+	mlx5e_dcbnl_ieee_setets_core(priv, &priv->params.ets);
+#endif
+
 	err = register_netdev(netdev);
 	if (err) {
 		mlx5_core_err(mdev, "register_netdev failed, %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 2c3fba0..00d855a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -109,12 +109,10 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	int channel_ix = fallback(dev, skb);
-	int up = skb_vlan_tag_present(skb)        ?
-		 skb->vlan_tci >> VLAN_PRIO_SHIFT :
-		 priv->default_vlan_prio;
-	int tc = netdev_get_prio_tc_map(dev, up);
+	int up = (netdev_get_num_tc(dev) && skb_vlan_tag_present(skb)) ?
+		 skb->vlan_tci >> VLAN_PRIO_SHIFT : 0;
 
-	return priv->channeltc_to_txq_map[channel_ix][tc];
+	return priv->channeltc_to_txq_map[channel_ix][up];
 }
 
 static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
-- 
1.7.1
