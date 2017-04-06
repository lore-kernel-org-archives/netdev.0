From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] mlxsw: convert to pci_alloc_irq_vectors
Date: Thu,  6 Apr 2017 11:40:23 +0200
Message-ID: <20170406094023.2710-1-hch@lst.de>
Cc: netdev@vger.kernel.org
To: jiri@mellanox.com, idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:46838 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754291AbdDFJk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 05:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial conversion as only one vector is supported, but at least we
lose the useless msix_entry member in the per-device structure.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index a223c85dfde0..f7e0467e5b96 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -155,7 +155,6 @@ struct mlxsw_pci {
 	u8 __iomem *hw_addr;
 	struct mlxsw_pci_queue_type_group queues[MLXSW_PCI_QUEUE_TYPE_COUNT];
 	u32 doorbell_offset;
-	struct msix_entry msix_entry;
 	struct mlxsw_core *core;
 	struct {
 		struct mlxsw_pci_mem_item *items;
@@ -1534,7 +1533,7 @@ static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 	if (err)
 		goto err_aqs_init;
 
-	err = request_irq(mlxsw_pci->msix_entry.vector,
+	err = request_irq(pci_irq_vector(pdev, 0),
 			  mlxsw_pci_eq_irq_handler, 0,
 			  mlxsw_pci->bus_info.device_kind, mlxsw_pci);
 	if (err) {
@@ -1567,7 +1566,7 @@ static void mlxsw_pci_fini(void *bus_priv)
 {
 	struct mlxsw_pci *mlxsw_pci = bus_priv;
 
-	free_irq(mlxsw_pci->msix_entry.vector, mlxsw_pci);
+	free_irq(pci_irq_vector(mlxsw_pci->pdev, 0), mlxsw_pci);
 	mlxsw_pci_aqs_fini(mlxsw_pci);
 	mlxsw_pci_fw_area_fini(mlxsw_pci);
 	mlxsw_pci_mbox_free(mlxsw_pci, &mlxsw_pci->cmd.out_mbox);
@@ -1842,8 +1841,8 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_sw_reset;
 	}
 
-	err = pci_enable_msix_exact(pdev, &mlxsw_pci->msix_entry, 1);
-	if (err) {
+	err = pci_alloc_irq_vectors(pdev, 1, 1, PCI_IRQ_MSIX);
+	if (err < 0) {
 		dev_err(&pdev->dev, "MSI-X init failed\n");
 		goto err_msix_init;
 	}
@@ -1872,7 +1871,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 err_bus_device_register:
 	debugfs_remove_recursive(mlxsw_pci->dbg_dir);
 err_dbg_create_dir:
-	pci_disable_msix(mlxsw_pci->pdev);
+	pci_free_irq_vectors(mlxsw_pci->pdev);
 err_msix_init:
 err_sw_reset:
 	iounmap(mlxsw_pci->hw_addr);
@@ -1893,7 +1892,7 @@ static void mlxsw_pci_remove(struct pci_dev *pdev)
 
 	mlxsw_core_bus_device_unregister(mlxsw_pci->core);
 	debugfs_remove_recursive(mlxsw_pci->dbg_dir);
-	pci_disable_msix(mlxsw_pci->pdev);
+	pci_free_irq_vectors(mlxsw_pci->pdev);
 	iounmap(mlxsw_pci->hw_addr);
 	pci_release_regions(mlxsw_pci->pdev);
 	pci_disable_device(mlxsw_pci->pdev);
-- 
2.11.0
