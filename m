From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Wed, 13 Oct 2004 18:18:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005a01c4b18b$c1fd7400$6c10100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_005B_01C4B151.159E9C00"
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_005B_01C4B151.159E9C00
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,
Attached is the patch for implementing 2-buffer mode on Rx path.
More description of this mode of operation follows.

On certain systems when a DMA has to happen on an un-aligned memory location
performance will take a significant hit. It's standard practice to offset
the Rx buffer address by 2 (as Mac header is 14 bytes) so the IP header
starts from an aligned location. Obviously using a single Rx buffer both
cannot be achieved. Thus XFrame supports something called 2 buffer Rx mode,
where in the Rx'ed frame is split into 2 parts, one is the Ethernet header
and the other is the Ethernet payload. So now we can allocate proper aligned
memory for both buffers, hence the DMA is not slowed down. Also, the
Ethernet payload(starting from L3 header) is on an aligned location so OS
need not have to do un-aligned accesses to process IP header. To achieve
this, the kernel function eth_type_trans functionality has to be partially
implemented in the driver itself.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>

------=_NextPart_000_005B_01C4B151.159E9C00
Content-Type: application/octet-stream;
	name="s2io_2buff.patch8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="s2io_2buff.patch8"

diff -urN vanilla-linux/drivers/net/Kconfig =
linux-2.6.8.1/drivers/net/Kconfig
--- vanilla-linux/drivers/net/Kconfig	2004-10-06 15:15:04.000000000 =
-0700
+++ linux-2.6.8.1/drivers/net/Kconfig	2004-10-11 20:06:36.000000000 =
-0700
@@ -2267,6 +2267,17 @@
=20
 	  If in doubt, say N.
=20
+config 2BUFF_MODE
+	bool "Use 2 Buffer Mode on Rx side."
+	depends on S2IO
+	---help---
+	On enabling the 2 buffer mode, the received frame will be
+	split into 2 parts before being DMA'ed to the hosts memory.
+	The parts are the ethernet header and ethernet payload.=20
+	This is useful on systems where DMA'ing to to unaligned=20
+	physical memory loactions comes with a heavy price.
+	If not sure please say N.
+
 endmenu
=20
 source "drivers/net/tokenring/Kconfig"
diff -urN vanilla-linux/drivers/net/s2io.c =
linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-11 21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-12 16:49:27.796331624 -0700
@@ -325,6 +325,10 @@
 	int i, j, blk_cnt;
 	int lst_size, lst_per_page;
 	struct net_device *dev =3D nic->dev;
+#ifdef CONFIG_2BUFF_MODE
+	u64 tmp;
+	buffAdd_t *ba;
+#endif
=20
 	mac_info_t *mac_control;
 	struct config_param *config;
@@ -425,7 +429,11 @@
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
 		/*  Allocating all the Rx blocks */
 		for (j =3D 0; j < blk_cnt; j++) {
+#ifndef CONFIG_2BUFF_MODE
 			size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
+#else
+			size =3D SIZE_OF_BLOCK;
+#endif
 			tmp_v_addr =3D pci_alloc_consistent(nic->pdev, size,
 							  &tmp_p_addr);
 			if (tmp_v_addr =3D=3D NULL) {
@@ -458,13 +466,60 @@
 			pre_rxd_blk->reserved_1 =3D END_OF_BLOCK;	/* last RxD=20
 								 * marker.
 								 */
+#ifndef	CONFIG_2BUFF_MODE
 			pre_rxd_blk->reserved_2_pNext_RxD_block =3D
 			    (unsigned long) tmp_v_addr_next;
+#endif
 			pre_rxd_blk->pNext_RxD_Blk_physical =3D
 			    (u64) tmp_p_addr_next;
 		}
 	}
