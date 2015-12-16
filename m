From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx5_en: Add HW timestamping (TS) support
Date: Wed, 16 Dec 2015 18:46:34 +0200
Message-ID: <1450284394-32386-3-git-send-email-saeedm@mellanox.com>
References: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51511 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933012AbbLPQrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 11:47:20 -0500
In-Reply-To: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add support for enable/disable HW timestamping for incoming and/or
outgoing packets. It adds and initializes all structs and callbacks
needed by kernel TS API.  To enable/disable HW timestamping appropriate
ioctl should be used.  Currently HWTSTAMP_FILTER_ALL/NONE and
HWTSAMP_TX_ON/OFF only are supported.  Make all relevant changes in
RX/TX flows to consider TS request and plant HW timestamps into
relevant structures.

Add a PHC support to the mlx5_en driver. Use reader/writer spinlocks to
protect the timecounter since every packet received needs to call
timecounter_cycle2time() when timestamping is enabled.  This can become
a performance bottleneck with RSS and multiple receive queues if normal
spinlocks are used.

This driver has been tested with both Documentation/ptp/testptp and the
linuxptp project (http://linuxptp.sourceforge.net/) on a Mellanox
ConnectX-4 card.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   25 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  226 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   32 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  103 +++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   14 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   31 +++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
 include/linux/mlx5/device.h                        |   20 ++-
 include/linux/mlx5/mlx5_ifc.h                      |    5 +-
 12 files changed, 462 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 158c88c..c503ea0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -13,6 +13,7 @@ config MLX5_CORE
 config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
 	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
+	select PTP_1588_CLOCK
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
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
index f689ce5..7634eb2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -32,6 +32,9 @@
 
 #include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
+#include <linux/timecounter.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/net_tstamp.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
@@ -63,6 +66,7 @@
 #define MLX5E_TX_CQ_POLL_BUDGET        128
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
 #define MLX5E_SQ_BF_BUDGET             16
+#define MLX5E_SERVICE_TASK_DELAY       (HZ / 4)
 
 #define MLX5E_NUM_MAIN_GROUPS 9
 
@@ -486,6 +490,18 @@ struct mlx5e_flow_tables {
 	struct mlx5e_flow_table		main;
 };
 
+struct mlx5e_tstamp {
+	rwlock_t                   lock;
+	struct cyclecounter        cycles;
+	struct timecounter         clock;
+	struct ptp_clock          *ptp;
+	struct ptp_clock_info      ptp_info;
+	struct hwtstamp_config     hwtstamp_config;
+	u32                        nominal_c_mult;
+	unsigned long              last_overflow_check;
+	unsigned long              overflow_period;
+};
+
 struct mlx5e_priv {
 	/* priv data path fields - start */
 	int                        default_vlan_prio;
@@ -515,10 +531,12 @@ struct mlx5e_priv {
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
@@ -585,6 +603,13 @@ void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv);
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv);
 void mlx5e_set_rx_mode_work(struct work_struct *work);
 
+void mlx5e_fill_hwstamp(struct mlx5e_tstamp *clock,
+			struct skb_shared_hwtstamps *hwts,
+			u64 timestamp);
+void mlx5e_timestamp_overflow_check(struct mlx5e_priv *priv);
+void mlx5e_timestamp_init(struct mlx5e_priv *priv);
+void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv);
+
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid);
 int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
