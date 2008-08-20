From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [Patch RFC 04/10 v2] mlx4_en: en_params
Date: Wed, 20 Aug 2008 16:00:28 +0300
Message-ID: <48AC156C.30907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49070 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754156AbYHTNBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 09:01:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 18 Aug 2008 11:34:00 +0300
Subject: [PATCH] mlx4_en: en_params

This file is responsible for parsing and validating module
parameters. It also implements the Ethtool interface.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_params.c |  603 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 603 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mlx4/en_params.c

diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
new file mode 100644
index 0000000..e6b3878
--- /dev/null
+++ b/drivers/net/mlx4/en_params.c
@@ -0,0 +1,603 @@
+/*
+ * Copyright (c) 2007 Mellanox Technologies. All rights reserved.
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
+#include <linux/kernel.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+
+#include "mlx4_en.h"
+#include "en_port.h"
+
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
+MLX4_EN_PARM_INT(pptx, MLX4_EN_DEF_TX_PAUSE,
+		 "Pause policy on TX: 0 never generate pause frames "
+		 "1 generate pause frames according to RX buffer threshold");
+MLX4_EN_PARM_INT(pprx, MLX4_EN_DEF_RX_PAUSE,
+		 "Pause policy on RX: 0 ignore received pause frames "
+		 "1 respect received pause frames");
+MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
+			   " Per priority bit mask");
+MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
+			   " Per priority bit mask");
+
+/* Interrupt moderation tunning */
+MLX4_EN_PARM_INT(rx_moder_cnt, MLX4_EN_AUTO_CONF,
+	       "Max coalesced descriptors for Rx interrupt moderation");
+MLX4_EN_PARM_INT(rx_moder_time, MLX4_EN_AUTO_CONF,
+	       "Timeout following last packet for Rx interrupt moderation");
+MLX4_EN_PARM_INT(auto_moder, 1, "Enable dynamic interrupt moderation");
+
+MLX4_EN_PARM_INT(rx_ring_num1, 0, "Number or Rx rings for port 1 (0 = #cores)");
+MLX4_EN_PARM_INT(rx_ring_num2, 0, "Number or Rx rings for port 2 (0 = #cores)");
+
+MLX4_EN_PARM_INT(tx_ring_size1, MLX4_EN_AUTO_CONF, "Tx ring size for port 1");
+MLX4_EN_PARM_INT(tx_ring_size2, MLX4_EN_AUTO_CONF, "Tx ring size for port 2");
+MLX4_EN_PARM_INT(rx_ring_size1, MLX4_EN_AUTO_CONF, "Rx ring size for port 1");
+MLX4_EN_PARM_INT(rx_ring_size2, MLX4_EN_AUTO_CONF, "Rx ring size for port 2");
+
+
+int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
+{
+	struct mlx4_en_profile *params = &mdev->profile;
+
+	params->rx_moder_cnt = min_t(int, rx_moder_cnt, MLX4_EN_AUTO_CONF);
+	params->rx_moder_time = min_t(int, rx_moder_time, MLX4_EN_AUTO_CONF);
+	params->auto_moder = auto_moder;
+	params->rss_xor = (rss_xor != 0);
+	params->rss_mask = rss_mask & 0x1f;
+	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
+	params->rx_pause = pprx;
+	params->rx_ppp = pfcrx;
+	params->tx_pause = pptx;
+	params->tx_ppp = pfctx;
+	if (params->rx_ppp || params->tx_ppp) {
+		params->prof[1].tx_ring_num = MLX4_EN_TX_RING_NUM;
+		params->prof[2].tx_ring_num = MLX4_EN_TX_RING_NUM;
+	} else {
+		params->prof[1].tx_ring_num = 1;
+		params->prof[2].tx_ring_num = 1;
+	}
+	params->prof[1].rx_ring_num = min_t(int, rx_ring_num1, MAX_RX_RINGS);
+	params->prof[2].rx_ring_num = min_t(int, rx_ring_num2, MAX_RX_RINGS);
+	if (tx_ring_size1 == MLX4_EN_AUTO_CONF) {
+		tx_ring_size1 = (BITS_PER_LONG == 64) ?
+			MLX4_EN_DEF_TX_RING_SIZE : MLX4_EN_DEF_TX_RING_SIZE_32;
+	}
+	params->prof[1].tx_ring_size = roundup_pow_of_two(tx_ring_size1);
+	if (tx_ring_size2 == MLX4_EN_AUTO_CONF) {
+		tx_ring_size2 = (BITS_PER_LONG == 64) ?
+			MLX4_EN_DEF_TX_RING_SIZE : MLX4_EN_DEF_TX_RING_SIZE_32;
+	}
+	params->prof[2].tx_ring_size = roundup_pow_of_two(tx_ring_size2);
+	if (rx_ring_size1 == MLX4_EN_AUTO_CONF) {
+		rx_ring_size1 = (BITS_PER_LONG == 64) ?
+			MLX4_EN_DEF_TX_RING_SIZE : MLX4_EN_DEF_TX_RING_SIZE_32;
+	}
+	params->prof[1].rx_ring_size = (rx_ring_size1 < MLX4_EN_MIN_RX_SIZE) ?
+		MLX4_EN_MIN_RX_SIZE : roundup_pow_of_two(rx_ring_size1);
+	if (rx_ring_size2 == MLX4_EN_AUTO_CONF) {
+		rx_ring_size2 = (BITS_PER_LONG == 64) ?
+			MLX4_EN_DEF_TX_RING_SIZE : MLX4_EN_DEF_TX_RING_SIZE_32;
+	}
+	params->prof[2].rx_ring_size = (rx_ring_size2 < MLX4_EN_MIN_RX_SIZE) ?
+		MLX4_EN_MIN_RX_SIZE : roundup_pow_of_two(rx_ring_size2);
+
+	return 0;
+}
+
+
+/*
+ * Ethtool support
+ */
+
+static void
+mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+
+	sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
+	strncpy(drvinfo->version, DRV_VERSION " (" DRV_RELDATE ")", 32);
+	sprintf(drvinfo->fw_version, "%d.%d.%d",
+		(u16) (mdev->dev->caps.fw_ver >> 32),
+		(u16) ((mdev->dev->caps.fw_ver >> 16) & 0xffff),
+		(u16) (mdev->dev->caps.fw_ver & 0xffff));
+	strncpy(drvinfo->bus_info, pci_name(mdev->dev->pdev), 32);
+	drvinfo->n_stats = 0;
+	drvinfo->regdump_len = 0;
+	drvinfo->eedump_len = 0;
+}
+
+static u32 mlx4_en_get_tso(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_TSO) != 0;
+}
+
+static int mlx4_en_set_tso(struct net_device *dev, u32 data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	if (data) {
+		if (!priv->mdev->LSO_support)
+			return -EPERM;
+		dev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	} else
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+	return 0;
+}
+
+static u32 mlx4_en_get_rx_csum(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	return priv->rx_csum;
+}
+
+static int mlx4_en_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	priv->rx_csum = (data != 0);
+	return 0;
+}
+
+static char perf_strings[NUM_PERF_COUNTERS][ETH_GSTRING_LEN] = {
+	"tso",
+	"tx_pktsz_avg",
+	"inflight_avg",
+	"rx_coal_avg",
+	"tx_coal_avg",
+	"tx_poll",
+	"lro_size_avg",
+	"lro_flushes",
+	"lro_misses",
+	"napi_quota",
+	"rx_chksum_none",
+	"rx_alloc_failed"
+};
+
+static char port_strings[NUM_PORT_STATS][ETH_GSTRING_LEN] = {
+	"rst_cnt",
+	"lro_session_ovfl",
+	"queue_stopped"
+};
+
+#define NUM_HW_STATS		378
+#define NUM_HW_STATS_RES	22
+#define NUM_HW_STATS32		9
+#define NUM_HW_STATS64		(NUM_HW_STATS - NUM_HW_STATS32)
+
+static char hw_strings[NUM_HW_STATS][ETH_GSTRING_LEN] = {
+	"#R64_prio_0", "#R64_prio_1", "#R64_prio_2", "#R64_prio_3",
+	"#R64_prio_4", "#R64_prio_5", "#R64_prio_6", "#R64_prio_7",
+	"#R64_novlan",
+	"#R127_prio_0", "#R127_prio_1", "#R127_prio_2", "#R127_prio_3",
+	"#R127_prio_4", "#R127_prio_5", "#R127_prio_6", "#R127_prio_7",
+	"#R127_novlan",
+	"#R255_prio_0", "#R255_prio_1", "#R255_prio_2", "#R255_prio_3",
+	"#R255_prio_4", "#R255_prio_5", "#R255_prio_6", "#R255_prio_7",
+	"#R255_novlan",
+	"#R511_prio_0", "#R511_prio_1", "#R511_prio_2", "#R511_prio_3",
+	"#R511_prio_4", "#R511_prio_5", "#R511_prio_6", "#R511_prio_7",
+	"#R511_novlan",
+	"#R1023_prio_0", "#R1023_prio_1", "#R1023_prio_2", "#R1023_prio_3",
+	"#R1023_prio_4", "#R1023_prio_5", "#R1023_prio_6", "#R1023_prio_7",
+	"#R1023_novlan",
+	"#R1518_prio_0", "#R1518_prio_1", "#R1518_prio_2", "#R1518_prio_3",
+	"#R1518_prio_4", "#R1518_prio_5", "#R1518_prio_6", "#R1518_prio_7",
+	"#R1518_novlan",
+	"#R1522_prio_0", "#R1522_prio_1", "#R1522_prio_2", "#R1522_prio_3",
+	"#R1522_prio_4", "#R1522_prio_5", "#R1522_prio_6", "#R1522_prio_7",
+	"#R1522_novlan",
+	"#R1548_prio_0", "#R1548_prio_1", "#R1548_prio_2", "#R1548_prio_3",
+	"#R1548_prio_4", "#R1548_prio_5", "#R1548_prio_6", "#R1548_prio_7",
+	"#R1548_novlan",
+	"#R2MTU_prio_0", "#R2MTU_prio_1", "#R2MTU_prio_2", "#R2MTU_prio_3",
+	"#R2MTU_prio_4", "#R2MTU_prio_5", "#R2MTU_prio_6", "#R2MTU_prio_7",
+	"#R2MTU_novlan",
+	"#RGIANT_prio_0", "#RGIANT_prio_1", "#RGIANT_prio_2", "#RGIANT_prio_3",
+	"#RGIANT_prio_4", "#RGIANT_prio_5", "#RGIANT_prio_6", "#RGIANT_prio_7",
+	"#RGIANT_novlan",
+	"#RBCAST_prio_0", "#RBCAST_prio_1", "#RBCAST_prio_2", "#RBCAST_prio_3",
+	"#RBCAST_prio_4", "#RBCAST_prio_5", "#RBCAST_prio_6", "#RBCAST_prio_7",
+	"#RBCAST_novlan",
+	"#MCAST_prio_0", "#MCAST_prio_1", "#MCAST_prio_2", "#MCAST_prio_3",
+	"#MCAST_prio_4", "#MCAST_prio_5", "#MCAST_prio_6", "#MCAST_prio_7",
+	"#MCAST_novlan",
+	"#RTOTG_prio_0", "#RTOTG_prio_1", "#RTOTG_prio_2", "#RTOTG_prio_3",
+	"#RTOTG_prio_4", "#RTOTG_prio_5", "#RTOTG_prio_6", "#RTOTG_prio_7",
+	"#RTOTG_novlan",
+	"#RTTLOCT_prio_0", "#RTTLOCT_NOFRM_prio_0", "#ROCT_prio_0",
+	"#RTTLOCT_prio_1", "#RTTLOCT_NOFRM_prio_1", "#ROCT_prio_1",
+	"#RTTLOCT_prio_2", "#RTTLOCT_NOFRM_prio_2", "#ROCT_prio_2",
+	"#RTTLOCT_prio_3", "#RTTLOCT_NOFRM_prio_3", "#ROCT_prio_3",
+	"#RTTLOCT_prio_4", "#RTTLOCT_NOFRM_prio_4", "#ROCT_prio_4",
+	"#RTTLOCT_prio_5", "#RTTLOCT_NOFRM_prio_5", "#ROCT_prio_5",
+	"#RTTLOCT_prio_6", "#RTTLOCT_NOFRM_prio_6", "#ROCT_prio_6",
+	"#RTTLOCT_prio_7", "#RTTLOCT_NOFRM_prio_7", "#ROCT_prio_7",
+	"#RTTLOCT_novlan", "#RTTLOCT_NOFRM_novlan", "#ROCT_novlan",
+	"#RTOT_prio_0", "#R1Q_prio_0", "reserved",
+	"#RTOT_prio_1", "#R1Q_prio_1", "reserved",
+	"#RTOT_prio_2", "#R1Q_prio_2", "reserved",
+	"#RTOT_prio_3", "#R1Q_prio_3", "reserved",
+	"#RTOT_prio_4", "#R1Q_prio_4", "reserved",
+	"#RTOT_prio_5", "#R1Q_prio_5", "reserved",
+	"#RTOT_prio_6", "#R1Q_prio_6", "reserved",
+	"#RTOT_prio_7", "#R1Q_prio_7", "reserved",
+	"#RTOT_novlan", "#R1Q_novlan", "reserved",
+	"#RCNTL", "reserved", "reserved", "reserved",
+	"#RInRangeLengthErr", "#ROutRangeLengthErr", "#RFrmTooLong",
+	"#PCS",
+	"#T64_prio_0", "#T64_prio_1", "#T64_prio_2", "#T64_prio_3",
+	"#T64_prio_4", "#T64_prio_5", "#T64_prio_6", "#T64_prio_7",
+	"#T64_novlan", "#T64_loopbk",
+	"#T127_prio_0", "#T127_prio_1", "#T127_prio_2", "#T127_prio_3",
+	"#T127_prio_4", "#T127_prio_5", "#T127_prio_6", "#T127_prio_7",
+	"#T127_novlan", "#T127_loopbk",
+	"#T255_prio_0", "#T255_prio_1", "#T255_prio_2", "#T255_prio_3",
+	"#T255_prio_4", "#T255_prio_5", "#T255_prio_6", "#T255_prio_7",
+	"#T255_novlan", "#T255_loopbk",
+	"#T511_prio_0", "#T511_prio_1", "#T511_prio_2", "#T511_prio_3",
+	"#T511_prio_4", "#T511_prio_5", "#T511_prio_6", "#T511_prio_7",
+	"#T511_novlan", "#T511_loopbk",
+	"#T1023_prio_0", "#T1023_prio_1", "#T1023_prio_2", "#T1023_prio_3",
+	"#T1023_prio_4", "#T1023_prio_5", "#T1023_prio_6", "#T1023_prio_7",
+	"#T1023_novlan", "#T1023_loopbk",
+	"#T1518_prio_0", "#T1518_prio_1", "#T1518_prio_2", "#T1518_prio_3",
+	"#T1518_prio_4", "#T1518_prio_5", "#T1518_prio_6", "#T1518_prio_7",
+	"#T1518_novlan", "#T1518_loopbk",
+	"#T1522_prio_0", "#T1522_prio_1", "#T1522_prio_2", "#T1522_prio_3",
+	"#T1522_prio_4", "#T1522_prio_5", "#T1522_prio_6", "#T1522_prio_7",
+	"#T1522_novlan", "#T1522_loopbk",
+	"#T1548_prio_0", "#T1548_prio_1", "#T1548_prio_2", "#T1548_prio_3",
+	"#T1548_prio_4", "#T1548_prio_5", "#T1548_prio_6", "#T1548_prio_7",
+	"#T1548_novlan", "#T1548_loopbk",
+	"#T2MTU_prio_0", "#T2MTU_prio_1", "#T2MTU_prio_2", "#T2MTU_prio_3",
+	"#T2MTU_prio_4", "#T2MTU_prio_5", "#T2MTU_prio_6", "#T2MTU_prio_7",
+	"#T2MTU_novlan", "#T2MTU_loopbk",
+	"#TGIANT_prio_0", "#TGIANT_prio_1", "#TGIANT_prio_2", "#TGIANT_prio_3",
+	"#TGIANT_prio_4", "#TGIANT_prio_5", "#TGIANT_prio_6", "#TGIANT_prio_7",
+	"#TGIANT_novlan", "#TGIANT_loopbk",
+	"#TBCAST_prio_0", "#TBCAST_prio_1", "#TBCAST_prio_2", "#TBCAST_prio_3",
+	"#TBCAST_prio_4", "#TBCAST_prio_5", "#TBCAST_prio_6", "#TBCAST_prio_7",
+	"#TBCAST_novlan", "#TBCAST_loopbk",
+	"#TMCAST_prio_0", "#TMCAST_prio_1", "#TMCAST_prio_2", "#TMCAST_prio_3",
+	"#TMCAST_prio_4", "#TMCAST_prio_5", "#TMCAST_prio_6", "#TMCAST_prio_7",
+	"#TMCAST_novlan", "#TMCAST_loopbk",
+	"#TTOTG_prio_0", "#TTOTG_prio_1", "#TTOTG_prio_2", "#TTOTG_prio_3",
+	"#TTOTG_prio_4", "#TTOTG_prio_5", "#TTOTG_prio_6", "#TTOTG_prio_7",
+	"#TTOTG_novlan", "#TTOTG_loopbk",
+	"#TTTLOCT_prio_0", "#TTTLOCT_NOFRM_prio_0", "#TOCT_prio_0",
+	"#TTTLOCT_prio_1", "#TTTLOCT_NOFRM_prio_1", "#TOCT_prio_1",
+	"#TTTLOCT_prio_2", "#TTTLOCT_NOFRM_prio_2", "#TOCT_prio_2",
+	"#TTTLOCT_prio_3", "#TTTLOCT_NOFRM_prio_3", "#TOCT_prio_3",
+	"#TTTLOCT_prio_4", "#TTTLOCT_NOFRM_prio_4", "#TOCT_prio_4",
+	"#TTTLOCT_prio_5", "#TTTLOCT_NOFRM_prio_5", "#TOCT_prio_5",
+	"#TTTLOCT_prio_6", "#TTTLOCT_NOFRM_prio_6", "#TOCT_prio_6",
+	"#TTTLOCT_prio_7", "#TTTLOCT_NOFRM_prio_7", "#TOCT_prio_7",
+	"#TTTLOCT_novlan", "#TTTLOCT_NOFRM_novlan", "#TOCT_novlan",
+	"#TTTLOCT_loopbk", "#TTTLOCT_NOFRM_loopbk", "#TOCT_loopbk",
+	"#TTOT_prio_0", "#T1Q_prio_0", "reserved",
+	"#TTOT_prio_1", "#T1Q_prio_1", "reserved",
+	"#TTOT_prio_2", "#T1Q_prio_2", "reserved",
+	"#TTOT_prio_3", "#T1Q_prio_3", "reserved",
+	"#TTOT_prio_4", "#T1Q_prio_4", "reserved",
+	"#TTOT_prio_5", "#T1Q_prio_5", "reserved",
+	"#TTOT_prio_6", "#T1Q_prio_6", "reserved",
+	"#TTOT_prio_7", "#T1Q_prio_7", "reserved",
+	"#TTOT_novlan", "#T1Q_novlan", "reserved",
+	"#TTOT_loopbk", "#T1Q_loopbk", "reserved",
+	"#RJBBR", "#RCRC", "#RRUNT", "#RSHORT", "#RDROP",
+	"#RdropOvflw", "#RdropLength", "#RTOTFRMS", "#TDROP",
+};
+
+static int mlx4_en_get_stats_count(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int cnt = NUM_PORT_STATS;
+
+	if (DO_SW_COUNTERS)
+		cnt += (priv->tx_ring_num + priv->rx_ring_num) * 2;
+	cnt += NUM_PERF_STATS;
+	cnt += NUM_HW_STATS - NUM_HW_STATS_RES;
+	return cnt;
+}
+
+static void mlx4_en_get_ethtool_stats(struct net_device *dev,
+		struct ethtool_stats *stats, uint64_t *data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int index = 0;
+	int i;
+
+	/* Generic statistics */
+	data[index++] = priv->port_stats.rst_cnt;
+	data[index++] = priv->port_stats.lro_session_ovfl;
+	data[index++] = priv->port_stats.queue_stopped;
+
+	/* Per-ring SW counters */
+	if (DO_SW_COUNTERS) {
+		for (i = 0; i < priv->tx_ring_num; i++) {
+			data[index++] = priv->tx_ring[i].packets;
+			data[index++] = priv->tx_ring[i].bytes;
+		}
+		for (i = 0; i < priv->rx_ring_num; i++) {
+			data[index++] = priv->rx_ring[i].packets;
+			data[index++] = priv->rx_ring[i].bytes;
+		}
+	}
+
+	/* Performance statistics */
+	if (NUM_PERF_STATS) {
+		data[index++] = GET_PERF_COUNTER(priv->pstats.tso);
+		data[index++] = GET_AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg);
+		data[index++] = GET_AVG_PERF_COUNTER(priv->pstats.inflight_avg);
+		data[index++] = GET_AVG_PERF_COUNTER(priv->pstats.rx_coal_avg);
+		data[index++] = GET_AVG_PERF_COUNTER(priv->pstats.tx_coal_avg);
+		data[index++] = GET_PERF_COUNTER(priv->pstats.tx_poll);
+		data[index++] = GET_AVG_PERF_COUNTER(priv->pstats.lro_size_avg);
+		data[index++] = GET_PERF_COUNTER(priv->pstats.lro_flushes);
+		data[index++] = GET_PERF_COUNTER(priv->pstats.lro_misses);
+		data[index++] = GET_PERF_COUNTER(priv->pstats.napi_quota);
+		data[index++] = GET_PERF_COUNTER(priv->pstats.rx_chksum_none);
+		data[index++] = GET_PERF_COUNTER(priv->pstats.rx_alloc_failed);
+	}
+
+	/* HW statistics */
+	mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 0);
+	for (i = 0; i < NUM_HW_STATS64; i++) {
+		if (strcmp(hw_strings[i], "reserved"))
+			data[index++] = be64_to_cpu(*((u64 *)
+						      &priv->hw_stats + i));
+	}
+	for (i = 0; i < NUM_HW_STATS32; i++)
+		data[index++] = (u64) be32_to_cpu(*((u32 *)
+			    &priv->hw_stats + 2 * NUM_HW_STATS64 + i));
+}
+
+static void mlx4_en_get_strings(struct net_device *dev,
+			      uint32_t stringset, uint8_t *data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int index = 0;
+	int i;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	/* Add port counters */
+	for (i = 0; i < NUM_PORT_STATS; i++)
+		strcpy(data + (index++) * ETH_GSTRING_LEN, port_strings[i]);
+
+	/* Add SW counters */
+	if (DO_SW_COUNTERS) {
+		for (i = 0; i < priv->tx_ring_num; i++) {
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"tx%d_packets", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"tx%d_bytes", i);
+		}
+		for (i = 0; i < priv->rx_ring_num; i++) {
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_packets", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_bytes", i);
+		}
+	}
+
+	/* Add performance counters */
+	for (i = 0; i < NUM_PERF_STATS; i++)
+		strcpy(data + (index++) * ETH_GSTRING_LEN, perf_strings[i]);
+
+	/* Add HW counters */
+	for (i = 0; i < NUM_HW_STATS; i++) {
+		if (strcmp(hw_strings[i], "reserved"))
+			strcpy(data + (index++) * ETH_GSTRING_LEN, hw_strings[i]);
+	}
+}
+
+static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->autoneg = AUTONEG_DISABLE;
+	cmd->supported = SUPPORTED_10000baseT_Full;
+	cmd->advertising = SUPPORTED_10000baseT_Full;
+	if (netif_carrier_ok(dev)) {
+		cmd->speed = SPEED_10000;
+		cmd->duplex = DUPLEX_FULL;
+	} else {
+		cmd->speed = -1;
+		cmd->duplex = -1;
+	}
+	return 0;
+}
+
+static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	if ((cmd->autoneg == AUTONEG_ENABLE) ||
+	    (cmd->speed != SPEED_10000) || (cmd->duplex != DUPLEX_FULL))
+		return -EINVAL;
+
+	/* Nothing to change */
+	return 0;
+}
+
+static int mlx4_en_get_coalesce(struct net_device *dev,
+			      struct ethtool_coalesce *coal)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	coal->tx_coalesce_usecs = 0;
+	coal->tx_max_coalesced_frames = 0;
+	coal->rx_coalesce_usecs = priv->rx_usecs;
+	coal->rx_max_coalesced_frames = priv->rx_frames;
+
+	coal->pkt_rate_low = priv->pkt_rate_low;
+	coal->rx_coalesce_usecs_low = priv->rx_usecs_low;
+	coal->pkt_rate_high = priv->pkt_rate_high;
+	coal->rx_coalesce_usecs_high = priv->rx_usecs_high;
+	coal->rate_sample_interval = priv->sample_interval;
+	coal->use_adaptive_rx_coalesce = priv->adaptive_rx_coal;
+	return 0;
+}
+
+static int mlx4_en_set_coalesce(struct net_device *dev,
+			      struct ethtool_coalesce *coal)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int err, i;
+
+	priv->rx_frames = (coal->rx_max_coalesced_frames ==
+			   MLX4_EN_AUTO_CONF) ?
+				MLX4_EN_RX_COAL_TARGET /
+				priv->dev->mtu + 1 :
+				coal->rx_max_coalesced_frames;
+	priv->rx_usecs = (coal->rx_coalesce_usecs ==
+			  MLX4_EN_AUTO_CONF) ?
+				MLX4_EN_RX_COAL_TIME :
+				coal->rx_coalesce_usecs;
+
+	/* Set adaptive coalescing params */
+	priv->pkt_rate_low = coal->pkt_rate_low;
+	priv->rx_usecs_low = coal->rx_coalesce_usecs_low;
+	priv->pkt_rate_high = coal->pkt_rate_high;
+	priv->rx_usecs_high = coal->rx_coalesce_usecs_high;
+	priv->sample_interval = coal->rate_sample_interval;
+	priv->adaptive_rx_coal = coal->use_adaptive_rx_coalesce;
+	priv->last_moder_time = MLX4_EN_AUTO_CONF;
+	if (priv->adaptive_rx_coal)
+		return 0;
+
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		priv->rx_cq[i].moder_cnt = priv->rx_frames;
+		priv->rx_cq[i].moder_time = priv->rx_usecs;
+		err = mlx4_en_set_cq_moder(priv, &priv->rx_cq[i]);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int mlx4_en_set_pauseparam(struct net_device *dev,
+				struct ethtool_pauseparam *pause)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int err;
+
+	mdev->profile.tx_pause = pause->tx_pause != 0;
+	mdev->profile.rx_pause = pause->rx_pause != 0;
+	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
+				    priv->rx_skb_size + ETH_FCS_LEN,
+				    mdev->profile.tx_pause,
+				    mdev->profile.tx_ppp,
+				    mdev->profile.rx_pause,
+				    mdev->profile.rx_ppp);
+	if (err)
+		mlx4_err(mdev, "Failed setting pause params to\n");
+
+	return err;
+}
+
+static void mlx4_en_get_pauseparam(struct net_device *dev,
+				 struct ethtool_pauseparam *pause)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+
+	pause->tx_pause = mdev->profile.tx_pause;
+	pause->rx_pause = mdev->profile.rx_pause;
+}
+
+void mlx4_en_get_ringparam(struct net_device *dev, struct ethtool_ringparam *param)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+
+	memset(param, 0, sizeof(*param));
+	param->rx_max_pending = mdev->dev->caps.max_rq_sg;
+	param->tx_max_pending = mdev->dev->caps.max_sq_sg;
+	param->rx_pending = mdev->profile.prof[priv->port].rx_ring_size;
+	param->tx_pending = mdev->profile.prof[priv->port].tx_ring_size;
+}
+
+const struct ethtool_ops mlx4_en_ethtool_ops = {
+	.get_drvinfo = mlx4_en_get_drvinfo,
+	.get_settings = mlx4_en_get_settings,
+	.set_settings = mlx4_en_set_settings,
+#ifdef NETIF_F_TSO
+	.get_tso = mlx4_en_get_tso,
+	.set_tso = mlx4_en_set_tso,
+#endif
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ethtool_op_set_sg,
+	.get_link = ethtool_op_get_link,
+	.get_rx_csum = mlx4_en_get_rx_csum,
+	.set_rx_csum = mlx4_en_set_rx_csum,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_ipv6_csum,
+	.get_strings = mlx4_en_get_strings,
+	.get_stats_count = mlx4_en_get_stats_count,
+	.get_ethtool_stats = mlx4_en_get_ethtool_stats,
+	.get_coalesce = mlx4_en_get_coalesce,
+	.set_coalesce = mlx4_en_set_coalesce,
+	.get_pauseparam = mlx4_en_get_pauseparam,
+	.set_pauseparam = mlx4_en_set_pauseparam,
+	.get_ringparam = mlx4_en_get_ringparam,
+	.get_flags = ethtool_op_get_flags,
+	.set_flags = ethtool_op_set_flags,
+};
+
+
+
+
+
-- 
1.5.4




