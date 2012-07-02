From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 4/7] qlge: Fixed double pci free upon tx_ring->q allocation failure.
Date: Mon,  2 Jul 2012 19:41:51 -0400
Message-ID: <1341272514-5156-5-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58943 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752874Ab2GBX6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 19:58:37 -0400
In-Reply-To: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index cdbc860..9ecd15f 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2701,20 +2701,20 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 	    pci_alloc_consistent(qdev->pdev, tx_ring->wq_size,
 				 &tx_ring->wq_base_dma);
 
-	if ((tx_ring->wq_base == NULL) ||
-	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
-		netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
-		return -ENOMEM;
-	}
+	if (!tx_ring->wq_base || tx_ring->wq_base_dma & WQ_ADDR_ALIGN)
+		goto err;
+
 	tx_ring->q =
 	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
-	if (tx_ring->q == NULL)
+	if (!tx_ring->q)
 		goto err;
 
 	return 0;
 err:
 	pci_free_consistent(qdev->pdev, tx_ring->wq_size,
-			    tx_ring->wq_base, tx_ring->wq_base_dma);
+			tx_ring->wq_base, tx_ring->wq_base_dma);
+	tx_ring->wq_base = NULL;
+	netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
 	return -ENOMEM;
 }
 
-- 
1.7.1
