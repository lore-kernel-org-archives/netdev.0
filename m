From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH RFC] mlx4_en: Add PTP hardware clock
Date: Wed, 11 Dec 2013 12:24:25 -0600
Message-ID: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:50021 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab3LKSY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 13:24:59 -0500
Received: by mail-oa0-f54.google.com with SMTP id h16so7791276oag.27
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 10:24:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

This adds a PHC to the mlx4_en driver.  This is largely based off of the
e1000e driver (drivers/net/ethernet/intel/e1000e/ptp.c) which seemed
very similar.  One thing I am unsure about is that in the e1000e driver
they protect the timecounter code with a spinlock because the hardware
reports the time in two 32bit registers.  The Mellanox code looks
similar however the existing timecounter code in the mlx4_en driver
wasn't protected with a lock so I left the lock out here as well.

Additionally here the mlx4_en_phc_adjfreq() method simply returns
-EOPNOTSUPP because I don't have the relevant hardware documentation on
how to do this.  I'm hoping one of the Mellanox developers can either
provide this documentation or provide a patch to implement that
function.

This is minimally tested at this point but Documentation/ptp/testptp
appears to work on a Mellanox ConnectX-3 card.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c   |  156 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |   11 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    4 +
 4 files changed, 162 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index fd64410..4405b90 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -111,10 +111,142 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
 	hwts->hwtstamp = ns_to_ktime(nsec);
 }
 
+/**
+ * mlx4_en_remove_timestamp - disable PTP device
+ * @mdev: board private structure
+ *
+ * Stop the PTP support.
+ **/
+void mlx4_en_remove_timestamp(struct mlx4_en_dev *mdev)
+{
+	if (mdev->ptp_clock) {
+		ptp_clock_unregister(mdev->ptp_clock);
+		mdev->ptp_clock = NULL;
+		mlx4_info(mdev, "removed PHC\n");
+	}
+}
+
+void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
+{
+	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
+					      mdev->overflow_period);
+
+	if (timeout) {
+		timecounter_read(&mdev->clock);
+		mdev->last_overflow_check = jiffies;
+	}
+}
+
+/**
+ * mlx4_en_phc_adjfreq - adjust the frequency of the hardware clock
+ * @ptp: ptp clock structure
+ * @delta: Desired frequency change in parts per billion
+ *
+ * Adjust the frequency of the PHC cycle counter by the indicated delta from
+ * the base frequency.
+ **/
+static int mlx4_en_phc_adjfreq(struct ptp_clock_info __always_unused *ptp,
+			       s32 __always_unused delta)
+{
+	return -EOPNOTSUPP;
+}
+
+/**
+ * mlx4_en_phc_adjtime - Shift the time of the hardware clock
+ * @ptp: ptp clock structure
+ * @delta: Desired change in nanoseconds
+ *
+ * Adjust the timer by resetting the timecounter structure.
+ **/
+static int mlx4_en_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
+						ptp_clock_info);
+	s64 now;
+
+	now = timecounter_read(&mdev->clock);
+	now += delta;
+	timecounter_init(&mdev->clock, &mdev->cycles, now);
+
+	return 0;
+}
+
+/**
+ * mlx4_en_phc_gettime - Reads the current time from the hardware clock
+ * @ptp: ptp clock structure
+ * @ts: timespec structure to hold the current time value
+ *
+ * Read the timecounter and return the correct value in ns after converting
+ * it into a struct timespec.
+ **/
+static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
+						ptp_clock_info);
+	u32 remainder;
+	u64 ns = timecounter_read(&mdev->clock);
+
+	ts->tv_sec = div_u64_rem(ns, NSEC_PER_SEC, &remainder);
+	ts->tv_nsec = remainder;
+
+	return 0;
+}
+
+/**
+ * mlx4_en_phc_settime - Set the current time on the hardware clock
+ * @ptp: ptp clock structure
+ * @ts: timespec containing the new time for the cycle counter
+ *
+ * Reset the timecounter to use a new base value instead of the kernel
+ * wall timer value.
+ **/
+static int mlx4_en_phc_settime(struct ptp_clock_info *ptp,
+			       const struct timespec *ts)
+{
+	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
+						ptp_clock_info);
+	u64 ns = timespec_to_ns(ts);
+
+	/* reset the timecounter */
+	timecounter_init(&mdev->clock, &mdev->cycles, ns);
+
+	return 0;
+}
+
+/**
+ * mlx4_en_phc_enable - enable or disable an ancillary feature
+ * @ptp: ptp clock structure
+ * @request: Desired resource to enable or disable
+ * @on: Caller passes one to enable or zero to disable
+ *
+ * Enable (or disable) ancillary features of the PHC subsystem.
+ * Currently, no ancillary features are supported.
+ **/
+static int mlx4_en_phc_enable(struct ptp_clock_info __always_unused *ptp,
+			      struct ptp_clock_request __always_unused *request,
+			      int __always_unused on)
+{
+	return -EOPNOTSUPP;
+}
+
+static const struct ptp_clock_info mlx4_en_ptp_clock_info = {
+	.owner		= THIS_MODULE,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 0,
+	.adjfreq	= mlx4_en_phc_adjfreq,
+	.adjtime	= mlx4_en_phc_adjtime,
+	.gettime	= mlx4_en_phc_gettime,
+	.settime	= mlx4_en_phc_settime,
+	.enable		= mlx4_en_phc_enable,
+};
+
 void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_dev *dev = mdev->dev;
 	u64 ns;
