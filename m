From: jon@ringle.org
Subject: [PATCH net-next v3 1/2] regmap: Allow installing custom reg_update_bits function
Date: Thu,  1 Oct 2015 12:38:07 -0400
Message-ID: <1443717488-16533-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Ringle <jringle@gridpoint.com>

This commit allows installing a custom reg_update_bits function for cases where
the hardware provides a mechanism to set or clear register bits without a
read/modify/write cycle. Such is the case with the Microchip ENCX24J600.

If a custom reg_update_bits function is provided, it will only be used against
volatile registers.

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---

I am now only calling map->reg_update_bits() if the register is marked as being
volatile, and therefore should have no impact on the reg cache.

Jon

 drivers/base/regmap/internal.h |  2 ++
 drivers/base/regmap/regmap.c   | 29 ++++++++++++++++++-----------
 include/linux/regmap.h         |  3 +++
 3 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/base/regmap/internal.h b/drivers/base/regmap/internal.h
index cc55788..628ad7a 100644
--- a/drivers/base/regmap/internal.h
+++ b/drivers/base/regmap/internal.h
@@ -98,6 +98,8 @@ struct regmap {
 
 	int (*reg_read)(void *context, unsigned int reg, unsigned int *val);
 	int (*reg_write)(void *context, unsigned int reg, unsigned int val);
+	int (*reg_update_bits)(void *context, unsigned int reg,
+			       unsigned int mask, unsigned int val);
 
 	bool defer_caching;
 
diff --git a/drivers/base/regmap/regmap.c b/drivers/base/regmap/regmap.c
index afaf562..8cd155a 100644
--- a/drivers/base/regmap/regmap.c
+++ b/drivers/base/regmap/regmap.c
@@ -619,6 +619,7 @@ struct regmap *__regmap_init(struct device *dev,
 		goto skip_format_initialization;
 	} else {
 		map->reg_read  = _regmap_bus_read;
+		map->reg_update_bits = bus->reg_update_bits;
 	}
 
 	reg_endian = regmap_get_reg_endian(bus, config);
@@ -2509,20 +2510,26 @@ static int _regmap_update_bits(struct regmap *map, unsigned int reg,
 	int ret;
 	unsigned int tmp, orig;
 
-	ret = _regmap_read(map, reg, &orig);
-	if (ret != 0)
-		return ret;
+	if (change)
+		*change = false;
 
-	tmp = orig & ~mask;
-	tmp |= val & mask;
-
-	if (force_write || (tmp != orig)) {
-		ret = _regmap_write(map, reg, tmp);
-		if (change)
+	if (regmap_volatile(map, reg) && map->reg_update_bits) {
+		ret = map->reg_update_bits(map->bus_context, reg, mask, val);
+		if (ret == 0 && change)
 			*change = true;
 	} else {
-		if (change)
-			*change = false;
+		ret = _regmap_read(map, reg, &orig);
+		if (ret != 0)
+			return ret;
+
+		tmp = orig & ~mask;
+		tmp |= val & mask;
+
+		if (force_write || (tmp != orig)) {
+			ret = _regmap_write(map, reg, tmp);
+			if (ret == 0 && change)
+				*change = true;
+		}
 	}
 
 	return ret;
diff --git a/include/linux/regmap.h b/include/linux/regmap.h
index 8fc0bfd..b49d413 100644
--- a/include/linux/regmap.h
+++ b/include/linux/regmap.h
@@ -296,6 +296,8 @@ typedef int (*regmap_hw_reg_read)(void *context, unsigned int reg,
 				  unsigned int *val);
 typedef int (*regmap_hw_reg_write)(void *context, unsigned int reg,
 				   unsigned int val);
+typedef int (*regmap_hw_reg_update_bits)(void *context, unsigned int reg,
+					 unsigned int mask, unsigned int val);
 typedef struct regmap_async *(*regmap_hw_async_alloc)(void);
 typedef void (*regmap_hw_free_context)(void *context);
 
@@ -335,6 +337,7 @@ struct regmap_bus {
 	regmap_hw_gather_write gather_write;
 	regmap_hw_async_write async_write;
 	regmap_hw_reg_write reg_write;
+	regmap_hw_reg_update_bits reg_update_bits;
 	regmap_hw_read read;
 	regmap_hw_reg_read reg_read;
 	regmap_hw_free_context free_context;
-- 
2.4.1
