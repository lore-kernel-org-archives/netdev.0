From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/5] net: thunderxvf: switch to pci_alloc_irq_vectors
Date: Mon, 27 Mar 2017 10:29:33 +0200
Message-ID: <20170327082936.6830-3-hch@lst.de>
References: <20170327082936.6830-1-hch@lst.de>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: bhelgaas@google.com, davem@davemloft.net,
        netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:36452 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751608AbdC0JDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:03:46 -0400
In-Reply-To: <20170327082936.6830-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the deprecated pci_enable_msix API in favour of it's successor.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/cavium/thunder/nic.h        |  2 -
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 70 ++++++++----------------
 2 files changed, 24 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 2269ff562d95..6fb44218bf55 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -319,9 +319,7 @@ struct nicvf {
 	struct bgx_stats	bgx_stats;
 
 	/* MSI-X  */
-	bool			msix_enabled;
 	u8			num_vec;
-	struct msix_entry	msix_entries[NIC_VF_MSIX_VECTORS];
 	char			irq_name[NIC_VF_MSIX_VECTORS][IFNAMSIZ + 15];
 	bool			irq_allocated[NIC_VF_MSIX_VECTORS];
 	cpumask_var_t		affinity_mask[NIC_VF_MSIX_VECTORS];
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 24017588f531..183782ce9581 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -882,38 +882,9 @@ static irqreturn_t nicvf_qs_err_intr_handler(int irq, void *nicvf_irq)
 	return IRQ_HANDLED;
 }
 
