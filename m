From: Hadar Hen-Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Thu, 26 Dec 2013 16:41:11 +0200
Message-ID: <20131226144111.GB12695@mtl-eit-vdi-41.mtl.labs.mlnx>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
 <20131223184845.GA4922@netboy>
 <52B992EE.5030401@mellanox.com>
 <20131225115322.GB5378@netboy>
 <52BBE84C.1030702@mellanox.com>
 <52BBE9D6.3040006@mellanox.com>
 <20131226091740.GA8787@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	Tom Ketterhagen <tomk@rgmadvisors.com>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:61649 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab3LZOlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 09:41:17 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so3660292eaj.21
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 06:41:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131226091740.GA8787@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 26, 2013 at 10:17:41AM +0100, Richard Cochran wrote:
> On Thu, Dec 26, 2013 at 10:33:26AM +0200, Hadar Hen Zion wrote:
> > 
> > Is there a way to time stamping packets per socket?
> 
> No, it is at the device level. Some devices support time stamping
> different types of packets, like PTP events.
> 
> I looked again at your driver, and now it makes sense to me that the
> spin lock is so costly in your tests. Every received packet calls
> timecounter_cyc2time.  So you will need locking, and I think
> reader/writer is perfectly fine for you to use.
> 
> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


The below patch is my suggestion for using RCU.
According to my test there is no performace loss with RCU.
If reader/writer is deprecated, why not using RCU? 

Thanks,
Hadar

---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |   82 +++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h  |    2 +-
 2 files changed, 52 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index cc6a546..2fbe9aa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -107,17 +107,54 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
 			    struct skb_shared_hwtstamps *hwts,
 			    u64 timestamp)
 {
-	unsigned long flags;
 	u64 nsec;
 
-	spin_lock_irqsave(&mdev->clock_lock, flags);
-	nsec = timecounter_cyc2time(&mdev->clock, timestamp);
-	spin_unlock_irqrestore(&mdev->clock_lock, flags);
+	rcu_read_lock();
+	nsec = timecounter_cyc2time(rcu_dereference(mdev->clock), timestamp);
+	rcu_read_unlock();
 
 	memset(hwts, 0, sizeof(struct skb_shared_hwtstamps));
 	hwts->hwtstamp = ns_to_ktime(nsec);
 }
 
+void mlx4_en_timecounter_init(struct mlx4_en_dev *mdev,
+			      u64 start_tstamp)
+{
+	struct timecounter *new_tc, *old_tc;
+	unsigned long flags;
+
+	new_tc = kmalloc(sizeof(*new_tc), GFP_KERNEL);
+
+	spin_lock_irqsave(&mdev->clock_lock, flags);
+	old_tc = mdev->clock;
+	*new_tc = *old_tc;
+	timecounter_init(new_tc, &mdev->cycles, start_tstamp);
+	rcu_assign_pointer(mdev->clock, new_tc);
+	spin_unlock_irqrestore(&mdev->clock_lock, flags);
+	synchronize_rcu();
+	kfree(old_tc);
+}
+
+u64 mlx4_en_timecounter_read(struct mlx4_en_dev *mdev)
+{
+	struct timecounter *new_tc, *old_tc;
+	unsigned long flags;
+	s64 now;
+
+	new_tc = kmalloc(sizeof(*new_tc), GFP_KERNEL);
+
+	spin_lock_irqsave(&mdev->clock_lock, flags);
+	old_tc = mdev->clock;
+	*new_tc = *old_tc;
+	now = timecounter_read(new_tc);
+	rcu_assign_pointer(mdev->clock, new_tc);
+	spin_unlock_irqrestore(&mdev->clock_lock, flags);
+	synchronize_rcu();
+	kfree(old_tc);
+
+	return now;
+}
+
 /**
  * mlx4_en_remove_timestamp - disable PTP device
  * @mdev: board private structure
@@ -129,6 +166,7 @@ void mlx4_en_remove_timestamp(struct mlx4_en_dev *mdev)
 	if (mdev->ptp_clock) {
 		ptp_clock_unregister(mdev->ptp_clock);
 		mdev->ptp_clock = NULL;
+		kfree(mdev->clock);
 		mlx4_info(mdev, "removed PHC\n");
 	}
 }
@@ -137,12 +175,9 @@ void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
 {
 	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
 					      mdev->overflow_period);
-	unsigned long flags;
 
 	if (timeout) {
-		spin_lock_irqsave(&mdev->clock_lock, flags);
-		timecounter_read(&mdev->clock);
-		spin_unlock_irqrestore(&mdev->clock_lock, flags);
+		mlx4_en_timecounter_read(mdev);
 		mdev->last_overflow_check = jiffies;
 	}
 }
@@ -160,7 +195,6 @@ static int mlx4_en_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	u64 adj;
 	u32 diff, mult;
 	int neg_adj = 0;
-	unsigned long flags;
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
 
@@ -173,10 +207,8 @@ static int mlx4_en_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	adj *= delta;
 	diff = div_u64(adj, 1000000000ULL);
 
-	spin_lock_irqsave(&mdev->clock_lock, flags);
-	timecounter_read(&mdev->clock);
+	mlx4_en_timecounter_read(mdev);
 	mdev->cycles.mult = neg_adj ? mult - diff : mult + diff;
-	spin_unlock_irqrestore(&mdev->clock_lock, flags);
 
 	return 0;
 }
@@ -192,14 +224,11 @@ static int mlx4_en_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
-	unsigned long flags;
 	s64 now;
 
-	spin_lock_irqsave(&mdev->clock_lock, flags);
-	now = timecounter_read(&mdev->clock);
+	now = mlx4_en_timecounter_read(mdev);
 	now += delta;
-	timecounter_init(&mdev->clock, &mdev->cycles, now);
-	spin_unlock_irqrestore(&mdev->clock_lock, flags);
+	mlx4_en_timecounter_init(mdev, now);
 
 	return 0;
 }
@@ -216,14 +245,10 @@ static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 {
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
-	unsigned long flags;
 	u32 remainder;
 	u64 ns;
 
-	spin_lock_irqsave(&mdev->clock_lock, flags);
-	ns = timecounter_read(&mdev->clock);
-	spin_unlock_irqrestore(&mdev->clock_lock, flags);
-
+	ns = mlx4_en_timecounter_read(mdev);
 	ts->tv_sec = div_u64_rem(ns, NSEC_PER_SEC, &remainder);
 	ts->tv_nsec = remainder;
 
@@ -244,12 +269,9 @@ static int mlx4_en_phc_settime(struct ptp_clock_info *ptp,
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
 	u64 ns = timespec_to_ns(ts);
-	unsigned long flags;
 
 	/* reset the timecounter */
