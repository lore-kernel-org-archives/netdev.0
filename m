From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 8/12] S2io: two buffer mode
Date: Thu, 28 Oct 2004 11:34:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001401c4bd1c$d5e64b30$9810100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>,
        <alicia.pena@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-reply-to: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached is the patch for implementing 2-buffer mode on Rx path.
More description of this mode of operation follows.

On certain systems when a DMA has to happen on an un-aligned memory location performance will take a significant hit. It's standard
practice to offset the Rx buffer address by 2 (as Mac header is 14 bytes) so the IP header starts from an aligned location.
Obviously using a single Rx buffer both cannot be achieved. Thus XFrame supports something called 2 buffer Rx mode, where in the
Rx'ed frame is split into 2 parts, one is the Ethernet header and the other is the Ethernet payload. So now we can allocate proper
aligned memory for both buffers, hence the DMA is not slowed down. Also, the Ethernet payload(starting from L3 header) is on an
aligned location so OS need not have to do un-aligned accesses to process IP header. To achieve this, the kernel function
eth_type_trans functionality has to be partially implemented in the driver itself.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
---
diff -urN vanilla-linux/drivers/net/Kconfig linux-2.6.8.1/drivers/net/Kconfig
--- vanilla-linux/drivers/net/Kconfig	2004-10-06 15:15:04.000000000 -0700
+++ linux-2.6.8.1/drivers/net/Kconfig	2004-10-11 20:06:36.000000000 -0700
@@ -2267,6 +2267,17 @@

 	  If in doubt, say N.

+config 2BUFF_MODE
+	bool "Use 2 Buffer Mode on Rx side."
+	depends on S2IO
+	---help---
+	On enabling the 2 buffer mode, the received frame will be
+	split into 2 parts before being DMA'ed to the hosts memory.
+	The parts are the ethernet header and ethernet payload.
+	This is useful on systems where DMA'ing to to unaligned
+	physical memory loactions comes with a heavy price.
+	If not sure please say N.
+
 endmenu

 source "drivers/net/tokenring/Kconfig"
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-11 21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-12 16:49:27.796331624 -0700
@@ -325,6 +325,10 @@
 	int i, j, blk_cnt;
 	int lst_size, lst_per_page;
 	struct net_device *dev = nic->dev;
+#ifdef CONFIG_2BUFF_MODE
+	u64 tmp;
+	buffAdd_t *ba;
+#endif

 	mac_info_t *mac_control;
 	struct config_param *config;
@@ -425,7 +429,11 @@
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
 		/*  Allocating all the Rx blocks */
 		for (j = 0; j < blk_cnt; j++) {
+#ifndef CONFIG_2BUFF_MODE
 			size = (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
+#else
+			size = SIZE_OF_BLOCK;
+#endif
 			tmp_v_addr = pci_alloc_consistent(nic->pdev, size,
 							  &tmp_p_addr);
 			if (tmp_v_addr == NULL) {
@@ -458,13 +466,60 @@
 			pre_rxd_blk->reserved_1 = END_OF_BLOCK;	/* last RxD
 								 * marker.
 								 */
+#ifndef	CONFIG_2BUFF_MODE
 			pre_rxd_blk->reserved_2_pNext_RxD_block =
 			    (unsigned long) tmp_v_addr_next;
+#endif
 			pre_rxd_blk->pNext_RxD_Blk_physical =
 			    (u64) tmp_p_addr_next;
 		}
 	}

+#ifdef CONFIG_2BUFF_MODE
+	/*
+	 * Allocation of Storages for buffer addresses in 2BUFF mode
+	 * and the buffers as well.
+	 */
+	for (i = 0; i < config->rx_ring_num; i++) {
+		blk_cnt =
+		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+		nic->ba[i] = kmalloc((sizeof(buffAdd_t *) * blk_cnt),
+				     GFP_KERNEL);
+		if (!nic->ba[i])
+			return -ENOMEM;
+		for (j = 0; j < blk_cnt; j++) {
+			int k = 0;
+			nic->ba[i][j] = kmalloc((sizeof(buffAdd_t) *
+						 (MAX_RXDS_PER_BLOCK + 1)),
+						GFP_KERNEL);
+			if (!nic->ba[i][j])
+				return -ENOMEM;
+			while (k != MAX_RXDS_PER_BLOCK) {
+				ba = &nic->ba[i][j][k];
+
+				ba->ba_0_org = (void *) kmalloc
+				    (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);
+				if (!ba->ba_0_org)
+					return -ENOMEM;
+				tmp = (u64) ba->ba_0_org;
+				tmp += ALIGN_SIZE;
+				tmp &= ~((u64) ALIGN_SIZE);
+				ba->ba_0 = (void *) tmp;
+
+				ba->ba_1_org = (void *) kmalloc
+				    (BUF1_LEN + ALIGN_SIZE, GFP_ATOMIC);
+				if (!ba->ba_1_org)
+					return -ENOMEM;
+				tmp = (u64) ba->ba_1_org;
+				tmp += ALIGN_SIZE;
+				tmp &= ~((u64) ALIGN_SIZE);
+				ba->ba_1 = (void *) tmp;
+				k++;
+			}
+		}
+	}
+#endif
+
 	/* Allocation and initialization of Statistics block */
 	size = sizeof(StatInfo_t);
 	mac_control->stats_mem = pci_alloc_consistent
@@ -532,7 +587,11 @@
 		kfree(nic->list_info[i]);
 	}

