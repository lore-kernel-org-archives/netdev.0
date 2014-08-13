From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [linux-stable] i40e: Don't stop driver probe when querying DCB config fails
Date: Wed, 13 Aug 2014 04:30:55 -0700
Message-ID: <1407929455-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	stable@vger.kernel.org,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: gregkh@linuxfoundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20620 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbaHMLbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 07:31:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Commit id: 014269ff376f552363ecdab78d3d947fbe2237d9 in Linus's tree
should be queued up for stable 3.14 & 3.15 since the i40e driver will
not load when DCB is enabled, unless this patch is applied.

In case of any AQ command to query port's DCB configuration fails
during driver's probe time; the probe fails and returns an error.

This patch prevents this issue by continuing the driver probe even
when an error is returned.

Also, added an error message to dump the AQ error status to show what
error caused the failure to get the DCB configuration from firmware.

Change-ID: Ifd5663512588bca684069bb7d4fb586dd72221af
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b901371..5d3206d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4024,6 +4024,9 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 				       DCB_CAP_DCBX_VER_IEEE;
 			pf->flags |= I40E_FLAG_DCB_ENABLED;
 		}
+	} else {
+		dev_info(&pf->pdev->dev, "AQ Querying DCB configuration failed: %d\n",
+			 pf->hw.aq.asq_last_status);
 	}
 
 out:
@@ -8003,7 +8006,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err) {
 		dev_info(&pdev->dev, "init_pf_dcb failed: %d\n", err);
 		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
-		goto err_init_dcb;
+		/* Continue without DCB enabled */
 	}
 #endif /* CONFIG_I40E_DCB */
 
@@ -8119,9 +8122,6 @@ err_vsis:
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
1.9.3
