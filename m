From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xtables: make XT_ALIGN() usable in exported headers by
 exporting __ALIGN_KERNEL()
Date: Wed, 7 Apr 2010 19:22:46 +0300
Message-ID: <20100407162245.GA4557@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, bhutchings@solarflare.com, andreas@fatal.se,
	hadi@cyberus.ca, hideaki@yoshifuji.org
To: kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

XT_ALIGN() was rewritten through ALIGN() by commit 42107f5009da223daa800d6da6904d77297ae829
"netfilter: xtables: symmetric COMPAT_XT_ALIGN definition".
ALIGN() is not exported in userspace headers, which created compile problem for tc(8)
and will create problem for iptables(8).

We can't export generic looking name ALIGN() but we can export less generic
__ALIGN_KERNEL() (suggested by Ben Hutchings).
Google knows nothing about __ALIGN_KERNEL().

COMPAT_XT_ALIGN() changed for symmetry.

Reported-by: Andreas Henriksson <andreas@fatal.se>
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/kernel.h             |    5 +++--
 include/linux/netfilter/x_tables.h |    6 +++---
 2 files changed, 6 insertions(+), 5 deletions(-)

--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -4,6 +4,8 @@
 /*
  * 'kernel.h' contains some often-used function prototypes etc
  */
+#define __ALIGN_KERNEL(x, a)		__ALIGN_KERNEL_MASK(x, (typeof(x))(a) - 1)
+#define __ALIGN_KERNEL_MASK(x, mask)	(((x) + (mask)) & ~(mask))
 
 #ifdef __KERNEL__
 
@@ -37,8 +39,7 @@ extern const char linux_proc_banner[];
 
 #define STACK_MAGIC	0xdeadbeef
 
-#define ALIGN(x,a)		__ALIGN_MASK(x,(typeof(x))(a)-1)
-#define __ALIGN_MASK(x,mask)	(((x)+(mask))&~(mask))
+#define ALIGN(x, a)		__ALIGN_KERNEL((x), (a))
 #define PTR_ALIGN(p, a)		((typeof(p))ALIGN((unsigned long)(p), (a)))
 #define IS_ALIGNED(x, a)		(((x) & ((typeof(x))(a) - 1)) == 0)
 
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -1,6 +1,6 @@
 #ifndef _X_TABLES_H
 #define _X_TABLES_H
-
+#include <linux/kernel.h>
 #include <linux/types.h>
 
 #define XT_FUNCTION_MAXNAMELEN 30
@@ -93,7 +93,7 @@ struct _xt_align {
 	__u64 u64;
 };
 
-#define XT_ALIGN(s) ALIGN((s), __alignof__(struct _xt_align))
+#define XT_ALIGN(s) __ALIGN_KERNEL((s), __alignof__(struct _xt_align))
 
 /* Standard return verdict, or do jump. */
 #define XT_STANDARD_TARGET ""
@@ -598,7 +598,7 @@ struct _compat_xt_align {
 	compat_u64 u64;
 };
 
-#define COMPAT_XT_ALIGN(s) ALIGN((s), __alignof__(struct _compat_xt_align))
+#define COMPAT_XT_ALIGN(s) __ALIGN_KERNEL((s), __alignof__(struct _compat_xt_align))
 
 extern void xt_compat_lock(u_int8_t af);
 extern void xt_compat_unlock(u_int8_t af);
