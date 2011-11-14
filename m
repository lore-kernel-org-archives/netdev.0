From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH Fix V2] mlx4_en: Remove FCS bytes from packet length.
Date: Mon, 14 Nov 2011 18:40:13 +0200
Message-ID: <4EC1446D.4020209@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:47360 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753323Ab1KNTUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:20:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When HW doesn't remove FCS bytes they are reported in the completion
byte count, we don't need to take them to skb.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    6 +++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    1 +
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b89c36d..c2df6c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -581,6 +581,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		 * Packet is OK - process it.
 		 */
 		length = be32_to_cpu(cqe->byte_cnt);
+		length -= ring->fcs_del;
 		ring->bytes += length;
 		ring->packets++;
 
@@ -813,8 +814,11 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
 	context->db_rec_addr = cpu_to_be64(ring->wqres.db.dma);
 
 	/* Cancel FCS removal if FW allows */
-	if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP)
+	if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP) {
 		context->param3 |= cpu_to_be32(1 << 29);
+		ring->fcs_del = ETH_FCS_LEN;
+	} else
+		ring->fcs_del = 0;
 
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, context, qp, state);
 	if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8fda331c..207b5ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -272,6 +272,7 @@ struct mlx4_en_rx_ring {
 	u32 prod;
 	u32 cons;
 	u32 buf_size;
+	u8  fcs_del;
 	void *buf;
 	void *rx_info;
 	unsigned long bytes;
-- 
1.7.7
