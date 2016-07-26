From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 3/2] e1000e: convert systim overflow check to use flags2
Date: Tue, 26 Jul 2016 13:39:06 -0400
Message-ID: <1469554746-410-1-git-send-email-jarod@redhat.com>
References: <20160725105648.00000dda@unknown>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160725105648.00000dda@unknown>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Per Jesse Brandeburg, e1000e should be using flags for this sort of thing.

Littering functional code with device-specific checks is much messier than
simply checking a flag, and having device-specific init set flags as needed.
There are probably a number of other cases in the e1000e code that
could/should be converted similarly.

At present, this patch is a follow-up to the previously submitted 2
patches, but I can redo the series to omit the conversion to a switch
entirely, if so desired.

Suggested-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c   |  6 ++++--
 drivers/net/ethernet/intel/e1000e/e1000.h   |  1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c |  3 ++-
 drivers/net/ethernet/intel/e1000e/netdev.c  | 10 ++--------
 4 files changed, 9 insertions(+), 11 deletions(-)

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
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 3e11322..395ca26 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -5885,7 +5885,8 @@ const struct e1000_info e1000_pch_lpt_info = {
 				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_APME_IN_WUC,
 	.flags2			= FLAG2_HAS_PHY_STATS
-				  | FLAG2_HAS_EEE,
+				  | FLAG2_HAS_EEE
+				  | FLAGS2_CHECK_SYSTIM_OVERFLOW,
 	.pba			= 26,
 	.max_hw_frame_size	= 9022,
 	.get_variants		= e1000_get_variants_ich8lan,
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 206bd6a..1b2df11 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4371,15 +4371,9 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	systim = (cycle_t)systimel;
 	systim |= (cycle_t)systimeh << 32;
 
-	switch (hw->mac.type) {
-	case e1000_82574:
-	case e1000_82583:
-	case e1000_pch_lpt:
+	if (adapter->flags2 & FLAG2_CHECK_SYSTIM_OVERFLOW)
 		systim = e1000e_sanitize_systim(hw, systim);
-		break;
-	default:
-		break;
-	}
+
 	return systim;
 }
 
-- 
1.8.3.1
