From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 4/6] qlge: Fixed double pci free upon tx_ring->q allocation failure.
Date: Fri, 29 Jun 2012 14:24:48 -0400
Message-ID: <1340994290-28832-5-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, Ron@linux-zupk.site,
	"Mercer <ron.mercer"@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:35961 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932101Ab2F2Sln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 14:41:43 -0400
In-Reply-To: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index cdbc860..aa514c5 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2701,11 +2701,9 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 	    pci_alloc_consistent(qdev->pdev, tx_ring->wq_size,
 				 &tx_ring->wq_base_dma);
 
-	if ((tx_ring->wq_base == NULL) ||
-	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
-		netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
-		return -ENOMEM;
-	}
+	if ((tx_ring->wq_base == NULL) || tx_ring->wq_base_dma & WQ_ADDR_ALIGN)
+		goto err;
+
 	tx_ring->q =
 	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
 	if (tx_ring->q == NULL)
@@ -2713,8 +2711,12 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 
 	return 0;
 err:
-	pci_free_consistent(qdev->pdev, tx_ring->wq_size,
+	if (tx_ring->wq_base) {
+		pci_free_consistent(qdev->pdev, tx_ring->wq_size,
 			    tx_ring->wq_base, tx_ring->wq_base_dma);
+		tx_ring->wq_base = NULL;
+	}
+	netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
 	return -ENOMEM;
 }
 
-- 
1.7.1
