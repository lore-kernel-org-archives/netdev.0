From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4_en: Restoring RX buffer pointer in case of failure
Date: Thu, 7 Apr 2011 12:25:45 +0300
Message-ID: <4D9D8319.4030208@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:56588 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751646Ab1DGJZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 05:25:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If not done, second attempt to open the RX ring would cause memory corruption.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_rx.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index a0423eb..33edecb 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -345,6 +345,8 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		err = mlx4_en_init_allocator(priv, ring);
 		if (err) {
 			en_err(priv, "Failed initializing ring allocator\n");
+			if (ring->stride <= TXBB_SIZE)
+				ring->buf -= TXBB_SIZE;
 			ring_ind--;
 			goto err_allocator;
 		}
@@ -369,6 +371,8 @@ err_buffers:
 	ring_ind = priv->rx_ring_num - 1;
 err_allocator:
 	while (ring_ind >= 0) {
+		if (priv->rx_ring[ring_ind].stride <= TXBB_SIZE)
+			priv->rx_ring[ring_ind].buf -= TXBB_SIZE;
 		mlx4_en_destroy_allocator(priv, &priv->rx_ring[ring_ind]);
 		ring_ind--;
 	}
-- 
1.6.0.2



