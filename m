From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 10/23 v3] mlx4_core: associate resources with specific functions
Date: Thu, 04 Feb 2010 17:55:40 +0200
Message-ID: <4B6AEDFC.2060406@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49708 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933120Ab0BDPzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:55:43 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resources are associated with functions by means of pds - the upper 7 msbs
specify the function id. Since cqs do not refer to a specific pd, the function
id is passed explicitly to hw in the cq context.
For uars, which are statically partitioned between slaves, we only need to adjust
their offsets with respect to the associated function bar.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cq.c |    4 +++-
 drivers/net/mlx4/pd.c |   12 +++++++++---
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mlx4/cq.c b/drivers/net/mlx4/cq.c
index 3fb9f7f..9f9f246 100644
--- a/drivers/net/mlx4/cq.c
+++ b/drivers/net/mlx4/cq.c
@@ -59,7 +59,8 @@ struct mlx4_cq_context {
 	__be32			solicit_producer_index;
 	__be32			consumer_index;
 	__be32			producer_index;
-	u32			reserved4[2];
+	__be32			pd; /* for sriov guest id */
+	u32			reserved4;
 	__be64			db_rec_addr;
 };
 
@@ -293,6 +294,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 	mtt_addr = mlx4_mtt_addr(dev, mtt);
 	cq_context->mtt_base_addr_h = mtt_addr >> 32;
 	cq_context->mtt_base_addr_l = cpu_to_be32(mtt_addr & 0xffffffff);
+	cq_context->pd = cpu_to_be32(dev->caps.pd_base << dev->caps.slave_pd_shift);
 	cq_context->db_rec_addr     = cpu_to_be64(db_rec);
 
 	err = mlx4_SW2HW_CQ(dev, mailbox, cq->cqn);
diff --git a/drivers/net/mlx4/pd.c b/drivers/net/mlx4/pd.c
index c4988d6..08eaf08 100644
--- a/drivers/net/mlx4/pd.c
+++ b/drivers/net/mlx4/pd.c
@@ -45,7 +45,7 @@ int mlx4_pd_alloc(struct mlx4_dev *dev, u32 *pdn)
 	*pdn = mlx4_bitmap_alloc(&priv->pd_bitmap);
 	if (*pdn == -1)
 		return -ENOMEM;
-
+	*pdn |= dev->caps.pd_base << dev->caps.slave_pd_shift;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_pd_alloc);
@@ -72,12 +72,18 @@ void mlx4_cleanup_pd_table(struct mlx4_dev *dev)
 
 int mlx4_uar_alloc(struct mlx4_dev *dev, struct mlx4_uar *uar)
 {
+	int offset;
+
 	uar->index = mlx4_bitmap_alloc(&mlx4_priv(dev)->uar_table.bitmap);
 	if (uar->index == -1)
 		return -ENOMEM;
 
-	uar->pfn = (pci_resource_start(dev->pdev, 2) >> PAGE_SHIFT) + uar->index;
-
+	if (mlx4_is_slave(dev))
+		offset = uar->index % ((int) pci_resource_len(dev->pdev, 2) /
+				       dev->caps.uar_page_size);
+	else
+		offset = uar->index;
+	uar->pfn = (pci_resource_start(dev->pdev, 2) >> PAGE_SHIFT) + offset;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_uar_alloc);
-- 
1.6.1.3


