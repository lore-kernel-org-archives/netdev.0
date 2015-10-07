From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] i40e: enable WoL operation if config bit show WoL capable
Date: Wed,  7 Oct 2015 15:46:56 -0700
Message-ID: <1444258032-41476-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8249 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175AbbJGWrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:22 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The driver was disabling Wake-on-LAN by default and waiting for the user
to expressly turn it on.  This patch has the driver turning on WoL from
the start if enabled in the hardware config, which matches the behavior
of our other drivers.

Change-ID: I43faedb907f8ba4d1a61b72a7c86072b97af12b1
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5646ee8..7fc5e2c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9947,6 +9947,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
+	u16 wol_nvm_bits;
 	u16 link_status;
 	int err = 0;
 	u32 len;
@@ -10163,8 +10164,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	clear_bit(__I40E_SERVICE_SCHED, &pf->state);
 	pf->flags |= I40E_FLAG_NEED_LINK_UPDATE;
 
-	/* WoL defaults to disabled */
-	pf->wol_en = false;
+	/* NVM bit on means WoL disabled for the port */
+	i40e_read_nvm_word(hw, I40E_SR_NVM_WAKE_ON_LAN, &wol_nvm_bits);
+	if ((1 << hw->port) & wol_nvm_bits || hw->partition_id != 1)
+		pf->wol_en = false;
+	else
+		pf->wol_en = true;
 	device_set_wakeup_enable(&pf->pdev->dev, pf->wol_en);
 
 	/* set up the main switch operations */
-- 
2.4.3
