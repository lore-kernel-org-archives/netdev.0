From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] ixgbe: (PTP) refactor init, cyclecounter and reset
Date: Fri, 19 Oct 2012 23:26:01 -0700
Message-ID: <1350714367-24208-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22515 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753084Ab2JTG0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:26:40 -0400
In-Reply-To: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch modifies when and where PTP registers and data are set. Previously
a work-around was used inside cyclecounter_start in order to reset some of the
time registers. This patch creates a new ixgbe_ptp_reset specifically for this
purpose. The cyclecounter configuration has trimmed down to only modify what
is necessary. Due to hardware conditions after probe and before open, PTP init
has now moved into the ixgbe_open call. This allows the ptp device name in the
sysfs to be the ethernet device name instead of the MAC address.

The cyclecounter check flag is renamed to PTP_ENABLED and is used to prevent
PTP init from happening when PTP has not been enabled.

CC: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  26 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 109 +++++++++++---------------
 3 files changed, 66 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 101e525..c64a777 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -483,7 +483,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_FDIR_REQUIRES_REINIT        (u32)(1 << 7)
 #define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP		(u32)(1 << 8)
 #define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		(u32)(1 << 9)
-#define IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED	(u32)(1 << 10)
+#define IXGBE_FLAG2_PTP_ENABLED			(u32)(1 << 10)
 #define IXGBE_FLAG2_PTP_PPS_ENABLED		(u32)(1 << 11)
 
 	/* Tx fast path data */
@@ -581,7 +581,6 @@ struct ixgbe_adapter {
 	struct timecounter tc;
 	int rx_hwtstamp_filter;
 	u32 base_incval;
-	u32 cycle_speed;
 #endif /* CONFIG_IXGBE_PTP */
 
 	/* SR-IOV */
@@ -754,6 +753,7 @@ extern void ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
 extern int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 				    struct ifreq *ifr, int cmd);
 extern void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter);
+extern void ixgbe_ptp_reset(struct ixgbe_adapter *adapter);
 extern void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr);
 #endif /* CONFIG_IXGBE_PTP */
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e417394..46bf0fd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4210,6 +4210,11 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	/* update SAN MAC vmdq pool selection */
 	if (hw->mac.san_mac_rar_index)
 		hw->mac.ops.set_vmdq_san_mac(hw, VMDQ_P(0));
+
+#ifdef CONFIG_IXGBE_PTP
+	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
+		ixgbe_ptp_reset(adapter);
+#endif
 }
 
 /**
@@ -4919,6 +4924,10 @@ static int ixgbe_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
+#ifdef CONFIG_IXGBE_PTP
+	ixgbe_ptp_init(adapter);
+#endif /* CONFIG_IXGBE_PTP*/
+
 	ixgbe_up_complete(adapter);
 
 	return 0;
@@ -4950,6 +4959,10 @@ static int ixgbe_close(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
+#ifdef CONFIG_IXGBE_PTP
+	ixgbe_ptp_stop(adapter);
+#endif
+
 	ixgbe_down(adapter);
 	ixgbe_free_irq(adapter);
 
@@ -5518,7 +5531,8 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	}
 
 #ifdef CONFIG_IXGBE_PTP
-	ixgbe_ptp_start_cyclecounter(adapter);
+	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
+		ixgbe_ptp_start_cyclecounter(adapter);
 #endif
 
 	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
@@ -5565,7 +5579,8 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 		adapter->flags2 |= IXGBE_FLAG2_SEARCH_FOR_SFP;
 
 #ifdef CONFIG_IXGBE_PTP
-	ixgbe_ptp_start_cyclecounter(adapter);
+	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
+		ixgbe_ptp_start_cyclecounter(adapter);
 #endif
 
 	e_info(drv, "NIC Link is Down\n");
@@ -7403,10 +7418,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
-#ifdef CONFIG_IXGBE_PTP
-	ixgbe_ptp_init(adapter);
-#endif /* CONFIG_IXGBE_PTP*/
-
 	/* save off EEPROM version number */
 	hw->eeprom.ops.read(hw, 0x2e, &adapter->eeprom_verh);
 	hw->eeprom.ops.read(hw, 0x2d, &adapter->eeprom_verl);
