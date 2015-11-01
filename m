From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/8] net/mlx5e: Wait for RX buffers initialization in a more proper manner
Date: Sun,  1 Nov 2015 19:35:16 +0200
Message-ID: <1446399322-14046-3-git-send-email-ogerlitz@mellanox.com>
References: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56257 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752448AbbKARfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2015 12:35:46 -0500
In-Reply-To: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Use jiffies rather than wait loop with msleep().

The wait loop didn't take into consideration time when the
process was not executing.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9df6f9a..0bab33c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -442,12 +442,12 @@ static void mlx5e_disable_rq(struct mlx5e_rq *rq)
 
 static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
 {
+	unsigned long exp_time = jiffies + msecs_to_jiffies(20000);
 	struct mlx5e_channel *c = rq->channel;
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_wq_ll *wq = &rq->wq;
-	int i;
 
-	for (i = 0; i < 1000; i++) {
+	while (time_before(jiffies, exp_time)) {
 		if (wq->cur_sz >= priv->params.min_rx_wqes)
 			return 0;
 
-- 
2.3.7
