From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 13/13] net/mlx5e: Fix blue flame quota logic
Date: Fri, 10 Jun 2016 00:07:40 +0300
Message-ID: <1465506460-1854-14-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34533 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750792AbcFIVKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:10:09 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Blue flame is a latency enhancement feature that allows the driver to
write the packet data directly to the NIC's registers thus making the
read of the packet data from host memory redundant.

We maintain a quota for the blue flame which is reloaded whenever we
identify that the hardware is processing send requests and processes
them fast enough so by the time we post the next send request it was
able to process all the pending ones. This indicates that the hardware
is capable of processing more blue flame requests efficiently. The blue
flame quota is decremented whenever we send using blue flame.

The current code erroneously clears the budget if we did not use blue
flame for the current post send operation and we fix it here.

Fixes: 88a85f99e51f ('net/mlx5e: TX latency optimization to save DMA reads')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 229ab16..b000ddc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -317,7 +317,8 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	while ((sq->pc & wq->sz_m1) > sq->edge)
 		mlx5e_send_nop(sq, false);
 
-	sq->bf_budget = bf ? sq->bf_budget - 1 : 0;
+	if (bf)
+		sq->bf_budget--;
 
 	sq->stats.packets++;
 	sq->stats.bytes += num_bytes;
-- 
2.8.0
