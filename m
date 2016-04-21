From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] fm10k: fix documentation of fm10k_tlv_parse_attr
Date: Wed, 20 Apr 2016 23:09:22 -0700
Message-ID: <1461218969-68578-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24794 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbcDUGJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:35 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

fm10k_tlv_parse_attr is supposed to return FM10K_NOT_IMPLEMENTED for any
TLV who's attribute id lies outside the range of results. It does not do
this today. In addition, the documentation does not indicate that other
attributes which are not implemented for a given TLV will be silently
ignored. Fix this. Clean up the logic so that we don't rely on the fact
that FM10K_NOT_IMPLEMENTED is greater than zero, as this can easily
cause confusion.

A future extension could look into some way of reporting unknown TLVs
in order to make issues more easily discoverable. We can't just return
FM10K_NOT_IMPLEMENTED here because we don't want to drop the entire
message if it has an unknown TLV.

While here, update the copyright year.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
index b999897..6b500a63 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -481,7 +481,8 @@ static s32 fm10k_tlv_attr_validate(u32 *attr,
  *  up into an array of pointers stored in results.  The function will
  *  return FM10K_ERR_PARAM on any input or message error,
  *  FM10K_NOT_IMPLEMENTED for any attribute that is outside of the array
- *  and 0 on success.
+ *  and 0 on success. Any attributes not found in tlv_attr will be silently
+ *  ignored.
  **/
 static s32 fm10k_tlv_attr_parse(u32 *attr, u32 **results,
 				const struct fm10k_tlv_attr *tlv_attr)
@@ -518,14 +519,15 @@ static s32 fm10k_tlv_attr_parse(u32 *attr, u32 **results,
 	while (offset < len) {
 		attr_id = *attr & FM10K_TLV_ID_MASK;
 
-		if (attr_id < FM10K_TLV_RESULTS_MAX)
-			err = fm10k_tlv_attr_validate(attr, tlv_attr);
-		else
-			err = FM10K_NOT_IMPLEMENTED;
+		if (attr_id >= FM10K_TLV_RESULTS_MAX)
+			return FM10K_NOT_IMPLEMENTED;
 
-		if (err < 0)
+		err = fm10k_tlv_attr_validate(attr, tlv_attr);
+		if (err == FM10K_NOT_IMPLEMENTED)
+			; /* silently ignore non-implemented attributes */
+		else if (err)
 			return err;
-		if (!err)
+		else
 			results[attr_id] = attr;
 
 		/* update offset */
-- 
2.5.5
