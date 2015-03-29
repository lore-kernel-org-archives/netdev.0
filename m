From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 23/23] ptp: remove 32 bit get/set methods.
Date: Sun, 29 Mar 2015 23:12:13 +0200
Message-ID: <753bff854097714c85cafd3037574be3ad5ed12d.1427662907.git.richardcochran@gmail.com>
References: <cover.1427662906.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zha
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35186 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbbC2VNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 17:13:21 -0400
In-Reply-To: <cover.1427662906.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of the PHC drivers have been converted to the new methods.  This patch
converts the three remaining callers within the core code and removes the
older methods for good.  As a result, the core PHC code is ready for the
year 2038.  However, some of the PHC drivers are not quite ready yet.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_chardev.c        |    8 +-------
 drivers/ptp/ptp_clock.c          |   15 ++++-----------
 include/linux/ptp_clock_kernel.h |    8 --------
 3 files changed, 5 insertions(+), 26 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index 95bcf15..da7bae9 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -125,7 +125,6 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 	struct ptp_clock_info *ops = ptp->info;
 	struct ptp_clock_time *pct;
 	struct timespec64 ts;
-	struct timespec t2;
 	int enable, err = 0;
 	unsigned int i, pin_index;
 
@@ -202,12 +201,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 			pct->sec = ts.tv_sec;
 			pct->nsec = ts.tv_nsec;
 			pct++;
-			if (ptp->info->gettime64) {
-				ptp->info->gettime64(ptp->info, &ts);
-			} else {
-				ptp->info->gettime(ptp->info, &t2);
-				ts = timespec_to_timespec64(t2);
-			}
+			ptp->info->gettime64(ptp->info, &ts);
 			pct->sec = ts.tv_sec;
 			pct->nsec = ts.tv_nsec;
 			pct++;
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index df50d5e..2e481b9 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -109,9 +109,7 @@ static int ptp_clock_settime(struct posix_clock *pc, const struct timespec *tp)
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
 	struct timespec64 ts = timespec_to_timespec64(*tp);
 
-	return  ptp->info->settime64 ?
-		ptp->info->settime64(ptp->info, &ts) :
-		ptp->info->settime(ptp->info, tp);
+	return  ptp->info->settime64(ptp->info, &ts);
 }
 
 static int ptp_clock_gettime(struct posix_clock *pc, struct timespec *tp)
@@ -120,14 +118,9 @@ static int ptp_clock_gettime(struct posix_clock *pc, struct timespec *tp)
 	struct timespec64 ts;
 	int err;
 
-	if (ptp->info->gettime64) {
-		err = ptp->info->gettime64(ptp->info, &ts);
-		if (!err)
-			*tp = timespec64_to_timespec(ts);
-	} else {
-		err = ptp->info->gettime(ptp->info, tp);
-	}
-
+	err = ptp->info->gettime64(ptp->info, &ts);
+	if (!err)
+		*tp = timespec64_to_timespec(ts);
 	return err;
 }
 
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 7d6f8e6..b8b7306 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -64,12 +64,6 @@ struct ptp_clock_request {
  * @adjtime:  Shifts the time of the hardware clock.
  *            parameter delta: Desired change in nanoseconds.
  *
- * @gettime:  Reads the current time from the hardware clock. (deprecated)
- *            parameter ts: Holds the result.
- *
- * @settime:  Set the current time on the hardware clock. (deprecated)
- *            parameter ts: Time value to set.
- *
  * @gettime64:  Reads the current time from the hardware clock.
  *              parameter ts: Holds the result.
  *
@@ -110,8 +104,6 @@ struct ptp_clock_info {
 	struct ptp_pin_desc *pin_config;
 	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
-	int (*gettime)(struct ptp_clock_info *ptp, struct timespec *ts);
-	int (*settime)(struct ptp_clock_info *ptp, const struct timespec *ts);
 	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
 	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
 	int (*enable)(struct ptp_clock_info *ptp,
-- 
1.7.10.4