+#ifndef CONFIG_2BUFF_MODE
 	size = (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
+#else
+	size = SIZE_OF_BLOCK;
+#endif
 	for (i = 0; i < config->rx_ring_num; i++) {
 		blk_cnt = nic->block_count[i];
 		for (j = 0; j < blk_cnt; j++) {
@@ -545,6 +604,27 @@
 		}
 	}

+#ifdef CONFIG_2BUFF_MODE
+	/* Freeing buffer storage addresses in 2BUFF mode. */
+	for (i = 0; i < config->rx_ring_num; i++) {
+		blk_cnt =
+		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+		for (j = 0; j < blk_cnt; j++) {
+			int k = 0;
+			if (!nic->ba[i][j])
+				continue;
+			while (k != MAX_RXDS_PER_BLOCK) {
+				buffAdd_t *ba = &nic->ba[i][j][k];
+				kfree(ba->ba_0_org);
+				kfree(ba->ba_1_org);
+				k++;
+			}
+			kfree(nic->ba[i][j]);
+		}
+		if (nic->ba[i])
+			kfree(nic->ba[i]);
+	}
+#endif

 	if (mac_control->stats_mem) {
 		pci_free_consistent(nic->pdev,
@@ -1366,10 +1446,21 @@
 		       &bar0->prc_rxd0_n[i]);

 		val64 = readq(&bar0->prc_ctrl_n[i]);
+#ifndef CONFIG_2BUFF_MODE
 		val64 |= PRC_CTRL_RC_ENABLED;
+#else
+		val64 |= PRC_CTRL_RC_ENABLED | PRC_CTRL_RING_MODE_3;
+#endif
 		writeq(val64, &bar0->prc_ctrl_n[i]);
 	}

+#ifdef CONFIG_2BUFF_MODE
+	/* Enabling 2 buffer mode by writing into Rx_pa_cfg reg. */
+	val64 = readq(&bar0->rx_pa_cfg);
+	val64 |= RX_PA_CFG_IGNORE_L2_ERR;
+	writeq(val64, &bar0->rx_pa_cfg);
+#endif
+
 	/*
 	 * Enabling MC-RLDRAM. After enabling the device, we timeout
 	 * for around 100ms, which is approximately the time required
@@ -1437,6 +1528,12 @@
 	}

 	/*
+	 * Don't see link state interrupts on certain switches, so
+	 * directly scheduling a link state task from here.
+	 */
+	schedule_work(&nic->set_link_task);
+
+	/*
 	 * Here we are performing soft reset on XGXS to
 	 * force link down. Since link is already up, we will get
 	 * link state change interrupt after this reset
@@ -1565,6 +1662,13 @@
 	    atomic_read(&nic->rx_bufs_left[ring_no]);
 	mac_info_t *mac_control;
 	struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+	RxD_t *rxdpnext;
+	int nextblk;
+	u64 tmp;
+	buffAdd_t *ba;
+	dma_addr_t rxdpphys;
+#endif
 #ifndef CONFIG_S2IO_NAPI
 	unsigned long flags;
 #endif
@@ -1589,10 +1693,14 @@
 		    block_index;
 		off = mac_control->rx_curr_put_info[ring_no].offset;
 		off1 = mac_control->rx_curr_get_info[ring_no].offset;
+#ifndef CONFIG_2BUFF_MODE
 		offset = block_no * (MAX_RXDS_PER_BLOCK + 1) + off;
 		offset1 = block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;
+#else
 		offset = block_no * (MAX_RXDS_PER_BLOCK) + off;
 		offset1 = block_no1 * (MAX_RXDS_PER_BLOCK) + off1;
+#endif
+
 		rxdp = nic->rx_blocks[ring_no][block_no].
 		    block_virt_addr + off;
 		if ((offset == offset1) && (rxdp->Host_Control)) {
@@ -1600,6 +1708,7 @@
 			DBG_PRINT(INTR_DBG, " info equated\n");
 			goto end;
 		}
+#ifndef	CONFIG_2BUFF_MODE
 		if (rxdp->Control_1 == END_OF_BLOCK) {
 			mac_control->rx_curr_put_info[ring_no].
 			    block_index++;
@@ -1617,23 +1726,81 @@
 		}
 #ifndef CONFIG_S2IO_NAPI
 		spin_lock_irqsave(&nic->put_lock, flags);
+		nic->put_pos[ring_no] =
+		    (block_no * (MAX_RXDS_PER_BLOCK + 1)) + off;
+		spin_unlock_irqrestore(&nic->put_lock, flags);
+#endif
+#else
+		if (rxdp->Host_Control == END_OF_BLOCK) {
+			mac_control->rx_curr_put_info[ring_no].
+			    block_index++;
+			mac_control->rx_curr_put_info[ring_no].
+			    block_index %= nic->block_count[ring_no];
+			block_no = mac_control->rx_curr_put_info
+			    [ring_no].block_index;
+			off = 0;
+			DBG_PRINT(INTR_DBG, "%s: block%d at: 0x%llx\n",
+				  dev->name, block_no,
+				  (unsigned long long) rxdp->Control_1);
+			mac_control->rx_curr_put_info[ring_no].offset =
+			    off;
+			rxdp = nic->rx_blocks[ring_no][block_no].
+			    block_virt_addr;
+		}
+#ifndef CONFIG_S2IO_NAPI
+		spin_lock_irqsave(&nic->put_lock, flags);
 		nic->put_pos[ring_no] = (block_no *
 					 (MAX_RXDS_PER_BLOCK + 1)) + off;
 		spin_unlock_irqrestore(&nic->put_lock, flags);
 #endif
+#endif

-		if (rxdp->Control_1 & RXD_OWN_XENA) {
+#ifndef	CONFIG_2BUFF_MODE
+		if (rxdp->Control_1 & RXD_OWN_XENA)
+#else
+		if (rxdp->Control_2 & BIT(0))
+#endif
+		{
 			mac_control->rx_curr_put_info[ring_no].
 			    offset = off;
 			goto end;
 		}
+#ifdef	CONFIG_2BUFF_MODE
+		/*
+		 * RxDs Spanning cache lines will be replenished only
+		 * if the succeeding RxD is also owned by Host. It
+		 * will always be the ((8*i)+3) and ((8*i)+6)
+		 * descriptors for the 48 byte descriptor. The offending
+		 * decsriptor is of-course the 3rd descriptor.
+		 */
+		rxdpphys = nic->rx_blocks[ring_no][block_no].
+		    block_dma_addr + (off * sizeof(RxD_t));
+		if (((u64) (rxdpphys)) % 128 > 80) {
+			rxdpnext = nic->rx_blocks[ring_no][block_no].
+			    block_virt_addr + (off + 1);
+			if (rxdpnext->Host_Control == END_OF_BLOCK) {
+				nextblk = (block_no + 1) %
+				    (nic->block_count[ring_no]);
+				rxdpnext = nic->rx_blocks[ring_no]
+				    [nextblk].block_virt_addr;
+			}
+			if (rxdpnext->Control_2 & BIT(0))
+				goto end;
+		}
+#endif

+#ifndef	CONFIG_2BUFF_MODE
 		skb = dev_alloc_skb(size + NET_IP_ALIGN);
+#else
+		skb = dev_alloc_skb(dev->mtu + ALIGN_SIZE +
+				    /*BUF0_LEN + */ 22);
+#endif
 		if (!skb) {
 			DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
 			DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
 			return -ENOMEM;
 		}
+#ifndef	CONFIG_2BUFF_MODE
 		skb_reserve(skb, NET_IP_ALIGN);
 		memset(rxdp, 0, sizeof(RxD_t));
 		rxdp->Buffer0_ptr = pci_map_single
@@ -1645,6 +1812,33 @@
 		off++;
 		off %= (MAX_RXDS_PER_BLOCK + 1);
 		mac_control->rx_curr_put_info[ring_no].offset = off;
+#else
+		ba = &nic->ba[ring_no][block_no][off];
+		tmp = (u64) skb->data;
+		tmp += ALIGN_SIZE;
+		tmp &= ~ALIGN_SIZE;
+		skb->data = (void *) tmp;
+
+		memset(rxdp, 0, sizeof(RxD_t));
+		rxdp->Buffer2_ptr = pci_map_single
+		    (nic->pdev, skb->data, dev->mtu + 22,
+		     PCI_DMA_FROMDEVICE);
+		rxdp->Buffer0_ptr =
+		    pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
+				   PCI_DMA_FROMDEVICE);
+		rxdp->Buffer1_ptr =
+		    pci_map_single(nic->pdev, ba->ba_1, BUF1_LEN,
+				   PCI_DMA_FROMDEVICE);
+
+		rxdp->Control_2 = SET_BUFFER2_SIZE(dev->mtu + 22);
+		rxdp->Control_2 |= SET_BUFFER0_SIZE(BUF0_LEN);
+		rxdp->Control_2 |= SET_BUFFER1_SIZE(1);	/* dummy. */
+		rxdp->Control_2 |= BIT(0);	/* Set Buffer_Empty bit. */
+		rxdp->Host_Control = (u64) ((unsigned long) (skb));
+		rxdp->Control_1 |= RXD_OWN_XENA;
+		off++;
+		mac_control->rx_curr_put_info[ring_no].offset = off;
+#endif
 		atomic_inc(&nic->rx_bufs_left[ring_no]);
 		alloc_tab++;
 	}
