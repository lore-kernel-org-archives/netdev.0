From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4: Cache line CQE/EQE stride fixes
Date: Tue, 16 Dec 2014 13:28:54 +0200
Message-ID: <1418729334-2974-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, clsoto@linux.vnet.ibm.com,
	Ido Shamay <idos@mellanox.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:56671 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750885AbaLPL3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 06:29:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

This commit contains 2 fixes for the 128B CQE/EQE stride feaure.
Wei found that mlx4_QUERY_HCA function marked the wrong capability
in flags (64B CQE/EQE), when CQE/EQE stride feature was enabled.
Also added small fix in initial CQE ownership bit assignment, when CQE
is size is not default 32B.

Fixes: 77507aa24 (net/mlx4: Enable CQE/EQE stride support)
Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
Dave Hi,

Please pull this patch also to stable (at least 3.17)

Thanks,
Amir

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 11 +++++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.c        |  4 ++--
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 6ff214d..190cbd9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1569,8 +1569,15 @@ int mlx4_en_start_port(struct net_device *dev)
 			mlx4_en_free_affinity_hint(priv, i);
 			goto cq_err;
 		}
-		for (j = 0; j < cq->size; j++)
-			cq->buf[j].owner_sr_opcode = MLX4_CQE_OWNER_MASK;
+
+		for (j = 0; j < cq->size; j++) {
+			struct mlx4_cqe *cqe = NULL;
+
+			cqe = mlx4_en_get_cqe(cq->buf, j, priv->cqe_size) +
+			      priv->cqe_factor;
+			cqe->owner_sr_opcode = MLX4_CQE_OWNER_MASK;
+		}
+
 		err = mlx4_en_set_cq_moder(priv, cq);
 		if (err) {
 			en_err(priv, "Failed setting cq moderation parameters\n");
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index ef3b95b..32c848d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1848,8 +1848,8 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 	/* CX3 is capable of extending CQEs\EQEs to strides larger than 64B */
 	MLX4_GET(byte_field, outbox, INIT_HCA_EQE_CQE_STRIDE_OFFSET);
 	if (byte_field) {
-		param->dev_cap_enabled |= MLX4_DEV_CAP_64B_EQE_ENABLED;
-		param->dev_cap_enabled |= MLX4_DEV_CAP_64B_CQE_ENABLED;
+		param->dev_cap_enabled |= MLX4_DEV_CAP_EQE_STRIDE_ENABLED;
+		param->dev_cap_enabled |= MLX4_DEV_CAP_CQE_STRIDE_ENABLED;
 		param->cqe_size = 1 << ((byte_field &
 					 MLX4_CQE_SIZE_MASK_STRIDE) + 5);
 		param->eqe_size = 1 << (((byte_field &
-- 
1.8.3.1
