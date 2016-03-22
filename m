From: Tina Ruchandani <ruchandani.tina@gmail.com>
Subject: [PATCH v2] prism54: isl_38xx: Replace 'struct timeval'
Date: Tue, 22 Mar 2016 15:16:15 -0700
Message-ID: <20160322221615.GA55727@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	arnd@arndb.de, linux-kernel@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>
To: y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33165 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbcCVWQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 18:16:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'struct timeval' uses a 32-bit seconds field which will overflow in
year 2038 and beyond. This patch is part of a larger effort to remove
all instances of 'struct timeval' from the kernel and replace them
with 64-bit timekeeping variables.
The correctness of the code isn't affected by this patch - the seconds
value being printed would earlier be wrong due to overflow in timeval,
and now it gets truncated to 32-bit due to the 'long' cast used on
tv.sec field to prevent compiler warnings. Truly fixing this would
require changing the debug print to print more than 8 digits and
use a different specifier from %li.
The patch was build-tested / debugged by removing the
"if VERBOSE > SHOW_ERROR_MESSAGES" guards.

Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>
Suggested-by: Arnd Bergmann <arnd@arndb.de>
--
Changes in v2:
- Changed printf specifier as suggested by Arnd Bergmann to
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
