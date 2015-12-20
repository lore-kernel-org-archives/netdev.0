From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS) support
Date: Sun, 20 Dec 2015 23:46:30 +0200
Message-ID: <1450647991-13736-4-git-send-email-saeedm@mellanox.com>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	saeedm@dev.mellanox.co.il, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60573 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751219AbbLTVrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2015 16:47:43 -0500
In-Reply-To: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add support for enable/disable HW timestamping for incoming and/or
outgoing packets. To enable/disable HW timestamping appropriate
ioctl should be used. Currently HWTSTAMP_FILTER_ALL/NONE and
HWTSAMP_TX_ON/OFF only are supported. Make all relevant changes in
RX/TX flows to consider TS request and plant HW timestamps into
relevant structures.

Add internal clock for converting hardware timestamp to nanoseconds. In
addition, add a service task to catch internal clock overflow, to make
sure timestamping is accurate.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   19 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  134 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   31 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   77 +++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   10 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   17 +++
 7 files changed, 288 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index fe11e96..01c0256 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -5,4 +5,4 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
-		en_txrx.o
+		en_txrx.o en_clock.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ae3f0e3..0395e72 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -32,6 +32,8 @@
 
 #include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
+#include <linux/timecounter.h>
+#include <linux/net_tstamp.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
@@ -485,6 +487,16 @@ struct mlx5e_flow_tables {
 	struct mlx5e_flow_table		main;
 };
 
+struct mlx5e_tstamp {
+	rwlock_t                   lock;
+	struct cyclecounter        cycles;
+	struct timecounter         clock;
+	struct hwtstamp_config     hwtstamp_config;
+	u32                        nominal_c_mult;
+	unsigned long              overflow_period;
+	struct delayed_work        overflow_work;
+};
+
 struct mlx5e_priv {
 	/* priv data path fields - start */
 	int                        default_vlan_prio;
@@ -518,6 +530,7 @@ struct mlx5e_priv {
 	struct mlx5_core_dev      *mdev;
 	struct net_device         *netdev;
 	struct mlx5e_stats         stats;
+	struct mlx5e_tstamp        tstamp;
 };
 
 #define MLX5E_NET_IP_ALIGN 2
@@ -584,6 +597,12 @@ void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv);
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv);
 void mlx5e_set_rx_mode_work(struct work_struct *work);
 
+void mlx5e_fill_hwstamp(struct mlx5e_tstamp *clock,
+			struct skb_shared_hwtstamps *hwts,
+			u64 timestamp);
+void mlx5e_timestamp_init(struct mlx5e_priv *priv);
+void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv);
+
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid);
 int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
