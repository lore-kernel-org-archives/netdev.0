From: dev.srinivasulu@gmail.com
Subject: [PATCH] net: thunderx: Switch to pci_alloc_irq_vectors
Date: Tue,  4 Apr 2017 14:59:06 +0530
Message-ID: <1491298146-13609-1-git-send-email-tsrinivasulu@cavium.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sgoutham@cavium.com, tsrinivasulu@cavium.com, hch@lst.de
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>

Remove deprecated pci_enable_msix API in favour of it's
successor pci_alloc_irq_vectors.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h        |    2 -
 drivers/net/ethernet/cavium/thunder/nic_main.c   |   64 +++++---------------
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |   70 ++++++++--------------
 3 files changed, 40 insertions(+), 96 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 2269ff5..6fb4421 100644
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
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 767234e..fb770b0 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -65,9 +65,7 @@ struct nicpf {
 	bool			mbx_lock[MAX_NUM_VFS_SUPPORTED];
 
 	/* MSI-X */
-	bool			msix_enabled;
 	u8			num_vec;
-	struct msix_entry	*msix_entries;
 	bool			irq_allocated[NIC_PF_MSIX_VECTORS];
 	char			irq_name[NIC_PF_MSIX_VECTORS][20];
 };
@@ -1088,7 +1086,7 @@ static irqreturn_t nic_mbx_intr_handler(int irq, void *nic_irq)
 	u64 intr;
 	u8  vf, vf_per_mbx_reg = 64;
 
-	if (irq == nic->msix_entries[NIC_PF_INTR_ID_MBOX0].vector)
+	if (irq == pci_irq_vector(nic->pdev, NIC_PF_INTR_ID_MBOX0))
 		mbx = 0;
 	else
 		mbx = 1;
@@ -1107,51 +1105,13 @@ static irqreturn_t nic_mbx_intr_handler(int irq, void *nic_irq)
 	return IRQ_HANDLED;
 }
 
-static int nic_enable_msix(struct nicpf *nic)
-{
-	int i, ret;
-
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
-		dev_err(&nic->pdev->dev,
-			"Request for #%d msix vectors failed, returned %d\n",
-			   nic->num_vec, ret);
-		kfree(nic->msix_entries);
-		return ret;
-	}
-
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
 static void nic_free_all_interrupts(struct nicpf *nic)
 {
 	int irq;
 
 	for (irq = 0; irq < nic->num_vec; irq++) {
 		if (nic->irq_allocated[irq])
-			free_irq(nic->msix_entries[irq].vector, nic);
+			free_irq(pci_irq_vector(nic->pdev, irq), nic);
 		nic->irq_allocated[irq] = false;
 	}
 }
@@ -1159,18 +1119,24 @@ static void nic_free_all_interrupts(struct nicpf *nic)
 static int nic_register_interrupts(struct nicpf *nic)
 {
 	int i, ret;
+	nic->num_vec = pci_msix_vec_count(nic->pdev);
 
 	/* Enable MSI-X */
-	ret = nic_enable_msix(nic);
-	if (ret)
-		return ret;
+	ret = pci_alloc_irq_vectors(nic->pdev, nic->num_vec, nic->num_vec,
+				    PCI_IRQ_MSIX);
+	if (ret < 0) {
+		dev_err(&nic->pdev->dev,
+			"Request for #%d msix vectors failed, returned %d\n",
+			   nic->num_vec, ret);
+		return 1;
+	}
 
 	/* Register mailbox interrupt handler */
 	for (i = NIC_PF_INTR_ID_MBOX0; i < nic->num_vec; i++) {
 		sprintf(nic->irq_name[i],
 			"NICPF Mbox%d", (i - NIC_PF_INTR_ID_MBOX0));
 
-		ret = request_irq(nic->msix_entries[i].vector,
+		ret = request_irq(pci_irq_vector(nic->pdev, i),
 				  nic_mbx_intr_handler, 0,
 				  nic->irq_name[i], nic);
 		if (ret)
@@ -1186,14 +1152,16 @@ static int nic_register_interrupts(struct nicpf *nic)
 fail:
 	dev_err(&nic->pdev->dev, "Request irq failed\n");
 	nic_free_all_interrupts(nic);
-	nic_disable_msix(nic);
+	pci_free_irq_vectors(nic->pdev);
+	nic->num_vec = 0;
 	return ret;
 }
 
 static void nic_unregister_interrupts(struct nicpf *nic)
 {
 	nic_free_all_interrupts(nic);
-	nic_disable_msix(nic);
+	pci_free_irq_vectors(nic->pdev);
+	nic->num_vec = 0;
 }
 
 static int nic_num_sqs_en(struct nicpf *nic, int vf_en)
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 2401758..bfaf858 100644
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
+	nic->num_vec = pci_msix_vec_count(nic->pdev);
+	ret = pci_alloc_irq_vectors(nic->pdev, nic->num_vec, nic->num_vec,
+				    PCI_IRQ_MSIX);
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
1.7.1
