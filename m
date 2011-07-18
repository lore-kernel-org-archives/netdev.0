From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 15/45] bna: Set MBOX MSIX Index to Zero
Date: Mon, 18 Jul 2011 01:22:35 -0700
Message-ID: <1310977385-5268-5-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37782 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801Ab1GRIXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:35 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Modifying mbox irq alloc/free code to use MSIX index 0 for mailbox
 - Call register_netdev() with the bnad_conf_lock() not held.
 - setting interrupt type conditionally - MSI-X or INTx and not setting
   interrupt type invariably to INTx.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |   17 +++++++++--------
 drivers/net/bna/bnad.h |    3 +++
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index f696d3a..cd2b921 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -58,7 +58,7 @@ static const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
 #define BNAD_GET_MBOX_IRQ(_bnad)				\
 	(((_bnad)->cfg_flags & BNAD_CF_MSIX) ?			\
-	 ((_bnad)->msix_table[(_bnad)->msix_num - 1].vector) :	\
+	 ((_bnad)->msix_table[BNAD_MAILBOX_MSIX_INDEX].vector) : \
 	 ((_bnad)->pcidev->irq))
 
 #define BNAD_FILL_UNMAPQ_MEM_REQ(_res_info, _num, _depth)	\
@@ -1216,17 +1216,17 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (bnad->cfg_flags & BNAD_CF_MSIX) {
 		irq_handler = (irq_handler_t)bnad_msix_mbox_handler;
-		irq = bnad->msix_table[bnad->msix_num - 1].vector;
+		irq = bnad->msix_table[BNAD_MAILBOX_MSIX_INDEX].vector;
 		irq_flags = 0;
 		intr_info->intr_type = BNA_INTR_T_MSIX;
-		intr_info->idl[0].vector = bnad->msix_num - 1;
+		intr_info->idl[0].vector = BNAD_MAILBOX_MSIX_INDEX;
 	} else {
 		irq_handler = (irq_handler_t)bnad_isr;
 		irq = bnad->pcidev->irq;
 		irq_flags = IRQF_SHARED;
 		intr_info->intr_type = BNA_INTR_T_INTX;
-		/* intr_info->idl.vector = 0 ? */
 	}
+
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 	sprintf(bnad->mbox_irq_name, "%s", BNAD_NAME);
 
@@ -1279,11 +1279,12 @@ bnad_txrx_irq_alloc(struct bnad *bnad, enum bnad_intr_source src,
 
 		switch (src) {
 		case BNAD_INTR_TX:
-			vector_start = txrx_id;
+			vector_start = BNAD_MAILBOX_MSIX_VECTORS + txrx_id;
 			break;
 
 		case BNAD_INTR_RX:
-			vector_start = bnad->num_tx * bnad->num_txq_per_tx +
+			vector_start = BNAD_MAILBOX_MSIX_VECTORS +
+					(bnad->num_tx * bnad->num_txq_per_tx) +
 					txrx_id;
 			break;
 
@@ -1304,11 +1305,11 @@ bnad_txrx_irq_alloc(struct bnad *bnad, enum bnad_intr_source src,
 
 		switch (src) {
 		case BNAD_INTR_TX:
-			intr_info->idl[0].vector = 0x1; /* Bit mask : Tx IB */
+			intr_info->idl[0].vector = BNAD_INTX_TX_IB_BITMASK;
 			break;
 
 		case BNAD_INTR_RX:
-			intr_info->idl[0].vector = 0x2; /* Bit mask : Rx IB */
+			intr_info->idl[0].vector = BNAD_INTX_RX_IB_BITMASK;
 			break;
 		}
 	}
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 0928e68..6a161b0 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -68,7 +68,10 @@ struct bnad_rx_ctrl {
 
 #define BNAD_VERSION			"2.3.2.3"
 
+#define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
+#define BNAD_INTX_TX_IB_BITMASK		0x1
+#define BNAD_INTX_RX_IB_BITMASK		0x2
 
 #define BNAD_STATS_TIMER_FREQ		1000	/* in msecs */
 #define BNAD_DIM_TIMER_FREQ		1000	/* in msecs */
-- 
1.7.1

