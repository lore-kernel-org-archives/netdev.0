From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] i40e: Make sure to be in VEB mode if SRIOV is enabled at probe
Date: Thu,  4 Jun 2015 20:27:04 -0700
Message-ID: <1433474824-5414-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433474824-5414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:39345 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883AbbFED1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 23:27:12 -0400
In-Reply-To: <1433474824-5414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

If SRIOV is enabled we need to be in VEB mode not VEPA mode at probe.
This fixes an NPAR bug when SRIOV is enabled in the BIOS.

Change-ID: Ibf006abafd9a0ca3698ec24848cd771cf345cbbc
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 853eb2f..5b5bea1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8756,9 +8756,14 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 					 __func__);
 				return NULL;
 			}
-			/* We come up by default in VEPA mode */
-			veb->bridge_mode = BRIDGE_MODE_VEPA;
-			pf->flags &= ~I40E_FLAG_VEB_MODE_ENABLED;
+			/* We come up by default in VEPA mode if SRIOV is not
+			 * already enabled, in which case we can't force VEPA
+			 * mode.
+			 */
+			if (!(pf->flags & I40E_FLAG_VEB_MODE_ENABLED)) {
+				veb->bridge_mode = BRIDGE_MODE_VEPA;
+				pf->flags &= ~I40E_FLAG_VEB_MODE_ENABLED;
+			}
 			i40e_config_bridge_mode(veb);
 		}
 		for (i = 0; i < I40E_MAX_VEB && !veb; i++) {
@@ -9869,6 +9874,15 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_switch_setup;
 	}
 
+#ifdef CONFIG_PCI_IOV
+	/* prep for VF support */
+	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
+	    (pf->flags & I40E_FLAG_MSIX_ENABLED) &&
+	    !test_bit(__I40E_BAD_EEPROM, &pf->state)) {
+		if (pci_num_vf(pdev))
+			pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
+	}
+#endif
 	err = i40e_setup_pf_switch(pf, false);
 	if (err) {
 		dev_info(&pdev->dev, "setup_pf_switch failed: %d\n", err);
-- 
2.1.0
