From: Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] prism54: isl_38xx: Replace 'struct timeval'
Date: Tue, 22 Mar 2016 02:55:22 -0700
Message-ID: <20160322095522.GA35392@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

'struct timeval' uses a 32-bit seconds field which will overflow in
year 2038 and beyond. This patch is part of a larger effort to remove
all instances of 'struct timeval' from the kernel and replace them
with 64-bit timekeeping variables.
The correctness of the code isn't affected by this patch - the seconds
value being printed would earlier be wrong due to overflow in timeval,
and now it gets truncated to 32-bit due to the 'long' cast used on
tv.sec field to prevent compiler warnings. Truly fixing this would 
require changing the debug print to print more than 8 digits and using 
a different specifier from %li.
The patch was build-tested / debugged by removing the
"if VERBOSE > SHOW_ERROR_MESSAGES" guards.

Signed-off-by: Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/intersil/prism54/isl_38xx.c | 29 +++++++++++++++---------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/intersil/prism54/isl_38xx.c b/drivers/net/wireless/intersil/prism54/isl_38xx.c
index 333c1a2..e510375 100644
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

@@ -121,22 +122,25 @@ isl38xx_trigger_device(int asleep, void __iomem *device_base)
 	if (asleep) {
 		/* device is in powersave, trigger the device for wakeup */
 #if VERBOSE > SHOW_ERROR_MESSAGES
-		do_gettimeofday(&current_time);
+		ktime_get_real_ts64(&current_ts64);
 		DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\n",
-		      current_time.tv_sec, (long)current_time.tv_usec);
+		      (long)current_ts64.tv_sec,
+		      (long)(current_ts64.tv_nsec / NSEC_PER_USEC));

 		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, (long)current_time.tv_usec,
+		      (long)current_ts64.tv_sec,
+		      (long)(current_ts64.tv_nsec / NSEC_PER_USEC),
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 #endif

 		reg = readl(device_base + ISL38XX_INT_IDENT_REG);
 		if (reg == 0xabadface) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
-			do_gettimeofday(&current_time);
+			ktime_get_real_ts64(&current_ts64);
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device register abadface\n",
-			      current_time.tv_sec, (long)current_time.tv_usec);
+			      (long)current_ts64.tv_sec,
+			      (long)(current_ts64.tv_nsec / NSEC_PER_USEC));
 #endif
 			/* read the Device Status Register until Sleepmode bit is set */
 			while (reg = readl(device_base + ISL38XX_CTRL_STAT_REG),
@@ -150,12 +154,14 @@ isl38xx_trigger_device(int asleep, void __iomem *device_base)
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device register read %08x\n",
-			      current_time.tv_sec, (long)current_time.tv_usec,
+			      (long)current_ts64.tv_sec,
+			      (long)(current_ts64.tv_nsec / NSEC_PER_USEC),
 			      readl(device_base + ISL38XX_CTRL_STAT_REG));
-			do_gettimeofday(&current_time);
+			ktime_get_real_ts64(&current_ts64);
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device asleep counter %i\n",
-			      current_time.tv_sec, (long)current_time.tv_usec,
+			      (long)current_ts64.tv_sec,
+			      (long)(current_ts64.tv_nsec / NSEC_PER_USEC),
 			      counter);
 #endif
 		}
@@ -168,9 +174,10 @@ isl38xx_trigger_device(int asleep, void __iomem *device_base)

 		/* perform another read on the Device Status Register */
 		reg = readl(device_base + ISL38XX_CTRL_STAT_REG);
-		do_gettimeofday(&current_time);
+		ktime_get_real_ts64(&current_ts64);
 		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, (long)current_time.tv_usec, reg);
+		      (long)current_ts64.tv_sec,
+		      (long)(current_ts64.tv_nsec / NSEC_PER_USEC), reg);
 #endif
 	} else {
 		/* device is (still) awake  */
--
2.8.0.rc3.226.g39d4020

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
