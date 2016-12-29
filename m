From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/5] net/mlx4_en: Fix bad WQE issue
Date: Thu, 29 Dec 2016 18:37:10 +0200
Message-ID: <1483029433-3624-3-git-send-email-tariqt@mellanox.com>
References: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51877 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752869AbcL2Qh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 11:37:58 -0500
In-Reply-To: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Single send WQE in RX buffer should be stamped with software
ownership in order to prevent the flow of QP in error in FW
once UPDATE_QP is called.


Fixes: 9f519f68cfff ('mlx4_en: Not using Shared Receive Queues')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 3c37e216bbf3..eac527e25ec9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -445,8 +445,14 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		ring->cqn = priv->rx_cq[ring_ind]->mcq.cqn;
 
 		ring->stride = stride;
-		if (ring->stride <= TXBB_SIZE)
+		if (ring->stride <= TXBB_SIZE) {
+			/* Stamp first unused send wqe */
+			__be32 *ptr = (__be32 *)ring->buf;
+			__be32 stamp = cpu_to_be32(1 << STAMP_SHIFT);
+			*ptr = stamp;
+			/* Move pointer to start of rx section */
 			ring->buf += TXBB_SIZE;
+		}
 
 		ring->log_stride = ffs(ring->stride) - 1;
 		ring->buf_size = ring->size * ring->stride;
-- 
1.8.3.1
