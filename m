From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e: refactor AQ CMD buffer debug printing
Date: Sat, 18 Feb 2017 22:33:35 -0800
Message-ID: <20170219063341.8039-8-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39180 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751112AbdBSGeN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:13 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This patch refactors the '%*ph' printk format specifier to instead use
the print_hex_dump function, as recommended by the '%*ph' documentation.
This produces better/more standardized output.

Change-ID: Id56700b4e8abc40ff8c04bc8379e7df04cb4d6fd
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 19 ++++++++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 19 ++++++++++++-------
 2 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index fc73e4ef27ac..ece57d6a6e23 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -300,7 +300,6 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
 	u16 len;
 	u8 *buf = (u8 *)buffer;
-	u16 i = 0;
 
 	if ((!(mask & hw->debug_mask)) || (desc == NULL))
 		return;
@@ -328,12 +327,18 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 		if (buf_len < len)
 			len = buf_len;
 		/* write the full 16-byte chunks */
-		for (i = 0; i < (len - 16); i += 16)
-			i40e_debug(hw, mask, "\t0x%04X  %16ph\n", i, buf + i);
-		/* write whatever's left over without overrunning the buffer */
-		if (i < len)
-			i40e_debug(hw, mask, "\t0x%04X  %*ph\n",
-					     i, len - i, buf + i);
+		if (hw->debug_mask & mask) {
+			char prefix[20];
+
+			snprintf(prefix, 20,
+				 "i40e %02x:%02x.%x: \t0x",
+				 hw->bus.bus_id,
+				 hw->bus.device,
+				 hw->bus.func);
+
+			print_hex_dump(KERN_INFO, prefix, DUMP_PREFIX_OFFSET,
+				       16, 1, buf, len, false);
+		}
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index b5a59dd72a0c..89dfdbca13db 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -304,7 +304,6 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 {
 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
 	u8 *buf = (u8 *)buffer;
-	u16 i = 0;
 
 	if ((!(mask & hw->debug_mask)) || (desc == NULL))
 		return;
@@ -332,12 +331,18 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 		if (buf_len < len)
 			len = buf_len;
 		/* write the full 16-byte chunks */
-		for (i = 0; i < (len - 16); i += 16)
-			i40e_debug(hw, mask, "\t0x%04X  %16ph\n", i, buf + i);
-		/* write whatever's left over without overrunning the buffer */
-		if (i < len)
-			i40e_debug(hw, mask, "\t0x%04X  %*ph\n",
-					     i, len - i, buf + i);
+		if (hw->debug_mask & mask) {
+			char prefix[20];
+
+			snprintf(prefix, 20,
+				 "i40evf %02x:%02x.%x: \t0x",
+				 hw->bus.bus_id,
+				 hw->bus.device,
+				 hw->bus.func);
+
+			print_hex_dump(KERN_INFO, prefix, DUMP_PREFIX_OFFSET,
+				       16, 1, buf, len, false);
+		}
 	}
 }
 
-- 
2.11.0
