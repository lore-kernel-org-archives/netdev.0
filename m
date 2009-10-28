From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 4/7] mlx4: Use bitmap_find_next_zero_area
Date: Wed, 28 Oct 2009 17:43:14 +0900
Message-ID: <1256719397-4258-4-git-send-email-akinobu.mita@gmail.com>
References: <1256719397-4258-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932815AbZJ1Iom@vger.kernel.org>
In-Reply-To: <1256719397-4258-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Reviewed-by: Roland Dreier <rolandd@cisco.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org
---
 drivers/net/mlx4/alloc.c |   37 ++++---------------------------------
 1 files changed, 4 insertions(+), 33 deletions(-)

diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index ad95d5f..8c85156 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -72,35 +72,6 @@ void mlx4_bitmap_free(struct mlx4_bitmap *bitmap, u32 obj)
 	mlx4_bitmap_free_range(bitmap, obj, 1);
 }
 
-static unsigned long find_aligned_range(unsigned long *bitmap,
-					u32 start, u32 nbits,
-					int len, int align)
-{
-	unsigned long end, i;
-
-again:
-	start = ALIGN(start, align);
-
-	while ((start < nbits) && test_bit(start, bitmap))
-		start += align;
-
-	if (start >= nbits)
-		return -1;
-
-	end = start+len;
-	if (end > nbits)
-		return -1;
-
-	for (i = start + 1; i < end; i++) {
-		if (test_bit(i, bitmap)) {
-			start = i + 1;
-			goto again;
-		}
-	}
-
-	return start;
-}
-
 u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align)
 {
 	u32 obj, i;
@@ -110,13 +81,13 @@ u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align)
 
 	spin_lock(&bitmap->lock);
 
-	obj = find_aligned_range(bitmap->table, bitmap->last,
-				 bitmap->max, cnt, align);
+	obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
+				bitmap->last, cnt, align - 1);
 	if (obj >= bitmap->max) {
 		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
 				& bitmap->mask;
-		obj = find_aligned_range(bitmap->table, 0, bitmap->max,
-					 cnt, align);
+		obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
+						0, cnt, align - 1);
 	}
 
 	if (obj < bitmap->max) {
-- 
1.6.5.1
