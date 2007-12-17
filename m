From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.25 1/2]S2io: Fixes to enable multiple transmit fifo
	support
Date: 17 Dec 2007 11:35:50 -0800
Message-ID: <1197920149.7518.40.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: support@neterion.com
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:53975 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbXLQSFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 13:05:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes to enable multiple transmit fifos (upto a maximum of eight).
  - Moved single tx_lock from struct s2io_nic to struct fifo_info.
  - Moved single ufo_in_band_v structure from struct s2io_nic to struct 
    fifo_info.
  - Assign the respective interrupt number for the transmitting fifo in the 
    transmit descriptor (TXD).
- Added boundary checks for number of FIFOs enabled and FIFO length.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-10/drivers/net/s2io.c 2-0-26-15-1/drivers/net/s2io.c
--- 2-0-26-10/drivers/net/s2io.c	2007-12-17 22:09:00.000000000 +0530
+++ 2-0-26-15-1/drivers/net/s2io.c	2007-12-17 22:10:50.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.10"
+#define DRV_VERSION "2.0.26.15-1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -368,12 +368,19 @@ static void do_s2io_copy_mac_addr(struct
 static void s2io_vlan_rx_register(struct net_device *dev,
 					struct vlan_group *grp)
 {
+	int i;
 	struct s2io_nic *nic = dev->priv;
-	unsigned long flags;
+	unsigned long flags[MAX_TX_FIFOS];
+	struct mac_info *mac_control = &nic->mac_control;
+	struct config_param *config = &nic->config;
+
+	for (i = 0; i < config->tx_fifo_num; i++)
+		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags[i]);
 
-	spin_lock_irqsave(&nic->tx_lock, flags);
 	nic->vlgrp = grp;
-	spin_unlock_irqrestore(&nic->tx_lock, flags);
+	for (i = config->tx_fifo_num - 1; i >= 0; i--)
+		spin_unlock_irqrestore(&mac_control->fifos[i].tx_lock,
+				flags[i]);
 }
 
 /* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
@@ -565,6 +572,21 @@ static int init_shared_mem(struct s2io_n
 		return -EINVAL;
 	}
 
+	size = 0;
+	for (i = 0; i < config->tx_fifo_num; i++) {
+		size = config->tx_cfg[i].fifo_len;
+		/*
+		 * Legal values are from 2 to 8192
+		 */
+		if (size < 2) {
+			DBG_PRINT(ERR_DBG, "s2io: Invalid fifo len (%d)", size);
+			DBG_PRINT(ERR_DBG, "for fifo %d\n", i);
+			DBG_PRINT(ERR_DBG, "s2io: Legal values for fifo len"
+				"are 2 to 8192\n");
+			return -EINVAL;
+		}
+	}
+
 	lst_size = (sizeof(struct TxD) * config->max_txds);
 	lst_per_page = PAGE_SIZE / lst_size;
 
@@ -639,10 +661,14 @@ static int init_shared_mem(struct s2io_n
 		}
 	}
 
-	nic->ufo_in_band_v = kcalloc(size, sizeof(u64), GFP_KERNEL);
-	if (!nic->ufo_in_band_v)
-		return -ENOMEM;
-	 mem_allocated += (size * sizeof(u64));
+	for (i = 0; i < config->tx_fifo_num; i++) {
+		size = config->tx_cfg[i].fifo_len;
+		mac_control->fifos[i].ufo_in_band_v
+			= kcalloc(size, sizeof(u64), GFP_KERNEL);
+		if (!mac_control->fifos[i].ufo_in_band_v)
+			return -ENOMEM;
+		mem_allocated += (size * sizeof(u64));
+	}
 
 	/* Allocation and initialization of RXDs in Rings */
 	size = 0;
