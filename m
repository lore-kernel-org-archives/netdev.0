From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] ixgbe: Enable timesync clock-out feature for PPS support on X540
Date: Wed,  9 May 2012 23:46:48 -0700
Message-ID: <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob E Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7765 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756213Ab2EJGrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:47:01 -0400
In-Reply-To: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob E Keller <jacob.e.keller@intel.com>

This patch enables the PPS system in the PHC framework, by enabling
the clock-out feature on the X540 device. Causes the SDP0 to be set as
a 1Hz clock. Also configures the timesync interrupt cause in order to
report each pulse to the PPS via the PHC framework, which can be used
for general system clock synchronization. (This allows a stable method
for tuning the general system time via the on-board SYSTIM register
based clock.)

Signed-off-by: Jacob E Keller <jacob.e.keller@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  |  170 ++++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |   12 ++
 4 files changed, 189 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index c90fbd2..cba6ff4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -466,6 +466,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP		(u32)(1 << 8)
 #define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		(u32)(1 << 9)
 #define IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED	(u32)(1 << 10)
+#define IXGBE_FLAG2_PTP_PPS_ENABLED		(u32)(1 << 11)
 
 	/* Tx fast path data */
 	int num_tx_queues;
@@ -719,6 +720,7 @@ extern void ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
 extern int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 				    struct ifreq *ifr, int cmd);
 extern void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter);
+extern void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr);
 #endif /* CONFIG_IXGBE_PTP */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9a83c40..1ad6e2a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2322,6 +2322,9 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 	}
 
 	ixgbe_check_fan_failure(adapter, eicr);
+#ifdef CONFIG_IXGBE_PTP
+	ixgbe_ptp_check_pps_event(adapter, eicr);
+#endif
 
 	/* re-enable the original interrupt state, no lsc, no queues */
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -2514,6 +2517,9 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	}
 
 	ixgbe_check_fan_failure(adapter, eicr);
+#ifdef CONFIG_IXGBE_PTP
+	ixgbe_ptp_check_pps_event(adapter, eicr);
+#endif
 
 	/* would disable interrupts here but EIAM disabled it */
 	napi_schedule(&q_vector->napi);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 0b6553e..ddc6a4d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -96,6 +96,10 @@
 
 #define IXGBE_OVERFLOW_PERIOD    (HZ * 30)
 
