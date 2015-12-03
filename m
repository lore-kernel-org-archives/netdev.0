From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] ixgbe: Use private workqueue to avoid certain possible hangs
Date: Thu,  3 Dec 2015 03:07:11 -0800
Message-ID: <1449140843-118580-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28882 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759868AbbLCLH1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:27 -0500
In-Reply-To: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Use a private workqueue to avoid hangs that were otherwise possible
when performing stress tests, such as creating and destroying many
VFS repeatedly.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c95042e..0918e32 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -172,6 +172,8 @@ MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static struct workqueue_struct *ixgbe_wq;
+
 static bool ixgbe_check_cfg_remove(struct ixgbe_hw *hw, struct pci_dev *pdev);
 
 static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
@@ -313,7 +315,7 @@ static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
 	    !test_bit(__IXGBE_REMOVING, &adapter->state) &&
 	    !test_and_set_bit(__IXGBE_SERVICE_SCHED, &adapter->state))
-		schedule_work(&adapter->service_task);
+		queue_work(ixgbe_wq, &adapter->service_task);
 }
 
 static void ixgbe_remove_adapter(struct ixgbe_hw *hw)
@@ -9320,6 +9322,12 @@ static int __init ixgbe_init_module(void)
 	pr_info("%s - version %s\n", ixgbe_driver_string, ixgbe_driver_version);
 	pr_info("%s\n", ixgbe_copyright);
 
+	ixgbe_wq = create_singlethread_workqueue(ixgbe_driver_name);
+	if (!ixgbe_wq) {
+		pr_err("%s: Failed to create workqueue\n", ixgbe_driver_name);
+		return -ENOMEM;
+	}
+
 	ixgbe_dbg_init();
 
 	ret = pci_register_driver(&ixgbe_driver);
@@ -9351,6 +9359,10 @@ static void __exit ixgbe_exit_module(void)
 	pci_unregister_driver(&ixgbe_driver);
 
 	ixgbe_dbg_exit();
+	if (ixgbe_wq) {
+		destroy_workqueue(ixgbe_wq);
+		ixgbe_wq = NULL;
+	}
 }
 
 #ifdef CONFIG_IXGBE_DCA
-- 
2.5.0