new file mode 100644
index 0000000..7542f17
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -0,0 +1,226 @@
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
+static int mlx5e_ptp_settime(struct ptp_clock_info *ptp,
+			     const struct timespec64 *ts)
+{
+	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
+						   ptp_info);
+	u64 ns = timespec64_to_ns(ts);
+	unsigned long flags;
+
+	write_lock_irqsave(&tstamp->lock, flags);
+	timecounter_init(&tstamp->clock, &tstamp->cycles, ns);
+	write_unlock_irqrestore(&tstamp->lock, flags);
+
+	return 0;
+}
+
+static int mlx5e_ptp_gettime(struct ptp_clock_info *ptp,
+			     struct timespec64 *ts)
+{
+	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
+						   ptp_info);
+	u64 ns;
+	unsigned long flags;
+
+	write_lock_irqsave(&tstamp->lock, flags);
+	ns = timecounter_read(&tstamp->clock);
+	write_unlock_irqrestore(&tstamp->lock, flags);
+
+	*ts = ns_to_timespec64(ns);
+
+	return 0;
+}
+
+static int mlx5e_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
+						   ptp_info);
+	unsigned long flags;
+
+	write_lock_irqsave(&tstamp->lock, flags);
+	timecounter_adjtime(&tstamp->clock, delta);
+	write_unlock_irqrestore(&tstamp->lock, flags);
+
+	return 0;
+}
+
+static int mlx5e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 delta)
+{
+	u64 adj;
+	u32 diff;
+	int neg_adj = 0;
+	unsigned long flags;
+	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
+						  ptp_info);
+
+	if (delta < 0) {
+		neg_adj = 1;
+		delta = -delta;
+	}
+
+	adj = tstamp->nominal_c_mult;
+	adj *= delta;
+	diff = div_u64(adj, 1000000000ULL);
+
+	write_lock_irqsave(&tstamp->lock, flags);
+	timecounter_read(&tstamp->clock);
+	tstamp->cycles.mult = neg_adj ? tstamp->nominal_c_mult - diff :
+					tstamp->nominal_c_mult + diff;
+	write_unlock_irqrestore(&tstamp->lock, flags);
+
+	return 0;
+}
+
+static const struct ptp_clock_info mlx5e_ptp_clock_info = {
+	.owner		= THIS_MODULE,
+	.max_adj	= 100000000,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.n_pins		= 0,
+	.pps		= 0,
+	.adjfreq	= mlx5e_ptp_adjfreq,
+	.adjtime	= mlx5e_ptp_adjtime,
+	.gettime64	= mlx5e_ptp_gettime,
+	.settime64	= mlx5e_ptp_settime,
+	.enable		= NULL,
+};
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
+
+	/* Configure the PHC */
+	tstamp->ptp_info = mlx5e_ptp_clock_info;
+	snprintf(tstamp->ptp_info.name, 16, "mlx5 ptp");
+
+	tstamp->ptp = ptp_clock_register(&tstamp->ptp_info,
+					 &priv->mdev->pdev->dev);
+	if (IS_ERR_OR_NULL(tstamp->ptp)) {
+		mlx5_core_warn(priv->mdev, "ptp_clock_register failed %ld\n",
+			       PTR_ERR(tstamp->ptp));
+		tstamp->ptp = NULL;
+	}
+}
+
+void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
+{
+	if (priv->tstamp.ptp) {
+		ptp_clock_unregister(priv->tstamp.ptp);
+		priv->tstamp.ptp = NULL;
+	}
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 2e022e9..df15205 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -855,6 +855,37 @@ static int mlx5e_set_pauseparam(struct net_device *netdev,
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
+	if (priv->tstamp.ptp)
+		info->phc_index = ptp_clock_index(priv->tstamp.ptp);
+
+	return ret;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -878,4 +909,5 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_tunable       = mlx5e_set_tunable,
 	.get_pauseparam    = mlx5e_get_pauseparam,
 	.set_pauseparam    = mlx5e_set_pauseparam,
+	.get_ts_info       = mlx5e_get_ts_info,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d4601a5..f331031 100644
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
+			/* Only mlx5e_timestamp_overflow_check is called from this
+			 * service task. schedule a new task only if clock
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
@@ -2283,6 +2382,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	return priv;
 
 err_destroy_flow_tables:
+	mlx5e_timestamp_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 
 err_destroy_tirs:
@@ -2329,6 +2429,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5e_disable_async_events(priv);
 	flush_scheduled_work();
 	unregister_netdev(netdev);
+	mlx5e_timestamp_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 	mlx5e_destroy_tirs(priv);
 	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
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
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 789882b..b16eb42 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -504,6 +504,37 @@ int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id)
 	return mlx5_cmd_status_to_err_v2(out);
 }
 
+static u32 internal_timer_h(struct mlx5_core_dev *dev)
+{
+	return ioread32be(&dev->iseg->internal_timer_h);
+}
+
+static u32 internal_timer_l(struct mlx5_core_dev *dev)
+{
+	return ioread32be(&dev->iseg->internal_timer_l);
+}
+
+cycle_t mlx5_core_read_clock(struct mlx5_core_dev *dev)
+{
+	u32 timer_h, timer_h1, timer_l;
+
+	/*  Reading the internal timer using 2 PCI reads in a non-atomic manner
+	 * may hit the wraparound of the 32 LSBs. Reading the 32 MSBs twice can
+	 * verify a wraparound did not happen.
+	 */
+	timer_h = internal_timer_h(dev);
+	timer_l = internal_timer_l(dev);
+	timer_h1 = internal_timer_h(dev);
+	if (timer_h == timer_h1)
+		goto ret;
+
+	/* In case of overflow or wraparound, re-read the LSB */
+	timer_l = internal_timer_l(dev);
+
+ret:
+	return (u64)timer_l | (u64)timer_h1 << 32;
+}
+
 static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
 {
 	struct mlx5_priv *priv  = &mdev->priv;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index ea6a137..b6651b8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -98,6 +98,7 @@ int mlx5_core_sriov_configure(struct pci_dev *dev, int num_vfs);
 int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
 int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id);
 int mlx5_wait_for_vf_pages(struct mlx5_core_dev *dev);
+cycle_t mlx5_core_read_clock(struct mlx5_core_dev *dev);
 
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 7d3a85f..df2f79e 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -443,9 +443,12 @@ struct mlx5_init_seg {
 	__be32			rsvd1[120];
 	__be32			initializing;
 	struct health_buffer	health;
-	__be32			rsvd2[884];
+	__be32			rsvd2[880];
+	__be32			internal_timer_h;
+	__be32			internal_timer_l;
+	__be32			rsrv3[2];
 	__be32			health_counter;
-	__be32			rsvd3[1019];
+	__be32			rsvd4[1019];
 	__be64			ieee1588_clk;
 	__be32			ieee1588_clk_type;
 	__be32			clr_intx;
@@ -601,7 +604,8 @@ struct mlx5_cqe64 {
 	__be32		imm_inval_pkey;
 	u8		rsvd40[4];
 	__be32		byte_cnt;
-	__be64		timestamp;
+	__be32		timestamp_h;
+	__be32		timestamp_l;
 	__be32		sop_drop_qpn;
 	__be16		wqe_counter;
 	u8		signature;
@@ -623,6 +627,16 @@ static inline int cqe_has_vlan(struct mlx5_cqe64 *cqe)
 	return !!(cqe->l4_hdr_type_etc & 0x1);
 }
 
+static inline u64 get_cqe_ts(struct mlx5_cqe64 *cqe)
+{
+	u32 hi, lo;
+
+	hi = be32_to_cpu(cqe->timestamp_h);
+	lo = be32_to_cpu(cqe->timestamp_l);
+
+	return (u64)lo | ((u64)hi << 32);
+}
+
 enum {
 	CQE_L4_HDR_TYPE_NONE			= 0x0,
 	CQE_L4_HDR_TYPE_TCP_NO_ACK		= 0x1,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 131a273..e4da900 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -829,9 +829,10 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         reserved_66[0x8];
 	u8         log_uar_page_sz[0x10];
 
-	u8         reserved_67[0xe0];
+	u8         reserved_67[0x40];
+	u8         device_frequency_khz[0x20];
+	u8         reserved_68[0x5f];
 
-	u8         reserved_68[0x1f];
 	u8         cqe_zip[0x1];
 
 	u8         cqe_zip_timeout[0x10];
-- 
1.7.1
