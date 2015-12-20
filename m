From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 4/4] net/mlx5e: Add PTP Hardware Clock (PHC) support
Date: Sun, 20 Dec 2015 23:46:31 +0200
Message-ID: <1450647991-13736-5-git-send-email-saeedm@mellanox.com>
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
Received: from [193.47.165.129] ([193.47.165.129]:60555 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751211AbbLTVr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2015 16:47:28 -0500
In-Reply-To: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
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
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  104 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    2 +
 4 files changed, 110 insertions(+), 0 deletions(-)

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
index 0395e72..9fa933d 100644
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
@@ -495,6 +496,8 @@ struct mlx5e_tstamp {
 	u32                        nominal_c_mult;
 	unsigned long              overflow_period;
 	struct delayed_work        overflow_work;
+	struct ptp_clock          *ptp;
+	struct ptp_clock_info      ptp_info;
 };
 
 struct mlx5e_priv {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index b85863e..eacf633 100644
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
@@ -117,6 +204,18 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 
 	INIT_DELAYED_WORK(&tstamp->overflow_work, mlx5e_timestamp_overflow);
 	schedule_delayed_work(&tstamp->overflow_work, 0);
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
 }
 
 void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
@@ -131,4 +230,9 @@ void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
 	write_unlock(&tstamp->lock);
 
 	cancel_delayed_work_sync(&tstamp->overflow_work);
+
+	if (priv->tstamp.ptp) {
+		ptp_clock_unregister(priv->tstamp.ptp);
+		priv->tstamp.ptp = NULL;
+	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 00458c7..aa1fc3e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -881,6 +881,8 @@ static int mlx5e_get_ts_info(struct net_device *dev,
 	}
 
 	info->phc_index = -1;
+	if (priv->tstamp.ptp)
+		info->phc_index = ptp_clock_index(priv->tstamp.ptp);
 
 	return 0;
 }
-- 
1.7.1
