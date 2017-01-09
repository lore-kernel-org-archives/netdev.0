From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next V3 04/10] IB/mlx5: Fix retrieval of index to first hi class bfreg
Date: Mon,  9 Jan 2017 21:00:47 +0200
Message-ID: <1483988453-28551-5-git-send-email-saeedm@mellanox.com>
References: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Eli Cohen <eli@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51989 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1761705AbdAITBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:01:07 -0500
In-Reply-To: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

First the function retrieving the index of the first hi latency class
blue flame register. High latency class bfregs are located right above
medium latency class bfregs.

Fixes: c1be5232d21d ('IB/mlx5: Fix micro UAR allocator')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index fbea9bd..240fbb0 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -490,12 +490,21 @@ static int next_bfreg(int n)
 	return n;
 }
 
+enum {
+	/* this is the first blue flame register in the array of bfregs assigned
+	 * to a processes. Since we do not use it for blue flame but rather
+	 * regular 64 bit doorbells, we do not need a lock for maintaiing
+	 * "odd/even" order
+	 */
+	NUM_NON_BLUE_FLAME_BFREGS = 1,
+};
+
 static int num_med_bfreg(struct mlx5_bfreg_info *bfregi)
 {
 	int n;
 
 	n = bfregi->num_uars * MLX5_NON_FP_BFREGS_PER_UAR -
-		bfregi->num_low_latency_bfregs - 1;
+		bfregi->num_low_latency_bfregs - NUM_NON_BLUE_FLAME_BFREGS;
 
 	return n >= 0 ? n : 0;
 }
@@ -508,17 +517,9 @@ static int max_bfregi(struct mlx5_bfreg_info *bfregi)
 static int first_hi_bfreg(struct mlx5_bfreg_info *bfregi)
 {
 	int med;
-	int i;
-	int t;
 
 	med = num_med_bfreg(bfregi);
-	for (t = 0, i = first_med_bfreg();; i = next_bfreg(i)) {
-		t++;
-		if (t == med)
-			return next_bfreg(i);
-	}
-
-	return 0;
+	return next_bfreg(med);
 }
 
 static int alloc_high_class_bfreg(struct mlx5_bfreg_info *bfregi)
@@ -544,6 +545,8 @@ static int alloc_med_class_bfreg(struct mlx5_bfreg_info *bfregi)
 	for (i = first_med_bfreg(); i < first_hi_bfreg(bfregi); i = next_bfreg(i)) {
 		if (bfregi->count[i] < bfregi->count[minidx])
 			minidx = i;
+		if (!bfregi->count[minidx])
+			break;
 	}
 
 	bfregi->count[minidx]++;
@@ -558,6 +561,7 @@ static int alloc_bfreg(struct mlx5_bfreg_info *bfregi,
 	mutex_lock(&bfregi->lock);
 	switch (lat) {
 	case MLX5_IB_LATENCY_CLASS_LOW:
+		BUILD_BUG_ON(NUM_NON_BLUE_FLAME_BFREGS != 1);
 		bfregn = 0;
 		bfregi->count[bfregn]++;
 		break;
-- 
2.7.4
