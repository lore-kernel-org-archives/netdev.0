From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 2/11] r8169: per device receive buffer size
Date: Tue, 24 Aug 2004 00:45:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823224548.GB20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823224425.GA20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Turn the Rx receive buffer size into a per device variable.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-010 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-010	2004-08-23 23:29:59.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:29:59.000000000 +0200
@@ -341,6 +341,7 @@ struct rtl8169_private {
 	dma_addr_t RxPhyAddr;
 	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
 	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Tx data buffers */
+	unsigned rx_buf_sz;
 	struct timer_list timer;
 	u16 cp_cmd;
 	u16 intr_mask;
@@ -1056,6 +1057,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 	tp->chipset = i;
 
+	tp->rx_buf_sz = RX_BUF_SIZE;
+
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
 	return 0;
@@ -1377,46 +1380,48 @@ static inline void rtl8169_make_unusable
 	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
 }
 
-static void rtl8169_free_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
-				struct RxDesc *desc)
+static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
+				struct sk_buff **sk_buff, struct RxDesc *desc)
 {
-	pci_unmap_single(pdev, le64_to_cpu(desc->addr), RX_BUF_SIZE,
+	struct pci_dev *pdev = tp->pci_dev;
+
+	pci_unmap_single(pdev, le64_to_cpu(desc->addr), tp->rx_buf_sz,
 			 PCI_DMA_FROMDEVICE);
 	dev_kfree_skb(*sk_buff);
 	*sk_buff = NULL;
 	rtl8169_make_unusable_by_asic(desc);
 }
 
-static inline void rtl8169_return_to_asic(struct RxDesc *desc)
+static inline void rtl8169_return_to_asic(struct RxDesc *desc, int rx_buf_sz)
 {
-	desc->status |= cpu_to_le32(OWNbit + RX_BUF_SIZE);
+	desc->status |= cpu_to_le32(OWNbit + rx_buf_sz);
 }
 
-static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
+static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping,
+					int rx_buf_sz)
 {
 	desc->addr = cpu_to_le64(mapping);
-	desc->status |= cpu_to_le32(OWNbit + RX_BUF_SIZE);
+	desc->status |= cpu_to_le32(OWNbit + rx_buf_sz);
 }
 
-static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct net_device *dev,
-				struct sk_buff **sk_buff, struct RxDesc *desc)
+static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
+				struct RxDesc *desc, int rx_buf_sz)
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
 	int ret = 0;
 
-	skb = dev_alloc_skb(RX_BUF_SIZE);
+	skb = dev_alloc_skb(rx_buf_sz);
 	if (!skb)
 		goto err_out;
 
-	skb->dev = dev;
 	skb_reserve(skb, 2);
 	*sk_buff = skb;
 
-	mapping = pci_map_single(pdev, skb->tail, RX_BUF_SIZE,
+	mapping = pci_map_single(pdev, skb->tail, rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
 
-	rtl8169_give_to_asic(desc, mapping);
+	rtl8169_give_to_asic(desc, mapping, rx_buf_sz);
 
 out:
 	return ret;
@@ -1433,7 +1438,7 @@ static void rtl8169_rx_clear(struct rtl8
 
 	for (i = 0; i < NUM_RX_DESC; i++) {
 		if (tp->Rx_skbuff[i]) {
-			rtl8169_free_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
+			rtl8169_free_rx_skb(tp, tp->Rx_skbuff + i,
 					    tp->RxDescArray + i);
 		}
 	}
@@ -1450,8 +1455,8 @@ static u32 rtl8169_rx_fill(struct rtl816
 		if (tp->Rx_skbuff[i])
 			continue;
 			
-		ret = rtl8169_alloc_rx_skb(tp->pci_dev, dev, tp->Rx_skbuff + i,
-					   tp->RxDescArray + i);
+		ret = rtl8169_alloc_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
+					   tp->RxDescArray + i, tp->rx_buf_sz);
 		if (ret < 0)
 			break;
 	}
@@ -1646,8 +1651,7 @@ rtl8169_tx_interrupt(struct net_device *
 }
 
 static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-				      struct RxDesc *desc,
-				      struct net_device *dev)
+				      struct RxDesc *desc, int rx_buf_sz)
 {
 	int ret = -1;
 
@@ -1656,11 +1660,10 @@ static inline int rtl8169_try_rx_copy(st
 
 		skb = dev_alloc_skb(pkt_size + 2);
 		if (skb) {
-			skb->dev = dev;
 			skb_reserve(skb, 2);
 			eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
 			*sk_buff = skb;
-			rtl8169_return_to_asic(desc);
+			rtl8169_return_to_asic(desc, rx_buf_sz);
 			ret = 0;
 		}
 	}
@@ -1707,17 +1710,19 @@ rtl8169_rx_interrupt(struct net_device *
 
 
 			pci_dma_sync_single_for_cpu(tp->pci_dev,
-				le64_to_cpu(desc->addr), RX_BUF_SIZE,
+				le64_to_cpu(desc->addr), tp->rx_buf_sz,
 				PCI_DMA_FROMDEVICE);
 
-			if (rtl8169_try_rx_copy(&skb, pkt_size, desc, dev)) {
+			if (rtl8169_try_rx_copy(&skb, pkt_size, desc,
+						tp->rx_buf_sz)) {
 				pci_action = pci_unmap_single;
 				tp->Rx_skbuff[entry] = NULL;
 			}
 
 			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
-				   RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+				   tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
+			skb->dev = dev;
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 			rtl8169_rx_skb(skb);

_
