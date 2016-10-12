From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH V2 net-next] net/mlx5: Add MLX5_ARRAY_SET64 to fix BUILD_BUG_ON
Date: Wed, 12 Oct 2016 04:57:10 +0300
Message-ID: <1476237430-11756-1-git-send-email-saeedm@mellanox.com>
Cc: Leon Romanovsky <leonro@mellanox.com>,
        David Laight <David.Laight@aculab.com>, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52930 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753185AbcJLCED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 22:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>

I am hitting this in mlx5:

drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
reclaim_pages_cmd.clone.0:
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:346: error: call
to __compiletime_assert_346 declared with attribute error:
BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_out, pas[i]) % 64
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function give_pages:
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:291: error: call
to __compiletime_assert_291 declared with attribute error:
BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_in, pas[i]) % 64

Problem is that this is doing a BUILD_BUG_ON on a non-constant
expression because of trying to take offset of pas[i] in the
structure.

Fix is to create MLX5_ARRAY_SET64 that takes an additional argument
that is the field index to separate between BUILD_BUG_ON on the array
constant field and the indexed field to assign the value to.
There are two callers of MLX5_SET64 that are trying to get a variable
offset, change those to call MLX5_ARRAY_SET64 passing 'pas' and 'i'
as the arguments to use in the offset check and the indexed value
assignment.

Fixes: a533ed5e179cd ("net/mlx5: Pages management commands via mlx5 ifc")
Signed-off-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---

Hi Dave,

I hope this version of this patch will make it to -rc1, I made
some changes to the original version Tom submitted.  Following David Laight
suggestion to separate the array index from the constant array field to have
a more natural API.

Thanks,
Saeed.


 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c |  4 ++--
 include/linux/mlx5/device.h                         | 13 +++++++++++--
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index d458515..cc4fd61 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -287,7 +287,7 @@ retry:
 
 			goto retry;
 		}
-		MLX5_SET64(manage_pages_in, in, pas[i], addr);
+		MLX5_ARRAY_SET64(manage_pages_in, in, pas, i, addr);
 	}
 
 	MLX5_SET(manage_pages_in, in, opcode, MLX5_CMD_OP_MANAGE_PAGES);
@@ -344,7 +344,7 @@ static int reclaim_pages_cmd(struct mlx5_core_dev *dev,
 		if (fwp->func_id != func_id)
 			continue;
 
-		MLX5_SET64(manage_pages_out, out, pas[i], fwp->addr);
+		MLX5_ARRAY_SET64(manage_pages_out, out, pas, i, fwp->addr);
 		i++;
 	}
 
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 77c1417..5827614 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -92,12 +92,21 @@ __mlx5_mask(typ, fld))
 	___t; \
 })
 
-#define MLX5_SET64(typ, p, fld, v) do { \
+#define __MLX5_SET64(typ, p, fld, v) do { \
 	BUILD_BUG_ON(__mlx5_bit_sz(typ, fld) != 64); \
-	BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
 	*((__be64 *)(p) + __mlx5_64_off(typ, fld)) = cpu_to_be64(v); \
 } while (0)
 
+#define MLX5_SET64(typ, p, fld, v) do { \
+	BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
+	__MLX5_SET64(typ, p, fld, v); \
+} while (0)
+
+#define MLX5_ARRAY_SET64(typ, p, fld, idx, v) do { \
+	BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
+	__MLX5_SET64(typ, p, fld[idx], v); \
+} while (0)
+
 #define MLX5_GET64(typ, p, fld) be64_to_cpu(*((__be64 *)(p) + __mlx5_64_off(typ, fld)))
 
 #define MLX5_GET64_PR(typ, p, fld) ({ \
-- 
2.7.4
