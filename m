From: David Ahern <david.ahern@oracle.com>
Subject: [PATCH] net/mlx4_core: Fix unaligned accesses
Date: Wed, 29 Apr 2015 16:52:51 -0400
Message-ID: <1430340771-12425-1-git-send-email-david.ahern@oracle.com>
Cc: David Ahern <david.ahern@oracle.com>
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39451 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbbD2UxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 16:53:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addresses the following kernel logs seen during boot:

Kernel unaligned access at TPC[100ee150] mlx4_QUERY_HCA+0x80/0x248 [mlx4_core]
Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]

Signed-off-by: David Ahern <david.ahern@oracle.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 5a21e5d..a8e5661 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -56,11 +56,13 @@ MODULE_PARM_DESC(enable_qos, "Enable Quality of Service support in the HCA (defa
 #define MLX4_GET(dest, source, offset)				      \
 	do {							      \
 		void *__p = (char *) (source) + (offset);	      \
+		u64 val;                                              \
 		switch (sizeof (dest)) {			      \
 		case 1: (dest) = *(u8 *) __p;	    break;	      \
 		case 2: (dest) = be16_to_cpup(__p); break;	      \
 		case 4: (dest) = be32_to_cpup(__p); break;	      \
-		case 8: (dest) = be64_to_cpup(__p); break;	      \
+		case 8: val = get_unaligned((u64 *)__p);              \
+			(dest) = be64_to_cpu(val);  break;            \
 		default: __buggy_use_of_MLX4_GET();		      \
 		}						      \
 	} while (0)
@@ -1526,9 +1528,17 @@ static void get_board_id(void *vsd, char *board_id)
 		 * swaps each 4-byte word before passing it back to
 		 * us.  Therefore we need to swab it before printing.
 		 */
-		for (i = 0; i < 4; ++i)
-			((u32 *) board_id)[i] =
-				swab32(*(u32 *) (vsd + VSD_OFFSET_MLX_BOARD_ID + i * 4));
+		u32 *bid_u32 = (u32 *)board_id;
+
+		for (i = 0; i < 4; ++i) {
+			u32 *addr;
+			u32 val;
+
+			addr = (u32 *) (vsd + VSD_OFFSET_MLX_BOARD_ID + i * 4);
+			val = get_unaligned(addr);
+			val = swab32(val);
+			put_unaligned(val, &bid_u32[i]);
+		}
 	}
 }
 
-- 
1.7.1
