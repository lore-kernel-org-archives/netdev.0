From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Fix a bug with VMDq RSS queue allocation
Date: Sat, 12 Aug 2017 04:08:37 -0700
Message-ID: <20170812110848.18264-6-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Alice Michael <alice.michael@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7745 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750802AbdHLLIx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:53 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The X722 pf flag setup should happen before the VMDq RSS queue count is
initialized for VMDq VSI to get the right number of queues for RSS in
case of X722 devices.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Alice Michael <alice.michael@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 46 ++++++++++++++---------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0cb571e337f6..5df25df123d7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9000,6 +9000,29 @@ static int i40e_sw_init(struct i40e_pf *pf)
 				 pf->hw.func_caps.fd_filters_best_effort;
 	}
 
+	if (pf->hw.mac.type == I40E_MAC_X722) {
+		pf->flags |= I40E_FLAG_RSS_AQ_CAPABLE
+			     | I40E_FLAG_128_QP_RSS_CAPABLE
+			     | I40E_FLAG_HW_ATR_EVICT_CAPABLE
+			     | I40E_FLAG_OUTER_UDP_CSUM_CAPABLE
+			     | I40E_FLAG_WB_ON_ITR_CAPABLE
+			     | I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE
+			     | I40E_FLAG_NO_PCI_LINK_CHECK
+			     | I40E_FLAG_USE_SET_LLDP_MIB
+			     | I40E_FLAG_GENEVE_OFFLOAD_CAPABLE
+			     | I40E_FLAG_PTP_L4_CAPABLE
+			     | I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE;
+	} else if ((pf->hw.aq.api_maj_ver > 1) ||
+		   ((pf->hw.aq.api_maj_ver == 1) &&
+		    (pf->hw.aq.api_min_ver > 4))) {
+		/* Supported in FW API version higher than 1.4 */
+		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
+	}
+
+	/* Enable HW ATR eviction if possible */
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
+		pf->flags |= I40E_FLAG_HW_ATR_EVICT_ENABLED;
+
 	if ((pf->hw.mac.type == I40E_MAC_XL710) &&
 	    (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 33)) ||
 	    (pf->hw.aq.fw_maj_ver < 4))) {
@@ -9041,29 +9064,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 					I40E_MAX_VF_COUNT);
 	}
 #endif /* CONFIG_PCI_IOV */
-	if (pf->hw.mac.type == I40E_MAC_X722) {
-		pf->flags |= I40E_FLAG_RSS_AQ_CAPABLE
-			     | I40E_FLAG_128_QP_RSS_CAPABLE
-			     | I40E_FLAG_HW_ATR_EVICT_CAPABLE
-			     | I40E_FLAG_OUTER_UDP_CSUM_CAPABLE
-			     | I40E_FLAG_WB_ON_ITR_CAPABLE
-			     | I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE
-			     | I40E_FLAG_NO_PCI_LINK_CHECK
-			     | I40E_FLAG_USE_SET_LLDP_MIB
-			     | I40E_FLAG_GENEVE_OFFLOAD_CAPABLE
-			     | I40E_FLAG_PTP_L4_CAPABLE
-			     | I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE;
-	} else if ((pf->hw.aq.api_maj_ver > 1) ||
-		   ((pf->hw.aq.api_maj_ver == 1) &&
-		    (pf->hw.aq.api_min_ver > 4))) {
-		/* Supported in FW API version higher than 1.4 */
-		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
-	}
-
-	/* Enable HW ATR eviction if possible */
-	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
-		pf->flags |= I40E_FLAG_HW_ATR_EVICT_ENABLED;
-
 	pf->eeprom_version = 0xDEAD;
 	pf->lan_veb = I40E_NO_VEB;
 	pf->lan_vsi = I40E_NO_VSI;
-- 
2.14.0
