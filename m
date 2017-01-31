From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 2/8] net/mlx5: Configure cache line size for start and end padding
Date: Tue, 31 Jan 2017 22:58:37 +0200
Message-ID: <20170131205843.23235-3-saeedm@mellanox.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60060 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750974AbdAaVFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:05:39 -0500
In-Reply-To: <20170131205843.23235-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

There is a hardware feature that will pad the start or end of a DMA to
be cache line aligned to avoid RMWs on the last cache line. The default
cache line size setting for this feature is 64B. This change configures
the hardware to use 128B alignment on systems with 128B cache lines.

Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 6 ++++++
 include/linux/mlx5/mlx5_ifc.h                  | 6 ++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 84f7970c5080..ca09895b3a05 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -543,6 +543,12 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 
 	MLX5_SET(cmd_hca_cap, set_hca_cap, log_uar_page_sz, PAGE_SHIFT - 12);
 
+	if (MLX5_CAP_GEN_MAX(dev, cache_line_128byte))
+		MLX5_SET(cmd_hca_cap,
+			 set_hca_cap,
+			 cache_line_128byte,
+			 cache_line_size() == 128 ? 1 : 0);
+
 	err = set_caps(dev, set_ctx, set_sz,
 		       MLX5_SET_HCA_CAP_OP_MOD_GENERAL_DEVICE);
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index a919dfb920ae..cc8ae860cd45 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -804,10 +804,12 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         reserved_at_150[0xa];
 	u8         log_max_ra_res_qp[0x6];
 
-	u8         pad_cap[0x1];
+	u8         end_pad[0x1];
 	u8         cc_query_allowed[0x1];
 	u8         cc_modify_allowed[0x1];
-	u8         reserved_at_163[0xd];
+	u8         start_pad[0x1];
+	u8         cache_line_128byte[0x1];
+	u8         reserved_at_163[0xb];
 	u8         gid_table_size[0x10];
 
 	u8         out_of_seq_cnt[0x1];
-- 
2.11.0
