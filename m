From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/20] i40e/i40evf: Use private workqueue
Date: Thu,  4 Feb 2016 03:49:05 -0800
Message-ID: <1454586551-35919-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41087 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933859AbcBDLtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:15 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As done per ixgbe, use a private workqueue to avoid blocking the
system workqueue.  This avoids some strange side effects when
some other entity is depending on the system work queue.

Change-ID: Ic8ba08f5b03696cf638b21afd25fbae7738d55ee
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 15 ++++++++++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 +++++++++-
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bd81a97..3e482bc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -112,6 +112,8 @@ MODULE_DESCRIPTION("Intel(R) Ethernet Connection XL710 Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static struct workqueue_struct *i40e_wq;
+
 /**
  * i40e_allocate_dma_mem_d - OS specific memory alloc for shared code
  * @hw:   pointer to the HW structure
@@ -297,7 +299,7 @@ static void i40e_service_event_schedule(struct i40e_pf *pf)
 	if (!test_bit(__I40E_DOWN, &pf->state) &&
 	    !test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) &&
 	    !test_and_set_bit(__I40E_SERVICE_SCHED, &pf->state))
-		schedule_work(&pf->service_task);
+		queue_work(i40e_wq, &pf->service_task);
 }
 
 /**
@@ -11470,6 +11472,16 @@ static int __init i40e_init_module(void)
 		i40e_driver_string, i40e_driver_version_str);
 	pr_info("%s: %s\n", i40e_driver_name, i40e_copyright);
 
+	/* we will see if single thread per module is enough for now,
+	 * it can't be any worse than using the system workqueue which
+	 * was already single threaded
+	 */
+	i40e_wq = create_singlethread_workqueue(i40e_driver_name);
+	if (!i40e_wq) {
+		pr_err("%s: Failed to create workqueue\n", i40e_driver_name);
+		return -ENOMEM;
+	}
+
 	i40e_dbg_init();
 	return pci_register_driver(&i40e_driver);
 }
@@ -11484,6 +11496,7 @@ module_init(i40e_init_module);
 static void __exit i40e_exit_module(void)
 {
 	pci_unregister_driver(&i40e_driver);
+	destroy_workqueue(i40e_wq);
 	i40e_dbg_exit();
 }
 module_exit(i40e_exit_module);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 615ad0f..66964eb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -69,6 +69,8 @@ MODULE_DESCRIPTION("Intel(R) XL710 X710 Virtual Function Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static struct workqueue_struct *i40evf_wq;
+
 /**
  * i40evf_allocate_dma_mem_d - OS specific memory alloc for shared code
  * @hw:   pointer to the HW structure
@@ -182,7 +184,7 @@ static void i40evf_tx_timeout(struct net_device *netdev)
 	if (!(adapter->flags & (I40EVF_FLAG_RESET_PENDING |
 				I40EVF_FLAG_RESET_NEEDED))) {
 		adapter->flags |= I40EVF_FLAG_RESET_NEEDED;
-		schedule_work(&adapter->reset_task);
+		queue_work(i40evf_wq, &adapter->reset_task);
 	}
 }
 
@@ -2895,6 +2897,11 @@ static int __init i40evf_init_module(void)
 
 	pr_info("%s\n", i40evf_copyright);
 
+	i40evf_wq = create_singlethread_workqueue(i40evf_driver_name);
+	if (!i40evf_wq) {
+		pr_err("%s: Failed to create workqueue\n", i40evf_driver_name);
+		return -ENOMEM;
+	}
 	ret = pci_register_driver(&i40evf_driver);
 	return ret;
 }
@@ -2910,6 +2917,7 @@ module_init(i40evf_init_module);
 static void __exit i40evf_exit_module(void)
 {
 	pci_unregister_driver(&i40evf_driver);
+	destroy_workqueue(i40evf_wq);
 }
 
 module_exit(i40evf_exit_module);
-- 
2.5.0
