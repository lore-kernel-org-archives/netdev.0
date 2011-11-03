From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 08/10] ixgbe: fix reading of the buffer returned by the firmware
Date: Wed,  2 Nov 2011 17:19:59 -0700
Message-ID: <1320279601-1276-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753215Ab1KCAUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:09 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch fixes some issues found in the buffer read portion of
ixgbe_host_interface_command()

- use `bi` as the buffer index counter instead of `i`
- add conversion to native cpu byte ordering on register read
- fix conversion from bytes to dword
- use dword_len instead of buf_len when reading the register

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 834f044..f1365fe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3344,7 +3344,7 @@ static u8 ixgbe_calculate_checksum(u8 *buffer, u32 length)
 static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u32 *buffer,
 					u32 length)
 {
-	u32 hicr, i;
+	u32 hicr, i, bi;
 	u32 hdr_size = sizeof(struct ixgbe_hic_hdr);
 	u8 buf_len, dword_len;
 
@@ -3398,9 +3398,9 @@ static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u32 *buffer,
 	dword_len = hdr_size >> 2;
 
 	/* first pull in the header so we know the buffer length */
-	for (i = 0; i < dword_len; i++) {
-		buffer[i] = IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, i);
-		le32_to_cpus(&buffer[i]);
+	for (bi = 0; bi < dword_len; bi++) {
+		buffer[bi] = IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, bi);
+		le32_to_cpus(&buffer[bi]);
 	}
 
 	/* If there is any thing in data position pull it in */
@@ -3414,12 +3414,14 @@ static s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u32 *buffer,
 		goto out;
 	}
 
-	/* Calculate length in DWORDs, add one for odd lengths */
-	dword_len = (buf_len + 1) >> 2;
+	/* Calculate length in DWORDs, add 3 for odd lengths */
+	dword_len = (buf_len + 3) >> 2;
 
-	/* Pull in the rest of the buffer (i is where we left off)*/
-	for (; i < buf_len; i++)
-		buffer[i] = IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, i);
+	/* Pull in the rest of the buffer (bi is where we left off)*/
+	for (; bi <= dword_len; bi++) {
+		buffer[bi] = IXGBE_READ_REG_ARRAY(hw, IXGBE_FLEX_MNG, bi);
+		le32_to_cpus(&buffer[bi]);
+	}
 
 out:
 	return ret_val;
-- 
1.7.6.4
