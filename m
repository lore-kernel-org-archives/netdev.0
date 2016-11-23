From: Ulrik De Bie <ulrik.debie-os@e2big.org>
Subject: [PATCH net-next 1/1] ptp: gianfar: Use high resolution frequency method.
Date: Wed, 23 Nov 2016 21:11:04 +0100
Message-ID: <20161123201104.9706-1-ulrik.debie-os@e2big.org>
Cc: David Miller <davem@davemloft.net>,
        Richard Cochran <richardcochran@gmail.com>,
        ulrik.debie-os@e2big.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2big.org ([198.61.226.133]:55116 "EHLO e2big.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933402AbcKWU3B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 15:29:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch depends on commit d8d263541913 ("ptp: Introduce a high
resolution frequency adjustment method.")

The gianfar devices offer a frequency resolution of about 0.46 ppb
(depends on actual value of tmr_add, for the calculation assumed
0x80000000). This patch lets users of the device benefit from the increased
frequency resolution when tuning the clock. Thanks to the rounding the
maximum error between the requested frequency and the applied frequency
will then be about 0.23 ppb.

Tested on a v3.3.8 kernel on a real gianfar device. Verified compilation
on net-next (currently at v4.9-rc5).

Signed-off-by: Ulrik De Bie <ulrik.debie-os@e2big.org>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 3e8d1ff..721be13 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -280,21 +280,26 @@ static irqreturn_t isr(int irq, void *priv)
  * PTP clock operations
  */
 
-static int ptp_gianfar_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+static int ptp_gianfar_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
 {
-	u64 adj;
-	u32 diff, tmr_add;
+	u64 adj, diff;
+	u32 tmr_add;
 	int neg_adj = 0;
 	struct etsects *etsects = container_of(ptp, struct etsects, caps);
 
-	if (ppb < 0) {
+	if (scaled_ppm < 0) {
 		neg_adj = 1;
-		ppb = -ppb;
+		scaled_ppm = -scaled_ppm;
 	}
 	tmr_add = etsects->tmr_add;
 	adj = tmr_add;
-	adj *= ppb;
-	diff = div_u64(adj, 1000000000ULL);
+
+	/* calculate diff as adj*(scaled_ppm/65536)/1000000
+	 * and round() to the nearest integer
+	 */
+	adj *= scaled_ppm;
+	diff = div_u64(adj, 8000000);
+	diff = (diff >> 13) + ((diff >> 12) & 1);
 
 	tmr_add = neg_adj ? tmr_add - diff : tmr_add + diff;
 
@@ -415,7 +420,7 @@ static struct ptp_clock_info ptp_gianfar_caps = {
 	.n_per_out	= 0,
 	.n_pins		= 0,
 	.pps		= 1,
-	.adjfreq	= ptp_gianfar_adjfreq,
+	.adjfine	= ptp_gianfar_adjfine,
 	.adjtime	= ptp_gianfar_adjtime,
 	.gettime64	= ptp_gianfar_gettime,
 	.settime64	= ptp_gianfar_settime,
-- 
2.10.2