@@ -829,7 +855,6 @@ static int init_shared_mem(struct s2io_n
 static void free_shared_mem(struct s2io_nic *nic)
 {
 	int i, j, blk_cnt, size;
-	u32 ufo_size = 0;
 	void *tmp_v_addr;
 	dma_addr_t tmp_p_addr;
 	struct mac_info *mac_control;
@@ -850,7 +875,6 @@ static void free_shared_mem(struct s2io_
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		ufo_size += config->tx_cfg[i].fifo_len;
 		page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
 							lst_per_page);
 		for (j = 0; j < page_num; j++) {
@@ -940,18 +964,21 @@ static void free_shared_mem(struct s2io_
 		}
 	}
 
+	for (i = 0; i < nic->config.tx_fifo_num; i++) {
+		if (mac_control->fifos[i].ufo_in_band_v) {
+			nic->mac_control.stats_info->sw_stat.mem_freed
+				+= (config->tx_cfg[i].fifo_len * sizeof(u64));
+			kfree(mac_control->fifos[i].ufo_in_band_v);
+		}
+	}
+
 	if (mac_control->stats_mem) {
+		nic->mac_control.stats_info->sw_stat.mem_freed +=
+			mac_control->stats_mem_sz;
 		pci_free_consistent(nic->pdev,
 				    mac_control->stats_mem_sz,
 				    mac_control->stats_mem,
 				    mac_control->stats_mem_phy);
-		nic->mac_control.stats_info->sw_stat.mem_freed +=
-			mac_control->stats_mem_sz;
-	}
-	if (nic->ufo_in_band_v) {
-		kfree(nic->ufo_in_band_v);
-		nic->mac_control.stats_info->sw_stat.mem_freed
-			+= (ufo_size * sizeof(u64));
 	}
 }
 
@@ -2241,7 +2268,7 @@ static struct sk_buff *s2io_txdl_getskb(
 	u16 j, frg_cnt;
 
 	txds = txdlp;
-	if (txds->Host_Control == (u64)(long)nic->ufo_in_band_v) {
+	if (txds->Host_Control == (u64)(long)fifo_data->ufo_in_band_v) {
 		pci_unmap_single(nic->pdev, (dma_addr_t)
 			txds->Buffer_Pointer, sizeof(u64),
 			PCI_DMA_TODEVICE);
@@ -2296,6 +2323,8 @@ static void free_tx_buffers(struct s2io_
 	config = &nic->config;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
+		unsigned long flags;
+		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags);
 		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
 			txdp = (struct TxD *) \
 			mac_control->fifos[i].list_info[j].list_virt_addr;
@@ -2312,6 +2341,7 @@ static void free_tx_buffers(struct s2io_
 			  dev->name, cnt, i);
 		mac_control->fifos[i].tx_curr_get_info.offset = 0;
 		mac_control->fifos[i].tx_curr_put_info.offset = 0;
+		spin_unlock_irqrestore(&mac_control->fifos[i].tx_lock, flags);
 	}
 }
 
@@ -2935,8 +2965,12 @@ static void tx_intr_handler(struct fifo_
 	struct tx_curr_get_info get_info, put_info;
 	struct sk_buff *skb;
 	struct TxD *txdlp;
+	unsigned long flags = 0;
 	u8 err_mask;
 
+	if (!spin_trylock_irqsave(&fifo_data->tx_lock, flags))
+			return;
+
 	get_info = fifo_data->tx_curr_get_info;
 	memcpy(&put_info, &fifo_data->tx_curr_put_info, sizeof(put_info));
 	txdlp = (struct TxD *) fifo_data->list_info[get_info.offset].
@@ -2985,6 +3019,7 @@ static void tx_intr_handler(struct fifo_
 
 		skb = s2io_txdl_getskb(fifo_data, txdlp, get_info.offset);
 		if (skb == NULL) {
+			spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
 			DBG_PRINT(ERR_DBG, "%s: Null skb ",
 			__FUNCTION__);
 			DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
@@ -3005,10 +3040,10 @@ static void tx_intr_handler(struct fifo_
 		    get_info.offset;
 	}
 
-	spin_lock(&nic->tx_lock);
 	if (netif_queue_stopped(dev))
 		netif_wake_queue(dev);
-	spin_unlock(&nic->tx_lock);
+
+	spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
 }
 
 /**
@@ -3972,9 +4007,10 @@ static int s2io_xmit(struct sk_buff *skb
 	register u64 val64;
 	struct TxD *txdp;
 	struct TxFIFO_element __iomem *tx_fifo;
-	unsigned long flags;
+	unsigned long flags = 0;
 	u16 vlan_tag = 0;
 	int vlan_priority = 0;
+	struct fifo_info *fifo = NULL;
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int offload_type;
@@ -3989,13 +4025,11 @@ static int s2io_xmit(struct sk_buff *skb
 		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
 		dev_kfree_skb_any(skb);
 		return 0;
-}
+	}
 
-	spin_lock_irqsave(&sp->tx_lock, flags);
 	if (!is_s2io_card_up(sp)) {
 		DBG_PRINT(TX_DBG, "%s: Card going down for reset\n",
 			  dev->name);
-		spin_unlock_irqrestore(&sp->tx_lock, flags);
 		dev_kfree_skb(skb);
 		return 0;
 	}
@@ -4008,19 +4042,20 @@ static int s2io_xmit(struct sk_buff *skb
 		queue = config->fifo_mapping[vlan_priority];
 	}
 
-	put_off = (u16) mac_control->fifos[queue].tx_curr_put_info.offset;
-	get_off = (u16) mac_control->fifos[queue].tx_curr_get_info.offset;
-	txdp = (struct TxD *) mac_control->fifos[queue].list_info[put_off].
-		list_virt_addr;
+	fifo = &mac_control->fifos[queue];
+	spin_lock_irqsave(&fifo->tx_lock, flags);
+	put_off = (u16) fifo->tx_curr_put_info.offset;
+	get_off = (u16) fifo->tx_curr_get_info.offset;
+	txdp = (struct TxD *) fifo->list_info[put_off].list_virt_addr;
 
-	queue_len = mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
+	queue_len = fifo->tx_curr_put_info.fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (txdp->Host_Control ||
 		   ((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
 		DBG_PRINT(TX_DBG, "Error in xmit, No free TXDs.\n");
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
-		spin_unlock_irqrestore(&sp->tx_lock, flags);
+		spin_unlock_irqrestore(&fifo->tx_lock, flags);
 		return 0;
 	}
 
@@ -4036,7 +4071,7 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 	txdp->Control_1 |= TXD_GATHER_CODE_FIRST;
 	txdp->Control_1 |= TXD_LIST_OWN_XENA;
-	txdp->Control_2 |= config->tx_intr_type;
+	txdp->Control_2 |= TXD_INT_NUMBER(fifo->fifo_no);
 
 	if (sp->vlgrp && vlan_tx_tag_present(skb)) {
 		txdp->Control_2 |= TXD_VLAN_ENABLE;
@@ -4053,15 +4088,15 @@ static int s2io_xmit(struct sk_buff *skb
 		txdp->Control_1 |= TXD_UFO_MSS(ufo_size);
 		txdp->Control_1 |= TXD_BUFFER0_SIZE(8);
 #ifdef __BIG_ENDIAN
-		sp->ufo_in_band_v[put_off] =
+		fifo->ufo_in_band_v[put_off] =
 				(u64)skb_shinfo(skb)->ip6_frag_id;
 #else
-		sp->ufo_in_band_v[put_off] =
+		fifo->ufo_in_band_v[put_off] =
 				(u64)skb_shinfo(skb)->ip6_frag_id << 32;
 #endif
-		txdp->Host_Control = (unsigned long)sp->ufo_in_band_v;
+		txdp->Host_Control = (unsigned long)fifo->ufo_in_band_v;
 		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
-					sp->ufo_in_band_v,
+					fifo->ufo_in_band_v,
 					sizeof(u64), PCI_DMA_TODEVICE);
 		if((txdp->Buffer_Pointer == 0) ||
 			(txdp->Buffer_Pointer == DMA_ERROR_CODE))
@@ -4101,7 +4136,7 @@ static int s2io_xmit(struct sk_buff *skb
 		frg_cnt++; /* as Txd0 was used for inband header */
 
 	tx_fifo = mac_control->tx_FIFO_start[queue];
-	val64 = mac_control->fifos[queue].list_info[put_off].list_phy_addr;
+	val64 = fifo->list_info[put_off].list_phy_addr;
 	writeq(val64, &tx_fifo->TxDL_Pointer);
 
 	val64 = (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
@@ -4114,9 +4149,9 @@ static int s2io_xmit(struct sk_buff *skb
 	mmiowb();
 
 	put_off++;
-	if (put_off == mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1)
+	if (put_off == fifo->tx_curr_put_info.fifo_len + 1)
 		put_off = 0;
-	mac_control->fifos[queue].tx_curr_put_info.offset = put_off;
+	fifo->tx_curr_put_info.offset = put_off;
 
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
@@ -4128,7 +4163,7 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 	mac_control->stats_info->sw_stat.mem_allocated += skb->truesize;
 	dev->trans_start = jiffies;
-	spin_unlock_irqrestore(&sp->tx_lock, flags);
+	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
 	return 0;
 pci_map_failed:
@@ -4136,7 +4171,7 @@ pci_map_failed:
 	netif_stop_queue(dev);
 	stats->mem_freed += skb->truesize;
 	dev_kfree_skb(skb);
-	spin_unlock_irqrestore(&sp->tx_lock, flags);
+	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 	return 0;
 }
 
@@ -6996,10 +7031,8 @@ static void do_s2io_card_down(struct s2i
 	if (do_io)
 		s2io_reset(sp);
 
-	spin_lock_irqsave(&sp->tx_lock, flags);
 	/* Free all Tx buffers */
 	free_tx_buffers(sp);
-	spin_unlock_irqrestore(&sp->tx_lock, flags);
 
 	/* Free all Rx buffers */
 	spin_lock_irqsave(&sp->rx_lock, flags);
@@ -7458,12 +7491,18 @@ static void s2io_init_pci(struct s2io_ni
 
 static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type)
 {
-	if ( tx_fifo_num > 8) {
-		DBG_PRINT(ERR_DBG, "s2io: Requested number of Tx fifos not "
-			 "supported\n");
-		DBG_PRINT(ERR_DBG, "s2io: Default to 8 Tx fifos\n");
-		tx_fifo_num = 8;
+	if ((tx_fifo_num > MAX_TX_FIFOS) ||
+		(tx_fifo_num < FIFO_DEFAULT_NUM)) {
+		DBG_PRINT(ERR_DBG, "s2io: Requested number of tx fifos "
+			"(%d) not supported\n", tx_fifo_num);
+		tx_fifo_num =
+			((tx_fifo_num > MAX_TX_FIFOS)? MAX_TX_FIFOS :
+			((tx_fifo_num < FIFO_DEFAULT_NUM) ? FIFO_DEFAULT_NUM :
+			tx_fifo_num));
+		DBG_PRINT(ERR_DBG, "s2io: Default to %d ", tx_fifo_num);
+		DBG_PRINT(ERR_DBG, "tx fifos\n");
 	}
+
 	if ( rx_ring_num > 8) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested number of Rx rings not "
 			 "supported\n");
@@ -7842,7 +7881,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	sp->state = 0;
 
 	/* Initialize spinlocks */
-	spin_lock_init(&sp->tx_lock);
+	for (i = 0; i < sp->config.tx_fifo_num; i++)
+		spin_lock_init(&mac_control->fifos[i].tx_lock);
 
 	if (!napi)
 		spin_lock_init(&sp->put_lock);
diff -Nurp 2-0-26-10/drivers/net/s2io.h 2-0-26-15-1/drivers/net/s2io.h
--- 2-0-26-10/drivers/net/s2io.h	2007-12-17 22:09:01.000000000 +0530
+++ 2-0-26-15-1/drivers/net/s2io.h	2007-12-17 22:10:58.000000000 +0530
@@ -360,6 +360,8 @@ struct stat_block {
 #define MAX_TX_FIFOS 8
 #define MAX_RX_RINGS 8
 
+#define FIFO_DEFAULT_NUM	1
+
 #define MAX_RX_DESC_1  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 127 )
 #define MAX_RX_DESC_2  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
 #define MAX_RX_DESC_3  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
@@ -719,8 +721,14 @@ struct fifo_info {
 	 */
 	struct tx_curr_get_info tx_curr_get_info;
 
+	/* Per fifo lock */
+	spinlock_t tx_lock;
+
+	/* Per fifo UFO in band structure */
+	u64 *ufo_in_band_v;
+
 	struct s2io_nic *nic;
-};
+} ____cacheline_aligned;
 
 /* Information related to the Tx and Rx FIFOs and Rings of Xena
  * is maintained in this structure.
@@ -848,7 +856,6 @@ struct s2io_nic {
 
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
 
-	spinlock_t tx_lock;
 	spinlock_t put_lock;
 
 #define PROMISC     1
@@ -915,7 +922,6 @@ struct s2io_nic {
 	volatile unsigned long state;
 	spinlock_t	rx_lock;
 	u64		general_int_mask;
-	u64 *ufo_in_band_v;
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
 	u8  serial_num[VPD_STRING_LEN];



