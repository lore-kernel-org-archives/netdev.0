From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] igb: Add SMBI semaphore to I210/I211
Date: Sat, 20 Apr 2013 02:49:06 -0700
Message-ID: <1366451353-24714-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49450 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686Ab3DTJtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 05:49:21 -0400
In-Reply-To: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

It was previously thought that, since I210/I211 are single port devices,
they did not need the SMBI semaphore. This is not the case. Add support for
the SMBI semaphore.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |  3 ++
 drivers/net/ethernet/intel/igb/e1000_hw.h    |  1 +
 drivers/net/ethernet/intel/igb/e1000_i210.c  | 65 +++++++++++++++++-----------
 3 files changed, 43 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index c9bba39d5..6cb0ca2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -389,6 +389,9 @@ static s32 igb_init_mac_params_82575(struct e1000_hw *hw)
 		dev_spec->eee_disable = false;
 	else
 		dev_spec->eee_disable = true;
+	/* Allow a single clear of the SW semaphore on I210 and newer */
+	if (mac->type >= e1000_i210)
+		dev_spec->clear_semaphore_once = true;
 	/* physical interface link setup */
 	mac->ops.setup_physical_interface =
 		(hw->phy.media_type == e1000_media_type_copper)
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 1138cca..f1dbab9 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -529,6 +529,7 @@ struct e1000_dev_spec_82575 {
 	bool sgmii_active;
 	bool global_device_reset;
 	bool eee_disable;
+	bool clear_semaphore_once;
 };
 
 struct e1000_hw {
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 9764cd3..ddb3cf5 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -44,10 +44,42 @@
 static s32 igb_get_hw_semaphore_i210(struct e1000_hw *hw)
 {
 	u32 swsm;
-	s32 ret_val = E1000_SUCCESS;
 	s32 timeout = hw->nvm.word_size + 1;
 	s32 i = 0;
 
+	/* Get the SW semaphore */
+	while (i < timeout) {
+		swsm = rd32(E1000_SWSM);
+		if (!(swsm & E1000_SWSM_SMBI))
+			break;
+
+		udelay(50);
+		i++;
+	}
+
+	if (i == timeout) {
+		/* In rare circumstances, the SW semaphore may already be held
+		 * unintentionally. Clear the semaphore once before giving up.
+		 */
+		if (hw->dev_spec._82575.clear_semaphore_once) {
+			hw->dev_spec._82575.clear_semaphore_once = false;
+			igb_put_hw_semaphore(hw);
+			for (i = 0; i < timeout; i++) {
+				swsm = rd32(E1000_SWSM);
+				if (!(swsm & E1000_SWSM_SMBI))
+					break;
+
+				udelay(50);
+			}
+		}
+
+		/* If we do not have the semaphore here, we have to give up. */
+		if (i == timeout) {
+			hw_dbg("Driver can't access device - SMBI bit is set.\n");
+			return -E1000_ERR_NVM;
+		}
+	}
+
 	/* Get the FW semaphore. */
 	for (i = 0; i < timeout; i++) {
 		swsm = rd32(E1000_SWSM);
@@ -64,12 +96,10 @@ static s32 igb_get_hw_semaphore_i210(struct e1000_hw *hw)
 		/* Release semaphores */
 		igb_put_hw_semaphore(hw);
 		hw_dbg("Driver can't access the NVM\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
-out:
-	return ret_val;
+	return E1000_SUCCESS;
 }
 
 /**
@@ -99,23 +129,6 @@ void igb_release_nvm_i210(struct e1000_hw *hw)
 }
 
 /**
- *  igb_put_hw_semaphore_i210 - Release hardware semaphore
- *  @hw: pointer to the HW structure
- *
- *  Release hardware semaphore used to access the PHY or NVM
- **/
-static void igb_put_hw_semaphore_i210(struct e1000_hw *hw)
-{
-	u32 swsm;
-
-	swsm = rd32(E1000_SWSM);
-
-	swsm &= ~E1000_SWSM_SWESMBI;
-
-	wr32(E1000_SWSM, swsm);
-}
-
-/**
  *  igb_acquire_swfw_sync_i210 - Acquire SW/FW semaphore
  *  @hw: pointer to the HW structure
  *  @mask: specifies which semaphore to acquire
@@ -138,11 +151,11 @@ s32 igb_acquire_swfw_sync_i210(struct e1000_hw *hw, u16 mask)
 		}
 
 		swfw_sync = rd32(E1000_SW_FW_SYNC);
-		if (!(swfw_sync & fwmask))
+		if (!(swfw_sync & (fwmask | swmask)))
 			break;
 
 		/* Firmware currently using resource (fwmask) */
-		igb_put_hw_semaphore_i210(hw);
+		igb_put_hw_semaphore(hw);
 		mdelay(5);
 		i++;
 	}
@@ -156,7 +169,7 @@ s32 igb_acquire_swfw_sync_i210(struct e1000_hw *hw, u16 mask)
 	swfw_sync |= swmask;
 	wr32(E1000_SW_FW_SYNC, swfw_sync);
 
-	igb_put_hw_semaphore_i210(hw);
+	igb_put_hw_semaphore(hw);
 out:
 	return ret_val;
 }
@@ -180,7 +193,7 @@ void igb_release_swfw_sync_i210(struct e1000_hw *hw, u16 mask)
 	swfw_sync &= ~mask;
 	wr32(E1000_SW_FW_SYNC, swfw_sync);
 
-	igb_put_hw_semaphore_i210(hw);
+	igb_put_hw_semaphore(hw);
 }
 
 /**
-- 
1.7.11.7
