From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: disable IOV before freeing resources
Date: Tue, 13 Jan 2015 03:33:17 -0800
Message-ID: <1421148811-9763-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41319 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbbAMLde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 06:33:34 -0500
In-Reply-To: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

If VF drivers are loaded in the host OS, the call to pci_disable_sriov()
will cause these drivers' remove routines to be called. If the PF driver
has already freed VF resources before this happens, then the VF remove
routine can't properly communicate with the PF driver causing all sorts
of mayhem and error messages and hurt feelings.

To fix this, we move the call to pci_disable_sriov() up to the top of
the function and let it complete before freeing any VF resources.

Change-ID: I397c3997a00f6408e32b7735273911e499600236
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 5bae895..044019b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -791,10 +791,18 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	if (!pf->vf)
 		return;
 
+	/* Disable IOV before freeing resources. This lets any VF drivers
+	 * running in the host get themselves cleaned up before we yank
+	 * the carpet out from underneath their feet.
+	 */
+	if (!pci_vfs_assigned(pf->pdev))
+		pci_disable_sriov(pf->pdev);
+
+	msleep(20); /* let any messages in transit get finished up */
+
 	/* Disable interrupt 0 so we don't try to handle the VFLR. */
 	i40e_irq_dynamic_disable_icr0(pf);
 
-	mdelay(10); /* let any messages in transit get finished up */
 	/* free up vf resources */
 	tmp = pf->num_alloc_vfs;
 	pf->num_alloc_vfs = 0;
@@ -813,7 +821,6 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	 * before this function ever gets called.
 	 */
 	if (!pci_vfs_assigned(pf->pdev)) {
-		pci_disable_sriov(pf->pdev);
 		/* Acknowledge VFLR for all VFS. Without this, VFs will fail to
 		 * work correctly when SR-IOV gets re-enabled.
 		 */
-- 
1.9.3
