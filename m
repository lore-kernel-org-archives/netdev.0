From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 8/11] r8169: Tx checksum offload
Date: Tue, 24 Aug 2004 00:55:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823225505.GH20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com> <20040823225120.GF20726@electric-eye.fr.zoreil.com> <20040823225335.GG20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823225335.GG20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

SG and IP checksumming support on output.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-080 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-080	2004-08-23 23:30:04.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:30:04.000000000 +0200
@@ -51,6 +51,9 @@ VERSION 1.6LK	<2004/04/14>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/crc32.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 
@@ -312,6 +315,11 @@ enum _DescStatusBit {
 	RingEnd		= (1 << 30), /* End of descriptor ring */
 	FirstFrag	= (1 << 29), /* First segment of a packet */
 	LastFrag	= (1 << 28), /* Final segment of a packet */
+
+	/* Tx private */
+	IPCS		= (1 << 18), /* Calculate IP checksum */
+	UDPCS		= (1 << 17), /* Calculate UDP/IP checksum */
+	TCPCS		= (1 << 16), /* Calculate TCP/IP checksum */
 };
 
 #define RsvdMask	0x3fffc000
@@ -328,6 +336,12 @@ struct RxDesc {
 	u64 addr;
 };
 
+struct ring_info {
+	struct sk_buff	*skb;
+	u32		len;
+	u8		__pad[sizeof(void *) - sizeof(u32)];
+};
+
 struct rtl8169_private {
 	void *mmio_addr;		/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device  */
@@ -345,7 +359,7 @@ struct rtl8169_private {
 	dma_addr_t TxPhyAddr;
 	dma_addr_t RxPhyAddr;
 	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
-	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Tx data buffers */
+	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
 	unsigned rx_buf_sz;
 	struct timer_list timer;
 	u16 cp_cmd;
@@ -702,6 +716,10 @@ static struct ethtool_ops rtl8169_ethtoo
 	.get_link		= ethtool_op_get_link,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
 	.get_regs		= rtl8169_get_regs,
 };
 
@@ -1479,7 +1497,7 @@ static int rtl8169_init_ring(struct net_
 	tp->cur_rx = tp->dirty_rx = 0;
 	tp->cur_tx = tp->dirty_tx = 0;
 
-	memset(tp->Tx_skbuff, 0x0, NUM_TX_DESC * sizeof(struct sk_buff *));
+	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
 	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));
 
 	if (rtl8169_rx_fill(tp, dev, 0, NUM_RX_DESC) != NUM_RX_DESC)
@@ -1494,33 +1512,38 @@ err_out:
 	return -ENOMEM;
 }
 
-static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
+static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 				 struct TxDesc *desc)
 {
-	u32 len = sk_buff[0]->len;
+	unsigned int len = tx_skb->len;
 
-	pci_unmap_single(pdev, le64_to_cpu(desc->addr),
-			 len < ETH_ZLEN ? ETH_ZLEN : len, PCI_DMA_TODEVICE);
+	pci_unmap_single(pdev, le64_to_cpu(desc->addr), len, PCI_DMA_TODEVICE);
 	desc->addr = 0x00;
-	*sk_buff = NULL;
+	tx_skb->len = 0;
 }
 
-static void
-rtl8169_tx_clear(struct rtl8169_private *tp)
+static void rtl8169_tx_clear(struct rtl8169_private *tp)
 {
-	int i;
+	unsigned int i;
 
-	tp->cur_tx = 0;
-	for (i = 0; i < NUM_TX_DESC; i++) {
-		struct sk_buff *skb = tp->Tx_skbuff[i];
+	for (i = tp->dirty_tx; i < tp->dirty_tx + NUM_TX_DESC; i++) {
+		unsigned int entry = i % NUM_TX_DESC;
+		struct ring_info *tx_skb = tp->tx_skb + entry;
+		unsigned int len = tx_skb->len;
 
-		if (skb) {
-			rtl8169_unmap_tx_skb(tp->pci_dev, tp->Tx_skbuff + i,
-					     tp->TxDescArray + i);
-			dev_kfree_skb(skb);
+		if (len) {
+			struct sk_buff *skb = tx_skb->skb;
+
+			rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb,
+					     tp->TxDescArray + entry);
+			if (skb) {
+				dev_kfree_skb(skb);
+				tx_skb->skb = NULL;
+			}
 			tp->stats.tx_dropped++;
 		}
 	}
+	tp->cur_tx = tp->dirty_tx = 0;
 }
 
 static void
@@ -1550,51 +1573,121 @@ rtl8169_tx_timeout(struct net_device *de
 	netif_wake_queue(dev);
 }
 
-static int
-rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
+			      u32 opts1)
+{
+	struct skb_shared_info *info = skb_shinfo(skb);
+	unsigned int cur_frag, entry;
+	struct TxDesc *txd;
+
+	entry = tp->cur_tx;
+	for (cur_frag = 0; cur_frag < info->nr_frags; cur_frag++) {
+		skb_frag_t *frag = info->frags + cur_frag;
+		dma_addr_t mapping;
+		u32 status, len;
+		void *addr;
+
+		entry = (entry + 1) % NUM_TX_DESC;
+
+		txd = tp->TxDescArray + entry;
+		len = frag->size;
+		addr = ((void *) page_address(frag->page)) + frag->page_offset;
+		mapping = pci_map_single(tp->pci_dev, addr, len, PCI_DMA_TODEVICE);
+
+		/* anti gcc 2.95.3 bugware (sic) */
+		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
+
+		txd->opts1 = cpu_to_le32(status);
+		txd->addr = cpu_to_le64(mapping);
+
+		tp->tx_skb[entry].len = len;
+	}
+
+	if (cur_frag) {
+		tp->tx_skb[entry].skb = skb;
+		txd->opts1 |= cpu_to_le32(LastFrag);
+	}
+
+	return cur_frag;
+}
+
+static inline u32 rtl8169_tx_csum(struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_HW) {
+		const struct iphdr *ip = skb->nh.iph;
+
+		if (ip->protocol == IPPROTO_TCP)
+			return IPCS | TCPCS;
+		else if (ip->protocol == IPPROTO_UDP)
+			return IPCS | UDPCS;
+		BUG();
+	}
+	return 0;
+}
+
+static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
+	struct TxDesc *txd = tp->TxDescArray + entry;
 	void *ioaddr = tp->mmio_addr;
