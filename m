From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] ixgbe: Cleanup unpacking code for DCB
Date: Sat, 14 Jul 2012 16:07:02 -0700
Message-ID: <1342307225-28917-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23399 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128Ab2GNXHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 19:07:43 -0400
In-Reply-To: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This is meant to be a generic clean-up of the remaining functions for
unpacking data from the DCB structures. The only real changes are:
replaced the variable i with tc for functions that were looping through the
traffic classes, and added a pointer for tc_class instead of path since
that way we only need to pull the pointer once instead of once per loop.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c |   47 ++++++++++++--------------
 1 file changed, 22 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 4fd5a0d..39ac2fe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -180,55 +180,52 @@ out:
 
 void ixgbe_dcb_unpack_pfc(struct ixgbe_dcb_config *cfg, u8 *pfc_en)
 {
-	int i;
+	struct tc_configuration *tc_config = &cfg->tc_config[0];
+	int tc;
 
-	*pfc_en = 0;
-	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-		*pfc_en |= !!(cfg->tc_config[i].dcb_pfc & 0xF) << i;
+	for (*pfc_en = 0, tc = 0; tc < MAX_TRAFFIC_CLASS; tc++) {
+		if (tc_config[tc].dcb_pfc != pfc_disabled)
+			*pfc_en |= 1 << tc;
+	}
 }
 
 void ixgbe_dcb_unpack_refill(struct ixgbe_dcb_config *cfg, int direction,
 			     u16 *refill)
 {
-	struct tc_bw_alloc *p;
-	int i;
+	struct tc_configuration *tc_config = &cfg->tc_config[0];
+	int tc;
 
-	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &cfg->tc_config[i].path[direction];
-		refill[i] = p->data_credits_refill;
-	}
+	for (tc = 0; tc < MAX_TRAFFIC_CLASS; tc++)
+		refill[tc] = tc_config[tc].path[direction].data_credits_refill;
 }
 
 void ixgbe_dcb_unpack_max(struct ixgbe_dcb_config *cfg, u16 *max)
 {
-	int i;
+	struct tc_configuration *tc_config = &cfg->tc_config[0];
+	int tc;
 
-	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-		max[i] = cfg->tc_config[i].desc_credits_max;
+	for (tc = 0; tc < MAX_TRAFFIC_CLASS; tc++)
+		max[tc] = tc_config[tc].desc_credits_max;
 }
 
 void ixgbe_dcb_unpack_bwgid(struct ixgbe_dcb_config *cfg, int direction,
 			    u8 *bwgid)
 {
-	struct tc_bw_alloc *p;
-	int i;
+	struct tc_configuration *tc_config = &cfg->tc_config[0];
+	int tc;
 
-	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &cfg->tc_config[i].path[direction];
-		bwgid[i] = p->bwg_id;
-	}
+	for (tc = 0; tc < MAX_TRAFFIC_CLASS; tc++)
+		bwgid[tc] = tc_config[tc].path[direction].bwg_id;
 }
 
 void ixgbe_dcb_unpack_prio(struct ixgbe_dcb_config *cfg, int direction,
 			    u8 *ptype)
 {
-	struct tc_bw_alloc *p;
-	int i;
+	struct tc_configuration *tc_config = &cfg->tc_config[0];
+	int tc;
 
-	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &cfg->tc_config[i].path[direction];
-		ptype[i] = p->prio_type;
-	}
+	for (tc = 0; tc < MAX_TRAFFIC_CLASS; tc++)
+		ptype[tc] = tc_config[tc].path[direction].prio_type;
 }
 
 static u8 ixgbe_dcb_get_tc_from_up(struct ixgbe_dcb_config *cfg,
-- 
1.7.10.4
