From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 08/11] net/mlx5: Update PAGE_FAULT_RESUME layout
Date: Sun,  1 Jan 2017 23:10:24 +0200
Message-ID: <1483305027-2573-9-git-send-email-saeedm@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42858 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932488AbdAAVKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 16:10:50 -0500
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

Update PAGE_FAULT_RESUME command layout.

Three bit fields describing page fault: rdma, rdma_write, req_res gave 8
possible combinations, while only a few were legal. Now they
are interpreted as three-bit type field, where former legal
combinations turns into corresponding types and unused were added as new
types.

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/qp.c | 10 ++--------
 include/linux/mlx5/mlx5_ifc.h                |  9 ++++-----
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index d0a4005..5378a5f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -515,14 +515,8 @@ int mlx5_core_page_fault_resume(struct mlx5_core_dev *dev, u32 qpn,
 
 	MLX5_SET(page_fault_resume_in, in, opcode,
 		 MLX5_CMD_OP_PAGE_FAULT_RESUME);
-	MLX5_SET(page_fault_resume_in, in, qpn, qpn);
-
-	if (flags & MLX5_PAGE_FAULT_RESUME_REQUESTOR)
-		MLX5_SET(page_fault_resume_in, in, req_res, 1);
-	if (flags & MLX5_PAGE_FAULT_RESUME_WRITE)
-		MLX5_SET(page_fault_resume_in, in, read_write, 1);
-	if (flags & MLX5_PAGE_FAULT_RESUME_RDMA)
-		MLX5_SET(page_fault_resume_in, in, rdma, 1);
+	MLX5_SET(page_fault_resume_in, in, wq_number, qpn);
+	MLX5_SET(page_fault_resume_in, in, page_fault_type, flags);
 	if (error)
 		MLX5_SET(page_fault_resume_in, in, error, 1);
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 7c760e5..608dc98 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -4775,12 +4775,11 @@ struct mlx5_ifc_page_fault_resume_in_bits {
 
 	u8         error[0x1];
 	u8         reserved_at_41[0x4];
-	u8         rdma[0x1];
-	u8         read_write[0x1];
-	u8         req_res[0x1];
-	u8         qpn[0x18];
+	u8         page_fault_type[0x3];
+	u8         wq_number[0x18];
 
-	u8         reserved_at_60[0x20];
+	u8         reserved_at_60[0x8];
+	u8         token[0x18];
 };
 
 struct mlx5_ifc_nop_out_bits {
-- 
2.7.4
