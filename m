From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net] bnx2x: avoid leaking memory on bnx2x_init_one() failures
Date: Mon, 30 May 2016 15:00:54 +0200
Message-ID: <1464613254-13640-1-git-send-email-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org, Ariel Elior <ariel.elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bnx2x_init_bp() allocates memory with bnx2x_alloc_mem_bp() so if we
fail later in bnx2x_init_one() we need to free this memory
with bnx2x_free_mem_bp() to avoid leakages. E.g. I'm observing memory
leaks reported by kmemleak when a failure (unrelated) happens in
bnx2x_vfpf_acquire().

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0a5b770..c5fe9158 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13941,14 +13941,14 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 		bp->doorbells = bnx2x_vf_doorbells(bp);
 		rc = bnx2x_vf_pci_alloc(bp);
 		if (rc)
-			goto init_one_exit;
+			goto init_one_freemem;
 	} else {
 		doorbell_size = BNX2X_L2_MAX_CID(bp) * (1 << BNX2X_DB_SHIFT);
 		if (doorbell_size > pci_resource_len(pdev, 2)) {
 			dev_err(&bp->pdev->dev,
 				"Cannot map doorbells, bar size too small, aborting\n");
 			rc = -ENOMEM;
-			goto init_one_exit;
+			goto init_one_freemem;
 		}
 		bp->doorbells = ioremap_nocache(pci_resource_start(pdev, 2),
 						doorbell_size);
@@ -13957,19 +13957,19 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 		dev_err(&bp->pdev->dev,
 			"Cannot map doorbell space, aborting\n");
 		rc = -ENOMEM;
-		goto init_one_exit;
+		goto init_one_freemem;
 	}
 
 	if (IS_VF(bp)) {
 		rc = bnx2x_vfpf_acquire(bp, tx_count, rx_count);
 		if (rc)
-			goto init_one_exit;
+			goto init_one_freemem;
 	}
 
 	/* Enable SRIOV if capability found in configuration space */
 	rc = bnx2x_iov_init_one(bp, int_mode, BNX2X_MAX_NUM_OF_VFS);
 	if (rc)
-		goto init_one_exit;
+		goto init_one_freemem;
 
 	/* calc qm_cid_count */
 	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp);
@@ -13988,7 +13988,7 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	rc = bnx2x_set_int_mode(bp);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot set interrupts\n");
-		goto init_one_exit;
+		goto init_one_freemem;
 	}
 	BNX2X_DEV_INFO("set interrupts successfully\n");
 
@@ -13996,7 +13996,7 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	rc = register_netdev(dev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
-		goto init_one_exit;
+		goto init_one_freemem;
 	}
 	BNX2X_DEV_INFO("device name after netdev register %s\n", dev->name);
 
@@ -14029,6 +14029,9 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 
 	return 0;
 
+init_one_freemem:
+	bnx2x_free_mem_bp(bp);
+
 init_one_exit:
 	bnx2x_disable_pcie_error_reporting(bp);
 
-- 
2.5.5
