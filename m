From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces with "ktime_t" type
Date: Thu, 19 Mar 2015 13:45:07 +0800
Message-ID: <1426743909-24335-3-git-send-email-baolin.wang@linaro.org>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.stultz@linaro.com, tglx@linutronix.de, arnd@linaro.org,
	baolin.wang@linaro.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36331 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbCSFqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 01:46:34 -0400
Received: by pdbcz9 with SMTP id cz9so65606179pdb.3
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 22:46:34 -0700 (PDT)
In-Reply-To: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces another two options to get/set time with "ktime_t"
type in ptp clock operation.

Original code will set/get time through the settime/gettime interfaces
with "timespec" type, that will cause break issue in year 2038. And now
introducing the new setktime/getktime interfaces with "ktime_t" type to
use firstly.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 drivers/ptp/ptp_clock.c |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 296b0ec..46425ad 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -106,14 +106,30 @@ static int ptp_clock_getres(struct posix_clock *pc, struct timespec *tp)
 
 static int ptp_clock_settime(struct posix_clock *pc, const struct timespec *tp)
 {
+	ktime_t kt;
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
-	return ptp->info->settime(ptp->info, tp);
+
+	if (ptp->info->setktime) {
+		kt = timespec_to_ktime(*tp);
+		return ptp->info->setktime(ptp->info, kt);
+	} else {
+		return ptp->info->settime(ptp->info, tp);
+	}
 }
 
 static int ptp_clock_gettime(struct posix_clock *pc, struct timespec *tp)
 {
+	ktime_t kt;
+	int ret;
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
-	return ptp->info->gettime(ptp->info, tp);
+
+	if (ptp->info->getktime) {
+		ret = ptp->info->getktime(ptp->info, &kt);
+		*tp = ktime_to_timespec(kt);
+		return ret;
+	} else {
+		return ptp->info->gettime(ptp->info, tp);
+	}
 }
 
 static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
-- 
1.7.9.5
