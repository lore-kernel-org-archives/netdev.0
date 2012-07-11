From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 6/9] qlge: Fixed double pci free upon tx_ring->q allocation failure.
Date: Tue, 10 Jul 2012 20:57:36 -0400
Message-ID: <1341968259-18931-7-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23739 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753562Ab2GKBOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:14:38 -0400
In-Reply-To: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index ee3457e..cf6887a 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2710,10 +2710,9 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 				 &tx_ring->wq_base_dma);
 
 	if ((tx_ring->wq_base == NULL) ||
-	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
-		netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
-		return -ENOMEM;
-	}
+	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN)
+		goto pci_alloc_err;
+
 	tx_ring->q =
 	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
 	if (tx_ring->q == NULL)
@@ -2723,6 +2722,9 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 err:
 	pci_free_consistent(qdev->pdev, tx_ring->wq_size,
 			    tx_ring->wq_base, tx_ring->wq_base_dma);
+	tx_ring->wq_base = NULL;
+pci_alloc_err:
+	netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
 	return -ENOMEM;
 }
 
-- 
1.7.1
