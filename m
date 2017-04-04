From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH] i40e: only register client on iWarp-capable devices
Date: Tue,  4 Apr 2017 12:40:16 -0700
Message-ID: <1491334816-27356-1-git-send-email-mitch.a.williams@intel.com>
Cc: netdev@vger.kernel.org, sassmann@kpanic.de,
        Mitch Williams <mitch.a.williams@intel.com>
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16820 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752477AbdDDTku (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 15:40:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The client interface is only intended for use on devices that support
iWarp). Only register with the client if this is the case.

This fixes a panic when loading i40iw on X710 devices.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Reported-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 87d99fa..5e0e44e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11828,10 +11828,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		  round_jiffies(jiffies + pf->service_timer_period));
 
 	/* add this PF to client device list and launch a client service task */
-	err = i40e_lan_add_device(pf);
-	if (err)
-		dev_info(&pdev->dev, "Failed to add PF to client API service list: %d\n",
-			 err);
+	if (pf->flags & I40E_FLAG_IWARP_ENABLED) {
+		err = i40e_lan_add_device(pf);
+		if (err)
+			dev_info(&pdev->dev, "Failed to add PF to client API service list: %d\n",
+				 err);
+	}
 
 #define PCI_SPEED_SIZE 8
 #define PCI_WIDTH_SIZE 8
@@ -12013,10 +12015,11 @@ static void i40e_remove(struct pci_dev *pdev)
 		i40e_vsi_release(pf->vsi[pf->lan_vsi]);
 
 	/* remove attached clients */
-	ret_code = i40e_lan_del_device(pf);
-	if (ret_code) {
-		dev_warn(&pdev->dev, "Failed to delete client device: %d\n",
-			 ret_code);
+	if (pf->flags & I40E_FLAG_IWARP_ENABLED) {
+		ret_code = i40e_lan_del_device(pf);
+		if (ret_code)
+			dev_warn(&pdev->dev, "Failed to delete client device: %d\n",
+				 ret_code);
 	}
 
 	/* shutdown and destroy the HMC */
-- 
2.7.4
