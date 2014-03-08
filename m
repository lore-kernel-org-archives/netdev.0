From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] e1000e: Fix SHRA register access for 82579
Date: Sat,  8 Mar 2014 01:25:38 -0800
Message-ID: <1394270741-29926-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	John Greene <jogreene@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23968 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbaCHJZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:59 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Previous commit c3a0dce35af0 fixed an overrun for the RAR on i218 devices.
This commit also attempted to homogenize the RAR/SHRA access for all parts
accessed by the e1000e driver.  This change introduced an error for
assigning MAC addresses to guest OS's for 82579 devices.

Only RAR[0] is accessible to the driver for 82579 parts, and additional
addresses must be placed into the SHRA[L|H] registers.  The rar_entry_count
was changed in the previous commit to an inaccurate value that accounted
for all RAR and SHRA registers, not just the ones usable by the driver.

This patch fixes the count to the correct value and adjusts the
e1000_rar_set_pch2lan() function to user the correct index.

Cc: John Greene <jogreene@redhat.com>
Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 1898451..9866f26 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1675,7 +1675,7 @@ static void e1000_rar_set_pch2lan(struct e1000_hw *hw, u8 *addr, u32 index)
 	/* RAR[1-6] are owned by manageability.  Skip those and program the
 	 * next address into the SHRA register array.
 	 */
-	if (index < (u32)(hw->mac.rar_entry_count - 6)) {
+	if (index < (u32)(hw->mac.rar_entry_count)) {
 		s32 ret_val;
 
 		ret_val = e1000_acquire_swflag_ich8lan(hw);
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 553f05e..bead50f 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -101,7 +101,7 @@
 #define PCIE_ICH8_SNOOP_ALL	PCIE_NO_SNOOP_ALL
 
 #define E1000_ICH_RAR_ENTRIES	7
-#define E1000_PCH2_RAR_ENTRIES	11      /* RAR[0-6], SHRA[0-3] */
+#define E1000_PCH2_RAR_ENTRIES	5	/* RAR[0], SHRA[0-3] */
 #define E1000_PCH_LPT_RAR_ENTRIES	12	/* RAR[0], SHRA[0-10] */
 
 #define PHY_PAGE_SHIFT		5
-- 
1.8.3.1
