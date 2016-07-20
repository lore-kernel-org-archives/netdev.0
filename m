From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/20] fm10k: don't stop reset due to FM10K_ERR_REQUESTS_PENDING
Date: Wed, 20 Jul 2016 15:23:43 -0700
Message-ID: <1469053438-85381-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755274AbcGTWYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:02 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Don't report FM10K_ERR_REQUESTS_PENDING when we fail to disable queues
within the timeout. This can occur due to a hardware Tx hang, or when
the switch ethernet fabric is resetting while we are transmitting
traffic. It can sometimes take up to 500ms before the Tx DMA engine
gives up. Instead, just skip the DMA engine check and perform
a data-path reset anyways. Add a statistic counter to keep track of the
number of resets occurring while we have pending DMA on the rings.

In order to prevent having to re-assign err to 0, re-order the
last few items of the reset_hw_pf function so that we don't perform
"return err" at the end.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 24 ++++++++++++++----------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      | 12 +++++++-----
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 9b51954..c04cbe9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -76,6 +76,8 @@ static const struct fm10k_stats fm10k_gstrings_global_stats[] = {
 	FM10K_STAT("mac_rules_used", hw.swapi.mac.used),
 	FM10K_STAT("mac_rules_avail", hw.swapi.mac.avail),
 
+	FM10K_STAT("reset_while_pending", hw.mac.reset_while_pending),
+
 	FM10K_STAT("tx_hang_count", tx_timeout_count),
 };
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 69e2c82..7fbd94b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -51,8 +51,12 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 
 	/* shut down all rings */
 	err = fm10k_disable_queues_generic(hw, FM10K_MAX_QUEUES);
-	if (err)
+	if (err == FM10K_ERR_REQUESTS_PENDING) {
+		hw->mac.reset_while_pending++;
+		goto force_reset;
+	} else if (err) {
 		return err;
+	}
 
 	/* Verify that DMA is no longer active */
 	reg = fm10k_read_reg(hw, FM10K_DMA_CTRL);
@@ -62,27 +66,27 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 	/* verify the switch is ready for reset */
 	reg = fm10k_read_reg(hw, FM10K_DMA_CTRL2);
 	if (!(reg & FM10K_DMA_CTRL2_SWITCH_READY))
-		goto out;
+		return FM10K_ERR_DMA_PENDING;
 
+force_reset:
 	/* Inititate data path reset */
-	reg |= FM10K_DMA_CTRL_DATAPATH_RESET;
+	reg = FM10K_DMA_CTRL_DATAPATH_RESET;
 	fm10k_write_reg(hw, FM10K_DMA_CTRL, reg);
 
 	/* Flush write and allow 100us for reset to complete */
 	fm10k_write_flush(hw);
 	udelay(FM10K_RESET_TIMEOUT);
 
-	/* Verify we made it out of reset */
-	reg = fm10k_read_reg(hw, FM10K_IP);
-	if (!(reg & FM10K_IP_NOTINRESET))
-		err = FM10K_ERR_RESET_FAILED;
-
 	/* Reset mailbox global interrupts */
 	reg = FM10K_MBX_GLOBAL_REQ_INTERRUPT | FM10K_MBX_GLOBAL_ACK_INTERRUPT;
 	fm10k_write_reg(hw, FM10K_GMBX, reg);
 
-out:
-	return err;
+	/* Verify we made it out of reset */
+	reg = fm10k_read_reg(hw, FM10K_IP);
+	if (!(reg & FM10K_IP_NOTINRESET))
+		return FM10K_ERR_RESET_FAILED;
+
+	return 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index b8bc061..1d65ad8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -562,6 +562,7 @@ struct fm10k_mac_info {
 	bool tx_ready;
 	u32 dglort_map;
 	u8 itr_scale;
+	u64 reset_while_pending;
 };
 
 struct fm10k_swapi_table_info {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 3b06685e..337ba65 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -34,7 +34,7 @@ static s32 fm10k_stop_hw_vf(struct fm10k_hw *hw)
 
 	/* we need to disable the queues before taking further steps */
 	err = fm10k_stop_hw_generic(hw);
-	if (err)
+	if (err && err != FM10K_ERR_REQUESTS_PENDING)
 		return err;
 
 	/* If permanent address is set then we need to restore it */
@@ -67,7 +67,7 @@ static s32 fm10k_stop_hw_vf(struct fm10k_hw *hw)
 		fm10k_write_reg(hw, FM10K_TDLEN(i), tdlen);
 	}
 
-	return 0;
+	return err;
 }
 
 /**
@@ -83,7 +83,9 @@ static s32 fm10k_reset_hw_vf(struct fm10k_hw *hw)
 
 	/* shut down queues we own and reset DMA configuration */
 	err = fm10k_stop_hw_vf(hw);
-	if (err)
+	if (err == FM10K_ERR_REQUESTS_PENDING)
+		hw->mac.reset_while_pending++;
+	else if (err)
 		return err;
 
 	/* Inititate VF reset */
@@ -96,9 +98,9 @@ static s32 fm10k_reset_hw_vf(struct fm10k_hw *hw)
 	/* Clear reset bit and verify it was cleared */
 	fm10k_write_reg(hw, FM10K_VFCTRL, 0);
 	if (fm10k_read_reg(hw, FM10K_VFCTRL) & FM10K_VFCTRL_RST)
-		err = FM10K_ERR_RESET_FAILED;
+		return FM10K_ERR_RESET_FAILED;
 
-	return err;
+	return 0;
 }
 
 /**
-- 
2.5.5
