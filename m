From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 5/6] net/mlx5e: Fix wrong indications in DIM due to counter wraparound
Date: Sun, 11 Jun 2017 17:00:27 +0300
Message-ID: <20170611140028.12467-6-saeedm@mellanox.com>
References: <20170611140028.12467-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tal Gilboa <talgi@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35956 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751679AbdFKOAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:00:50 -0400
In-Reply-To: <20170611140028.12467-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tal Gilboa <talgi@mellanox.com>

DIM (Dynamically-tuned Interrupt Moderation) is a mechanism designed for
changing the channel interrupt moderation values in order to reduce CPU
overhead for all traffic types.
Each iteration of the algorithm, DIM calculates the difference in
throughput, packet rate and interrupt rate from last iteration in order
to make a decision. DIM relies on counters for each metric. When these
counters get to their type's max value they wraparound. In this case
the delta between 'end' and 'start' samples is negative and when
translated to unsigned integers - very high. This results in a false
indication to the algorithm and might result in a wrong decision.

The fix calculates the 'distance' between 'end' and 'start' samples in a
cyclic way around the relevant type's max value. It can also be viewed as
an absolute value around the type's max value instead of around 0.

Testing show higher stability in DIM profile selection and no wraparound
issues.

Fixes: cb3c7fd4f839 ("net/mlx5e: Support adaptive RX coalescing")
Signed-off-by: Tal Gilboa <talgi@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c | 10 +++++++---
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 429da21a583d..944fc1742464 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -463,10 +463,10 @@ struct mlx5e_rx_am_stats {
 };
 
 struct mlx5e_rx_am_sample {
-	ktime_t		time;
-	unsigned int	pkt_ctr;
-	unsigned int    byte_ctr;
-	u16		event_ctr;
+	ktime_t	time;
+	u32	pkt_ctr;
+	u32	byte_ctr;
+	u16	event_ctr;
 };
 
 struct mlx5e_rx_am { /* Adaptive Moderation */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
index 54cdda957f9a..acf32fe952cd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
@@ -270,6 +270,8 @@ static void mlx5e_am_sample(struct mlx5e_rq *rq,
 }
 
 #define MLX5E_AM_NEVENTS 64
+#define BITS_PER_TYPE(type) (sizeof(type) * BITS_PER_BYTE)
+#define BIT_GAP(bits, end, start) ((((end) - (start)) + BIT_ULL(bits)) & (BIT_ULL(bits) - 1))
 
 static void mlx5e_am_calc_stats(struct mlx5e_rx_am_sample *start,
 				struct mlx5e_rx_am_sample *end,
@@ -277,8 +279,9 @@ static void mlx5e_am_calc_stats(struct mlx5e_rx_am_sample *start,
 {
 	/* u32 holds up to 71 minutes, should be enough */
 	u32 delta_us = ktime_us_delta(end->time, start->time);
-	unsigned int npkts = end->pkt_ctr - start->pkt_ctr;
-	unsigned int nbytes = end->byte_ctr - start->byte_ctr;
+	u32 npkts = BIT_GAP(BITS_PER_TYPE(u32), end->pkt_ctr, start->pkt_ctr);
+	u32 nbytes = BIT_GAP(BITS_PER_TYPE(u32), end->byte_ctr,
+			     start->byte_ctr);
 
 	if (!delta_us)
 		return;
@@ -311,7 +314,8 @@ void mlx5e_rx_am(struct mlx5e_rq *rq)
 
 	switch (am->state) {
 	case MLX5E_AM_MEASURE_IN_PROGRESS:
-		nevents = rq->cq.event_ctr - am->start_sample.event_ctr;
+		nevents = BIT_GAP(BITS_PER_TYPE(u16), rq->cq.event_ctr,
+				  am->start_sample.event_ctr);
 		if (nevents < MLX5E_AM_NEVENTS)
 			break;
 		mlx5e_am_sample(rq, &end_sample);
-- 
2.11.0
