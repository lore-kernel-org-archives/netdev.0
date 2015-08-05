From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next] r8169:Issues on alloc memory
Date: Wed,  5 Aug 2015 18:41:17 +0300
Message-ID: <1438789277-4468-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36227 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbbHEPlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 11:41:35 -0400
Received: by wicgj17 with SMTP id gj17so198041315wic.1
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 08:41:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Many, many issues DESC_ARRAY represent number of descriptor 
 on array on Tx and Rx and is fit with TxDesc and RxDesc  structure,
 MAX_DESCRIPTORS is 1024 on Rx and Tx wich is  included 256 Descriptors from
 chip on Rx and Tx.  DESC_ARRAY * NUM_ARRAYS_MAX must fit with MAX_DESCRIPTORS
  256 from chip and rest from memory.  DESC_ARRAY * NUM_ARRAY_MIN is hardware
 descriptors from chip.  On doc RTL 8101/8102 and RTL 8169 report  same number
 of descriptors  1024.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index bf78f94..8bf8c3f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -74,7 +74,7 @@
 	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)
 
 #define TX_SLOTS_AVAIL(tp) \
-	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx)
+	(tp->dirty_tx + NUM_ARRAYS_MAX - tp->cur_tx)
 
 /* A skbuff with nr_frags needs nr_frags+1 entries in the tx queue */
 #define TX_FRAGS_READY_FOR(tp,nr_frags) \
@@ -87,13 +87,17 @@ static const int multicast_filter_limit = 32;
 #define MAX_READ_REQUEST_SHIFT	12
 #define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
