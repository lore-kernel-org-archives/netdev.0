From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/5] ixgbe: Fix PTP X540 SDP alignment code for PPS signal
Date: Wed,  3 Oct 2012 15:27:07 -0700
Message-ID: <1349303231-28855-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15313 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756633Ab2JCW1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 18:27:16 -0400
In-Reply-To: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes a bug in the method used for calculating the trigger
alignment for SDP0 when enabling a PPS output on the X540. The alignment math
wasn't properly taking into account the overflow cyclecounter, and was
misaligning the pin triggers so that two X540 devices synced properly had
mis-aligned SDP pins. This patch fixes the math to calculate the correct
seconds alignment for the PPS signal.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 188 ++++++++++++++-------------
 1 file changed, 99 insertions(+), 89 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 39881cb..58d930d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -106,6 +106,94 @@ static struct sock_filter ptp_filter[] = {
 };
 
 /**
+ * ixgbe_ptp_enable_sdp
+ * @hw: the hardware private structure
+ * @shift: the clock shift for calculating nanoseconds
+ *
+ * this function enables the clock out feature on the sdp0 for the
+ * X540 device. It will create a 1second periodic output that can be
+ * used as the PPS (via an interrupt).
+ *
+ * It calculates when the systime will be on an exact second, and then
+ * aligns the start of the PPS signal to that value. The shift is
+ * necessary because it can change based on the link speed.
+ */
+static void ixgbe_ptp_enable_sdp(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int shift = adapter->cc.shift;
+	u32 esdp, tsauxc, clktiml, clktimh, trgttiml, trgttimh, rem;
+	u64 ns = 0, clock_edge = 0;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_X540:
+		esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
+
+		/*
+		 * enable the SDP0 pin as output, and connected to the native
+		 * function for Timesync (ClockOut)
+		 */
+		esdp |= (IXGBE_ESDP_SDP0_DIR |
+			 IXGBE_ESDP_SDP0_NATIVE);
+
+		/*
+		 * enable the Clock Out feature on SDP0, and allow interrupts
+		 * to occur when the pin changes
+		 */
+		tsauxc = (IXGBE_TSAUXC_EN_CLK |
+			  IXGBE_TSAUXC_SYNCLK |
+			  IXGBE_TSAUXC_SDP0_INT);
+
+		/* clock period (or pulse length) */
+		clktiml = (u32)(NSECS_PER_SEC << shift);
+		clktimh = (u32)((NSECS_PER_SEC << shift) >> 32);
+
+		/*
+		 * Account for the cyclecounter wrap-around value by
+		 * using the converted ns value of the current time to
+		 * check for when the next aligned second would occur.
+		 */
+		clock_edge |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIML);
+		clock_edge |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIMH) << 32;
+		ns = timecounter_cyc2time(&adapter->tc, clock_edge);
+
+		div_u64_rem(ns, NSECS_PER_SEC, &rem);
+		clock_edge += ((NSECS_PER_SEC - (u64)rem) << shift);
+
+		/* specify the initial clock start time */
+		trgttiml = (u32)clock_edge;
+		trgttimh = (u32)(clock_edge >> 32);
+
+		IXGBE_WRITE_REG(hw, IXGBE_CLKTIML, clktiml);
+		IXGBE_WRITE_REG(hw, IXGBE_CLKTIMH, clktimh);
+		IXGBE_WRITE_REG(hw, IXGBE_TRGTTIML0, trgttiml);
+		IXGBE_WRITE_REG(hw, IXGBE_TRGTTIMH0, trgttimh);
+
+		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp);
+		IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, tsauxc);
+
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EICR_TIMESYNC);
+		IXGBE_WRITE_FLUSH(hw);
+		break;
+	default:
+		break;
+	}
+}
+
+/**
+ * ixgbe_ptp_disable_sdp
+ * @hw: the private hardware structure
+ *
+ * this function disables the auxiliary SDP clock out feature
+ */
+static void ixgbe_ptp_disable_sdp(struct ixgbe_hw *hw)
+{
+	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EICR_TIMESYNC);
+	IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, 0);
+	IXGBE_WRITE_FLUSH(hw);
+}
+
+/**
  * ixgbe_ptp_read - read raw cycle counter (to be used by time counter)
  * @cc: the cyclecounter structure
  *
@@ -187,6 +275,7 @@ static int ixgbe_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	unsigned long flags;
 	u64 now;
 
+	ixgbe_ptp_disable_sdp(&adapter->hw);
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
 
 	now = timecounter_read(&adapter->tc);
@@ -198,6 +287,8 @@ static int ixgbe_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 			 now);
 
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
+	ixgbe_ptp_enable_sdp(adapter);
+
 	return 0;
 }
 
@@ -246,11 +337,14 @@ static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
 	ns = ts->tv_sec * 1000000000ULL;
 	ns += ts->tv_nsec;
 
+	ixgbe_ptp_disable_sdp(&adapter->hw);
+
 	/* reset the timecounter */
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
 	timecounter_init(&adapter->tc, &adapter->cc, ns);
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 
+	ixgbe_ptp_enable_sdp(adapter);
 	return 0;
 }
 
