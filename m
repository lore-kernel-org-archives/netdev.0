From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 5/8] net/mlx5e: Fix warnings around parsing of TC pedit actions
Date: Tue, 23 May 2017 17:16:07 +0300
Message-ID: <20170523141610.27833-6-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44679 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936349AbdEWOQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:37 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The sparse tool emits these correct complaints:

drivers/net/ethernet/mellanox/mlx5/core//en_tc.c:1005:25: warning: cast to restricted __be32
drivers/net/ethernet/mellanox/mlx5/core//en_tc.c:1007:25: warning: cast to restricted __be16

The value is provided from user-space in network order, but there's
no way for them to realize that, avoid the warnings by casting to the
appropriate type.

Fixes: d79b6df6b10a ('net/mlx5e: Add parsing of TC pedit actions to HW format')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 0387c321f0a2..ec63158ab643 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -928,9 +928,9 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 	struct pedit_headers *set_masks, *add_masks, *set_vals, *add_vals;
 	int i, action_size, nactions, max_actions, first, last, first_z;
 	void *s_masks_p, *a_masks_p, *vals_p;
-	u32 s_mask, a_mask, val;
 	struct mlx5_fields *f;
 	u8 cmd, field_bsize;
+	u32 s_mask, a_mask;
 	unsigned long mask;
 	void *action;
 
@@ -947,7 +947,8 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 	for (i = 0; i < ARRAY_SIZE(fields); i++) {
 		f = &fields[i];
 		/* avoid seeing bits set from previous iterations */
-		s_mask = a_mask = mask = val = 0;
+		s_mask = 0;
+		a_mask = 0;
 
 		s_masks_p = (void *)set_masks + f->offset;
 		a_masks_p = (void *)add_masks + f->offset;
@@ -982,9 +983,8 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 			memset(a_masks_p, 0, f->size);
 		}
 
-		memcpy(&val, vals_p, f->size);
-
 		field_bsize = f->size * BITS_PER_BYTE;
+
 		first_z = find_first_zero_bit(&mask, field_bsize);
 		first = find_first_bit(&mask, field_bsize);
 		last  = find_last_bit(&mask, field_bsize);
@@ -1004,11 +1004,11 @@ static int offload_pedit_fields(struct pedit_headers *masks,
 		}
 
 		if (field_bsize == 32)
-			MLX5_SET(set_action_in, action, data, ntohl(val));
+			MLX5_SET(set_action_in, action, data, ntohl(*(__be32 *)vals_p));
 		else if (field_bsize == 16)
-			MLX5_SET(set_action_in, action, data, ntohs(val));
+			MLX5_SET(set_action_in, action, data, ntohs(*(__be16 *)vals_p));
 		else if (field_bsize == 8)
-			MLX5_SET(set_action_in, action, data, val);
+			MLX5_SET(set_action_in, action, data, *(u8 *)vals_p);
 
 		action += action_size;
 		nactions++;
-- 
2.11.0
