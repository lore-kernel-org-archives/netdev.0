From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 03/10] qede: Add missing Status-block free
Date: Sun, 21 May 2017 12:10:54 +0300
Message-ID: <1495357860-28280-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0041.outbound.protection.outlook.com ([104.47.41.41]:26256
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752421AbdEUJLf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:11:35 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

When destroying the datapath channels, qede doesn't notify qed of the
released status blocks which were acquired during the initialization.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 766bd37..aea9dcf 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1072,12 +1072,15 @@ static int qede_set_num_queues(struct qede_dev *edev)
 	return rc;
 }
 
-static void qede_free_mem_sb(struct qede_dev *edev,
-			     struct qed_sb_info *sb_info)
+static void qede_free_mem_sb(struct qede_dev *edev, struct qed_sb_info *sb_info,
+			     u16 sb_id)
 {
-	if (sb_info->sb_virt)
+	if (sb_info->sb_virt) {
+		edev->ops->common->sb_release(edev->cdev, sb_info, sb_id);
 		dma_free_coherent(&edev->pdev->dev, sizeof(*sb_info->sb_virt),
 				  (void *)sb_info->sb_virt, sb_info->sb_phys);
+		memset(sb_info, 0, sizeof(*sb_info));
+	}
 }
 
 /* This function allocates fast-path status block memory */
@@ -1334,7 +1337,7 @@ static int qede_alloc_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 /* This function frees all memory of a single fp */
 static void qede_free_mem_fp(struct qede_dev *edev, struct qede_fastpath *fp)
 {
-	qede_free_mem_sb(edev, fp->sb_info);
+	qede_free_mem_sb(edev, fp->sb_info, fp->id);
 
 	if (fp->type & QEDE_FASTPATH_RX)
 		qede_free_mem_rxq(edev, fp->rxq);
-- 
1.9.3
