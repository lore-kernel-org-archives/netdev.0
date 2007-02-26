From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 07/13] qla3xxx: Dynamically size the rx buffer queue based on the MTU.
Date: Mon, 26 Feb 2007 11:06:37 -0800
Message-ID: <11725168032690-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030462AbXBZTHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:45 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change removes use of constants for rx buffer queue size
and instead calculates the queue length based on what he MTU
is set to.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   41 ++++++++++++++++++++++++++++-------------
 drivers/net/qla3xxx.h |    8 ++++++--
 2 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index b86cef0..fe494ac 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1718,11 +1718,11 @@ static void ql_update_lrg_bufq_prod_index(struct ql3_adapter *qdev)
 
 			qdev->lrg_buf_q_producer_index++;
 
-			if (qdev->lrg_buf_q_producer_index == NUM_LBUFQ_ENTRIES)
+			if (qdev->lrg_buf_q_producer_index == qdev->num_lbufq_entries)
 				qdev->lrg_buf_q_producer_index = 0;
 
 			if (qdev->lrg_buf_q_producer_index ==
-			    (NUM_LBUFQ_ENTRIES - 1)) {
+			    (qdev->num_lbufq_entries - 1)) {
 				lrg_buf_q_ele = qdev->lrg_buf_q_virt_addr;
 			}
 		}
@@ -1803,7 +1803,7 @@ static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 		lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
 		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
 		qdev->lrg_buf_release_cnt++;
