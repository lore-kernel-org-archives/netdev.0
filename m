From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: do not use rwlock in fast path
Date: Thu, 09 Feb 2017 09:10:04 -0800
Message-ID: <1486660204.7793.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36405 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752365AbdBIRKG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:10:06 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so582866pfo.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:10:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using a reader-writer lock in fast path is silly, when we can
instead use RCU or a seqlock.

For mlx4 hwstamp clock, a seqlock is the way to go, removing
two atomic operations and false sharing. 

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |   35 ++++++++--------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h  |    2 
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 504461a464c581bf77b5cca127680f262222..e7b81a305469e64b97f68bc0e2bcb064b78f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -62,12 +62,13 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
 			    struct skb_shared_hwtstamps *hwts,
 			    u64 timestamp)
 {
-	unsigned long flags;
+	unsigned int seq;
 	u64 nsec;
 
-	read_lock_irqsave(&mdev->clock_lock, flags);
-	nsec = timecounter_cyc2time(&mdev->clock, timestamp);
-	read_unlock_irqrestore(&mdev->clock_lock, flags);
+	do {
+		seq = read_seqbegin(&mdev->clock_lock);
+		nsec = timecounter_cyc2time(&mdev->clock, timestamp);
+	} while (read_seqretry(&mdev->clock_lock, seq));
 
 	memset(hwts, 0, sizeof(struct skb_shared_hwtstamps));
 	hwts->hwtstamp = ns_to_ktime(nsec);
@@ -95,9 +96,9 @@ void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
 	unsigned long flags;
 
 	if (timeout) {
-		write_lock_irqsave(&mdev->clock_lock, flags);
+		write_seqlock_irqsave(&mdev->clock_lock, flags);
 		timecounter_read(&mdev->clock);
-		write_unlock_irqrestore(&mdev->clock_lock, flags);
+		write_sequnlock_irqrestore(&mdev->clock_lock, flags);
 		mdev->last_overflow_check = jiffies;
 	}
 }
@@ -128,10 +129,10 @@ static int mlx4_en_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	adj *= delta;
 	diff = div_u64(adj, 1000000000ULL);
 
-	write_lock_irqsave(&mdev->clock_lock, flags);
+	write_seqlock_irqsave(&mdev->clock_lock, flags);
 	timecounter_read(&mdev->clock);
 	mdev->cycles.mult = neg_adj ? mult - diff : mult + diff;
-	write_unlock_irqrestore(&mdev->clock_lock, flags);
+	write_sequnlock_irqrestore(&mdev->clock_lock, flags);
 
 	return 0;
 }
@@ -149,9 +150,9 @@ static int mlx4_en_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 						ptp_clock_info);
 	unsigned long flags;
 
-	write_lock_irqsave(&mdev->clock_lock, flags);
+	write_seqlock_irqsave(&mdev->clock_lock, flags);
 	timecounter_adjtime(&mdev->clock, delta);
-	write_unlock_irqrestore(&mdev->clock_lock, flags);
+	write_sequnlock_irqrestore(&mdev->clock_lock, flags);
 
 	return 0;
 }
@@ -172,9 +173,9 @@ static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp,
 	unsigned long flags;
 	u64 ns;
 
-	write_lock_irqsave(&mdev->clock_lock, flags);
+	write_seqlock_irqsave(&mdev->clock_lock, flags);
 	ns = timecounter_read(&mdev->clock);
-	write_unlock_irqrestore(&mdev->clock_lock, flags);
+	write_sequnlock_irqrestore(&mdev->clock_lock, flags);
 
 	*ts = ns_to_timespec64(ns);
 
@@ -198,9 +199,9 @@ static int mlx4_en_phc_settime(struct ptp_clock_info *ptp,
 	unsigned long flags;
 
 	/* reset the timecounter */
-	write_lock_irqsave(&mdev->clock_lock, flags);
+	write_seqlock_irqsave(&mdev->clock_lock, flags);
 	timecounter_init(&mdev->clock, &mdev->cycles, ns);
-	write_unlock_irqrestore(&mdev->clock_lock, flags);
+	write_sequnlock_irqrestore(&mdev->clock_lock, flags);
 
 	return 0;
 }
@@ -266,7 +267,7 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 	if (mdev->ptp_clock)
 		return;
 
-	rwlock_init(&mdev->clock_lock);
+	seqlock_init(&mdev->clock_lock);
 
 	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
 	mdev->cycles.read = mlx4_en_read_clock;
@@ -276,10 +277,10 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 		clocksource_khz2mult(1000 * dev->caps.hca_core_clock, mdev->cycles.shift);
 	mdev->nominal_c_mult = mdev->cycles.mult;
 
-	write_lock_irqsave(&mdev->clock_lock, flags);
+	write_seqlock_irqsave(&mdev->clock_lock, flags);
 	timecounter_init(&mdev->clock, &mdev->cycles,
 			 ktime_to_ns(ktime_get_real()));
-	write_unlock_irqrestore(&mdev->clock_lock, flags);
+	write_sequnlock_irqrestore(&mdev->clock_lock, flags);
 
 	/* Calculate period in seconds to call the overflow watchdog - to make
 	 * sure counter is checked at least once every wrap around.
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 52f157cea7765ad6907c59aead357a158848..59f67cdd27d65125138c746fbb615d945d53 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -417,9 +417,9 @@ struct mlx4_en_dev {
 	u32                     priv_pdn;
 	spinlock_t              uar_lock;
 	u8			mac_removed[MLX4_MAX_PORTS + 1];
-	rwlock_t		clock_lock;
 	u32			nominal_c_mult;
 	struct cyclecounter	cycles;
+	seqlock_t		clock_lock;
 	struct timecounter	clock;
 	unsigned long		last_overflow_check;
 	unsigned long		overflow_period;
