From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/13] i40e: Detect ATR HW Evict NVM issue and disable the feature
Date: Fri, 25 Aug 2017 15:00:50 -0700
Message-ID: <20170825220057.51804-7-jeffrey.t.kirsher@intel.com>
References: <20170825220057.51804-1-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Alice Michael <alice.michael@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48593 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935133AbdHYWBF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 18:01:05 -0400
In-Reply-To: <20170825220057.51804-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch fixes a problem with the HW ATR eviction feature where the
NVM setting was incorrect.  This patch detects the issue on X720
adapters and disables the feature if the NVM setting is incorrect.

Without this patch, HW ATR Evict feature does not work on broken NVMs
and is not detected either.  If the HW ATR Evict feature is disabled
the SW Eviction feature will take effect.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Alice Michael <alice.michael@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4d1eb0c19028..6a59d9367a2a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8963,6 +8963,14 @@ static int i40e_sw_init(struct i40e_pf *pf)
 				    I40E_HW_PTP_L4_CAPABLE |
 				    I40E_HW_WOL_MC_MAGIC_PKT_WAKE |
 				    I40E_HW_OUTER_UDP_CSUM_CAPABLE);
+
+#define I40E_FDEVICT_PCTYPE_DEFAULT 0xc03
+		if (rd32(&pf->hw, I40E_GLQF_FDEVICTENA(1)) !=
+		    I40E_FDEVICT_PCTYPE_DEFAULT) {
+			dev_warn(&pf->pdev->dev,
+				 "FD EVICT PCTYPES are not right, disable FD HW EVICT\n");
+			pf->hw_features &= ~I40E_HW_ATR_EVICT_CAPABLE;
+		}
 	} else if ((pf->hw.aq.api_maj_ver > 1) ||
 		   ((pf->hw.aq.api_maj_ver == 1) &&
 		    (pf->hw.aq.api_min_ver > 4))) {
-- 
2.14.1
