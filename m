From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next V3 01/10] IB/mlx5: Fix kernel to user leak prevention logic
Date: Mon,  9 Jan 2017 21:00:44 +0200
Message-ID: <1483988453-28551-2-git-send-email-saeedm@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51975 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1761751AbdAITBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:01:07 -0500
In-Reply-To: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

The logic was broken as it failed to update the response length for
architectures with PAGE_SIZE larger than 4kB. As a result further
extension of the ucontext response struct would fail.

Fixes: d69e3bcf7976 ('IB/mlx5: Mmap the HCA's core clock register to user-space')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 86c61e7..852b5b7 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1148,13 +1148,13 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	 * pretend we don't support reading the HCA's core clock. This is also
 	 * forced by mmap function.
 	 */
-	if (PAGE_SIZE <= 4096 &&
-	    field_avail(typeof(resp), hca_core_clock_offset, udata->outlen)) {
-		resp.comp_mask |=
-			MLX5_IB_ALLOC_UCONTEXT_RESP_MASK_CORE_CLOCK_OFFSET;
-		resp.hca_core_clock_offset =
-			offsetof(struct mlx5_init_seg, internal_timer_h) %
-			PAGE_SIZE;
+	if (field_avail(typeof(resp), hca_core_clock_offset, udata->outlen)) {
+		if (PAGE_SIZE <= 4096) {
+			resp.comp_mask |=
+				MLX5_IB_ALLOC_UCONTEXT_RESP_MASK_CORE_CLOCK_OFFSET;
+			resp.hca_core_clock_offset =
+				offsetof(struct mlx5_init_seg, internal_timer_h) % PAGE_SIZE;
+		}
 		resp.response_length += sizeof(resp.hca_core_clock_offset) +
 					sizeof(resp.reserved2);
 	}
-- 
2.7.4