@@ -1670,6 +1864,9 @@
 	struct sk_buff *skb;
 	mac_info_t *mac_control;
 	struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+	buffAdd_t *ba;
+#endif

 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -1679,6 +1876,7 @@
 			off = j % (MAX_RXDS_PER_BLOCK + 1);
 			rxdp = sp->rx_blocks[i][blk].block_virt_addr + off;

+#ifndef CONFIG_2BUFF_MODE
 			if (rxdp->Control_1 == END_OF_BLOCK) {
 				rxdp =
 				    (RxD_t *) ((unsigned long) rxdp->
@@ -1686,6 +1884,12 @@
 				j++;
 				blk++;
 			}
+#else
+			if (rxdp->Host_Control == END_OF_BLOCK) {
+				blk++;
+				continue;
+			}
+#endif

 			if (!(rxdp->Control_1 & RXD_OWN_XENA)) {
 				memset(rxdp, 0, sizeof(RxD_t));
@@ -1696,6 +1900,7 @@
 			    (struct sk_buff *) ((unsigned long) rxdp->
 						Host_Control);
 			if (skb) {
+#ifndef CONFIG_2BUFF_MODE
 				pci_unmap_single(sp->pdev, (dma_addr_t)
 						 rxdp->Buffer0_ptr,
 						 dev->mtu +
@@ -1703,6 +1908,21 @@
 						 + HEADER_802_2_SIZE +
 						 HEADER_SNAP_SIZE,
 						 PCI_DMA_FROMDEVICE);
+#else
+				ba = &sp->ba[i][blk][off];
+				pci_unmap_single(sp->pdev, (dma_addr_t)
+						 rxdp->Buffer0_ptr,
+						 BUF0_LEN,
+						 PCI_DMA_FROMDEVICE);
+				pci_unmap_single(sp->pdev, (dma_addr_t)
+						 rxdp->Buffer1_ptr,
+						 BUF1_LEN,
+						 PCI_DMA_FROMDEVICE);
+				pci_unmap_single(sp->pdev, (dma_addr_t)
+						 rxdp->Buffer2_ptr,
+						 dev->mtu + 22,
+						 PCI_DMA_FROMDEVICE);
+#endif
 				dev_kfree_skb(skb);
 				atomic_dec(&sp->rx_bufs_left[i]);
 				buf_cnt++;
@@ -1741,11 +1961,16 @@
 	register u64 val64 = 0;
 	rx_curr_get_info_t get_info, put_info;
 	int i, get_block, put_block, get_offset, put_offset, ring_bufs;
+#ifndef CONFIG_2BUFF_MODE
 	u16 val16, cksum;
+#endif
 	struct sk_buff *skb;
 	RxD_t *rxdp;
 	mac_info_t *mac_control;
 	struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+	buffAdd_t *ba;
+#endif

 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -1764,6 +1989,7 @@
 		ring_bufs = config->rx_cfg[i].num_rxd;
 		rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
 		    get_info.offset;
+#ifndef	CONFIG_2BUFF_MODE
 		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
 		    get_info.offset;
 		put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
@@ -1820,6 +2046,66 @@
 			mac_control->rx_curr_get_info[i].offset =
 			    get_info.offset;
 		}
+#else
+		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    get_info.offset;
+		put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    put_info.offset;
+		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+			!(rxdp->Control_2 & BIT(0))) &&
+		       (((get_offset + 1) % ring_bufs) != put_offset)) {
+			if (--pkts_to_process < 0) {
+				goto no_rx;
+			}
+			skb = (struct sk_buff *) ((unsigned long)
+						  rxdp->Host_Control);
+			if (skb == NULL) {
+				DBG_PRINT(ERR_DBG, "%s: The skb is ",
+					  dev->name);
+				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
+				goto no_rx;
+			}
+
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+					 rxdp->Buffer0_ptr,
+					 BUF0_LEN, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+					 rxdp->Buffer1_ptr,
+					 BUF1_LEN, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+					 rxdp->Buffer2_ptr,
+					 dev->mtu + 22,
+					 PCI_DMA_FROMDEVICE);
+			ba = &nic->ba[i][get_block][get_info.offset];
+
+			rx_osm_handler(nic, rxdp, i, ba);
+
+			get_info.offset++;
+			mac_control->rx_curr_get_info[i].offset =
+			    get_info.offset;
+			rxdp =
+			    nic->rx_blocks[i][get_block].block_virt_addr +
+			    get_info.offset;
+
+			if (get_info.offset &&
+			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
+				get_info.offset = 0;
+				mac_control->rx_curr_get_info[i].
+				    offset = get_info.offset;
+				get_block++;
+				get_block %= nic->block_count[i];
+				mac_control->rx_curr_get_info[i].
+				    block_index = get_block;
+				rxdp =
+				    nic->rx_blocks[i][get_block].
+				    block_virt_addr;
+			}
+			get_offset =
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+			    get_info.offset;
+			pkt_cnt++;
+		}
+#endif
 	}
 	if (!pkt_cnt)
 		pkt_cnt = 1;
