From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 02/11] IB/mlx5: Reorder code in query device command
Date: Mon,  2 Jan 2017 11:37:39 +0200
Message-ID: <1483349868-11716-3-git-send-email-saeedm@mellanox.com>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34471 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932506AbdABJiX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 04:38:23 -0500
In-Reply-To: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leon@kernel.org>

The order of features exposed by private mlx5-abi.h
file is CQE zipping, packet pacing and multi-packet WQE.

The internal order implemented in mlx5_ib_query_device() is
multi-packet WQE, CQE zipping and packet pacing.

Such difference hurts code readability, so let's sync,
while mlx5-abi.h (exposed to userspace) is the primary
order.

This commit doesn't change any functionality.

Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d566f67..2ab4e32 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -672,17 +672,6 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 			1 << MLX5_CAP_GEN(dev->mdev, log_max_rq);
 	}
 
-	if (field_avail(typeof(resp), mlx5_ib_support_multi_pkt_send_wqes,
-			uhw->outlen)) {
-		resp.mlx5_ib_support_multi_pkt_send_wqes =
-			MLX5_CAP_ETH(mdev, multi_pkt_send_wqe);
-		resp.response_length +=
-			sizeof(resp.mlx5_ib_support_multi_pkt_send_wqes);
-	}
-
-	if (field_avail(typeof(resp), reserved, uhw->outlen))
-		resp.response_length += sizeof(resp.reserved);
-
 	if (field_avail(typeof(resp), cqe_comp_caps, uhw->outlen)) {
 		resp.cqe_comp_caps.max_num =
 			MLX5_CAP_GEN(dev->mdev, cqe_compression) ?
@@ -706,6 +695,17 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 		resp.response_length += sizeof(resp.packet_pacing_caps);
 	}
 
+	if (field_avail(typeof(resp), mlx5_ib_support_multi_pkt_send_wqes,
+			uhw->outlen)) {
+		resp.mlx5_ib_support_multi_pkt_send_wqes =
+			MLX5_CAP_ETH(mdev, multi_pkt_send_wqe);
+		resp.response_length +=
+			sizeof(resp.mlx5_ib_support_multi_pkt_send_wqes);
+	}
+
+	if (field_avail(typeof(resp), reserved, uhw->outlen))
+		resp.response_length += sizeof(resp.reserved);
+
 	if (uhw->outlen) {
 		err = ib_copy_to_udata(uhw, &resp, resp.response_length);
 
-- 
2.7.4
