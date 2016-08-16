From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] i40e: check for and deal with non-contiguous TCs
Date: Tue, 16 Aug 2016 13:40:14 -0700
Message-ID: <1471380014-134435-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dave Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20746 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466AbcHPUkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 16:40:18 -0400
In-Reply-To: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Ertman <david.m.ertman@intel.com>

The i40e driver was causing a kernel panic when
non-contiguous Traffic Classes, or Traffic Classes not
starting with TC0, were configured on a link partner switch.
i40e does not support non-contiguous TCs.

To fix this, the patch changes the logic when determining
the total number of TCs enabled.  Before, this would use the
highest TC number enabled and assume that all TCs below it were
also enabled.  Now, we create a bitmask of enabled TCs and scan
it to determine not only the number of TCs, but also if the set
of enabled TCs starts at zero and is contiguous.  If not, then
DCB is disabled by only returning one TC.

Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 35 ++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 81c99e1..c6ac7a6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4554,23 +4554,38 @@ static u8 i40e_get_iscsi_tc_map(struct i40e_pf *pf)
  **/
 static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
 {
+	int i, tc_unused = 0;
 	u8 num_tc = 0;
-	int i;
+	u8 ret = 0;
 
 	/* Scan the ETS Config Priority Table to find
 	 * traffic class enabled for a given priority
-	 * and use the traffic class index to get the
-	 * number of traffic classes enabled
+	 * and create a bitmask of enabled TCs
 	 */
-	for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
-		if (dcbcfg->etscfg.prioritytable[i] > num_tc)
-			num_tc = dcbcfg->etscfg.prioritytable[i];
-	}
+	for (i = 0; i < I40E_MAX_USER_PRIORITY; i++)
+		num_tc |= BIT(dcbcfg->etscfg.prioritytable[i]);
 
-	/* Traffic class index starts from zero so
-	 * increment to return the actual count
+	/* Now scan the bitmask to check for
+	 * contiguous TCs starting with TC0
 	 */
-	return num_tc + 1;
+	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
+		if (num_tc & BIT(i)) {
+			if (!tc_unused) {
+				ret++;
+			} else {
+				pr_err("Non-contiguous TC - Disabling DCB\n");
+				return 1;
+			}
+		} else {
+			tc_unused = 1;
+		}
+	}
+
+	/* There is always at least TC0 */
+	if (!ret)
+		ret = 1;
+
+	return ret;
 }
 
 /**
-- 
2.7.4
