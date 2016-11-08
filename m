From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/3] ptp: dp83640: Use the high resolution frequency method.
Date: Tue,  8 Nov 2016 22:49:18 +0100
Message-ID: <d7d35004cd2769efcd0e26b0b78d2890bd5c9d40.1478526333.git.richardcochran@gmail.com>
References: <cover.1478526333.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Manfred Rudigier <Manfred.Rudigier@omicron.at>,
        =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ulrik De Bie <ulrik.debie-os@e2big.org>,
        intel-wired-lan@lists.osuosl.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36065 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753391AbcKHVt2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:49:28 -0500
Received: by mail-wm0-f65.google.com with SMTP id c17so25324310wmc.3
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 13:49:28 -0800 (PST)
In-Reply-To: <cover.1478526333.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dp83640 has a frequency resolution of about 0.029 ppb.
This patch lets users of the device benefit from the
increased frequency resolution when tuning the clock.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 7a240fc..e2460a5 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -375,7 +375,7 @@ static int periodic_output(struct dp83640_clock *clock,
 
 /* ptp clock methods */
 
-static int ptp_dp83640_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+static int ptp_dp83640_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
 {
 	struct dp83640_clock *clock =
 		container_of(ptp, struct dp83640_clock, caps);
@@ -384,13 +384,13 @@ static int ptp_dp83640_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 	int neg_adj = 0;
 	u16 hi, lo;
 
-	if (ppb < 0) {
+	if (scaled_ppm < 0) {
 		neg_adj = 1;
-		ppb = -ppb;
+		scaled_ppm = -scaled_ppm;
 	}
-	rate = ppb;
-	rate <<= 26;
-	rate = div_u64(rate, 1953125);
+	rate = scaled_ppm;
+	rate <<= 13;
+	rate = div_u64(rate, 15625);
 
 	hi = (rate >> 16) & PTP_RATE_HI_MASK;
 	if (neg_adj)
@@ -1035,7 +1035,7 @@ static void dp83640_clock_init(struct dp83640_clock *clock, struct mii_bus *bus)
 	clock->caps.n_per_out	= N_PER_OUT;
 	clock->caps.n_pins	= DP83640_N_PINS;
 	clock->caps.pps		= 0;
-	clock->caps.adjfreq	= ptp_dp83640_adjfreq;
+	clock->caps.adjfine	= ptp_dp83640_adjfine;
 	clock->caps.adjtime	= ptp_dp83640_adjtime;
 	clock->caps.gettime64	= ptp_dp83640_gettime;
 	clock->caps.settime64	= ptp_dp83640_settime;
-- 
2.1.4
