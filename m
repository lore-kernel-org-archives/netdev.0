From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V7 3/8] net/mlx4_en: DCB QoS support
Date: Thu,  5 Apr 2012 10:33:26 +0300
Message-ID: <1333611211-1032-4-git-send-email-amirv@mellanox.com>
References: <1333611211-1032-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:41184 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753998Ab2DEHdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 03:33:45 -0400
In-Reply-To: <1333611211-1032-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set TSA, promised BW and PFC using IEEE 802.1qaz netlink commands.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Kconfig     |   12 ++
 drivers/net/ethernet/mellanox/mlx4/Makefile    |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |  209 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    5 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   21 +++
 5 files changed, 248 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 1bb9353..5f027f9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -11,6 +11,18 @@ config MLX4_EN
 	  This driver supports Mellanox Technologies ConnectX Ethernet
 	  devices.
 
+config MLX4_EN_DCB
+	bool "Data Center Bridging (DCB) Support"
+	default y
+	depends on MLX4_EN && DCB
+	---help---
+	  Say Y here if you want to use Data Center Bridging (DCB) in the
+	  driver.
+	  If set to N, will not be able to configure QoS and ratelimit attributes.
+	  This flag is depended on the kernel's DCB support.
+
+	  If unsure, set to Y
+
 config MLX4_CORE
 	tristate
 	depends on PCI
diff --git a/drivers/net/ethernet/mellanox/mlx4/Makefile b/drivers/net/ethernet/mellanox/mlx4/Makefile
index 4a40ab9..293127d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx4/Makefile
@@ -7,3 +7,4 @@ obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
 
 mlx4_en-y := 	en_main.o en_tx.o en_rx.o en_ethtool.o en_port.o en_cq.o \
 		en_resources.o en_netdev.o en_selftest.o
+mlx4_en-$(CONFIG_MLX4_EN_DCB) += en_dcb_nl.o
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
new file mode 100644
index 0000000..6892320
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -0,0 +1,209 @@
+/*
+ * Copyright (c) 2011 Mellanox Technologies. All rights reserved.
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
+#include <linux/dcbnl.h>
+
+#include "mlx4_en.h"
+
+static int mlx4_en_dcbnl_ieee_getets(struct net_device *dev,
+				   struct ieee_ets *ets)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct ieee_ets *my_ets = &priv->ets;
+
+	/* No IEEE PFC settings available */
+	if (!my_ets)
+		return -EINVAL;
+
+	ets->ets_cap = IEEE_8021QAZ_MAX_TCS;
+	ets->cbs = my_ets->cbs;
+	memcpy(ets->tc_tx_bw, my_ets->tc_tx_bw, sizeof(ets->tc_tx_bw));
+	memcpy(ets->tc_tsa, my_ets->tc_tsa, sizeof(ets->tc_tsa));
+	memcpy(ets->prio_tc, my_ets->prio_tc, sizeof(ets->prio_tc));
+
+	return 0;
+}
+
+static int mlx4_en_ets_validate(struct mlx4_en_priv *priv, struct ieee_ets *ets)
+{
+	int i;
+	int total_ets_bw = 0;
+	int has_ets_tc = 0;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		if (ets->prio_tc[i] > MLX4_EN_NUM_UP) {
+			en_err(priv, "Bad priority in UP <=> TC mapping. TC: %d, UP: %d\n",
+					i, ets->prio_tc[i]);
+			return -EINVAL;
+		}
+
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			has_ets_tc = 1;
+			total_ets_bw += ets->tc_tx_bw[i];
+			break;
+		default:
+			en_err(priv, "TC[%d]: Not supported TSA: %d\n",
+					i, ets->tc_tsa[i]);
+			return -ENOTSUPP;
+		}
+	}
+
+	if (has_ets_tc && total_ets_bw != MLX4_EN_BW_MAX) {
+		en_err(priv, "Bad ETS BW sum: %d. Should be exactly 100%%\n",
+				total_ets_bw);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int mlx4_en_config_port_scheduler(struct mlx4_en_priv *priv,
+		struct ieee_ets *ets, u16 *ratelimit)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int num_strict = 0;
+	int i;
+	__u8 tc_tx_bw[IEEE_8021QAZ_MAX_TCS] = { 0 };
+	__u8 pg[IEEE_8021QAZ_MAX_TCS] = { 0 };
+
+	ets = ets ?: &priv->ets;
+
+	/* higher TC means higher priority => lower pg */
+	for (i = IEEE_8021QAZ_MAX_TCS - 1; i >= 0; i--) {
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			pg[i] = num_strict++;
+			tc_tx_bw[i] = MLX4_EN_BW_MAX;
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			pg[i] = MLX4_EN_TC_ETS;
+			tc_tx_bw[i] = ets->tc_tx_bw[i] ?: MLX4_EN_BW_MIN;
+			break;
+		}
+	}
+
+	return mlx4_SET_PORT_SCHEDULER(mdev->dev, priv->port, tc_tx_bw, pg,
+			ratelimit);
+}
+
+static int
+mlx4_en_dcbnl_ieee_setets(struct net_device *dev, struct ieee_ets *ets)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int err;
+
+	err = mlx4_en_ets_validate(priv, ets);
+	if (err)
+		return err;
+
+	err = mlx4_SET_PORT_PRIO2TC(mdev->dev, priv->port, ets->prio_tc);
+	if (err)
+		return err;
+
+	err = mlx4_en_config_port_scheduler(priv, ets, NULL);
+	if (err)
+		return err;
+
+	memcpy(&priv->ets, ets, sizeof(priv->ets));
+
+	return 0;
+}
+
+static int mlx4_en_dcbnl_ieee_getpfc(struct net_device *dev,
+		struct ieee_pfc *pfc)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	pfc->pfc_cap = IEEE_8021QAZ_MAX_TCS;
+	pfc->pfc_en = priv->prof->tx_ppp;
+
+	return 0;
+}
+
+static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
+		struct ieee_pfc *pfc)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int err;
+
+	en_dbg(DRV, priv, "cap: 0x%x en: 0x%x mbc: 0x%x delay: %d\n",
+			pfc->pfc_cap,
+			pfc->pfc_en,
+			pfc->mbc,
+			pfc->delay);
+
+	priv->prof->rx_pause = priv->prof->tx_pause = !!pfc->pfc_en;
+	priv->prof->rx_ppp = priv->prof->tx_ppp = pfc->pfc_en;
+
+	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
+				    priv->rx_skb_size + ETH_FCS_LEN,
+				    priv->prof->tx_pause,
+				    priv->prof->tx_ppp,
+				    priv->prof->rx_pause,
+				    priv->prof->rx_ppp);
+	if (err)
+		en_err(priv, "Failed setting pause params\n");
+
+	return err;
+}
+
+static u8 mlx4_en_dcbnl_getdcbx(struct net_device *dev)
+{
+	return DCB_CAP_DCBX_VER_IEEE;
+}
+
+static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
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
+const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
+	.ieee_getets	= mlx4_en_dcbnl_ieee_getets,
+	.ieee_setets	= mlx4_en_dcbnl_ieee_setets,
+	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
+	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
+
+	.getdcbx	= mlx4_en_dcbnl_getdcbx,
+	.setdcbx	= mlx4_en_dcbnl_setdcbx,
+};
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2322622..107f005 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -967,6 +967,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	mutex_unlock(&mdev->state_lock);
 
 	mlx4_en_free_resources(priv);