-static int nicvf_enable_msix(struct nicvf *nic)
-{
-	int ret, vec;
-
-	nic->num_vec = NIC_VF_MSIX_VECTORS;
-
-	for (vec = 0; vec < nic->num_vec; vec++)
-		nic->msix_entries[vec].entry = vec;
-
-	ret = pci_enable_msix(nic->pdev, nic->msix_entries, nic->num_vec);
-	if (ret) {
-		netdev_err(nic->netdev,
-			   "Req for #%d msix vectors failed\n", nic->num_vec);
-		return 0;
-	}
-	nic->msix_enabled = 1;
-	return 1;
-}
-
-static void nicvf_disable_msix(struct nicvf *nic)
-{
-	if (nic->msix_enabled) {
-		pci_disable_msix(nic->pdev);
-		nic->msix_enabled = 0;
-		nic->num_vec = 0;
-	}
-}
-
 static void nicvf_set_irq_affinity(struct nicvf *nic)
 {
 	int vec, cpu;
-	int irqnum;
 
 	for (vec = 0; vec < nic->num_vec; vec++) {
 		if (!nic->irq_allocated[vec])
@@ -930,15 +901,14 @@ static void nicvf_set_irq_affinity(struct nicvf *nic)
 
 		cpumask_set_cpu(cpumask_local_spread(cpu, nic->node),
 				nic->affinity_mask[vec]);
-		irqnum = nic->msix_entries[vec].vector;
-		irq_set_affinity_hint(irqnum, nic->affinity_mask[vec]);
+		irq_set_affinity_hint(pci_irq_vector(nic->pdev, vec),
+				      nic->affinity_mask[vec]);
 	}
 }
 
 static int nicvf_register_interrupts(struct nicvf *nic)
 {
 	int irq, ret = 0;
-	int vector;
 
 	for_each_cq_irq(irq)
 		sprintf(nic->irq_name[irq], "%s-rxtx-%d",
@@ -957,8 +927,8 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 
 	/* Register CQ interrupts */
 	for (irq = 0; irq < nic->qs->cq_cnt; irq++) {
-		vector = nic->msix_entries[irq].vector;
-		ret = request_irq(vector, nicvf_intr_handler,
+		ret = request_irq(pci_irq_vector(nic->pdev, irq),
+				  nicvf_intr_handler,
 				  0, nic->irq_name[irq], nic->napi[irq]);
 		if (ret)
 			goto err;
@@ -968,8 +938,8 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 	/* Register RBDR interrupt */
 	for (irq = NICVF_INTR_ID_RBDR;
 	     irq < (NICVF_INTR_ID_RBDR + nic->qs->rbdr_cnt); irq++) {
-		vector = nic->msix_entries[irq].vector;
-		ret = request_irq(vector, nicvf_rbdr_intr_handler,
+		ret = request_irq(pci_irq_vector(nic->pdev, irq),
+				  nicvf_rbdr_intr_handler,
 				  0, nic->irq_name[irq], nic);
 		if (ret)
 			goto err;
@@ -981,7 +951,7 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 		nic->pnicvf->netdev->name,
 		nic->sqs_mode ? (nic->sqs_id + 1) : 0);
 	irq = NICVF_INTR_ID_QS_ERR;
-	ret = request_irq(nic->msix_entries[irq].vector,
+	ret = request_irq(pci_irq_vector(nic->pdev, irq),
 			  nicvf_qs_err_intr_handler,
 			  0, nic->irq_name[irq], nic);
 	if (ret)
@@ -1001,6 +971,7 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 
 static void nicvf_unregister_interrupts(struct nicvf *nic)
 {
+	struct pci_dev *pdev = nic->pdev;
 	int irq;
 
 	/* Free registered interrupts */
@@ -1008,19 +979,20 @@ static void nicvf_unregister_interrupts(struct nicvf *nic)
 		if (!nic->irq_allocated[irq])
 			continue;
 
-		irq_set_affinity_hint(nic->msix_entries[irq].vector, NULL);
+		irq_set_affinity_hint(pci_irq_vector(pdev, irq), NULL);
 		free_cpumask_var(nic->affinity_mask[irq]);
 
 		if (irq < NICVF_INTR_ID_SQ)
-			free_irq(nic->msix_entries[irq].vector, nic->napi[irq]);
+			free_irq(pci_irq_vector(pdev, irq), nic->napi[irq]);
 		else
-			free_irq(nic->msix_entries[irq].vector, nic);
+			free_irq(pci_irq_vector(pdev, irq), nic);
 
 		nic->irq_allocated[irq] = false;
 	}
 
 	/* Disable MSI-X */
-	nicvf_disable_msix(nic);
+	pci_free_irq_vectors(pdev);
+	nic->num_vec = 0;
 }
 
 /* Initialize MSIX vectors and register MISC interrupt.
@@ -1032,16 +1004,22 @@ static int nicvf_register_misc_interrupt(struct nicvf *nic)
 	int irq = NICVF_INTR_ID_MISC;
 
 	/* Return if mailbox interrupt is already registered */
-	if (nic->msix_enabled)
+	if (nic->pdev->msix_enabled)
 		return 0;
 
 	/* Enable MSI-X */
-	if (!nicvf_enable_msix(nic))
+	nic->num_vec = NIC_VF_MSIX_VECTORS;
+	ret = pci_alloc_irq_vectors(nic->pdev, nic->num_vec, nic->num_vec,
+			PCI_IRQ_MSIX);
+	if (ret < 0) {
+		netdev_err(nic->netdev,
+			   "Req for #%d msix vectors failed\n", nic->num_vec);
 		return 1;
+	}
 
 	sprintf(nic->irq_name[irq], "%s Mbox", "NICVF");
 	/* Register Misc interrupt */
-	ret = request_irq(nic->msix_entries[irq].vector,
+	ret = request_irq(pci_irq_vector(nic->pdev, irq),
 			  nicvf_misc_intr_handler, 0, nic->irq_name[irq], nic);
 
 	if (ret)
@@ -1164,7 +1142,7 @@ int nicvf_stop(struct net_device *netdev)
 
 	/* Wait for pending IRQ handlers to finish */
 	for (irq = 0; irq < nic->num_vec; irq++)
-		synchronize_irq(nic->msix_entries[irq].vector);
+		synchronize_irq(pci_irq_vector(nic->pdev, irq));
 
 	tasklet_kill(&nic->rbdr_task);
 	tasklet_kill(&nic->qs_err_task);
@@ -1365,7 +1343,7 @@ static int nicvf_set_mac_address(struct net_device *netdev, void *p)
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
-	if (nic->msix_enabled) {
+	if (nic->pdev->msix_enabled) {
 		if (nicvf_hw_set_mac_addr(nic, netdev))
 			return -EBUSY;
 	} else {
-- 
2.11.0
