From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: mlxsw: avoid unused variable warnings
Date: Wed, 23 Mar 2016 17:37:38 +0100
Message-ID: <1458751080-2044921-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Elad Raz <eladr@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:63926 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcCWQiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 12:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_dbg_ratelimited() is a macro that ignores its arguments when DEBUG is
not set, which can lead to unused variable warnings:

ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_sdq_handle':
ethernet/mellanox/mlxsw/pci.c:646:18: warning: unused variable 'pdev' [-Wunused-variable]
ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_rdq_handle':
ethernet/mellanox/mlxsw/pci.c:671:18: warning: unused variable 'pdev' [-Wunused-variable]

This changes the mlxsw driver to remove the local variables we get
warnings for and instead pass the device directly into the API.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 7f4173c8eda3..fdcce03b028d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -643,7 +643,6 @@ static void mlxsw_pci_cqe_sdq_handle(struct mlxsw_pci *mlxsw_pci,
 				     u16 consumer_counter_limit,
 				     char *cqe)
 {
-	struct pci_dev *pdev = mlxsw_pci->pdev;
 	struct mlxsw_pci_queue_elem_info *elem_info;
 	char *wqe;
 	struct sk_buff *skb;
@@ -659,7 +658,7 @@ static void mlxsw_pci_cqe_sdq_handle(struct mlxsw_pci *mlxsw_pci,
 	elem_info->u.sdq.skb = NULL;
 
 	if (q->consumer_counter++ != consumer_counter_limit)
-		dev_dbg_ratelimited(&pdev->dev, "Consumer counter does not match limit in SDQ\n");
+		dev_dbg_ratelimited(&mlxsw_pci->pdev->dev, "Consumer counter does not match limit in SDQ\n");
 	spin_unlock(&q->lock);
 }
 
@@ -668,7 +667,6 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 				     u16 consumer_counter_limit,
 				     char *cqe)
 {
-	struct pci_dev *pdev = mlxsw_pci->pdev;
 	struct mlxsw_pci_queue_elem_info *elem_info;
 	char *wqe;
 	struct sk_buff *skb;
@@ -684,7 +682,7 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 	mlxsw_pci_wqe_frag_unmap(mlxsw_pci, wqe, 0, DMA_FROM_DEVICE);
 
 	if (q->consumer_counter++ != consumer_counter_limit)
-		dev_dbg_ratelimited(&pdev->dev, "Consumer counter does not match limit in RDQ\n");
+		dev_dbg_ratelimited(&mlxsw_pci->pdev->dev, "Consumer counter does not match limit in RDQ\n");
 
 	if (mlxsw_pci_cqe_lag_get(cqe)) {
 		rx_info.is_lag = true;
@@ -706,7 +704,7 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 	memset(wqe, 0, q->elem_size);
 	err = mlxsw_pci_rdq_skb_alloc(mlxsw_pci, elem_info);
 	if (err)
-		dev_dbg_ratelimited(&pdev->dev, "Failed to alloc skb for RDQ\n");
+		dev_dbg_ratelimited(&mlxsw_pci->pdev->dev, "Failed to alloc skb for RDQ\n");
 	/* Everything is set up, ring doorbell to pass elem to HW */
 	q->producer_counter++;
 	mlxsw_pci_queue_doorbell_producer_ring(mlxsw_pci, q);
-- 
2.7.0
