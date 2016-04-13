From: Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Tue, 12 Apr 2016 23:09:16 -0700
Message-ID: <20160413060916.GA21184@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

'struct timeval' uses a 32-bit seconds field which will overflow in
year 2038 and beyond. This patch is part of a larger effort to remove
all instances of 'struct timeval' from the kernel and replace them
with 64-bit timekeeping variables.
The patch also fixes the debug printf specifier to avoid the
seconds value being truncated.
The patch was build-tested / debugged by removing the
"if VERBOSE > SHOW_ERROR_MESSAGES" guards.

Signed-off-by: Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Suggested-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
--
Changes in v3:
 Fix commit message
Changes in v2:
 Changed printf specifier as suggested by Arnd Bergmann to
avoid truncation.
---
 drivers/net/wireless/intersil/prism54/isl_38xx.c | 35 ++++++++++++------------
 1 file changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/intersil/prism54/isl_38xx.c b/drivers/net/wireless/intersil/prism54/isl_38xx.c
index 333c1a2..6700387 100644
--- a/drivers/net/wireless/intersil/prism54/isl_38xx.c
+++ b/drivers/net/wireless/intersil/prism54/isl_38xx.c
@@ -19,6 +19,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/delay.h>
+#include <linux/ktime.h>

 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -113,7 +114,7 @@ isl38xx_trigger_device(int asleep, void __iomem *device_base)

 #if VERBOSE > SHOW_ERROR_MESSAGES
 	u32 counter = 0;
-	struct timeval current_time;
+	struct timespec64 current_ts64;
 	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx trigger device\n");
 #endif

@@ -121,22 +122,22 @@ isl38xx_trigger_device(int asleep, void __iomem *device_base)
 	if (asleep) {
 		/* device is in powersave, trigger the device for wakeup */
 #if VERBOSE > SHOW_ERROR_MESSAGES
-		do_gettimeofday(&current_time);
-		DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\n",
-		      current_time.tv_sec, (long)current_time.tv_usec);
+		ktime_get_real_ts64(&current_ts64);
+		DEBUG(SHOW_TRACING, "%lld.%09ld Device wakeup triggered\n",
+		      (s64)current_ts64.tv_sec, current_ts64.tv_nsec);

-		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, (long)current_time.tv_usec,
+		DEBUG(SHOW_TRACING, "%lld.%09ld Device register read %08x\n",
+		      (s64)current_ts64.tv_sec, current_ts64.tv_nsec,
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 #endif

 		reg = readl(device_base + ISL38XX_INT_IDENT_REG);
 		if (reg == 0xabadface) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
-			do_gettimeofday(&current_time);
+			ktime_get_real_ts64(&current_ts64);
 			DEBUG(SHOW_TRACING,
-			      "%08li.%08li Device register abadface\n",
-			      current_time.tv_sec, (long)current_time.tv_usec);
+			      "%lld.%09ld Device register abadface\n",
+			      (s64)current_ts64.tv_sec, current_ts64.tv_nsec);
 #endif
 			/* read the Device Status Register until Sleepmode bit is set */
 			while (reg = readl(device_base + ISL38XX_CTRL_STAT_REG),
@@ -149,13 +150,13 @@ isl38xx_trigger_device(int asleep, void __iomem *device_base)

 #if VERBOSE > SHOW_ERROR_MESSAGES
 			DEBUG(SHOW_TRACING,
-			      "%08li.%08li Device register read %08x\n",
-			      current_time.tv_sec, (long)current_time.tv_usec,
+			      "%lld.%09ld Device register read %08x\n",
+			      (s64)current_ts64.tv_sec, current_ts64.tv_nsec,
 			      readl(device_base + ISL38XX_CTRL_STAT_REG));
-			do_gettimeofday(&current_time);
+			ktime_get_real_ts64(&current_ts64);
 			DEBUG(SHOW_TRACING,
-			      "%08li.%08li Device asleep counter %i\n",
-			      current_time.tv_sec, (long)current_time.tv_usec,
+			      "%lld.%09ld Device asleep counter %i\n",
+			      (s64)current_ts64.tv_sec, current_ts64.tv_nsec,
 			      counter);
 #endif
 		}
@@ -168,9 +169,9 @@ isl38xx_trigger_device(int asleep, void __iomem *device_base)

 		/* perform another read on the Device Status Register */
 		reg = readl(device_base + ISL38XX_CTRL_STAT_REG);
-		do_gettimeofday(&current_time);
-		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, (long)current_time.tv_usec, reg);
+		ktime_get_real_ts64(&current_ts64);
+		DEBUG(SHOW_TRACING, "%lld.%00ld Device register read %08x\n",
+		      (s64)current_ts64.tv_sec, current_ts64.tv_nsec, reg);
 #endif
 	} else {
 		/* device is (still) awake  */
--
2.8.0.rc3.226.g39d4020

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
