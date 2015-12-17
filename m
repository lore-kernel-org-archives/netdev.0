From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 3/4] net/mlx5e: Add HW timestamping (TS) support
Date: Thu, 17 Dec 2015 14:35:34 +0200
Message-ID: <1450355735-30846-4-git-send-email-saeedm@mellanox.com>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60071 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755220AbbLQMgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 07:36:06 -0500
In-Reply-To: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add support for enable/disable HW timestamping for incoming and/or
outgoing packets. To enable/disable HW timestamping appropriate
ioctl should be used.  Currently HWTSTAMP_FILTER_ALL/NONE and
HWTSAMP_TX_ON/OFF only are supported.  Make all relevant changes in
RX/TX flows to consider TS request and plant HW timestamps into
relevant structures.

Add internal clock for converting hardware timestamp to nanoseconds.  In
addition, add a service task to catch internal clock overflow, to make
sure timestamping is accurate.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   21 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  119 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   29 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  101 ++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   14 +++
 7 files changed, 293 insertions(+), 2 deletions(-)
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
index f689ce5..84e65a5 100644
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
@@ -63,6 +65,7 @@
 #define MLX5E_TX_CQ_POLL_BUDGET        128
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
 #define MLX5E_SQ_BF_BUDGET             16
+#define MLX5E_SERVICE_TASK_DELAY       (HZ / 4)
 
 #define MLX5E_NUM_MAIN_GROUPS 9
 
@@ -486,6 +489,16 @@ struct mlx5e_flow_tables {
 	struct mlx5e_flow_table		main;
 };
 
+struct mlx5e_tstamp {
+	rwlock_t                   lock;
+	struct cyclecounter        cycles;
+	struct timecounter         clock;
+	struct hwtstamp_config     hwtstamp_config;
+	u32                        nominal_c_mult;
+	unsigned long              last_overflow_check;
+	unsigned long              overflow_period;
+};
+
 struct mlx5e_priv {
 	/* priv data path fields - start */
 	int                        default_vlan_prio;
@@ -515,10 +528,12 @@ struct mlx5e_priv {
 	struct work_struct         update_carrier_work;
 	struct work_struct         set_rx_mode_work;
 	struct delayed_work        update_stats_work;
+	struct delayed_work        service_task;
 
 	struct mlx5_core_dev      *mdev;
 	struct net_device         *netdev;
 	struct mlx5e_stats         stats;
+	struct mlx5e_tstamp        tstamp;
 };
 
 #define MLX5E_NET_IP_ALIGN 2
@@ -585,6 +600,12 @@ void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv);
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv);
 void mlx5e_set_rx_mode_work(struct work_struct *work);
 
+void mlx5e_fill_hwstamp(struct mlx5e_tstamp *clock,
+			struct skb_shared_hwtstamps *hwts,
+			u64 timestamp);
+void mlx5e_timestamp_overflow_check(struct mlx5e_priv *priv);
+void mlx5e_timestamp_init(struct mlx5e_priv *priv);
+
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid);
 int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
