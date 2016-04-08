From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/18] ixgbe: Take manageability semaphore for firmware commands
Date: Thu,  7 Apr 2016 20:21:00 -0700
Message-ID: <1460085673-87056-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63152 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756906AbcDHDVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:19 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

We need to take the manageability semaphore when issuing firmware
commands to avoid problems. With this in place, the semaphore is
no longer taken in the ixgbe_set_fw_drv_ver_generic function, since
it will now always be taken by the ixgbe_host_interface_command
function.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 30 ++++++++++++++++---------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index b8cdff7..ee43a38 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3494,11 +3494,16 @@ s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, void *buffer,
 		struct ixgbe_hic_hdr hdr;
 		u32 u32arr[1];
 	} *bp = buffer;
+	s32 status;
 
 	if (!length || length > IXGBE_HI_MAX_BLOCK_BYTE_LENGTH) {
 		hw_dbg(hw, "Buffer length failure buffersize-%d.\n", length);
 		return IXGBE_ERR_HOST_INTERFACE_COMMAND;
 	}
+	/* Take management host interface semaphore */
+	status = hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_SW_MNG_SM);
+	if (status)
+		return status;
 
 	/* Set bit 9 of FWSTS clearing FW reset indication */
 	fwsts = IXGBE_READ_REG(hw, IXGBE_FWSTS);
@@ -3508,13 +3513,15 @@ s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, void *buffer,
 	hicr = IXGBE_READ_REG(hw, IXGBE_HICR);
 	if (!(hicr & IXGBE_HICR_EN)) {
 		hw_dbg(hw, "IXGBE_HOST_EN bit disabled.\n");
-		return IXGBE_ERR_HOST_INTERFACE_COMMAND;
+		status = IXGBE_ERR_HOST_INTERFACE_COMMAND;
+		goto rel_out;
 	}
 
 	/* Calculate length in DWORDs. We must be DWORD aligned */
 	if (length % sizeof(u32)) {
 		hw_dbg(hw, "Buffer length failure, not aligned to dword");
-		return IXGBE_ERR_INVALID_ARGUMENT;
+		status = IXGBE_ERR_INVALID_ARGUMENT;
+		goto rel_out;
 	}
 
 	dword_len = length >> 2;
@@ -3540,11 +3547,12 @@ s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, void *buffer,
 	if ((timeout && i == timeout) ||
 	    !(IXGBE_READ_REG(hw, IXGBE_HICR) & IXGBE_HICR_SV)) {
 		hw_dbg(hw, "Command has failed with no status valid.\n");
-		return IXGBE_ERR_HOST_INTERFACE_COMMAND;
+		status = IXGBE_ERR_HOST_INTERFACE_COMMAND;
+		goto rel_out;
 	}
 
 	if (!return_data)
-		return 0;
+		goto rel_out;
 
 	/* Calculate length in DWORDs */
 	dword_len = hdr_size >> 2;
@@ -3558,11 +3566,12 @@ s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, void *buffer,
 	/* If there is any thing in data position pull it in */
 	buf_len = bp->hdr.buf_len;
 	if (!buf_len)
-		return 0;
+		goto rel_out;
 
 	if (length < round_up(buf_len, 4) + hdr_size) {
 		hw_dbg(hw, "Buffer not large enough for reply message.\n");
-		return IXGBE_ERR_HOST_INTERFACE_COMMAND;
+		status = IXGBE_ERR_HOST_INTERFACE_COMMAND;
+		goto rel_out;
 	}
 
 	/* Calculate length in DWORDs, add 3 for odd lengths */
@@ -3574,7 +3583,10 @@ s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, void *buffer,
 		le32_to_cpus(&bp->u32arr[bi]);
 	}
 
-	return 0;
+rel_out:
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_SW_MNG_SM);
+
+	return status;
 }
 
 /**
@@ -3597,9 +3609,6 @@ s32 ixgbe_set_fw_drv_ver_generic(struct ixgbe_hw *hw, u8 maj, u8 min,
 	int i;
 	s32 ret_val;
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_SW_MNG_SM))
-		return IXGBE_ERR_SWFW_SYNC;
-
 	fw_cmd.hdr.cmd = FW_CEM_CMD_DRIVER_INFO;
 	fw_cmd.hdr.buf_len = FW_CEM_CMD_DRIVER_INFO_LEN;
 	fw_cmd.hdr.cmd_or_resp.cmd_resv = FW_CEM_CMD_RESERVED;
@@ -3631,7 +3640,6 @@ s32 ixgbe_set_fw_drv_ver_generic(struct ixgbe_hw *hw, u8 maj, u8 min,
 		break;
 	}
 
-	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_SW_MNG_SM);
 	return ret_val;
 }
 
-- 
2.5.5