@@ -1873,12 +2159,17 @@
 	rx_curr_get_info_t get_info, put_info;
 	RxD_t *rxdp;
 	struct sk_buff *skb;
+#ifndef CONFIG_2BUFF_MODE
 	u16 val16, cksum;
+#endif
 	register u64 val64 = 0;
 	int get_block, get_offset, put_block, put_offset, ring_bufs;
 	int i, pkt_cnt = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+	buffAdd_t *ba;
+#endif

 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -1898,6 +2189,7 @@
 		ring_bufs = config->rx_cfg[i].num_rxd;
 		rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
 		    get_info.offset;
+#ifndef	CONFIG_2BUFF_MODE
 		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
 		    get_info.offset;
 		spin_lock(&nic->put_lock);
@@ -1953,6 +2245,67 @@
 			    && (pkt_cnt > indicate_max_pkts))
 				break;
 		}
+#else
+		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    get_info.offset;
+		spin_lock(&nic->put_lock);
+		put_offset = nic->put_pos[i];
+		spin_unlock(&nic->put_lock);
+		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+			!(rxdp->Control_2 & BIT(0))) &&
+		       (((get_offset + 1) % ring_bufs) != put_offset)) {
+			skb = (struct sk_buff *) ((unsigned long)
+						  rxdp->Host_Control);
+			if (skb == NULL) {
+				DBG_PRINT(ERR_DBG, "%s: The skb is ",
+					  dev->name);
+				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
+				return;
+			}
+
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+					 rxdp->Buffer0_ptr,
+					 BUF0_LEN, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+					 rxdp->Buffer1_ptr,
+					 BUF1_LEN, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+					 rxdp->Buffer2_ptr,
+					 dev->mtu + 22,
+					 PCI_DMA_FROMDEVICE);
+			ba = &nic->ba[i][get_block][get_info.offset];
+
+			rx_osm_handler(nic, rxdp, i, ba);
+
+			get_info.offset++;
+			mac_control->rx_curr_get_info[i].offset =
+			    get_info.offset;
+			rxdp =
+			    nic->rx_blocks[i][get_block].block_virt_addr +
+			    get_info.offset;
+
+			if (get_info.offset &&
+			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
+				get_info.offset = 0;
+				mac_control->rx_curr_get_info[i].
+				    offset = get_info.offset;
+				get_block++;
+				get_block %= nic->block_count[i];
+				mac_control->rx_curr_get_info[i].
+				    block_index = get_block;
+				rxdp =
+				    nic->rx_blocks[i][get_block].
+				    block_virt_addr;
+			}
+			get_offset =
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+			    get_info.offset;
+			pkt_cnt++;
+			if ((indicate_max_pkts)
+			    && (pkt_cnt > indicate_max_pkts))
+				break;
+		}
+#endif
 		if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))
 			break;
 	}
