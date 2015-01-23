From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] igb: enable auxiliary PHC functions for the i210
Date: Thu, 22 Jan 2015 18:37:05 -0800
Message-ID: <1421980631-1955-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16348 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753800AbbAWChT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:19 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>

The i210 device offers a number of special PTP Hardware Clock features on
the Software Defined Pins (SDPs). This patch adds support for two of the
possible functions, namely time stamping external events, and periodic
output signals.

The assignment of PHC functions to the four SDP can be freely chosen by
the user.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |   9 ++
 drivers/net/ethernet/intel/igb/igb_main.c |  51 ++++++-
 drivers/net/ethernet/intel/igb/igb_ptp.c  | 222 +++++++++++++++++++++++++++++-
 3 files changed, 276 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index ee22da3..c2bd4f9 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -343,6 +343,9 @@ struct hwmon_buff {
 	};
 #endif
 
+#define IGB_N_EXTTS	2
+#define IGB_N_PEROUT	2
+#define IGB_N_SDP	4
 #define IGB_RETA_SIZE	128
 
 /* board specific private data structure */
@@ -439,6 +442,12 @@ struct igb_adapter {
 	u32 tx_hwtstamp_timeouts;
 	u32 rx_hwtstamp_cleared;
 
+	struct ptp_pin_desc sdp_config[IGB_N_SDP];
+	struct {
+		struct timespec start;
+		struct timespec period;
+	} perout[IGB_N_PEROUT];
+
 	char fw_version[32];
 #ifdef CONFIG_IGB_HWMON
 	struct hwmon_buff *igb_hwmon_buff;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e844162..6e65449 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5388,7 +5388,8 @@ static void igb_tsync_interrupt(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct ptp_clock_event event;
-	u32 ack = 0, tsicr = rd32(E1000_TSICR);
+	struct timespec ts;
+	u32 ack = 0, tsauxc, sec, nsec, tsicr = rd32(E1000_TSICR);
 
 	if (tsicr & TSINTR_SYS_WRAP) {
 		event.type = PTP_CLOCK_PPS;
@@ -5405,6 +5406,54 @@ static void igb_tsync_interrupt(struct igb_adapter *adapter)
 		ack |= E1000_TSICR_TXTS;
 	}
 
+	if (tsicr & TSINTR_TT0) {
+		spin_lock(&adapter->tmreg_lock);
+		ts = timespec_add(adapter->perout[0].start,
+				  adapter->perout[0].period);
+		wr32(E1000_TRGTTIML0, ts.tv_nsec);
+		wr32(E1000_TRGTTIMH0, ts.tv_sec);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsauxc |= TSAUXC_EN_TT0;
+		wr32(E1000_TSAUXC, tsauxc);
+		adapter->perout[0].start = ts;
+		spin_unlock(&adapter->tmreg_lock);
+		ack |= TSINTR_TT0;
+	}
+
+	if (tsicr & TSINTR_TT1) {
+		spin_lock(&adapter->tmreg_lock);
+		ts = timespec_add(adapter->perout[1].start,
+				  adapter->perout[1].period);
+		wr32(E1000_TRGTTIML1, ts.tv_nsec);
+		wr32(E1000_TRGTTIMH1, ts.tv_sec);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsauxc |= TSAUXC_EN_TT1;
+		wr32(E1000_TSAUXC, tsauxc);
+		adapter->perout[1].start = ts;
+		spin_unlock(&adapter->tmreg_lock);
+		ack |= TSINTR_TT1;
+	}
+
+	if (tsicr & TSINTR_AUTT0) {
+		nsec = rd32(E1000_AUXSTMPL0);
+		sec  = rd32(E1000_AUXSTMPH0);
+		event.type = PTP_CLOCK_EXTTS;
+		event.index = 0;
+		event.timestamp = sec * 1000000000ULL + nsec;
+		ptp_clock_event(adapter->ptp_clock, &event);
+		ack |= TSINTR_AUTT0;
+	}
+
+	if (tsicr & TSINTR_AUTT1) {
+		nsec = rd32(E1000_AUXSTMPL1);
+		sec  = rd32(E1000_AUXSTMPH1);
+		event.type = PTP_CLOCK_EXTTS;
+		event.index = 1;
+		event.timestamp = sec * 1000000000ULL + nsec;
+		ptp_clock_event(adapter->ptp_clock, &event);
+		ack |= TSINTR_AUTT1;
+	}
+
 	/* acknowledge the interrupts */
 	wr32(E1000_TSICR, ack);
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 98c58d9..d20fc8e 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -355,16 +355,204 @@ static int igb_ptp_settime_i210(struct ptp_clock_info *ptp,
 	return 0;
 }
 
+static void igb_pin_direction(int pin, int input, u32 *ctrl, u32 *ctrl_ext)
+{
+	u32 *ptr = pin < 2 ? ctrl : ctrl_ext;
+	u32 mask[IGB_N_SDP] = {
+		E1000_CTRL_SDP0_DIR,
+		E1000_CTRL_SDP1_DIR,
+		E1000_CTRL_EXT_SDP2_DIR,
+		E1000_CTRL_EXT_SDP3_DIR,
+	};
+
+	if (input)
+		*ptr &= ~mask[pin];
+	else
+		*ptr |= mask[pin];
+}
+
+static void igb_pin_extts(struct igb_adapter *igb, int chan, int pin)
+{
+	struct e1000_hw *hw = &igb->hw;
+	u32 aux0_sel_sdp[IGB_N_SDP] = {
+		AUX0_SEL_SDP0, AUX0_SEL_SDP1, AUX0_SEL_SDP2, AUX0_SEL_SDP3,
+	};
+	u32 aux1_sel_sdp[IGB_N_SDP] = {
+		AUX1_SEL_SDP0, AUX1_SEL_SDP1, AUX1_SEL_SDP2, AUX1_SEL_SDP3,
+	};
+	u32 ts_sdp_en[IGB_N_SDP] = {
+		TS_SDP0_EN, TS_SDP1_EN, TS_SDP2_EN, TS_SDP3_EN,
+	};
+	u32 ctrl, ctrl_ext, tssdp = 0;
+
+	ctrl = rd32(E1000_CTRL);
+	ctrl_ext = rd32(E1000_CTRL_EXT);
+	tssdp = rd32(E1000_TSSDP);
+
+	igb_pin_direction(pin, 1, &ctrl, &ctrl_ext);
+
+	/* Make sure this pin is not enabled as an output. */
+	tssdp &= ~ts_sdp_en[pin];
+
+	if (chan == 1) {
+		tssdp &= ~AUX1_SEL_SDP3;
+		tssdp |= aux1_sel_sdp[pin] | AUX1_TS_SDP_EN;
+	} else {
+		tssdp &= ~AUX0_SEL_SDP3;
+		tssdp |= aux0_sel_sdp[pin] | AUX0_TS_SDP_EN;
+	}
+
+	wr32(E1000_TSSDP, tssdp);
+	wr32(E1000_CTRL, ctrl);
+	wr32(E1000_CTRL_EXT, ctrl_ext);
+}
+
+static void igb_pin_perout(struct igb_adapter *igb, int chan, int pin)
+{
+	struct e1000_hw *hw = &igb->hw;
+	u32 aux0_sel_sdp[IGB_N_SDP] = {
+		AUX0_SEL_SDP0, AUX0_SEL_SDP1, AUX0_SEL_SDP2, AUX0_SEL_SDP3,
+	};
+	u32 aux1_sel_sdp[IGB_N_SDP] = {
+		AUX1_SEL_SDP0, AUX1_SEL_SDP1, AUX1_SEL_SDP2, AUX1_SEL_SDP3,
+	};
+	u32 ts_sdp_en[IGB_N_SDP] = {
+		TS_SDP0_EN, TS_SDP1_EN, TS_SDP2_EN, TS_SDP3_EN,
+	};
+	u32 ts_sdp_sel_tt0[IGB_N_SDP] = {
+		TS_SDP0_SEL_TT0, TS_SDP1_SEL_TT0,
+		TS_SDP2_SEL_TT0, TS_SDP3_SEL_TT0,
+	};
+	u32 ts_sdp_sel_tt1[IGB_N_SDP] = {
+		TS_SDP0_SEL_TT1, TS_SDP1_SEL_TT1,
+		TS_SDP2_SEL_TT1, TS_SDP3_SEL_TT1,
+	};
+	u32 ts_sdp_sel_clr[IGB_N_SDP] = {
+		TS_SDP0_SEL_FC1, TS_SDP1_SEL_FC1,
+		TS_SDP2_SEL_FC1, TS_SDP3_SEL_FC1,
+	};
+	u32 ctrl, ctrl_ext, tssdp = 0;
+
+	ctrl = rd32(E1000_CTRL);
+	ctrl_ext = rd32(E1000_CTRL_EXT);
+	tssdp = rd32(E1000_TSSDP);
+
+	igb_pin_direction(pin, 0, &ctrl, &ctrl_ext);
+
+	/* Make sure this pin is not enabled as an input. */
+	if ((tssdp & AUX0_SEL_SDP3) == aux0_sel_sdp[pin])
+		tssdp &= ~AUX0_TS_SDP_EN;
+
+	if ((tssdp & AUX1_SEL_SDP3) == aux1_sel_sdp[pin])
+		tssdp &= ~AUX1_TS_SDP_EN;
+
+	tssdp &= ~ts_sdp_sel_clr[pin];
+	if (chan == 1)
+		tssdp |= ts_sdp_sel_tt1[pin];
+	else
+		tssdp |= ts_sdp_sel_tt0[pin];
+
+	tssdp |= ts_sdp_en[pin];
+
+	wr32(E1000_TSSDP, tssdp);
+	wr32(E1000_CTRL, ctrl);
+	wr32(E1000_CTRL_EXT, ctrl_ext);
+}
+
 static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
 				       struct ptp_clock_request *rq, int on)
 {
 	struct igb_adapter *igb =
 		container_of(ptp, struct igb_adapter, ptp_caps);
 	struct e1000_hw *hw = &igb->hw;
+	u32 tsauxc, tsim, tsauxc_mask, tsim_mask, trgttiml, trgttimh;
 	unsigned long flags;
-	u32 tsim;
+	struct timespec ts;
+	int pin;
+	s64 ns;
 
 	switch (rq->type) {
+	case PTP_CLK_REQ_EXTTS:
+		if (on) {
+			pin = ptp_find_pin(igb->ptp_clock, PTP_PF_EXTTS,
+					   rq->extts.index);
+			if (pin < 0)
+				return -EBUSY;
+		}
+		if (rq->extts.index == 1) {
+			tsauxc_mask = TSAUXC_EN_TS1;
+			tsim_mask = TSINTR_AUTT1;
+		} else {
+			tsauxc_mask = TSAUXC_EN_TS0;
+			tsim_mask = TSINTR_AUTT0;
+		}
+		spin_lock_irqsave(&igb->tmreg_lock, flags);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsim = rd32(E1000_TSIM);
+		if (on) {
+			igb_pin_extts(igb, rq->extts.index, pin);
+			tsauxc |= tsauxc_mask;
+			tsim |= tsim_mask;
+		} else {
+			tsauxc &= ~tsauxc_mask;
+			tsim &= ~tsim_mask;
+		}
+		wr32(E1000_TSAUXC, tsauxc);
+		wr32(E1000_TSIM, tsim);
+		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+		return 0;
+
+	case PTP_CLK_REQ_PEROUT:
+		if (on) {
+			pin = ptp_find_pin(igb->ptp_clock, PTP_PF_PEROUT,
+					   rq->perout.index);
+			if (pin < 0)
+				return -EBUSY;
+		}
+		ts.tv_sec = rq->perout.period.sec;
+		ts.tv_nsec = rq->perout.period.nsec;
+		ns = timespec_to_ns(&ts);
+		ns = ns >> 1;
+		if (on && ns < 500000LL) {
+			/* 2k interrupts per second is an awful lot. */
+			return -EINVAL;
+		}
+		ts = ns_to_timespec(ns);
+		if (rq->perout.index == 1) {
+			tsauxc_mask = TSAUXC_EN_TT1;
+			tsim_mask = TSINTR_TT1;
+			trgttiml = E1000_TRGTTIML1;
+			trgttimh = E1000_TRGTTIMH1;
+		} else {
+			tsauxc_mask = TSAUXC_EN_TT0;
+			tsim_mask = TSINTR_TT0;
+			trgttiml = E1000_TRGTTIML0;
+			trgttimh = E1000_TRGTTIMH0;
+		}
+		spin_lock_irqsave(&igb->tmreg_lock, flags);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsim = rd32(E1000_TSIM);
+		if (on) {
+			int i = rq->perout.index;
+
+			igb_pin_perout(igb, i, pin);
+			igb->perout[i].start.tv_sec = rq->perout.start.sec;
+			igb->perout[i].start.tv_nsec = rq->perout.start.nsec;
+			igb->perout[i].period.tv_sec = ts.tv_sec;
+			igb->perout[i].period.tv_nsec = ts.tv_nsec;
+			wr32(trgttiml, rq->perout.start.sec);
+			wr32(trgttimh, rq->perout.start.nsec);
+			tsauxc |= tsauxc_mask;
+			tsim |= tsim_mask;
+		} else {
+			tsauxc &= ~tsauxc_mask;
+			tsim &= ~tsim_mask;
+		}
+		wr32(E1000_TSAUXC, tsauxc);
+		wr32(E1000_TSIM, tsim);
+		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+		return 0;
+
 	case PTP_CLK_REQ_PPS:
 		spin_lock_irqsave(&igb->tmreg_lock, flags);
 		tsim = rd32(E1000_TSIM);
@@ -375,9 +563,6 @@ static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
 		wr32(E1000_TSIM, tsim);
 		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
 		return 0;
-
-	default:
-		break;
 	}
 
 	return -EOPNOTSUPP;
@@ -389,6 +574,20 @@ static int igb_ptp_feature_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
+static int igb_ptp_verify_pin(struct ptp_clock_info *ptp, unsigned int pin,
+			      enum ptp_pin_function func, unsigned int chan)
+{
+	switch (func) {
+	case PTP_PF_NONE:
+	case PTP_PF_EXTTS:
+	case PTP_PF_PEROUT:
+		break;
+	case PTP_PF_PHYSYNC:
+		return -1;
+	}
+	return 0;
+}
+
 /**
  * igb_ptp_tx_work
  * @work: pointer to work struct
@@ -779,6 +978,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
+	int i;
 
 	switch (hw->mac.type) {
 	case e1000_82576:
@@ -821,16 +1021,27 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		break;
 	case e1000_i210:
 	case e1000_i211:
+		for (i = 0; i < IGB_N_SDP; i++) {
+			struct ptp_pin_desc *ppd = &adapter->sdp_config[i];
+
+			snprintf(ppd->name, sizeof(ppd->name), "SDP%d", i);
+			ppd->index = i;
+			ppd->func = PTP_PF_NONE;
+		}
 		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 62499999;
-		adapter->ptp_caps.n_ext_ts = 0;
+		adapter->ptp_caps.n_ext_ts = IGB_N_EXTTS;
+		adapter->ptp_caps.n_per_out = IGB_N_PEROUT;
+		adapter->ptp_caps.n_pins = IGB_N_SDP;
 		adapter->ptp_caps.pps = 1;
+		adapter->ptp_caps.pin_config = adapter->sdp_config;
 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82580;
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_i210;
 		adapter->ptp_caps.gettime = igb_ptp_gettime_i210;
 		adapter->ptp_caps.settime = igb_ptp_settime_i210;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable_i210;
+		adapter->ptp_caps.verify = igb_ptp_verify_pin;
 		/* Enable the timer functions by clearing bit 31. */
 		wr32(E1000_TSAUXC, 0x0);
 		break;
@@ -949,6 +1160,7 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	case e1000_i210:
 	case e1000_i211:
 		wr32(E1000_TSAUXC, 0x0);
+		wr32(E1000_TSSDP, 0x0);
 		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
 		wr32(E1000_IMS, E1000_IMS_TS);
 		break;
-- 
1.9.3
