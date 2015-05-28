From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: fix unrecognized FCOE EOF case
Date: Thu, 28 May 2015 04:25:34 -0700
Message-ID: <1432812339-17129-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4939 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983AbbE1LZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:56 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Because i40e_fcoe_ctxt_eof should never be called without
i40e_fcoe_eof_is_supported being called first, the EOF in fcoe_ctxt_eof
should always be valid and therefore we do not need to print an error
if it is not valid.

However, a WARN ON to easily catch any calls to i40e_fcoe_ctxt_eof that
aren't preceded with a call to i40e_fcoe_eof_is_supported is helpful.

Change-ID: I3b536b1981ec0bce80576a74440b7dea3908bdb9
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 1803afe..c8b621e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -118,7 +118,7 @@ static inline int i40e_fcoe_fc_eof(struct sk_buff *skb, u8 *eof)
  *
  * The FC EOF is converted to the value understood by HW for descriptor
  * programming. Never call this w/o calling i40e_fcoe_eof_is_supported()
- * first.
+ * first and that already checks for all supported valid eof values.
  **/
 static inline u32 i40e_fcoe_ctxt_eof(u8 eof)
 {
@@ -132,9 +132,12 @@ static inline u32 i40e_fcoe_ctxt_eof(u8 eof)
 	case FC_EOF_A:
 		return I40E_TX_DESC_CMD_L4T_EOFT_EOF_A;
 	default:
-		/* FIXME: still returns 0 */
-		pr_err("Unrecognized EOF %x\n", eof);
-		return 0;
+		/* Supported valid eof shall be already checked by
+		 * calling i40e_fcoe_eof_is_supported() first,
+		 * therefore this default case shall never hit.
+		 */
+		WARN_ON(1);
+		return -EINVAL;
 	}
 }
 
-- 
2.1.0
