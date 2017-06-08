From: <netanel@amazon.com>
Subject: [PATCH net-next 06/13] net: ena: allow the driver to work with small number of msix vectors
Date: Fri, 9 Jun 2017 00:46:43 +0300
Message-ID: <1496958410-4220-17-git-send-email-netanel@amazon.com>
References: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:17600 "EHLO
        smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751753AbdFHVsp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 17:48:45 -0400
In-Reply-To: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Current driver tries to allocate msix vectors as the number of the
negotiated io queues. (with another msix vector for management).
If pci_alloc_irq_vectors() fails, the driver aborts the probe
and the ENA network device is never brought up.

With this patch, the driver's logic will reduce the number of IO
queues to the number of allocated msix vectors (minus one for management)
instead of failing probe().

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 65 ++++++++++++++++++++--------
 drivers/net/ethernet/amazon/ena/ena_netdev.h |  6 ++-
 2 files changed, 51 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index fcbcd18..04aade8 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1269,9 +1269,20 @@ static irqreturn_t ena_intr_msix_io(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+/* Reserve a single MSI-X vector for management (admin + aenq).
+ * plus reserve one vector for each potential io queue.
+ * the number of potential io queues is the minimum of what the device
+ * supports and the number of vCPUs.
+ */
 static int ena_enable_msix(struct ena_adapter *adapter, int num_queues)
 {
-	int msix_vecs, rc;
+	int msix_vecs, irq_cnt;
+
+	if (test_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags)) {
+		netif_err(adapter, probe, adapter->netdev,
+			  "Error, MSI-X is already enabled\n");
+		return -EPERM;
+	}
 
 	/* Reserved the max msix vectors we might need */
 	msix_vecs = ENA_MAX_MSIX_VEC(num_queues);
@@ -1279,25 +1290,28 @@ static int ena_enable_msix(struct ena_adapter *adapter, int num_queues)
 	netif_dbg(adapter, probe, adapter->netdev,
 		  "trying to enable MSI-X, vectors %d\n", msix_vecs);
 
-	rc = pci_alloc_irq_vectors(adapter->pdev, msix_vecs, msix_vecs,
-			PCI_IRQ_MSIX);
-	if (rc < 0) {
+	irq_cnt = pci_alloc_irq_vectors(adapter->pdev, ENA_MIN_MSIX_VEC,
+					msix_vecs, PCI_IRQ_MSIX);
+
+	if (irq_cnt < 0) {
 		netif_err(adapter, probe, adapter->netdev,
-			  "Failed to enable MSI-X, vectors %d rc %d\n",
-			  msix_vecs, rc);
+			  "Failed to enable MSI-X. irq_cnt %d\n", irq_cnt);
 		return -ENOSPC;
 	}
 
-	netif_dbg(adapter, probe, adapter->netdev, "enable MSI-X, vectors %d\n",
-		  msix_vecs);
-
-	if (msix_vecs >= 1) {
-		if (ena_init_rx_cpu_rmap(adapter))
-			netif_warn(adapter, probe, adapter->netdev,
-				   "Failed to map IRQs to CPUs\n");
+	if (irq_cnt != msix_vecs) {
+		netif_notice(adapter, probe, adapter->netdev,
+			     "enable only %d MSI-X (out of %d), reduce the number of queues\n",
+			     irq_cnt, msix_vecs);
+		adapter->num_queues = irq_cnt - ENA_ADMIN_MSIX_VEC;
 	}
 
-	adapter->msix_vecs = msix_vecs;
+	if (ena_init_rx_cpu_rmap(adapter))
+		netif_warn(adapter, probe, adapter->netdev,
+			   "Failed to map IRQs to CPUs\n");
+
+	adapter->msix_vecs = irq_cnt;
+	set_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags);
 
 	return 0;
 }
@@ -1374,6 +1388,12 @@ static int ena_request_io_irq(struct ena_adapter *adapter)
 	struct ena_irq *irq;
 	int rc = 0, i, k;
 
+	if (!test_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags)) {
+		netif_err(adapter, ifup, adapter->netdev,
+			  "Failed to request I/O IRQ: MSI-X is not enabled\n");
+		return -EINVAL;
+	}
+
 	for (i = ENA_IO_IRQ_FIRST_IDX; i < adapter->msix_vecs; i++) {
 		irq = &adapter->irq_tbl[i];
 		rc = request_irq(irq->vector, irq->handler, flags, irq->name,
@@ -1432,6 +1452,12 @@ static void ena_free_io_irq(struct ena_adapter *adapter)
 	}
 }
 
+static void ena_disable_msix(struct ena_adapter *adapter)
+{
+	if (test_and_clear_bit(ENA_FLAG_MSIX_ENABLED, &adapter->flags))
+		pci_free_irq_vectors(adapter->pdev);
+}
+
 static void ena_disable_io_intr_sync(struct ena_adapter *adapter)
 {
 	int i;
@@ -2520,7 +2546,8 @@ static int ena_enable_msix_and_set_admin_interrupts(struct ena_adapter *adapter,
 	return 0;
 
 err_disable_msix:
-	pci_free_irq_vectors(adapter->pdev);
+	ena_disable_msix(adapter);
+
 	return rc;
 }
 
@@ -2558,7 +2585,7 @@ static void ena_fw_reset_device(struct work_struct *work)
 
 	ena_free_mgmnt_irq(adapter);
 
-	pci_free_irq_vectors(adapter->pdev);
+	ena_disable_msix(adapter);
 
 	ena_com_abort_admin_commands(ena_dev);
 
@@ -2610,7 +2637,7 @@ static void ena_fw_reset_device(struct work_struct *work)
 	return;
 err_disable_msix:
 	ena_free_mgmnt_irq(adapter);
-	pci_free_irq_vectors(adapter->pdev);
+	ena_disable_msix(adapter);
 err_device_destroy:
 	ena_com_admin_destroy(ena_dev);
 err:
@@ -3269,7 +3296,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_free_msix:
 	ena_com_dev_reset(ena_dev, ENA_REGS_RESET_INIT_ERR);
 	ena_free_mgmnt_irq(adapter);
-	pci_free_irq_vectors(adapter->pdev);
+	ena_disable_msix(adapter);
 err_worker_destroy:
 	ena_com_destroy_interrupt_moderation(ena_dev);
 	del_timer(&adapter->timer_service);
@@ -3354,7 +3381,7 @@ static void ena_remove(struct pci_dev *pdev)
 
 	ena_free_mgmnt_irq(adapter);
 
-	pci_free_irq_vectors(adapter->pdev);
+	ena_disable_msix(adapter);
 
 	free_netdev(netdev);
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index c6b17ce..4518a9d 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -58,7 +58,10 @@
 #define DEVICE_NAME	"Elastic Network Adapter (ENA)"
 
 /* 1 for AENQ + ADMIN */
-#define ENA_MAX_MSIX_VEC(io_queues)	(1 + (io_queues))
+#define ENA_ADMIN_MSIX_VEC		1
+#define ENA_MAX_MSIX_VEC(io_queues)	(ENA_ADMIN_MSIX_VEC + (io_queues))
+
+#define ENA_MIN_MSIX_VEC		2
 
 #define ENA_REG_BAR			0
 #define ENA_MEM_BAR			2
@@ -267,6 +270,7 @@ enum ena_flags_t {
 	ENA_FLAG_DEVICE_RUNNING,
 	ENA_FLAG_DEV_UP,
 	ENA_FLAG_LINK_UP,
+	ENA_FLAG_MSIX_ENABLED,
 	ENA_FLAG_TRIGGER_RESET
 };
 
-- 
2.7.4
