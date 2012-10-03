From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/5] ixgbe: (PTP) Fix PPS interrupt code
Date: Wed,  3 Oct 2012 15:27:08 -0700
Message-ID: <1349303231-28855-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15313 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475Ab2JCW1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 18:27:17 -0400
In-Reply-To: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Driver was enabling PPS interrupt even when user wasn't enabling it via the
ptp core. This patch fixes the PPS so that it is only enabled explicitly, and
moves the interrupt enabling code into the correct location in the driver

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Stable <stable@vger.kernel.org> [3.5+]
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 13 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 96 +++++++++++----------------
 2 files changed, 48 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 868af69..c407b2f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2322,6 +2322,12 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 	default:
 		break;
 	}
+
+#ifdef CONFIG_IXGBE_PTP
+	if (adapter->hw.mac.type == ixgbe_mac_X540)
+		mask |= IXGBE_EIMS_TIMESYNC;
+#endif
+
 	if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) &&
 	    !(adapter->flags2 & IXGBE_FLAG2_FDIR_REQUIRES_REINIT))
 		mask |= IXGBE_EIMS_FLOW_DIR;
@@ -2385,8 +2391,10 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 	}
 
 	ixgbe_check_fan_failure(adapter, eicr);
+
 #ifdef CONFIG_IXGBE_PTP
-	ixgbe_ptp_check_pps_event(adapter, eicr);
+	if (unlikely(eicr & IXGBE_EICR_TIMESYNC))
+		ixgbe_ptp_check_pps_event(adapter, eicr);
 #endif
 
 	/* re-enable the original interrupt state, no lsc, no queues */
@@ -2580,7 +2588,8 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 	ixgbe_check_fan_failure(adapter, eicr);
 #ifdef CONFIG_IXGBE_PTP
-	ixgbe_ptp_check_pps_event(adapter, eicr);
+	if (unlikely(eicr & IXGBE_EICR_TIMESYNC))
+		ixgbe_ptp_check_pps_event(adapter, eicr);
 #endif
 
 	/* would disable interrupts here but EIAM disabled it */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 58d930d..d929131 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -106,39 +106,43 @@ static struct sock_filter ptp_filter[] = {
 };
 
 /**
- * ixgbe_ptp_enable_sdp
+ * ixgbe_ptp_setup_sdp
  * @hw: the hardware private structure
- * @shift: the clock shift for calculating nanoseconds
  *
- * this function enables the clock out feature on the sdp0 for the
- * X540 device. It will create a 1second periodic output that can be
- * used as the PPS (via an interrupt).
+ * this function enables or disables the clock out feature on SDP0 for
+ * the X540 device. It will create a 1second periodic output that can
+ * be used as the PPS (via an interrupt).
  *
  * It calculates when the systime will be on an exact second, and then
  * aligns the start of the PPS signal to that value. The shift is
  * necessary because it can change based on the link speed.
  */
-static void ixgbe_ptp_enable_sdp(struct ixgbe_adapter *adapter)
+static void ixgbe_ptp_setup_sdp(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int shift = adapter->cc.shift;
 	u32 esdp, tsauxc, clktiml, clktimh, trgttiml, trgttimh, rem;
 	u64 ns = 0, clock_edge = 0;
 
-	switch (hw->mac.type) {
-	case ixgbe_mac_X540:
+	if ((adapter->flags2 & IXGBE_FLAG2_PTP_PPS_ENABLED) &&
+	    (hw->mac.type == ixgbe_mac_X540)) {
+
+		/* disable the pin first */
+		IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, 0x0);
+		IXGBE_WRITE_FLUSH(hw);
+
 		esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
 
 		/*
-		 * enable the SDP0 pin as output, and connected to the native
-		 * function for Timesync (ClockOut)
+		 * enable the SDP0 pin as output, and connected to the
+		 * native function for Timesync (ClockOut)
 		 */
 		esdp |= (IXGBE_ESDP_SDP0_DIR |
 			 IXGBE_ESDP_SDP0_NATIVE);
 
 		/*
-		 * enable the Clock Out feature on SDP0, and allow interrupts
-		 * to occur when the pin changes
+		 * enable the Clock Out feature on SDP0, and allow
+		 * interrupts to occur when the pin changes
 		 */
 		tsauxc = (IXGBE_TSAUXC_EN_CLK |
 			  IXGBE_TSAUXC_SYNCLK |
@@ -171,25 +175,10 @@ static void ixgbe_ptp_enable_sdp(struct ixgbe_adapter *adapter)
 
 		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp);
 		IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, tsauxc);
-
-		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EICR_TIMESYNC);
-		IXGBE_WRITE_FLUSH(hw);
-		break;
-	default:
-		break;
+	} else {
+		IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, 0x0);
 	}
