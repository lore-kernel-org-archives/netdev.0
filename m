From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 2/4] net: fec: ptp: Use hardware algorithm to adjust
 PTP counter.
Date: Mon, 29 Sep 2014 02:13:52 +0000
Message-ID: <483972bb1090495d8f90ffe6495485f0@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1411878011-21767-1-git-send-email-b45643@freescale.com>
 <1411878011-21767-3-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0137.outbound.protection.outlook.com ([65.55.169.137]:35424
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753122AbaI2CNz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 22:13:55 -0400
In-Reply-To: <1411878011-21767-3-git-send-email-b45643@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luwei Zhou <b45643@freescale.com> Sent: Sunday, September 28, 2014 12:20 PM + 0800
>To: davem@davemloft.net; richardcochran@gmail.com
>Cc: netdev@vger.kernel.org; shawn.guo@linaro.org;
>bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li
>Frank-B20596; stephen@networkplumber.org
>Subject: [PATCH v2 2/4] net: fec: ptp: Use hardware algorithm to adjust
>PTP counter.
>
>The FEC IP supports hardware adjustment for ptp timer. Refer to the
>description of ENET_ATCOR and ENET_ATINC registers in the spec about the
>hardware adjustment. This patch uses hardware support to adjust the ptp
>offset and frequency on the slave side.
>
>Signed-off-by: Luwei Zhou <b45643@freescale.com>
>Signed-off-by: Frank Li <Frank.Li@freescale.com>
>Signed-off-by: Fugang Duan <b38611@freescale.com>
>---
> drivers/net/ethernet/freescale/fec.h     |  3 ++
> drivers/net/ethernet/freescale/fec_ptp.c | 66 ++++++++++++++++++++++++++-
>-----
> 2 files changed, 57 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/net/ethernet/freescale/fec.h
>b/drivers/net/ethernet/freescale/fec.h
>index 354a309..b2e263e 100644
>--- a/drivers/net/ethernet/freescale/fec.h
>+++ b/drivers/net/ethernet/freescale/fec.h
>@@ -482,6 +482,9 @@ struct fec_enet_private {
> 	unsigned int tx_pkts_itr;
> 	unsigned int tx_time_itr;
> 	unsigned int itr_clk_rate;
>+
>+	/* ptp clock period in ns*/
>+	unsigned int ptp_inc;
> };
>
> void fec_ptp_init(struct platform_device *pdev); diff --git
>a/drivers/net/ethernet/freescale/fec_ptp.c
>b/drivers/net/ethernet/freescale/fec_ptp.c
>index 8016bdd..036d956 100644
>--- a/drivers/net/ethernet/freescale/fec_ptp.c
>+++ b/drivers/net/ethernet/freescale/fec_ptp.c
>@@ -71,6 +71,7 @@
>
> #define FEC_CC_MULT	(1 << 31)
> #define FEC_COUNTER_PERIOD	(1 << 31)
>+#define FEC_T_NSEC_PER_SEC	(1000000000UL)

Don't need redefine it, use NSEC_PER_SEC instead.
> /**
>  * fec_ptp_read - read raw cycle counter (to be used by time counter)
>  * @cc: the cyclecounter structure
>@@ -145,32 +146,59 @@ void fec_ptp_start_cyclecounter(struct net_device
>*ndev)
>  */
> static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)  {
>-	u64 diff;
> 	unsigned long flags;
> 	int neg_adj = 0;
>-	u32 mult = FEC_CC_MULT;
>+	u32 i, tmp;
>+	u32 corr_inc, corr_period;
>+	u32 corr_ns;
>+	u64 lhs, rhs;
>
> 	struct fec_enet_private *fep =
> 	    container_of(ptp, struct fec_enet_private, ptp_caps);
>
>+	if (ppb == 0)
>+		return 0;
>+
> 	if (ppb < 0) {
> 		ppb = -ppb;
> 		neg_adj = 1;
> 	}
>
>-	diff = mult;
>-	diff *= ppb;
>-	diff = div_u64(diff, 1000000000ULL);
>+	/* In theory, corr_inc/corr_period = ppb/FEC_T_NSEC_PER_SEC;
>+	 * Try to find the corr_inc  between 1 to fep->ptp_inc to
>+	 * meet adjustment requirement.
>+	 */
>+	lhs = FEC_T_NSEC_PER_SEC;
>+	rhs = (u64)ppb * (u64)fep->ptp_inc;
>+	for (i = 1; i <= fep->ptp_inc; i++) {
>+		if (lhs >= rhs) {
>+			corr_inc = i;
>+			corr_period = div_u64(lhs, rhs);
>+			break;
>+		}
>+		lhs += FEC_T_NSEC_PER_SEC;
>+	}
>+	/* Not found? Set it to high value - double speed
>+	 * correct in every clock step.
>+	 */
>+	if (i > fep->ptp_inc) {
>+		corr_inc = fep->ptp_inc;
>+		corr_period = 1;
>+	}
>+
>+	if (neg_adj)
>+		corr_ns = fep->ptp_inc - corr_inc;
>+	else
>+		corr_ns = fep->ptp_inc + corr_inc;
>
> 	spin_lock_irqsave(&fep->tmreg_lock, flags);
>-	/*
>-	 * dummy read to set cycle_last in tc to now.
>-	 * So use adjusted mult to calculate when next call
>-	 * timercounter_read.
>-	 */
>-	timecounter_read(&fep->tc);
>
>-	fep->cc.mult = neg_adj ? mult - diff : mult + diff;
>+	tmp = readl(fep->hwp + FEC_ATIME_INC) & FEC_T_INC_MASK;
>+	tmp |= corr_ns << FEC_T_INC_CORR_OFFSET;
>+	writel(tmp, fep->hwp + FEC_ATIME_INC);
>+	writel(corr_period, fep->hwp + FEC_ATIME_CORR);
>+	/* dummy read to update the timer. */
>+	timecounter_read(&fep->tc);
>
> 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>
>@@ -190,12 +218,19 @@ static int fec_ptp_adjtime(struct ptp_clock_info
>*ptp, s64 delta)
> 	    container_of(ptp, struct fec_enet_private, ptp_caps);
> 	unsigned long flags;
> 	u64 now;
>+	u32 counter;
>
> 	spin_lock_irqsave(&fep->tmreg_lock, flags);
>
> 	now = timecounter_read(&fep->tc);
> 	now += delta;
>
>+	/* Get the timer value based on adjusted timestamp.
>+	 * Update the counter with the masked value.
>+	 */
>+	counter = now & fep->cc.mask;
>+	writel(counter, fep->hwp + FEC_ATIME);
>+
> 	/* reset the timecounter */
> 	timecounter_init(&fep->tc, &fep->cc, now);
>
>@@ -246,6 +281,7 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>
> 	u64 ns;
> 	unsigned long flags;
>+	u32 counter;
>
> 	mutex_lock(&fep->ptp_clk_mutex);
> 	/* Check the ptp clock */
>@@ -256,8 +292,13 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>
> 	ns = ts->tv_sec * 1000000000ULL;
> 	ns += ts->tv_nsec;
>+	/* Get the timer value based on timestamp.
>+	 * Update the counter with the masked value.
>+	 */
>+	counter = ns & fep->cc.mask;
>
> 	spin_lock_irqsave(&fep->tmreg_lock, flags);
>+	writel(counter, fep->hwp + FEC_ATIME);
> 	timecounter_init(&fep->tc, &fep->cc, ns);
> 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> 	mutex_unlock(&fep->ptp_clk_mutex);
>@@ -396,6 +437,7 @@ void fec_ptp_init(struct platform_device *pdev)
> 	fep->ptp_caps.enable = fec_ptp_enable;
>
> 	fep->cycle_speed = clk_get_rate(fep->clk_ptp);
>+	fep->ptp_inc = FEC_T_NSEC_PER_SEC / fep->cycle_speed;
>
> 	spin_lock_init(&fep->tmreg_lock);
>
>--
>1.9.1

Regards,
Andy