-	unsigned int entry = tp->cur_tx % NUM_TX_DESC;
-	u32 len = skb->len;
+	dma_addr_t mapping;
+	u32 status, len;
+	u32 opts1;
+	
+	if (unlikely(tp->cur_tx - tp->dirty_tx < skb_shinfo(skb)->nr_frags)) {
+		netif_stop_queue(dev);
+		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
+		       dev->name);
+		return 1;
+	}
+
+	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
+		goto err_drop;
+
+	opts1 = DescOwn | rtl8169_tx_csum(skb);
+
+	frags = rtl8169_xmit_frags(tp, skb, opts1);
+	if (frags) {
+		len = skb_headlen(skb);
+		opts1 |= FirstFrag;
+	} else {
+		len = skb->len;
+
+		if (unlikely(len < ETH_ZLEN)) {
+			skb = skb_padto(skb, ETH_ZLEN);
+			if (!skb)
+				goto err_update_stats;
+			len = ETH_ZLEN;
+		}
 
-	if (unlikely(skb->len < ETH_ZLEN)) {
-		skb = skb_padto(skb, ETH_ZLEN);
-		if (!skb)
-			goto err_update_stats;
-		len = ETH_ZLEN;
+		opts1 |= FirstFrag | LastFrag;
+		tp->tx_skb[entry].skb = skb;
 	}
-	
-	if (!(le32_to_cpu(tp->TxDescArray[entry].opts1) & DescOwn)) {
-		dma_addr_t mapping;
-		u32 status;
 
-		mapping = pci_map_single(tp->pci_dev, skb->data, len,
-					 PCI_DMA_TODEVICE);
+	mapping = pci_map_single(tp->pci_dev, skb->data, len, PCI_DMA_TODEVICE);
 
-		tp->Tx_skbuff[entry] = skb;
-		tp->TxDescArray[entry].addr = cpu_to_le64(mapping);
+	tp->tx_skb[entry].len = len;
+	txd->addr = cpu_to_le64(mapping);
 
-		/* anti gcc 2.95.[3/4] bugware - do not merge these lines */
-		status = DescOwn | FirstFrag | LastFrag | len |
-			 (RingEnd * !((entry + 1) % NUM_TX_DESC));
-		tp->TxDescArray[entry].opts1 = cpu_to_le32(status);
-			
-		RTL_W8(TxPoll, 0x40);	//set polling bit
+	wmb();
 
-		dev->trans_start = jiffies;
+	/* anti gcc 2.95.3 bugware (sic) */
+	status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
+	txd->opts1 = cpu_to_le32(status);
 
-		tp->cur_tx++;
-		smp_wmb();
-	} else
-		goto err_drop;
+	dev->trans_start = jiffies;
 
-	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx) {
-		u32 dirty = tp->dirty_tx;
-	
+	tp->cur_tx += frags + 1;
+
+	smp_wmb();
+
+	RTL_W8(TxPoll, 0x40);	//set polling bit
+
+	if (tp->cur_tx - tp->dirty_tx < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
 		smp_rmb();
-		if (dirty != tp->dirty_tx)
+		if (tp->cur_tx - tp->dirty_tx >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
 	}
 
@@ -1624,7 +1717,8 @@ rtl8169_tx_interrupt(struct net_device *
 
 	while (tx_left > 0) {
 		unsigned int entry = dirty_tx % NUM_TX_DESC;
-		struct sk_buff *skb = tp->Tx_skbuff[entry];
+		struct ring_info *tx_skb = tp->tx_skb + entry;
+		u32 len = tx_skb->len;
 		u32 status;
 
 		rmb();
@@ -1632,14 +1726,15 @@ rtl8169_tx_interrupt(struct net_device *
 		if (status & DescOwn)
 			break;
 
-		/* FIXME: is it really accurate for TxErr ? */
-		tp->stats.tx_bytes += skb->len >= ETH_ZLEN ?
-				      skb->len : ETH_ZLEN;
+		tp->stats.tx_bytes += len;
 		tp->stats.tx_packets++;
-		rtl8169_unmap_tx_skb(tp->pci_dev, tp->Tx_skbuff + entry,
-				     tp->TxDescArray + entry);
-		dev_kfree_skb_irq(skb);
-		tp->Tx_skbuff[entry] = NULL;
+
+		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);
+
+		if (status & LastFrag) {
+			dev_kfree_skb_irq(tx_skb->skb);
+			tx_skb->skb = NULL;
+		}
 		dirty_tx++;
 		tx_left--;
 	}

_
