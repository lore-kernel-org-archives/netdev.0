From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 3/4] ptp/pch:Replace timespec with ktime_t in ptp_pch.c
Date: Thu, 19 Mar 2015 13:45:08 +0800
Message-ID: <1426743909-24335-4-git-send-email-baolin.wang@linaro.org>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.stultz@linaro.com, tglx@linutronix.de, arnd@linaro.org,
	baolin.wang@linaro.org
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the 32-bit time type (timespec) to the 64-bit one
(ktime_t), since 32-bit time types will break in the year 2038.

This patch implements the getktime/setktime interfaces with
"ktime_t" type, and removed the gettime/settime interfaces with
"timespec" type in ptp_pch.c file.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 drivers/ptp/ptp_pch.c |   21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 2554872..c759225 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -449,36 +449,27 @@ static int ptp_pch_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int ptp_pch_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_pch_getktime(struct ptp_clock_info *ptp, ktime_t *kt)
 {
-	u64 ns;
-	u32 remainder;
 	unsigned long flags;
 	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
 	struct pch_ts_regs __iomem *regs = pch_dev->regs;
 
 	spin_lock_irqsave(&pch_dev->register_lock, flags);
-	ns = pch_systime_read(regs);
+	*kt = ns_to_ktime(pch_systime_read(regs));
 	spin_unlock_irqrestore(&pch_dev->register_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
-	ts->tv_nsec = remainder;
 	return 0;
 }
 
-static int ptp_pch_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *ts)
+static int ptp_pch_setktime(struct ptp_clock_info *ptp, ktime_t kt)
 {
-	u64 ns;
 	unsigned long flags;
 	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
 	struct pch_ts_regs __iomem *regs = pch_dev->regs;
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
-
 	spin_lock_irqsave(&pch_dev->register_lock, flags);
-	pch_systime_write(regs, ns);
+	pch_systime_write(regs, ktime_to_ns(kt));
 	spin_unlock_irqrestore(&pch_dev->register_lock, flags);
 
 	return 0;
@@ -518,8 +509,8 @@ static struct ptp_clock_info ptp_pch_caps = {
 	.pps		= 0,
 	.adjfreq	= ptp_pch_adjfreq,
 	.adjtime	= ptp_pch_adjtime,
-	.gettime	= ptp_pch_gettime,
-	.settime	= ptp_pch_settime,
+	.getktime	= ptp_pch_getktime,
+	.setktime	= ptp_pch_setktime,
 	.enable		= ptp_pch_enable,
 };
 
-- 
1.7.9.5
