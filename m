From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 1/4] ptp/chardev:Introduce another option to get/set time in ptp_clock_info structure
Date: Thu, 19 Mar 2015 13:45:06 +0800
Message-ID: <1426743909-24335-2-git-send-email-baolin.wang@linaro.org>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.stultz@linaro.com, tglx@linutronix.de, arnd@linaro.org,
	baolin.wang@linaro.org
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces two options with "ktime_t" type to get/set time
in ptp_clock_info structure that will avoid breaking in the year 2038.

In ptp_chardev.c file, replace the gettime interface with getktime
interface using the "ktime_t" type to get the ptp clock time.

The patch's goal is to remove the original code using the "timespec" type,
and I expect to be done with that in the following merge window.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 drivers/ptp/ptp_chardev.c        |   27 ++++++++++++++++++---------
 include/linux/ptp_clock_kernel.h |    2 ++
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index f8a7609..4e14cc6 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -125,8 +125,10 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 	struct ptp_clock_info *ops = ptp->info;
 	struct ptp_clock_time *pct;
 	struct timespec ts;
+	struct timespec64 ts64;
 	int enable, err = 0;
 	unsigned int i, pin_index;
+	ktime_t kt;
 
 	switch (cmd) {
 
@@ -197,18 +199,25 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		}
 		pct = &sysoff->ts[0];
 		for (i = 0; i < sysoff->n_samples; i++) {
-			getnstimeofday(&ts);
-			pct->sec = ts.tv_sec;
-			pct->nsec = ts.tv_nsec;
+			ktime_get_real_ts64(&ts64);
+			pct->sec = ts64.tv_sec;
+			pct->nsec = ts64.tv_nsec;
 			pct++;
-			ptp->info->gettime(ptp->info, &ts);
-			pct->sec = ts.tv_sec;
-			pct->nsec = ts.tv_nsec;
+			if (ptp->info->getktime) {
+				ptp->info->getktime(ptp->info, &kt);
+				ts64 = ktime_to_timespec64(kt);
+				pct->sec =  ts64.tv_sec;
+				pct->nsec = ts64.tv_nsec;
+			} else {
+				ptp->info->gettime(ptp->info, &ts);
+				pct->sec = ts.tv_sec;
+				pct->nsec = ts.tv_nsec;
+			}
 			pct++;
 		}
-		getnstimeofday(&ts);
-		pct->sec = ts.tv_sec;
-		pct->nsec = ts.tv_nsec;
+		ktime_get_real_ts64(&ts64);
+		pct->sec = ts64.tv_sec;
+		pct->nsec = ts64.tv_nsec;
 		if (copy_to_user((void __user *)arg, sysoff, sizeof(*sysoff)))
 			err = -EFAULT;
 		break;
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 0d8ff3f..86decc2 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -105,7 +105,9 @@ struct ptp_clock_info {
 	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
 	int (*gettime)(struct ptp_clock_info *ptp, struct timespec *ts);
+	int (*getktime)(struct ptp_clock_info *ptp, ktime_t *kt);
 	int (*settime)(struct ptp_clock_info *ptp, const struct timespec *ts);
+	int (*setktime)(struct ptp_clock_info *ptp, ktime_t kt);
 	int (*enable)(struct ptp_clock_info *ptp,
 		      struct ptp_clock_request *request, int on);
 	int (*verify)(struct ptp_clock_info *ptp, unsigned int pin,
-- 
1.7.9.5
