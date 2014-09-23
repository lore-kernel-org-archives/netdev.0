From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 28/29] fm10k: Add support for ptp to hw specific files
Date: Tue, 23 Sep 2014 04:16:56 -0700
Message-ID: <1411471017-28213-29-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46846 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755400AbaIWLRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:31 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds the messaging support needed to support PTP.  In the case
of Tx timestamps it is necessary for the Switch Management entity to return
the frames via the mailbox as the host interface cannot know which port the
timestamp will be delivered to.  In addition there is only one clock on the
entire switch, as such the entity that has BAR 4 access is the only one who
can actually update the frequency as it is the only one with access.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_common.h |  8 ++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c     | 99 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_type.h   | 14 ++++
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c     | 55 ++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h     | 10 +++
 5 files changed, 186 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.h b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
index 8250e14..45e4e5b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
@@ -39,6 +39,14 @@ do { \
 		writel((val), &hw_addr[(reg)]); \
 } while (0)
 
+/* Switch register write operations, index using DWORDS */
+#define fm10k_write_sw_reg(hw, reg, val) \
+do { \
+	u32 __iomem *sw_addr = ACCESS_ONCE((hw)->sw_addr); \
+	if (!FM10K_REMOVED(sw_addr)) \
+		writel((val), &sw_addr[(reg)]); \
+} while (0)
+
 /* read ctrl register which has no clear on read fields as PCIe flush */
 #define fm10k_write_flush(hw) fm10k_read_reg((hw), FM10K_CTRL)
 s32 fm10k_get_bus_info_generic(struct fm10k_hw *hw);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 0b6ce10..275423d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1123,6 +1123,19 @@ static void fm10k_iov_update_stats_pf(struct fm10k_hw *hw,
 	fm10k_update_hw_stats_q(hw, q, idx, qpp);
 }
 