@@ -4096,12 +4449,21 @@
  *   Return value:
  *   SUCCESS on success and -1 on failure.
  */
+#ifndef CONFIG_2BUFF_MODE
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no)
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+			  buffAdd_t * ba)
+#endif
 {
 	struct net_device *dev = (struct net_device *) sp->dev;
 	struct sk_buff *skb =
 	    (struct sk_buff *) ((unsigned long) rxdp->Host_Control);
 	u16 l3_csum, l4_csum;
+#ifdef CONFIG_2BUFF_MODE
+	int buf0_len, buf2_len;
+	struct ethhdr *eth = (struct ethhdr *) ba->ba_0;
+#endif

 	l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum)) {
@@ -4129,10 +4491,32 @@
 		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
 			  dev->name, err);
 	}
+#ifdef CONFIG_2BUFF_MODE
+	buf0_len = RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
+	buf2_len = RXD_GET_BUFFER2_SIZE(rxdp->Control_2);
+#endif

 	skb->dev = dev;
+#ifndef CONFIG_2BUFF_MODE
 	skb_put(skb, len);
 	skb->protocol = eth_type_trans(skb, dev);
+#else
+	skb_put(skb, buf2_len);
+	/*
+	 * Reproducing eth_type_trans functionality and running
+	 * on the ethernet header 'eth' stripped and given to us
+	 * by the hardware in 2Buff mode.
+	 */
+	if (*eth->h_dest & 1) {
+		if (!memcmp(eth->h_dest, dev->broadcast, ETH_ALEN))
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_MULTICAST;
+	} else if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN)) {
+		skb->pkt_type = PACKET_OTHERHOST;
+	}
+	skb->protocol = eth->h_proto;
+#endif

 #ifdef CONFIG_S2IO_NAPI
 	netif_receive_skb(skb);
