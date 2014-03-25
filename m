From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 11/54] atl1c: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:57 -0700
Message-ID: <1395727540-12148-11-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59096 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbaCYGLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:37 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

The call path: atl1c_xmit_frame, atlc_tx_rollback, atl1c_clean_buffer
can not be tell at compile time if it will be invoked from hard irq
or other context, as atl1c_xmit_frame does not know.  So remove
the logic that  passes the compile time knowledge into al1c_clean_buffer
and figure out it out at runtime with dev_consume_skb_any.

Replace dev_kfree_skb with dev_kfree_skb_any in atl1c_xmit_frame that
can be called in hard irq and other contexts.

Replace dev_kfree_skb and dev_kfree_skb_irq with dev_consume_skb_any
in atl1c_clean_buffer that can be called in hard irq and other
contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 4d3258dd0a88..31f262302128 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -832,7 +832,7 @@ static int atl1c_sw_init(struct atl1c_adapter *adapter)
 }
 
 static inline void atl1c_clean_buffer(struct pci_dev *pdev,
-				struct atl1c_buffer *buffer_info, int in_irq)
+				struct atl1c_buffer *buffer_info)
 {
 	u16 pci_driection;
 	if (buffer_info->flags & ATL1C_BUFFER_FREE)
@@ -850,12 +850,8 @@ static inline void atl1c_clean_buffer(struct pci_dev *pdev,
 			pci_unmap_page(pdev, buffer_info->dma,
 					buffer_info->length, pci_driection);
 	}
-	if (buffer_info->skb) {
-		if (in_irq)
-			dev_kfree_skb_irq(buffer_info->skb);
-		else
-			dev_kfree_skb(buffer_info->skb);
-	}
+	if (buffer_info->skb)
+		dev_consume_skb_any(buffer_info->skb);
 	buffer_info->dma = 0;
 	buffer_info->skb = NULL;
 	ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
@@ -875,7 +871,7 @@ static void atl1c_clean_tx_ring(struct atl1c_adapter *adapter,
 	ring_count = tpd_ring->count;
 	for (index = 0; index < ring_count; index++) {
 		buffer_info = &tpd_ring->buffer_info[index];
-		atl1c_clean_buffer(pdev, buffer_info, 0);
+		atl1c_clean_buffer(pdev, buffer_info);
 	}
 
 	/* Zero out Tx-buffers */
@@ -899,7 +895,7 @@ static void atl1c_clean_rx_ring(struct atl1c_adapter *adapter)
 
 	for (j = 0; j < rfd_ring->count; j++) {
 		buffer_info = &rfd_ring->buffer_info[j];
-		atl1c_clean_buffer(pdev, buffer_info, 0);
+		atl1c_clean_buffer(pdev, buffer_info);
 	}
 	/* zero out the descriptor ring */
 	memset(rfd_ring->desc, 0, rfd_ring->size);
@@ -1562,7 +1558,7 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 
 	while (next_to_clean != hw_next_to_clean) {
 		buffer_info = &tpd_ring->buffer_info[next_to_clean];
-		atl1c_clean_buffer(pdev, buffer_info, 1);
+		atl1c_clean_buffer(pdev, buffer_info);
 		if (++next_to_clean == tpd_ring->count)
 			next_to_clean = 0;
 		atomic_set(&tpd_ring->next_to_clean, next_to_clean);
@@ -2085,7 +2081,7 @@ static void atl1c_tx_rollback(struct atl1c_adapter *adpt,
 	while (index != tpd_ring->next_to_use) {
 		tpd = ATL1C_TPD_DESC(tpd_ring, index);
 		buffer_info = &tpd_ring->buffer_info[index];
-		atl1c_clean_buffer(adpt->pdev, buffer_info, 0);
+		atl1c_clean_buffer(adpt->pdev, buffer_info);
 		memset(tpd, 0, sizeof(struct atl1c_tpd_desc));
 		if (++index == tpd_ring->count)
 			index = 0;
@@ -2258,7 +2254,7 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 		/* roll back tpd/buffer */
 		atl1c_tx_rollback(adapter, tpd, type);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	} else {
 		atl1c_tx_queue(adapter, skb, tpd, type);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-- 
1.7.10.4
