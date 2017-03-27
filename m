From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/5] net: thunderx: switch to pci_alloc_irq_vectors
Date: Mon, 27 Mar 2017 10:29:32 +0200
Message-ID: <20170327082936.6830-2-hch@lst.de>
References: <20170327082936.6830-1-hch@lst.de>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: bhelgaas@google.com, davem@davemloft.net,
        netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:45781 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752088AbdC0JEG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:04:06 -0400
In-Reply-To: <20170327082936.6830-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the deprecated pci_enable_msix API in favour of it's successor.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 75 ++++++--------------------
 1 file changed, 15 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 767234e2e8f9..205569db9093 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -65,10 +65,7 @@ struct nicpf {
 	bool			mbx_lock[MAX_NUM_VFS_SUPPORTED];
 
 	/* MSI-X */
-	bool			msix_enabled;
 	u8			num_vec;
-	struct msix_entry	*msix_entries;
-	bool			irq_allocated[NIC_PF_MSIX_VECTORS];
 	char			irq_name[NIC_PF_MSIX_VECTORS][20];
 };
 
@@ -1088,7 +1085,7 @@ static irqreturn_t nic_mbx_intr_handler(int irq, void *nic_irq)
 	u64 intr;
 	u8  vf, vf_per_mbx_reg = 64;
 
-	if (irq == nic->msix_entries[NIC_PF_INTR_ID_MBOX0].vector)
+	if (irq == pci_irq_vector(nic->pdev, NIC_PF_INTR_ID_MBOX0))
 		mbx = 0;
 	else
 		mbx = 1;
@@ -1107,76 +1104,30 @@ static irqreturn_t nic_mbx_intr_handler(int irq, void *nic_irq)
 	return IRQ_HANDLED;
 }
 
-static int nic_enable_msix(struct nicpf *nic)
+static int nic_register_interrupts(struct nicpf *nic)
 {
 	int i, ret;
 
-	nic->num_vec = pci_msix_vec_count(nic->pdev);
-
-	nic->msix_entries = kmalloc_array(nic->num_vec,
-					  sizeof(struct msix_entry),
-					  GFP_KERNEL);
-	if (!nic->msix_entries)
-		return -ENOMEM;
-
-	for (i = 0; i < nic->num_vec; i++)
-		nic->msix_entries[i].entry = i;
-
-	ret = pci_enable_msix(nic->pdev, nic->msix_entries, nic->num_vec);
-	if (ret) {
+	/* Enable MSI-X */
+	ret = pci_alloc_irq_vectors(nic->pdev, nic->num_vec, nic->num_vec,
+			PCI_IRQ_MSIX);
+	if (ret < 0) {
 		dev_err(&nic->pdev->dev,
 			"Request for #%d msix vectors failed, returned %d\n",
 			   nic->num_vec, ret);
-		kfree(nic->msix_entries);
 		return ret;
 	}
 
-	nic->msix_enabled = 1;
-	return 0;
-}
-
-static void nic_disable_msix(struct nicpf *nic)
-{
-	if (nic->msix_enabled) {
-		pci_disable_msix(nic->pdev);
-		kfree(nic->msix_entries);
-		nic->msix_enabled = 0;
-		nic->num_vec = 0;
-	}
-}
-
-static void nic_free_all_interrupts(struct nicpf *nic)
-{
-	int irq;
-
-	for (irq = 0; irq < nic->num_vec; irq++) {
-		if (nic->irq_allocated[irq])
-			free_irq(nic->msix_entries[irq].vector, nic);
-		nic->irq_allocated[irq] = false;
-	}
-}
-
-static int nic_register_interrupts(struct nicpf *nic)
-{
-	int i, ret;
-
-	/* Enable MSI-X */
-	ret = nic_enable_msix(nic);
-	if (ret)
-		return ret;
-
 	/* Register mailbox interrupt handler */
 	for (i = NIC_PF_INTR_ID_MBOX0; i < nic->num_vec; i++) {
 		sprintf(nic->irq_name[i],
 			"NICPF Mbox%d", (i - NIC_PF_INTR_ID_MBOX0));
 
-		ret = request_irq(nic->msix_entries[i].vector,
+		ret = request_irq(pci_irq_vector(nic->pdev, i),
 				  nic_mbx_intr_handler, 0,
 				  nic->irq_name[i], nic);
 		if (ret)
 			goto fail;
-
-		nic->irq_allocated[i] = true;
 	}
 
 	/* Enable mailbox interrupt */
@@ -1185,15 +1136,19 @@ static int nic_register_interrupts(struct nicpf *nic)
 
 fail:
 	dev_err(&nic->pdev->dev, "Request irq failed\n");
-	nic_free_all_interrupts(nic);
-	nic_disable_msix(nic);
+	while (--i >= 0)
+		free_irq(pci_irq_vector(nic->pdev, i), nic);
+	pci_free_irq_vectors(nic->pdev);
 	return ret;
 }
 
 static void nic_unregister_interrupts(struct nicpf *nic)
 {
-	nic_free_all_interrupts(nic);
-	nic_disable_msix(nic);
+	int i;
+
+	for (i = 0; i < nic->num_vec; i++)
+		free_irq(pci_irq_vector(nic->pdev, i), nic);
+	pci_free_irq_vectors(nic->pdev);
 }
 
 static int nic_num_sqs_en(struct nicpf *nic, int vf_en)
-- 
2.11.0