@@ -4143,7 +4527,11 @@
 	dev->last_rx = jiffies;
 	sp->rx_pkt_count++;
 	sp->stats.rx_packets++;
+#ifndef CONFIG_2BUFF_MODE
 	sp->stats.rx_bytes += len;
+#else
+	sp->stats.rx_bytes += buf0_len + buf2_len;
+#endif

 	atomic_dec(&sp->rx_bufs_left[ring_no]);
 	rxdp->Host_Control = 0;
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-11 21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-11 21:22:23.000000000 -0700
@@ -466,19 +466,46 @@
 #define RXD_GET_L4_CKSUM(val)   ((u16)(val) & 0xFFFF)

 	u64 Control_2;
+#ifndef CONFIG_2BUFF_MODE
 #define MASK_BUFFER0_SIZE       vBIT(0xFFFF,0,16)
 #define SET_BUFFER0_SIZE(val)   vBIT(val,0,16)
+#else
+#define MASK_BUFFER0_SIZE       vBIT(0xFF,0,16)
+#define MASK_BUFFER1_SIZE       vBIT(0xFFFF,16,16)
+#define MASK_BUFFER2_SIZE       vBIT(0xFFFF,32,16)
+#define SET_BUFFER0_SIZE(val)   vBIT(val,8,8)
+#define SET_BUFFER1_SIZE(val)   vBIT(val,16,16)
+#define SET_BUFFER2_SIZE(val)   vBIT(val,32,16)
+#endif
+
 #define MASK_VLAN_TAG           vBIT(0xFFFF,48,16)
 #define SET_VLAN_TAG(val)       vBIT(val,48,16)
 #define SET_NUM_TAG(val)       vBIT(val,16,32)

