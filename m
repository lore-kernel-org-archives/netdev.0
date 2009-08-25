From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/9] s2io.c: Shorten code line length by using intermediate pointers
Date: Mon, 24 Aug 2009 20:29:41 -0700
Message-ID: <11b2dbc0b920eecb1b89f9788a68f33b0faba563.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1352 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326AbZHYDjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 23:39:04 -0400
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Repeated variable use and line wrapping is hard to read.
Use temp variables instead of direct references.

struct fifo_info *fifo = &mac_control->fifos[i];
struct ring_info *ring = &mac_control->rings[i];
struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
struct rx_ring_config *rx_cfg = &config->rx_cfg[i];

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |  393 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 224 insertions(+), 169 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 07e95e9..b6bd3c8 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -364,13 +364,19 @@ static void s2io_vlan_rx_register(struct net_device *dev,
 	struct mac_info *mac_control = &nic->mac_control;
 	struct config_param *config = &nic->config;
 
-	for (i = 0; i < config->tx_fifo_num; i++)
-		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags[i]);
+	for (i = 0; i < config->tx_fifo_num; i++) {
+		struct fifo_info *fifo = &mac_control->fifos[i];
+
+		spin_lock_irqsave(&fifo->tx_lock, flags[i]);
+	}
 
 	nic->vlgrp = grp;
-	for (i = config->tx_fifo_num - 1; i >= 0; i--)
-		spin_unlock_irqrestore(&mac_control->fifos[i].tx_lock,
-				flags[i]);
+
+	for (i = config->tx_fifo_num - 1; i >= 0; i--) {
+		struct fifo_info *fifo = &mac_control->fifos[i];
+
+		spin_unlock_irqrestore(&fifo->tx_lock, flags[i]);
+	}
 }
 
 /* Unregister the vlan */
@@ -382,15 +388,20 @@ static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	struct mac_info *mac_control = &nic->mac_control;
 	struct config_param *config = &nic->config;
 
-	for (i = 0; i < config->tx_fifo_num; i++)
-		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags[i]);
+	for (i = 0; i < config->tx_fifo_num; i++) {
+		struct fifo_info *fifo = &mac_control->fifos[i];
+
+		spin_lock_irqsave(&fifo->tx_lock, flags[i]);
+	}
 
 	if (nic->vlgrp)
 		vlan_group_set_device(nic->vlgrp, vid, NULL);
 
-	for (i = config->tx_fifo_num - 1; i >= 0; i--)
-		spin_unlock_irqrestore(&mac_control->fifos[i].tx_lock,
-			flags[i]);
+	for (i = config->tx_fifo_num - 1; i >= 0; i--) {
+		struct fifo_info *fifo = &mac_control->fifos[i];
+
+		spin_unlock_irqrestore(&fifo->tx_lock, flags[i]);
+	}
 }
 
 /*
@@ -635,11 +646,12 @@ static int init_shared_mem(struct s2io_nic *nic)
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-
-	/* Allocation and initialization of TXDLs in FIOFs */
+	/* Allocation and initialization of TXDLs in FIFOs */
 	size = 0;
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		size += config->tx_cfg[i].fifo_len;
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		size += tx_cfg->fifo_len;
 	}
 	if (size > MAX_AVAILABLE_TXDS) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested TxDs too high, ");
@@ -649,7 +661,9 @@ static int init_shared_mem(struct s2io_nic *nic)
 
 	size = 0;
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		size = config->tx_cfg[i].fifo_len;
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		size = tx_cfg->fifo_len;
 		/*
 		 * Legal values are from 2 to 8192
 		 */
@@ -666,11 +680,13 @@ static int init_shared_mem(struct s2io_nic *nic)
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		int fifo_len = config->tx_cfg[i].fifo_len;
+		struct fifo_info *fifo = &mac_control->fifos[i];
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+		int fifo_len = tx_cfg->fifo_len;
 		int list_holder_size = fifo_len * sizeof(struct list_info_hold);
