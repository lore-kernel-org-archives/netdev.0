From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbe: align flow control DV macros with datasheet
Date: Thu, 14 Jun 2012 03:18:05 -0700
Message-ID: <1339669089-27955-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339669089-27955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6172 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755624Ab2FNKSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 06:18:13 -0400
In-Reply-To: <1339669089-27955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The flow control DV macros are used to calculate the flow control
high and low thresholds. This patch annotates these macros slightly
better and fixes the issues below.

The macro variables are renamed LINK to _max_frame_link and TC to
_max_frame_tc. This was to avoid confusion and make them more
readable. It was found that people auditing the code read TC to be
'traffic class' in the 802.1Q definition instead of the max frame
size of the tc. Hopefully it is clear now.

This audit also found the following real deviations from the
theoretical values. Fixed in this patch.

  * I multiplied the DV calculations by (36/25) which always
    evaluates to 1. This does not match the intended theoretical
    value of 1.44.

  * IXGBE_BT2KB added 1023 to account for rounding however this
    really should be 8 * 1023 - 1 to account for division by 8k.

  * x2 multiplication of max frame in DV calculations to account
    for updated hardware recommendations.

With this patch the DV values are inline with the recommendations
in the 82599 and 82598 data sheets. Its worth noting I did not
see any dropped frames with flow control on in my experiments without
this patch. However aligning with the hardware specs and
recommendations seems like a good idea here to account for worst
case scenarios.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |   37 +++++++++++++++----------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 204848d..1085c07 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2419,7 +2419,7 @@ typedef u32 ixgbe_physical_layer;
  */
 
 /* BitTimes (BT) conversion */
-#define IXGBE_BT2KB(BT) ((BT + 1023) / (8 * 1024))
+#define IXGBE_BT2KB(BT) ((BT + (8 * 1024 - 1)) / (8 * 1024))
 #define IXGBE_B2BT(BT) (BT * 8)
 
 /* Calculate Delay to respond to PFC */
@@ -2450,24 +2450,31 @@ typedef u32 ixgbe_physical_layer;
 #define IXGBE_PCI_DELAY	10000
 
 /* Calculate X540 delay value in bit times */
-#define IXGBE_FILL_RATE (36 / 25)
-
-#define IXGBE_DV_X540(LINK, TC) (IXGBE_FILL_RATE * \
-				 (IXGBE_B2BT(LINK) + IXGBE_PFC_D + \
-				 (2 * IXGBE_CABLE_DC) + \
-				 (2 * IXGBE_ID_X540) + \
-				 IXGBE_HD + IXGBE_B2BT(TC)))
+#define IXGBE_DV_X540(_max_frame_link, _max_frame_tc) \
+			((36 * \
+			  (IXGBE_B2BT(_max_frame_link) + \
+			   IXGBE_PFC_D + \
+			   (2 * IXGBE_CABLE_DC) + \
+			   (2 * IXGBE_ID_X540) + \
+			   IXGBE_HD) / 25 + 1) + \
+			 2 * IXGBE_B2BT(_max_frame_tc))
 
 /* Calculate 82599, 82598 delay value in bit times */
-#define IXGBE_DV(LINK, TC) (IXGBE_FILL_RATE * \
-			    (IXGBE_B2BT(LINK) + IXGBE_PFC_D + \
-			    (2 * IXGBE_CABLE_DC) + (2 * IXGBE_ID) + \
-			    IXGBE_HD + IXGBE_B2BT(TC)))
+#define IXGBE_DV(_max_frame_link, _max_frame_tc) \
+			((36 * \
+			  (IXGBE_B2BT(_max_frame_link) + \
+			   IXGBE_PFC_D + \
+			   (2 * IXGBE_CABLE_DC) + \
+			   (2 * IXGBE_ID) + \
+			   IXGBE_HD) / 25 + 1) + \
+			 2 * IXGBE_B2BT(_max_frame_tc))
 
 /* Calculate low threshold delay values */
-#define IXGBE_LOW_DV_X540(TC) (2 * IXGBE_B2BT(TC) + \
-			       (IXGBE_FILL_RATE * IXGBE_PCI_DELAY))
-#define IXGBE_LOW_DV(TC)      (2 * IXGBE_LOW_DV_X540(TC))
+#define IXGBE_LOW_DV_X540(_max_frame_tc) \
+			(2 * IXGBE_B2BT(_max_frame_tc) + \
+			(36 * IXGBE_PCI_DELAY / 25) + 1)
+#define IXGBE_LOW_DV(_max_frame_tc) \
+			(2 * IXGBE_LOW_DV_X540(_max_frame_tc))
 
 /* Software ATR hash keys */
 #define IXGBE_ATR_BUCKET_HASH_KEY    0x3DAD14E2
-- 
1.7.10.2
