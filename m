From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] mlx5: fix 64-bit division on times
Date: Wed, 15 Jun 2016 17:27:52 +0200
Message-ID: <20160615152816.2800830-2-arnd@arndb.de>
References: <20160615152816.2800830-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Achiad Shochat <achiad@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615152816.2800830-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mlx5 driver fails to build on 32-bit architectures after some
references to 64-bit divisions got added:

drivers/net/built-in.o: In function `mlx5e_rx_am':
:(.text+0xf88ac): undefined reference to `__aeabi_ldivmod'

The driver even performs three division here, and it uses the
obsolete 'struct timespec' that we want to get rid of.

Using ktime_t and ktime_us_delta() replaces one of the divisions
and is mildly more efficient, aside from working across 'settimeofday'
calls and being the right type for the y2038 conversion.

Using a u32 instead of s64 to store the number of microseconds
limits the maximum time to about 71 minutes, but if we exceed that
time, we probably don't care about the result any more for the
purpose of rx coalescing.

For the number of packets, we are taking the difference between
two 'unsigned int', so the result won't ever be greater than that
either.

After those changes, the other two divisions are done as 32-bit
arithmetic operations, which are much faster.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 3841f0b3493b ("net/mlx5e: Support adaptive RX coalescing")
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 775b8d02a3dc..37df5728323b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -272,7 +272,7 @@ struct mlx5e_rx_am_stats {
 };
 
 struct mlx5e_rx_am_sample {
-	struct timespec	time;
+	ktime_t		time;
 	unsigned int	pkt_ctr;
 	u16		event_ctr;
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
index cdff5cace4c2..bd0c70220a80 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
@@ -267,7 +267,7 @@ static bool mlx5e_am_decision(struct mlx5e_rx_am_stats *curr_stats,
 static void mlx5e_am_sample(struct mlx5e_rq *rq,
 			    struct mlx5e_rx_am_sample *s)
 {
-	getnstimeofday(&s->time);
+	s->time	     = ktime_get();
 	s->pkt_ctr   = rq->stats.packets;
 	s->event_ctr = rq->cq.event_ctr;
 }
@@ -278,17 +278,17 @@ static void mlx5e_am_calc_stats(struct mlx5e_rx_am_sample *start,
 				struct mlx5e_rx_am_sample *end,
 				struct mlx5e_rx_am_stats *curr_stats)
 {
-	struct timespec time = timespec_sub(end->time, start->time);
-	s64 delta_us = timespec_to_ns(&time) / 1000;
-	s64 npkts = end->pkt_ctr - start->pkt_ctr;
+	/* u32 holds up to 71 minutes, should be enough */
+	u32 delta_us = ktime_us_delta(end->time, start->time);
+	unsigned int npkts = end->pkt_ctr - start->pkt_ctr;
 
 	if (!delta_us) {
 		WARN_ONCE(true, "mlx5e_am_calc_stats: delta_us=0\n");
 		return;
 	}
 
-	curr_stats->ppms =            (npkts * 1000) / delta_us;
-	curr_stats->epms = (MLX5E_AM_NEVENTS * 1000) / delta_us;
+	curr_stats->ppms = 	      (npkts * USEC_PER_MSEC) / delta_us;
+	curr_stats->epms = (MLX5E_AM_NEVENTS * USEC_PER_MSEC) / delta_us;
 }
 
 void mlx5e_rx_am_work(struct work_struct *work)
-- 
2.9.0
