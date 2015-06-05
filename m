From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH net-next 1/1] net: fec: ptp: correct the ENET_ATCOR value
Date: Fri, 5 Jun 2015 17:22:08 +0800
Message-ID: <1433496128-3102-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <B20596@freescale.com>,
	<b38611@freescale.com>
To: <richardcochran@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0114.outbound.protection.outlook.com ([157.56.110.114]:58176
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751669AbbFEJYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2015 05:24:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>

The current driver adjust freq formula is:
fe * diff = ppb * pc
Note:
  fe: ENET ref clock frequency in Hz
  diff = inc_corr - inc: difference between default increment and correction increment
  ppb: parts per billion adjustment from base
  pc: correction period (in number of fe clock cycles)

The correction increment will be used after N cycles of regular increments,
not every N cycles (with N being the correction period). For example, set ENET_ATCOR=4,
INC=8, INC_CORR=9, there will be 4 increments of 8 (ENET_ATINC[INC]) , followed by 1
increment of 9 (ENET_ATINC[INC_CORR]).

So, the correct formula is:
	fe * diff = ppb * (pc + 1)

For ENET_ATCOR, a value 0 disables the correction counter and no corrections occur.
So base on the origin formula, set pc = pc > 1 ? pc - 1 : pc.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 2daf42e..9eb81fa 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -353,6 +353,7 @@ static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 	tmp = readl(fep->hwp + FEC_ATIME_INC) & FEC_T_INC_MASK;
 	tmp |= corr_ns << FEC_T_INC_CORR_OFFSET;
 	writel(tmp, fep->hwp + FEC_ATIME_INC);
+	corr_period = corr_period > 1 ? corr_period - 1 : corr_period;
 	writel(corr_period, fep->hwp + FEC_ATIME_CORR);
 	/* dummy read to update the timer. */
 	timecounter_read(&fep->tc);
-- 
1.7.8
