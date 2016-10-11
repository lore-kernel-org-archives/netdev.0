From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] mlx5: Add MLX5_SET64_VCHK to fix BUILD_BUG_ON
Date: Mon, 10 Oct 2016 21:22:22 -0700
Message-ID: <20161011042222.2366145-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50250 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751123AbcJKEWg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 00:22:36 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u9B4M5g3017740
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 21:22:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 25xvfbxh4t-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 21:22:36 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 54f283e48f6a11e692c80002c991e86a-321eea50 for <netdev@vger.kernel.org>;        Mon,
 10 Oct 2016 21:22:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am hitting this in mlx5:

drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
‘reclaim_pages_cmd.clone.0’:
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:346: error: call
to ‘__compiletime_assert_346’ declared with attribute error:
BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_out, pas[i]) % 64
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function ‘give_pages’:
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:291: error: call
to ‘__compiletime_assert_291’ declared with attribute error:
BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_in, pas[i]) % 64

Problem is that this is doing a BUILD_BUG_ON on a non-constant
expression because of trying to take offset of pas[i] in the
structure.

Fix is to create MLX5_SET64_VCHK that takes an additional argument
that is a constant. There are two callers of MLX5_SET64 that are
trying to get a variable offset, change those to call MLX5_SET64_VCHK
passing pas[0] as the argument to use in the offset check.

Fixes: a533ed5e179cd ("net/mlx5: Pages management commands via mlx5 ifc")
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c |  5 +++--
 include/linux/mlx5/device.h                         | 13 +++++++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index d458515..5ef5ae2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -287,7 +287,7 @@ retry:
 
 			goto retry;
 		}
-		MLX5_SET64(manage_pages_in, in, pas[i], addr);
+		MLX5_SET64_VCHK(manage_pages_in, in, pas[i], pas[0], addr);
 	}
 
 	MLX5_SET(manage_pages_in, in, opcode, MLX5_CMD_OP_MANAGE_PAGES);
@@ -344,7 +344,8 @@ static int reclaim_pages_cmd(struct mlx5_core_dev *dev,
 		if (fwp->func_id != func_id)
 			continue;
 
-		MLX5_SET64(manage_pages_out, out, pas[i], fwp->addr);
+		MLX5_SET64_VCHK(manage_pages_out, out, pas[i], pas[0],
+				fwp->addr);
 		i++;
 	}
 
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 77c1417..943eb18 100644
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
+#define MLX5_SET64_VCHK(typ, p, fld, const_fld, v) do { \
+	BUILD_BUG_ON(__mlx5_bit_off(typ, const_fld) % 64); \
+	__MLX5_SET64(typ, p, fld, v); \
+} while (0)
+
 #define MLX5_GET64(typ, p, fld) be64_to_cpu(*((__be64 *)(p) + __mlx5_64_off(typ, fld)))
 
 #define MLX5_GET64_PR(typ, p, fld) ({ \
-- 
2.9.3
