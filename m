From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/16] i40e: Fix the EMPR interrupt received handling
Date: Mon, 23 Feb 2015 18:11:15 -0800
Message-ID: <1424743881-30485-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57876 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440AbbBXCLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 21:11:33 -0500
In-Reply-To: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We shouldn't trigger another EMPR when we receive an EMPR event.
This patch handles EMPR event reception with a different state
so that we can do the right thing for NVM.

Change-ID: I9cac70b3658600f016a65beb6fb157e1c1f9adf9
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2: Update to use test_and_clear_bit() as Sergei Shtylyov has suggested

 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++----
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2b65cdc..5912fdf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -140,6 +140,7 @@ enum i40e_state_t {
 	__I40E_CORE_RESET_REQUESTED,
 	__I40E_GLOBAL_RESET_REQUESTED,
 	__I40E_EMP_RESET_REQUESTED,
+	__I40E_EMP_RESET_INTR_RECEIVED,
 	__I40E_FILTER_OVERFLOW_PROMISC,
 	__I40E_SUSPENDED,
 	__I40E_PTP_TX_IN_PROGRESS,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2260cc1..652cb4e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3171,7 +3171,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 			pf->globr_count++;
 		} else if (val == I40E_RESET_EMPR) {
 			pf->empr_count++;
-			set_bit(__I40E_EMP_RESET_REQUESTED, &pf->state);
+			set_bit(__I40E_EMP_RESET_INTR_RECEIVED, &pf->state);
 		}
 	}
 
@@ -6179,10 +6179,8 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	}
 
 	/* re-verify the eeprom if we just had an EMP reset */
-	if (test_bit(__I40E_EMP_RESET_REQUESTED, &pf->state)) {
-		clear_bit(__I40E_EMP_RESET_REQUESTED, &pf->state);
+	if (test_and_clear_bit(__I40E_EMP_RESET_INTR_RECEIVED, &pf->state))
 		i40e_verify_eeprom(pf);
-	}
 
 	i40e_clear_pxe_mode(hw);
 	ret = i40e_get_capabilities(pf);
-- 
1.9.3
