From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] cxgb4: fix BUG() on interrupt deallocating path of ULD
Date: Mon, 10 Jul 2017 10:55:46 -0300
Message-ID: <20170710135546.350-1-gpiccoli@linux.vnet.ibm.com>
Cc: atul.gupta@chelsio.com, ganeshgr@chelsio.com, swise@chelsio.com,
        gpiccoli@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38652 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932108AbdGJNzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 09:55:53 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6ADroGc098528
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 09:55:52 -0400
Received: from e24smtp03.br.ibm.com (e24smtp03.br.ibm.com [32.104.18.24])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2bma5pj4ku-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 09:55:52 -0400
Received: from localhost
        by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Mon, 10 Jul 2017 10:55:50 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
        by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6ADtn7l14155904
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 10:55:49 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
        by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6ADtnHl029120
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 10:55:49 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the introduction of ULD (Upper-Layer Drivers), the MSI-X
deallocating path changed in cxgb4: the driver frees the interrupts
of ULD when unregistering it or on shutdown PCI handler.

Problem is that if a MSI-X is not freed before deallocated in the PCI
layer, it will trigger a BUG() due to still "alive" interrupt being
tentatively quiesced.

The below trace was observed when doing a simple unbind of Chelsio's
adapter PCI function, like:
  "echo 001e:80:00.4 > /sys/bus/pci/drivers/cxgb4/unbind"

Trace:

  kernel BUG at drivers/pci/msi.c:352!
  Oops: Exception in kernel mode, sig: 5 [#1]
  ...
  NIP [c0000000005a5e60] free_msi_irqs+0xa0/0x250
  LR [c0000000005a5e50] free_msi_irqs+0x90/0x250
  Call Trace:
  [c0000000005a5e50] free_msi_irqs+0x90/0x250 (unreliable)
  [c0000000005a72c4] pci_disable_msix+0x124/0x180
  [d000000011e06708] disable_msi+0x88/0xb0 [cxgb4]
  [d000000011e06948] free_some_resources+0xa8/0x160 [cxgb4]
  [d000000011e06d60] remove_one+0x170/0x3c0 [cxgb4]
  [c00000000058a910] pci_device_remove+0x70/0x110
  [c00000000064ef04] device_release_driver_internal+0x1f4/0x2c0
  ...

This patch fixes the issue by refactoring the shutdown path of ULD on
cxgb4 driver, by properly freeing and disabling interrupts on PCI
remove handler too.

Fixes: 0fbc81b3ad51 ("Allocate resources dynamically for all cxgb4 ULD's")
Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---

It might be important to add this patch to stable too if possible, v4.9+ .

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 16 +++++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c  | 42 +++++++++++++++----------
 2 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 86f92e31e8aa..e403fa18f1b1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2083,12 +2083,12 @@ static void detach_ulds(struct adapter *adap)
 
 	mutex_lock(&uld_mutex);
 	list_del(&adap->list_node);
+
 	for (i = 0; i < CXGB4_ULD_MAX; i++)
-		if (adap->uld && adap->uld[i].handle) {
+		if (adap->uld && adap->uld[i].handle)
 			adap->uld[i].state_change(adap->uld[i].handle,
 					     CXGB4_STATE_DETACH);
-			adap->uld[i].handle = NULL;
-		}
+
 	if (netevent_registered && list_empty(&adapter_list)) {
 		unregister_netevent_notifier(&cxgb4_netevent_nb);
 		netevent_registered = false;
@@ -5303,8 +5303,10 @@ static void remove_one(struct pci_dev *pdev)
 		 */
 		destroy_workqueue(adapter->workq);
 
-		if (is_uld(adapter))
+		if (is_uld(adapter)) {
 			detach_ulds(adapter);
+			t4_uld_clean_up(adapter);
+		}
 
 		disable_interrupts(adapter);
 
@@ -5385,7 +5387,11 @@ static void shutdown_one(struct pci_dev *pdev)
 			if (adapter->port[i]->reg_state == NETREG_REGISTERED)
 				cxgb_close(adapter->port[i]);
 
-		t4_uld_clean_up(adapter);
+		if (is_uld(adapter)) {
+			detach_ulds(adapter);
+			t4_uld_clean_up(adapter);
+		}
+
 		disable_interrupts(adapter);
 		disable_msi(adapter);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index ec53fe9dec68..71a315bc1409 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -589,22 +589,37 @@ void t4_uld_mem_free(struct adapter *adap)
 	kfree(adap->uld);
 }
 
+/* This function should be called with uld_mutex taken. */
+static void cxgb4_shutdown_uld_adapter(struct adapter *adap, enum cxgb4_uld type)
+{
+	if (adap->uld[type].handle) {
+		adap->uld[type].handle = NULL;
+		adap->uld[type].add = NULL;
+		release_sge_txq_uld(adap, type);
+
+		if (adap->flags & FULL_INIT_DONE)
+			quiesce_rx_uld(adap, type);
+
+		if (adap->flags & USING_MSIX)
+			free_msix_queue_irqs_uld(adap, type);
+
+		free_sge_queues_uld(adap, type);
+		free_queues_uld(adap, type);
+	}
+}
+
 void t4_uld_clean_up(struct adapter *adap)
 {
 	unsigned int i;
 
-	if (!adap->uld)
-		return;
+	mutex_lock(&uld_mutex);
 	for (i = 0; i < CXGB4_ULD_MAX; i++) {
 		if (!adap->uld[i].handle)
 			continue;
-		if (adap->flags & FULL_INIT_DONE)
-			quiesce_rx_uld(adap, i);
-		if (adap->flags & USING_MSIX)
-			free_msix_queue_irqs_uld(adap, i);
-		free_sge_queues_uld(adap, i);
-		free_queues_uld(adap, i);
+
+		cxgb4_shutdown_uld_adapter(adap, i);
 	}
+	mutex_unlock(&uld_mutex);
 }
 
 static void uld_init(struct adapter *adap, struct cxgb4_lld_info *lld)
@@ -783,15 +798,8 @@ int cxgb4_unregister_uld(enum cxgb4_uld type)
 			continue;
 		if (type == CXGB4_ULD_ISCSIT && is_t4(adap->params.chip))
 			continue;
-		adap->uld[type].handle = NULL;
-		adap->uld[type].add = NULL;
-		release_sge_txq_uld(adap, type);
-		if (adap->flags & FULL_INIT_DONE)
-			quiesce_rx_uld(adap, type);
-		if (adap->flags & USING_MSIX)
-			free_msix_queue_irqs_uld(adap, type);
-		free_sge_queues_uld(adap, type);
-		free_queues_uld(adap, type);
+
+		cxgb4_shutdown_uld_adapter(adap, type);
 	}
 	mutex_unlock(&uld_mutex);
 
-- 
2.13.0