new file mode 100644
index 0000000..9bc0058
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -0,0 +1,119 @@
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
+void mlx5e_timestamp_overflow_check(struct mlx5e_priv *priv)
+{
+	bool timeout = time_is_before_jiffies(priv->tstamp.last_overflow_check +
+					      priv->tstamp.overflow_period);
+	unsigned long flags;
+
+	if (timeout) {
+		write_lock_irqsave(&priv->tstamp.lock, flags);
+		timecounter_read(&priv->tstamp.clock);
+		write_unlock_irqrestore(&priv->tstamp.lock, flags);
+		priv->tstamp.last_overflow_check = jiffies;
+	}
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
+		mlx5_core_warn(priv->mdev, "invalid device_frequency_khz. %s failed\n",
+			       __func__);
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
+	ns = cyclecounter_cyc2ns(&tstamp->cycles, tstamp->cycles.mask, frac,
+				 &frac);
+	do_div(ns, NSEC_PER_SEC / 2 / HZ);
+	tstamp->overflow_period = ns;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 2e022e9..8e86f2c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -855,6 +855,34 @@ static int mlx5e_set_pauseparam(struct net_device *netdev,
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
+	return 0;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -878,4 +906,5 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_tunable       = mlx5e_set_tunable,
 	.get_pauseparam    = mlx5e_get_pauseparam,
 	.set_pauseparam    = mlx5e_set_pauseparam,
+	.get_ts_info       = mlx5e_get_ts_info,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d4601a5..c8c4fa7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -884,6 +884,30 @@ static void mlx5e_close_cq(struct mlx5e_cq *cq)
 	mlx5e_destroy_cq(cq);
 }
 
+/* mlx5e_service_task - Run service task for tasks that needed to be done
+ * periodically
+ */
+static void mlx5e_service_task(struct work_struct *work)
+{
+	struct delayed_work *dwork = to_delayed_work(work);
+	struct mlx5e_priv *priv = container_of(dwork, struct mlx5e_priv,
+					       service_task);
+
+	mutex_lock(&priv->state_lock);
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state) &&
+	    !test_bit(MLX5E_STATE_DESTROYING, &priv->state)) {
+		if (MLX5_CAP_GEN(priv->mdev, device_frequency_khz)) {
+			mlx5e_timestamp_overflow_check(priv);
+			/* Only mlx5e_timestamp_overflow_check is called from
+			 * this service task. schedule a new task only if clock
+			 * is initialized. if changed, move the scheduler.
+			 */
+			schedule_delayed_work(dwork, MLX5E_SERVICE_TASK_DELAY);
+		}
+	}
+	mutex_unlock(&priv->state_lock);
+}
+
 static int mlx5e_get_cpu(struct mlx5e_priv *priv, int ix)
 {
 	return cpumask_first(priv->mdev->priv.irq_info[ix].mask);
@@ -1429,6 +1453,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 	mlx5e_redirect_rqts(priv);
 
 	schedule_delayed_work(&priv->update_stats_work, 0);
+	schedule_delayed_work(&priv->service_task, 0);
 
 	return 0;
 
@@ -1932,6 +1957,77 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
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
@@ -2015,7 +2111,8 @@ static struct net_device_ops mlx5e_netdev_ops = {
 	.ndo_vlan_rx_add_vid	 = mlx5e_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	 = mlx5e_vlan_rx_kill_vid,
 	.ndo_set_features        = mlx5e_set_features,
-	.ndo_change_mtu		 = mlx5e_change_mtu
+	.ndo_change_mtu		 = mlx5e_change_mtu,
+	.ndo_do_ioctl		 = mlx5e_ioctl,
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
@@ -2096,6 +2193,7 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	INIT_WORK(&priv->update_carrier_work, mlx5e_update_carrier_work);
 	INIT_WORK(&priv->set_rx_mode_work, mlx5e_set_rx_mode_work);
 	INIT_DELAYED_WORK(&priv->update_stats_work, mlx5e_update_stats_work);
+	INIT_DELAYED_WORK(&priv->service_task, mlx5e_service_task);
 }
 
 static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
@@ -2270,6 +2368,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	}
 
 	mlx5e_init_eth_addr(priv);
+	mlx5e_timestamp_init(priv);
 
 	err = register_netdev(netdev);
 	if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 7c8c408..4ae70cd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -36,6 +36,10 @@
 #include <net/busy_poll.h>
 #include "en.h"
 
+#define MLX5E_RX_HW_STAMP(priv)				\
+	(priv->tstamp.hwtstamp_config.rx_filter ==	\
+		     HWTSTAMP_FILTER_ALL)
+
 static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
 				     struct mlx5e_rx_wqe *wqe, u16 ix)
 {
@@ -189,6 +193,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 				      struct sk_buff *skb)
 {
 	struct net_device *netdev = rq->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 	u32 cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
 	int lro_num_seg;
 
@@ -202,6 +207,10 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 		rq->stats.lro_bytes += cqe_bcnt;
 	}
 
+	if (MLX5E_RX_HW_STAMP(priv))
+		mlx5e_fill_hwstamp(&priv->tstamp, skb_hwtstamps(skb),
+				   get_cqe_ts(cqe));
+
 	mlx5e_handle_csum(netdev, cqe, rq, skb);
 
 	skb->protocol = eth_type_trans(skb, netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 0fcfe64..6d53386 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -37,6 +37,9 @@
 #define MLX5E_SQ_NOPS_ROOM  MLX5_SEND_WQE_MAX_WQEBBS
 #define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
 			    MLX5E_SQ_NOPS_ROOM)
+#define MLX5E_TX_HW_STAMP(priv, skb)					\
+	(priv->tstamp.hwtstamp_config.tx_type == HWTSTAMP_TX_ON &&	\
+	skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
 
 void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 {
@@ -271,6 +274,9 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 							MLX5_SEND_WQEBB_NUM_DS);
 	sq->pc += MLX5E_TX_SKB_CB(skb)->num_wqebbs;
 
+	if (MLX5E_TX_HW_STAMP(sq->channel->priv, skb))
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+
 	netdev_tx_sent_queue(sq->txq, MLX5E_TX_SKB_CB(skb)->num_bytes);
 
 	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
@@ -369,6 +375,14 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 				continue;
 			}
 
+			if (MLX5E_TX_HW_STAMP(sq->channel->priv, skb)) {
+				struct skb_shared_hwtstamps hwts;
+
+				mlx5e_fill_hwstamp(&sq->cq.channel->priv->tstamp,
+						   &hwts, get_cqe_ts(cqe));
+				skb_tstamp_tx(skb, &hwts);
+			}
+
 			for (j = 0; j < MLX5E_TX_SKB_CB(skb)->num_dma; j++) {
 				struct mlx5e_sq_dma *dma =
 					mlx5e_dma_get(sq, dma_fifo_cc++);
-- 
1.7.1
