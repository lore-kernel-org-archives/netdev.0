From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: introduce alloc_skb_order0
Date: Mon, 11 Oct 2010 23:17:47 +0200
Message-ID: <1286831867.30423.80.camel@edumazet-laptop>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	 <20101008145256.GB10393@redhat.com>
	 <1286550247.2959.444.camel@edumazet-laptop>
	 <20101008160341.GC10393@redhat.com>
	 <1286639996.2692.148.camel@edumazet-laptop>
	 <20101011155556.GA2431@redhat.com>
	 <1286813133.2737.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55606 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756204Ab0JKVSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 17:18:08 -0400
Received: by wye20 with SMTP id 20so818618wye.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 14:18:06 -0700 (PDT)
In-Reply-To: <1286813133.2737.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 1) Allocation of a physically continous 16Kbytes bloc for the rx-ring,
> at device initialization (GFP_KERNEL OK here)
> 
>    Here, the only thing you could do is to not allocate real skbs but
> only 16KB data blocs (no need for the sk_buf, only the ->data part), and
> force copybreak for all incoming packets (remove the rx_copybreak
> tunable)
> 

Here is the patch I cooked for net-next-2.6 to implement this idea.

I tested it on a dev machine and it works well.

[PATCH net-next] r8169: use 50% less ram for RX ring

Using standard skb allocations in r8169 leads to order-3 allocations (if
PAGE_SIZE=4096), because NIC needs 16383 bytes, and skb overhead makes
this bigger than 16384 -> 32768 bytes per "skb"

Using kmalloc() permits to reduce memory requirements of one r8169 nic
by 4Mbytes. (256 frames * 16Kbytes). This is fine since a hardware bug
requires us to copy incoming frames, so we build real skb when doing
this copy.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/r8169.c |  183 ++++++++++++++----------------------------
 1 file changed, 64 insertions(+), 119 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bc669a4..1760533 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -187,12 +187,7 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
 
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
-/*
- * we set our copybreak very high so that we don't have
- * to allocate 16k frames all the time (see note in
- * rtl8169_open()
- */
-static int rx_copybreak = 16383;
+static int rx_buf_sz = 16383;
 static int use_dac;
 static struct {
 	u32 msg_enable;
@@ -484,10 +479,8 @@ struct rtl8169_private {
 	struct RxDesc *RxDescArray;	/* 256-aligned Rx descriptor ring */
 	dma_addr_t TxPhyAddr;
 	dma_addr_t RxPhyAddr;
-	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
+	void *Rx_databuff[NUM_RX_DESC];	/* Rx data buffers */
 	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
-	unsigned align;
-	unsigned rx_buf_sz;
 	struct timer_list timer;
 	u16 cp_cmd;
 	u16 intr_event;
@@ -515,8 +508,6 @@ struct rtl8169_private {
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
-module_param(rx_copybreak, int, 0);
-MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 module_param_named(debug, debug.msg_enable, int, 0);
@@ -3196,7 +3187,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= NETIF_F_GRO;
 
 	tp->intr_mask = 0xffff;
-	tp->align = cfg->align;
 	tp->hw_start = cfg->hw_start;
 	tp->intr_event = cfg->intr_event;
 	tp->napi_event = cfg->napi_event;
@@ -3266,18 +3256,6 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
-static void rtl8169_set_rxbufsize(struct rtl8169_private *tp,
-				  unsigned int mtu)
-{
-	unsigned int max_frame = mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
-
-	if (max_frame != 16383)
-		printk(KERN_WARNING PFX "WARNING! Changing of MTU on this "
-			"NIC may lead to frame reception errors!\n");
-
-	tp->rx_buf_sz = (max_frame > RX_BUF_SIZE) ? max_frame : RX_BUF_SIZE;
-}
-
 static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3287,18 +3265,6 @@ static int rtl8169_open(struct net_device *dev)
 	pm_runtime_get_sync(&pdev->dev);
 
 	/*
-	 * Note that we use a magic value here, its wierd I know
-	 * its done because, some subset of rtl8169 hardware suffers from
-	 * a problem in which frames received that are longer than
-	 * the size set in RxMaxSize register return garbage sizes
-	 * when received.  To avoid this we need to turn off filtering,
-	 * which is done by setting a value of 16383 in the RxMaxSize register
-	 * and allocating 16k frames to handle the largest possible rx value
-	 * thats what the magic math below does.
-	 */
-	rtl8169_set_rxbufsize(tp, 16383 - VLAN_ETH_HLEN - ETH_FCS_LEN);
-
-	/*
 	 * Rx and Tx desscriptors needs 256 bytes alignment.
 	 * dma_alloc_coherent provides more.
 	 */
@@ -3474,7 +3440,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
@@ -3735,7 +3701,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
 	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
 
@@ -3915,7 +3881,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
 	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
@@ -3956,8 +3922,6 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 
 	rtl8169_down(dev);
 
-	rtl8169_set_rxbufsize(tp, dev->mtu);
-
 	ret = rtl8169_init_ring(dev);
 	if (ret < 0)
 		goto out;
@@ -3978,15 +3942,15 @@ static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 	desc->opts1 &= ~cpu_to_le32(DescOwn | RsvdMask);
 }
 
-static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
-				struct sk_buff **sk_buff, struct RxDesc *desc)
+static void rtl8169_free_rx_databuff(struct rtl8169_private *tp,
+				     void **data_buff, struct RxDesc *desc)
 {
 	struct pci_dev *pdev = tp->pci_dev;
 
-	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), tp->rx_buf_sz,
+	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), rx_buf_sz,
 			 PCI_DMA_FROMDEVICE);
