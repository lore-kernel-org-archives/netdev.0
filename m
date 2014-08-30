From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 5/7] e1000: rename struct e1000_buffer to e1000_tx_buffer
Date: Sat, 30 Aug 2014 20:28:25 +0200
Message-ID: <1409423307-23470-6-git-send-email-fw@strlen.de>
References: <1409423307-23470-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43559 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751808AbaH3S25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 14:28:57 -0400
In-Reply-To: <1409423307-23470-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

and remove *page, its only used for rx.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/intel/e1000/e1000.h         |  9 ++++-----
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |  2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 23 ++++++++++++-----------
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 81efe33..4c2a102 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -148,16 +148,15 @@ struct e1000_adapter;
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer
  */
-struct e1000_buffer {
+struct e1000_tx_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
-	struct page *page;
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
-	unsigned int segs;
+	bool mapped_as_page;
+	unsigned short segs;
 	unsigned int bytecount;
-	u16 mapped_as_page;
 };
 
 struct e1000_rx_buffer {
@@ -180,7 +179,7 @@ struct e1000_tx_ring {
 	/* next descriptor to check for DD status bit */
 	unsigned int next_to_clean;
 	/* array of buffer information structs */
-	struct e1000_buffer *buffer_info;
+	struct e1000_tx_buffer *buffer_info;
 
 	u16 tdh;
 	u16 tdt;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index fbf7a4d..380a730 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1010,7 +1010,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	if (!txdr->count)
 		txdr->count = E1000_DEFAULT_TXD;
 
-	txdr->buffer_info = kcalloc(txdr->count, sizeof(struct e1000_buffer),
+	txdr->buffer_info = kcalloc(txdr->count, sizeof(struct e1000_tx_buffer),
 				    GFP_KERNEL);
 	if (!txdr->buffer_info) {
 		ret_val = 1;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 5ff48af..73cd509 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1497,7 +1497,7 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
-	size = sizeof(struct e1000_buffer) * txdr->count;
+	size = sizeof(struct e1000_tx_buffer) * txdr->count;
 	txdr->buffer_info = vzalloc(size);
 	if (!txdr->buffer_info)
 		return -ENOMEM;
@@ -1947,8 +1947,9 @@ void e1000_free_all_tx_resources(struct e1000_adapter *adapter)
 		e1000_free_tx_resources(adapter, &adapter->tx_ring[i]);
 }
 
-static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
-					     struct e1000_buffer *buffer_info)
+static void
+e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
+				 struct e1000_tx_buffer *buffer_info)
 {
 	if (buffer_info->dma) {
 		if (buffer_info->mapped_as_page)
@@ -1977,7 +1978,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 				struct e1000_tx_ring *tx_ring)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct e1000_buffer *buffer_info;
+	struct e1000_tx_buffer *buffer_info;
 	unsigned long size;
 	unsigned int i;
 
@@ -1989,7 +1990,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 	}
 
 	netdev_reset_queue(adapter->netdev);
-	size = sizeof(struct e1000_buffer) * tx_ring->count;
+	size = sizeof(struct e1000_tx_buffer) * tx_ring->count;
 	memset(tx_ring->buffer_info, 0, size);
 
 	/* Zero out the descriptor ring */
@@ -2677,7 +2678,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
 		     struct e1000_tx_ring *tx_ring, struct sk_buff *skb)
 {
 	struct e1000_context_desc *context_desc;
-	struct e1000_buffer *buffer_info;
+	struct e1000_tx_buffer *buffer_info;
 	unsigned int i;
 	u32 cmd_length = 0;
 	u16 ipcse = 0, tucse, mss;
@@ -2748,7 +2749,7 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter,
 			  struct e1000_tx_ring *tx_ring, struct sk_buff *skb)
 {
 	struct e1000_context_desc *context_desc;
-	struct e1000_buffer *buffer_info;
+	struct e1000_tx_buffer *buffer_info;
 	unsigned int i;
 	u8 css;
 	u32 cmd_len = E1000_TXD_CMD_DEXT;
@@ -2807,7 +2808,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_buffer *buffer_info;
+	struct e1000_tx_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
 	unsigned int f, bytecount, segs;
@@ -2953,7 +2954,7 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_tx_desc *tx_desc = NULL;
-	struct e1000_buffer *buffer_info;
+	struct e1000_tx_buffer *buffer_info;
 	u32 txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
 	unsigned int i;
 
@@ -3370,7 +3371,7 @@ static void e1000_dump(struct e1000_adapter *adapter)
 
 	for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
 		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*tx_ring, i);
-		struct e1000_buffer *buffer_info = &tx_ring->buffer_info[i];
+		struct e1000_tx_buffer *buffer_info = &tx_ring->buffer_info[i];
 		struct my_u { __le64 a; __le64 b; };
 		struct my_u *u = (struct my_u *)tx_desc;
 		const char *type;
@@ -3808,7 +3809,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_desc *tx_desc, *eop_desc;
-	struct e1000_buffer *buffer_info;
+	struct e1000_tx_buffer *buffer_info;
 	unsigned int i, eop;
 	unsigned int count = 0;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
-- 
1.8.1.5
