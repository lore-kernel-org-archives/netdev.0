From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/mlx4_en: fix overflow in mlx4_en_init_timestamp()
Date: Thu, 23 Feb 2017 15:22:43 -0800
Message-ID: <1487892163.9415.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33112 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdBWXWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 18:22:45 -0500
Received: by mail-pg0-f67.google.com with SMTP id 5so680039pgj.0
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 15:22:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

The cited commit makes a great job of finding optimal shift/multiplier
values assuming a 10 seconds wrap around, but forgot to change the
overflow_period computation.

It overflows in cyclecounter_cyc2ns(), and the final result is 804 ms,
which is silly.

Lets simply use 5 seconds, no need to recompute this, given how it is
supposed to work.

Later, we will use a timer instead of a work queue, since the new RX
allocation schem will no longer need mlx4_en_recover_from_oom() and the
service_task firing every 250 ms.

Fixes: 31c128b66e5b ("net/mlx4_en: Choose time-stamping shift value according to HW frequency")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |   18 +++++++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h  |    1 
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index e7b81a305469e64b97f68bc0e2bcb064b78f08fe..024788549c2569a13d3a07ebbde718cccf980a26 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -89,10 +89,17 @@ void mlx4_en_remove_timestamp(struct mlx4_en_dev *mdev)
 	}
 }
 
+#define MLX4_EN_WRAP_AROUND_SEC	10UL
+/* By scheduling the overflow check every 5 seconds, we have a reasonably
+ * good chance we wont miss a wrap around.
+ * TOTO: Use a timer instead of a work queue to increase the guarantee.
+ */
+#define MLX4_EN_OVERFLOW_PERIOD (MLX4_EN_WRAP_AROUND_SEC * HZ / 2)
+
 void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
 {
 	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
-					      mdev->overflow_period);
+					      MLX4_EN_OVERFLOW_PERIOD);
 	unsigned long flags;
 
 	if (timeout) {
@@ -237,7 +244,6 @@ static const struct ptp_clock_info mlx4_en_ptp_clock_info = {
 	.enable		= mlx4_en_phc_enable,
 };
 
-#define MLX4_EN_WRAP_AROUND_SEC	10ULL
 
 /* This function calculates the max shift that enables the user range
  * of MLX4_EN_WRAP_AROUND_SEC values in the cycles register.
@@ -258,7 +264,6 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_dev *dev = mdev->dev;
 	unsigned long flags;
-	u64 ns, zero = 0;
 
 	/* mlx4_en_init_timestamp is called for each netdev.
 	 * mdev->ptp_clock is common for all ports, skip initialization if
@@ -282,13 +287,6 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 			 ktime_to_ns(ktime_get_real()));
 	write_sequnlock_irqrestore(&mdev->clock_lock, flags);
 
-	/* Calculate period in seconds to call the overflow watchdog - to make
-	 * sure counter is checked at least once every wrap around.
-	 */
-	ns = cyclecounter_cyc2ns(&mdev->cycles, mdev->cycles.mask, zero, &zero);
-	do_div(ns, NSEC_PER_SEC / 2 / HZ);
-	mdev->overflow_period = ns;
-
 	/* Configure the PHC */
 	mdev->ptp_clock_info = mlx4_en_ptp_clock_info;
 	snprintf(mdev->ptp_clock_info.name, 16, "mlx4 ptp");
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 4941b692e9479bc7800e92f9bfb13baf3ff7d0d4..3629ce11a68b9dec5c1659539bdc6f2c11114e35 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -430,7 +430,6 @@ struct mlx4_en_dev {
 	seqlock_t		clock_lock;
 	struct timecounter	clock;
 	unsigned long		last_overflow_check;
-	unsigned long		overflow_period;
 	struct ptp_clock	*ptp_clock;
 	struct ptp_clock_info	ptp_clock_info;
 	struct notifier_block	nb;
