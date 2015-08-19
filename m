From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 4/4] average: remove out-of-line implementation
Date: Wed, 19 Aug 2015 09:46:22 +0200
Message-ID: <1439970382-6170-5-git-send-email-johannes@sipsolutions.net>
References: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56388 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbbHSHq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 03:46:27 -0400
In-Reply-To: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Since all users are now converted to the inline implementation,
remove the out-of-line implementation entirely.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/average.h | 24 -------------------
 lib/Kconfig             | 10 --------
 lib/average.c           | 64 -------------------------------------------------
 3 files changed, 98 deletions(-)
 delete mode 100644 lib/average.c

diff --git a/include/linux/average.h b/include/linux/average.h
index 60f8226c5652..d04aa58280de 100644
--- a/include/linux/average.h
+++ b/include/linux/average.h
@@ -3,30 +3,6 @@
 
 /* Exponentially weighted moving average (EWMA) */
 
-/* For more documentation see lib/average.c */
-
-struct ewma {
-	unsigned long internal;
-	unsigned long factor;
-	unsigned long weight;
-};
-
-extern void ewma_init(struct ewma *avg, unsigned long factor,
-		      unsigned long weight);
-
-extern struct ewma *ewma_add(struct ewma *avg, unsigned long val);
-
-/**
- * ewma_read() - Get average value
- * @avg: Average structure
- *
- * Returns the average value held in @avg.
- */
-static inline unsigned long ewma_read(const struct ewma *avg)
-{
-	return avg->internal >> avg->factor;
-}
-
 #define DECLARE_EWMA(name, _factor, _weight)				\
 	struct ewma_##name {						\
 		unsigned long internal;					\
diff --git a/lib/Kconfig b/lib/Kconfig
index 3a2ef67db6c7..278890dd1049 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -460,16 +460,6 @@ config ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
 config LRU_CACHE
 	tristate
 
-config AVERAGE
-	bool "Averaging functions"
-	help
-	  This option is provided for the case where no in-kernel-tree
-	  modules require averaging functions, but a module built outside
-	  the kernel tree does. Such modules that use library averaging
-	  functions require Y here.
-
-	  If unsure, say N.
-
 config CLZ_TAB
 	bool
 
diff --git a/lib/average.c b/lib/average.c
deleted file mode 100644
index 114d1beae0c7..000000000000
--- a/lib/average.c
+++ /dev/null
@@ -1,64 +0,0 @@
-/*
- * lib/average.c
- *
- * This source code is licensed under the GNU General Public License,
- * Version 2.  See the file COPYING for more details.
- */
-
-#include <linux/export.h>
-#include <linux/average.h>
-#include <linux/kernel.h>
-#include <linux/bug.h>
-#include <linux/log2.h>
-
-/**
- * DOC: Exponentially Weighted Moving Average (EWMA)
- *
- * These are generic functions for calculating Exponentially Weighted Moving
- * Averages (EWMA). We keep a structure with the EWMA parameters and a scaled
- * up internal representation of the average value to prevent rounding errors.
- * The factor for scaling up and the exponential weight (or decay rate) have to
- * be specified thru the init fuction. The structure should not be accessed
- * directly but only thru the helper functions.
- */
-
-/**
- * ewma_init() - Initialize EWMA parameters
- * @avg: Average structure
- * @factor: Factor to use for the scaled up internal value. The maximum value
- *	of averages can be ULONG_MAX/(factor*weight). For performance reasons
- *	factor has to be a power of 2.
- * @weight: Exponential weight, or decay rate. This defines how fast the
- *	influence of older values decreases. For performance reasons weight has
- *	to be a power of 2.
- *
- * Initialize the EWMA parameters for a given struct ewma @avg.
- */
-void ewma_init(struct ewma *avg, unsigned long factor, unsigned long weight)
-{
-	WARN_ON(!is_power_of_2(weight) || !is_power_of_2(factor));
-
-	avg->weight = ilog2(weight);
-	avg->factor = ilog2(factor);
-	avg->internal = 0;
-}
-EXPORT_SYMBOL(ewma_init);
-
-/**
- * ewma_add() - Exponentially weighted moving average (EWMA)
- * @avg: Average structure
- * @val: Current value
- *
- * Add a sample to the average.
- */
-struct ewma *ewma_add(struct ewma *avg, unsigned long val)
-{
-	unsigned long internal = ACCESS_ONCE(avg->internal);
-
-	ACCESS_ONCE(avg->internal) = internal ?
-		(((internal << avg->weight) - internal) +
-			(val << avg->factor)) >> avg->weight :
-		(val << avg->factor);
-	return avg;
-}
-EXPORT_SYMBOL(ewma_add);
-- 
2.1.4
