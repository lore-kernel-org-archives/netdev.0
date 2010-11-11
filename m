From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 03/12] vxge: cleanup debug printing and asserts
Date: Thu, 11 Nov 2010 08:25:55 -0600
Message-ID: <1289485564-8822-4-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45298 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568Ab0KKO0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 09:26:48 -0500
Received: by yxk8 with SMTP id 8so34940yxk.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 06:26:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove all of the unnecessary debug printk indirection and temporary
variables for vxge_debug_ll and vxge_assert.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.h |   42 ++++++++-------------------------------
 drivers/net/vxge/vxge-main.h   |    2 -
 2 files changed, 9 insertions(+), 35 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 95e7021..b395d8d 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -20,13 +20,6 @@
 #define VXGE_CACHE_LINE_SIZE 128
 #endif
 
-#define vxge_os_vaprintf(level, mask, fmt, ...) { \
-	char buff[255]; \
-		snprintf(buff, 255, fmt, __VA_ARGS__); \
-		printk(buff); \
-		printk("\n"); \
-}
-
 #ifndef VXGE_ALIGN
 #define VXGE_ALIGN(adrs, size) \
 	(((size) - (((u64)adrs) & ((size)-1))) & ((size)-1))
@@ -37,7 +30,6 @@
 #define VXGE_HW_DEFAULT_MTU			1500
 
 #ifdef VXGE_DEBUG_ASSERT
-
 /**
  * vxge_assert
  * @test: C-condition to check
@@ -48,16 +40,13 @@
  * compilation
  * time.
  */
-#define vxge_assert(test) { \
-	if (!(test)) \
-		vxge_os_bug("bad cond: "#test" at %s:%d\n", \
-				__FILE__, __LINE__); }
+#define vxge_assert(test) BUG_ON(!(test))
 #else
 #define vxge_assert(test)
 #endif /* end of VXGE_DEBUG_ASSERT */
 
 /**
- * enum enum vxge_debug_level
+ * enum vxge_debug_level
  * @VXGE_NONE: debug disabled
  * @VXGE_ERR: all errors going to be logged out
  * @VXGE_TRACE: all errors plus all kind of verbose tracing print outs
@@ -2000,7 +1989,7 @@ enum vxge_hw_status
 vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
 
 /**
- * vxge_debug
+ * vxge_debug_ll
  * @level: level of debug verbosity.
  * @mask: mask for the debug
  * @buf: Circular buffer for tracing
@@ -2012,26 +2001,13 @@ vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
  * may be compiled out if DEBUG macro was never defined.
  * See also: enum vxge_debug_level{}.
  */
-
-#define vxge_trace_aux(level, mask, fmt, ...) \
-{\
-		vxge_os_vaprintf(level, mask, fmt, __VA_ARGS__);\
-}
-
-#define vxge_debug(module, level, mask, fmt, ...) { \
-if ((level >= VXGE_TRACE && ((module & VXGE_DEBUG_TRACE_MASK) == module)) || \
-	(level >= VXGE_ERR && ((module & VXGE_DEBUG_ERR_MASK) == module))) {\
-	if ((mask & VXGE_DEBUG_MASK) == mask)\
-		vxge_trace_aux(level, mask, fmt, __VA_ARGS__); \
-} \
-}
-
 #if (VXGE_COMPONENT_LL & VXGE_DEBUG_MODULE_MASK)
-#define vxge_debug_ll(level, mask, fmt, ...) \
-{\
-	vxge_debug(VXGE_COMPONENT_LL, level, mask, fmt, __VA_ARGS__);\
-}
-
+#define vxge_debug_ll(level, mask, fmt, ...) do {			       \
+	if ((level >= VXGE_ERR && VXGE_COMPONENT_LL & VXGE_DEBUG_ERR_MASK) ||  \
+	    (level >= VXGE_TRACE && VXGE_COMPONENT_LL & VXGE_DEBUG_TRACE_MASK))\
+		if ((mask & VXGE_DEBUG_MASK) == mask)			       \
+			printk(fmt "\n", __VA_ARGS__);			       \
+} while (0)
 #else
 #define vxge_debug_ll(level, mask, fmt, ...)
 #endif
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 54989d0..3845e62 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -387,8 +387,6 @@ struct vxge_tx_priv {
 	static int p = val; \
 	module_param(p, int, 0)
 
-#define vxge_os_bug(fmt...)		{ printk(fmt); BUG(); }
-
 #define vxge_os_timer(timer, handle, arg, exp) do { \
 		init_timer(&timer); \
 		timer.function = handle; \
-- 
1.7.0.4

