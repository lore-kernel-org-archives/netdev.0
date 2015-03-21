From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 18/23] ptp: cpts: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 22:39:36 +0100
Message-ID: <ab9b5c33586d63ec3bcfeac5c5d9491f6e107abc.1426973658.git.richardcochran@gmail.com>
References: <cover.1426973658.git.richardcochran@gmail.com>
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
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorense
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37091 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbCUVkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 17:40:31 -0400
In-Reply-To: <cover.1426973658.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver's clock is implemented using a timecounter, and so with
this patch the driver is ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index fbe42cb..074b636 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -167,7 +167,7 @@ static int cpts_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int cpts_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int cpts_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
 	u32 remainder;
@@ -185,7 +185,7 @@ static int cpts_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int cpts_ptp_settime(struct ptp_clock_info *ptp,
-			    const struct timespec *ts)
+			    const struct timespec64 *ts)
 {
 	u64 ns;
 	unsigned long flags;
@@ -216,20 +216,20 @@ static struct ptp_clock_info cpts_info = {
 	.pps		= 0,
 	.adjfreq	= cpts_ptp_adjfreq,
 	.adjtime	= cpts_ptp_adjtime,
-	.gettime	= cpts_ptp_gettime,
-	.settime	= cpts_ptp_settime,
+	.gettime64	= cpts_ptp_gettime,
+	.settime64	= cpts_ptp_settime,
 	.enable		= cpts_ptp_enable,
 };
 
 static void cpts_overflow_check(struct work_struct *work)
 {
-	struct timespec ts;
+	struct timespec64 ts;
 	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
 
 	cpts_write32(cpts, CPTS_EN, control);
 	cpts_write32(cpts, TS_PEND_EN, int_enable);
 	cpts_ptp_gettime(&cpts->info, &ts);
-	pr_debug("cpts overflow check at %ld.%09lu\n", ts.tv_sec, ts.tv_nsec);
+	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
 	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
 }
 
-- 
1.7.10.4