+
 	free_netdev(dev);
 }
 
@@ -1080,6 +1081,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	INIT_WORK(&priv->watchdog_task, mlx4_en_restart);
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
 	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
+#ifdef CONFIG_MLX4_EN_DCB
+	if (!mlx4_is_slave(priv->mdev->dev))
+		dev->dcbnl_ops = &mlx4_en_dcbnl_ops;
+#endif
 
 	/* Query for default mac and max mtu */
 	priv->max_mtu = mdev->dev->caps.eth_mtu_cap[priv->port];
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 5bd7c2a..97d4f35 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -40,6 +40,9 @@
 #include <linux/mutex.h>
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
+#ifdef CONFIG_MLX4_EN_DCB
+#include <linux/dcbnl.h>
+#endif
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/qp.h>
@@ -110,6 +113,7 @@ enum {
 #define MLX4_EN_NUM_TX_RINGS		8
 #define MLX4_EN_NUM_PPP_RINGS		8
 #define MAX_TX_RINGS			(MLX4_EN_NUM_TX_RINGS + MLX4_EN_NUM_PPP_RINGS)
+#define MLX4_EN_NUM_UP			8
 #define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
 
@@ -410,6 +414,15 @@ struct mlx4_en_frag_info {
 
 };
 
+#ifdef CONFIG_MLX4_EN_DCB
+/* Minimal TC BW - setting to 0 will block traffic */
+#define MLX4_EN_BW_MIN 1
+#define MLX4_EN_BW_MAX 100 /* Utilize 100% of the line */
+
+#define MLX4_EN_TC_ETS 7
+
+#endif
+
 struct mlx4_en_priv {
 	struct mlx4_en_dev *mdev;
 	struct mlx4_en_port_profile *prof;
@@ -483,6 +496,10 @@ struct mlx4_en_priv {
 	int vids[128];
 	bool wol;
 	struct device *ddev;
+
+#ifdef CONFIG_MLX4_EN_DCB
+	struct ieee_ets ets;
+#endif
 };
 
 enum mlx4_en_wol {
@@ -557,6 +574,10 @@ int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
 int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 
+#ifdef CONFIG_MLX4_EN_DCB
+extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops;
+#endif
+
 #define MLX4_EN_NUM_SELF_TEST	5
 void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf);
 u64 mlx4_en_mac_to_u64(u8 *addr);
-- 
1.7.8.2
