From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] e1000e: factor out systim sanitization
Date: Tue, 16 Aug 2016 13:40:10 -0700
Message-ID: <1471380014-134435-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56287 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790AbcHPUkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 16:40:17 -0400
In-Reply-To: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>

This is prepatory work for an expanding list of adapter families that have
occasional ~10 hour clock jumps when being used for PTP. Factor out the
sanitization function and convert to using a feature (bug) flag, per
suggestion from Jesse Brandeburg.

Littering functional code with device-specific checks is much messier than
simply checking a flag, and having device-specific init set flags as needed.
There are probably a number of other cases in the e1000e code that
could/should be converted similarly.

Suggested-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c  |  6 ++-
 drivers/net/ethernet/intel/e1000e/e1000.h  |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c | 66 ++++++++++++++++++------------
 3 files changed, 44 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 7fd4d54..6b03c85 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -2032,7 +2032,8 @@ const struct e1000_info e1000_82574_info = {
 				  | FLAG2_DISABLE_ASPM_L0S
 				  | FLAG2_DISABLE_ASPM_L1
 				  | FLAG2_NO_DISABLE_RX
-				  | FLAG2_DMA_BURST,
+				  | FLAG2_DMA_BURST
+				  | FLAG2_CHECK_SYSTIM_OVERFLOW,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
@@ -2053,7 +2054,8 @@ const struct e1000_info e1000_82583_info = {
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.flags2			= FLAG2_DISABLE_ASPM_L0S
 				  | FLAG2_DISABLE_ASPM_L1
-				  | FLAG2_NO_DISABLE_RX,
+				  | FLAG2_NO_DISABLE_RX
+				  | FLAG2_CHECK_SYSTIM_OVERFLOW,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index ef96cd1..879cca4 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -452,6 +452,7 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca);
 #define FLAG2_PCIM2PCI_ARBITER_WA         BIT(11)
 #define FLAG2_DFLT_CRC_STRIPPING          BIT(12)
 #define FLAG2_CHECK_RX_HWTSTAMP           BIT(13)
+#define FLAG2_CHECK_SYSTIM_OVERFLOW       BIT(14)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 02f4439..7017281 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4303,6 +4303,42 @@ void e1000e_reinit_locked(struct e1000_adapter *adapter)
 }
 
 /**
+ * e1000e_sanitize_systim - sanitize raw cycle counter reads
+ * @hw: pointer to the HW structure
+ * @systim: cycle_t value read, sanitized and returned
+ *
+ * Errata for 82574/82583 possible bad bits read from SYSTIMH/L:
+ * check to see that the time is incrementing at a reasonable
+ * rate and is a multiple of incvalue.
+ **/
+static cycle_t e1000e_sanitize_systim(struct e1000_hw *hw, cycle_t systim)
+{
+	u64 time_delta, rem, temp;
+	cycle_t systim_next;
+	u32 incvalue;
+	int i;
+
+	incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
+	for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
+		/* latch SYSTIMH on read of SYSTIML */
+		systim_next = (cycle_t)er32(SYSTIML);
+		systim_next |= (cycle_t)er32(SYSTIMH) << 32;
+
+		time_delta = systim_next - systim;
+		temp = time_delta;
+		/* VMWare users have seen incvalue of zero, don't div / 0 */
+		rem = incvalue ? do_div(temp, incvalue) : (time_delta != 0);
+
+		systim = systim_next;
+
+		if ((time_delta < E1000_82574_SYSTIM_EPSILON) && (rem == 0))
+			break;
+	}
+
+	return systim;
+}
+
+/**
  * e1000e_cyclecounter_read - read raw cycle counter (used by time counter)
  * @cc: cyclecounter structure
  **/
@@ -4312,7 +4348,7 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 						     cc);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 systimel, systimeh;
-	cycle_t systim, systim_next;
+	cycle_t systim;
 	/* SYSTIMH latching upon SYSTIML read does not work well.
 	 * This means that if SYSTIML overflows after we read it but before
 	 * we read SYSTIMH, the value of SYSTIMH has been incremented and we
@@ -4335,33 +4371,9 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	systim = (cycle_t)systimel;
 	systim |= (cycle_t)systimeh << 32;
 
-	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
-		u64 time_delta, rem, temp;
-		u32 incvalue;
-		int i;
-
-		/* errata for 82574/82583 possible bad bits read from SYSTIMH/L
-		 * check to see that the time is incrementing at a reasonable
-		 * rate and is a multiple of incvalue
-		 */
-		incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
-		for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
-			/* latch SYSTIMH on read of SYSTIML */
-			systim_next = (cycle_t)er32(SYSTIML);
-			systim_next |= (cycle_t)er32(SYSTIMH) << 32;
-
-			time_delta = systim_next - systim;
-			temp = time_delta;
-			/* VMWare users have seen incvalue of zero, don't div / 0 */
-			rem = incvalue ? do_div(temp, incvalue) : (time_delta != 0);
-
-			systim = systim_next;
+	if (adapter->flags2 & FLAG2_CHECK_SYSTIM_OVERFLOW)
+		systim = e1000e_sanitize_systim(hw, systim);
 
-			if ((time_delta < E1000_82574_SYSTIM_EPSILON) &&
-			    (rem == 0))
-				break;
-		}
-	}
 	return systim;
 }
 
-- 
2.7.4
