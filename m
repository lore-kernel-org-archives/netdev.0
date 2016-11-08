From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/3] ptp: igb: Use the high resolution frequency method.
Date: Tue,  8 Nov 2016 22:49:17 +0100
Message-ID: <b1d732324e0b1960b294e90ca5eb2a31b6559188.1478526333.git.richardcochran@gmail.com>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33062 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754100AbcKHVt1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:49:27 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so25376399wmu.0
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 13:49:27 -0800 (PST)
In-Reply-To: <cover.1478526333.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 82580 and related devices offer a frequency resolution of about
0.029 ppb.  This patch lets users of the device benefit from the
increased frequency resolution when tuning the clock.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index a7895c4..c30eea8 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -226,7 +226,7 @@ static int igb_ptp_adjfreq_82576(struct ptp_clock_info *ptp, s32 ppb)
 	return 0;
 }
 
-static int igb_ptp_adjfreq_82580(struct ptp_clock_info *ptp, s32 ppb)
+static int igb_ptp_adjfine_82580(struct ptp_clock_info *ptp, long scaled_ppm)
 {
 	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
 					       ptp_caps);
@@ -235,13 +235,13 @@ static int igb_ptp_adjfreq_82580(struct ptp_clock_info *ptp, s32 ppb)
 	u64 rate;
 	u32 inca;
 
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
 
 	inca = rate & INCVALUE_MASK;
 	if (neg_adj)
@@ -1103,7 +1103,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.max_adj = 62499999;
 		adapter->ptp_caps.n_ext_ts = 0;
 		adapter->ptp_caps.pps = 0;
-		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82580;
+		adapter->ptp_caps.adjfine = igb_ptp_adjfine_82580;
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_82576;
 		adapter->ptp_caps.gettime64 = igb_ptp_gettime_82576;
 		adapter->ptp_caps.settime64 = igb_ptp_settime_82576;
@@ -1131,7 +1131,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.n_pins = IGB_N_SDP;
 		adapter->ptp_caps.pps = 1;
 		adapter->ptp_caps.pin_config = adapter->sdp_config;
-		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82580;
+		adapter->ptp_caps.adjfine = igb_ptp_adjfine_82580;
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_i210;
 		adapter->ptp_caps.gettime64 = igb_ptp_gettime_i210;
 		adapter->ptp_caps.settime64 = igb_ptp_settime_i210;
-- 
2.1.4
