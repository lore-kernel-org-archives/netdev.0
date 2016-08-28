From: Colin King <colin.king@canonical.com>
Subject: [PATCH] i40e: avoid potential null pointer dereference when assigning len
Date: Sun, 28 Aug 2016 18:41:01 +0100
Message-ID: <20160828174101.9671-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

There is a sanitcy check for desc being null in the first line of
function i40evf_debug_aq.  However, before that, aq_desc is cast from
desc, and aq_desc is being dereferenced on the assignment of len, so
this could be a potential null pointer deference.  Fix this by moving
the initialization of len to the code block where len is being used
and hence at this point we know it is OK to dereference aq_desc.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 4db0c03..7953c13 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -302,7 +302,6 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 		   void *buffer, u16 buf_len)
 {
 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
-	u16 len = le16_to_cpu(aq_desc->datalen);
 	u8 *buf = (u8 *)buffer;
 	u16 i = 0;
 
@@ -326,6 +325,8 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 		   le32_to_cpu(aq_desc->params.external.addr_low));
 
 	if ((buffer != NULL) && (aq_desc->datalen != 0)) {
+		u16 len = le16_to_cpu(aq_desc->datalen);
+
 		i40e_debug(hw, mask, "AQ CMD Buffer:\n");
 		if (buf_len < len)
 			len = buf_len;
-- 
2.9.3