+	int i;
 
 	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
 	mdev->cycles.read = mlx4_en_read_clock;
@@ -137,15 +269,23 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 	ns = cyclecounter_cyc2ns(&mdev->cycles, mdev->cycles.mask);
 	do_div(ns, NSEC_PER_SEC / 2 / HZ);
 	mdev->overflow_period = ns;
-}
 
-void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
-{
-	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
-					      mdev->overflow_period);
+	/* Configure the PHC */
+	mdev->ptp_clock_info = mlx4_en_ptp_clock_info;
+	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
+		snprintf(mdev->ptp_clock_info.name,
+			 sizeof(mdev->ptp_clock_info.name), "%pm",
+			 mdev->pndev[i]->perm_addr);
+		break;
+	}
 
-	if (timeout) {
-		timecounter_read(&mdev->clock);
-		mdev->last_overflow_check = jiffies;
+	mdev->ptp_clock = ptp_clock_register(&mdev->ptp_clock_info,
+					     &mdev->pdev->dev);
+	if (IS_ERR(mdev->ptp_clock)) {
+		mdev->ptp_clock = NULL;
+		mlx4_err(mdev, "ptp_clock_register failed\n");
+	} else {
+		mlx4_info(mdev, "registered PHC clock\n");
 	}
+
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 0596f9f..3e8d336 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1193,6 +1193,9 @@ static int mlx4_en_get_ts_info(struct net_device *dev,
 		info->rx_filters =
 			(1 << HWTSTAMP_FILTER_NONE) |
 			(1 << HWTSTAMP_FILTER_ALL);
+
+		if (mdev->ptp_clock)
+			info->phc_index = ptp_clock_index(mdev->ptp_clock);
 	}
 
 	return ret;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 0d087b0..51bed5d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -196,6 +196,9 @@ static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
 		if (mdev->pndev[i])
 			mlx4_en_destroy_netdev(mdev->pndev[i]);
 
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
+		mlx4_en_remove_timestamp(mdev);
+
 	flush_workqueue(mdev->workqueue);
 	destroy_workqueue(mdev->workqueue);
 	(void) mlx4_mr_free(dev, &mdev->mr);
@@ -264,10 +267,6 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH)
 		mdev->port_cnt++;
 
-	/* Initialize time stamp mechanism */
-	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
-		mlx4_en_init_timestamp(mdev);
-
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
 		if (!dev->caps.comp_pool) {
 			mdev->profile.prof[i].rx_ring_num =
@@ -305,6 +304,10 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 			mdev->pndev[i] = NULL;
 	}
 
+	/* Initialize time stamp mechanism */
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
+		mlx4_en_init_timestamp(mdev);
+
 	return mdev;
 
 err_mr:
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index f3758de..fc35801 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -45,6 +45,7 @@
 #include <linux/dcbnl.h>
 #endif
 #include <linux/cpu_rmap.h>
+#include <linux/ptp_clock_kernel.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/qp.h>
@@ -377,6 +378,8 @@ struct mlx4_en_dev {
 	struct timecounter	clock;
 	unsigned long		last_overflow_check;
 	unsigned long		overflow_period;
+	struct ptp_clock	*ptp_clock;
+	struct ptp_clock_info	ptp_clock_info;
 };
 
 
@@ -786,6 +789,7 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
 			    struct skb_shared_hwtstamps *hwts,
 			    u64 timestamp);
 void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev);
+void mlx4_en_remove_timestamp(struct mlx4_en_dev *mdev);
 int mlx4_en_timestamp_config(struct net_device *dev,
 			     int tx_type,
 			     int rx_filter);
-- 
1.7.7.6