-	dev_kfree_skb(*sk_buff);
-	*sk_buff = NULL;
+	kfree(*data_buff);
+	*data_buff = NULL;
 	rtl8169_make_unusable_by_asic(desc);
 }
 
@@ -4005,33 +3969,34 @@ static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 	rtl8169_mark_to_asic(desc, rx_buf_sz);
 }
 
-static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
+static inline void *rtl8169_align(void *data)
+{
+	return (void *)ALIGN((long)data, 16);
+}
+
+static struct sk_buff *rtl8169_alloc_rx_data(struct pci_dev *pdev,
 					    struct net_device *dev,
-					    struct RxDesc *desc, int rx_buf_sz,
-					    unsigned int align, gfp_t gfp)
+					    struct RxDesc *desc)
 {
-	struct sk_buff *skb;
+	void *data;
 	dma_addr_t mapping;
-	unsigned int pad;
+	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 
-	pad = align ? align : NET_IP_ALIGN;
+	data = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
+	if (!data)
+		return NULL;
 
-	skb = __netdev_alloc_skb(dev, rx_buf_sz + pad, gfp);
-	if (!skb)
-		goto err_out;
-
-	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
-
-	mapping = dma_map_single(&pdev->dev, skb->data, rx_buf_sz,
+	if (rtl8169_align(data) != data) {
+		kfree(data);
+		data = kmalloc_node(rx_buf_sz + 15, GFP_KERNEL, node);
+		if (!data)
+			return NULL;
+	}
+	mapping = dma_map_single(&pdev->dev, rtl8169_align(data), rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
-out:
-	return skb;
-
-err_out:
-	rtl8169_make_unusable_by_asic(desc);
-	goto out;
+	return data;
 }
 
 static void rtl8169_rx_clear(struct rtl8169_private *tp)
@@ -4039,8 +4004,8 @@ static void rtl8169_rx_clear(struct rtl8169_private *tp)
 	unsigned int i;
 
 	for (i = 0; i < NUM_RX_DESC; i++) {
-		if (tp->Rx_skbuff[i]) {
-			rtl8169_free_rx_skb(tp, tp->Rx_skbuff + i,
+		if (tp->Rx_databuff[i]) {
+			rtl8169_free_rx_databuff(tp, tp->Rx_databuff + i,
 					    tp->RxDescArray + i);
 		}
 	}
@@ -4052,21 +4017,21 @@ static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
 	u32 cur;
 
 	for (cur = start; end - cur != 0; cur++) {
-		struct sk_buff *skb;
+		void *data;
 		unsigned int i = cur % NUM_RX_DESC;
 
 		WARN_ON((s32)(end - cur) < 0);
 
-		if (tp->Rx_skbuff[i])
+		if (tp->Rx_databuff[i])
 			continue;
 
-		skb = rtl8169_alloc_rx_skb(tp->pci_dev, dev,
-					   tp->RxDescArray + i,
-					   tp->rx_buf_sz, tp->align, gfp);
-		if (!skb)
+		data = rtl8169_alloc_rx_data(tp->pci_dev, dev,
+					     tp->RxDescArray + i);
+		if (!data) {
+			rtl8169_make_unusable_by_asic(tp->RxDescArray + i);
 			break;
-
-		tp->Rx_skbuff[i] = skb;
+		}
+		tp->Rx_databuff[i] = data;
 	}
 	return cur - start;
 }
@@ -4088,7 +4053,7 @@ static int rtl8169_init_ring(struct net_device *dev)
 	rtl8169_init_ring_indexes(tp);
 
 	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
-	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));
+	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
 
 	if (rtl8169_rx_fill(tp, dev, 0, NUM_RX_DESC, GFP_KERNEL) != NUM_RX_DESC)
 		goto err_out;
@@ -4473,27 +4438,23 @@ static inline void rtl8169_rx_csum(struct sk_buff *skb, u32 opts1)
 		skb_checksum_none_assert(skb);
 }
 
