From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40e: Add define for interrupt name string len
Date: Thu, 15 Jan 2015 04:19:16 -0800
Message-ID: <1421324368-6860-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066AbbAOMTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:33 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch creates a define for interrupt name string configuration that
is large enough to contain full bus/slot info, rather than just netdev->name.

Change-ID: Iaac0d23dfb8526defeed69d91cea85ed4a50ddb2
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  5 +++--
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 ++++++------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index fc50f64..fadf8fa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -92,6 +92,7 @@
 #define I40E_MAX_USER_PRIORITY        8
 #define I40E_DEFAULT_MSG_ENABLE       4
 #define I40E_QUEUE_WAIT_RETRY_LIMIT   10
+#define I40E_INT_NAME_STR_LEN        (IFNAMSIZ + 9)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
@@ -268,7 +269,7 @@ struct i40e_pf {
 	u16 rx_itr_default;
 	u16 tx_itr_default;
 	u16 msg_enable;
-	char misc_int_name[IFNAMSIZ + 9];
+	char int_name[I40E_INT_NAME_STR_LEN];
 	u16 adminq_work_limit; /* num of admin receive queue desc to process */
 	unsigned long service_timer_period;
 	unsigned long service_timer_previous;
@@ -524,7 +525,7 @@ struct i40e_q_vector {
 
 	cpumask_t affinity_mask;
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
-	char name[IFNAMSIZ + 9];
+	char name[I40E_INT_NAME_STR_LEN];
 } ____cacheline_internodealigned_in_smp;
 
 /* lan device */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fd6411e..4d1fe56 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3402,10 +3402,10 @@ static int i40e_vsi_request_irq(struct i40e_vsi *vsi, char *basename)
 		err = i40e_vsi_request_irq_msix(vsi, basename);
 	else if (pf->flags & I40E_FLAG_MSI_ENABLED)
 		err = request_irq(pf->pdev->irq, i40e_intr, 0,
-				  pf->misc_int_name, pf);
+				  pf->int_name, pf);
 	else
 		err = request_irq(pf->pdev->irq, i40e_intr, IRQF_SHARED,
-				  pf->misc_int_name, pf);
+				  pf->int_name, pf);
 
 	if (err)
 		dev_info(&pf->pdev->dev, "request_irq failed, Error %d\n", err);
@@ -4846,7 +4846,7 @@ static int i40e_open(struct net_device *netdev)
 int i40e_vsi_open(struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = vsi->back;
-	char int_name[IFNAMSIZ + 9];
+	char int_name[I40E_INT_NAME_STR_LEN];
 	int err;
 
 	/* allocate descriptors */
@@ -7128,11 +7128,11 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 	 */
 	if (!test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state)) {
 		err = request_irq(pf->msix_entries[0].vector,
-				  i40e_intr, 0, pf->misc_int_name, pf);
+				  i40e_intr, 0, pf->int_name, pf);
 		if (err) {
 			dev_info(&pf->pdev->dev,
 				 "request_irq for %s failed: %d\n",
-				 pf->misc_int_name, err);
+				 pf->int_name, err);
 			return -EFAULT;
 		}
 	}
@@ -9179,7 +9179,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->aq.asq_buf_size = I40E_MAX_AQ_BUF_SIZE;
 	pf->adminq_work_limit = I40E_AQ_WORK_LIMIT;
 
-	snprintf(pf->misc_int_name, sizeof(pf->misc_int_name) - 1,
+	snprintf(pf->int_name, sizeof(pf->int_name) - 1,
 		 "%s-%s:misc",
 		 dev_driver_string(&pf->pdev->dev), dev_name(&pdev->dev));
 
-- 
1.9.3
