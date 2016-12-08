From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 5/5] liquidio VF error handling
Date: Thu, 8 Dec 2016 13:00:48 -0800
Message-ID: <1481230848-2393-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0072.outbound.protection.outlook.com ([104.47.42.72]:2178
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753427AbcLHVBY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:01:24 -0500
In-Reply-To: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF error handling.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 139 +++++++++++++++++++++
 1 file changed, 139 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index dc0e1f6..70d96c1 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -175,6 +175,144 @@ static int wait_for_pending_requests(struct octeon_device *oct)
 	return 0;
 }
 
+/**
+ * \brief Cause device to go quiet so it can be safely removed/reset/etc
+ * @param oct Pointer to Octeon device
+ */
+static void pcierror_quiesce_device(struct octeon_device *oct)
+{
+	int i;
+
+	/* Disable the input and output queues now. No more packets will
+	 * arrive from Octeon, but we should wait for all packet processing
+	 * to finish.
+	 */
+
+	/* To allow for in-flight requests */
+	schedule_timeout_uninterruptible(100);
+
+	if (wait_for_pending_requests(oct))
+		dev_err(&oct->pci_dev->dev, "There were pending requests\n");
+
+	/* Force all requests waiting to be fetched by OCTEON to complete. */
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+		struct octeon_instr_queue *iq;
+
+		if (!(oct->io_qmask.iq & BIT_ULL(i)))
+			continue;
+		iq = oct->instr_queue[i];
+
+		if (atomic_read(&iq->instr_pending)) {
+			spin_lock_bh(&iq->lock);
+			iq->fill_cnt = 0;
+			iq->octeon_read_index = iq->host_write_index;
+			iq->stats.instr_processed +=
+			    atomic_read(&iq->instr_pending);
+			lio_process_iq_request_list(oct, iq, 0);
+			spin_unlock_bh(&iq->lock);
+		}
+	}
+
+	/* Force all pending ordered list requests to time out. */
+	lio_process_ordered_list(oct, 1);
+
+	/* We do not need to wait for output queue packets to be processed. */
+}
+
+/**
+ * \brief Cleanup PCI AER uncorrectable error status
+ * @param dev Pointer to PCI device
+ */
+static void cleanup_aer_uncorrect_error_status(struct pci_dev *dev)
+{
+	u32 status, mask;
+	int pos = 0x100;
+
+	pr_info("%s :\n", __func__);
+
+	pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, &status);
+	pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_SEVER, &mask);
+	if (dev->error_state == pci_channel_io_normal)
+		status &= ~mask; /* Clear corresponding nonfatal bits */
+	else
+		status &= mask; /* Clear corresponding fatal bits */
+	pci_write_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, status);
+}
+
+/**
+ * \brief Stop all PCI IO to a given device
+ * @param dev Pointer to Octeon device
+ */
+static void stop_pci_io(struct octeon_device *oct)
+{
+	struct msix_entry *msix_entries;
+	int i;
+
+	/* No more instructions will be forwarded. */
+	atomic_set(&oct->status, OCT_DEV_IN_RESET);
+
+	for (i = 0; i < oct->ifcount; i++)
+		netif_device_detach(oct->props[i].netdev);
+
+	/* Disable interrupts  */
+	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
+
+	pcierror_quiesce_device(oct);
+	if (oct->msix_on) {
+		msix_entries = (struct msix_entry *)oct->msix_entries;
+		for (i = 0; i < oct->num_msix_irqs; i++) {
+			/* clear the affinity_cpumask */
+			irq_set_affinity_hint(msix_entries[i].vector,
+					      NULL);
+			free_irq(msix_entries[i].vector,
+				 &oct->ioq_vector[i]);
+		}
+		pci_disable_msix(oct->pci_dev);
+		kfree(oct->msix_entries);
+		oct->msix_entries = NULL;
+		octeon_free_ioq_vector(oct);
+	}
+	dev_dbg(&oct->pci_dev->dev, "Device state is now %s\n",
+		lio_get_state_string(&oct->status));
+
+	/* making it a common function for all OCTEON models */
+	cleanup_aer_uncorrect_error_status(oct->pci_dev);
+
+	pci_disable_device(oct->pci_dev);
+}
+
+/**
+ * \brief called when PCI error is detected
+ * @param pdev Pointer to PCI device
+ * @param state The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t liquidio_pcie_error_detected(struct pci_dev *pdev,
+						     pci_channel_state_t state)
+{
+	struct octeon_device *oct = pci_get_drvdata(pdev);
+
+	/* Non-correctable Non-fatal errors */
+	if (state == pci_channel_io_normal) {
+		dev_err(&oct->pci_dev->dev, "Non-correctable non-fatal error reported:\n");
+		cleanup_aer_uncorrect_error_status(oct->pci_dev);
+		return PCI_ERS_RESULT_CAN_RECOVER;
+	}
+
+	/* Non-correctable Fatal errors */
+	dev_err(&oct->pci_dev->dev, "Non-correctable FATAL reported by PCI AER driver\n");
+	stop_pci_io(oct);
+
+	return PCI_ERS_RESULT_DISCONNECT;
+}
+
+/* For PCI-E Advanced Error Recovery (AER) Interface */
+static const struct pci_error_handlers liquidio_vf_err_handler = {
+	.error_detected = liquidio_pcie_error_detected,
+};
+
 static const struct pci_device_id liquidio_vf_pci_tbl[] = {
 	{
 		PCI_VENDOR_ID_CAVIUM, OCTEON_CN23XX_VF_VID,
@@ -191,6 +329,7 @@ static int wait_for_pending_requests(struct octeon_device *oct)
 	.id_table	= liquidio_vf_pci_tbl,
 	.probe		= liquidio_vf_probe,
 	.remove		= liquidio_vf_remove,
+	.err_handler	= &liquidio_vf_err_handler,    /* For AER */
 };
 
 /**
-- 
1.8.3.1