@@ -323,91 +417,6 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
 	}
 }
 
-/**
- * ixgbe_ptp_enable_sdp
- * @hw: the hardware private structure
- * @shift: the clock shift for calculating nanoseconds
- *
- * this function enables the clock out feature on the sdp0 for the
- * X540 device. It will create a 1second periodic output that can be
- * used as the PPS (via an interrupt).
- *
- * It calculates when the systime will be on an exact second, and then
- * aligns the start of the PPS signal to that value. The shift is
- * necessary because it can change based on the link speed.
- */
-static void ixgbe_ptp_enable_sdp(struct ixgbe_hw *hw, int shift)
-{
-	u32 esdp, tsauxc, clktiml, clktimh, trgttiml, trgttimh;
-	u64 clock_edge = 0;
-	u32 rem;
-
-	switch (hw->mac.type) {
-	case ixgbe_mac_X540:
-		esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
-
-		/*
-		 * enable the SDP0 pin as output, and connected to the native
-		 * function for Timesync (ClockOut)
-		 */
-		esdp |= (IXGBE_ESDP_SDP0_DIR |
-			 IXGBE_ESDP_SDP0_NATIVE);
-
-		/*
-		 * enable the Clock Out feature on SDP0, and allow interrupts
-		 * to occur when the pin changes
-		 */
-		tsauxc = (IXGBE_TSAUXC_EN_CLK |
-			  IXGBE_TSAUXC_SYNCLK |
-			  IXGBE_TSAUXC_SDP0_INT);
-
-		/* clock period (or pulse length) */
-		clktiml = (u32)(NSECS_PER_SEC << shift);
-		clktimh = (u32)((NSECS_PER_SEC << shift) >> 32);
-
-		clock_edge |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIML);
-		clock_edge |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIMH) << 32;
-
-		/*
-		 * account for the fact that we can't do u64 division
-		 * with remainder, by converting the clock values into
-		 * nanoseconds first
-		 */
-		clock_edge >>= shift;
-		div_u64_rem(clock_edge, NSECS_PER_SEC, &rem);
-		clock_edge += (NSECS_PER_SEC - rem);
-		clock_edge <<= shift;
-
-		/* specify the initial clock start time */
-		trgttiml = (u32)clock_edge;
-		trgttimh = (u32)(clock_edge >> 32);
-
-		IXGBE_WRITE_REG(hw, IXGBE_CLKTIML, clktiml);
-		IXGBE_WRITE_REG(hw, IXGBE_CLKTIMH, clktimh);
-		IXGBE_WRITE_REG(hw, IXGBE_TRGTTIML0, trgttiml);
-		IXGBE_WRITE_REG(hw, IXGBE_TRGTTIMH0, trgttimh);
-
-		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp);
-		IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, tsauxc);
-
-		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EICR_TIMESYNC);
-		break;
-	default:
-		break;
-	}
-}
-
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
-}
 
 /**
  * ixgbe_ptp_overflow_check - delayed work to detect SYSTIME overflow
@@ -877,10 +886,6 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_SYSTIMH, 0x00000000);
 	IXGBE_WRITE_FLUSH(hw);
 
-	/* now that the shift has been calculated and the systime
-	 * registers reset, (re-)enable the Clock out feature*/
-	ixgbe_ptp_enable_sdp(hw, shift);
-
 	/* store the new cycle speed */
 	adapter->cycle_speed = cycle_speed;
 
@@ -901,6 +906,11 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 			 ktime_to_ns(ktime_get_real()));
 
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
+
+	/* Now that the shift has been calculated and the systime
+	 * registers reset, (re-)enable the Clock out feature
+	 */
+	ixgbe_ptp_enable_sdp(adapter);
 }
 
 /**
-- 
1.7.11.4
