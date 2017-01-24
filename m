From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/12] IB/mlx5: Enable Eth VFs to query their min-inline value for user-space
Date: Tue, 24 Jan 2017 22:16:50 +0200
Message-ID: <20170124201652.2920-11-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54289 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751082AbdAXURf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:35 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

For some mlx5 HW models (CX4, CX4Lx), the VF driver needs to put part
of the packet headers on the TX descriptor so the e-switch can do proper
matching and steering. This is called "min-inline", it's advertized to
the VF by the FW and also enforced on them by the HW, such that if they
don't obey, their packets are dropped.

SRIOV VF libmlx5 instances should take into account the min-inline
value of their vports. For that end, we provide this value through
the vendor response part of init_ucontext command.

The min inline value is reported in a way which will let newer libmlx5
instances realize that they are running over an older kernel and act
accordingly (e.g apply some educated guess).

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c |  9 +++++++++
 include/uapi/rdma/mlx5-abi.h      | 14 +++++++++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 8727116a4cab..9d8535385bb8 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -53,6 +53,7 @@
 #include <linux/in.h>
 #include <linux/etherdevice.h>
 #include <linux/mlx5/fs.h>
+#include <linux/mlx5/vport.h>
 #include "mlx5_ib.h"
 
 #define DRIVER_NAME "mlx5_ib"
@@ -1202,6 +1203,14 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 		resp.response_length += sizeof(resp.cmds_supp_uhw);
 	}
 
+	if (field_avail(typeof(resp), eth_min_inline, udata->outlen)) {
+		if (mlx5_ib_port_link_layer(ibdev, 1) == IB_LINK_LAYER_ETHERNET) {
+			mlx5_query_min_inline(dev->mdev, &resp.eth_min_inline);
+			resp.eth_min_inline++;
+		}
+		resp.response_length += sizeof(resp.eth_min_inline);
+	}
+
 	/*
 	 * We don't want to expose information from the PCI bar that is located
 	 * after 4096 bytes, so if the arch only supports larger pages, let's
diff --git a/include/uapi/rdma/mlx5-abi.h b/include/uapi/rdma/mlx5-abi.h
index 85dc966ea70b..da7cd62bace7 100644
--- a/include/uapi/rdma/mlx5-abi.h
+++ b/include/uapi/rdma/mlx5-abi.h
@@ -90,6 +90,17 @@ enum mlx5_user_cmds_supp_uhw {
 	MLX5_USER_CMDS_SUPP_UHW_CREATE_AH    = 1 << 1,
 };
 
+/* The eth_min_inline response value is set to off-by-one vs the FW
+ * returned value to allow user-space to deal with older kernels.
+ */
+enum mlx5_user_inline_mode {
+	MLX5_USER_INLINE_MODE_NA,
+	MLX5_USER_INLINE_MODE_NONE,
+	MLX5_USER_INLINE_MODE_L2,
+	MLX5_USER_INLINE_MODE_IP,
+	MLX5_USER_INLINE_MODE_TCP_UDP,
+};
+
 struct mlx5_ib_alloc_ucontext_resp {
 	__u32	qp_tab_size;
 	__u32	bf_reg_size;
@@ -106,7 +117,8 @@ struct mlx5_ib_alloc_ucontext_resp {
 	__u32	response_length;
 	__u8	cqe_version;
 	__u8	cmds_supp_uhw;
-	__u16	reserved2;
+	__u8	eth_min_inline;
+	__u8	reserved2;
 	__u64	hca_core_clock_offset;
 	__u32	log_uar_size;
 	__u32	num_uars_per_page;
-- 
2.11.0