+static s32 fm10k_iov_report_timestamp_pf(struct fm10k_hw *hw,
+					 struct fm10k_vf_info *vf_info,
+					 u64 timestamp)
+{
+	u32 msg[4];
+
+	/* generate port state response to notify VF it is not ready */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_1588);
+	fm10k_tlv_attr_put_u64(msg, FM10K_1588_MSG_TIMESTAMP, timestamp);
+
+	return vf_info->mbx.ops.enqueue_tx(hw, &vf_info->mbx, msg);
+}
+
 /**
  *  fm10k_iov_msg_msix_pf - Message handler for MSI-X request from VF
  *  @hw: Pointer to hardware structure
@@ -1723,6 +1736,89 @@ s32 fm10k_msg_err_pf(struct fm10k_hw *hw, u32 **results,
 	return 0;
 }
 
+const struct fm10k_tlv_attr fm10k_1588_timestamp_msg_attr[] = {
+	FM10K_TLV_ATTR_LE_STRUCT(FM10K_PF_ATTR_ID_1588_TIMESTAMP,
+				 sizeof(struct fm10k_swapi_1588_timestamp)),
+	FM10K_TLV_ATTR_LAST
+};
+
+/* currently there is no shared 1588 timestamp handler */
+
+/**
+ *  fm10k_adjust_systime_pf - Adjust systime frequency
+ *  @hw: pointer to hardware structure
+ *  @ppb: adjustment rate in parts per billion
+ *
+ *  This function will adjust the SYSTIME_CFG register contained in BAR 4
+ *  if this function is supported for BAR 4 access.  The adjustment amount
+ *  is based on the parts per billion value provided and adjusted to a
+ *  value based on parts per 2^48 clock cycles.
+ *
+ *  If adjustment is not supported or the requested value is too large
+ *  we will return an error.
+ **/
+static s32 fm10k_adjust_systime_pf(struct fm10k_hw *hw, s32 ppb)
+{
+	u64 systime_adjust;
+
+	/* if sw_addr is not set we don't have switch register access */
+	if (!hw->sw_addr)
+		return ppb ? FM10K_ERR_PARAM : 0;
+
+	/* we must convert the value from parts per billion to parts per
+	 * 2^48 cycles.  In addition I have opted to only use the 30 most
+	 * significant bits of the adjustment value as the 8 least
+	 * significant bits are located in another register and represent
+	 * a value significantly less than a part per billion, the result
+	 * of dropping the 8 least significant bits is that the adjustment
+	 * value is effectively multiplied by 2^8 when we write it.
+	 *
+	 * As a result of all this the math for this breaks down as follows:
+	 *	ppb / 10^9 == adjust * 2^8 / 2^48
+	 * If we solve this for adjust, and simplify it comes out as:
+	 *	ppb * 2^31 / 5^9 == adjust
+	 */
+	systime_adjust = (ppb < 0) ? -ppb : ppb;
+	systime_adjust <<= 31;
+	do_div(systime_adjust, 1953125);
+
+	/* verify the requested adjustment value is in range */
+	if (systime_adjust > FM10K_SW_SYSTIME_ADJUST_MASK)
+		return FM10K_ERR_PARAM;
+
+	if (ppb < 0)
+		systime_adjust |= FM10K_SW_SYSTIME_ADJUST_DIR_NEGATIVE;
+
+	fm10k_write_sw_reg(hw, FM10K_SW_SYSTIME_ADJUST, (u32)systime_adjust);
+
+	return 0;
+}
+
+/**
+ *  fm10k_read_systime_pf - Reads value of systime registers
+ *  @hw: pointer to the hardware structure
+ *
+ *  Function reads the content of 2 registers, combined to represent a 64 bit
+ *  value measured in nanosecods.  In order to guarantee the value is accurate
+ *  we check the 32 most significant bits both before and after reading the
+ *  32 least significant bits to verify they didn't change as we were reading
+ *  the registers.
+ **/
+static u64 fm10k_read_systime_pf(struct fm10k_hw *hw)
+{
+	u32 systime_l, systime_h, systime_tmp;
+
+	systime_h = fm10k_read_reg(hw, FM10K_SYSTIME + 1);
+
+	do {
+		systime_tmp = systime_h;
+		systime_l = fm10k_read_reg(hw, FM10K_SYSTIME);
+		systime_h = fm10k_read_reg(hw, FM10K_SYSTIME + 1);
+	} while (systime_tmp != systime_h);
+
+	return ((u64)systime_h << 32) | systime_l;
+}
+
 static const struct fm10k_msg_data fm10k_msg_data_pf[] = {
 	FM10K_PF_MSG_ERR_HANDLER(XCAST_MODES, fm10k_msg_err_pf),
 	FM10K_PF_MSG_ERR_HANDLER(UPDATE_MAC_FWD_RULE, fm10k_msg_err_pf),
@@ -1753,6 +1849,8 @@ static struct fm10k_mac_ops mac_ops_pf = {
 	.set_dma_mask		= &fm10k_set_dma_mask_pf,
 	.get_fault		= &fm10k_get_fault_pf,
 	.get_host_state		= &fm10k_get_host_state_pf,
+	.adjust_systime		= &fm10k_adjust_systime_pf,
+	.read_systime		= &fm10k_read_systime_pf,
 };
 
 static struct fm10k_iov_ops iov_ops_pf = {
@@ -1764,6 +1862,7 @@ static struct fm10k_iov_ops iov_ops_pf = {
 	.set_lport			= &fm10k_iov_set_lport_pf,
 	.reset_lport			= &fm10k_iov_reset_lport_pf,
 	.update_stats			= &fm10k_iov_update_stats_pf,
+	.report_timestamp		= &fm10k_iov_report_timestamp_pf,
 };
 
 static s32 fm10k_get_invariants_pf(struct fm10k_hw *hw)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index ecaf93a..280296f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -224,6 +224,11 @@ struct fm10k_hw;
 #define FM10K_STATS_LOOPBACK_DROP	0x3806
 #define FM10K_STATS_NODESC_DROP		0x3807
 
+/* Timesync registers */
+#define FM10K_SYSTIME		0x3814
+#define FM10K_SYSTIME_CFG	0x3818
+#define FM10K_SYSTIME_CFG_STEP_MASK		0x0000000F
+
 /* PCIe state registers */
 #define FM10K_PHYADDR		0x381C
 
@@ -358,6 +363,12 @@ struct fm10k_hw;
 #define FM10K_VFSYSTIME		0x00040
 #define FM10K_VFITR(_n)		((_n) + 0x00060)
 
+/* Registers contained in BAR 4 for Switch management */
+#define FM10K_SW_SYSTIME_ADJUST	0x0224D
+#define FM10K_SW_SYSTIME_ADJUST_MASK		0x3FFFFFFF
+#define FM10K_SW_SYSTIME_ADJUST_DIR_NEGATIVE	0x80000000
+#define FM10K_SW_SYSTIME_PULSE(_n)	((_n) + 0x02252)
+
 enum fm10k_int_source {
 	fm10k_int_Mailbox	= 0,
 	fm10k_int_PCIeFault	= 1,
@@ -524,6 +535,7 @@ struct fm10k_mac_ops {
 	s32 (*get_fault)(struct fm10k_hw *, int, struct fm10k_fault *);
 	void (*request_lport_map)(struct fm10k_hw *);
 	s32 (*adjust_systime)(struct fm10k_hw *, s32 ppb);
+	u64 (*read_systime)(struct fm10k_hw *);
 };
 
 enum fm10k_mac_type {
@@ -614,6 +626,7 @@ struct fm10k_iov_ops {
 	s32 (*set_lport)(struct fm10k_hw *, struct fm10k_vf_info *, u16, u8);
 	void (*reset_lport)(struct fm10k_hw *, struct fm10k_vf_info *);
 	void (*update_stats)(struct fm10k_hw *, struct fm10k_hw_stats_q *, u16);
+	s32 (*report_timestamp)(struct fm10k_hw *, struct fm10k_vf_info *, u64);
 };
 
 struct fm10k_iov_info {
@@ -637,6 +650,7 @@ struct fm10k_info {
 
 struct fm10k_hw {
 	u32 __iomem *hw_addr;
+	u32 __iomem *sw_addr;
 	void *back;
 	struct fm10k_mac_info mac;
 	struct fm10k_bus_info bus;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 25c23fc..f0aa0f9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -431,6 +431,13 @@ static s32 fm10k_update_xcast_mode_vf(struct fm10k_hw *hw, u16 glort, u8 mode)
 	return mbx->ops.enqueue_tx(hw, mbx, msg);
 }
 
+const struct fm10k_tlv_attr fm10k_1588_msg_attr[] = {
+	FM10K_TLV_ATTR_U64(FM10K_1588_MSG_TIMESTAMP),
+	FM10K_TLV_ATTR_LAST
+};
+
+/* currently there is no shared 1588 timestamp handler */
+
 /**
  *  fm10k_update_hw_stats_vf - Updates hardware related statistics of VF
  *  @hw: pointer to hardware structure
@@ -482,6 +489,52 @@ static s32 fm10k_configure_dglort_map_vf(struct fm10k_hw *hw,
 	return 0;
 }
 
+/**
+ *  fm10k_adjust_systime_vf - Adjust systime frequency
+ *  @hw: pointer to hardware structure
+ *  @ppb: adjustment rate in parts per billion
+ *
+ *  This function takes an adjustment rate in parts per billion and will
+ *  verify that this value is 0 as the VF cannot support adjusting the
+ *  systime clock.
+ *
+ *  If the ppb value is non-zero the return is ERR_PARAM else success
+ **/
+static s32 fm10k_adjust_systime_vf(struct fm10k_hw *hw, s32 ppb)
+{
+	/* The VF cannot adjust the clock frequency, however it should
+	 * already have a syntonic clock with whichever host interface is
+	 * running as the master for the host interface clock domain so
+	 * there should be not frequency adjustment necessary.
+	 */
+	return ppb ? FM10K_ERR_PARAM : 0;
+}
+
+/**
+ *  fm10k_read_systime_vf - Reads value of systime registers
+ *  @hw: pointer to the hardware structure
+ *
+ *  Function reads the content of 2 registers, combined to represent a 64 bit
+ *  value measured in nanosecods.  In order to guarantee the value is accurate
+ *  we check the 32 most significant bits both before and after reading the
+ *  32 least significant bits to verify they didn't change as we were reading
+ *  the registers.
+ **/
+static u64 fm10k_read_systime_vf(struct fm10k_hw *hw)
+{
+	u32 systime_l, systime_h, systime_tmp;
+
+	systime_h = fm10k_read_reg(hw, FM10K_VFSYSTIME + 1);
+
+	do {
+		systime_tmp = systime_h;
+		systime_l = fm10k_read_reg(hw, FM10K_VFSYSTIME);
+		systime_h = fm10k_read_reg(hw, FM10K_VFSYSTIME + 1);
+	} while (systime_tmp != systime_h);
+
+	return ((u64)systime_h << 32) | systime_l;
+}
+
 static const struct fm10k_msg_data fm10k_msg_data_vf[] = {
 	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
 	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_msg_mac_vlan_vf),
@@ -507,6 +560,8 @@ static struct fm10k_mac_ops mac_ops_vf = {
 	.rebind_hw_stats	= &fm10k_rebind_hw_stats_vf,
 	.configure_dglort_map	= &fm10k_configure_dglort_map_vf,
 	.get_host_state		= &fm10k_get_host_state_generic,
+	.adjust_systime		= &fm10k_adjust_systime_vf,
+	.read_systime		= &fm10k_read_systime_vf,
 };
 
 static s32 fm10k_get_invariants_vf(struct fm10k_hw *hw)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
index 8e96ee5..06a99d7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
@@ -29,6 +29,7 @@ enum fm10k_vf_tlv_msg_id {
 	FM10K_VF_MSG_ID_MSIX,
 	FM10K_VF_MSG_ID_MAC_VLAN,
 	FM10K_VF_MSG_ID_LPORT_STATE,
+	FM10K_VF_MSG_ID_1588,
 	FM10K_VF_MSG_ID_MAX,
 };
 
@@ -48,6 +49,11 @@ enum fm10k_tlv_lport_state_attr_id {
 	FM10K_LPORT_STATE_MSG_MAX
 };
 
+enum fm10k_tlv_1588_attr_id {
+	FM10K_1588_MSG_TIMESTAMP,
+	FM10K_1588_MSG_MAX
+};
+
 #define FM10K_VF_MSG_MSIX_HANDLER(func) \
 	 FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_MSIX, NULL, func)
 
@@ -64,5 +70,9 @@ extern const struct fm10k_tlv_attr fm10k_lport_state_msg_attr[];
 	FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_LPORT_STATE, \
 			  fm10k_lport_state_msg_attr, func)
 
+extern const struct fm10k_tlv_attr fm10k_1588_msg_attr[];
+#define FM10K_VF_MSG_1588_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_1588, fm10k_1588_msg_attr, func)
+
 extern struct fm10k_info fm10k_vf_info;
 #endif /* _FM10K_VF_H */
-- 
1.9.3