=20
+#ifdef CONFIG_2BUFF_MODE
+	/*=20
+	 * Allocation of Storages for buffer addresses in 2BUFF mode
+	 * and the buffers as well.
+	 */
+	for (i =3D 0; i < config->rx_ring_num; i++) {
+		blk_cnt =3D
+		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+		nic->ba[i] =3D kmalloc((sizeof(buffAdd_t *) * blk_cnt),
+				     GFP_KERNEL);
+		if (!nic->ba[i])
+			return -ENOMEM;
+		for (j =3D 0; j < blk_cnt; j++) {
+			int k =3D 0;
+			nic->ba[i][j] =3D kmalloc((sizeof(buffAdd_t) *
+						 (MAX_RXDS_PER_BLOCK + 1)),
+						GFP_KERNEL);
+			if (!nic->ba[i][j])
+				return -ENOMEM;
+			while (k !=3D MAX_RXDS_PER_BLOCK) {
+				ba =3D &nic->ba[i][j][k];
+
+				ba->ba_0_org =3D (void *) kmalloc
+				    (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);
+				if (!ba->ba_0_org)
+					return -ENOMEM;
+				tmp =3D (u64) ba->ba_0_org;
+				tmp +=3D ALIGN_SIZE;
+				tmp &=3D ~((u64) ALIGN_SIZE);
+				ba->ba_0 =3D (void *) tmp;
+
+				ba->ba_1_org =3D (void *) kmalloc
+				    (BUF1_LEN + ALIGN_SIZE, GFP_ATOMIC);
+				if (!ba->ba_1_org)
+					return -ENOMEM;
+				tmp =3D (u64) ba->ba_1_org;
+				tmp +=3D ALIGN_SIZE;
+				tmp &=3D ~((u64) ALIGN_SIZE);
+				ba->ba_1 =3D (void *) tmp;
+				k++;
+			}
+		}
+	}
+#endif
+
 	/* Allocation and initialization of Statistics block */
 	size =3D sizeof(StatInfo_t);
 	mac_control->stats_mem =3D pci_alloc_consistent
@@ -532,7 +587,11 @@
 		kfree(nic->list_info[i]);
 	}
=20
+#ifndef CONFIG_2BUFF_MODE
 	size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
+#else
+	size =3D SIZE_OF_BLOCK;
+#endif
 	for (i =3D 0; i < config->rx_ring_num; i++) {
 		blk_cnt =3D nic->block_count[i];
 		for (j =3D 0; j < blk_cnt; j++) {
@@ -545,6 +604,27 @@
 		}
 	}