+#ifndef CONFIG_2BUFF_MODE
 #define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 & vBIT(0xFFFF,0,16)))
+#else
+#define RXD_GET_BUFFER0_SIZE(Control_2) (u8)((Control_2 & MASK_BUFFER0_SIZE) \
+							>> 48)
+#define RXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 & MASK_BUFFER1_SIZE) \
+							>> 32)
+#define RXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 & MASK_BUFFER2_SIZE) \
+							>> 16)
+#define BUF0_LEN	40
+#define BUF1_LEN	1
+#endif
+
 	u64 Buffer0_ptr;
+#ifdef CONFIG_2BUFF_MODE
+	u64 Buffer1_ptr;
+	u64 Buffer2_ptr;
+#endif
 } RxD_t;

 /* Structure that represents the Rx descriptor block which contains
  * 128 Rx descriptors.
  */
+#ifndef CONFIG_2BUFF_MODE
 typedef struct _RxD_block {
 #define MAX_RXDS_PER_BLOCK             127
 	RxD_t rxd[MAX_RXDS_PER_BLOCK];
@@ -492,6 +519,27 @@
 					 * the upper 32 bits should
 					 * be 0 */
 } RxD_block_t;
+#else
+typedef struct _RxD_block {
+#define MAX_RXDS_PER_BLOCK             85
+	RxD_t rxd[MAX_RXDS_PER_BLOCK];
+
+#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd
+				 * in this blk */
+	u64 pNext_RxD_Blk_physical;	/* Phy ponter to next blk. */
+} RxD_block_t;
+#define SIZE_OF_BLOCK	4096
+
+/* Structure to hold virtual addresses of Buf0 and Buf1 in
+ * 2buf mode. */
+typedef struct bufAdd {
+	void *ba_0_org;
+	void *ba_1_org;
+	void *ba_0;
+	void *ba_1;
+} buffAdd_t;
+#endif

 /* Structure which stores all the MAC control parameters */

@@ -677,6 +725,10 @@
 #define	LINK_DOWN	1
 #define	LINK_UP		2

+#ifdef CONFIG_2BUFF_MODE
+	/* Buffer Address store. */
+	buffAdd_t **ba[MAX_RX_RINGS];
+#endif
 	int task_flag;
 } nic_t;

@@ -802,7 +854,12 @@
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
+#ifndef CONFIG_2BUFF_MODE
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no);
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+			  buffAdd_t * ba);
+#endif
 void s2io_link(nic_t * sp, int link);
 void s2io_reset(nic_t * sp);
 #ifdef CONFIG_S2IO_NAPI
