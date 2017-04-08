From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] i40e: only register client on iWarp-capable devices
Date: Sat,  8 Apr 2017 02:55:42 -0700
Message-ID: <20170408095553.78307-2-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26215 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751447AbdDHJz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:55:58 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The client interface is only intended for use on devices that support
iWarp. Only register with the client if this is the case.

This fixes a panic when loading i40iw on X710 devices.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Reported-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d83430faaa41..1ee2759c38f7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11245,10 +11245,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -11426,10 +11428,11 @@ static void i40e_remove(struct pci_dev *pdev)
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
2.12.2
