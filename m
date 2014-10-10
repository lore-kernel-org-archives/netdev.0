From: Luwei Zhou <b45643@freescale.com>
Subject: [PATCH v3 1/3] net: fec: ptp: Use the 31-bit ptp timer.
Date: Fri, 10 Oct 2014 13:15:28 +0800
Message-ID: <1412918130-18830-2-git-send-email-b45643@freescale.com>
References: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<b38611@freescale.com>, <b20596@freescale.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0111.outbound.protection.outlook.com ([65.55.169.111]:37055
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751337AbaJJGfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 02:35:24 -0400
In-Reply-To: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ptp switches from software adjustment to hardware ajustment, linux ptp can't converge.
It is caused by the IP limit. Hardware adjustment logcial have issue when ptp counter
runs over 0x80000000(31 bit counter). The internal IP reference manual already remove 32bit
free-running count support. This patch replace the 32-bit PTP timer with 31-bit.

Signed-off-by: Luwei Zhou <b45643@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index cca3617..8016bdd 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -70,6 +70,7 @@
 #define FEC_TS_TIMESTAMP	0x418
 
 #define FEC_CC_MULT	(1 << 31)
+#define FEC_COUNTER_PERIOD	(1 << 31)
 /**
  * fec_ptp_read - read raw cycle counter (to be used by time counter)
  * @cc: the cyclecounter structure
@@ -113,14 +114,15 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
 	/* 1ns counter */
 	writel(inc << FEC_T_INC_OFFSET, fep->hwp + FEC_ATIME_INC);
 
-	/* use free running count */
-	writel(0, fep->hwp + FEC_ATIME_EVT_PERIOD);
+	/* use 31-bit timer counter */
+	writel(FEC_COUNTER_PERIOD, fep->hwp + FEC_ATIME_EVT_PERIOD);
 
-	writel(FEC_T_CTRL_ENABLE, fep->hwp + FEC_ATIME_CTRL);
+	writel(FEC_T_CTRL_ENABLE | FEC_T_CTRL_PERIOD_RST,
+		fep->hwp + FEC_ATIME_CTRL);
 
 	memset(&fep->cc, 0, sizeof(fep->cc));
 	fep->cc.read = fec_ptp_read;
-	fep->cc.mask = CLOCKSOURCE_MASK(32);
+	fep->cc.mask = CLOCKSOURCE_MASK(31);
 	fep->cc.shift = 31;
 	fep->cc.mult = FEC_CC_MULT;
 
-- 
1.9.1
