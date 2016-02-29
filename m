From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 3/7] net/mlx5e: Fix soft lockup when HW Timestamping is enabled
Date: Mon, 29 Feb 2016 21:17:11 +0200
Message-ID: <1456773435-16607-4-git-send-email-saeedm@mellanox.com>
References: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53198 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751411AbcB2TSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 14:18:49 -0500
In-Reply-To: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Readers/Writers lock for SW timecounter was acquired without disabling
interrupts on local CPU.

The problematic scenario:
* HW timestamping is enabled
* Timestamp overflow periodic service task is running on local CPU and
  holding write_lock for SW timecounter
* Completion arrives, triggers interrupt for local CPU.
  Interrupt routine calls napi_schedule(), which triggers rx/tx
  skb process.
  An attempt to read SW timecounter using read_lock is done, which is
  already locked by a writer on the same CPU and cause soft lockup.

Add irqsave/irqrestore for when using the readers/writers lock for
writing.

Fixes: ef9814deafd0 ('net/mlx5e: Add HW timestamping (TS) support')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   25 ++++++++++++--------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index be65435..2018eeb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -62,10 +62,11 @@ static void mlx5e_timestamp_overflow(struct work_struct *work)
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct mlx5e_tstamp *tstamp = container_of(dwork, struct mlx5e_tstamp,
 						   overflow_work);
+	unsigned long flags;
 
-	write_lock(&tstamp->lock);
+	write_lock_irqsave(&tstamp->lock, flags);
 	timecounter_read(&tstamp->clock);
-	write_unlock(&tstamp->lock);
+	write_unlock_irqrestore(&tstamp->lock, flags);
 	schedule_delayed_work(&tstamp->overflow_work, tstamp->overflow_period);
 }
 
@@ -136,10 +137,11 @@ static int mlx5e_ptp_settime(struct ptp_clock_info *ptp,
 	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
 						   ptp_info);
 	u64 ns = timespec64_to_ns(ts);
+	unsigned long flags;
 
-	write_lock(&tstamp->lock);
+	write_lock_irqsave(&tstamp->lock, flags);
 	timecounter_init(&tstamp->clock, &tstamp->cycles, ns);
-	write_unlock(&tstamp->lock);
+	write_unlock_irqrestore(&tstamp->lock, flags);
 
 	return 0;
 }
@@ -150,10 +152,11 @@ static int mlx5e_ptp_gettime(struct ptp_clock_info *ptp,
 	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
 						   ptp_info);
 	u64 ns;
+	unsigned long flags;
 
-	write_lock(&tstamp->lock);
+	write_lock_irqsave(&tstamp->lock, flags);
 	ns = timecounter_read(&tstamp->clock);
-	write_unlock(&tstamp->lock);
+	write_unlock_irqrestore(&tstamp->lock, flags);
 
 	*ts = ns_to_timespec64(ns);
 
@@ -164,10 +167,11 @@ static int mlx5e_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
 	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
 						   ptp_info);
+	unsigned long flags;
 
-	write_lock(&tstamp->lock);
+	write_lock_irqsave(&tstamp->lock, flags);
 	timecounter_adjtime(&tstamp->clock, delta);
-	write_unlock(&tstamp->lock);
+	write_unlock_irqrestore(&tstamp->lock, flags);
 
 	return 0;
 }
@@ -176,6 +180,7 @@ static int mlx5e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 {
 	u64 adj;
 	u32 diff;
+	unsigned long flags;
 	int neg_adj = 0;
 	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
 						  ptp_info);
@@ -189,11 +194,11 @@ static int mlx5e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	adj *= delta;
 	diff = div_u64(adj, 1000000000ULL);
 
-	write_lock(&tstamp->lock);
+	write_lock_irqsave(&tstamp->lock, flags);
 	timecounter_read(&tstamp->clock);
 	tstamp->cycles.mult = neg_adj ? tstamp->nominal_c_mult - diff :
 					tstamp->nominal_c_mult + diff;
-	write_unlock(&tstamp->lock);
+	write_unlock_irqrestore(&tstamp->lock, flags);
 
 	return 0;
 }
-- 
1.7.1
