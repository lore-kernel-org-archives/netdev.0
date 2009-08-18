From: Roland Dreier <rdreier@cisco.com>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Mon, 17 Aug 2009 18:28:56 -0700
Message-ID: <ada3a7p3o6f.fsf@cisco.com>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org>
	<ada7hx22j3g.fsf@cisco.com>
	<alpine.DEB.1.10.0908171814210.15956@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:55206 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbZHRB2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 21:28:55 -0400
In-Reply-To: <alpine.DEB.1.10.0908171814210.15956@gentwo.org> (Christoph
	Lameter's message of "Mon, 17 Aug 2009 18:17:57 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > > [   10.256371] mlx4_core 0000:04:00.0: SW2HW_EQ failed (-5)

 > Device FW??? The log you wanted follows at the end of this message.

Not sure why there are "???" there... the (-5) error code is an
"internal error" status from the device FW on the event queue
initialization command.  Anyway I think the log shows that the problem
is exactly the one fixed in the commit I mentioned -- a423b8a0
("mlx4_core: Allocate and map sufficient ICM memory for EQ context")
from my infiniband.git tree should fix this.

The log

 > [ 7425.199430] mlx4_core 0000:04:00.0: irq 70 for MSI/MSI-X
...
 > [ 7425.199488] mlx4_core 0000:04:00.0: irq 102 for MSI/MSI-X

shows 33 event queues being allocated (num_possible_cpus() + 1) and that
will hit the issue fixed in that commit.

Assuming this fixes it for you, I guess I should get this into 2.6.31,
since it obviously is hitting not-particularly-exotic systems in
practice.  I do wonder why num_possible_cpus() is 32 on your box (since
16 threads is really the max with nehalem EP).

Anyway, here's the patch I mean:

commit a423b8a022d523abe834cefe67bfaf42424150a7
Author: Eli Cohen <eli@mellanox.co.il>
Date:   Fri Aug 7 11:13:13 2009 -0700

    mlx4_core: Allocate and map sufficient ICM memory for EQ context
    
    The current implementation allocates a single host page for EQ context
    memory, which was OK when we only allocated a few EQs.  However, since
    we now allocate an EQ for each CPU core, this patch removes the
    hard-coded limit and makes the allocation depend on EQ entry size and
    the number of required EQs.
    
    Signed-off-by: Eli Cohen <eli@mellanox.co.il>
    Signed-off-by: Roland Dreier <rolandd@cisco.com>

diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index c11a052..dae6387 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -529,29 +529,36 @@ int mlx4_map_eq_icm(struct mlx4_dev *dev, u64 icm_virt)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int ret;
+	int host_pages, icm_pages;
+	int i;
 
-	/*
-	 * We assume that mapping one page is enough for the whole EQ
-	 * context table.  This is fine with all current HCAs, because
-	 * we only use 32 EQs and each EQ uses 64 bytes of context
-	 * memory, or 1 KB total.
-	 */
+	host_pages = ALIGN(min_t(int, dev->caps.num_eqs, num_possible_cpus() + 1) *
+			   dev->caps.eqc_entry_size, PAGE_SIZE) >> PAGE_SHIFT;
+	priv->eq_table.order = order_base_2(host_pages);
 	priv->eq_table.icm_virt = icm_virt;
-	priv->eq_table.icm_page = alloc_page(GFP_HIGHUSER);
+	priv->eq_table.icm_page = alloc_pages(GFP_HIGHUSER, priv->eq_table.order);
 	if (!priv->eq_table.icm_page)
 		return -ENOMEM;
 	priv->eq_table.icm_dma  = pci_map_page(dev->pdev, priv->eq_table.icm_page, 0,
-					       PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
+					       PAGE_SIZE << priv->eq_table.order,
+					       PCI_DMA_BIDIRECTIONAL);
 	if (pci_dma_mapping_error(dev->pdev, priv->eq_table.icm_dma)) {
-		__free_page(priv->eq_table.icm_page);
+		__free_pages(priv->eq_table.icm_page, priv->eq_table.order);
 		return -ENOMEM;
 	}
 
-	ret = mlx4_MAP_ICM_page(dev, priv->eq_table.icm_dma, icm_virt);
-	if (ret) {
-		pci_unmap_page(dev->pdev, priv->eq_table.icm_dma, PAGE_SIZE,
-			       PCI_DMA_BIDIRECTIONAL);
-		__free_page(priv->eq_table.icm_page);
+	icm_pages = (PAGE_SIZE / MLX4_ICM_PAGE_SIZE) << priv->eq_table.order;
+	for (i = 0; i < icm_pages; ++i) {
+		ret = mlx4_MAP_ICM_page(dev, priv->eq_table.icm_dma,
+					icm_virt + i * MLX4_ICM_PAGE_SIZE);
+		if (ret) {
+			if (i)
+				mlx4_UNMAP_ICM(dev, priv->eq_table.icm_virt, i);
+			pci_unmap_page(dev->pdev, priv->eq_table.icm_dma, PAGE_SIZE,
+				       PCI_DMA_BIDIRECTIONAL);
+			__free_pages(priv->eq_table.icm_page, priv->eq_table.order);
+			break;
+		}
 	}
 
 	return ret;
@@ -560,11 +567,12 @@ int mlx4_map_eq_icm(struct mlx4_dev *dev, u64 icm_virt)
 void mlx4_unmap_eq_icm(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	int icm_pages = (PAGE_SIZE / MLX4_ICM_PAGE_SIZE) << priv->eq_table.order;
 
-	mlx4_UNMAP_ICM(dev, priv->eq_table.icm_virt, 1);
-	pci_unmap_page(dev->pdev, priv->eq_table.icm_dma, PAGE_SIZE,
-		       PCI_DMA_BIDIRECTIONAL);
-	__free_page(priv->eq_table.icm_page);
+	mlx4_UNMAP_ICM(dev, priv->eq_table.icm_virt, icm_pages);
+	pci_unmap_page(dev->pdev, priv->eq_table.icm_dma,
+		       PAGE_SIZE << priv->eq_table.order, PCI_DMA_BIDIRECTIONAL);
+	__free_pages(priv->eq_table.icm_page, priv->eq_table.order);
 }
 
 int mlx4_alloc_eq_table(struct mlx4_dev *dev)
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 5c1afe0..474d1f3 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -207,6 +207,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.max_cqes	     = dev_cap->max_cq_sz - 1;
 	dev->caps.reserved_cqs	     = dev_cap->reserved_cqs;
 	dev->caps.reserved_eqs	     = dev_cap->reserved_eqs;
+	dev->caps.eqc_entry_size     = dev_cap->eqc_entry_sz;
 	dev->caps.mtts_per_seg	     = 1 << log_mtts_per_seg;
 	dev->caps.reserved_mtts	     = DIV_ROUND_UP(dev_cap->reserved_mtts,
 						    dev->caps.mtts_per_seg);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 5bd79c2..34bcc11 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -210,6 +210,7 @@ struct mlx4_eq_table {
 	dma_addr_t		icm_dma;
 	struct mlx4_icm_table	cmpt_table;
 	int			have_irq;
+	int			order;
 	u8			inta_pin;
 };
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ce7cc6c..8923c9b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -206,6 +206,7 @@ struct mlx4_caps {
 	int			max_cqes;
 	int			reserved_cqs;
 	int			num_eqs;
+	int			eqc_entry_size;
 	int			reserved_eqs;
 	int			num_comp_vectors;
 	int			num_mpts;