-}
 
-/**
- * ixgbe_ptp_disable_sdp
- * @hw: the private hardware structure
- *
- * this function disables the auxiliary SDP clock out feature
- */
-static void ixgbe_ptp_disable_sdp(struct ixgbe_hw *hw)
-{
-	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EICR_TIMESYNC);
-	IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, 0);
 	IXGBE_WRITE_FLUSH(hw);
 }
 
@@ -275,7 +264,6 @@ static int ixgbe_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	unsigned long flags;
 	u64 now;
 
-	ixgbe_ptp_disable_sdp(&adapter->hw);
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
 
 	now = timecounter_read(&adapter->tc);
@@ -287,7 +275,8 @@ static int ixgbe_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 			 now);
 
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
-	ixgbe_ptp_enable_sdp(adapter);
+
+	ixgbe_ptp_setup_sdp(adapter);
 
 	return 0;
 }
@@ -337,14 +326,12 @@ static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
 	ns = ts->tv_sec * 1000000000ULL;
 	ns += ts->tv_nsec;
 
-	ixgbe_ptp_disable_sdp(&adapter->hw);
-
 	/* reset the timecounter */
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
 	timecounter_init(&adapter->tc, &adapter->cc, ns);
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 
-	ixgbe_ptp_enable_sdp(adapter);
+	ixgbe_ptp_setup_sdp(adapter);
 	return 0;
 }
 
@@ -375,8 +362,9 @@ static int ixgbe_ptp_enable(struct ptp_clock_info *ptp,
 			if (on)
 				adapter->flags2 |= IXGBE_FLAG2_PTP_PPS_ENABLED;
 			else
-				adapter->flags2 &=
-					~IXGBE_FLAG2_PTP_PPS_ENABLED;
+				adapter->flags2 &= ~IXGBE_FLAG2_PTP_PPS_ENABLED;
+
+			ixgbe_ptp_setup_sdp(adapter);
 			return 0;
 		default:
 			break;
@@ -399,21 +387,12 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ptp_clock_event event;
 
-	event.type = PTP_CLOCK_PPS;
-
-	/* Make sure ptp clock is valid, and PPS event enabled */
-	if (!adapter->ptp_clock ||
-	    !(adapter->flags2 & IXGBE_FLAG2_PTP_PPS_ENABLED))
-		return;
-
-	if (unlikely(eicr & IXGBE_EICR_TIMESYNC)) {
-		switch (hw->mac.type) {
-		case ixgbe_mac_X540:
-			ptp_clock_event(adapter->ptp_clock, &event);
-			break;
-		default:
-			break;
-		}
+	switch (hw->mac.type) {
+	case ixgbe_mac_X540:
+		ptp_clock_event(adapter->ptp_clock, &event);
+		break;
+	default:
+		break;
 	}
 }
 
@@ -831,9 +810,6 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 	if (adapter->cycle_speed == cycle_speed && timinca)
 		return;
 
-	/* disable the SDP clock out */
-	ixgbe_ptp_disable_sdp(hw);
-
 	/**
 	 * Scale the NIC cycle counter by a large factor so that
 	 * relatively small corrections to the frequency can be added
@@ -907,10 +883,11 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 
-	/* Now that the shift has been calculated and the systime
+	/*
+	 * Now that the shift has been calculated and the systime
 	 * registers reset, (re-)enable the Clock out feature
 	 */
-	ixgbe_ptp_enable_sdp(adapter);
+	ixgbe_ptp_setup_sdp(adapter);
 }
 
 /**
@@ -989,10 +966,11 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
  */
 void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
 {
-	ixgbe_ptp_disable_sdp(&adapter->hw);
-
 	/* stop the overflow check task */
-	adapter->flags2 &= ~IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED;
+	adapter->flags2 &= ~(IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED |
+			     IXGBE_FLAG2_PTP_PPS_ENABLED);
+
+	ixgbe_ptp_setup_sdp(adapter);
 
 	if (adapter->ptp_clock) {
 		ptp_clock_unregister(adapter->ptp_clock);
-- 
1.7.11.4
