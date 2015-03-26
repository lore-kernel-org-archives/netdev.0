From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 2/2] cxgb4: Disable interrupts and napi before unregistering netdev
Date: Thu, 26 Mar 2015 10:04:26 +0530
Message-ID: <1427344466-17658-3-git-send-email-hariprasad@chelsio.com>
References: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9289 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750926AbbCZE2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 00:28:52 -0400
In-Reply-To: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable interrupts and quiesce rx before unregistering net device to avoid crash
while unloading driver when traffic is flowing through.

Based on original work by Shameem Khalid <shameem@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   25 ++++++++++++++++------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b9b5a7b..826de7a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -934,6 +934,21 @@ static void quiesce_rx(struct adapter *adap)
 	}
 }
 
+/* Disable interrupt and napi handler */
+static void disable_interrupts(struct adapter *adap)
+{
+	if (adap->flags & FULL_INIT_DONE) {
+		t4_intr_disable(adap);
+		if (adap->flags & USING_MSIX) {
+			free_msix_queue_irqs(adap);
+			free_irq(adap->msix_info[0].vec, adap);
+		} else {
+			free_irq(adap->pdev->irq, adap);
+		}
+		quiesce_rx(adap);
+	}
+}
+
 /*
  * Enable NAPI scheduling and interrupt generation for all Rx queues.
  */
@@ -4257,19 +4272,12 @@ static int cxgb_up(struct adapter *adap)
 
 static void cxgb_down(struct adapter *adapter)
 {
-	t4_intr_disable(adapter);
 	cancel_work_sync(&adapter->tid_release_task);
 	cancel_work_sync(&adapter->db_full_task);
 	cancel_work_sync(&adapter->db_drop_task);
 	adapter->tid_release_task_busy = false;
 	adapter->tid_release_head = NULL;
 
-	if (adapter->flags & USING_MSIX) {
-		free_msix_queue_irqs(adapter);
-		free_irq(adapter->msix_info[0].vec, adapter);
-	} else
-		free_irq(adapter->pdev->irq, adapter);
-	quiesce_rx(adapter);
 	t4_sge_stop(adapter);
 	t4_free_sge_resources(adapter);
 	adapter->flags &= ~FULL_INIT_DONE;
@@ -5591,6 +5599,7 @@ static pci_ers_result_t eeh_err_detected(struct pci_dev *pdev,
 		netif_carrier_off(dev);
 	}
 	spin_unlock(&adap->stats_lock);
+	disable_interrupts(adap);
 	if (adap->flags & FULL_INIT_DONE)
 		cxgb_down(adap);
 	rtnl_unlock();
@@ -6304,6 +6313,8 @@ static void remove_one(struct pci_dev *pdev)
 		if (is_offload(adapter))
 			detach_ulds(adapter);
 
+		disable_interrupts(adapter);
+
 		for_each_port(adapter, i)
 			if (adapter->port[i]->reg_state == NETREG_REGISTERED)
 				unregister_netdev(adapter->port[i]);
-- 
1.7.1
