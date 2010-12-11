From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 12/27] ixgbe: fix X540 to use it's own info struct
Date: Fri, 10 Dec 2010 22:18:59 -0800
Message-ID: <1292048354-22076-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:57319 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751264Ab0LKGTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:19:19 -0500
To: davem@davemloft.net
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch enables X540 hardware to use it's own set of support
functions.  This is useful as it has no need of SFP+ support.  A
couple minor bugs with the eeprom semaphore were also cleaned up.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   16 ++++++++--------
 drivers/net/ixgbe/ixgbe_x540.c |    4 ++--
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fdb35d0..f2694f2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -118,7 +118,7 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_COMBO_BACKPLANE),
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T),
-	 board_82599 },
+	 board_X540 },
 
 	/* required last entry */
 	{0, }
@@ -1897,6 +1897,13 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
+		ixgbe_check_sfp_event(adapter, eicr);
+		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
+		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
+			adapter->interrupt_event = eicr;
+			schedule_work(&adapter->check_overtemp_task);
+		}
+		/* now fallthrough to handle Flow Director */
 	case ixgbe_mac_X540:
 		/* Handle Flow Director Full threshold interrupt */
 		if (eicr & IXGBE_EICR_FLOW_DIR) {
@@ -1912,12 +1919,6 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 					schedule_work(&adapter->fdir_reinit_task);
 			}
 		}
-		ixgbe_check_sfp_event(adapter, eicr);
-		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
-		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
-			adapter->interrupt_event = eicr;
-			schedule_work(&adapter->check_overtemp_task);
-		}
 		break;
 	default:
 		break;
@@ -2508,7 +2509,6 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
 		ixgbe_check_sfp_event(adapter, eicr);
 		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
 		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 9649fa7..cf88515 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -278,7 +278,7 @@ static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 {
 	s32 status;
 
-	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM))
+	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM) == 0)
 		status = ixgbe_read_eerd_generic(hw, offset, data);
 	else
 		status = IXGBE_ERR_SWFW_SYNC;
@@ -311,7 +311,7 @@ static s32 ixgbe_write_eewr_X540(struct ixgbe_hw *hw, u16 offset, u16 data)
 	       (data << IXGBE_EEPROM_RW_REG_DATA) |
 	       IXGBE_EEPROM_RW_REG_START;
 
-	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM)) {
+	if (ixgbe_acquire_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM) == 0) {
 		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
 		if (status != 0) {
 			hw_dbg(hw, "Eeprom write EEWR timed out\n");
-- 
1.7.3.2

