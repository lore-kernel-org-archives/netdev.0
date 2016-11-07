From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 08/13] net/mlx5: Check max encap header size capability
Date: Mon,  7 Nov 2016 15:14:43 +0200
Message-ID: <1478524488-1377-9-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39585 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753427AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Instead of comparing to a const value, check the value of max encap
header size capability as reported by the Firmware.

Fixes: 575ddf5888ea ('net/mlx5: Introduce alloc_encap and dealloc_encap commands')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 26 +++++++++++++++---------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 6c9d99a..301cec8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -453,27 +453,32 @@ void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
 	*bytes = MLX5_GET64(traffic_counter, stats, octets);
 }
 
-#define MAX_ENCAP_SIZE (128)
-
 int mlx5_encap_alloc(struct mlx5_core_dev *dev,
 		     int header_type,
 		     size_t size,
 		     void *encap_header,
 		     u32 *encap_id)
 {
+	int max_encap_size = MLX5_CAP_ESW(dev, max_encap_header_size);
 	u32 out[MLX5_ST_SZ_DW(alloc_encap_header_out)];
-	u32 in[MLX5_ST_SZ_DW(alloc_encap_header_in) +
-	      (MAX_ENCAP_SIZE / sizeof(u32))];
-	void *encap_header_in = MLX5_ADDR_OF(alloc_encap_header_in, in,
-					     encap_header);
-	void *header = MLX5_ADDR_OF(encap_header_in, encap_header_in,
-				    encap_header);
-	int inlen = header - (void *)in  + size;
+	void *encap_header_in;
+	void *header;
+	int inlen;
 	int err;
+	u32 *in;
 
-	if (size > MAX_ENCAP_SIZE)
+	if (size > MLX5_CAP_ESW(dev, max_encap_header_size))
 		return -EINVAL;
 
+	in = kzalloc(MLX5_ST_SZ_BYTES(alloc_encap_header_in) + max_encap_size,
+		     GFP_KERNEL);
+	if (!in)
+		return -ENOMEM;
+
+	encap_header_in = MLX5_ADDR_OF(alloc_encap_header_in, in, encap_header);
+	header = MLX5_ADDR_OF(encap_header_in, encap_header_in, encap_header);
+	inlen = header - (void *)in  + size;
+
 	memset(in, 0, inlen);
 	MLX5_SET(alloc_encap_header_in, in, opcode,
 		 MLX5_CMD_OP_ALLOC_ENCAP_HEADER);
@@ -485,6 +490,7 @@ int mlx5_encap_alloc(struct mlx5_core_dev *dev,
 	err = mlx5_cmd_exec(dev, in, inlen, out, sizeof(out));
 
 	*encap_id = MLX5_GET(alloc_encap_header_out, out, encap_id);
+	kfree(in);
 	return err;
 }
 
-- 
2.7.4