+#define DESC_ARRAY	16	/* Number of descriptors on array to Rx and Tx */
+#define NUM_ARRAYS_MAX	64	/* Number of arrays descriptors maximum on Rx and Tx */
+#define NUM_ARRAYS_MIN	16	/* Number of arrays descriptors minimum on Rx and Tx */
+#define MAX_DESCRIPTORS	1024	/* Number of descriptors total and maximum on Rx and Tx */
 
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	256U	/* Number of Rx descriptor registers */
-#define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
-#define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
+#define R8169_TX_RING_BYTES	(NUM_ARRAYS_MAX * sizeof(struct TxDesc)) /* here sizeof not reporting correct */
+#define R8169_RX_RING_BYTES	(NUM_ARRAYS_MAX * sizeof(struct RxDesc)) /* here sizeof not reporting correct */
 
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
@@ -778,8 +782,8 @@ struct rtl8169_private {
 	struct RxDesc *RxDescArray;	/* 256-aligned Rx descriptor ring */
 	dma_addr_t TxPhyAddr;
 	dma_addr_t RxPhyAddr;
-	void *Rx_databuff[NUM_RX_DESC];	/* Rx data buffers */
-	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
+	void *Rx_databuff[NUM_ARRAYS_MAX];	/* Rx data buffers */
+	struct ring_info tx_skb[NUM_ARRAYS_MAX];	/* Tx data buffers */
 	struct timer_list timer;
 	u16 cp_cmd;
 
@@ -6679,7 +6683,7 @@ static void rtl8169_rx_clear(struct rtl8169_private *tp)
 {
 	unsigned int i;
 
-	for (i = 0; i < NUM_RX_DESC; i++) {
+	for (i = 0; i < NUM_ARRAYS_MAX; i++) {
 		if (tp->Rx_databuff[i]) {
 			rtl8169_free_rx_databuff(tp, tp->Rx_databuff + i,
 					    tp->RxDescArray + i);
@@ -6696,7 +6700,7 @@ static int rtl8169_rx_fill(struct rtl8169_private *tp)
 {
 	unsigned int i;
 
-	for (i = 0; i < NUM_RX_DESC; i++) {
+	for (i = 0; i < NUM_ARRAYS_MAX; i++) {
 		void *data;
 
 		if (tp->Rx_databuff[i])
@@ -6710,7 +6714,7 @@ static int rtl8169_rx_fill(struct rtl8169_private *tp)
 		tp->Rx_databuff[i] = data;
 	}
 
-	rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
+	rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_ARRAYS_MAX - 1);
 	return 0;
 
 err_out:
@@ -6724,8 +6728,8 @@ static int rtl8169_init_ring(struct net_device *dev)
 
 	rtl8169_init_ring_indexes(tp);
 
-	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
-	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
+	memset(tp->tx_skb, 0x0, DESC_ARRAY * NUM_ARRAYS_MIN);
+	memset(tp->Rx_databuff, 0x0, DESC_ARRAY * NUM_ARRAYS_MIN);
 
 	return rtl8169_rx_fill(tp);
 }
@@ -6749,7 +6753,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 	unsigned int i;
 
 	for (i = 0; i < n; i++) {
-		unsigned int entry = (start + i) % NUM_TX_DESC;
+		unsigned int entry = (start + i) % NUM_ARRAYS_MAX;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		unsigned int len = tx_skb->len;
 
@@ -6769,7 +6773,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 
 static void rtl8169_tx_clear(struct rtl8169_private *tp)
 {
-	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
+	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_ARRAYS_MAX);
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
@@ -6784,7 +6788,7 @@ static void rtl_reset_work(struct rtl8169_private *tp)
 
 	rtl8169_hw_reset(tp);
 
-	for (i = 0; i < NUM_RX_DESC; i++)
+	for (i = 0; i < NUM_ARRAYS_MAX; i++)
 		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
 
 	rtl8169_tx_clear(tp);
@@ -6818,7 +6822,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		u32 status, len;
 		void *addr;
 
-		entry = (entry + 1) % NUM_TX_DESC;
+		entry = (entry + 1) % NUM_ARRAYS_MAX;
 
 		txd = tp->TxDescArray + entry;
 		len = skb_frag_size(frag);
@@ -6833,7 +6837,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 
 		/* Anti gcc 2.95.3 bugware (sic) */
 		status = opts[0] | len |
-			(RingEnd * !((entry + 1) % NUM_TX_DESC));
+			(RingEnd * !((entry + 1) % NUM_ARRAYS_MAX));
 
 		txd->opts1 = cpu_to_le32(status);
 		txd->opts2 = cpu_to_le32(opts[1]);
@@ -7039,7 +7043,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned int entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned int entry = tp->cur_tx % NUM_ARRAYS_MAX;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct device *d = &tp->pci_dev->dev;
@@ -7093,7 +7097,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	dma_wmb();
 
 	/* Anti gcc 2.95.3 bugware (sic) */
-	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
+	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_ARRAYS_MAX));
 	txd->opts1 = cpu_to_le32(status);
 
 	/* Force all memory writes to complete before notifying device */
@@ -7194,7 +7198,7 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
-		unsigned int entry = dirty_tx % NUM_TX_DESC;
+		unsigned int entry = dirty_tx % NUM_ARRAYS_MAX;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		u32 status;
 
@@ -7292,8 +7296,8 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 
 	cur_rx = tp->cur_rx;
 
-	for (rx_left = min(budget, NUM_RX_DESC); rx_left > 0; rx_left--, cur_rx++) {
-		unsigned int entry = cur_rx % NUM_RX_DESC;
+	for (rx_left = min(budget, NUM_ARRAYS_MAX); rx_left > 0; rx_left--, cur_rx++) {
+		unsigned int entry = cur_rx % NUM_ARRAYS_MAX;
 		struct RxDesc *desc = tp->RxDescArray + entry;
 		u32 status;
 
@@ -7555,9 +7559,9 @@ static int rtl8169_close(struct net_device *dev)
 
 	free_irq(pdev->irq, dev);
 
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+	dma_free_coherent(&pdev->dev, (DESC_ARRAY * NUM_ARRAYS_MAX) , tp->RxDescArray,
 			  tp->RxPhyAddr);
-	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
+	dma_free_coherent(&pdev->dev, (DESC_ARRAY * NUM_ARRAYS_MAX), tp->TxDescArray,
 			  tp->TxPhyAddr);
 	tp->TxDescArray = NULL;
 	tp->RxDescArray = NULL;
@@ -7589,12 +7593,12 @@ static int rtl_open(struct net_device *dev)
 	 * Rx and Tx descriptors needs 256 bytes alignment.
 	 * dma_alloc_coherent provides more.
 	 */
-	tp->TxDescArray = dma_zalloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
+	tp->TxDescArray = dma_zalloc_coherent(&pdev->dev, (DESC_ARRAY * NUM_ARRAYS_MAX),
 					     &tp->TxPhyAddr, GFP_KERNEL);
 	if (!tp->TxDescArray)
 		goto err_pm_runtime_put;
 
-	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, R8169_RX_RING_BYTES,
+	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, (DESC_ARRAY * NUM_ARRAYS_MAX),
 					     &tp->RxPhyAddr, GFP_KERNEL);
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
@@ -7644,11 +7648,11 @@ err_release_fw_2:
 	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
 err_free_rx_1:
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+	dma_free_coherent(&pdev->dev, (DESC_ARRAY * NUM_ARRAYS_MAX), tp->RxDescArray,
 			  tp->RxPhyAddr);
 	tp->RxDescArray = NULL;
 err_free_tx_0:
-	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
+	dma_free_coherent(&pdev->dev, (DESC_ARRAY * NUM_ARRAYS_MAX), tp->TxDescArray,
 			  tp->TxPhyAddr);
 	tp->TxDescArray = NULL;
 err_pm_runtime_put:
-- 
2.1.4
