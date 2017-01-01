From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 06/11] IB/mlx5: Add support for big MRs
Date: Sun,  1 Jan 2017 23:10:22 +0200
Message-ID: <1483305027-2573-7-git-send-email-saeedm@mellanox.com>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42842 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932468AbdAAVKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 16:10:50 -0500
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

Make use of extended UMR translation offset.

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/mlx5_ib.h | 1 +
 drivers/infiniband/hw/mlx5/mr.c      | 8 +++++---
 drivers/infiniband/hw/mlx5/odp.c     | 5 +++++
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index d79580d..73bff77 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -634,6 +634,7 @@ struct mlx5_ib_dev {
 	int				fill_delay;
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	struct ib_odp_caps	odp_caps;
+	u64			odp_max_size;
 	/*
 	 * Sleepable RCU that prevents destruction of MRs while they are still
 	 * being used by a page fault handler.
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 738ba13..271b78e 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1121,8 +1121,9 @@ static struct mlx5_ib_mr *reg_create(struct ib_mr *ibmr, struct ib_pd *pd,
 		goto err_1;
 	}
 	pas = (__be64 *)MLX5_ADDR_OF(create_mkey_in, in, klm_pas_mtt);
-	mlx5_ib_populate_pas(dev, umem, page_shift, pas,
-			     pg_cap ? MLX5_IB_MTT_PRESENT : 0);
+	if (!(access_flags & IB_ACCESS_ON_DEMAND))
+		mlx5_ib_populate_pas(dev, umem, page_shift, pas,
+				     pg_cap ? MLX5_IB_MTT_PRESENT : 0);
 
 	/* The pg_access bit allows setting the access flags
 	 * in the page list submitted with the command. */
@@ -1210,7 +1211,8 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 			mlx5_ib_dbg(dev, "cache empty for order %d", order);
 			mr = NULL;
 		}
-	} else if (access_flags & IB_ACCESS_ON_DEMAND) {
+	} else if (access_flags & IB_ACCESS_ON_DEMAND &&
+		   !MLX5_CAP_GEN(dev->mdev, umr_extended_translation_offset)) {
 		err = -EINVAL;
 		pr_err("Got MR registration for ODP MR > 512MB, not supported for Connect-IB");
 		goto error;
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 67651ec..1e73c12 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -121,6 +121,11 @@ void mlx5_ib_internal_fill_odp_caps(struct mlx5_ib_dev *dev)
 
 	caps->general_caps = IB_ODP_SUPPORT;
 
+	if (MLX5_CAP_GEN(dev->mdev, umr_extended_translation_offset))
+		dev->odp_max_size = U64_MAX;
+	else
+		dev->odp_max_size = BIT_ULL(MLX5_MAX_UMR_SHIFT + PAGE_SHIFT);
+
 	if (MLX5_CAP_ODP(dev->mdev, ud_odp_caps.send))
 		caps->per_transport_caps.ud_odp_caps |= IB_ODP_SUPPORT_SEND;
 
-- 
2.7.4
