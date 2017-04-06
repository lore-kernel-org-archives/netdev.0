From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/4] net/ena: switch to pci_alloc_irq_vectors
Date: Thu,  6 Apr 2017 14:24:46 +0200
Message-ID: <20170406122448.31854-3-hch@lst.de>
References: <20170406122448.31854-1-hch@lst.de>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: bhelgaas@google.com, davem@davemloft.net,
        netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:57863 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934662AbdDFMZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:25:07 -0400
In-Reply-To: <20170406122448.31854-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the deprecated pci_enable_msix API in favour of it's successor.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 55 ++++++----------------------
 drivers/net/ethernet/amazon/ena/ena_netdev.h |  2 -
 2 files changed, 12 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 35f19430c84a..7c1214d78855 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -133,7 +133,7 @@ static int ena_init_rx_cpu_rmap(struct ena_adapter *adapter)
 		int irq_idx = ENA_IO_IRQ_IDX(i);
 
 		rc = irq_cpu_rmap_add(adapter->netdev->rx_cpu_rmap,
-				      adapter->msix_entries[irq_idx].vector);
+				      pci_irq_vector(adapter->pdev, irq_idx));
 		if (rc) {
 			free_irq_cpu_rmap(adapter->netdev->rx_cpu_rmap);
 			adapter->netdev->rx_cpu_rmap = NULL;
@@ -1208,13 +1208,7 @@ static irqreturn_t ena_intr_msix_io(int irq, void *data)
 
 static int ena_enable_msix(struct ena_adapter *adapter, int num_queues)
 {
-	int i, msix_vecs, rc;
-
-	if (test_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags)) {
-		netif_err(adapter, probe, adapter->netdev,
-			  "Error, MSI-X is already enabled\n");
-		return -EPERM;
-	}
+	int msix_vecs, rc;
 
 	/* Reserved the max msix vectors we might need */
 	msix_vecs = ENA_MAX_MSIX_VEC(num_queues);
@@ -1222,16 +1216,9 @@ static int ena_enable_msix(struct ena_adapter *adapter, int num_queues)
 	netif_dbg(adapter, probe, adapter->netdev,
 		  "trying to enable MSI-X, vectors %d\n", msix_vecs);
 
-	adapter->msix_entries = vzalloc(msix_vecs * sizeof(struct msix_entry));
-
-	if (!adapter->msix_entries)
-		return -ENOMEM;
-
-	for (i = 0; i < msix_vecs; i++)
-		adapter->msix_entries[i].entry = i;
-
-	rc = pci_enable_msix(adapter->pdev, adapter->msix_entries, msix_vecs);
-	if (rc != 0) {
+	rc = pci_alloc_irq_vectors(adapter->pdev, msix_vecs, msix_vecs,
+			PCI_IRQ_MSIX);
+	if (rc < 0) {
 		netif_err(adapter, probe, adapter->netdev,
 			  "Failed to enable MSI-X, vectors %d rc %d\n",
 			  msix_vecs, rc);
@@ -1248,7 +1235,6 @@ static int ena_enable_msix(struct ena_adapter *adapter, int num_queues)
 	}
 
 	adapter->msix_vecs = msix_vecs;
-	set_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags);
 
 	return 0;
 }
@@ -1264,7 +1250,7 @@ static void ena_setup_mgmnt_intr(struct ena_adapter *adapter)
 		ena_intr_msix_mgmnt;
 	adapter->irq_tbl[ENA_MGMNT_IRQ_IDX].data = adapter;
 	adapter->irq_tbl[ENA_MGMNT_IRQ_IDX].vector =