@@ -7544,9 +7555,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
 
-#ifdef CONFIG_IXGBE_PTP
-	ixgbe_ptp_stop(adapter);
-#endif
 
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index d929131..5e71ddb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -411,7 +411,7 @@ void ixgbe_ptp_overflow_check(struct ixgbe_adapter *adapter)
 	unsigned long elapsed_jiffies = adapter->last_overflow_check - jiffies;
 	struct timespec ts;
 
-	if ((adapter->flags2 & IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED) &&
+	if ((adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED) &&
 	    (elapsed_jiffies >= IXGBE_OVERFLOW_PERIOD)) {
 		ixgbe_ptp_gettime(&adapter->ptp_caps, &ts);
 		adapter->last_overflow_check = jiffies;
@@ -759,58 +759,20 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
  * ixgbe_ptp_start_cyclecounter - create the cycle counter from hw
  * @adapter: pointer to the adapter structure
  *
- * this function initializes the timecounter and cyclecounter
- * structures for use in generated a ns counter from the arbitrary
- * fixed point cycles registers in the hardware.
- *
- * A change in link speed impacts the frequency of the DMA clock on
- * the device, which is used to generate the cycle counter
- * registers. Therefor this function is called whenever the link speed
- * changes.
- *
- * This function also turns on the SDP pin for clock out feature (X540
- * only), because this is where the shift is first calculated.
+ * This function should be called to set the proper values for the TIMINCA
+ * register and tell the cyclecounter structure what the tick rate of SYSTIME
+ * is. It does not directly modify SYSTIME registers or the timecounter
+ * structure. It should be called whenever a new TIMINCA value is necessary,
+ * such as during initialization or when the link speed changes.
  */
 void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 incval = 0;
-	u32 timinca = 0;
 	u32 shift = 0;
-	u32 cycle_speed;
 	unsigned long flags;
 
 	/**
-	 * Determine what speed we need to set the cyclecounter
-	 * for. It should be different for 100Mb, 1Gb, and 10Gb. Treat
-	 * unknown speeds as 10Gb. (Hence why we can't just copy the
-	 * link_speed.
-	 */
-	switch (adapter->link_speed) {
-	case IXGBE_LINK_SPEED_100_FULL:
-	case IXGBE_LINK_SPEED_1GB_FULL:
-	case IXGBE_LINK_SPEED_10GB_FULL:
-		cycle_speed = adapter->link_speed;
-		break;
-	default:
-		/* cycle speed should be 10Gb when there is no link */
-		cycle_speed = IXGBE_LINK_SPEED_10GB_FULL;
-		break;
-	}
-
-	/*
-	 * grab the current TIMINCA value from the register so that it can be
-	 * double checked. If the register value has been cleared, it must be
-	 * reset to the correct value for generating a cyclecounter. If
-	 * TIMINCA is zero, the SYSTIME registers do not increment at all.
-	 */
-	timinca = IXGBE_READ_REG(hw, IXGBE_TIMINCA);
-
-	/* Bail if the cycle speed didn't change and TIMINCA is non-zero */
-	if (adapter->cycle_speed == cycle_speed && timinca)
-		return;
-
-	/**
 	 * Scale the NIC cycle counter by a large factor so that
 	 * relatively small corrections to the frequency can be added
 	 * or subtracted. The drawbacks of a large factor include
@@ -819,8 +781,12 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 	 * to nanoseconds using only a multiplier and a right-shift,
 	 * and (c) the value must fit within the timinca register space
 	 * => math based on internal DMA clock rate and available bits
+	 *
+	 * Note that when there is no link, internal DMA clock is same as when
+	 * link speed is 10Gb. Set the registers correctly even when link is
+	 * down to preserve the clock setting
 	 */
-	switch (cycle_speed) {
+	switch (adapter->link_speed) {
 	case IXGBE_LINK_SPEED_100_FULL:
 		incval = IXGBE_INCVAL_100;
 		shift = IXGBE_INCVAL_SHIFT_100;
@@ -830,6 +796,7 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 		shift = IXGBE_INCVAL_SHIFT_1GB;
 		break;
 	case IXGBE_LINK_SPEED_10GB_FULL:
+	default:
 		incval = IXGBE_INCVAL_10GB;
 		shift = IXGBE_INCVAL_SHIFT_10GB;
 		break;
@@ -857,18 +824,11 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 		return;
 	}
 
-	/* reset the system time registers */
-	IXGBE_WRITE_REG(hw, IXGBE_SYSTIML, 0x00000000);
-	IXGBE_WRITE_REG(hw, IXGBE_SYSTIMH, 0x00000000);
-	IXGBE_WRITE_FLUSH(hw);
-
-	/* store the new cycle speed */
-	adapter->cycle_speed = cycle_speed;
-
+	/* update the base incval used to calculate frequency adjustment */
 	ACCESS_ONCE(adapter->base_incval) = incval;
 	smp_mb();
 
-	/* grab the ptp lock */
+	/* need lock to prevent incorrect read while modifying cyclecounter */
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
 
 	memset(&adapter->cc, 0, sizeof(adapter->cc));
@@ -877,6 +837,31 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 	adapter->cc.shift = shift;
 	adapter->cc.mult = 1;
 
+	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
+}
+
+/**
+ * ixgbe_ptp_reset
+ * @adapter: the ixgbe private board structure
+ *
+ * When the MAC resets, all timesync features are reset. This function should be
+ * called to re-enable the PTP clock structure. It will re-init the timecounter
+ * structure based on the kernel time as well as setup the cycle counter data.
+ */
+void ixgbe_ptp_reset(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	unsigned long flags;
+
+	/* set SYSTIME registers to 0 just in case */
+	IXGBE_WRITE_REG(hw, IXGBE_SYSTIML, 0x00000000);
+	IXGBE_WRITE_REG(hw, IXGBE_SYSTIMH, 0x00000000);
+	IXGBE_WRITE_FLUSH(hw);
+
+	ixgbe_ptp_start_cyclecounter(adapter);
+
+	spin_lock_irqsave(&adapter->tmreg_lock, flags);
+
 	/* reset the ns time counter */
 	timecounter_init(&adapter->tc, &adapter->cc,
 			 ktime_to_ns(ktime_get_real()));
@@ -904,7 +889,7 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X540:
-		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
+		snprintf(adapter->ptp_caps.name, 16, "%s", netdev->name);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 250000000;
 		adapter->ptp_caps.n_alarm = 0;
@@ -918,7 +903,7 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 		adapter->ptp_caps.enable = ixgbe_ptp_enable;
 		break;
 	case ixgbe_mac_82599EB:
-		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
+		snprintf(adapter->ptp_caps.name, 16, "%s", netdev->name);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 250000000;
 		adapter->ptp_caps.n_alarm = 0;
@@ -942,11 +927,6 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 
 	spin_lock_init(&adapter->tmreg_lock);
 
-	ixgbe_ptp_start_cyclecounter(adapter);
-
-	/* (Re)start the overflow check */
-	adapter->flags2 |= IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED;
-
 	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
 						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
@@ -955,6 +935,11 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 	} else
 		e_dev_info("registered PHC device on %s\n", netdev->name);
 
+	ixgbe_ptp_reset(adapter);
+
+	/* set the flag that PTP has been enabled */
+	adapter->flags2 |= IXGBE_FLAG2_PTP_ENABLED;
+
 	return;
 }
 
@@ -967,7 +952,7 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
 {
 	/* stop the overflow check task */
-	adapter->flags2 &= ~(IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED |
+	adapter->flags2 &= ~(IXGBE_FLAG2_PTP_ENABLED |
 			     IXGBE_FLAG2_PTP_PPS_ENABLED);
 
 	ixgbe_ptp_setup_sdp(adapter);
-- 
1.7.11.7
