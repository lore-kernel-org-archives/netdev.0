From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 5/5] mlxsw: convert to pci_alloc_irq_vectors
Date: Tue, 11 Apr 2017 13:01:25 +0200
Message-ID: <20170411110125.3446-6-hch@lst.de>
References: <20170411110125.3446-1-hch@lst.de>
Cc: bhelgaas@google.com, netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org,
        jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:45751 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752841AbdDKLCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 07:02:00 -0400
In-Reply-To: <20170411110125.3446-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial conversion as only one vector is supported, but at least we
lose the useless msix_entry member in the per-device structure.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Tested-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index eaa3e3bf5a2b..23f7d828cf67 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -136,7 +136,6 @@ struct mlxsw_pci {
 	u8 __iomem *hw_addr;
 	struct mlxsw_pci_queue_type_group queues[MLXSW_PCI_QUEUE_TYPE_COUNT];
 	u32 doorbell_offset;
-	struct msix_entry msix_entry;
 	struct mlxsw_core *core;
 	struct {
 		struct mlxsw_pci_mem_item *items;
@@ -1409,7 +1408,7 @@ static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 	if (err)
 		goto err_aqs_init;
 
-	err = request_irq(mlxsw_pci->msix_entry.vector,
+	err = request_irq(pci_irq_vector(pdev, 0),
 			  mlxsw_pci_eq_irq_handler, 0,
 			  mlxsw_pci->bus_info.device_kind, mlxsw_pci);
 	if (err) {
@@ -1442,7 +1441,7 @@ static void mlxsw_pci_fini(void *bus_priv)
 {
 	struct mlxsw_pci *mlxsw_pci = bus_priv;
 
-	free_irq(mlxsw_pci->msix_entry.vector, mlxsw_pci);
+	free_irq(pci_irq_vector(mlxsw_pci->pdev, 0), mlxsw_pci);
 	mlxsw_pci_aqs_fini(mlxsw_pci);
 	mlxsw_pci_fw_area_fini(mlxsw_pci);
 	mlxsw_pci_mbox_free(mlxsw_pci, &mlxsw_pci->cmd.out_mbox);
@@ -1717,8 +1716,8 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_sw_reset;
 	}
 
-	err = pci_enable_msix_exact(pdev, &mlxsw_pci->msix_entry, 1);
-	if (err) {
+	err = pci_alloc_irq_vectors(pdev, 1, 1, PCI_IRQ_MSIX);
+	if (err < 0) {
 		dev_err(&pdev->dev, "MSI-X init failed\n");
 		goto err_msix_init;
 	}
@@ -1737,7 +1736,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_bus_device_register:
-	pci_disable_msix(mlxsw_pci->pdev);
+	pci_free_irq_vectors(mlxsw_pci->pdev);
 err_msix_init:
 err_sw_reset:
 	iounmap(mlxsw_pci->hw_addr);
@@ -1757,7 +1756,7 @@ static void mlxsw_pci_remove(struct pci_dev *pdev)
 	struct mlxsw_pci *mlxsw_pci = pci_get_drvdata(pdev);
 
 	mlxsw_core_bus_device_unregister(mlxsw_pci->core);
-	pci_disable_msix(mlxsw_pci->pdev);
+	pci_free_irq_vectors(mlxsw_pci->pdev);
 	iounmap(mlxsw_pci->hw_addr);
 	pci_release_regions(mlxsw_pci->pdev);
 	pci_disable_device(mlxsw_pci->pdev);
-- 
2.11.0
