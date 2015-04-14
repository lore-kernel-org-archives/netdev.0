From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/25] fm10k: use separate workqueue for fm10k driver
Date: Tue, 14 Apr 2015 16:51:01 -0700
Message-ID: <1429055471-401-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbbDNXvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:24 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we run the watchdog periodically, which might take a while and
potentially monopolize the system default workqueue, create our own
separate work queue. This also helps reduce and stabilize latency
between scheduling the work in our interrupt and actually performing
the work. Still use a timer for the regular scheduled interval but
queue the work onto its own work queue.

It seemed overkill to create a single workqueue per interface, so we
just spawn a single work queue for all interfaces upon driver load. For
this reason, use a multi-threaded workqueue with one thread per
processor, rather than single threaded queue.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h      |  3 +++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 12 ++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  |  2 +-
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index b45f797..c8c8c5b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -235,6 +235,9 @@ struct fm10k_vxlan_port {
 	__be16			port;
 };
 
+/* one work queue for entire driver */
+extern struct workqueue_struct *fm10k_workqueue;
+
 struct fm10k_intfc {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 5022a45..1e08832 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -41,6 +41,9 @@ MODULE_DESCRIPTION("Intel(R) Ethernet Switch Host Interface Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+/* single workqueue for entire fm10k driver */
+struct workqueue_struct *fm10k_workqueue = NULL;
+
 /**
  * fm10k_init_module - Driver Registration Routine
  *
@@ -52,6 +55,10 @@ static int __init fm10k_init_module(void)
 	pr_info("%s - version %s\n", fm10k_driver_string, fm10k_driver_version);
 	pr_info("%s\n", fm10k_copyright);
 
+	/* create driver workqueue */
+	if (!fm10k_workqueue)
+		fm10k_workqueue = create_workqueue("fm10k");
+
 	fm10k_dbg_init();
 
 	return fm10k_register_pci_driver();
@@ -69,6 +76,11 @@ static void __exit fm10k_exit_module(void)
 	fm10k_unregister_pci_driver();
 
 	fm10k_dbg_exit();
+
+	/* destroy driver workqueue */
+	flush_workqueue(fm10k_workqueue);
+	destroy_workqueue(fm10k_workqueue);
+	fm10k_workqueue = NULL;
 }
 module_exit(fm10k_exit_module);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 64ea734..514f35c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -94,7 +94,7 @@ void fm10k_service_event_schedule(struct fm10k_intfc *interface)
 {
 	if (!test_bit(__FM10K_SERVICE_DISABLE, &interface->state) &&
 	    !test_and_set_bit(__FM10K_SERVICE_SCHED, &interface->state))
-		schedule_work(&interface->service_task);
+		queue_work(fm10k_workqueue, &interface->service_task);
 }
 
 static void fm10k_service_event_complete(struct fm10k_intfc *interface)
-- 
1.9.3
