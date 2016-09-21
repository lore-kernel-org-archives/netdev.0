From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: avoid potential null pointer dereference when assigning len
Date: Tue, 20 Sep 2016 20:43:46 -0700
Message-ID: <1474429432-102772-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Colin Ian King <colin.king@canonical.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:43488 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754783AbcIUDn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:58 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

There is a sanitcy check for desc being null in the first line of
function i40evf_debug_aq.  However, before that, aq_desc is cast from
desc, and aq_desc is being dereferenced on the assignment of len, so
this could be a potential null pointer deference.  Fix this by moving
the initialization of len to the code block where len is being used
and hence at this point we know it is OK to dereference aq_desc.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
2.7.4
