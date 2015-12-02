From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] ixgbevf: Use a private workqueue to avoid certain possible hangs
Date: Wed,  2 Dec 2015 04:30:57 -0800
Message-ID: <1449059468-87025-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30731 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814AbbLBMbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 07:31:13 -0500
In-Reply-To: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index dbbd1be..18f1c22 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -59,7 +59,7 @@ static const char ixgbevf_driver_string[] =
 #define DRV_VERSION "2.12.1-k"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
-	"Copyright (c) 2009 - 2012 Intel Corporation.";
+	"Copyright (c) 2009 - 2015 Intel Corporation.";
 
 static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
 	[board_82599_vf] = &ixgbevf_82599_vf_info,
@@ -96,12 +96,14 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+static struct workqueue_struct *ixgbevf_wq;
+
 static void ixgbevf_service_event_schedule(struct ixgbevf_adapter *adapter)
 {
 	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
 	    !test_bit(__IXGBEVF_REMOVING, &adapter->state) &&
 	    !test_and_set_bit(__IXGBEVF_SERVICE_SCHED, &adapter->state))
-		schedule_work(&adapter->service_task);
+		queue_work(ixgbevf_wq, &adapter->service_task);
 }
 
 static void ixgbevf_service_event_complete(struct ixgbevf_adapter *adapter)
@@ -4250,6 +4252,11 @@ static int __init ixgbevf_init_module(void)
 		ixgbevf_driver_version);
 
 	pr_info("%s\n", ixgbevf_copyright);
+	ixgbevf_wq = create_singlethread_workqueue(ixgbevf_driver_name);
+	if (!ixgbevf_wq) {
+		pr_err("%s: Failed to create workqueue\n", ixgbevf_driver_name);
+		return -ENOMEM;
+	}
 
 	ret = pci_register_driver(&ixgbevf_driver);
 	return ret;
@@ -4266,6 +4273,10 @@ module_init(ixgbevf_init_module);
 static void __exit ixgbevf_exit_module(void)
 {
 	pci_unregister_driver(&ixgbevf_driver);
+	if (ixgbevf_wq) {
+		destroy_workqueue(ixgbevf_wq);
+		ixgbevf_wq = NULL;
+	}
 }
 
 #ifdef DEBUG
-- 
2.5.0