-		adapter->msix_entries[ENA_MGMNT_IRQ_IDX].vector;
+		pci_irq_vector(adapter->pdev, ENA_MGMNT_IRQ_IDX);
 	cpu = cpumask_first(cpu_online_mask);
 	adapter->irq_tbl[ENA_MGMNT_IRQ_IDX].cpu = cpu;
 	cpumask_set_cpu(cpu,
@@ -1287,7 +1273,7 @@ static void ena_setup_io_intr(struct ena_adapter *adapter)
 		adapter->irq_tbl[irq_idx].handler = ena_intr_msix_io;
 		adapter->irq_tbl[irq_idx].data = &adapter->ena_napi[i];
 		adapter->irq_tbl[irq_idx].vector =
-			adapter->msix_entries[irq_idx].vector;
+			pci_irq_vector(adapter->pdev, irq_idx);
 		adapter->irq_tbl[irq_idx].cpu = cpu;
 
 		cpumask_set_cpu(cpu,
@@ -1325,12 +1311,6 @@ static int ena_request_io_irq(struct ena_adapter *adapter)
 	struct ena_irq *irq;
 	int rc = 0, i, k;
 
-	if (!test_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags)) {
-		netif_err(adapter, ifup, adapter->netdev,
-			  "Failed to request I/O IRQ: MSI-X is not enabled\n");
-		return -EINVAL;
-	}
-
 	for (i = ENA_IO_IRQ_FIRST_IDX; i < adapter->msix_vecs; i++) {
 		irq = &adapter->irq_tbl[i];
 		rc = request_irq(irq->vector, irq->handler, flags, irq->name,
@@ -1389,16 +1369,6 @@ static void ena_free_io_irq(struct ena_adapter *adapter)
 	}
 }
 
-static void ena_disable_msix(struct ena_adapter *adapter)
-{
-	if (test_and_clear_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags))
-		pci_disable_msix(adapter->pdev);
-
-	if (adapter->msix_entries)
-		vfree(adapter->msix_entries);
-	adapter->msix_entries = NULL;
-}
-
 static void ena_disable_io_intr_sync(struct ena_adapter *adapter)
 {
 	int i;
@@ -2479,8 +2449,7 @@ static int ena_enable_msix_and_set_admin_interrupts(struct ena_adapter *adapter,
 	return 0;
 
 err_disable_msix:
-	ena_disable_msix(adapter);
-
+	pci_free_irq_vectors(adapter->pdev);
 	return rc;
 }
 
@@ -2518,7 +2487,7 @@ static void ena_fw_reset_device(struct work_struct *work)
 
 	ena_free_mgmnt_irq(adapter);
 
-	ena_disable_msix(adapter);
+	pci_free_irq_vectors(adapter->pdev);
 
 	ena_com_abort_admin_commands(ena_dev);
 
@@ -2569,7 +2538,7 @@ static void ena_fw_reset_device(struct work_struct *work)
 	return;
 err_disable_msix:
 	ena_free_mgmnt_irq(adapter);
-	ena_disable_msix(adapter);
+	pci_free_irq_vectors(adapter->pdev);
 err_device_destroy:
 	ena_com_admin_destroy(ena_dev);
 err:
@@ -3103,7 +3072,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_free_msix:
 	ena_com_dev_reset(ena_dev);
 	ena_free_mgmnt_irq(adapter);
-	ena_disable_msix(adapter);
+	pci_free_irq_vectors(adapter->pdev);
 err_worker_destroy:
 	ena_com_destroy_interrupt_moderation(ena_dev);
 	del_timer(&adapter->timer_service);
@@ -3188,7 +3157,7 @@ static void ena_remove(struct pci_dev *pdev)
 
 	ena_free_mgmnt_irq(adapter);
 
-	ena_disable_msix(adapter);
+	pci_free_irq_vectors(adapter->pdev);
 
 	free_netdev(netdev);
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index ed62d8e231a1..0e22bce6239d 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -248,7 +248,6 @@ enum ena_flags_t {
 	ENA_FLAG_DEVICE_RUNNING,
 	ENA_FLAG_DEV_UP,
 	ENA_FLAG_LINK_UP,
-	ENA_FLAG_MSIX_ENABLED,
 	ENA_FLAG_TRIGGER_RESET
 };
 
@@ -267,7 +266,6 @@ struct ena_adapter {
 
 	int num_queues;
 
-	struct msix_entry *msix_entries;
 	int msix_vecs;
 
 	u32 tx_usecs, rx_usecs; /* interrupt moderation */
-- 
2.11.0
