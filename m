From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] igb: Read register for latch_on without return value
Date: Wed, 26 Jun 2013 03:55:18 -0700
Message-ID: <1372244122-17664-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61757 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166Ab3FZKz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:28 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch changes register read to "just-read" without returning a value
for hardware to accurately latch the register value.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |  9 ++++-----
 drivers/net/ethernet/intel/igb/igb_main.c    | 14 ++++----------
 drivers/net/ethernet/intel/igb/igb_ptp.c     |  8 ++++----
 3 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index f21a91a..9057d10 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1320,7 +1320,7 @@ void igb_shutdown_serdes_link_82575(struct e1000_hw *hw)
  **/
 static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 {
-	u32 ctrl, icr;
+	u32 ctrl;
 	s32 ret_val;
 
 	/* Prevent the PCI-E bus from sticking if there is no TLP connection
@@ -1365,7 +1365,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 
 	/* Clear any pending interrupt events. */
 	wr32(E1000_IMC, 0xffffffff);
-	icr = rd32(E1000_ICR);
+	rd32(E1000_ICR);
 
 	/* Install any alternate MAC address into RAR0 */
 	ret_val = igb_check_alt_mac_addr(hw);
@@ -2103,10 +2103,9 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 	s32 ret_val = 0;
 	/* BH SW mailbox bit in SW_FW_SYNC */
 	u16 swmbsw_mask = E1000_SW_SYNCH_MB;
-	u32 ctrl, icr;
+	u32 ctrl;
 	bool global_device_reset = hw->dev_spec._82575.global_device_reset;
 
-
 	hw->dev_spec._82575.global_device_reset = false;
 
 	/* due to hw errata, global device reset doesn't always
@@ -2165,7 +2164,7 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 
 	/* Clear any pending interrupt events. */
 	wr32(E1000_IMC, 0xffffffff);
-	icr = rd32(E1000_ICR);
+	rd32(E1000_ICR);
 
 	ret_val = igb_reset_mdicnfg_82580(hw);
 	if (ret_val)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..7112e52 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3845,7 +3845,6 @@ bool igb_has_link(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	bool link_active = false;
-	s32 ret_val = 0;
 
 	/* get_link_status is set on LSC (link status) interrupt or
 	 * rx sequence error interrupt.  get_link_status will stay
@@ -3854,16 +3853,11 @@ bool igb_has_link(struct igb_adapter *adapter)
 	 */
 	switch (hw->phy.media_type) {
 	case e1000_media_type_copper:
-		if (hw->mac.get_link_status) {
-			ret_val = hw->mac.ops.check_for_link(hw);
-			link_active = !hw->mac.get_link_status;
-		} else {
-			link_active = true;
-		}
-		break;
+		if (!hw->mac.get_link_status)
+			return true;
 	case e1000_media_type_internal_serdes:
-		ret_val = hw->mac.ops.check_for_link(hw);
-		link_active = hw->mac.serdes_has_link;
+		hw->mac.ops.check_for_link(hw);
+		link_active = !hw->mac.get_link_status;
 		break;
 	default:
 	case e1000_media_type_unknown:
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 7e8c477..5a54e3d 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -97,14 +97,14 @@ static cycle_t igb_ptp_read_82580(const struct cyclecounter *cc)
 {
 	struct igb_adapter *igb = container_of(cc, struct igb_adapter, cc);
 	struct e1000_hw *hw = &igb->hw;
+	u32 lo, hi;
 	u64 val;
-	u32 lo, hi, jk;
 
 	/* The timestamp latches on lowest register read. For the 82580
 	 * the lowest register is SYSTIMR instead of SYSTIML.  However we only
 	 * need to provide nanosecond resolution, so we just ignore it.
 	 */
-	jk = rd32(E1000_SYSTIMR);
+	rd32(E1000_SYSTIMR);
 	lo = rd32(E1000_SYSTIML);
 	hi = rd32(E1000_SYSTIMH);
 
@@ -118,13 +118,13 @@ static cycle_t igb_ptp_read_82580(const struct cyclecounter *cc)
 static void igb_ptp_read_i210(struct igb_adapter *adapter, struct timespec *ts)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 sec, nsec, jk;
+	u32 sec, nsec;
 
 	/* The timestamp latches on lowest register read. For I210/I211, the
 	 * lowest register is SYSTIMR. Since we only need to provide nanosecond
 	 * resolution, we can ignore it.
 	 */
-	jk = rd32(E1000_SYSTIMR);
+	rd32(E1000_SYSTIMR);
 	nsec = rd32(E1000_SYSTIML);
 	sec = rd32(E1000_SYSTIMH);
 
-- 
1.7.11.7
