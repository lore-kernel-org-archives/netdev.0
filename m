From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Limit the RFS filter IDs to be < RPS_NO_FILTER
Date: Wed, 25 Jul 2012 17:35:07 +0300
Message-ID: <1343226907-31645-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, oren@mellanox.com,
	Amir Vadai <amirv@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Or Gerliz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:56567 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933148Ab2GYOfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 10:35:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

RFS filter id can't have the special value RPS_NO_FILTER, 
need to skip it when allocating id's.

Also, changed an ifdef into a more elegant IS_DEFINED.

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerliz <ogerlitz@mellanox.com>
---

Addressing feedback from Ben Hutchings

 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |    8 ++------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index aa9c2f6..866829b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -77,12 +77,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err = 0;
 	char name[25];
-	struct cpu_rmap *rmap =
-#ifdef CONFIG_RFS_ACCEL
-		priv->dev->rx_cpu_rmap;
-#else
-		NULL;
-#endif
+	struct cpu_rmap *rmap = IS_ENABLED(CONFIG_RFS_ACCEL) ?
+		priv->dev->rx_cpu_rmap : NULL;
 
 	cq->dev = mdev->pndev[priv->port];
 	cq->mcq.set_ci_db  = cq->wqres.db.db;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 8864d8b..edd9cb8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -201,7 +201,7 @@ mlx4_en_filter_alloc(struct mlx4_en_priv *priv, int rxq_index, __be32 src_ip,
 
 	filter->flow_id = flow_id;
 
-	filter->id = priv->last_filter_id++;
+	filter->id = priv->last_filter_id++ % RPS_NO_FILTER;
 
 	list_add_tail(&filter->next, &priv->filters);
 	hlist_add_head(&filter->filter_chain,
-- 
1.7.8.2
