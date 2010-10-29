From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 03/11] vxge: cleanup debug printing and asserts
Date: Thu, 28 Oct 2010 21:19:38 -0500
Message-ID: <1288318786-12319-3-git-send-email-jon.mason@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38952 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758819Ab0J2CT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:19:59 -0400
Received: by yxk8 with SMTP id 8so1381877yxk.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:19:58 -0700 (PDT)
In-Reply-To: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove all of the unnecessary debug printk indirection and temporary
variables for vxge_debug_ll and vxge_assert.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.h |   43 +++++++++------------------------------
 drivers/net/vxge/vxge-main.h   |    2 -
 2 files changed, 10 insertions(+), 35 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index eaa38e6..285695a 100644
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
@@ -2224,8 +2213,9 @@ __vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
 
 enum vxge_hw_status
 vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
+
 /**
- * vxge_debug
+ * vxge_debug_ll
  * @level: level of debug verbosity.
  * @mask: mask for the debug
  * @buf: Circular buffer for tracing
@@ -2237,26 +2227,13 @@ vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
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
index 8641822..411732d 100644
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

