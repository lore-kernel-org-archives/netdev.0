From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 08/13] qla3xxx: Clean up receive process.
Date: Mon, 26 Feb 2007 11:06:38 -0800
Message-ID: <1172516803865-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030463AbXBZTHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:45 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   78 +++++++++++++++----------------------------------
 1 files changed, 24 insertions(+), 54 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index fe494ac..cb3a05e 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1764,6 +1764,23 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	atomic_inc(&qdev->tx_count);
 }
 
+void ql_get_sbuf(struct ql3_adapter *qdev)
+{
+	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
+		qdev->small_buf_index = 0;
+	qdev->small_buf_release_cnt++;
+}
+
+struct ql_rcv_buf_cb *ql_get_lbuf(struct ql3_adapter *qdev)
+{
+	struct ql_rcv_buf_cb *lrg_buf_cb = NULL;
+	lrg_buf_cb = &qdev->lrg_buf[qdev->lrg_buf_index];
+	qdev->lrg_buf_release_cnt++;
+	if (++qdev->lrg_buf_index == qdev->num_large_buffers)
+		qdev->lrg_buf_index = 0;
+	return(lrg_buf_cb);
+}
+
 /*
  * The difference between 3022 and 3032 for inbound completions:
  * 3022 uses two buffers per completion.  The first buffer contains 
@@ -1779,47 +1796,21 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 				   struct ib_mac_iocb_rsp *ib_mac_rsp_ptr)
 {
-	long int offset;
-	u32 lrg_buf_phy_addr_low = 0;
 	struct ql_rcv_buf_cb *lrg_buf_cb1 = NULL;
 	struct ql_rcv_buf_cb *lrg_buf_cb2 = NULL;
-	u32 *curr_ial_ptr;
 	struct sk_buff *skb;
 	u16 length = le16_to_cpu(ib_mac_rsp_ptr->length);
 
 	/*
 	 * Get the inbound address list (small buffer).
 	 */
-	offset = qdev->small_buf_index * QL_SMALL_BUFFER_SIZE;
-	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
-		qdev->small_buf_index = 0;
-
-	curr_ial_ptr = (u32 *) (qdev->small_buf_virt_addr + offset);
-	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
-	qdev->small_buf_release_cnt++;
+	ql_get_sbuf(qdev);
 
-	if (qdev->device_id == QL3022_DEVICE_ID) {
-		/* start of first buffer (3022 only) */
-		lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
-		qdev->lrg_buf_release_cnt++;
-		if (++qdev->lrg_buf_index == qdev->num_large_buffers) {
-			qdev->lrg_buf_index = 0;
-		}
-		curr_ial_ptr++;	/* 64-bit pointers require two incs. */
-		curr_ial_ptr++;
-	}
+	if (qdev->device_id == QL3022_DEVICE_ID)
+		lrg_buf_cb1 = ql_get_lbuf(qdev);
 
 	/* start of second buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-	lrg_buf_cb2 = &qdev->lrg_buf[qdev->lrg_buf_index];
-
-	/*
-	 * Second buffer gets sent up the stack.
-	 */
-	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == qdev->num_large_buffers)
-		qdev->lrg_buf_index = 0;
+	lrg_buf_cb2 = ql_get_lbuf(qdev);
 	skb = lrg_buf_cb2->skb;
 
 	qdev->stats.rx_packets++;
@@ -1847,11 +1838,8 @@ static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 				     struct ib_ip_iocb_rsp *ib_ip_rsp_ptr)
 {
-	long int offset;
-	u32 lrg_buf_phy_addr_low = 0;
 	struct ql_rcv_buf_cb *lrg_buf_cb1 = NULL;
 	struct ql_rcv_buf_cb *lrg_buf_cb2 = NULL;
-	u32 *curr_ial_ptr;
 	struct sk_buff *skb1 = NULL, *skb2;
 	struct net_device *ndev = qdev->ndev;
 	u16 length = le16_to_cpu(ib_ip_rsp_ptr->length);
@@ -1861,35 +1849,20 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 	 * Get the inbound address list (small buffer).
 	 */
 
-	offset = qdev->small_buf_index * QL_SMALL_BUFFER_SIZE;
-	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
-		qdev->small_buf_index = 0;
-	curr_ial_ptr = (u32 *) (qdev->small_buf_virt_addr + offset);
-	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
-	qdev->small_buf_release_cnt++;
+	ql_get_sbuf(qdev);
 
 	if (qdev->device_id == QL3022_DEVICE_ID) {
 		/* start of first buffer on 3022 */
-		lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
-		qdev->lrg_buf_release_cnt++;
-		if (++qdev->lrg_buf_index == qdev->num_large_buffers)
-			qdev->lrg_buf_index = 0;
+		lrg_buf_cb1 = ql_get_lbuf(qdev);
 		skb1 = lrg_buf_cb1->skb;
-		curr_ial_ptr++;	/* 64-bit pointers require two incs. */
-		curr_ial_ptr++;
 		size = ETH_HLEN;
 		if (*((u16 *) skb1->data) != 0xFFFF)
 			size += VLAN_ETH_HLEN - ETH_HLEN;
 	}
 
 	/* start of second buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-	lrg_buf_cb2 = &qdev->lrg_buf[qdev->lrg_buf_index];
+	lrg_buf_cb2 = ql_get_lbuf(qdev);
 	skb2 = lrg_buf_cb2->skb;
-	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == qdev->num_large_buffers)
-		qdev->lrg_buf_index = 0;
 
 	skb_put(skb2, length);	/* Just the second buffer length here. */
 	pci_unmap_single(qdev->pdev,
@@ -2428,7 +2401,6 @@ static void ql_free_buffer_queues(struct ql3_adapter *qdev)
 		return;
 	}
 	if(qdev->lrg_buf) kfree(qdev->lrg_buf);
-
 	pci_free_consistent(qdev->pdev,
 			    qdev->lrg_buf_q_alloc_size,
 			    qdev->lrg_buf_q_alloc_virt_addr,
@@ -2473,8 +2445,6 @@ static int ql_alloc_small_buffers(struct ql3_adapter *qdev)
 
 	small_buf_q_entry = qdev->small_buf_q_virt_addr;
 
-	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low;
-
 	/* Initialize the small buffer queue. */
 	for (i = 0; i < (QL_ADDR_ELE_PER_BUFQ_ENTRY * NUM_SBUFQ_ENTRIES); i++) {
 		small_buf_q_entry->addr_high =
-- 
1.5.0.rc4.16.g9e258