-		mac_control->fifos[i].list_info = kzalloc(list_holder_size,
-							  GFP_KERNEL);
-		if (!mac_control->fifos[i].list_info) {
+
+		fifo->list_info = kzalloc(list_holder_size, GFP_KERNEL);
+		if (!fifo->list_info) {
 			DBG_PRINT(INFO_DBG,
 				  "Malloc failed for list_info\n");
 			return -ENOMEM;
@@ -680,16 +696,17 @@ static int init_shared_mem(struct s2io_nic *nic)
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
 						lst_per_page);
-		mac_control->fifos[i].tx_curr_put_info.offset = 0;
-		mac_control->fifos[i].tx_curr_put_info.fifo_len =
-		    config->tx_cfg[i].fifo_len - 1;
-		mac_control->fifos[i].tx_curr_get_info.offset = 0;
-		mac_control->fifos[i].tx_curr_get_info.fifo_len =
-		    config->tx_cfg[i].fifo_len - 1;
-		mac_control->fifos[i].fifo_no = i;
-		mac_control->fifos[i].nic = nic;
-		mac_control->fifos[i].max_txds = MAX_SKB_FRAGS + 2;
-		mac_control->fifos[i].dev = dev;
+		struct fifo_info *fifo = &mac_control->fifos[i];
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		fifo->tx_curr_put_info.offset = 0;
+		fifo->tx_curr_put_info.fifo_len = tx_cfg->fifo_len - 1;
+		fifo->tx_curr_get_info.offset = 0;
+		fifo->tx_curr_get_info.fifo_len = tx_cfg->fifo_len - 1;
+		fifo->fifo_no = i;
+		fifo->nic = nic;
+		fifo->max_txds = MAX_SKB_FRAGS + 2;
+		fifo->dev = dev;
 
 		for (j = 0; j < page_num; j++) {
 			int k = 0;
@@ -726,11 +743,11 @@ static int init_shared_mem(struct s2io_nic *nic)
 			}
 			while (k < lst_per_page) {
 				int l = (j * lst_per_page) + k;
-				if (l == config->tx_cfg[i].fifo_len)
+				if (l == tx_cfg->fifo_len)
 					break;
-				mac_control->fifos[i].list_info[l].list_virt_addr =
+				fifo->list_info[l].list_virt_addr =
 				    tmp_v + (k * lst_size);
-				mac_control->fifos[i].list_info[l].list_phy_addr =
+				fifo->list_info[l].list_phy_addr =
 				    tmp_p + (k * lst_size);
 				k++;
 			}
@@ -738,10 +755,12 @@ static int init_shared_mem(struct s2io_nic *nic)
 	}
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		size = config->tx_cfg[i].fifo_len;
-		mac_control->fifos[i].ufo_in_band_v
-			= kcalloc(size, sizeof(u64), GFP_KERNEL);
-		if (!mac_control->fifos[i].ufo_in_band_v)
+		struct fifo_info *fifo = &mac_control->fifos[i];
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		size = tx_cfg->fifo_len;
+		fifo->ufo_in_band_v = kcalloc(size, sizeof(u64), GFP_KERNEL);
+		if (!fifo->ufo_in_band_v)
 			return -ENOMEM;
 		mem_allocated += (size * sizeof(u64));
 	}
@@ -749,20 +768,19 @@ static int init_shared_mem(struct s2io_nic *nic)
 	/* Allocation and initialization of RXDs in Rings */
 	size = 0;
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (config->rx_cfg[i].num_rxd %
-		    (rxd_count[nic->rxd_mode] + 1)) {
+		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+		struct ring_info *ring = &mac_control->rings[i];
+
+		if (rx_cfg->num_rxd % (rxd_count[nic->rxd_mode] + 1)) {
 			DBG_PRINT(ERR_DBG, "%s: RxD count of ", dev->name);
-			DBG_PRINT(ERR_DBG, "Ring%d is not a multiple of ",
-				  i);
+			DBG_PRINT(ERR_DBG, "Ring%d is not a multiple of ", i);
 			DBG_PRINT(ERR_DBG, "RxDs per Block");
 			return FAILURE;
 		}
-		size += config->rx_cfg[i].num_rxd;
-		mac_control->rings[i].block_count =
-			config->rx_cfg[i].num_rxd /
+		size += rx_cfg->num_rxd;
+		ring->block_count = rx_cfg->num_rxd /
 			(rxd_count[nic->rxd_mode] + 1 );
-		mac_control->rings[i].pkt_cnt = config->rx_cfg[i].num_rxd -
-			mac_control->rings[i].block_count;
+		ring->pkt_cnt = rx_cfg->num_rxd - ring->block_count;
 	}
 	if (nic->rxd_mode == RXD_MODE_1)
 		size = (size * (sizeof(struct RxD1)));
