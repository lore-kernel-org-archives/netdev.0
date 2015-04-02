From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 05/16] net/mlx5_core: Clear doorbell record inside mlx5_db_alloc()
Date: Thu,  2 Apr 2015 17:07:23 +0300
Message-ID: <1427983654-971-6-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36590 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDBOH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:07:56 -0400
Received: by wizk4 with SMTP id k4so16537060wiz.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:55 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Do it in one place instead of every where the function is invoked

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/cq.c                 | 2 --
 drivers/infiniband/hw/mlx5/qp.c                 | 3 ---
 drivers/infiniband/hw/mlx5/srq.c                | 2 --
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c | 3 +++
 4 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index c463e7bba5f4..f78249c48173 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -697,8 +697,6 @@ static int create_cq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_cq *cq,
 
 	cq->mcq.set_ci_db  = cq->db.db;
 	cq->mcq.arm_db     = cq->db.db + 1;
-	*cq->mcq.set_ci_db = 0;
-	*cq->mcq.arm_db    = 0;
 	cq->mcq.cqe_sz = cqe_size;
 
 	err = alloc_cq_buf(dev, &cq->buf, entries, cqe_size);
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 859c136911e0..c2f43d378cb5 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -796,9 +796,6 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 		goto err_free;
 	}
 
-	qp->db.db[0] = 0;
-	qp->db.db[1] = 0;
-
 	qp->sq.wrid = kmalloc(qp->sq.wqe_cnt * sizeof(*qp->sq.wrid), GFP_KERNEL);
 	qp->sq.wr_data = kmalloc(qp->sq.wqe_cnt * sizeof(*qp->sq.wr_data), GFP_KERNEL);
 	qp->rq.wrid = kmalloc(qp->rq.wqe_cnt * sizeof(*qp->rq.wrid), GFP_KERNEL);
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 41fec66217dd..90bc9ff62fe7 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -165,8 +165,6 @@ static int create_srq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_srq *srq,
 		return err;
 	}
 
-	*srq->db.db = 0;
-
 	if (mlx5_buf_alloc(dev->mdev, buf_size, PAGE_SIZE * 2, &srq->buf)) {
 		mlx5_ib_dbg(dev, "buf alloc failed\n");
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 201ca6d76ce5..63dd75485204 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -171,6 +171,9 @@ static int mlx5_alloc_db_from_pgdir(struct mlx5_db_pgdir *pgdir,
 	db->db      = pgdir->db_page + offset / sizeof(*pgdir->db_page);
 	db->dma     = pgdir->db_dma  + offset;
 
+	db->db[0] = 0;
+	db->db[1] = 0;
+
 	return 0;
 }
 
-- 
2.3.1
