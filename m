From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e1000e: locking bug introduced by commit 67fd4fcb
Date: Thu, 13 Oct 2011 23:21:23 -0700
Message-ID: <1318573288-18286-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27147 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab1JNGVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 02:21:31 -0400
In-Reply-To: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Commit 67fd4fcb (e1000e: convert to stats64) added the ability to update
statistics more accurately and on-demand through the net_device_ops
.ndo_get_stats64 hook, but introduced a locking bug on 82577/8/9 when
linked at half-duplex (seen on kernels with CONFIG_DEBUG_ATOMIC_SLEEP=y and
CONFIG_PROVE_LOCKING=y).  The commit introduced code paths that caused a
mutex to be locked in atomic contexts, e.g. an rcu_read_lock is held when
irqbalance reads the stats from /sys/class/net/ethX/statistics causing the
mutex to be locked to read the Phy half-duplex statistics registers.

The mutex was originally introduced to prevent concurrent accesses of
resources (the NVM and Phy) shared by the driver, firmware and hardware
a few years back when there was an issue with the NVM getting corrupted.
It was later split into two mutexes - one for the NVM and one for the Phy
when it was determined the NVM, unlike the Phy, should not be protected by
the software/firmware/hardware semaphore (arbitration of which is done in
part with the SWFLAG bit in the EXTCNF_CTRL register).  This latter
semaphore should be sufficient to prevent resource contention of the Phy in
the driver (i.e. the mutex for Phy accesses is not needed), but to be sure
the mutex is replaced with an atomic bit flag which will warn if any
contention is possible.

Also add additional debug output to help determine when the sw/fw/hw
semaphore is owned by the firmware or hardware.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Reported-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |    1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   21 +++++++++++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 7877b9c..9fe18d1 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -469,6 +469,7 @@ struct e1000_info {
 enum e1000_state_t {
 	__E1000_TESTING,
 	__E1000_RESETTING,
+	__E1000_ACCESS_SHARED_RESOURCE,
 	__E1000_DOWN
 };
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 4f70974..6a17c62 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -852,8 +852,6 @@ static void e1000_release_nvm_ich8lan(struct e1000_hw *hw)
 	mutex_unlock(&nvm_mutex);
 }
 
-static DEFINE_MUTEX(swflag_mutex);
-
 /**
  *  e1000_acquire_swflag_ich8lan - Acquire software control flag
  *  @hw: pointer to the HW structure
@@ -866,7 +864,12 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	u32 extcnf_ctrl, timeout = PHY_CFG_TIMEOUT;
 	s32 ret_val = 0;
 
-	mutex_lock(&swflag_mutex);
+	if (test_and_set_bit(__E1000_ACCESS_SHARED_RESOURCE,
+			     &hw->adapter->state)) {
+		WARN(1, "e1000e: %s: contention for Phy access\n",
+		     hw->adapter->netdev->name);
+		return -E1000_ERR_PHY;
+	}
 
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
@@ -878,7 +881,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		e_dbg("SW/FW/HW has locked the resource for too long.\n");
+		e_dbg("SW has already locked the resource.\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -898,7 +901,9 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		e_dbg("Failed to acquire the semaphore.\n");
+		e_dbg("Failed to acquire the semaphore, FW or HW has it: "
+		      "FWSM=0x%8.8x EXTCNF_CTRL=0x%8.8x)\n",
+		      er32(FWSM), extcnf_ctrl);
 		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 		ew32(EXTCNF_CTRL, extcnf_ctrl);
 		ret_val = -E1000_ERR_CONFIG;
@@ -907,7 +912,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 out:
 	if (ret_val)
-		mutex_unlock(&swflag_mutex);
+		clear_bit(__E1000_ACCESS_SHARED_RESOURCE, &hw->adapter->state);
 
 	return ret_val;
 }
@@ -932,7 +937,7 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 		e_dbg("Semaphore unexpectedly released by sw/fw/hw\n");
 	}
 
-	mutex_unlock(&swflag_mutex);
+	clear_bit(__E1000_ACCESS_SHARED_RESOURCE, &hw->adapter->state);
 }
 
 /**
@@ -3139,7 +3144,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	msleep(20);
 
 	if (!ret_val)
-		mutex_unlock(&swflag_mutex);
+		clear_bit(__E1000_ACCESS_SHARED_RESOURCE, &hw->adapter->state);
 
 	if (ctrl & E1000_CTRL_PHY_RST) {
 		ret_val = hw->phy.ops.get_cfg_done(hw);
-- 
1.7.6.4
