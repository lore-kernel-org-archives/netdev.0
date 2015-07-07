From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next] net: igb: implement high frequency periodic output signals
Date: Tue,  7 Jul 2015 16:41:42 +0200
Message-ID: <1436280102-30310-1-git-send-email-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33908 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbbGGOlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 10:41:52 -0400
Received: by wifm2 with SMTP id m2so61801193wif.1
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 07:41:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to interrupt driven target time output events, the i210
also has two programmable clock outputs.  These clocks support periods
between 16 nanoseconds and 140 milliseconds.  This patch implements
the periodic output function using the clock outputs when possible,
falling back to the target time for longer periods.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/e1000_regs.h |  2 +
 drivers/net/ethernet/intel/igb/igb_ptp.c    | 72 +++++++++++++++++++++--------
 2 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 6f0490d..4af2870 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -104,6 +104,8 @@
 #define E1000_TRGTTIMH0  0x0B648 /* Target Time Register 0 High - RW */
 #define E1000_TRGTTIML1  0x0B64C /* Target Time Register 1 Low  - RW */
 #define E1000_TRGTTIMH1  0x0B650 /* Target Time Register 1 High - RW */
+#define E1000_FREQOUT0   0x0B654 /* Frequency Out 0 Control Register - RW */
+#define E1000_FREQOUT1   0x0B658 /* Frequency Out 1 Control Register - RW */
 #define E1000_AUXSTMPL0  0x0B65C /* Auxiliary Time Stamp 0 Register Low  - RO */
 #define E1000_AUXSTMPH0  0x0B660 /* Auxiliary Time Stamp 0 Register High - RO */
 #define E1000_AUXSTMPL1  0x0B664 /* Auxiliary Time Stamp 1 Register Low  - RO */
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index c3a9392c..5982f28 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -405,7 +405,7 @@ static void igb_pin_extts(struct igb_adapter *igb, int chan, int pin)
 	wr32(E1000_CTRL_EXT, ctrl_ext);
 }
 
