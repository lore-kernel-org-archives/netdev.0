From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH] Added additional callback to ptp_clock_info:
Date: Thu, 25 Jun 2015 16:42:57 -0700
Message-ID: <1435275777-3918-2-git-send-email-christopher.s.hall@intel.com>
References: <1435275777-3918-1-git-send-email-christopher.s.hall@intel.com>
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, kevin.b.stanton@intel.com,
	christopher.s.hall@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:16404 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600AbbFYXmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 19:42:01 -0400
In-Reply-To: <1435275777-3918-1-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* getsynctime64()

This takes 2 arguments referring to system and device time

With this callback drivers may provide both system time and device time
to ensure precise correlation

Modified PTP_SYS_OFFSET ioctl in PTP clock driver to use the above
callback if it's available

Signed-off-by: Christopher Hall <christopher.s.hall@intel.com>
---
 drivers/ptp/ptp_chardev.c        | 30 +++++++++++++++++++++---------
 include/linux/ptp_clock_kernel.h |  3 +++
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index da7bae9..e91f98e 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -124,7 +124,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
 	struct ptp_clock_info *ops = ptp->info;
 	struct ptp_clock_time *pct;
-	struct timespec64 ts;
+	struct timespec64 ts, systs;
 	int enable, err = 0;
 	unsigned int i, pin_index;
 
@@ -196,19 +196,31 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 			break;
 		}
 		pct = &sysoff->ts[0];
-		for (i = 0; i < sysoff->n_samples; i++) {
-			getnstimeofday64(&ts);
+		if (ptp->info->getsynctime64 && sysoff->n_samples == 1) {
+			ptp->info->getsynctime64(ptp->info, &ts, &systs);
+			pct->sec = systs.tv_sec;
+			pct->nsec = systs.tv_nsec;
+			++pct;
 			pct->sec = ts.tv_sec;
 			pct->nsec = ts.tv_nsec;
-			pct++;
-			ptp->info->gettime64(ptp->info, &ts);
+			++pct;
+			pct->sec = systs.tv_sec;
+			pct->nsec = systs.tv_nsec;
+		} else {
+			for (i = 0; i < sysoff->n_samples; i++) {
+				getnstimeofday64(&ts);
+				pct->sec = ts.tv_sec;
+				pct->nsec = ts.tv_nsec;
+				pct++;
+				ptp->info->gettime64(ptp->info, &ts);
+				pct->sec = ts.tv_sec;
+				pct->nsec = ts.tv_nsec;
+				pct++;
+			}
+			getnstimeofday64(&ts);
 			pct->sec = ts.tv_sec;
 			pct->nsec = ts.tv_nsec;
-			pct++;
 		}
-		getnstimeofday64(&ts);
-		pct->sec = ts.tv_sec;
-		pct->nsec = ts.tv_nsec;
 		if (copy_to_user((void __user *)arg, sysoff, sizeof(*sysoff)))
 			err = -EFAULT;
 		break;
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index b8b7306..edff9a5 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -105,6 +105,9 @@ struct ptp_clock_info {
 	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
 	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
+	int (*getsynctime64)
+		(struct ptp_clock_info *ptp, struct timespec64 *dev,
+		 struct timespec64 *sys);
 	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
 	int (*enable)(struct ptp_clock_info *ptp,
 		      struct ptp_clock_request *request, int on);
-- 
1.9.1