-static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff,
-				       struct rtl8169_private *tp, int pkt_size,
-				       dma_addr_t addr)
+static struct sk_buff *rtl8169_try_rx_copy(void *data,
+					   struct rtl8169_private *tp,
+					   int pkt_size,
+					   dma_addr_t addr)
 {
 	struct sk_buff *skb;
-	bool done = false;
-
-	if (pkt_size >= rx_copybreak)
-		goto out;
-
-	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
-	if (!skb)
-		goto out;
 
+	data = rtl8169_align(data);
 	dma_sync_single_for_cpu(&tp->pci_dev->dev, addr, pkt_size,
 				PCI_DMA_FROMDEVICE);
-	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
-	*sk_buff = skb;
-	done = true;
-out:
-	return done;
+	prefetch(data);
+	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
+	if (skb)
+		memcpy(skb->data, data, pkt_size);
+	dma_sync_single_for_device(&tp->pci_dev->dev, addr, pkt_size,
+				   PCI_DMA_FROMDEVICE);
+	return skb;
 }
 
 /*
@@ -4508,7 +4469,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				void __iomem *ioaddr, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
-	unsigned int delta, count;
+	unsigned int count;
 	int polling = (budget != ~(u32)0) ? 1 : 0;
 
 	cur_rx = tp->cur_rx;
@@ -4537,12 +4498,11 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				rtl8169_schedule_work(dev, rtl8169_reset_task);
 				dev->stats.rx_fifo_errors++;
 			}
-			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
+			rtl8169_mark_to_asic(desc, rx_buf_sz);
 		} else {
-			struct sk_buff *skb = tp->Rx_skbuff[entry];
+			struct sk_buff *skb;
 			dma_addr_t addr = le64_to_cpu(desc->addr);
 			int pkt_size = (status & 0x00001FFF) - 4;
-			struct pci_dev *pdev = tp->pci_dev;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -4552,18 +4512,16 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			if (unlikely(rtl8169_fragmented_frame(status))) {
 				dev->stats.rx_dropped++;
 				dev->stats.rx_length_errors++;
-				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
+				rtl8169_mark_to_asic(desc, rx_buf_sz);
 				continue;
 			}
 
-			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
-				dma_sync_single_for_device(&pdev->dev, addr,
-					pkt_size, PCI_DMA_FROMDEVICE);
-				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
-			} else {
-				dma_unmap_single(&pdev->dev, addr, tp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-				tp->Rx_skbuff[entry] = NULL;
+			skb = rtl8169_try_rx_copy(tp->Rx_databuff[entry],
+						  tp, pkt_size, addr);
+			rtl8169_mark_to_asic(desc, rx_buf_sz);
+			if (!skb) {
+				dev->stats.rx_dropped++;
+				continue;
 			}
 
 			rtl8169_rx_csum(skb, status);
@@ -4592,20 +4550,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 	count = cur_rx - tp->cur_rx;
 	tp->cur_rx = cur_rx;
 
-	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx, GFP_ATOMIC);
-	if (!delta && count)
-		netif_info(tp, intr, dev, "no Rx buffer allocated\n");
-	tp->dirty_rx += delta;
-
-	/*
-	 * FIXME: until there is periodic timer to try and refill the ring,
-	 * a temporary shortage may definitely kill the Rx process.
-	 * - disable the asic to try and avoid an overflow and kick it again
-	 *   after refill ?
-	 * - how do others driver handle this condition (Uh oh...).
-	 */
-	if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
-		netif_emerg(tp, intr, dev, "Rx buffers exhausted\n");
+	tp->dirty_rx += count;
 
 	return count;
 }


