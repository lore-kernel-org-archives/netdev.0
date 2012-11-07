From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 2/2] net: fec: reduce spin lock time in fec_ptp_adjfreq
Date: Wed, 7 Nov 2012 14:14:49 +0800
Message-ID: <1352268889-16836-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.or>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:36730 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751616Ab2KGG5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 01:57:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

move below calculate out of spin lock section
	diff = fep->cc.mult;
	diff *= ppb;
	diff = div_u64(diff, 1000000000ULL);

diff is local variable and not neccesary in spin lock

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 5352140..c40526c 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -145,6 +145,7 @@ static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 	u64 diff;
 	unsigned long flags;
 	int neg_adj = 0;
+	u32 mult = FEC_CC_MULT;
 
 	struct fec_enet_private *fep =
 	    container_of(ptp, struct fec_enet_private, ptp_caps);
@@ -154,6 +155,10 @@ static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 		neg_adj = 1;
 	}
 
+	diff = mult;
+	diff *= ppb;
+	diff = div_u64(diff, 1000000000ULL);
+
 	spin_lock_irqsave(&fep->tmreg_lock, flags);
 	/*
 	 * dummy read to set cycle_last in tc to now.
@@ -161,15 +166,8 @@ static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 	 * timercounter_read.
 	 */
 	timecounter_read(&fep->tc);
-	fep->cc.mult = FEC_CC_MULT;
-	diff = fep->cc.mult;
-	diff *= ppb;
-	diff = div_u64(diff, 1000000000ULL);
 
-	if (neg_adj)
-		fep->cc.mult -= diff;
-	else
-		fep->cc.mult += diff;
+	fep->cc.mult = neg_adj ? mult - diff : mult + diff;
 
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 
-- 
1.7.1
