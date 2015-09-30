From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 01/12] net: fec: avoid timespec use
Date: Wed, 30 Sep 2015 13:26:31 +0200
Message-ID: <1443612402-3000775-2-git-send-email-arnd@arndb.de>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Fugang Duan <b38611@freescale.com>,
	Luwei Zhou <b45643@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:64318 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932661AbbI3L1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 07:27:03 -0400
In-Reply-To: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fec_ptp_enable_pps uses an open-coded implementation of ns_to_timespec,
which will be removed eventually as it is not y2038-safe on 32-bit
architectures. Two more instances of the same code in this file were
already converted to use the safe ns_to_timespec64 in commit 6630514fcee
("ptp: fec: use helpers for converting ns to timespec"), this changes
the last one as well.

The seconds portion here is actually unused and we could just remove the
timespec variable, but using ns_to_timespec64 can still be better as the
implementation can be hand-optimized in the future.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Fugang Duan <b38611@freescale.com>
Cc: Luwei Zhou <b45643@freescale.com>
Cc: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 1543cf0e8ef6..f9e74461bdc0 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -112,9 +112,8 @@ static int fec_ptp_enable_pps(struct fec_enet_private *fep, uint enable)
 	unsigned long flags;
 	u32 val, tempval;
 	int inc;
-	struct timespec ts;
+	struct timespec64 ts;
 	u64 ns;
-	u32 remainder;
 	val = 0;
 
 	if (!(fep->hwts_tx_en || fep->hwts_rx_en)) {
@@ -163,8 +162,7 @@ static int fec_ptp_enable_pps(struct fec_enet_private *fep, uint enable)
 		tempval = readl(fep->hwp + FEC_ATIME);
 		/* Convert the ptp local counter to 1588 timestamp */
 		ns = timecounter_cyc2time(&fep->tc, tempval);
-		ts.tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
-		ts.tv_nsec = remainder;
+		ts = ns_to_timespec64(ns);
 
 		/* The tempval is  less than 3 seconds, and  so val is less than
 		 * 4 seconds. No overflow for 32bit calculation.
-- 
2.1.0.rc2