@@ -770,26 +788,26 @@ static int init_shared_mem(struct s2io_nic *nic)
 		size = (size * (sizeof(struct RxD3)));
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		mac_control->rings[i].rx_curr_get_info.block_index = 0;
-		mac_control->rings[i].rx_curr_get_info.offset = 0;
-		mac_control->rings[i].rx_curr_get_info.ring_len =
-		    config->rx_cfg[i].num_rxd - 1;
-		mac_control->rings[i].rx_curr_put_info.block_index = 0;
-		mac_control->rings[i].rx_curr_put_info.offset = 0;
-		mac_control->rings[i].rx_curr_put_info.ring_len =
-		    config->rx_cfg[i].num_rxd - 1;
-		mac_control->rings[i].nic = nic;
-		mac_control->rings[i].ring_no = i;
-		mac_control->rings[i].lro = lro_enable;
-
-		blk_cnt = config->rx_cfg[i].num_rxd /
-				(rxd_count[nic->rxd_mode] + 1);
+		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+		struct ring_info *ring = &mac_control->rings[i];
+
+		ring->rx_curr_get_info.block_index = 0;
+		ring->rx_curr_get_info.offset = 0;
+		ring->rx_curr_get_info.ring_len = rx_cfg->num_rxd - 1;
+		ring->rx_curr_put_info.block_index = 0;
+		ring->rx_curr_put_info.offset = 0;
+		ring->rx_curr_put_info.ring_len = rx_cfg->num_rxd - 1;
+		ring->nic = nic;
+		ring->ring_no = i;
+		ring->lro = lro_enable;
+
+		blk_cnt = rx_cfg->num_rxd / (rxd_count[nic->rxd_mode] + 1);
 		/*  Allocating all the Rx blocks */
 		for (j = 0; j < blk_cnt; j++) {
 			struct rx_block_info *rx_blocks;
 			int l;
 
-			rx_blocks = &mac_control->rings[i].rx_blocks[j];
+			rx_blocks = &ring->rx_blocks[j];
 			size = SIZE_OF_BLOCK; //size is always page size
 			tmp_v_addr = pci_alloc_consistent(nic->pdev, size,
 							  &tmp_p_addr);
@@ -825,16 +843,11 @@ static int init_shared_mem(struct s2io_nic *nic)
 		}
 		/* Interlinking all Rx Blocks */
 		for (j = 0; j < blk_cnt; j++) {
-			tmp_v_addr =
-				mac_control->rings[i].rx_blocks[j].block_virt_addr;
-			tmp_v_addr_next =
-				mac_control->rings[i].rx_blocks[(j + 1) %
-					      blk_cnt].block_virt_addr;
-			tmp_p_addr =
-				mac_control->rings[i].rx_blocks[j].block_dma_addr;
-			tmp_p_addr_next =
-				mac_control->rings[i].rx_blocks[(j + 1) %
-					      blk_cnt].block_dma_addr;
+			int next = (j + 1) % blk_cnt;
+			tmp_v_addr = ring->rx_blocks[j].block_virt_addr;
+			tmp_v_addr_next = ring->rx_blocks[next].block_virt_addr;
+			tmp_p_addr = ring->rx_blocks[j].block_dma_addr;
+			tmp_p_addr_next = ring->rx_blocks[next].block_dma_addr;
 
 			pre_rxd_blk = (struct RxD_block *) tmp_v_addr;
 			pre_rxd_blk->reserved_2_pNext_RxD_block =
@@ -849,26 +862,28 @@ static int init_shared_mem(struct s2io_nic *nic)
 		 * and the buffers as well.
 		 */
 		for (i = 0; i < config->rx_ring_num; i++) {
-			blk_cnt = config->rx_cfg[i].num_rxd /
-			   (rxd_count[nic->rxd_mode]+ 1);
-			mac_control->rings[i].ba =
-				kmalloc((sizeof(struct buffAdd *) * blk_cnt),
-				     GFP_KERNEL);
-			if (!mac_control->rings[i].ba)
+			struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+			struct ring_info *ring = &mac_control->rings[i];
+
+			blk_cnt = rx_cfg->num_rxd /
+				(rxd_count[nic->rxd_mode]+ 1);
+			ring->ba = kmalloc((sizeof(struct buffAdd *) * blk_cnt),
+					   GFP_KERNEL);
+			if (!ring->ba)
 				return -ENOMEM;
 			mem_allocated +=(sizeof(struct buffAdd *) * blk_cnt);
 			for (j = 0; j < blk_cnt; j++) {
 				int k = 0;
-				mac_control->rings[i].ba[j] =
+				ring->ba[j] =
 					kmalloc((sizeof(struct buffAdd) *
 						(rxd_count[nic->rxd_mode] + 1)),
 						GFP_KERNEL);
-				if (!mac_control->rings[i].ba[j])
+				if (!ring->ba[j])
 					return -ENOMEM;
 				mem_allocated += (sizeof(struct buffAdd) *  \
 					(rxd_count[nic->rxd_mode] + 1));
 				while (k != rxd_count[nic->rxd_mode]) {
-					ba = &mac_control->rings[i].ba[j][k];
+					ba = &ring->ba[j][k];
 
 					ba->ba_0_org = (void *) kmalloc
 					    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
@@ -952,22 +967,23 @@ static void free_shared_mem(struct s2io_nic *nic)
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
-							lst_per_page);
+		struct fifo_info *fifo = &mac_control->fifos[i];
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		page_num = TXD_MEM_PAGE_CNT(tx_cfg->fifo_len, lst_per_page);
 		for (j = 0; j < page_num; j++) {
 			int mem_blks = (j * lst_per_page);
-			if (!mac_control->fifos[i].list_info)
+			struct list_info_hold *fli;
+
+			if (!fifo->list_info)
 				return;
-			if (!mac_control->fifos[i].list_info[mem_blks].
-				 list_virt_addr)
+
+			fli = &fifo->list_info[mem_blks];
+			if (!fli->list_virt_addr)
 				break;
 			pci_free_consistent(nic->pdev, PAGE_SIZE,
-					    mac_control->fifos[i].
-					    list_info[mem_blks].
-					    list_virt_addr,
-					    mac_control->fifos[i].
-					    list_info[mem_blks].
-					    list_phy_addr);
+					    fli->list_virt_addr,
+					    fli->list_phy_addr);
 			nic->mac_control.stats_info->sw_stat.mem_freed
 						+= PAGE_SIZE;
 		}
@@ -986,25 +1002,25 @@ static void free_shared_mem(struct s2io_nic *nic)
 			nic->mac_control.stats_info->sw_stat.mem_freed
 						+= PAGE_SIZE;
 		}
-		kfree(mac_control->fifos[i].list_info);
+		kfree(fifo->list_info);
 		nic->mac_control.stats_info->sw_stat.mem_freed +=
 		(nic->config.tx_cfg[i].fifo_len *sizeof(struct list_info_hold));
 	}
 
 	size = SIZE_OF_BLOCK;
 	for (i = 0; i < config->rx_ring_num; i++) {
-		blk_cnt = mac_control->rings[i].block_count;
+		struct ring_info *ring = &mac_control->rings[i];
+
+		blk_cnt = ring->block_count;
 		for (j = 0; j < blk_cnt; j++) {
-			tmp_v_addr = mac_control->rings[i].rx_blocks[j].
-				block_virt_addr;
-			tmp_p_addr = mac_control->rings[i].rx_blocks[j].
-				block_dma_addr;
+			tmp_v_addr = ring->rx_blocks[j].block_virt_addr;
+			tmp_p_addr = ring->rx_blocks[j].block_dma_addr;
 			if (tmp_v_addr == NULL)
 				break;
 			pci_free_consistent(nic->pdev, size,
 					    tmp_v_addr, tmp_p_addr);
 			nic->mac_control.stats_info->sw_stat.mem_freed += size;
-			kfree(mac_control->rings[i].rx_blocks[j].rxds);
+			kfree(ring->rx_blocks[j].rxds);
 			nic->mac_control.stats_info->sw_stat.mem_freed +=
 			( sizeof(struct rxd_info)* rxd_count[nic->rxd_mode]);
 		}
@@ -1013,15 +1029,17 @@ static void free_shared_mem(struct s2io_nic *nic)
 	if (nic->rxd_mode == RXD_MODE_3B) {
 		/* Freeing buffer storage addresses in 2BUFF mode. */
 		for (i = 0; i < config->rx_ring_num; i++) {
-			blk_cnt = config->rx_cfg[i].num_rxd /
-			    (rxd_count[nic->rxd_mode] + 1);
+			struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+			struct ring_info *ring = &mac_control->rings[i];
+
+			blk_cnt = rx_cfg->num_rxd /
+				(rxd_count[nic->rxd_mode] + 1);
 			for (j = 0; j < blk_cnt; j++) {
 				int k = 0;
-				if (!mac_control->rings[i].ba[j])
+				if (!ring->ba[j])
 					continue;
 				while (k != rxd_count[nic->rxd_mode]) {
-					struct buffAdd *ba =
-						&mac_control->rings[i].ba[j][k];
+					struct buffAdd *ba = &ring->ba[j][k];
 					kfree(ba->ba_0_org);
 					nic->mac_control.stats_info->sw_stat.\
 					mem_freed += (BUF0_LEN + ALIGN_SIZE);
@@ -1030,22 +1048,25 @@ static void free_shared_mem(struct s2io_nic *nic)
 					mem_freed += (BUF1_LEN + ALIGN_SIZE);
 					k++;
 				}
-				kfree(mac_control->rings[i].ba[j]);
+				kfree(ring->ba[j]);
 				nic->mac_control.stats_info->sw_stat.mem_freed +=
 					(sizeof(struct buffAdd) *
 					(rxd_count[nic->rxd_mode] + 1));
 			}
-			kfree(mac_control->rings[i].ba);
+			kfree(ring->ba);
 			nic->mac_control.stats_info->sw_stat.mem_freed +=
 			(sizeof(struct buffAdd *) * blk_cnt);
 		}
 	}
 
 	for (i = 0; i < nic->config.tx_fifo_num; i++) {
-		if (mac_control->fifos[i].ufo_in_band_v) {
+		struct fifo_info *fifo = &mac_control->fifos[i];
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		if (fifo->ufo_in_band_v) {
 			nic->mac_control.stats_info->sw_stat.mem_freed
-				+= (config->tx_cfg[i].fifo_len * sizeof(u64));
-			kfree(mac_control->fifos[i].ufo_in_band_v);
+				+= (tx_cfg->fifo_len * sizeof(u64));
+			kfree(fifo->ufo_in_band_v);
 		}
 	}
 
@@ -1339,10 +1360,10 @@ static int init_nic(struct s2io_nic *nic)
 
 
 	for (i = 0, j = 0; i < config->tx_fifo_num; i++) {
-		val64 |=
-		    vBIT(config->tx_cfg[i].fifo_len - 1, ((j * 32) + 19),
-			 13) | vBIT(config->tx_cfg[i].fifo_priority,
-				    ((j * 32) + 5), 3);
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		val64 |= vBIT(tx_cfg->fifo_len - 1, ((j * 32) + 19), 13) |
+			vBIT(tx_cfg->fifo_priority, ((j * 32) + 5), 3);
 
 		if (i == (config->tx_fifo_num - 1)) {
 			if (i % 2 == 0)
@@ -1400,9 +1421,9 @@ static int init_nic(struct s2io_nic *nic)
 	/* Rx DMA intialization. */
 	val64 = 0;
 	for (i = 0; i < config->rx_ring_num; i++) {
-		val64 |=
-		    vBIT(config->rx_cfg[i].ring_priority, (5 + (i * 8)),
-			 3);
+		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+
+		val64 |= vBIT(rx_cfg->ring_priority, (5 + (i * 8)), 3);
 	}
 	writeq(val64, &bar0->rx_queue_priority);
 
@@ -2276,7 +2297,9 @@ static int start_nic(struct s2io_nic *nic)
 
 	/*  PRC Initialization and configuration */
 	for (i = 0; i < config->rx_ring_num; i++) {
-		writeq((u64) mac_control->rings[i].rx_blocks[0].block_dma_addr,
+		struct ring_info *ring = &mac_control->rings[i];
+
+		writeq((u64) ring->rx_blocks[0].block_dma_addr,
 		       &bar0->prc_rxd0_n[i]);
 
 		val64 = readq(&bar0->prc_ctrl_n[i]);
@@ -2434,11 +2457,13 @@ static void free_tx_buffers(struct s2io_nic *nic)
 	config = &nic->config;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+		struct fifo_info *fifo = &mac_control->fifos[i];
 		unsigned long flags;
-		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags);
-		for (j = 0; j < config->tx_cfg[i].fifo_len; j++) {
-			txdp = (struct TxD *) \
-			mac_control->fifos[i].list_info[j].list_virt_addr;
+
+		spin_lock_irqsave(&fifo->tx_lock, flags);
+		for (j = 0; j < tx_cfg->fifo_len; j++) {
+			txdp = (struct TxD *)fifo->list_info[j].list_virt_addr;
 			skb = s2io_txdl_getskb(&mac_control->fifos[i], txdp, j);
 			if (skb) {
 				nic->mac_control.stats_info->sw_stat.mem_freed
@@ -2450,9 +2475,9 @@ static void free_tx_buffers(struct s2io_nic *nic)
 		DBG_PRINT(INTR_DBG,
 			  "%s:forcibly freeing %d skbs on FIFO%d\n",
 			  dev->name, cnt, i);
-		mac_control->fifos[i].tx_curr_get_info.offset = 0;
-		mac_control->fifos[i].tx_curr_put_info.offset = 0;
-		spin_unlock_irqrestore(&mac_control->fifos[i].tx_lock, flags);
+		fifo->tx_curr_get_info.offset = 0;
+		fifo->tx_curr_put_info.offset = 0;
+		spin_unlock_irqrestore(&fifo->tx_lock, flags);
 	}
 }
 
@@ -2795,14 +2820,16 @@ static void free_rx_buffers(struct s2io_nic *sp)
 	config = &sp->config;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
+		struct ring_info *ring = &mac_control->rings[i];
+
 		for (blk = 0; blk < rx_ring_sz[i]; blk++)
 			free_rxd_blk(sp,i,blk);
 
-		mac_control->rings[i].rx_curr_put_info.block_index = 0;
-		mac_control->rings[i].rx_curr_get_info.block_index = 0;
-		mac_control->rings[i].rx_curr_put_info.offset = 0;
-		mac_control->rings[i].rx_curr_get_info.offset = 0;
-		mac_control->rings[i].rx_bufs_left = 0;
+		ring->rx_curr_put_info.block_index = 0;
+		ring->rx_curr_get_info.block_index = 0;
+		ring->rx_curr_put_info.offset = 0;
+		ring->rx_curr_get_info.offset = 0;
+		ring->rx_bufs_left = 0;
 		DBG_PRINT(INIT_DBG, "%s:Freed 0x%x Rx Buffers on ring%d\n",
 			  dev->name, buf_cnt, i);
 	}
@@ -2866,7 +2893,6 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 static int s2io_poll_inta(struct napi_struct *napi, int budget)
 {
 	struct s2io_nic *nic = container_of(napi, struct s2io_nic, napi);
-	struct ring_info *ring;
 	struct config_param *config;
 	struct mac_info *mac_control;
 	int pkts_processed = 0;
@@ -2881,7 +2907,7 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 		return 0;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		ring = &mac_control->rings[i];
+		struct ring_info *ring = &mac_control->rings[i];
 		ring_pkts_processed = rx_intr_handler(ring, budget);
 		s2io_chk_rx_buffers(nic, ring);
 		pkts_processed += ring_pkts_processed;
@@ -2936,12 +2962,16 @@ static void s2io_netpoll(struct net_device *dev)
 		tx_intr_handler(&mac_control->fifos[i]);
 
 	/* check for received packet and indicate up to network */
-	for (i = 0; i < config->rx_ring_num; i++)
-		rx_intr_handler(&mac_control->rings[i], 0);
+	for (i = 0; i < config->rx_ring_num; i++) {
+		struct ring_info *ring = &mac_control->rings[i];
+
+		rx_intr_handler(ring, 0);
+	}
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(nic, &mac_control->rings[i], 0) ==
-				-ENOMEM) {
+		struct ring_info *ring = &mac_control->rings[i];
+
+		if (fill_rx_buffers(nic, ring, 0) == -ENOMEM) {
 			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
 			break;
@@ -4803,8 +4833,11 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 			if (reason & GEN_INTR_RXTRAFFIC)
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
 
-			for (i = 0; i < config->rx_ring_num; i++)
-				rx_intr_handler(&mac_control->rings[i], 0);
+			for (i = 0; i < config->rx_ring_num; i++) {
+				struct ring_info *ring = &mac_control->rings[i];
+
+				rx_intr_handler(ring, 0);
+			}
 		}
 
 		/*
@@ -4825,8 +4858,11 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 		 * Reallocate the buffers from the interrupt handler itself.
 		 */
 		if (!config->napi) {
-			for (i = 0; i < config->rx_ring_num; i++)
-				s2io_chk_rx_buffers(sp, &mac_control->rings[i]);
+			for (i = 0; i < config->rx_ring_num; i++) {
+				struct ring_info *ring = &mac_control->rings[i];
+
+				s2io_chk_rx_buffers(sp, ring);
+			}
 		}
 		writeq(sp->general_int_mask, &bar0->general_int_mask);
 		readl(&bar0->general_int_status);
@@ -4923,8 +4959,10 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 	/* collect per-ring rx_packets and rx_bytes */
 	dev->stats.rx_packets = dev->stats.rx_bytes = 0;
 	for (i = 0; i < config->rx_ring_num; i++) {
-		dev->stats.rx_packets += mac_control->rings[i].rx_packets;
-		dev->stats.rx_bytes += mac_control->rings[i].rx_bytes;
+		struct ring_info *ring = &mac_control->rings[i];
+
+		dev->stats.rx_packets += ring->rx_packets;
+		dev->stats.rx_bytes += ring->rx_bytes;
 	}
 
 	return (&dev->stats);
@@ -6974,15 +7012,16 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 		size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		blk_cnt = config->rx_cfg[i].num_rxd /
-			(rxd_count[sp->rxd_mode] +1);
+		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+		struct ring_info *ring = &mac_control->rings[i];
+
+		blk_cnt = rx_cfg->num_rxd / (rxd_count[sp->rxd_mode] +1);
 
 		for (j = 0; j < blk_cnt; j++) {
 			for (k = 0; k < rxd_count[sp->rxd_mode]; k++) {
-				rxdp = mac_control->rings[i].
-					rx_blocks[j].rxds[k].virt_addr;
+				rxdp = ring-> rx_blocks[j].rxds[k].virt_addr;
 				if(sp->rxd_mode == RXD_MODE_3B)
-					ba = &mac_control->rings[i].ba[j][k];
+					ba = &ring->ba[j][k];
 				if (set_rxd_buffer_pointer(sp, rxdp, ba,
 						       &skb,(u64 *)&temp0_64,
 						       (u64 *)&temp1_64,
@@ -7205,8 +7244,10 @@ static int s2io_card_up(struct s2io_nic * sp)
 	config = &sp->config;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		mac_control->rings[i].mtu = dev->mtu;
-		ret = fill_rx_buffers(sp, &mac_control->rings[i], 1);
+		struct ring_info *ring = &mac_control->rings[i];
+
+		ring->mtu = dev->mtu;
+		ret = fill_rx_buffers(sp, ring, 1);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
 				  dev->name);
@@ -7215,7 +7256,7 @@ static int s2io_card_up(struct s2io_nic * sp)
 			return -ENOMEM;
 		}
 		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
-			  mac_control->rings[i].rx_bufs_left);
+			  ring->rx_bufs_left);
 	}
 
 	/* Initialise napi */
@@ -7875,8 +7916,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	config->multiq = dev_multiq;
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		config->tx_cfg[i].fifo_len = tx_fifo_len[i];
-		config->tx_cfg[i].fifo_priority = i;
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		tx_cfg->fifo_len = tx_fifo_len[i];
+		tx_cfg->fifo_priority = i;
 	}
 
 	/* mapping the QoS priority to the configured fifos */
@@ -7890,9 +7933,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	config->tx_intr_type = TXD_INT_TYPE_UTILZ;
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		config->tx_cfg[i].f_no_snoop =
-		    (NO_SNOOP_TXD | NO_SNOOP_TXD_BUFFER);
-		if (config->tx_cfg[i].fifo_len < 65) {
+		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
+
+		tx_cfg->f_no_snoop = (NO_SNOOP_TXD | NO_SNOOP_TXD_BUFFER);
+		if (tx_cfg->fifo_len < 65) {
 			config->tx_intr_type = TXD_INT_TYPE_PER_LIST;
 			break;
 		}
@@ -7903,20 +7947,23 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	/* Rx side parameters. */
 	config->rx_ring_num = rx_ring_num;
 	for (i = 0; i < config->rx_ring_num; i++) {
-		config->rx_cfg[i].num_rxd = rx_ring_sz[i] *
-		    (rxd_count[sp->rxd_mode] + 1);
-		config->rx_cfg[i].ring_priority = i;
-		mac_control->rings[i].rx_bufs_left = 0;
-		mac_control->rings[i].rxd_mode = sp->rxd_mode;
-		mac_control->rings[i].rxd_count = rxd_count[sp->rxd_mode];
-		mac_control->rings[i].pdev = sp->pdev;
-		mac_control->rings[i].dev = sp->dev;
+		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+		struct ring_info *ring = &mac_control->rings[i];
+
+		rx_cfg->num_rxd = rx_ring_sz[i] * (rxd_count[sp->rxd_mode] + 1);
+		rx_cfg->ring_priority = i;
+		ring->rx_bufs_left = 0;
+		ring->rxd_mode = sp->rxd_mode;
+		ring->rxd_count = rxd_count[sp->rxd_mode];
+		ring->pdev = sp->pdev;
+		ring->dev = sp->dev;
 	}
 
 	for (i = 0; i < rx_ring_num; i++) {
-		config->rx_cfg[i].ring_org = RING_ORG_BUFF1;
-		config->rx_cfg[i].f_no_snoop =
-		    (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);
+		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
+
+		rx_cfg->ring_org = RING_ORG_BUFF1;
+		rx_cfg->f_no_snoop = (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);
 	}
 
 	/*  Setting Mac Control parameters */
@@ -8015,9 +8062,11 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	}
 
 	if (config->intr_type ==  MSI_X) {
-		for (i = 0; i < config->rx_ring_num ; i++)
-			netif_napi_add(dev, &mac_control->rings[i].napi,
-				s2io_poll_msix, 64);
+		for (i = 0; i < config->rx_ring_num ; i++) {
+			struct ring_info *ring = &mac_control->rings[i];
+
+			netif_napi_add(dev, &ring->napi, s2io_poll_msix, 64);
+		}
 	} else {
 		netif_napi_add(dev, &sp->napi, s2io_poll_inta, 64);
 	}
@@ -8089,8 +8138,11 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	sp->state = 0;
 
 	/* Initialize spinlocks */
-	for (i = 0; i < sp->config.tx_fifo_num; i++)
-		spin_lock_init(&mac_control->fifos[i].tx_lock);
+	for (i = 0; i < sp->config.tx_fifo_num; i++) {
+		struct fifo_info *fifo = &mac_control->fifos[i];
+
+		spin_lock_init(&fifo->tx_lock);
+	}
 
 	/*
 	 * SXE-002: Configure link and activity LED to init state
@@ -8165,8 +8217,11 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		    break;
 	}
 	if (sp->config.multiq) {
-		for (i = 0; i < sp->config.tx_fifo_num; i++)
-			mac_control->fifos[i].multiq = config->multiq;
+		for (i = 0; i < sp->config.tx_fifo_num; i++) {
+			struct fifo_info *fifo = &mac_control->fifos[i];
+
+			fifo->multiq = config->multiq;
+		}
 		DBG_PRINT(ERR_DBG, "%s: Multiqueue support enabled\n",
 			dev->name);
 	} else
-- 
1.6.3.1.10.g659a0.dirty

