From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 2/5] netxen: small xmit optimizations
Date: Mon,  9 Mar 2009 11:50:53 -0700
Message-ID: <1236624656-2082-2-git-send-email-dhananjay@netxen.com>
References: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:43664 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754205AbZCISvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 14:51:04 -0400
In-Reply-To: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    5 +----
 drivers/net/netxen/netxen_nic_init.c |    2 ++
 drivers/net/netxen/netxen_nic_main.c |   22 ++++++++++++++--------
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 92a0c77..1e9bd1d 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -358,10 +358,7 @@ struct cmd_desc_type0 {
 		__le64 addr_buffer1;
 	};
 
-	__le16 buffer1_length;
-	__le16 buffer2_length;
-	__le16 buffer3_length;
-	__le16 buffer4_length;
+	__le16 buffer_length[4];
 
 	union {
 		struct {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index f816434..72aba63 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -955,6 +955,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	int done = 0;
 
 	last_consumer = adapter->last_cmd_consumer;
+	barrier(); /* cmd_consumer can change underneath */
 	consumer = le32_to_cpu(*(adapter->cmd_consumer));
 
 	while (last_consumer != consumer) {
@@ -1005,6 +1006,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	 * There is still a possible race condition and the host could miss an
 	 * interrupt. The card has to take care of this.
 	 */
+	barrier(); /* cmd_consumer can change underneath */
 	consumer = le32_to_cpu(*(adapter->cmd_consumer));
 	done = (last_consumer == consumer);
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index c5eace2..f764eb2 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1209,7 +1209,16 @@ netxen_clean_tx_dma_mapping(struct pci_dev *pdev,
 	}
 }
 
-static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static inline void
+netxen_clear_cmddesc(u64 *desc)
+{
+	int i;
+	for (i = 0; i < 8; i++)
+		desc[i] = 0ULL;
+}
+
+static int
+netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct netxen_hardware_context *hw = &adapter->ahw;
@@ -1242,7 +1251,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	/* Copy the descriptors into the hardware    */
 	hwdesc = &hw->cmd_desc_head[producer];
-	memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
+	netxen_clear_cmddesc((u64 *)hwdesc);
 	/* Take skb->data itself */
 	pbuf = &adapter->cmd_buf_arr[producer];
 
@@ -1261,7 +1270,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	netxen_set_tx_frags_len(hwdesc, frag_count, skb->len);
 	netxen_set_tx_port(hwdesc, adapter->portnum);
 
-	hwdesc->buffer1_length = cpu_to_le16(first_seg_len);
+	hwdesc->buffer_length[0] = cpu_to_le16(first_seg_len);
 	hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
 
 	for (i = 1, k = 1; i < frag_count; i++, k++) {
@@ -1274,7 +1283,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			k = 0;
 			producer = get_next_index(producer, num_txd);
 			hwdesc = &hw->cmd_desc_head[producer];
-			memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
+			netxen_clear_cmddesc((u64 *)hwdesc);
 			pbuf = &adapter->cmd_buf_arr[producer];
 			pbuf->skb = NULL;
 		}
@@ -1294,21 +1303,18 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		buffrag->dma = temp_dma;
 		buffrag->length = temp_len;
 
+		hwdesc->buffer_length[k] = cpu_to_le16(temp_len);
 		switch (k) {
 		case 0:
-			hwdesc->buffer1_length = cpu_to_le16(temp_len);
 			hwdesc->addr_buffer1 = cpu_to_le64(temp_dma);
 			break;
 		case 1:
-			hwdesc->buffer2_length = cpu_to_le16(temp_len);
 			hwdesc->addr_buffer2 = cpu_to_le64(temp_dma);
 			break;
 		case 2:
-			hwdesc->buffer3_length = cpu_to_le16(temp_len);
 			hwdesc->addr_buffer3 = cpu_to_le64(temp_dma);
 			break;
 		case 3:
-			hwdesc->buffer4_length = cpu_to_le16(temp_len);
 			hwdesc->addr_buffer4 = cpu_to_le64(temp_dma);
 			break;
 		}
-- 
1.6.0.2

