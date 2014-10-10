From: Luwei Zhou <b45643@freescale.com>
Subject: [PATCH v3 2/3] net: fec: ptp: Use hardware algorithm to adjust PTP counter.
Date: Fri, 10 Oct 2014 13:15:29 +0800
Message-ID: <1412918130-18830-3-git-send-email-b45643@freescale.com>
References: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<b38611@freescale.com>, <b20596@freescale.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0103.outbound.protection.outlook.com ([157.56.110.103]:48672
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750982AbaJJGUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 02:20:34 -0400
In-Reply-To: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FEC IP supports hardware adjustment for ptp timer. Refer to the description of
ENET_ATCOR and ENET_ATINC registers in the spec about the hardware adjustment. This
patch uses hardware support to adjust the ptp offset and frequency on the slave side.

Signed-off-by: Luwei Zhou <b45643@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
Signed-off-by: Fugang Duan <b38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h     |  3 ++
 drivers/net/ethernet/freescale/fec_ptp.c | 65 ++++++++++++++++++++++++++------
 2 files changed, 56 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 1d5e182..b0e6025 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -484,6 +484,9 @@ struct fec_enet_private {
 	unsigned int itr_clk_rate;
 
 	u32 rx_copybreak;
+
+	/* ptp clock period in ns*/
+	unsigned int ptp_inc;
 };
 
 void fec_ptp_init(struct platform_device *pdev);
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 8016bdd..f5ee460 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -145,32 +145,59 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
  */
 static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 {
-	u64 diff;
 	unsigned long flags;
 	int neg_adj = 0;
-	u32 mult = FEC_CC_MULT;
+	u32 i, tmp;
+	u32 corr_inc, corr_period;
+	u32 corr_ns;
+	u64 lhs, rhs;
 
 	struct fec_enet_private *fep =
 	    container_of(ptp, struct fec_enet_private, ptp_caps);
 
+	if (ppb == 0)
+		return 0;
+
 	if (ppb < 0) {
 		ppb = -ppb;
 		neg_adj = 1;
 	}
 
-	diff = mult;
-	diff *= ppb;
-	diff = div_u64(diff, 1000000000ULL);
+	/* In theory, corr_inc/corr_period = ppb/NSEC_PER_SEC;
+	 * Try to find the corr_inc  between 1 to fep->ptp_inc to
+	 * meet adjustment requirement.
+	 */
+	lhs = NSEC_PER_SEC;
+	rhs = (u64)ppb * (u64)fep->ptp_inc;
+	for (i = 1; i <= fep->ptp_inc; i++) {
+		if (lhs >= rhs) {
+			corr_inc = i;
+			corr_period = div_u64(lhs, rhs);
+			break;
+		}
+		lhs += NSEC_PER_SEC;
+	}
+	/* Not found? Set it to high value - double speed
+	 * correct in every clock step.
+	 */
+	if (i > fep->ptp_inc) {
+		corr_inc = fep->ptp_inc;
+		corr_period = 1;
+	}
+
+	if (neg_adj)
+		corr_ns = fep->ptp_inc - corr_inc;
+	else
+		corr_ns = fep->ptp_inc + corr_inc;
 
 	spin_lock_irqsave(&fep->tmreg_lock, flags);
-	/*
-	 * dummy read to set cycle_last in tc to now.
-	 * So use adjusted mult to calculate when next call
-	 * timercounter_read.
-	 */
-	timecounter_read(&fep->tc);
 
-	fep->cc.mult = neg_adj ? mult - diff : mult + diff;
+	tmp = readl(fep->hwp + FEC_ATIME_INC) & FEC_T_INC_MASK;
+	tmp |= corr_ns << FEC_T_INC_CORR_OFFSET;
+	writel(tmp, fep->hwp + FEC_ATIME_INC);
+	writel(corr_period, fep->hwp + FEC_ATIME_CORR);
+	/* dummy read to update the timer. */
+	timecounter_read(&fep->tc);
 
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 
@@ -190,12 +217,19 @@ static int fec_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	    container_of(ptp, struct fec_enet_private, ptp_caps);
 	unsigned long flags;
 	u64 now;
+	u32 counter;
 
 	spin_lock_irqsave(&fep->tmreg_lock, flags);
 
 	now = timecounter_read(&fep->tc);
 	now += delta;
 
+	/* Get the timer value based on adjusted timestamp.
+	 * Update the counter with the masked value.
+	 */
+	counter = now & fep->cc.mask;
+	writel(counter, fep->hwp + FEC_ATIME);
+
 	/* reset the timecounter */
 	timecounter_init(&fep->tc, &fep->cc, now);
 
@@ -246,6 +280,7 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
 
 	u64 ns;
 	unsigned long flags;
+	u32 counter;
 
 	mutex_lock(&fep->ptp_clk_mutex);
 	/* Check the ptp clock */
@@ -256,8 +291,13 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
 
 	ns = ts->tv_sec * 1000000000ULL;
 	ns += ts->tv_nsec;
+	/* Get the timer value based on timestamp.
+	 * Update the counter with the masked value.
+	 */
+	counter = ns & fep->cc.mask;
 
 	spin_lock_irqsave(&fep->tmreg_lock, flags);
+	writel(counter, fep->hwp + FEC_ATIME);
 	timecounter_init(&fep->tc, &fep->cc, ns);
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 	mutex_unlock(&fep->ptp_clk_mutex);
@@ -396,6 +436,7 @@ void fec_ptp_init(struct platform_device *pdev)
 	fep->ptp_caps.enable = fec_ptp_enable;
 
 	fep->cycle_speed = clk_get_rate(fep->clk_ptp);
+	fep->ptp_inc = NSEC_PER_SEC / fep->cycle_speed;
 
 	spin_lock_init(&fep->tmreg_lock);
 
-- 
1.9.1
