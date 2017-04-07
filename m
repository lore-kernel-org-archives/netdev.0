From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] i40e: close client on remove and shutdown
Date: Thu,  6 Apr 2017 20:23:25 -0700
Message-ID: <20170407032325.33374-5-jeffrey.t.kirsher@intel.com>
References: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:34860 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752836AbdDGDXa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:23:30 -0400
In-Reply-To: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When the driver is removed or shut down, close any attached clients
(i.e. i40iw). This prevents a panic seen sometimes on forced driver
removal or system shutdown when iWarp is running.

Change-ID: I4f6161e5a73ffbb2fd5883567b007310302bfcb5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7147c67a939d..d83430faaa41 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11395,6 +11395,11 @@ static void i40e_remove(struct pci_dev *pdev)
 	if (pf->service_task.func)
 		cancel_work_sync(&pf->service_task);
 
+	/* Client close must be called explicitly here because the timer
+	 * has been stopped.
+	 */
+	i40e_notify_client_of_netdev_close(pf->vsi[pf->lan_vsi], false);
+
 	if (pf->flags & I40E_FLAG_SRIOV_ENABLED) {
 		i40e_free_vfs(pf);
 		pf->flags &= ~I40E_FLAG_SRIOV_ENABLED;
@@ -11635,6 +11640,11 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	cancel_work_sync(&pf->service_task);
 	i40e_fdir_teardown(pf);
 
+	/* Client close must be called explicitly here because the timer
+	 * has been stopped.
+	 */
+	i40e_notify_client_of_netdev_close(pf->vsi[pf->lan_vsi], false);
+
 	if (pf->wol_en && (pf->flags & I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE))
 		i40e_enable_mc_magic_wake(pf);
 
-- 
2.12.2