-		if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS) {
+		if (++qdev->lrg_buf_index == qdev->num_large_buffers) {
 			qdev->lrg_buf_index = 0;
 		}
 		curr_ial_ptr++;	/* 64-bit pointers require two incs. */
@@ -1818,7 +1818,7 @@ static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 	 * Second buffer gets sent up the stack.
 	 */
 	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
+	if (++qdev->lrg_buf_index == qdev->num_large_buffers)
 		qdev->lrg_buf_index = 0;
 	skb = lrg_buf_cb2->skb;
 
@@ -1873,7 +1873,7 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 		lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
 		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
 		qdev->lrg_buf_release_cnt++;
-		if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
+		if (++qdev->lrg_buf_index == qdev->num_large_buffers)
 			qdev->lrg_buf_index = 0;
 		skb1 = lrg_buf_cb1->skb;
 		curr_ial_ptr++;	/* 64-bit pointers require two incs. */
@@ -1888,7 +1888,7 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 	lrg_buf_cb2 = &qdev->lrg_buf[qdev->lrg_buf_index];
 	skb2 = lrg_buf_cb2->skb;
 	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
+	if (++qdev->lrg_buf_index == qdev->num_large_buffers)
 		qdev->lrg_buf_index = 0;
 
 	skb_put(skb2, length);	/* Just the second buffer length here. */
@@ -2365,12 +2365,19 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 {
 	/* Create Large Buffer Queue */
 	qdev->lrg_buf_q_size =
-	    NUM_LBUFQ_ENTRIES * sizeof(struct lrg_buf_q_entry);
+	    qdev->num_lbufq_entries * sizeof(struct lrg_buf_q_entry);
 	if (qdev->lrg_buf_q_size < PAGE_SIZE)
 		qdev->lrg_buf_q_alloc_size = PAGE_SIZE;
 	else
 		qdev->lrg_buf_q_alloc_size = qdev->lrg_buf_q_size * 2;
 
+	qdev->lrg_buf = kmalloc(qdev->num_large_buffers * sizeof(struct ql_rcv_buf_cb),GFP_KERNEL);
+	if (qdev->lrg_buf == NULL) {
+		printk(KERN_ERR PFX
+		       "%s: qdev->lrg_buf alloc failed.\n", qdev->ndev->name);
+		return -ENOMEM;
+	}
+	
 	qdev->lrg_buf_q_alloc_virt_addr =
 	    pci_alloc_consistent(qdev->pdev,
 				 qdev->lrg_buf_q_alloc_size,
@@ -2420,6 +2427,7 @@ static void ql_free_buffer_queues(struct ql3_adapter *qdev)
 		       "%s: Already done.\n", qdev->ndev->name);
 		return;
 	}
+	if(qdev->lrg_buf) kfree(qdev->lrg_buf);
 
 	pci_free_consistent(qdev->pdev,
 			    qdev->lrg_buf_q_alloc_size,
@@ -2503,7 +2511,7 @@ static void ql_free_large_buffers(struct ql3_adapter *qdev)
 	int i = 0;
 	struct ql_rcv_buf_cb *lrg_buf_cb;
 
-	for (i = 0; i < NUM_LARGE_BUFFERS; i++) {
+	for (i = 0; i < qdev->num_large_buffers; i++) {
 		lrg_buf_cb = &qdev->lrg_buf[i];
 		if (lrg_buf_cb->skb) {
 			dev_kfree_skb(lrg_buf_cb->skb);
@@ -2524,7 +2532,7 @@ static void ql_init_large_buffers(struct ql3_adapter *qdev)
 	struct ql_rcv_buf_cb *lrg_buf_cb;
 	struct bufq_addr_element *buf_addr_ele = qdev->lrg_buf_q_virt_addr;
 
-	for (i = 0; i < NUM_LARGE_BUFFERS; i++) {
+	for (i = 0; i < qdev->num_large_buffers; i++) {
 		lrg_buf_cb = &qdev->lrg_buf[i];
 		buf_addr_ele->addr_high = lrg_buf_cb->buf_phy_addr_high;
 		buf_addr_ele->addr_low = lrg_buf_cb->buf_phy_addr_low;
@@ -2541,7 +2549,7 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 	struct sk_buff *skb;
 	u64 map;
 
-	for (i = 0; i < NUM_LARGE_BUFFERS; i++) {
+	for (i = 0; i < qdev->num_large_buffers; i++) {
 		skb = netdev_alloc_skb(qdev->ndev,
 				       qdev->lrg_buffer_len);
 		if (unlikely(!skb)) {
@@ -2620,9 +2628,15 @@ static int ql_create_send_free_list(struct ql3_adapter *qdev)
 
 static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 {
-	if (qdev->ndev->mtu == NORMAL_MTU_SIZE)
+	if (qdev->ndev->mtu == NORMAL_MTU_SIZE) {
+		qdev->num_lbufq_entries = NUM_LBUFQ_ENTRIES;
 		qdev->lrg_buffer_len = NORMAL_MTU_SIZE;
+	}
 	else if (qdev->ndev->mtu == JUMBO_MTU_SIZE) {
+		/*
+		 * Bigger buffers, so less of them.
+		 */
+		qdev->num_lbufq_entries = JUMBO_NUM_LBUFQ_ENTRIES;
 		qdev->lrg_buffer_len = JUMBO_MTU_SIZE;
 	} else {
 		printk(KERN_ERR PFX
@@ -2630,6 +2644,7 @@ static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 		       qdev->ndev->name);
 		return -ENOMEM;
 	}
+	qdev->num_large_buffers = qdev->num_lbufq_entries * QL_ADDR_ELE_PER_BUFQ_ENTRY;
 	qdev->lrg_buffer_len += VLAN_ETH_HLEN + VLAN_ID_LEN + QL_HEADER_SPACE;
 	qdev->max_frame_size =
 	    (qdev->lrg_buffer_len - QL_HEADER_SPACE) + ETHERNET_CRC_SIZE;
@@ -2862,7 +2877,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 			   &hmem_regs->rxLargeQBaseAddrLow,
 			   LS_64BITS(qdev->lrg_buf_q_phy_addr));
 
-	ql_write_page1_reg(qdev, &hmem_regs->rxLargeQLength, NUM_LBUFQ_ENTRIES);
+	ql_write_page1_reg(qdev, &hmem_regs->rxLargeQLength, qdev->num_lbufq_entries);
 
 	ql_write_page1_reg(qdev,
 			   &hmem_regs->rxLargeBufferLength,
@@ -2884,7 +2899,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 
 	qdev->small_buf_q_producer_index = NUM_SBUFQ_ENTRIES - 1;
 	qdev->small_buf_release_cnt = 8;
-	qdev->lrg_buf_q_producer_index = NUM_LBUFQ_ENTRIES - 1;
+	qdev->lrg_buf_q_producer_index = qdev->num_lbufq_entries - 1;
 	qdev->lrg_buf_release_cnt = 8;
 	qdev->lrg_buf_next_free =
 	    (struct bufq_addr_element *)qdev->lrg_buf_q_virt_addr;
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index b2d76ea..51173e5 100755
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1014,13 +1014,15 @@ struct eeprom_data {
 
 /* Transmit and Receive Buffers */
 #define NUM_LBUFQ_ENTRIES   	128
+#define JUMBO_NUM_LBUFQ_ENTRIES   	\
+(NUM_LBUFQ_ENTRIES/(JUMBO_MTU_SIZE/NORMAL_MTU_SIZE))
 #define NUM_SBUFQ_ENTRIES   	64
 #define QL_SMALL_BUFFER_SIZE    32
 #define QL_ADDR_ELE_PER_BUFQ_ENTRY \
 (sizeof(struct lrg_buf_q_entry) / sizeof(struct bufq_addr_element))
     /* Each send has at least control block.  This is how many we keep. */
 #define NUM_SMALL_BUFFERS     	NUM_SBUFQ_ENTRIES * QL_ADDR_ELE_PER_BUFQ_ENTRY
-#define NUM_LARGE_BUFFERS     	NUM_LBUFQ_ENTRIES * QL_ADDR_ELE_PER_BUFQ_ENTRY
+
 #define QL_HEADER_SPACE 32	/* make header space at top of skb. */
 /*
  * Large & Small Buffers for Receives
@@ -1207,9 +1209,11 @@ struct ql3_adapter {
 	u32 lrg_buf_q_producer_index;
 	u32 lrg_buf_release_cnt;
 	struct bufq_addr_element *lrg_buf_next_free;
+	u32 num_large_buffers;
+	u32 num_lbufq_entries;
 
 	/* Large (Receive) Buffers */
-	struct ql_rcv_buf_cb lrg_buf[NUM_LARGE_BUFFERS];
+	struct ql_rcv_buf_cb *lrg_buf;
 	struct ql_rcv_buf_cb *lrg_buf_free_head;
 	struct ql_rcv_buf_cb *lrg_buf_free_tail;
 	u32 lrg_buf_free_count;
-- 
1.5.0.rc4.16.g9e258