=20
+#ifdef CONFIG_2BUFF_MODE
+	/* Freeing buffer storage addresses in 2BUFF mode. */
+	for (i =3D 0; i < config->rx_ring_num; i++) {
+		blk_cnt =3D
+		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+		for (j =3D 0; j < blk_cnt; j++) {
+			int k =3D 0;
+			if (!nic->ba[i][j])
+				continue;
+			while (k !=3D MAX_RXDS_PER_BLOCK) {
+				buffAdd_t *ba =3D &nic->ba[i][j][k];
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
=20
 	if (mac_control->stats_mem) {
 		pci_free_consistent(nic->pdev,
@@ -1366,10 +1446,21 @@
 		       &bar0->prc_rxd0_n[i]);
=20
 		val64 =3D readq(&bar0->prc_ctrl_n[i]);
+#ifndef CONFIG_2BUFF_MODE
 		val64 |=3D PRC_CTRL_RC_ENABLED;
+#else
+		val64 |=3D PRC_CTRL_RC_ENABLED | PRC_CTRL_RING_MODE_3;
+#endif
 		writeq(val64, &bar0->prc_ctrl_n[i]);
 	}
=20
+#ifdef CONFIG_2BUFF_MODE
+	/* Enabling 2 buffer mode by writing into Rx_pa_cfg reg. */
+	val64 =3D readq(&bar0->rx_pa_cfg);
+	val64 |=3D RX_PA_CFG_IGNORE_L2_ERR;
+	writeq(val64, &bar0->rx_pa_cfg);
+#endif
+
 	/*=20
 	 * Enabling MC-RLDRAM. After enabling the device, we timeout
 	 * for around 100ms, which is approximately the time required
@@ -1437,6 +1528,12 @@
 	}
=20
 	/*=20
+	 * Don't see link state interrupts on certain switches, so=20
+	 * directly scheduling a link state task from here.
+	 */
+	schedule_work(&nic->set_link_task);
+
+	/*=20
 	 * Here we are performing soft reset on XGXS to=20
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
 		off =3D mac_control->rx_curr_put_info[ring_no].offset;
 		off1 =3D mac_control->rx_curr_get_info[ring_no].offset;
+#ifndef CONFIG_2BUFF_MODE
 		offset =3D block_no * (MAX_RXDS_PER_BLOCK + 1) + off;
 		offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;
+#else
 		offset =3D block_no * (MAX_RXDS_PER_BLOCK) + off;
 		offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK) + off1;
+#endif
+
 		rxdp =3D nic->rx_blocks[ring_no][block_no].
 		    block_virt_addr + off;
 		if ((offset =3D=3D offset1) && (rxdp->Host_Control)) {
@@ -1600,6 +1708,7 @@
 			DBG_PRINT(INTR_DBG, " info equated\n");
 			goto end;
 		}
+#ifndef	CONFIG_2BUFF_MODE
 		if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {
 			mac_control->rx_curr_put_info[ring_no].
 			    block_index++;
@@ -1617,23 +1726,81 @@
 		}
 #ifndef CONFIG_S2IO_NAPI
 		spin_lock_irqsave(&nic->put_lock, flags);
+		nic->put_pos[ring_no] =3D
+		    (block_no * (MAX_RXDS_PER_BLOCK + 1)) + off;
+		spin_unlock_irqrestore(&nic->put_lock, flags);
+#endif
+#else
+		if (rxdp->Host_Control =3D=3D END_OF_BLOCK) {
+			mac_control->rx_curr_put_info[ring_no].
+			    block_index++;
+			mac_control->rx_curr_put_info[ring_no].
+			    block_index %=3D nic->block_count[ring_no];
+			block_no =3D mac_control->rx_curr_put_info
+			    [ring_no].block_index;
+			off =3D 0;
+			DBG_PRINT(INTR_DBG, "%s: block%d at: 0x%llx\n",
+				  dev->name, block_no,
+				  (unsigned long long) rxdp->Control_1);
+			mac_control->rx_curr_put_info[ring_no].offset =3D
+			    off;
+			rxdp =3D nic->rx_blocks[ring_no][block_no].
+			    block_virt_addr;
+		}
+#ifndef CONFIG_S2IO_NAPI
+		spin_lock_irqsave(&nic->put_lock, flags);
 		nic->put_pos[ring_no] =3D (block_no *
 					 (MAX_RXDS_PER_BLOCK + 1)) + off;
 		spin_unlock_irqrestore(&nic->put_lock, flags);
 #endif
+#endif
=20
-		if (rxdp->Control_1 & RXD_OWN_XENA) {
+#ifndef	CONFIG_2BUFF_MODE
+		if (rxdp->Control_1 & RXD_OWN_XENA)
+#else
+		if (rxdp->Control_2 & BIT(0))
+#endif
+		{
 			mac_control->rx_curr_put_info[ring_no].
 			    offset =3D off;
 			goto end;
 		}
+#ifdef	CONFIG_2BUFF_MODE
+		/*=20
+		 * RxDs Spanning cache lines will be replenished only=20
+		 * if the succeeding RxD is also owned by Host. It=20
+		 * will always be the ((8*i)+3) and ((8*i)+6)=20
+		 * descriptors for the 48 byte descriptor. The offending=20
+		 * decsriptor is of-course the 3rd descriptor.
+		 */
+		rxdpphys =3D nic->rx_blocks[ring_no][block_no].
+		    block_dma_addr + (off * sizeof(RxD_t));
+		if (((u64) (rxdpphys)) % 128 > 80) {
+			rxdpnext =3D nic->rx_blocks[ring_no][block_no].
+			    block_virt_addr + (off + 1);
+			if (rxdpnext->Host_Control =3D=3D END_OF_BLOCK) {
+				nextblk =3D (block_no + 1) %
+				    (nic->block_count[ring_no]);
+				rxdpnext =3D nic->rx_blocks[ring_no]
+				    [nextblk].block_virt_addr;
+			}
+			if (rxdpnext->Control_2 & BIT(0))
+				goto end;
+		}
+#endif
=20
+#ifndef	CONFIG_2BUFF_MODE
 		skb =3D dev_alloc_skb(size + NET_IP_ALIGN);
+#else
+		skb =3D dev_alloc_skb(dev->mtu + ALIGN_SIZE +
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
 		rxdp->Buffer0_ptr =3D pci_map_single
@@ -1645,6 +1812,33 @@
 		off++;
 		off %=3D (MAX_RXDS_PER_BLOCK + 1);
 		mac_control->rx_curr_put_info[ring_no].offset =3D off;
+#else
+		ba =3D &nic->ba[ring_no][block_no][off];
+		tmp =3D (u64) skb->data;
+		tmp +=3D ALIGN_SIZE;
+		tmp &=3D ~ALIGN_SIZE;
+		skb->data =3D (void *) tmp;
+
+		memset(rxdp, 0, sizeof(RxD_t));
+		rxdp->Buffer2_ptr =3D pci_map_single
+		    (nic->pdev, skb->data, dev->mtu + 22,
+		     PCI_DMA_FROMDEVICE);
+		rxdp->Buffer0_ptr =3D
+		    pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
+				   PCI_DMA_FROMDEVICE);
+		rxdp->Buffer1_ptr =3D
+		    pci_map_single(nic->pdev, ba->ba_1, BUF1_LEN,
+				   PCI_DMA_FROMDEVICE);
+
+		rxdp->Control_2 =3D SET_BUFFER2_SIZE(dev->mtu + 22);
+		rxdp->Control_2 |=3D SET_BUFFER0_SIZE(BUF0_LEN);
+		rxdp->Control_2 |=3D SET_BUFFER1_SIZE(1);	/* dummy. */
+		rxdp->Control_2 |=3D BIT(0);	/* Set Buffer_Empty bit. */
+		rxdp->Host_Control =3D (u64) ((unsigned long) (skb));
+		rxdp->Control_1 |=3D RXD_OWN_XENA;
+		off++;
+		mac_control->rx_curr_put_info[ring_no].offset =3D off;
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
=20
 	mac_control =3D &sp->mac_control;
 	config =3D &sp->config;
@@ -1679,6 +1876,7 @@
 			off =3D j % (MAX_RXDS_PER_BLOCK + 1);
 			rxdp =3D sp->rx_blocks[i][blk].block_virt_addr + off;
=20
+#ifndef CONFIG_2BUFF_MODE
 			if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {
 				rxdp =3D
 				    (RxD_t *) ((unsigned long) rxdp->
@@ -1686,6 +1884,12 @@
 				j++;
 				blk++;
 			}
+#else
+			if (rxdp->Host_Control =3D=3D END_OF_BLOCK) {
+				blk++;
+				continue;
+			}
+#endif
=20
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
+				ba =3D &sp->ba[i][blk][off];
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
 	register u64 val64 =3D 0;
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
=20
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
@@ -1764,6 +1989,7 @@
 		ring_bufs =3D config->rx_cfg[i].num_rxd;
 		rxdp =3D nic->rx_blocks[i][get_block].block_virt_addr +
 		    get_info.offset;
+#ifndef	CONFIG_2BUFF_MODE
 		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
 		    get_info.offset;
 		put_offset =3D (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
@@ -1820,6 +2046,66 @@
 			mac_control->rx_curr_get_info[i].offset =3D
 			    get_info.offset;
 		}
+#else
+		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    get_info.offset;
+		put_offset =3D (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    put_info.offset;
+		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+			!(rxdp->Control_2 & BIT(0))) &&
+		       (((get_offset + 1) % ring_bufs) !=3D put_offset)) {
+			if (--pkts_to_process < 0) {
+				goto no_rx;
+			}
+			skb =3D (struct sk_buff *) ((unsigned long)
+						  rxdp->Host_Control);
+			if (skb =3D=3D NULL) {
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
+			ba =3D &nic->ba[i][get_block][get_info.offset];
+
+			rx_osm_handler(nic, rxdp, i, ba);
+
+			get_info.offset++;
+			mac_control->rx_curr_get_info[i].offset =3D
+			    get_info.offset;
+			rxdp =3D
+			    nic->rx_blocks[i][get_block].block_virt_addr +
+			    get_info.offset;
+
+			if (get_info.offset &&
+			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
+				get_info.offset =3D 0;
+				mac_control->rx_curr_get_info[i].
+				    offset =3D get_info.offset;
+				get_block++;
+				get_block %=3D nic->block_count[i];
+				mac_control->rx_curr_get_info[i].
+				    block_index =3D get_block;
+				rxdp =3D
+				    nic->rx_blocks[i][get_block].
+				    block_virt_addr;
+			}
+			get_offset =3D
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+			    get_info.offset;
+			pkt_cnt++;
+		}
+#endif
 	}
 	if (!pkt_cnt)
 		pkt_cnt =3D 1;
@@ -1873,12 +2159,17 @@
 	rx_curr_get_info_t get_info, put_info;
 	RxD_t *rxdp;
 	struct sk_buff *skb;
+#ifndef CONFIG_2BUFF_MODE
 	u16 val16, cksum;
+#endif
 	register u64 val64 =3D 0;
 	int get_block, get_offset, put_block, put_offset, ring_bufs;
 	int i, pkt_cnt =3D 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+	buffAdd_t *ba;
+#endif
=20
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
@@ -1898,6 +2189,7 @@
 		ring_bufs =3D config->rx_cfg[i].num_rxd;
 		rxdp =3D nic->rx_blocks[i][get_block].block_virt_addr +
 		    get_info.offset;
+#ifndef	CONFIG_2BUFF_MODE
 		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
 		    get_info.offset;
 		spin_lock(&nic->put_lock);
@@ -1953,6 +2245,67 @@
 			    && (pkt_cnt > indicate_max_pkts))
 				break;
 		}
+#else
+		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    get_info.offset;
+		spin_lock(&nic->put_lock);
+		put_offset =3D nic->put_pos[i];
+		spin_unlock(&nic->put_lock);
+		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+			!(rxdp->Control_2 & BIT(0))) &&
+		       (((get_offset + 1) % ring_bufs) !=3D put_offset)) {
+			skb =3D (struct sk_buff *) ((unsigned long)
+						  rxdp->Host_Control);
+			if (skb =3D=3D NULL) {
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
+			ba =3D &nic->ba[i][get_block][get_info.offset];
+
+			rx_osm_handler(nic, rxdp, i, ba);
+
+			get_info.offset++;
+			mac_control->rx_curr_get_info[i].offset =3D
+			    get_info.offset;
+			rxdp =3D
+			    nic->rx_blocks[i][get_block].block_virt_addr +
+			    get_info.offset;
+
+			if (get_info.offset &&
+			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
+				get_info.offset =3D 0;
+				mac_control->rx_curr_get_info[i].
+				    offset =3D get_info.offset;
+				get_block++;
+				get_block %=3D nic->block_count[i];
+				mac_control->rx_curr_get_info[i].
+				    block_index =3D get_block;
+				rxdp =3D
+				    nic->rx_blocks[i][get_block].
+				    block_virt_addr;
+			}
+			get_offset =3D
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
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int =
ring_no)
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+			  buffAdd_t * ba)
+#endif
 {
 	struct net_device *dev =3D (struct net_device *) sp->dev;
 	struct sk_buff *skb =3D
 	    (struct sk_buff *) ((unsigned long) rxdp->Host_Control);
 	u16 l3_csum, l4_csum;
+#ifdef CONFIG_2BUFF_MODE
+	int buf0_len, buf2_len;
+	struct ethhdr *eth =3D (struct ethhdr *) ba->ba_0;
+#endif
=20
 	l3_csum =3D RXD_GET_L3_CKSUM(rxdp->Control_1);
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum)) {
@@ -4129,10 +4491,32 @@
 		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
 			  dev->name, err);
 	}