new file mode 100644
index 0000000..b85863e
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -0,0 +1,134 @@
+/*
+ * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
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
+#include <linux/clocksource.h>
+#include "en.h"
+
+enum {
+	MLX5E_CYCLES_SHIFT	= 23
+};
+
+void mlx5e_fill_hwstamp(struct mlx5e_tstamp *tstamp,
+			struct skb_shared_hwtstamps *hwts,
+			u64 timestamp)
+{
+	unsigned long flags;
+	u64 nsec;
+
+	memset(hwts, 0, sizeof(struct skb_shared_hwtstamps));
+	read_lock_irqsave(&tstamp->lock, flags);
+	nsec = timecounter_cyc2time(&tstamp->clock, timestamp);
+	read_unlock_irqrestore(&tstamp->lock, flags);
+
+	hwts->hwtstamp = ns_to_ktime(nsec);
+}
+
+static cycle_t mlx5e_read_clock(const struct cyclecounter *cc)
+{
+	struct mlx5e_tstamp *tstamp = container_of(cc, struct mlx5e_tstamp,
+						   cycles);
+	struct mlx5e_priv *priv = container_of(tstamp, struct mlx5e_priv,
+					       tstamp);
+
+	return mlx5_core_read_clock(priv->mdev) & cc->mask;
+}
+
+/* Should run once every mlx5e_tstamp->overflow_period */
+static void mlx5e_timestamp_overflow(struct work_struct *work)
+{
+	struct delayed_work *dwork = to_delayed_work(work);
+	struct mlx5e_tstamp *tstamp = container_of(dwork, struct mlx5e_tstamp, overflow_work);
+	unsigned long flags;
+
+	write_lock_irqsave(&tstamp->lock, flags);
+	timecounter_read(&tstamp->clock);
+	if (tstamp->overflow_period)
+		schedule_delayed_work(&tstamp->overflow_work, tstamp->overflow_period);
+	write_unlock_irqrestore(&tstamp->lock, flags);
+}
+
+static void mlx5e_timestamp_init_config(struct mlx5e_tstamp *tstamp)
+{
+	tstamp->hwtstamp_config.flags = 0;
+	tstamp->hwtstamp_config.tx_type = HWTSTAMP_TX_OFF;
+	tstamp->hwtstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
+}
+
+void mlx5e_timestamp_init(struct mlx5e_priv *priv)
+{
+	struct mlx5e_tstamp *tstamp = &priv->tstamp;
+	u64 ns;
+	u64 frac = 0;
+	u32 dev_freq;
+
+	mlx5e_timestamp_init_config(tstamp);
+	dev_freq = MLX5_CAP_GEN(priv->mdev, device_frequency_khz);
+	if (!dev_freq) {
+		mlx5_core_warn(priv->mdev, "invalid device_frequency_khz, aborting HW clock init\n");
+		return;
+	}
+	rwlock_init(&tstamp->lock);
+	memset(&tstamp->cycles, 0, sizeof(tstamp->cycles));
+	tstamp->cycles.read = mlx5e_read_clock;
+	tstamp->cycles.shift = MLX5E_CYCLES_SHIFT;
+	tstamp->cycles.mult = clocksource_khz2mult(dev_freq,
+						   tstamp->cycles.shift);
+	tstamp->nominal_c_mult = tstamp->cycles.mult;
+	tstamp->cycles.mask = CLOCKSOURCE_MASK(41);
+
+	timecounter_init(&tstamp->clock, &tstamp->cycles,
+			 ktime_to_ns(ktime_get_real()));
+
+	/* Calculate period in seconds to call the overflow watchdog - to make
+	 * sure counter is checked at least once every wrap around.
+	 */
+	ns = cyclecounter_cyc2ns(&tstamp->cycles, tstamp->cycles.mask, frac, &frac);
+	do_div(ns, NSEC_PER_SEC / 2 / HZ);
+	tstamp->overflow_period = ns;
+
+	INIT_DELAYED_WORK(&tstamp->overflow_work, mlx5e_timestamp_overflow);
+	schedule_delayed_work(&tstamp->overflow_work, 0);
+}
+
+void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
+{
+	struct mlx5e_tstamp *tstamp = &priv->tstamp;
+
+	if (!MLX5_CAP_GEN(priv->mdev, device_frequency_khz))
+		return;
+
+	write_lock(&tstamp->lock);
+	tstamp->overflow_period = 0; /* Signal overflow_check to stop */
+	write_unlock(&tstamp->lock);
+
+	cancel_delayed_work_sync(&tstamp->overflow_work);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 2e022e9..00458c7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -855,6 +855,36 @@ static int mlx5e_set_pauseparam(struct net_device *netdev,
 	return err;
 }
 
+static int mlx5e_get_ts_info(struct net_device *dev,
+			     struct ethtool_ts_info *info)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	int ret;
+
+	ret = ethtool_op_get_ts_info(dev, info);
+	if (ret)
+		return ret;
+
+	if (MLX5_CAP_GEN(priv->mdev, device_frequency_khz)) {
+		info->so_timestamping |=
+				SOF_TIMESTAMPING_TX_HARDWARE |
+				SOF_TIMESTAMPING_RX_HARDWARE |
+				SOF_TIMESTAMPING_RAW_HARDWARE;
+
+		info->tx_types =
+				(1 << HWTSTAMP_TX_OFF) |
+				(1 << HWTSTAMP_TX_ON);
+
+		info->rx_filters =
+				(1 << HWTSTAMP_FILTER_NONE) |
+				(1 << HWTSTAMP_FILTER_ALL);
+	}
+
+	info->phc_index = -1;
+
+	return 0;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -878,4 +908,5 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_tunable       = mlx5e_set_tunable,
 	.get_pauseparam    = mlx5e_get_pauseparam,
 	.set_pauseparam    = mlx5e_set_pauseparam,
+	.get_ts_info       = mlx5e_get_ts_info,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 96775a2..97eeb5a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1935,6 +1935,77 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 	return err;
 }
 