+#ifndef NSECS_PER_SEC
+#define NSECS_PER_SEC 1000000000ULL
+#endif
+
 /**
  * ixgbe_ptp_read - read raw cycle counter (to be used by time counter)
  * @cc - the cyclecounter structure
@@ -252,15 +256,154 @@ static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
  * @on - whether to enable or disable the feature
  *
  * enable (or disable) ancillary features of the phc subsystem.
- * our driver does not support any of these features
+ * our driver only supports the PPS feature on the X540
  */
 static int ixgbe_ptp_enable(struct ptp_clock_info *ptp,
 			    struct ptp_clock_request *rq, int on)
 {
+	struct ixgbe_adapter *adapter =
+		container_of(ptp, struct ixgbe_adapter, ptp_caps);
+
+	/**
+	 * When PPS is enabled, unmask the interrupt for the ClockOut
+	 * feature, so that the interrupt handler can send the PPS
+	 * event when the clock SDP triggers. Clear mask when PPS is
+	 * disabled
+	 */
+	if (rq->type == PTP_CLK_REQ_PPS) {
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_X540:
+			if (on)
+				adapter->flags2 |= IXGBE_FLAG2_PTP_PPS_ENABLED;
+			else
+				adapter->flags2 &=
+					~IXGBE_FLAG2_PTP_PPS_ENABLED;
+			return 0;
+		default:
+			break;
+		}
+	}
+
 	return -ENOTSUPP;
 }
 
 /**
+ * ixgbe_ptp_check_pps_event
+ * @adapter - the private adapter structure
+ * @eicr - the interrupt cause register value
+ *
+ * This function is called by the interrupt routine when checking for
+ * interrupts. It will check and handle a pps event.
+ */
+void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ptp_clock_event event;
+
+	event.type = PTP_CLOCK_PPS;
+
+	/* Make sure ptp clock is valid, and PPS event enabled */
+	if (!adapter->ptp_clock ||
+	    !(adapter->flags2 & IXGBE_FLAG2_PTP_PPS_ENABLED))
+		return;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_X540:
+		if (eicr & IXGBE_EICR_TIMESYNC)
+			ptp_clock_event(adapter->ptp_clock, &event);
+		break;
+	default:
+		break;
+	}
+}
+
+/**
+ * ixgbe_ptp_enable_sdp
+ * @hw - the hardware private structure
+ * @shift - the clock shift for calculating nanoseconds
+ *
+ * this function enables the clock out feature on the sdp0 for the
+ * X540 device. It will create a 1second periodic output that can be
+ * used as the PPS (via an interrupt).
+ *
+ * It calculates when the systime will be on an exact second, and then
+ * aligns the start of the PPS signal to that value. The shift is
+ * necessary because it can change based on the link speed.
+ */
+static void ixgbe_ptp_enable_sdp(struct ixgbe_hw *hw, int shift)
+{
+	u32 esdp, tsauxc, clktiml, clktimh, trgttiml, trgttimh;
+	u64 clock_edge = 0;
+	u32 rem;
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
+		clock_edge |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIML);
+		clock_edge |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIMH) << 32;
+
+		/*
+		 * account for the fact that we can't do u64 division
+		 * with remainder, by converting the clock values into
+		 * nanoseconds first
+		 */
+		clock_edge >>= shift;
+		div_u64_rem(clock_edge, NSECS_PER_SEC, &rem);
+		clock_edge += (NSECS_PER_SEC - rem);
+		clock_edge <<= shift;
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
+		break;
+	default:
+		break;
+	}
+}
+
+/**
+ * ixgbe_ptp_disable_sdp
+ * @hw - the private hardware structure
+ *
+ * this function disables the auxiliary SDP clock out feature
+ */
+static void ixgbe_ptp_disable_sdp(struct ixgbe_hw *hw)
+{
+	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EICR_TIMESYNC);
+	IXGBE_WRITE_REG(hw, IXGBE_TSAUXC, 0);
+}
+
+/**
  * ixgbe_ptp_overflow_check - delayed work to detect SYSTIME overflow
  * @work: structure containing information about this work task
  *
@@ -557,6 +700,9 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
  * the device, which is used to generate the cycle counter
  * registers. Therefor this function is called whenever the link speed
  * changes.
+ *
+ * This function also turns on the SDP pin for clock out feature (X540
+ * only), because this is where the shift is first calculated.
  */
 void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 {
@@ -588,6 +734,9 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 	if (adapter->cycle_speed == cycle_speed)
 		return;
 
+	/* disable the SDP clock out */
+	ixgbe_ptp_disable_sdp(hw);
+
 	/**
 	 * Scale the NIC cycle counter by a large factor so that
 	 * relatively small corrections to the frequency can be added
@@ -640,6 +789,10 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_SYSTIMH, 0x00000000);
 	IXGBE_WRITE_FLUSH(hw);
 
+	/* now that the shift has been calculated and the systime
+	 * registers reset, (re-)enable the Clock out feature*/
+	ixgbe_ptp_enable_sdp(hw, shift);
+
 	/* store the new cycle speed */
 	adapter->cycle_speed = cycle_speed;
 
@@ -676,6 +829,19 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X540:
+		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
+		adapter->ptp_caps.owner = THIS_MODULE;
+		adapter->ptp_caps.max_adj = 250000000;
+		adapter->ptp_caps.n_alarm = 0;
+		adapter->ptp_caps.n_ext_ts = 0;
+		adapter->ptp_caps.n_per_out = 0;
+		adapter->ptp_caps.pps = 1;
+		adapter->ptp_caps.adjfreq = ixgbe_ptp_adjfreq;
+		adapter->ptp_caps.adjtime = ixgbe_ptp_adjtime;
+		adapter->ptp_caps.gettime = ixgbe_ptp_gettime;
+		adapter->ptp_caps.settime = ixgbe_ptp_settime;
+		adapter->ptp_caps.enable = ixgbe_ptp_enable;
+		break;
 	case ixgbe_mac_82599EB:
 		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
@@ -720,6 +886,8 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
  */
 void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
 {
+	ixgbe_ptp_disable_sdp(&adapter->hw);
+
 	/* stop the overflow check task */
 	adapter->flags2 &= ~IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 87d54ca..204848d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -824,6 +824,8 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_TRGTTIMH0  0x08C28 /* Target Time Register 0 High - RW */
 #define IXGBE_TRGTTIML1  0x08C2C /* Target Time Register 1 Low - RW */
 #define IXGBE_TRGTTIMH1  0x08C30 /* Target Time Register 1 High - RW */
+#define IXGBE_CLKTIML    0x08C34 /* Clock Out Time Register Low - RW */
+#define IXGBE_CLKTIMH    0x08C38 /* Clock Out Time Register High - RW */
 #define IXGBE_FREQOUT0   0x08C34 /* Frequency Out 0 Control register - RW */
 #define IXGBE_FREQOUT1   0x08C38 /* Frequency Out 1 Control register - RW */
 #define IXGBE_AUXSTMPL0  0x08C3C /* Auxiliary Time Stamp 0 register Low - RO */
@@ -1309,6 +1311,7 @@ enum {
 #define IXGBE_EICR_LINKSEC      0x00200000 /* PN Threshold */
 #define IXGBE_EICR_MNG          0x00400000 /* Manageability Event Interrupt */
 #define IXGBE_EICR_TS           0x00800000 /* Thermal Sensor Event */
+#define IXGBE_EICR_TIMESYNC     0x01000000 /* Timesync Event */
 #define IXGBE_EICR_GPI_SDP0     0x01000000 /* Gen Purpose Interrupt on SDP0 */
 #define IXGBE_EICR_GPI_SDP1     0x02000000 /* Gen Purpose Interrupt on SDP1 */
 #define IXGBE_EICR_GPI_SDP2     0x04000000 /* Gen Purpose Interrupt on SDP2 */
@@ -1326,6 +1329,7 @@ enum {
 #define IXGBE_EICS_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
 #define IXGBE_EICS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EICS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
+#define IXGBE_EICS_TIMESYNC     IXGBE_EICR_TIMESYNC  /* Timesync Event */
 #define IXGBE_EICS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
 #define IXGBE_EICS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
 #define IXGBE_EICS_GPI_SDP2     IXGBE_EICR_GPI_SDP2  /* SDP2 Gen Purpose Int */
@@ -1344,6 +1348,7 @@ enum {
 #define IXGBE_EIMS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
 #define IXGBE_EIMS_TS           IXGBE_EICR_TS        /* Thermel Sensor Event */
+#define IXGBE_EIMS_TIMESYNC     IXGBE_EICR_TIMESYNC  /* Timesync Event */
 #define IXGBE_EIMS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
 #define IXGBE_EIMS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
 #define IXGBE_EIMS_GPI_SDP2     IXGBE_EICR_GPI_SDP2  /* SDP2 Gen Purpose Int */
@@ -1361,6 +1366,7 @@ enum {
 #define IXGBE_EIMC_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
 #define IXGBE_EIMC_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMC_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
+#define IXGBE_EIMC_TIMESYNC     IXGBE_EICR_TIMESYNC  /* Timesync Event */
 #define IXGBE_EIMC_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
 #define IXGBE_EIMC_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
 #define IXGBE_EIMC_GPI_SDP2     IXGBE_EICR_GPI_SDP2  /* SDP2 Gen Purpose Int */
@@ -1501,8 +1507,10 @@ enum {
 #define IXGBE_ESDP_SDP4 0x00000010 /* SDP4 Data Value */
 #define IXGBE_ESDP_SDP5 0x00000020 /* SDP5 Data Value */
 #define IXGBE_ESDP_SDP6 0x00000040 /* SDP6 Data Value */
+#define IXGBE_ESDP_SDP0_DIR     0x00000100 /* SDP0 IO direction */
 #define IXGBE_ESDP_SDP4_DIR     0x00000004 /* SDP4 IO direction */
 #define IXGBE_ESDP_SDP5_DIR     0x00002000 /* SDP5 IO direction */
+#define IXGBE_ESDP_SDP0_NATIVE  0x00010000 /* SDP0 Native Function */
 
 /* LEDCTL Bit Masks */
 #define IXGBE_LED_IVRT_BASE      0x00000040
@@ -1879,6 +1887,10 @@ enum {
 #define IXGBE_RXDCTL_RLPML_EN   0x00008000
 #define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
 
+#define IXGBE_TSAUXC_EN_CLK   0x00000004
+#define IXGBE_TSAUXC_SYNCLK   0x00000008
+#define IXGBE_TSAUXC_SDP0_INT 0x00000040
+
 #define IXGBE_TSYNCTXCTL_VALID		0x00000001 /* Tx timestamp valid */
 #define IXGBE_TSYNCTXCTL_ENABLED	0x00000010 /* Tx timestamping enabled */
 
-- 
1.7.7.6
