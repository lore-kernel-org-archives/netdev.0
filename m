From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next] r8169: Add tx_buf_sz and rx_buf_coef on rtl_cfg_info
Date: Mon, 17 Aug 2015 14:10:46 +0300
Message-ID: <1439809846-3002-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36529 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbbHQLK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 07:10:58 -0400
Received: by wicja10 with SMTP id ja10so67522893wic.1
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 04:10:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put rx_buf_sz on rtl_cfg_info structure and add new
 parameter  rx_buf_coef.Param rx_buf_sz may be different by nic's and same
 rx_buf_coef On RTL 8101 series rx_buf_coef is not equal with  rx_buf_sz.
 Add --whitespace=warn on git

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6882eab..fecb7c9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -344,7 +344,7 @@ static const struct pci_device_id rtl8169_pci_tbl[] = {
 
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
-static int rx_buf_sz = 16383;
+//static int rx_buf_sz = 16383;
 static int use_dac;
 static struct {
 	u32 msg_enable;
@@ -784,6 +784,8 @@ struct rtl8169_private {
 	u16 cp_cmd;
 
 	u16 event_slow;
+        u16 rx_buf_sz;
+        u16 rx_buf_coef;
 
 	struct mdio_ops {
 		void (*write)(struct rtl8169_private *, int, int);
@@ -5321,7 +5323,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	RTL_W8(EarlyTxThres, NoEarlyTx);
 
-	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_01 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_02 ||
@@ -6229,7 +6231,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
 
 	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
 
@@ -6523,7 +6525,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
 
 	tp->cp_cmd &= ~R810X_CPCMD_QUIRK_MASK;
 	RTL_W16(CPlusCmd, tp->cp_cmd);
@@ -6609,7 +6611,7 @@ static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 static void rtl8169_free_rx_databuff(struct rtl8169_private *tp,
 				     void **data_buff, struct RxDesc *desc)
 {
-	dma_unmap_single(&tp->pci_dev->dev, le64_to_cpu(desc->addr), rx_buf_sz,
+	dma_unmap_single(&tp->pci_dev->dev, le64_to_cpu(desc->addr), tp->rx_buf_sz,
 			 DMA_FROM_DEVICE);
 
 	kfree(*data_buff);
@@ -6617,21 +6619,22 @@ static void rtl8169_free_rx_databuff(struct rtl8169_private *tp,
 	rtl8169_make_unusable_by_asic(desc);
 }
 
-static inline void rtl8169_mark_to_asic(struct RxDesc *desc, u32 rx_buf_sz)
+static inline void rtl8169_mark_to_asic(struct RxDesc *desc, u32 rx_buf_sz,
+                                        u32 rx_buf_coef)
 {
 	u32 eor = le32_to_cpu(desc->opts1) & RingEnd;
 
 	/* Force memory writes to complete before releasing descriptor */
 	dma_wmb();
 
-	desc->opts1 = cpu_to_le32(DescOwn | eor | rx_buf_sz);
+	desc->opts1 = cpu_to_le32(DescOwn | eor | (rx_buf_sz & rx_buf_coef));
 }
 
 static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
-				       u32 rx_buf_sz)
+				       u32 rx_buf_sz, u32 rx_buf_coef)
 {
 	desc->addr = cpu_to_le64(mapping);
-	rtl8169_mark_to_asic(desc, rx_buf_sz);
+	rtl8169_mark_to_asic(desc, rx_buf_sz, rx_buf_coef);
 }
 
 static inline void *rtl8169_align(void *data)
@@ -6648,18 +6651,18 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
 	struct net_device *dev = tp->dev;
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 
-	data = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
+	data = kmalloc_node(tp->rx_buf_sz, GFP_KERNEL, node);
 	if (!data)
 		return NULL;
 
 	if (rtl8169_align(data) != data) {
 		kfree(data);
-		data = kmalloc_node(rx_buf_sz + 15, GFP_KERNEL, node);
+		data = kmalloc_node(tp->rx_buf_sz + 15, GFP_KERNEL, node);
 		if (!data)
 			return NULL;
 	}
 
-	mapping = dma_map_single(d, rtl8169_align(data), rx_buf_sz,
+	mapping = dma_map_single(d, rtl8169_align(data), tp->rx_buf_sz,
 				 DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(d, mapping))) {
 		if (net_ratelimit())
@@ -6667,7 +6670,7 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
 		goto err_out;
 	}
 
-	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
+	rtl8169_map_to_asic(desc, mapping, tp->rx_buf_sz, tp->rx_buf_coef);
 	return data;
 
 err_out:
@@ -6785,7 +6788,8 @@ static void rtl_reset_work(struct rtl8169_private *tp)
 	rtl8169_hw_reset(tp);
 
 	for (i = 0; i < NUM_RX_DESC; i++)
-		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
+		rtl8169_mark_to_asic(tp->RxDescArray + i, tp->rx_buf_sz,
+                                     tp->rx_buf_coef);
 
 	rtl8169_tx_clear(tp);
 	rtl8169_init_ring_indexes(tp);
@@ -7368,7 +7372,7 @@ process_pkt:
 		}
 release_descriptor:
 		desc->opts2 = 0;
-		rtl8169_mark_to_asic(desc, rx_buf_sz);
+		rtl8169_mark_to_asic(desc, tp->rx_buf_sz, tp->rx_buf_coef);
 	}
 
 	count = cur_rx - tp->cur_rx;
@@ -7929,6 +7933,8 @@ static const struct rtl_cfg_info {
 	unsigned int region;
 	unsigned int align;
 	u16 event_slow;
+        u16 rx_buf_sz;
+        u16 rx_buf_coef;
 	unsigned features;
 	u8 default_ver;
 } rtl_cfg_infos [] = {
@@ -7937,6 +7943,8 @@ static const struct rtl_cfg_info {
 		.region		= 1,
 		.align		= 0,
 		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver,
+                .rx_buf_sz      = 16383,
+                .rx_buf_coef    = 0x3fff,
 		.features	= RTL_FEATURE_GMII,
 		.default_ver	= RTL_GIGA_MAC_VER_01,
 	},
@@ -7945,6 +7953,8 @@ static const struct rtl_cfg_info {
 		.region		= 2,
 		.align		= 8,
 		.event_slow	= SYSErr | LinkChg | RxOverflow,
+                .rx_buf_sz      = 16383,
+                .rx_buf_coef    = 0x3fff,
 		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI,
 		.default_ver	= RTL_GIGA_MAC_VER_11,
 	},
@@ -7952,6 +7962,8 @@ static const struct rtl_cfg_info {
 		.hw_start	= rtl_hw_start_8101,
 		.region		= 2,
 		.align		= 8,
+                .rx_buf_sz      = 16000,
+                .rx_buf_coef    = 0x1ff8,
                 .event_slow	= LinkChg | RxOverflow | RxFIFOOver | PCSTimeout,
 		.features	= RTL_FEATURE_MSI,
 		.default_ver	= RTL_GIGA_MAC_VER_13,
@@ -8307,6 +8319,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->hw_start = cfg->hw_start;
 	tp->event_slow = cfg->event_slow;
+        tp->rx_buf_sz = cfg->rx_buf_sz;
+        tp->rx_buf_coef = cfg->rx_buf_coef;
 
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;
-- 
2.1.4
