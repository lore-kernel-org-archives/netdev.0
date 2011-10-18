From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/6 V2] mlx4_en: Controlling FCS header removal
Date: Tue, 18 Oct 2011 13:50:42 +0200
Message-ID: <4E9D6812.5050105@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:35645 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757863Ab1JRN6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 09:58:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Canceling FCS removal where FW allows for better alignment
of incoming data.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    4 ++++
 drivers/net/ethernet/mellanox/mlx4/fw.c    |    1 +
 include/linux/mlx4/device.h                |    1 +
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 37cc9e5..fbf1dcf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -806,6 +806,10 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
 				qpn, ring->cqn, context);
 	context->db_rec_addr = cpu_to_be64(ring->wqres.db.dma);
 
+	/* Cancel FCS removal if FW allows */
+	if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP)
+		context->param3 |= cpu_to_be32(1 << 29);
+
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, context, qp, state);
 	if (err) {
 		mlx4_qp_remove(mdev->dev, qp);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 7eb8ba8..ed452dd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -101,6 +101,7 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u64 flags)
 		[25] = "Router support",
 		[30] = "IBoE support",
 		[32] = "Unicast loopback support",
+		[34] = "FCS header control",
 		[38] = "Wake On LAN support",
 		[40] = "UDP RSS support",
 		[41] = "Unicast VEP steering support",
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 53ef894..2366f94 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -75,6 +75,7 @@ enum {
 	MLX4_DEV_CAP_FLAG_UD_MCAST	= 1LL << 21,
 	MLX4_DEV_CAP_FLAG_IBOE		= 1LL << 30,
 	MLX4_DEV_CAP_FLAG_UC_LOOPBACK	= 1LL << 32,
+	MLX4_DEV_CAP_FLAG_FCS_KEEP	= 1LL << 34,
 	MLX4_DEV_CAP_FLAG_WOL		= 1LL << 38,
 	MLX4_DEV_CAP_FLAG_UDP_RSS	= 1LL << 40,
 	MLX4_DEV_CAP_FLAG_VEP_UC_STEER	= 1LL << 41,
-- 
1.7.7
