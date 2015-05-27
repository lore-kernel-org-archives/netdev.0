From: Tina Ruchandani <ruchandani.tina@gmail.com>
Subject: [PATCH v3] isdn: Use ktime_t instead of 'struct timeval'
Date: Wed, 27 May 2015 06:52:12 +0530
Message-ID: <20150527012212.GA2613@tinar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	y2038@lists.linaro.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34937 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbbE0BWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 21:22:17 -0400
Received: by pdea3 with SMTP id a3so103177475pde.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 18:22:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'struct timeval' uses 32-bit representation for seconds which will
overflow in year 2038 and beyond. mISDN/clock.c needs to compute and
store elapsed time in intervals of 125 microseconds. This patch replaces
the usage of 'struct timeval' with 64-bit ktime_t which is y2038 safe.
The patch also replaces do_gettimeofday() (wall-clock time) with 
ktime_get() (monotonic time) since we only care about elapsed time here.

Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>
Suggested-by: Arnd Bergmnann <arnd@arndb.de>
--
Changes in v3:
- Use division scheme suggested by Arnd Bergmann to avoid
  a (64-bit variable) / (32-bit variable) expression.
Changes in v2:
- Avoid possible truncation bug caused by assigning ktime_us_delta
output to a 16-bit number.
- Use ktime_us_delta, more concise than a combination of ktime_sub
and ktime_to_us.
---
 drivers/isdn/mISDN/clock.c | 56 ++++++++++++++++++----------------------------
 include/linux/mISDNif.h    |  2 +-
 2 files changed, 23 insertions(+), 35 deletions(-)

diff --git a/drivers/isdn/mISDN/clock.c b/drivers/isdn/mISDN/clock.c
index 693fb7c..0ea7e2f 100644
--- a/drivers/isdn/mISDN/clock.c
+++ b/drivers/isdn/mISDN/clock.c
@@ -37,6 +37,7 @@
 #include <linux/types.h>
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
+#include <linux/ktime.h>
 #include <linux/mISDNif.h>
 #include <linux/export.h>
 #include "core.h"
@@ -45,7 +46,7 @@ static u_int *debug;
 static LIST_HEAD(iclock_list);
 static DEFINE_RWLOCK(iclock_lock);
 static u16 iclock_count;		/* counter of last clock */
-static struct timeval iclock_tv;	/* time stamp of last clock */
+static ktime_t iclock_tv;		/* time stamp of last clock */
 static int iclock_tv_valid;		/* already received one timestamp */
 static struct mISDNclock *iclock_current;
 
@@ -53,7 +54,7 @@ void
 mISDN_init_clock(u_int *dp)
 {
 	debug = dp;
-	do_gettimeofday(&iclock_tv);
+	iclock_tv = ktime_get();
 }
 
 static void
@@ -139,12 +140,11 @@ mISDN_unregister_clock(struct mISDNclock *iclock)
 EXPORT_SYMBOL(mISDN_unregister_clock);
 
 void
-mISDN_clock_update(struct mISDNclock *iclock, int samples, struct timeval *tv)
+mISDN_clock_update(struct mISDNclock *iclock, int samples, ktime_t *tv)
 {
 	u_long		flags;
-	struct timeval	tv_now;
-	time_t		elapsed_sec;
-	int		elapsed_8000th;
+	ktime_t		tv_now;
+	u16		delta;
 
 	write_lock_irqsave(&iclock_lock, flags);
 	if (iclock_current != iclock) {
@@ -160,28 +160,22 @@ mISDN_clock_update(struct mISDNclock *iclock, int samples, struct timeval *tv)
 		/* increment sample counter by given samples */
 		iclock_count += samples;
 		if (tv) { /* tv must be set, if function call is delayed */
-			iclock_tv.tv_sec = tv->tv_sec;
-			iclock_tv.tv_usec = tv->tv_usec;
-		} else
-			do_gettimeofday(&iclock_tv);
+			iclock_tv = *tv;
+		} else {
+			iclock_tv = ktime_get();
+		}
 	} else {
 		/* calc elapsed time by system clock */
 		if (tv) { /* tv must be set, if function call is delayed */
-			tv_now.tv_sec = tv->tv_sec;
-			tv_now.tv_usec = tv->tv_usec;
-		} else
-			do_gettimeofday(&tv_now);
-		elapsed_sec = tv_now.tv_sec - iclock_tv.tv_sec;
-		elapsed_8000th = (tv_now.tv_usec / 125)
-			- (iclock_tv.tv_usec / 125);
-		if (elapsed_8000th < 0) {
-			elapsed_sec -= 1;
-			elapsed_8000th += 8000;
+			tv_now = *tv;
+		} else {
+			tv_now = ktime_get();
 		}
+		delta = ktime_divns(ktime_sub(tv_now, iclock_tv),
+				    (NS_PER_SEC / 8000));
 		/* add elapsed time to counter and set new timestamp */
-		iclock_count += elapsed_sec * 8000 + elapsed_8000th;
-		iclock_tv.tv_sec = tv_now.tv_sec;
-		iclock_tv.tv_usec = tv_now.tv_usec;
+		iclock_count += delta;
+		iclock_tv = tv_now;
 		iclock_tv_valid = 1;
 		if (*debug & DEBUG_CLOCK)
 			printk("Received first clock from source '%s'.\n",
@@ -195,22 +189,16 @@ unsigned short
 mISDN_clock_get(void)
 {
 	u_long		flags;
-	struct timeval	tv_now;
-	time_t		elapsed_sec;
-	int		elapsed_8000th;
+	ktime_t		tv_now;
+	u16		delta;
 	u16		count;
 
 	read_lock_irqsave(&iclock_lock, flags);
 	/* calc elapsed time by system clock */
-	do_gettimeofday(&tv_now);
-	elapsed_sec = tv_now.tv_sec - iclock_tv.tv_sec;
-	elapsed_8000th = (tv_now.tv_usec / 125) - (iclock_tv.tv_usec / 125);
-	if (elapsed_8000th < 0) {
-		elapsed_sec -= 1;
-		elapsed_8000th += 8000;
-	}
+	tv_now = ktime_get();
+	delta = ktime_divns(ktime_sub(tv_now, iclock_tv), (NS_PER_SEC / 8000));
 	/* add elapsed time to counter */
-	count =	iclock_count + elapsed_sec * 8000 + elapsed_8000th;
+	count =	iclock_count + delta;
 	read_unlock_irqrestore(&iclock_lock, flags);
 	return count;
 }
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index 246a352..ac02c54 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -596,7 +596,7 @@ static inline struct mISDNdevice *dev_to_mISDN(struct device *dev)
 }
 
 extern void	set_channel_address(struct mISDNchannel *, u_int, u_int);
-extern void	mISDN_clock_update(struct mISDNclock *, int, struct timeval *);
+extern void	mISDN_clock_update(struct mISDNclock *, int, ktime_t *);
 extern unsigned short mISDN_clock_get(void);
 extern const char *mISDNDevName4ch(struct mISDNchannel *);
 
-- 
2.2.0.rc0.207.ga3a616c