+#ifdef CONFIG_2BUFF_MODE
+	buf0_len =3D RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
+	buf2_len =3D RXD_GET_BUFFER2_SIZE(rxdp->Control_2);
+#endif
=20
 	skb->dev =3D dev;
+#ifndef CONFIG_2BUFF_MODE
 	skb_put(skb, len);
 	skb->protocol =3D eth_type_trans(skb, dev);
+#else
+	skb_put(skb, buf2_len);
+	/*=20
+	 * Reproducing eth_type_trans functionality and running
+	 * on the ethernet header 'eth' stripped and given to us
+	 * by the hardware in 2Buff mode.
+	 */
+	if (*eth->h_dest & 1) {
+		if (!memcmp(eth->h_dest, dev->broadcast, ETH_ALEN))
+			skb->pkt_type =3D PACKET_BROADCAST;
+		else
+			skb->pkt_type =3D PACKET_MULTICAST;
+	} else if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN)) {
+		skb->pkt_type =3D PACKET_OTHERHOST;
+	}
+	skb->protocol =3D eth->h_proto;
+#endif
=20
 #ifdef CONFIG_S2IO_NAPI
 	netif_receive_skb(skb);
@@ -4143,7 +4527,11 @@
 	dev->last_rx =3D jiffies;
 	sp->rx_pkt_count++;
 	sp->stats.rx_packets++;
