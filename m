From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 01/10] IB/mlx5: Fix kernel to user leak prevention logic
Date: Tue,  3 Jan 2017 23:55:19 +0200
Message-ID: <1483480528-22622-2-git-send-email-saeedm@mellanox.com>
References: <1483480528-22622-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483480528-22622-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

The logic was broken as it failed to update the response length for
architectures with PAGE_SIZE larger than 4kB. As a result further
extension of the ucontext response struct would fail.

Fixes: d69e3bcf7976 ('IB/mlx5: Mmap the HCA's core clock register to user-space')
Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
