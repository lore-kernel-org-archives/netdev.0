From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 13/16] mlx4_core: maintain available field in bitmap allocator
Date: Wed, 23 Mar 2011 10:38:45 +0200
Message-ID: <4D89B195.1030309@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eli@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:35798 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755882Ab1CWIis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:38:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.co.il>

Add mlx4_bitmap_avail() to give the number of available resources. We want to
use this as a hint to whether to allocate a resources or not. This patch is
introduced to be used with allocation blue flame registers.

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
---
 drivers/net/mlx4/alloc.c |   13 +++++++++++++
 drivers/net/mlx4/mlx4.h  |    2 ++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index 3a4277f..116cae3 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -62,6 +62,9 @@ u32 mlx4_bitmap_alloc(struct mlx4_bitmap *bitmap)
 	} else
 		obj = -1;
 
+	if (obj != -1)
+		--bitmap->avail;
+
 	spin_unlock(&bitmap->lock);
 
 	return obj;
@@ -101,11 +104,19 @@ u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align)
 	} else
 		obj = -1;
 
+	if (obj != -1)
+		bitmap->avail -= cnt;
+
 	spin_unlock(&bitmap->lock);
 
 	return obj;
 }
 
+u32 mlx4_bitmap_avail(struct mlx4_bitmap *bitmap)
+{
+	return bitmap->avail;
+}
+
 void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt)
 {
 	obj &= bitmap->max + bitmap->reserved_top - 1;
@@ -115,6 +126,7 @@ void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt)
 	bitmap->last = min(bitmap->last, obj);
 	bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
 			& bitmap->mask;
+	bitmap->avail += cnt;
 	spin_unlock(&bitmap->lock);
 }
 
@@ -130,6 +142,7 @@ int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 	bitmap->max  = num - reserved_top;
 	bitmap->mask = mask;
 	bitmap->reserved_top = reserved_top;
+	bitmap->avail = num - reserved_top - reserved_bot;
 	spin_lock_init(&bitmap->lock);
 	bitmap->table = kzalloc(BITS_TO_LONGS(bitmap->max) *
 				sizeof (long), GFP_KERNEL);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index bc9a216..c1e0e5f 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -105,6 +105,7 @@ struct mlx4_bitmap {
 	u32			max;
 	u32                     reserved_top;
 	u32			mask;
+	u32			avail;
 	spinlock_t		lock;
 	unsigned long	       *table;
 };
@@ -371,6 +372,7 @@ u32 mlx4_bitmap_alloc(struct mlx4_bitmap *bitmap);
 void mlx4_bitmap_free(struct mlx4_bitmap *bitmap, u32 obj);
 u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align);
 void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt);
+u32 mlx4_bitmap_avail(struct mlx4_bitmap *bitmap);
 int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 		     u32 reserved_bot, u32 resetrved_top);
 void mlx4_bitmap_cleanup(struct mlx4_bitmap *bitmap);
-- 
1.6.0.2





