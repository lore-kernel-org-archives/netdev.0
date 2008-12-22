From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH 5/9] mlx4_en: Removed Interrupt moderation
	module parameters
Date: Mon, 22 Dec 2008 12:00:59 +0200
Message-ID: <494F655B.1070405@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

They are controlled through Ethtool interface, no need to have two
ways to modify them.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   14 +++-----------
 drivers/net/mlx4/en_params.c |   10 ----------
 drivers/net/mlx4/mlx4_en.h   |    3 ---
 3 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 96e709d..8b5e8f0 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -369,7 +369,6 @@ static struct net_device_stats *mlx4_en_get_stats(struct net_device *dev)

 static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 {
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_cq *cq;
 	int i;

@@ -379,15 +378,8 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	 *   satisfy our coelsing target.
 	 * - moder_time is set to a fixed value.
 	 */
-	priv->rx_frames = (mdev->profile.rx_moder_cnt ==
-			   MLX4_EN_AUTO_CONF) ?
-				MLX4_EN_RX_COAL_TARGET /
-				priv->dev->mtu + 1 :
-				mdev->profile.rx_moder_cnt;
-	priv->rx_usecs = (mdev->profile.rx_moder_time ==
-			  MLX4_EN_AUTO_CONF) ?
-				MLX4_EN_RX_COAL_TIME :
-				mdev->profile.rx_moder_time;
+	priv->rx_frames = MLX4_EN_RX_COAL_TARGET / priv->dev->mtu + 1;
+	priv->rx_usecs = MLX4_EN_RX_COAL_TIME;
 	mlx4_dbg(INTR, priv, "Default coalesing params for mtu:%d - "
 			     "rx_frames:%d rx_usecs:%d\n",
 		 priv->dev->mtu, priv->rx_frames, priv->rx_usecs);
@@ -411,7 +403,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	priv->pkt_rate_high = MLX4_EN_RX_RATE_HIGH;
 	priv->rx_usecs_high = MLX4_EN_RX_COAL_TIME_HIGH;
 	priv->sample_interval = MLX4_EN_SAMPLE_INTERVAL;
-	priv->adaptive_rx_coal = mdev->profile.auto_moder;
+	priv->adaptive_rx_coal = 1;
 	priv->last_moder_time = MLX4_EN_AUTO_CONF;
 	priv->last_moder_jiffies = 0;
 	priv->last_moder_packets = 0;
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index 95706ee..86f4031 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -71,13 +71,6 @@ MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
 			   " Per priority bit mask");

-/* Interrupt moderation tunning */
-MLX4_EN_PARM_INT(rx_moder_cnt, MLX4_EN_AUTO_CONF,
-	       "Max coalesced descriptors for Rx interrupt moderation");
-MLX4_EN_PARM_INT(rx_moder_time, MLX4_EN_AUTO_CONF,
-	       "Timeout following last packet for Rx interrupt moderation");
-MLX4_EN_PARM_INT(auto_moder, 1, "Enable dynamic interrupt moderation");
-
 MLX4_EN_PARM_INT(rx_ring_num1, 0, "Number or Rx rings for port 1 (0 = #cores)");
 MLX4_EN_PARM_INT(rx_ring_num2, 0, "Number or Rx rings for port 2 (0 = #cores)");

@@ -92,9 +85,6 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	struct mlx4_en_profile *params = &mdev->profile;
 	int i;

-	params->rx_moder_cnt = min_t(int, rx_moder_cnt, MLX4_EN_AUTO_CONF);
-	params->rx_moder_time = min_t(int, rx_moder_time, MLX4_EN_AUTO_CONF);
-	params->auto_moder = auto_moder;
 	params->rss_xor = (rss_xor != 0);
 	params->rss_mask = rss_mask & 0x1f;
 	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 45b975f..63c42e4 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -333,9 +333,6 @@ struct mlx4_en_profile {
 	u8 rss_mask;
 	u32 active_ports;
 	u32 small_pkt_int;
-	int rx_moder_cnt;
-	int rx_moder_time;
-	int auto_moder;
 	u8 no_reset;
 	struct mlx4_en_port_profile prof[MLX4_MAX_PORTS + 1];
 };
-- 
1.5.4