-	spin_lock_irqsave(&mdev->clock_lock, flags);
-	timecounter_init(&mdev->clock, &mdev->cycles, ns);
-	spin_unlock_irqrestore(&mdev->clock_lock, flags);
+	mlx4_en_timecounter_init(mdev, ns);
 
 	return 0;
 }
@@ -287,9 +309,9 @@ static const struct ptp_clock_info mlx4_en_ptp_clock_info = {
 void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_dev *dev = mdev->dev;
-	unsigned long flags;
 	u64 ns;
 
+	mdev->clock = kmalloc(sizeof(struct timecounter), GFP_KERNEL);
 	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
 	mdev->cycles.read = mlx4_en_read_clock;
 	mdev->cycles.mask = CLOCKSOURCE_MASK(48);
@@ -303,10 +325,7 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 		clocksource_khz2mult(1000 * dev->caps.hca_core_clock, mdev->cycles.shift);
 	mdev->nominal_c_mult = mdev->cycles.mult;
 
-	spin_lock_irqsave(&mdev->clock_lock, flags);
-	timecounter_init(&mdev->clock, &mdev->cycles,
-			 ktime_to_ns(ktime_get_real()));
-	spin_unlock_irqrestore(&mdev->clock_lock, flags);
+	mlx4_en_timecounter_init(mdev, ktime_to_ns(ktime_get_real()));
 
 	/* Calculate period in seconds to call the overflow watchdog - to make
 	 * sure counter is checked at least once every wrap around.
@@ -323,6 +342,7 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 					     &mdev->pdev->dev);
 	if (IS_ERR(mdev->ptp_clock)) {
 		mdev->ptp_clock = NULL;
+		kfree(mdev->clock);
 		mlx4_err(mdev, "ptp_clock_register failed\n");
 	} else {
 		mlx4_info(mdev, "registered PHC clock\n");
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index e7733c1..7d1d460 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -379,7 +379,7 @@ struct mlx4_en_dev {
 	spinlock_t		clock_lock;
 	u32			nominal_c_mult;
 	struct cyclecounter	cycles;
-	struct timecounter	clock;
+	struct timecounter	*clock;
 	unsigned long		last_overflow_check;
 	unsigned long		overflow_period;
 	struct ptp_clock	*ptp_clock;
-- 
1.7.8.2
