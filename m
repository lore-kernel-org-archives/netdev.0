From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 19/25] fm10k: start service timer on probe
Date: Tue, 14 Apr 2015 16:51:05 -0700
Message-ID: <1429055471-401-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200AbbDNXv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:26 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the service task handles varying work that doesn't all require the
interface to be up, launch the service timer immediately. This ensures
that we continually check the mailbox, as well as handle other tasks
while the device is down.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 32e99eb..df9fda3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1511,7 +1511,7 @@ void fm10k_up(struct fm10k_intfc *interface)
 	/* enable transmits */
 	netif_tx_start_all_queues(interface->netdev);
 
-	/* kick off the service timer */
+	/* kick off the service timer now */
 	hw->mac.get_host_state = 1;
 	mod_timer(&interface->service_timer, jiffies);
 }
@@ -1551,8 +1551,6 @@ void fm10k_down(struct fm10k_intfc *interface)
 	/* disable polling routines */
 	fm10k_napi_disable_all(interface);
 
-	del_timer_sync(&interface->service_timer);
-
 	/* capture stats one last time before stopping interface */
 	fm10k_update_stats(interface);
 
@@ -1678,6 +1676,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		    (unsigned long)interface);
 	INIT_WORK(&interface->service_task, fm10k_service_task);
 
+	/* kick off service timer now, even when interface is down */
+	mod_timer(&interface->service_timer, (HZ * 2) + jiffies);
+
 	/* Intitialize timestamp data */
 	fm10k_ts_init(interface);
 
@@ -1894,6 +1895,8 @@ static void fm10k_remove(struct pci_dev *pdev)
 	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
 	struct net_device *netdev = interface->netdev;
 
+	del_timer_sync(&interface->service_timer);
+
 	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
 	cancel_work_sync(&interface->service_task);
 
-- 
1.9.3
