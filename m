From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] ixgbe: fix endianess when writing driver version to firmware
Date: Mon, 17 Oct 2011 17:12:45 -0700
Message-ID: <1318896767-5374-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32924 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab1JRAMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 20:12:52 -0400
In-Reply-To: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch makes sure that register writes are in little endian and
also converts the reads back to big-endian.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 35fa444..834f044 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3341,7 +3341,7 @@ static u8 ixgbe_calculate_checksum(u8 *buffer, u32 length)
  *  Communicates with the manageability block.  On success return 0
  *  else return IXGBE_ERR_HOST_INTERFACE_COMMAND.
  **/
-static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u8 *buffer,
+static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u32 *buffer,
 					u32 length)
 {
 	u32 hicr, i;
@@ -3374,7 +3374,7 @@ static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u8 *buffer,
 	 */
 	for (i = 0; i < dword_len; i++)
 		IXGBE_WRITE_REG_ARRAY(hw, IXGBE_FLEX_MNG,
-				      i, *((u32 *)buffer + i));
+				      i, cpu_to_le32(buffer[i]));
 
 	/* Setting this bit tells the ARC that a new command is pending. */
 	IXGBE_WRITE_REG(hw, IXGBE_HICR, hicr | IXGBE_HICR_C);
@@ -3398,9 +3398,10 @@ static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u8 *buffer,
 	dword_len = hdr_size >> 2;
 
 	/* first pull in the header so we know the buffer length */
-	for (i = 0; i < dword_len; i++)
-		*((u32 *)buffer + i) =
-			IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, i);
+	for (i = 0; i < dword_len; i++) {
+		buffer[i] = IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, i);
+		le32_to_cpus(&buffer[i]);
+	}
 
 	/* If there is any thing in data position pull it in */
 	buf_len = ((struct ixgbe_hic_hdr *)buffer)->buf_len;
@@ -3418,8 +3419,7 @@ static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u8 *buffer,
 
 	/* Pull in the rest of the buffer (i is where we left off)*/
 	for (; i < buf_len; i++)
-		*((u32 *)buffer + i) =
-			IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, i);
+		buffer[i] = IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, i);
 
 out:
 	return ret_val;
@@ -3465,7 +3465,7 @@ s32 ixgbe_set_fw_drv_ver_generic(struct ixgbe_hw *hw, u8 maj, u8 min,
 	fw_cmd.pad2 = 0;
 
 	for (i = 0; i <= FW_CEM_MAX_RETRIES; i++) {
-		ret_val = ixgbe_host_interface_command(hw, (u8 *)&fw_cmd,
+		ret_val = ixgbe_host_interface_command(hw, (u32 *)&fw_cmd,
 						       sizeof(fw_cmd));
 		if (ret_val != 0)
 			continue;
-- 
1.7.6.4
