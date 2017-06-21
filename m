From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Support firmware CEE DCB UP to TC map re-definition
Date: Tue, 20 Jun 2017 18:17:55 -0700
Message-ID: <20170621011802.81768-9-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Greg Bowers <gregory.j.bowers@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:4752 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753143AbdFUBSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:16 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Bowers <gregory.j.bowers@intel.com>

Changes parsing of FW 4.33 AQ command Get CEE DCBX OPER CFG (0x0A07).
Change is required because FW now creates the oper_prio_tc
nibbles reversed from those in the CEE Priority Group sub-TLV.
This change will only apply to FW 4.33 as future FW versions will use a
different function to parse the CEE data.

Signed-off-by: Greg Bowers <gregory.j.bowers@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index bf1d67e184f7..55079fe3ed63 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -620,14 +620,17 @@ static void i40e_cee_to_dcb_v1_config(
 	/* CEE PG data to ETS config */
 	dcbcfg->etscfg.maxtcs = cee_cfg->oper_num_tc;
 
+	/* Note that the FW creates the oper_prio_tc nibbles reversed
+	 * from those in the CEE Priority Group sub-TLV.
+	 */
 	for (i = 0; i < 4; i++) {
 		tc = (u8)((cee_cfg->oper_prio_tc[i] &
-			 I40E_CEE_PGID_PRIO_1_MASK) >>
-			 I40E_CEE_PGID_PRIO_1_SHIFT);
-		dcbcfg->etscfg.prioritytable[i*2] =  tc;
-		tc = (u8)((cee_cfg->oper_prio_tc[i] &
 			 I40E_CEE_PGID_PRIO_0_MASK) >>
 			 I40E_CEE_PGID_PRIO_0_SHIFT);
+		dcbcfg->etscfg.prioritytable[i * 2] =  tc;
+		tc = (u8)((cee_cfg->oper_prio_tc[i] &
+			 I40E_CEE_PGID_PRIO_1_MASK) >>
+			 I40E_CEE_PGID_PRIO_1_SHIFT);
 		dcbcfg->etscfg.prioritytable[i*2 + 1] = tc;
 	}
 
-- 
2.12.2
