From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 3/5] mlx4_en: Assign dummy event handler for TX queue
Date: Mon, 20 Apr 2009 17:30:03 +0300
Message-ID: <49EC86EB.1000004@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49480 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755479AbZDTObG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 10:31:06 -0400
In-Reply-To: <49EC859C.700@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The low level driver always assumes this handler exists.
The lack of it could cause kernel panic

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_resources.c |    6 ++++++
 drivers/net/mlx4/en_rx.c        |    6 ------
 drivers/net/mlx4/en_tx.c        |    1 +
 drivers/net/mlx4/mlx4_en.h      |    1 +
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/mlx4/en_resources.c b/drivers/net/mlx4/en_resources.c
index a054520..65ca706 100644
--- a/drivers/net/mlx4/en_resources.c
+++ b/drivers/net/mlx4/en_resources.c
@@ -94,3 +94,9 @@ void mlx4_en_unmap_buffer(struct mlx4_buf *buf)

 	vunmap(buf->direct.buf);
 }
+
+void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event)
+{
+    return;
+}
+
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 8673008..0cbb78c 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -928,12 +928,6 @@ void mlx4_en_set_default_rss_map(struct mlx4_en_priv *priv,
 	}
 }

-static void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event)
-{
-    return;
-}
-
-
 static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv,
 				 int qpn, int srqn, int cqn,
 				 enum mlx4_qp_state *state,
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 4afd599..ac6fc49 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -112,6 +112,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 		mlx4_err(mdev, "Failed allocating qp %d\n", ring->qpn);
 		goto err_reserve;
 	}
+	ring->qp.event = mlx4_en_sqp_event;

 	return 0;

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index e9af32d..ef840ab 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -538,6 +538,7 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 			     int is_tx, int rss, int qpn, int cqn, int srqn,
 			     struct mlx4_qp_context *context);
+void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event);
 int mlx4_en_map_buffer(struct mlx4_buf *buf);
 void mlx4_en_unmap_buffer(struct mlx4_buf *buf);

-- 
1.5.4


