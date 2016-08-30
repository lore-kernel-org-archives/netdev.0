From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: Fix kernel panic on enable/disable LLDP
Date: Mon, 29 Aug 2016 17:38:26 -0700
Message-ID: <1472517506-74650-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dave Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:48597 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755526AbcH3Ai3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 20:38:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Ertman <david.m.ertman@intel.com>

If DCB is configured on the link partner switch with an
unsupported traffic class configuration (e.g. non-contiguous TCs),
the driver is flagging DCB as disabled.  But, for future DCB
LLDPDUs, the driver was checking if the interface was DCB capable
instead of enabled.  This was causing a kernel panic when LLDP
was enabled/disabled on the link partner switch.

This patch corrects the situation by having the LLDP event handler
check the correct flag in the pf structure.  It also cleans up the
setting and clearing of the enabled flag for other checks.

Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 828ed28..d0b3a1b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5113,9 +5113,13 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 				       DCB_CAP_DCBX_VER_IEEE;
 
 			pf->flags |= I40E_FLAG_DCB_CAPABLE;
-			/* Enable DCB tagging only when more than one TC */
+			/* Enable DCB tagging only when more than one TC
+			 * or explicitly disable if only one TC
+			 */
 			if (i40e_dcb_get_num_tc(&hw->local_dcbx_config) > 1)
 				pf->flags |= I40E_FLAG_DCB_ENABLED;
+			else
+				pf->flags &= ~I40E_FLAG_DCB_ENABLED;
 			dev_dbg(&pf->pdev->dev,
 				"DCBX offload is supported for this PF.\n");
 		}
@@ -5716,7 +5720,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	u8 type;
 
 	/* Not DCB capable or capability disabled */
-	if (!(pf->flags & I40E_FLAG_DCB_CAPABLE))
+	if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
 		return ret;
 
 	/* Ignore if event is not for Nearest Bridge */
@@ -7896,6 +7900,7 @@ static int i40e_init_interrupt_scheme(struct i40e_pf *pf)
 #endif
 				       I40E_FLAG_RSS_ENABLED	|
 				       I40E_FLAG_DCB_CAPABLE	|
+				       I40E_FLAG_DCB_ENABLED	|
 				       I40E_FLAG_SRIOV_ENABLED	|
 				       I40E_FLAG_FD_SB_ENABLED	|
 				       I40E_FLAG_FD_ATR_ENABLED	|
@@ -10502,6 +10507,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 			       I40E_FLAG_FD_SB_ENABLED	|
 			       I40E_FLAG_FD_ATR_ENABLED	|
 			       I40E_FLAG_DCB_CAPABLE	|
+			       I40E_FLAG_DCB_ENABLED	|
 			       I40E_FLAG_SRIOV_ENABLED	|
 			       I40E_FLAG_VMDQ_ENABLED);
 	} else if (!(pf->flags & (I40E_FLAG_RSS_ENABLED |
@@ -10525,7 +10531,8 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 		/* Not enough queues for all TCs */
 		if ((pf->flags & I40E_FLAG_DCB_CAPABLE) &&
 		    (queues_left < I40E_MAX_TRAFFIC_CLASS)) {
-			pf->flags &= ~I40E_FLAG_DCB_CAPABLE;
+			pf->flags &= ~(I40E_FLAG_DCB_CAPABLE |
+					I40E_FLAG_DCB_ENABLED);
 			dev_info(&pf->pdev->dev, "not enough queues for DCB. DCB is disabled.\n");
 		}
 		pf->num_lan_qps = max_t(int, pf->rss_size_max,
@@ -10922,7 +10929,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = i40e_init_pf_dcb(pf);
 	if (err) {
 		dev_info(&pdev->dev, "DCB init failed %d, disabled\n", err);
-		pf->flags &= ~I40E_FLAG_DCB_CAPABLE;
+		pf->flags &= ~(I40E_FLAG_DCB_CAPABLE & I40E_FLAG_DCB_ENABLED);
 		/* Continue without DCB enabled */
 	}
 #endif /* CONFIG_I40E_DCB */
-- 
2.7.4
