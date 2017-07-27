From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 09/14] net/mlx5e: Fix broken disable 1PPS flow
Date: Thu, 27 Jul 2017 13:25:27 +0300
Message-ID: <20170727102532.2317-10-saeedm@mellanox.com>
References: <20170727102532.2317-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44985 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751428AbdG0K1O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:27:14 -0400
In-Reply-To: <20170727102532.2317-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Need to disable the MTPPS and unsubscribe from the pulse events
when user disables the 1PPS functionality.

Fixes: ee7f12205abc ('net/mlx5e: Implement 1PPS support')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 75 +++++++++++++---------
 1 file changed, 46 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index ab07233e2faa..25d43767c888 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -265,6 +265,8 @@ static int mlx5e_extts_configure(struct ptp_clock_info *ptp,
 	struct mlx5e_priv *priv =
 		container_of(tstamp, struct mlx5e_priv, tstamp);
 	u32 in[MLX5_ST_SZ_DW(mtpps_reg)] = {0};
+	u32 field_select = 0;
+	u8 pin_mode = 0;
 	u8 pattern = 0;
 	int pin = -1;
 	int err = 0;
@@ -279,18 +281,21 @@ static int mlx5e_extts_configure(struct ptp_clock_info *ptp,
 		pin = ptp_find_pin(tstamp->ptp, PTP_PF_EXTTS, rq->extts.index);
 		if (pin < 0)
 			return -EBUSY;
+		pin_mode = MLX5E_PIN_MODE_IN;
+		pattern = !!(rq->extts.flags & PTP_FALLING_EDGE);
+		field_select = MLX5E_MTPPS_FS_PIN_MODE |
+			       MLX5E_MTPPS_FS_PATTERN |
+			       MLX5E_MTPPS_FS_ENABLE;
+	} else {
+		pin = rq->extts.index;
+		field_select = MLX5E_MTPPS_FS_ENABLE;
 	}
 
-	if (rq->extts.flags & PTP_FALLING_EDGE)
-		pattern = 1;
-
 	MLX5_SET(mtpps_reg, in, pin, pin);
-	MLX5_SET(mtpps_reg, in, pin_mode, MLX5E_PIN_MODE_IN);
+	MLX5_SET(mtpps_reg, in, pin_mode, pin_mode);
 	MLX5_SET(mtpps_reg, in, pattern, pattern);
 	MLX5_SET(mtpps_reg, in, enable, on);
-	MLX5_SET(mtpps_reg, in, field_select, MLX5E_MTPPS_FS_PIN_MODE |
-					      MLX5E_MTPPS_FS_PATTERN |
-					      MLX5E_MTPPS_FS_ENABLE);
+	MLX5_SET(mtpps_reg, in, field_select, field_select);
 
 	err = mlx5_set_mtpps(priv->mdev, in, sizeof(in));
 	if (err)
@@ -313,6 +318,9 @@ static int mlx5e_perout_configure(struct ptp_clock_info *ptp,
 	u64 cycles_now, cycles_delta;
 	struct timespec64 ts;
 	unsigned long flags;
+	u32 field_select = 0;
+	u8 pin_mode = 0;
+	u8 pattern = 0;
 	int pin = -1;
 	s64 ns;
 
@@ -327,34 +335,43 @@ static int mlx5e_perout_configure(struct ptp_clock_info *ptp,
 				   rq->perout.index);
 		if (pin < 0)
 			return -EBUSY;
-	}
 
-	ts.tv_sec = rq->perout.period.sec;
-	ts.tv_nsec = rq->perout.period.nsec;
-	ns = timespec64_to_ns(&ts);
-	if (on)
+		pin_mode = MLX5E_PIN_MODE_OUT;
+		pattern = MLX5E_OUT_PATTERN_PERIODIC;
+		ts.tv_sec = rq->perout.period.sec;
+		ts.tv_nsec = rq->perout.period.nsec;
+		ns = timespec64_to_ns(&ts);
+
 		if ((ns >> 1) != 500000000LL)
 			return -EINVAL;
-	ts.tv_sec = rq->perout.start.sec;
-	ts.tv_nsec = rq->perout.start.nsec;
-	ns = timespec64_to_ns(&ts);
-	cycles_now = mlx5_read_internal_timer(tstamp->mdev);
-	write_lock_irqsave(&tstamp->lock, flags);
-	nsec_now = timecounter_cyc2time(&tstamp->clock, cycles_now);
-	nsec_delta = ns - nsec_now;
-	cycles_delta = div64_u64(nsec_delta << tstamp->cycles.shift,
-				 tstamp->cycles.mult);
-	write_unlock_irqrestore(&tstamp->lock, flags);
-	time_stamp = cycles_now + cycles_delta;
+
+		ts.tv_sec = rq->perout.start.sec;
+		ts.tv_nsec = rq->perout.start.nsec;
+		ns = timespec64_to_ns(&ts);
+		cycles_now = mlx5_read_internal_timer(tstamp->mdev);
+		write_lock_irqsave(&tstamp->lock, flags);
+		nsec_now = timecounter_cyc2time(&tstamp->clock, cycles_now);
+		nsec_delta = ns - nsec_now;
+		cycles_delta = div64_u64(nsec_delta << tstamp->cycles.shift,
+					 tstamp->cycles.mult);
+		write_unlock_irqrestore(&tstamp->lock, flags);
+		time_stamp = cycles_now + cycles_delta;
+		field_select = MLX5E_MTPPS_FS_PIN_MODE |
+			       MLX5E_MTPPS_FS_PATTERN |
+			       MLX5E_MTPPS_FS_ENABLE |
+			       MLX5E_MTPPS_FS_TIME_STAMP;
+	} else {
+		pin = rq->perout.index;
+		field_select = MLX5E_MTPPS_FS_ENABLE;
+	}
+
 	MLX5_SET(mtpps_reg, in, pin, pin);
-	MLX5_SET(mtpps_reg, in, pin_mode, MLX5E_PIN_MODE_OUT);
-	MLX5_SET(mtpps_reg, in, pattern, MLX5E_OUT_PATTERN_PERIODIC);
+	MLX5_SET(mtpps_reg, in, pin_mode, pin_mode);
+	MLX5_SET(mtpps_reg, in, pattern, pattern);
 	MLX5_SET(mtpps_reg, in, enable, on);
 	MLX5_SET64(mtpps_reg, in, time_stamp, time_stamp);
-	MLX5_SET(mtpps_reg, in, field_select, MLX5E_MTPPS_FS_PIN_MODE |
-					      MLX5E_MTPPS_FS_PATTERN |
-					      MLX5E_MTPPS_FS_ENABLE |
-					      MLX5E_MTPPS_FS_TIME_STAMP);
+	MLX5_SET(mtpps_reg, in, field_select, field_select);
+
 	return mlx5_set_mtpps(priv->mdev, in, sizeof(in));
 }
 
-- 
2.13.0
