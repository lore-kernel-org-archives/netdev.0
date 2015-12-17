From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 4/4] net/mlx5e: Add PTP Hardware Clock (PHC) support
Date: Thu, 17 Dec 2015 14:35:35 +0200
Message-ID: <1450355735-30846-5-git-send-email-saeedm@mellanox.com>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60062 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755222AbbLQMgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 07:36:06 -0500
In-Reply-To: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add a PHC support to the mlx5_en driver. Use reader/writer spinlocks to
protect the timecounter since every packet received needs to call
timecounter_cycle2time() when timestamping is enabled.  This can become
a performance bottleneck with RSS and multiple receive queues if normal
spinlocks are used.

The driver has been tested with both Documentation/ptp/testptp and the
linuxptp project (http://linuxptp.sourceforge.net/) on a Mellanox
ConnectX-4 card.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  107 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    2 +
 5 files changed, 117 insertions(+), 0 deletions(-)

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
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 84e65a5..f0a36d5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -34,6 +34,7 @@
 #include <linux/etherdevice.h>
 #include <linux/timecounter.h>
 #include <linux/net_tstamp.h>
+#include <linux/ptp_clock_kernel.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
@@ -497,6 +498,8 @@ struct mlx5e_tstamp {
 	u32                        nominal_c_mult;
 	unsigned long              last_overflow_check;
 	unsigned long              overflow_period;
+	struct ptp_clock          *ptp;
+	struct ptp_clock_info      ptp_info;
 };
 
 struct mlx5e_priv {
@@ -605,6 +608,7 @@ void mlx5e_fill_hwstamp(struct mlx5e_tstamp *clock,
 			u64 timestamp);
 void mlx5e_timestamp_overflow_check(struct mlx5e_priv *priv);
 void mlx5e_timestamp_init(struct mlx5e_priv *priv);
+void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv);
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 9bc0058..7542f17 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -52,6 +52,93 @@ void mlx5e_fill_hwstamp(struct mlx5e_tstamp *tstamp,
 	hwts->hwtstamp = ns_to_ktime(nsec);
 }
 
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
 static cycle_t mlx5e_read_clock(const struct cyclecounter *cc)
 {
 	struct mlx5e_tstamp *tstamp = container_of(cc, struct mlx5e_tstamp,
@@ -116,4 +203,24 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 				 &frac);
 	do_div(ns, NSEC_PER_SEC / 2 / HZ);
 	tstamp->overflow_period = ns;
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
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 8e86f2c..b2e5014 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -880,6 +880,9 @@ static int mlx5e_get_ts_info(struct net_device *dev,
 				(1 << HWTSTAMP_FILTER_ALL);
 	}
 
+	if (priv->tstamp.ptp)
+		info->phc_index = ptp_clock_index(priv->tstamp.ptp);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c8c4fa7..b2628d6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2382,6 +2382,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	return priv;
 
 err_destroy_flow_tables:
+	mlx5e_timestamp_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 
 err_destroy_tirs:
@@ -2428,6 +2429,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5e_disable_async_events(priv);
 	flush_scheduled_work();
 	unregister_netdev(netdev);
+	mlx5e_timestamp_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 	mlx5e_destroy_tirs(priv);
 	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
-- 
1.7.1
