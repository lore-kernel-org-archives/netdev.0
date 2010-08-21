From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] mlx4: use bitmap library
Date: Sat, 21 Aug 2010 18:24:48 +0900
Message-ID: <1282382688-5786-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Roland Dreier <rolandd@cisco.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:48327 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab0HUJbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 05:31:11 -0400
Received: by pxi10 with SMTP id 10so1562077pxi.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 02:31:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use bitmap_set() and bitmap_clear()

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Roland Dreier <rolandd@cisco.com>
Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/mlx4/alloc.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index 8c85156..76595bd 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -74,7 +74,7 @@ void mlx4_bitmap_free(struct mlx4_bitmap *bitmap, u32 obj)
 
 u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align)
 {
-	u32 obj, i;
+	u32 obj;
 
 	if (likely(cnt == 1 && align == 1))
 		return mlx4_bitmap_alloc(bitmap);
@@ -91,8 +91,7 @@ u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align)
 	}
 
 	if (obj < bitmap->max) {
-		for (i = 0; i < cnt; i++)
-			set_bit(obj + i, bitmap->table);
+		bitmap_set(bitmap->table, obj, cnt);
 		if (obj == bitmap->last) {
 			bitmap->last = (obj + cnt);
 			if (bitmap->last >= bitmap->max)
@@ -109,13 +108,10 @@ u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align)
 
 void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt)
 {
-	u32 i;
-
 	obj &= bitmap->max + bitmap->reserved_top - 1;
 
 	spin_lock(&bitmap->lock);
-	for (i = 0; i < cnt; i++)
-		clear_bit(obj + i, bitmap->table);
+	bitmap_clear(bitmap->table, obj, cnt);
 	bitmap->last = min(bitmap->last, obj);
 	bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
 			& bitmap->mask;
@@ -125,8 +121,6 @@ void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt)
 int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 		     u32 reserved_bot, u32 reserved_top)
 {
-	int i;
-
 	/* num must be a power of 2 */
 	if (num != roundup_pow_of_two(num))
 		return -EINVAL;
@@ -142,8 +136,7 @@ int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 	if (!bitmap->table)
 		return -ENOMEM;
 
-	for (i = 0; i < reserved_bot; ++i)
-		set_bit(i, bitmap->table);
+	bitmap_set(bitmap->table, 0, reserved_bot);
 
 	return 0;
 }
-- 
1.6.0.6

