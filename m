From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] ixgbe: Use num_tcs.pg_tcs as upper limit for TC when checking based on UP
Date: Sat, 21 Jul 2012 16:08:57 -0700
Message-ID: <1342912142-11130-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22894 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989Ab2GUXJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:11 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so the function ixgbe_dcb_get_tc_from_up will use the
num_tcs.pg_tcs to determine the starting value for determining a traffic
class based on a user priority.  The main motivation for this change is to
address possible bad configurations in which more TCs worth of data are
populated then there are actual TCs.  By limiting this value we can at
least make certain we are not providing a map with values that are out of
range.

As a result any user priorities that are setup in the configuration with a
traffic class mapping higher than what the hardware supports will be
reported as being on TC 0.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 5442b35..9bc17c0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -232,18 +232,22 @@ u8 ixgbe_dcb_get_tc_from_up(struct ixgbe_dcb_config *cfg, int direction, u8 up)
 {
 	struct tc_configuration *tc_config = &cfg->tc_config[0];
 	u8 prio_mask = 1 << up;
-	u8 tc;
+	u8 tc = cfg->num_tcs.pg_tcs;
+
+	/* If tc is 0 then DCB is likely not enabled or supported */
+	if (!tc)
+		goto out;
 
 	/*
-	 * Test for TCs 7 through 1 and report the first match we find.  If
+	 * Test from maximum TC to 1 and report the first match we find.  If
 	 * we find no match we can assume that the TC is 0 since the TC must
 	 * be set for all user priorities
 	 */
-	for (tc = MAX_TRAFFIC_CLASS - 1; tc; tc--) {
+	for (tc--; tc; tc--) {
 		if (prio_mask & tc_config[tc].path[direction].up_to_tc_bitmap)
 			break;
 	}
-
+out:
 	return tc;
 }
 
-- 
1.7.10.4