+static int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct hwtstamp_config config;
+
+	if (!MLX5_CAP_GEN(priv->mdev, device_frequency_khz))
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	/* TX HW timestamp */
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+	case HWTSTAMP_TX_ON:
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	/* RX HW timestamp */
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	priv->tstamp.hwtstamp_config.tx_type = config.tx_type;
+	priv->tstamp.hwtstamp_config.rx_filter = config.rx_filter;
+
+	return copy_to_user(ifr->ifr_data, &config,
+			    sizeof(config)) ? -EFAULT : 0;
+}
+
+static int mlx5e_hwstamp_get(struct net_device *dev, struct ifreq *ifr)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	return copy_to_user(ifr->ifr_data, &priv->tstamp.hwtstamp_config,
+			    sizeof(priv->tstamp.hwtstamp_config)) ? -EFAULT : 0;
+}
+
+static int mlx5e_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return mlx5e_hwstamp_set(dev, ifr);
+	case SIOCGHWTSTAMP:
+		return mlx5e_hwstamp_get(dev, ifr);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int mlx5e_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -2018,7 +2089,8 @@ static struct net_device_ops mlx5e_netdev_ops = {
 	.ndo_vlan_rx_add_vid	 = mlx5e_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	 = mlx5e_vlan_rx_kill_vid,
 	.ndo_set_features        = mlx5e_set_features,
-	.ndo_change_mtu		 = mlx5e_change_mtu
+	.ndo_change_mtu		 = mlx5e_change_mtu,
+	.ndo_do_ioctl		 = mlx5e_ioctl,
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
@@ -2273,6 +2345,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	}
 
 	mlx5e_init_eth_addr(priv);
+	mlx5e_timestamp_init(priv);
 
 	err = register_netdev(netdev);
 	if (err) {
@@ -2286,6 +2359,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	return priv;
 
 err_destroy_flow_tables:
+	mlx5e_timestamp_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 
 err_destroy_tirs:
@@ -2332,6 +2406,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5e_disable_async_events(priv);
 	flush_scheduled_work();
 	unregister_netdev(netdev);
+	mlx5e_timestamp_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 	mlx5e_destroy_tirs(priv);
 	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 7c8c408..2fae730 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -36,6 +36,11 @@
 #include <net/busy_poll.h>
 #include "en.h"
 
+static inline bool mlx5e_rx_hw_stamp(struct mlx5e_priv *priv)
+{
+	return priv->tstamp.hwtstamp_config.rx_filter == HWTSTAMP_FILTER_ALL;
+}
+
 static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
 				     struct mlx5e_rx_wqe *wqe, u16 ix)
 {
@@ -189,6 +194,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 				      struct sk_buff *skb)
 {
 	struct net_device *netdev = rq->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 	u32 cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
 	int lro_num_seg;
 
@@ -202,6 +208,10 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 		rq->stats.lro_bytes += cqe_bcnt;
 	}
 
+	if (mlx5e_rx_hw_stamp(priv))
+		mlx5e_fill_hwstamp(&priv->tstamp, skb_hwtstamps(skb),
+				   get_cqe_ts(cqe));
+
 	mlx5e_handle_csum(netdev, cqe, rq, skb);
 
 	skb->protocol = eth_type_trans(skb, netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index aa037eb..c48a732 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -38,6 +38,12 @@
 #define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
 			    MLX5E_SQ_NOPS_ROOM)
 
+static inline bool mlx5e_tx_hw_stamp(struct mlx5e_priv *priv, struct sk_buff *skb)
+{
+	return ((priv->tstamp.hwtstamp_config.tx_type == HWTSTAMP_TX_ON) &&
+		(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP));
+}
+
 void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 {
 	struct mlx5_wq_cyc                *wq  = &sq->wq;
@@ -282,6 +288,9 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	netdev_tx_sent_queue(sq->txq, wi->num_bytes);
 
+	if (mlx5e_tx_hw_stamp(sq->channel->priv, skb))
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+
 	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
 		netif_tx_stop_queue(sq->txq);
 		sq->stats.stopped++;
@@ -380,6 +389,14 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 				continue;
 			}
 
+			if (mlx5e_tx_hw_stamp(sq->channel->priv, skb)) {
+				struct skb_shared_hwtstamps hwts;
+
+				mlx5e_fill_hwstamp(&sq->cq.channel->priv->tstamp,
+						   &hwts, get_cqe_ts(cqe));
+				skb_tstamp_tx(skb, &hwts);
+			}
+
 			for (j = 0; j < wi->num_dma; j++) {
 				struct mlx5e_sq_dma *dma =
 					mlx5e_dma_get(sq, dma_fifo_cc++);
-- 
1.7.1