+#ifndef CONFIG_2BUFF_MODE
 	sp->stats.rx_bytes +=3D len;
+#else
+	sp->stats.rx_bytes +=3D buf0_len + buf2_len;
+#endif
=20
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
 	rxdp->Host_Control =3D 0;
diff -urN vanilla-linux/drivers/net/s2io.h =
linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-11 21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-11 21:22:23.000000000 -0700
@@ -466,19 +466,46 @@
 #define RXD_GET_L4_CKSUM(val)   ((u16)(val) & 0xFFFF)
=20
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
=20
+#ifndef CONFIG_2BUFF_MODE
 #define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 & =
vBIT(0xFFFF,0,16)))
+#else
+#define RXD_GET_BUFFER0_SIZE(Control_2) (u8)((Control_2 & =
MASK_BUFFER0_SIZE) \
+							>> 48)
+#define RXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER1_SIZE) \
+							>> 32)
+#define RXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER2_SIZE) \
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
=20
 /* Structure that represents the Rx descriptor block which contains=20
  * 128 Rx descriptors.
  */
+#ifndef CONFIG_2BUFF_MODE
 typedef struct _RxD_block {
 #define MAX_RXDS_PER_BLOCK             127
 	RxD_t rxd[MAX_RXDS_PER_BLOCK];
@@ -492,6 +519,27 @@
 					 * the upper 32 bits should=20
 					 * be 0 */
 } RxD_block_t;
