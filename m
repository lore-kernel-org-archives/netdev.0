From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 09/13] qla3xxx: bugfix: Fixed jumbo frame handling for 3032 chip.
Date: Mon, 26 Feb 2007 11:06:39 -0800
Message-ID: <11725168033739-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030464AbXBZTHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:46 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The scatter/gather lists were not being build correctly.  When
large frames spanned several buffers the chip would panic.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   99 +++++++++++++++++++++++++++++++-----------------
 drivers/net/qla3xxx.h |    1 -
 2 files changed, 64 insertions(+), 36 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index cb3a05e..d2f4397 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2140,11 +2140,13 @@ static void ql_hw_csum_setup(struct sk_buff *skb,
 
 	if (ip) {
 		if (ip->protocol == IPPROTO_TCP) {
-			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_TC;
+			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_TC | 
+			OB_3032MAC_IOCB_REQ_IC;
 			mac_iocb_ptr->ip_hdr_off = offset;
 			mac_iocb_ptr->ip_hdr_len = ip->ihl;
 		} else if (ip->protocol == IPPROTO_UDP) {
-			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_UC;
+			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_UC | 
+			OB_3032MAC_IOCB_REQ_IC;
 			mac_iocb_ptr->ip_hdr_off = offset;
 			mac_iocb_ptr->ip_hdr_len = ip->ihl;
 		}
@@ -2152,51 +2154,29 @@ static void ql_hw_csum_setup(struct sk_buff *skb,
 }
 
 /*
- * The difference between 3022 and 3032 sends:
- * 3022 only supports a simple single segment transmission.
- * 3032 supports checksumming and scatter/gather lists (fragments).
- * The 3032 supports sglists by using the 3 addr/len pairs (ALP) 
- * in the IOCB plus a chain of outbound address lists (OAL) that 
- * each contain 5 ALPs.  The last ALP of the IOCB (3rd) or OAL (5th) 
- * will used to point to an OAL when more ALP entries are required.  
- * The IOCB is always the top of the chain followed by one or more 
- * OALs (when necessary).
+ * Map the buffers for this transmit.  This will return
+ * NETDEV_TX_BUSY or NETDEV_TX_OK based on success.
  */
-static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
+static int ql_send_map(struct ql3_adapter *qdev,
+				struct ob_mac_iocb_req *mac_iocb_ptr,
+				struct ql_tx_buf_cb *tx_cb,
+				struct sk_buff *skb)
 {
-	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
-	struct ql_tx_buf_cb *tx_cb;
-	u32 tot_len = skb->len;
 	struct oal *oal;
 	struct oal_entry *oal_entry;
-	int len;
-	struct ob_mac_iocb_req *mac_iocb_ptr;
+	int len = skb_headlen(skb);
 	u64 map;
 	int seg_cnt, seg = 0;
 	int frag_cnt = (int)skb_shinfo(skb)->nr_frags;
 
-	if (unlikely(atomic_read(&qdev->tx_count) < 2)) {
-		if (!netif_queue_stopped(ndev))
-			netif_stop_queue(ndev);
-		return NETDEV_TX_BUSY;
-	}
-	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
 	seg_cnt = tx_cb->seg_count = ql_get_seg_count((skb_shinfo(skb)->nr_frags));
 	if(seg_cnt == -1) {
 		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
-		return NETDEV_TX_OK;
-
+		return NETDEV_TX_BUSY;
 	}
-	mac_iocb_ptr = tx_cb->queue_entry;
-	mac_iocb_ptr->opcode = qdev->mac_ob_opcode;
-	mac_iocb_ptr->flags |= qdev->mb_bit_mask;
-	mac_iocb_ptr->transaction_id = qdev->req_producer_index;
-	mac_iocb_ptr->data_len = cpu_to_le16((u16) tot_len);
-	tx_cb->skb = skb;
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		ql_hw_csum_setup(skb, mac_iocb_ptr);
-	len = skb_headlen(skb);
+	/*
+	 * Map the skb buffer first.
+	 */
 	map = pci_map_single(qdev->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
 	oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
@@ -2253,6 +2233,55 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 		oal_entry->len =
 		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
 	}
+	return NETDEV_TX_OK;
+}
+
+/*
+ * The difference between 3022 and 3032 sends:
+ * 3022 only supports a simple single segment transmission.
+ * 3032 supports checksumming and scatter/gather lists (fragments).
+ * The 3032 supports sglists by using the 3 addr/len pairs (ALP) 
+ * in the IOCB plus a chain of outbound address lists (OAL) that 
+ * each contain 5 ALPs.  The last ALP of the IOCB (3rd) or OAL (5th) 
+ * will used to point to an OAL when more ALP entries are required.  
+ * The IOCB is always the top of the chain followed by one or more 
+ * OALs (when necessary).
+ */
+static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
+	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql_tx_buf_cb *tx_cb;
+	u32 tot_len = skb->len;
+	struct ob_mac_iocb_req *mac_iocb_ptr;
+
+	if (unlikely(atomic_read(&qdev->tx_count) < 2)) {
+		if (!netif_queue_stopped(ndev))
+			netif_stop_queue(ndev);
+		return NETDEV_TX_BUSY;
+	}
+	
+	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
+	if((tx_cb->seg_count = ql_get_seg_count((skb_shinfo(skb)->nr_frags))) == -1) {
+		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
+		return NETDEV_TX_OK;
+	}
+	
+	mac_iocb_ptr = tx_cb->queue_entry;
+	mac_iocb_ptr->opcode = qdev->mac_ob_opcode;
+	mac_iocb_ptr->flags = OB_MAC_IOCB_REQ_X;
+	mac_iocb_ptr->flags |= qdev->mb_bit_mask;
+	mac_iocb_ptr->transaction_id = qdev->req_producer_index;
+	mac_iocb_ptr->data_len = cpu_to_le16((u16) tot_len);
+	tx_cb->skb = skb;
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		ql_hw_csum_setup(skb, mac_iocb_ptr);
+	
+	if(ql_send_map(qdev,mac_iocb_ptr,tx_cb,skb) != NETDEV_TX_OK) {
+		printk(KERN_ERR PFX"%s: Could not map the segments!\n",__func__);
+		return NETDEV_TX_BUSY;
+	}
+	
 	wmb();
 	qdev->req_producer_index++;
 	if (qdev->req_producer_index == NUM_REQ_Q_ENTRIES)
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 51173e5..40913d2 100755
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1094,7 +1094,6 @@ struct oal_entry {
 	u32 len;
 #define OAL_LAST_ENTRY   0x80000000	/* Last valid buffer in list. */
 #define OAL_CONT_ENTRY   0x40000000	/* points to an OAL. (continuation) */
-	u32 reserved;
 };
 
 struct oal {
-- 
1.5.0.rc4.16.g9e258

