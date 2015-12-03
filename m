From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] i40e/i40evf: avoid mutex re-init
Date: Thu,  3 Dec 2015 13:57:54 -0800
Message-ID: <1449179874-49174-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449179874-49174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60729 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbbLCV55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 16:57:57 -0500
In-Reply-To: <1449179874-49174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

If the driver were to happen to have a mutex held while
the i40e_init_adminq call was called, the init_adminq might
inadvertently call mutex_init on a lock that was held
which is a violation of the calling semantics.

Fix this by avoiding adminq.c code allocating/freeing this memory, and
then do the same work only once in probe/remove.

Testing Hints (Required if no HSD): for VF, load i40evf in bare metal
and echo 32 > sriov_numvfs; echo 0 > sriov_numvfs in a loop.  Yes this
is a horrible thing to do.

Change-ID: Ida263c51b34e195252179e7e5e400d73a99be7a2
Reported-by: Stefan Assmann <sassmann@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |  6 ------
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 11 ++++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |  6 ------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 ++++++++++
 4 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 0ff8f01..1fd5ea8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -567,10 +567,6 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 		goto init_adminq_exit;
 	}
 
-	/* initialize locks */
-	mutex_init(&hw->aq.asq_mutex);
-	mutex_init(&hw->aq.arq_mutex);
-
 	/* Set up register offsets */
 	i40e_adminq_init_regs(hw);
 
@@ -664,8 +660,6 @@ i40e_status i40e_shutdown_adminq(struct i40e_hw *hw)
 	i40e_shutdown_asq(hw);
 	i40e_shutdown_arq(hw);
 
-	/* destroy the locks */
-
 	if (hw->nvm_buff.va)
 		i40e_free_virt_mem(hw, &hw->nvm_buff);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b825f97..4a9873ec 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10295,6 +10295,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* set up a default setting for link flow control */
 	pf->hw.fc.requested_mode = I40E_FC_NONE;
 
+	/* set up the locks for the AQ, do this only once in probe
+	 * and destroy them only once in remove
+	 */
+	mutex_init(&hw->aq.asq_mutex);
+	mutex_init(&hw->aq.arq_mutex);
+
 	err = i40e_init_adminq(hw);
 
 	/* provide nvm, fw, api versions */
@@ -10697,7 +10703,6 @@ static void i40e_remove(struct pci_dev *pdev)
 	set_bit(__I40E_DOWN, &pf->state);
 	del_timer_sync(&pf->service_timer);
 	cancel_work_sync(&pf->service_task);
-	i40e_fdir_teardown(pf);
 
 	if (pf->flags & I40E_FLAG_SRIOV_ENABLED) {
 		i40e_free_vfs(pf);
@@ -10740,6 +10745,10 @@ static void i40e_remove(struct pci_dev *pdev)
 			 "Failed to destroy the Admin Queue resources: %d\n",
 			 ret_code);
 
+	/* destroy the locks only once, here */
+	mutex_destroy(&hw->aq.arq_mutex);
+	mutex_destroy(&hw->aq.asq_mutex);
+
 	/* Clear all dynamic memory lists of rings, q_vectors, and VSIs */
 	i40e_clear_interrupt_scheme(pf);
 	for (i = 0; i < pf->num_alloc_vsi; i++) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index fd123ca..3f65e39 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -551,10 +551,6 @@ i40e_status i40evf_init_adminq(struct i40e_hw *hw)
 		goto init_adminq_exit;
 	}
 
-	/* initialize locks */
-	mutex_init(&hw->aq.asq_mutex);
-	mutex_init(&hw->aq.arq_mutex);
-
 	/* Set up register offsets */
 	i40e_adminq_init_regs(hw);
 
@@ -596,8 +592,6 @@ i40e_status i40evf_shutdown_adminq(struct i40e_hw *hw)
 	i40e_shutdown_asq(hw);
 	i40e_shutdown_arq(hw);
 
-	/* destroy the locks */
-
 	if (hw->nvm_buff.va)
 		i40e_free_virt_mem(hw, &hw->nvm_buff);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d962164..99d2cff 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2476,6 +2476,12 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->bus.device = PCI_SLOT(pdev->devfn);
 	hw->bus.func = PCI_FUNC(pdev->devfn);
 
+	/* set up the locks for the AQ, do this only once in probe
+	 * and destroy them only once in remove
+	 */
+	mutex_init(&hw->aq.asq_mutex);
+	mutex_init(&hw->aq.arq_mutex);
+
 	INIT_LIST_HEAD(&adapter->mac_filter_list);
 	INIT_LIST_HEAD(&adapter->vlan_filter_list);
 
@@ -2629,6 +2635,10 @@ static void i40evf_remove(struct pci_dev *pdev)
 	if (hw->aq.asq.count)
 		i40evf_shutdown_adminq(hw);
 
+	/* destroy the locks only once, here */
+	mutex_destroy(&hw->aq.arq_mutex);
+	mutex_destroy(&hw->aq.asq_mutex);
+
 	iounmap(hw->hw_addr);
 	pci_release_regions(pdev);
 
-- 
2.5.0
