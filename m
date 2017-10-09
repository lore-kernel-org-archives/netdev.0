From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] ixgbe: fix use of uninitialized padding
Date: Mon,  9 Oct 2017 11:39:57 -0700
Message-ID: <20171009184000.80053-8-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54282 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755234AbdJISkY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:24 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch is resolving Coverity hits where padding in a structure could
be used uninitialized.

- Initialize fwd_cmd.pad/2 before ixgbe_calculate_checksum()

- Initialize buffer.pad2/3 before ixgbe_hic_unlocked()

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c   | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 2c19070d2a0b..041940c4bb2b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3800,10 +3800,10 @@ s32 ixgbe_set_fw_drv_ver_generic(struct ixgbe_hw *hw, u8 maj, u8 min,
 	fw_cmd.ver_build = build;
 	fw_cmd.ver_sub = sub;
 	fw_cmd.hdr.checksum = 0;
-	fw_cmd.hdr.checksum = ixgbe_calculate_checksum((u8 *)&fw_cmd,
-				(FW_CEM_HDR_LEN + fw_cmd.hdr.buf_len));
 	fw_cmd.pad = 0;
 	fw_cmd.pad2 = 0;
+	fw_cmd.hdr.checksum = ixgbe_calculate_checksum((u8 *)&fw_cmd,
+				(FW_CEM_HDR_LEN + fw_cmd.hdr.buf_len));
 
 	for (i = 0; i <= FW_CEM_MAX_RETRIES; i++) {
 		ret_val = ixgbe_host_interface_command(hw, &fw_cmd,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 8cea53b62e1b..cb7da5f9c4da 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -900,6 +900,8 @@ static s32 ixgbe_read_ee_hostif_buffer_X550(struct ixgbe_hw *hw,
 		/* convert offset from words to bytes */
 		buffer.address = cpu_to_be32((offset + current_word) * 2);
 		buffer.length = cpu_to_be16(words_to_read * 2);
+		buffer.pad2 = 0;
+		buffer.pad3 = 0;
 
 		status = ixgbe_hic_unlocked(hw, (u32 *)&buffer, sizeof(buffer),
 					    IXGBE_HI_COMMAND_TIMEOUT);
-- 
2.14.2
