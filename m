From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Don't stop driver probe when querying DCB config fails
Date: Mon, 28 Apr 2014 06:52:30 -0700
Message-ID: <1398693158-2815-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59462 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860AbaD1Nwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:46 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

In case of any AQ command to query port's DCB configuration fails
during driver's probe time; the probe fails and returns an error.

This patch prevents this issue by continuing the driver probe even
when an error is returned.

Also, added an error message to dump the AQ error status to show what
error caused the failure to get the DCB configuration from firmware.

Change-ID: Ifd5663512588bca684069bb7d4fb586dd72221af
Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 78308e0..126be0d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4068,6 +4068,9 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 				       DCB_CAP_DCBX_VER_IEEE;
 			pf->flags |= I40E_FLAG_DCB_ENABLED;
 		}
+	} else {
+		dev_info(&pf->pdev->dev, "AQ Querying DCB configuration failed: %d\n",
+			 pf->hw.aq.asq_last_status);
 	}
 
 out:
@@ -8300,7 +8303,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err) {
 		dev_info(&pdev->dev, "init_pf_dcb failed: %d\n", err);
 		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
-		goto err_init_dcb;
+		/* Continue without DCB enabled */
 	}
 #endif /* CONFIG_I40E_DCB */
 
@@ -8438,9 +8441,6 @@ err_vsis:
 err_switch_setup:
 	i40e_reset_interrupt_capability(pf);
 	del_timer_sync(&pf->service_timer);
-#ifdef CONFIG_I40E_DCB
-err_init_dcb:
-#endif /* CONFIG_I40E_DCB */
 err_mac_addr:
 err_configure_lan_hmc:
 	(void)i40e_shutdown_lan_hmc(hw);
-- 
1.9.0
