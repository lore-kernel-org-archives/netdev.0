From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] ixgbe: Simplify logic for getting traffic class from user priority
Date: Sat, 14 Jul 2012 16:07:01 -0700
Message-ID: <1342307225-28917-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23399 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208Ab2GNXHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 19:07:41 -0400
In-Reply-To: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to help simplify the logic for getting traffic classes
from user priorities. To do this I am adding a function named
ixgbe_dcb_get_tc_from_up that will go through the traffic classes in
reverse order in order to determine which traffic class contains a bit for
a given user priority.

Adding a declaration for this new function to the header so that
we have a centralized means for sorting out traffic classes belonging to
features such as FCoE.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c |   30 ++++++++++++++++++++------
 1 file changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 8bfaaee..4fd5a0d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -231,16 +231,32 @@ void ixgbe_dcb_unpack_prio(struct ixgbe_dcb_config *cfg, int direction,
 	}
 }
 
-void ixgbe_dcb_unpack_map(struct ixgbe_dcb_config *cfg, int direction, u8 *map)
+static u8 ixgbe_dcb_get_tc_from_up(struct ixgbe_dcb_config *cfg,
+				   int direction, u8 up)
 {
-	int i, up;
-	unsigned long bitmap;
+	struct tc_configuration *tc_config = &cfg->tc_config[0];
+	u8 prio_mask = 1 << up;
+	u8 tc;
 
-	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		bitmap = cfg->tc_config[i].path[direction].up_to_tc_bitmap;
-		for_each_set_bit(up, &bitmap, MAX_USER_PRIORITY)
-			map[up] = i;
+	/*
+	 * Test for TCs 7 through 1 and report the first match we find.  If
+	 * we find no match we can assume that the TC is 0 since the TC must
+	 * be set for all user priorities
+	 */
+	for (tc = MAX_TRAFFIC_CLASS - 1; tc; tc--) {
+		if (prio_mask & tc_config[tc].path[direction].up_to_tc_bitmap)
+			break;
 	}
+
+	return tc;
+}
+
+void ixgbe_dcb_unpack_map(struct ixgbe_dcb_config *cfg, int direction, u8 *map)
+{
+	u8 up;
+
+	for (up = 0; up < MAX_USER_PRIORITY; up++)
+		map[up] = ixgbe_dcb_get_tc_from_up(cfg, direction, up);
 }
 
 /**
-- 
1.7.10.4