-static void igb_pin_perout(struct igb_adapter *igb, int chan, int pin)
+static void igb_pin_perout(struct igb_adapter *igb, int chan, int pin, int freq)
 {
 	static const u32 aux0_sel_sdp[IGB_N_SDP] = {
 		AUX0_SEL_SDP0, AUX0_SEL_SDP1, AUX0_SEL_SDP2, AUX0_SEL_SDP3,
@@ -424,6 +424,14 @@ static void igb_pin_perout(struct igb_adapter *igb, int chan, int pin)
 		TS_SDP0_SEL_TT1, TS_SDP1_SEL_TT1,
 		TS_SDP2_SEL_TT1, TS_SDP3_SEL_TT1,
 	};
+	static const u32 ts_sdp_sel_fc0[IGB_N_SDP] = {
+		TS_SDP0_SEL_FC0, TS_SDP1_SEL_FC0,
+		TS_SDP2_SEL_FC0, TS_SDP3_SEL_FC0,
+	};
+	static const u32 ts_sdp_sel_fc1[IGB_N_SDP] = {
+		TS_SDP0_SEL_FC1, TS_SDP1_SEL_FC1,
+		TS_SDP2_SEL_FC1, TS_SDP3_SEL_FC1,
+	};
 	static const u32 ts_sdp_sel_clr[IGB_N_SDP] = {
 		TS_SDP0_SEL_FC1, TS_SDP1_SEL_FC1,
 		TS_SDP2_SEL_FC1, TS_SDP3_SEL_FC1,
@@ -445,11 +453,17 @@ static void igb_pin_perout(struct igb_adapter *igb, int chan, int pin)
 		tssdp &= ~AUX1_TS_SDP_EN;
 
 	tssdp &= ~ts_sdp_sel_clr[pin];
-	if (chan == 1)
-		tssdp |= ts_sdp_sel_tt1[pin];
-	else
-		tssdp |= ts_sdp_sel_tt0[pin];
-
+	if (freq) {
+		if (chan == 1)
+			tssdp |= ts_sdp_sel_fc1[pin];
+		else
+			tssdp |= ts_sdp_sel_fc0[pin];
+	} else {
+		if (chan == 1)
+			tssdp |= ts_sdp_sel_tt1[pin];
+		else
+			tssdp |= ts_sdp_sel_tt0[pin];
+	}
 	tssdp |= ts_sdp_en[pin];
 
 	wr32(E1000_TSSDP, tssdp);
@@ -463,10 +477,10 @@ static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
 	struct igb_adapter *igb =
 		container_of(ptp, struct igb_adapter, ptp_caps);
 	struct e1000_hw *hw = &igb->hw;
-	u32 tsauxc, tsim, tsauxc_mask, tsim_mask, trgttiml, trgttimh;
+	u32 tsauxc, tsim, tsauxc_mask, tsim_mask, trgttiml, trgttimh, freqout;
 	unsigned long flags;
 	struct timespec ts;
-	int pin = -1;
+	int use_freq = 0, pin = -1;
 	s64 ns;
 
 	switch (rq->type) {
@@ -511,40 +525,58 @@ static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
 		ts.tv_nsec = rq->perout.period.nsec;
 		ns = timespec_to_ns(&ts);
 		ns = ns >> 1;
-		if (on && ns < 500000LL) {
-			/* 2k interrupts per second is an awful lot. */
-			return -EINVAL;
+		if (on && ns <= 70000000LL) {
+			if (ns < 8LL)
+				return -EINVAL;
+			use_freq = 1;
 		}
 		ts = ns_to_timespec(ns);
 		if (rq->perout.index == 1) {
-			tsauxc_mask = TSAUXC_EN_TT1;
-			tsim_mask = TSINTR_TT1;
+			if (use_freq) {
+				tsauxc_mask = TSAUXC_EN_CLK1 | TSAUXC_ST1;
+				tsim_mask = 0;
+			} else {
+				tsauxc_mask = TSAUXC_EN_TT1;
+				tsim_mask = TSINTR_TT1;
+			}
 			trgttiml = E1000_TRGTTIML1;
 			trgttimh = E1000_TRGTTIMH1;
+			freqout = E1000_FREQOUT1;
 		} else {
-			tsauxc_mask = TSAUXC_EN_TT0;
-			tsim_mask = TSINTR_TT0;
+			if (use_freq) {
+				tsauxc_mask = TSAUXC_EN_CLK0 | TSAUXC_ST0;
+				tsim_mask = 0;
+			} else {
+				tsauxc_mask = TSAUXC_EN_TT0;
+				tsim_mask = TSINTR_TT0;
+			}
 			trgttiml = E1000_TRGTTIML0;
 			trgttimh = E1000_TRGTTIMH0;
+			freqout = E1000_FREQOUT0;
 		}
 		spin_lock_irqsave(&igb->tmreg_lock, flags);
 		tsauxc = rd32(E1000_TSAUXC);
 		tsim = rd32(E1000_TSIM);
+		if (rq->perout.index == 1) {
+			tsauxc &= ~(TSAUXC_EN_TT1 | TSAUXC_EN_CLK1 | TSAUXC_ST1);
+			tsim &= ~TSINTR_TT1;
+		} else {
+			tsauxc &= ~(TSAUXC_EN_TT0 | TSAUXC_EN_CLK0 | TSAUXC_ST0);
+			tsim &= ~TSINTR_TT0;
+		}
 		if (on) {
 			int i = rq->perout.index;
-
-			igb_pin_perout(igb, i, pin);
+			igb_pin_perout(igb, i, pin, use_freq);
 			igb->perout[i].start.tv_sec = rq->perout.start.sec;
 			igb->perout[i].start.tv_nsec = rq->perout.start.nsec;
 			igb->perout[i].period.tv_sec = ts.tv_sec;
 			igb->perout[i].period.tv_nsec = ts.tv_nsec;
 			wr32(trgttimh, rq->perout.start.sec);
 			wr32(trgttiml, rq->perout.start.nsec);
+			if (use_freq)
+				wr32(freqout, ns);
 			tsauxc |= tsauxc_mask;
 			tsim |= tsim_mask;
-		} else {
-			tsauxc &= ~tsauxc_mask;
-			tsim &= ~tsim_mask;
 		}
 		wr32(E1000_TSAUXC, tsauxc);
 		wr32(E1000_TSIM, tsim);
-- 
2.1.4
