From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/6] net/mlx5e: Re-arrange XDP SQ/CQ creation
Date: Fri,  4 Nov 2016 01:48:43 +0200
Message-ID: <1478216927-31328-3-git-send-email-saeedm@mellanox.com>
References: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37672 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933613AbcKCXuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:50:13 -0400
In-Reply-To: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In mlx5e_open_channel CQs must be created before napi is enabled.
Here we move the XDP CQ creation to satisfy that fact.

mlx5e_close_channel is already working according to the right order.

Fixes: b5503b994ed5 ("net/mlx5e: XDP TX forwarding support")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 32 +++++++++++------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c83619d..84e8b25 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1445,6 +1445,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->netdev   = priv->netdev;
 	c->mkey_be  = cpu_to_be32(priv->mdev->mlx5e_res.mkey.key);
 	c->num_tc   = priv->params.num_tc;
+	c->xdp      = !!priv->xdp_prog;
 
 	if (priv->params.rx_am_enabled)
 		rx_cq_profile = mlx5e_am_get_def_profile(priv->params.rx_cq_period_mode);
@@ -1468,6 +1469,12 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	if (err)
 		goto err_close_tx_cqs;
 
+	/* XDP SQ CQ params are same as normal TXQ sq CQ params */
+	err = c->xdp ? mlx5e_open_cq(c, &cparam->tx_cq, &c->xdp_sq.cq,
+				     priv->params.tx_cq_moderation) : 0;
+	if (err)
+		goto err_close_rx_cq;
+
 	napi_enable(&c->napi);
 
 	err = mlx5e_open_sq(c, 0, &cparam->icosq, &c->icosq);
@@ -1488,21 +1495,10 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		}
 	}
 
-	if (priv->xdp_prog) {
-		/* XDP SQ CQ params are same as normal TXQ sq CQ params */
-		err = mlx5e_open_cq(c, &cparam->tx_cq, &c->xdp_sq.cq,
-				    priv->params.tx_cq_moderation);
-		if (err)
-			goto err_close_sqs;
-
-		err = mlx5e_open_sq(c, 0, &cparam->xdp_sq, &c->xdp_sq);
-		if (err) {
-			mlx5e_close_cq(&c->xdp_sq.cq);
-			goto err_close_sqs;
-		}
-	}
+	err = c->xdp ? mlx5e_open_sq(c, 0, &cparam->xdp_sq, &c->xdp_sq) : 0;
+	if (err)
+		goto err_close_sqs;
 
-	c->xdp = !!priv->xdp_prog;
 	err = mlx5e_open_rq(c, &cparam->rq, &c->rq);
 	if (err)
 		goto err_close_xdp_sq;
@@ -1512,10 +1508,8 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 	return 0;
 err_close_xdp_sq:
-	if (priv->xdp_prog) {
+	if (c->xdp)
 		mlx5e_close_sq(&c->xdp_sq);
-		mlx5e_close_cq(&c->xdp_sq.cq);
-	}
 
 err_close_sqs:
 	mlx5e_close_sqs(c);
@@ -1525,6 +1519,10 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 err_disable_napi:
 	napi_disable(&c->napi);
+	if (c->xdp)
+		mlx5e_close_cq(&c->xdp_sq.cq);
+
+err_close_rx_cq:
 	mlx5e_close_cq(&c->rq.cq);
 
 err_close_tx_cqs:
-- 
2.7.4
