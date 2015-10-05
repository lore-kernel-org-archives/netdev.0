From: jon@ringle.org
Subject: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg is marked volatile
Date: Mon,  5 Oct 2015 09:29:31 -0400
Message-ID: <1444051772-20270-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Ringle <jringle@gridpoint.com>

The only time that it makes sense to call a custom provided reg_update_bits
function, is the register being updated is one that has volatile bits.
Otherwise, the normal read/modify/write cycle (where the read is likely to
be free from the cache) will do just fine. This should keep the reg cache
intact, since volatile registers won't get cached anyway.

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---

This patch is being submitted because
"[PATCH net-next v2 1/2] regmap: Allow installing custom reg_update_bits function"
was applied to net-next prematurely (there was a v3 patch out for review).

This is a diff between the v2 and v3.

Thanks,

Jon

 drivers/base/regmap/internal.h |  3 +--
 drivers/base/regmap/regmap.c   | 48 +++++++++++++-----------------------------
 include/linux/regmap.h         |  3 +--
 3 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/drivers/base/regmap/internal.h b/drivers/base/regmap/internal.h
index 4036d7a..628ad7a 100644
--- a/drivers/base/regmap/internal.h
+++ b/drivers/base/regmap/internal.h
@@ -99,8 +99,7 @@ struct regmap {
 	int (*reg_read)(void *context, unsigned int reg, unsigned int *val);
 	int (*reg_write)(void *context, unsigned int reg, unsigned int val);
 	int (*reg_update_bits)(void *context, unsigned int reg,
-			       unsigned int mask, unsigned int val,
-			       bool *change, bool force_write);
+			       unsigned int mask, unsigned int val);
 
 	bool defer_caching;
 
diff --git a/drivers/base/regmap/regmap.c b/drivers/base/regmap/regmap.c
index 70387c9..8cd155a 100644
--- a/drivers/base/regmap/regmap.c
+++ b/drivers/base/regmap/regmap.c
@@ -2510,44 +2510,26 @@ static int _regmap_update_bits(struct regmap *map, unsigned int reg,
 	int ret;
 	unsigned int tmp, orig;
 
-	if (map->reg_update_bits) {
-		ret = map->reg_update_bits(map->bus_context, reg, mask, val,
-					   change, force_write);
+	if (change)
+		*change = false;
+
+	if (regmap_volatile(map, reg) && map->reg_update_bits) {
+		ret = map->reg_update_bits(map->bus_context, reg, mask, val);
+		if (ret == 0 && change)
+			*change = true;
+	} else {
+		ret = _regmap_read(map, reg, &orig);
 		if (ret != 0)
 			return ret;
 
-		/* Fix up the cache by read/modify/write */
-		if (!map->cache_bypass && !map->defer_caching) {
-			ret = regcache_read(map, reg, &orig);
-			if (ret != 0)
-				return ret;
+		tmp = orig & ~mask;
+		tmp |= val & mask;
 
-			tmp = orig & ~mask;
-			tmp |= val & mask;
-
-			ret = regcache_write(map, reg, tmp);
-			if (ret != 0)
-				return ret;
-			if (map->cache_only)
-				map->cache_dirty = true;
+		if (force_write || (tmp != orig)) {
+			ret = _regmap_write(map, reg, tmp);
+			if (ret == 0 && change)
+				*change = true;
 		}
-		return ret;
-	}
-
-	ret = _regmap_read(map, reg, &orig);
-	if (ret != 0)
-		return ret;
-
-	tmp = orig & ~mask;
-	tmp |= val & mask;
-
-	if (force_write || (tmp != orig)) {
-		ret = _regmap_write(map, reg, tmp);
-		if (change)
-			*change = true;
-	} else {
-		if (change)
-			*change = false;
 	}
 
 	return ret;
diff --git a/include/linux/regmap.h b/include/linux/regmap.h
index 4d3a3b1..b49d413 100644
--- a/include/linux/regmap.h
+++ b/include/linux/regmap.h
@@ -297,8 +297,7 @@ typedef int (*regmap_hw_reg_read)(void *context, unsigned int reg,
 typedef int (*regmap_hw_reg_write)(void *context, unsigned int reg,
 				   unsigned int val);
 typedef int (*regmap_hw_reg_update_bits)(void *context, unsigned int reg,
-					 unsigned int mask, unsigned int val,
-					 bool *change, bool force_write);
+					 unsigned int mask, unsigned int val);
 typedef struct regmap_async *(*regmap_hw_async_alloc)(void);
 typedef void (*regmap_hw_free_context)(void *context);
 
-- 
2.4.1