+#else
+typedef struct _RxD_block {
+#define MAX_RXDS_PER_BLOCK             85
+	RxD_t rxd[MAX_RXDS_PER_BLOCK];
+
+#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd=20
+				 * in this blk */
+	u64 pNext_RxD_Blk_physical;	/* Phy ponter to next blk. */
+} RxD_block_t;
+#define SIZE_OF_BLOCK	4096
+
+/* Structure to hold virtual addresses of Buf0 and Buf1 in=20
+ * 2buf mode. */
+typedef struct bufAdd {
+	void *ba_0_org;
+	void *ba_1_org;
+	void *ba_0;
+	void *ba_1;
+} buffAdd_t;
+#endif
=20
 /* Structure which stores all the MAC control parameters */
=20
@@ -677,6 +725,10 @@
 #define	LINK_DOWN	1
 #define	LINK_UP		2
=20
+#ifdef CONFIG_2BUFF_MODE
+	/* Buffer Address store. */
+	buffAdd_t **ba[MAX_RX_RINGS];
+#endif
 	int task_flag;
 } nic_t;
=20
@@ -802,7 +854,12 @@
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
+#ifndef CONFIG_2BUFF_MODE
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int =
ring_no);
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+			  buffAdd_t * ba);
+#endif
 void s2io_link(nic_t * sp, int link);
 void s2io_reset(nic_t * sp);
 #ifdef CONFIG_S2IO_NAPI

------=_NextPart_000_005B_01C4B151.159E9C00--
