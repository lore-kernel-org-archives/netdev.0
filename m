From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/9] s2io: Generate complete messages using single line
 DBG_PRINTs
Date: Tue, 25 Aug 2009 11:52:00 -0700
Message-ID: <1251226321.24767.45.camel@Joe-Laptop.home>
References: <cover.1251170438.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Single line log messages should be emitted by a single call
where possible.

Converted multiple calls to DBG_PRINT to single call form.
Removed "s2io:" preface from DBG_PRINTs.

The DBG_PRINT macro now emits a log level and is surrounded by
a do {...} while (0)

All s2io log output is now prefaced with KBUILD_MODNAME ": "
via pr_fmt.

The DBG_PRINT macro should probably be converted to use the
dev_<level> form eventually.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 1d13f60..3138df5 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -652,9 +652,9 @@ static int init_shared_mem(struct s2io_nic *nic)
 		size += tx_cfg->fifo_len;
 	}
 	if (size > MAX_AVAILABLE_TXDS) {
-		DBG_PRINT(ERR_DBG, "s2io: Requested TxDs too high, ");
-		DBG_PRINT(ERR_DBG, "Requested: %d, max supported: 8192\n",
-			  size);
+		DBG_PRINT(ERR_DBG,
+			  "Too many TxDs requested: %d, max supported: %d\n",
+			  size, MAX_AVAILABLE_TXDS);
 		return -EINVAL;
 	}
 
@@ -667,10 +667,9 @@ static int init_shared_mem(struct s2io_nic *nic)
 		 * Legal values are from 2 to 8192
 		 */
 		if (size < 2) {
-			DBG_PRINT(ERR_DBG, "s2io: Invalid fifo len (%d)", size);
-			DBG_PRINT(ERR_DBG, "for fifo %d\n", i);
-			DBG_PRINT(ERR_DBG, "s2io: Legal values for fifo len"
-				  "are 2 to 8192\n");
+			DBG_PRINT(ERR_DBG, "Fifo %d: Invalid length (%d) - "
+				  "Valid lengths are 2 through 8192\n",
+				  i, size);
 			return -EINVAL;
 		}
 	}
@@ -713,8 +712,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 			tmp_v = pci_alloc_consistent(nic->pdev,
 						     PAGE_SIZE, &tmp_p);
 			if (!tmp_v) {
-				DBG_PRINT(INFO_DBG, "pci_alloc_consistent ");
-				DBG_PRINT(INFO_DBG, "failed for TxDL\n");
+				DBG_PRINT(INFO_DBG,
+					  "pci_alloc_consistent failed for TxDL\n");
 				return -ENOMEM;
 			}
 			/* If we got a zero DMA address(can happen on
@@ -725,17 +724,14 @@ static int init_shared_mem(struct s2io_nic *nic)
 			if (!tmp_p) {
 				mac_control->zerodma_virt_addr = tmp_v;
 				DBG_PRINT(INIT_DBG,
-					  "%s: Zero DMA address for TxDL. ",
-					  dev->name);
-				DBG_PRINT(INIT_DBG,
-					  "Virtual address %p\n", tmp_v);
+					  "%s: Zero DMA address for TxDL. "
+					  "Virtual address %p\n",
+					  dev->name, tmp_v);
 				tmp_v = pci_alloc_consistent(nic->pdev,
 							     PAGE_SIZE, &tmp_p);
 				if (!tmp_v) {
 					DBG_PRINT(INFO_DBG,
-						  "pci_alloc_consistent ");
-					DBG_PRINT(INFO_DBG,
-						  "failed for TxDL\n");
+						  "pci_alloc_consistent failed for TxDL\n");
 					return -ENOMEM;
 				}
 				mem_allocated += PAGE_SIZE;
@@ -771,9 +767,9 @@ static int init_shared_mem(struct s2io_nic *nic)
 		struct ring_info *ring = &mac_control->rings[i];
 
 		if (rx_cfg->num_rxd % (rxd_count[nic->rxd_mode] + 1)) {
-			DBG_PRINT(ERR_DBG, "%s: RxD count of ", dev->name);
-			DBG_PRINT(ERR_DBG, "Ring%d is not a multiple of ", i);
-			DBG_PRINT(ERR_DBG, "RxDs per Block");
+			DBG_PRINT(ERR_DBG, "%s: Ring%d RxD count is not a "
+				  "multiple of RxDs per Block\n",
+				  dev->name, i);
 			return FAILURE;
 		}
 		size += rx_cfg->num_rxd;
@@ -927,7 +923,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 	tmp_v_addr = mac_control->stats_mem;
 	mac_control->stats_info = (struct stat_block *)tmp_v_addr;
 	memset(tmp_v_addr, 0, size);
-	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,
+	DBG_PRINT(INIT_DBG, "%s: Ring Mem PHY: 0x%llx\n", dev->name,
 		  (unsigned long long)tmp_p_addr);
 	mac_control->stats_info->sw_stat.mem_allocated += mem_allocated;
 	return SUCCESS;
@@ -994,10 +990,9 @@ static void free_shared_mem(struct s2io_nic *nic)
 					    mac_control->zerodma_virt_addr,
 					    (dma_addr_t)0);
 			DBG_PRINT(INIT_DBG,
-				  "%s: Freeing TxDL with zero DMA addr. ",
-				  dev->name);
-			DBG_PRINT(INIT_DBG, "Virtual address %p\n",
-				  mac_control->zerodma_virt_addr);
+				  "%s: Freeing TxDL with zero DMA address. "
+				  "Virtual address %p\n",
+				  dev->name, mac_control->zerodma_virt_addr);
 			swstats->mem_freed += PAGE_SIZE;
 		}
 		kfree(fifo->list_info);
@@ -1120,6 +1115,7 @@ static int s2io_print_pci_mode(struct s2io_nic *nic)
 	register u64 val64 = 0;
 	int	mode;
 	struct config_param *config = &nic->config;
+	const char *pcimode;
 
 	val64 = readq(&bar0->pci_mode);
 	mode = (u8)GET_PCI_MODE(val64);
@@ -1135,38 +1131,39 @@ static int s2io_print_pci_mode(struct s2io_nic *nic)
 		return mode;
 	}
 
-	DBG_PRINT(ERR_DBG, "%s: Device is on %d bit ",
-		  nic->dev->name, val64 & PCI_MODE_32_BITS ? 32 : 64);
-
 	switch (mode) {
 	case PCI_MODE_PCI_33:
-		DBG_PRINT(ERR_DBG, "33MHz PCI bus\n");
+		pcimode = "33MHz PCI bus";
 		break;
 	case PCI_MODE_PCI_66:
-		DBG_PRINT(ERR_DBG, "66MHz PCI bus\n");
+		pcimode = "66MHz PCI bus";
 		break;
 	case PCI_MODE_PCIX_M1_66:
-		DBG_PRINT(ERR_DBG, "66MHz PCIX(M1) bus\n");
+		pcimode = "66MHz PCIX(M1) bus";
 		break;
 	case PCI_MODE_PCIX_M1_100:
-		DBG_PRINT(ERR_DBG, "100MHz PCIX(M1) bus\n");
+		pcimode = "100MHz PCIX(M1) bus";
 		break;
 	case PCI_MODE_PCIX_M1_133:
-		DBG_PRINT(ERR_DBG, "133MHz PCIX(M1) bus\n");
+		pcimode = "133MHz PCIX(M1) bus";
 		break;
 	case PCI_MODE_PCIX_M2_66:
-		DBG_PRINT(ERR_DBG, "133MHz PCIX(M2) bus\n");
+		pcimode = "133MHz PCIX(M2) bus";
 		break;
 	case PCI_MODE_PCIX_M2_100:
-		DBG_PRINT(ERR_DBG, "200MHz PCIX(M2) bus\n");
+		pcimode = "200MHz PCIX(M2) bus";
 		break;
 	case PCI_MODE_PCIX_M2_133:
-		DBG_PRINT(ERR_DBG, "266MHz PCIX(M2) bus\n");
+		pcimode = "266MHz PCIX(M2) bus";
 		break;
 	default:
-		return -1;	/* Unsupported bus speed */
+		pcimode = "unsupported bus!";
+		mode = -1;
 	}
 
+	DBG_PRINT(ERR_DBG, "%s: Device is on %d bit %s\n",
+		  nic->dev->name, val64 & PCI_MODE_32_BITS ? 32 : 64, pcimode);
+
 	return mode;
 }
 
@@ -1704,9 +1701,9 @@ static int init_nic(struct s2io_nic *nic)
 	/* Disable differentiated services steering logic */
 	for (i = 0; i < 64; i++) {
 		if (rts_ds_steer(nic, i, 0) == FAILURE) {
-			DBG_PRINT(ERR_DBG, "%s: failed rts ds steering",
-				  dev->name);
-			DBG_PRINT(ERR_DBG, "set on codepoint %d\n", i);
+			DBG_PRINT(ERR_DBG,
+				  "%s: rts_ds_steer failed on codepoint %d\n",
+				  dev->name, i);
 			return -ENODEV;
 		}
 	}
@@ -1783,7 +1780,7 @@ static int init_nic(struct s2io_nic *nic)
 				break;
 
 			if (time > 10) {
-				DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
+				DBG_PRINT(ERR_DBG, "%s: RTI init failed\n",
 					  dev->name);
 				return -ENODEV;
 			}
@@ -2189,35 +2186,35 @@ static int verify_xena_quiescence(struct s2io_nic *sp)
 	mode = s2io_verify_pci_mode(sp);
 
 	if (!(val64 & ADAPTER_STATUS_TDMA_READY)) {
-		DBG_PRINT(ERR_DBG, "%s", "TDMA is not ready!");
+		DBG_PRINT(ERR_DBG, "TDMA is not ready!\n");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_RDMA_READY)) {
-		DBG_PRINT(ERR_DBG, "%s", "RDMA is not ready!");
+		DBG_PRINT(ERR_DBG, "RDMA is not ready!\n");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_PFC_READY)) {
-		DBG_PRINT(ERR_DBG, "%s", "PFC is not ready!");
+		DBG_PRINT(ERR_DBG, "PFC is not ready!\n");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_TMAC_BUF_EMPTY)) {
-		DBG_PRINT(ERR_DBG, "%s", "TMAC BUF is not empty!");
+		DBG_PRINT(ERR_DBG, "TMAC BUF is not empty!\n");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_PIC_QUIESCENT)) {
-		DBG_PRINT(ERR_DBG, "%s", "PIC is not QUIESCENT!");
+		DBG_PRINT(ERR_DBG, "PIC is not QUIESCENT!\n");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_MC_DRAM_READY)) {
-		DBG_PRINT(ERR_DBG, "%s", "MC_DRAM is not ready!");
+		DBG_PRINT(ERR_DBG, "MC_DRAM is not ready!\n");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_MC_QUEUES_READY)) {
-		DBG_PRINT(ERR_DBG, "%s", "MC_QUEUES is not ready!");
+		DBG_PRINT(ERR_DBG, "MC_QUEUES is not ready!\n");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_M_PLL_LOCK)) {
-		DBG_PRINT(ERR_DBG, "%s", "M_PLL is not locked!");
+		DBG_PRINT(ERR_DBG, "M_PLL is not locked!\n");
 		return 0;
 	}
 
@@ -2229,12 +2226,12 @@ static int verify_xena_quiescence(struct s2io_nic *sp)
 	if (!(val64 & ADAPTER_STATUS_P_PLL_LOCK) &&
 	    sp->device_type == XFRAME_II_DEVICE &&
 	    mode != PCI_MODE_PCI_33) {
-		DBG_PRINT(ERR_DBG, "%s", "P_PLL is not locked!");
+		DBG_PRINT(ERR_DBG, "P_PLL is not locked!\n");
 		return 0;
 	}
 	if (!((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
 	      ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
-		DBG_PRINT(ERR_DBG, "%s", "RC_PRC is not QUIESCENT!");
+		DBG_PRINT(ERR_DBG, "RC_PRC is not QUIESCENT!\n");
 		return 0;
 	}
 	return 1;
@@ -2339,9 +2336,9 @@ static int start_nic(struct s2io_nic *nic)
 	 */
 	val64 = readq(&bar0->adapter_status);
 	if (!verify_xena_quiescence(nic)) {
-		DBG_PRINT(ERR_DBG, "%s: device is not ready, ", dev->name);
-		DBG_PRINT(ERR_DBG, "Adapter status reads: 0x%llx\n",
-			  (unsigned long long)val64);
+		DBG_PRINT(ERR_DBG, "%s: device is not ready, "
+			  "Adapter status reads: 0x%llx\n",
+			  dev->name, (unsigned long long)val64);
 		return FAILURE;
 	}
 
@@ -2455,7 +2452,7 @@ static void free_tx_buffers(struct s2io_nic *nic)
 			}
 		}
 		DBG_PRINT(INTR_DBG,
-			  "%s:forcibly freeing %d skbs on FIFO%d\n",
+			  "%s: forcibly freeing %d skbs on FIFO%d\n",
 			  dev->name, cnt, i);
 		fifo->tx_curr_get_info.offset = 0;
 		fifo->tx_curr_put_info.offset = 0;
@@ -2547,8 +2544,8 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 		if ((block_no == block_no1) &&
 		    (off == ring->rx_curr_get_info.offset) &&
 		    (rxdp->Host_Control)) {
-			DBG_PRINT(INTR_DBG, "%s: Get and Put", ring->dev->name);
-			DBG_PRINT(INTR_DBG, " info equated\n");
+			DBG_PRINT(INTR_DBG, "%s: Get and Put info equated\n",
+				  ring->dev->name);
 			goto end;
 		}
 		if (off && (off == ring->rxd_count)) {
@@ -2583,8 +2580,8 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 		/* allocate skb */
 		skb = dev_alloc_skb(size);
 		if (!skb) {
-			DBG_PRINT(INFO_DBG, "%s: Out of ", ring->dev->name);
-			DBG_PRINT(INFO_DBG, "memory to allocate SKBs\n");
+			DBG_PRINT(INFO_DBG, "%s: Could not allocate skb\n",
+				  ring->dev->name);
 			if (first_rxdp) {
 				wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
@@ -2806,7 +2803,7 @@ static void free_rx_buffers(struct s2io_nic *sp)
 		ring->rx_curr_put_info.offset = 0;
 		ring->rx_curr_get_info.offset = 0;
 		ring->rx_bufs_left = 0;
-		DBG_PRINT(INIT_DBG, "%s:Freed 0x%x Rx Buffers on ring%d\n",
+		DBG_PRINT(INIT_DBG, "%s: Freed 0x%x Rx Buffers on ring%d\n",
 			  dev->name, buf_cnt, i);
 	}
 }
@@ -2814,8 +2811,8 @@ static void free_rx_buffers(struct s2io_nic *sp)
 static int s2io_chk_rx_buffers(struct s2io_nic *nic, struct ring_info *ring)
 {
 	if (fill_rx_buffers(nic, ring, 0) == -ENOMEM) {
-		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
-		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
+		DBG_PRINT(INFO_DBG, "%s: Out of memory in Rx Intr!!\n",
+			  ring->dev->name);
 	}
 	return 0;
 }
@@ -2938,8 +2935,9 @@ static void s2io_netpoll(struct net_device *dev)
 		struct ring_info *ring = &mac_control->rings[i];
 
 		if (fill_rx_buffers(nic, ring, 0) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
+			DBG_PRINT(INFO_DBG,
+				  "%s: Out of memory in Rx Netpoll!!\n",
+				  dev->name);
 			break;
 		}
 	}
@@ -2991,9 +2989,8 @@ static int rx_intr_handler(struct ring_info *ring_data, int budget)
 		}
 		skb = (struct sk_buff *)((unsigned long)rxdp->Host_Control);
 		if (skb == NULL) {
-			DBG_PRINT(ERR_DBG, "%s: The skb is ",
+			DBG_PRINT(ERR_DBG, "%s: NULL skb in Rx Intr\n",
 				  ring_data->dev->name);
-			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
 			return 0;
 		}
 		if (ring_data->rxd_mode == RXD_MODE_1) {
@@ -3126,8 +3123,8 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		skb = s2io_txdl_getskb(fifo_data, txdlp, get_info.offset);
 		if (skb == NULL) {
 			spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
-			DBG_PRINT(ERR_DBG, "%s: Null skb ", __func__);
-			DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
+			DBG_PRINT(ERR_DBG, "%s: NULL skb in Tx Free Intr\n",
+				  __func__);
 			return;
 		}
 		pkt_cnt++;
@@ -3266,22 +3263,22 @@ static void s2io_chk_xpak_counter(u64 *counter, u64 * regs_stat, u32 index,
 		if (val64 == 3) {
 			switch (type) {
 			case 1:
-				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
-					  "service. Excessive temperatures may "
-					  "result in premature transceiver "
-					  "failure \n");
+				DBG_PRINT(ERR_DBG,
+					  "Take Xframe NIC out of service.\n");
+				DBG_PRINT(ERR_DBG,
+"Excessive temperatures may result in premature transceiver failure.\n");
 				break;
 			case 2:
-				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
-					  "service Excessive bias currents may "
-					  "indicate imminent laser diode "
-					  "failure \n");
+				DBG_PRINT(ERR_DBG,
+					  "Take Xframe NIC out of service.\n");
+				DBG_PRINT(ERR_DBG,
+"Excessive bias currents may indicate imminent laser diode failure.\n");
 				break;
 			case 3:
-				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
-					  "service Excessive laser output "
-					  "power may saturate far-end "
-					  "receiver\n");
+				DBG_PRINT(ERR_DBG,
+					  "Take Xframe NIC out of service.\n");
+				DBG_PRINT(ERR_DBG,
+"Excessive laser output power may saturate far-end receiver.\n");
 				break;
 			default:
 				DBG_PRINT(ERR_DBG,
@@ -3321,15 +3318,16 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	val64 = 0x0;
 	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
 	if ((val64 == 0xFFFF) || (val64 == 0x0000)) {
-		DBG_PRINT(ERR_DBG, "ERR: MDIO slave access failed - "
-			  "Returned %llx\n", (unsigned long long)val64);
+		DBG_PRINT(ERR_DBG,
+			  "ERR: MDIO slave access failed - Returned %llx\n",
+			  (unsigned long long)val64);
 		return;
 	}
 
 	/* Check for the expected value of control reg 1 */
 	if (val64 != MDIO_CTRL1_SPEED10G) {
-		DBG_PRINT(ERR_DBG, "Incorrect value at PMA address 0x0000 - ");
-		DBG_PRINT(ERR_DBG, "Returned: %llx- Expected: 0x%x\n",
+		DBG_PRINT(ERR_DBG, "Incorrect value at PMA address 0x0000 - "
+			  "Returned: %llx- Expected: 0x%x\n",
 			  (unsigned long long)val64, MDIO_CTRL1_SPEED10G);
 		return;
 	}
@@ -3481,7 +3479,7 @@ static void s2io_reset(struct s2io_nic *sp)
 	struct stat_block *stats;
 	struct swStat *swstats;
 
-	DBG_PRINT(INIT_DBG, "%s - Resetting XFrame card %s\n",
+	DBG_PRINT(INIT_DBG, "%s: Resetting XFrame card %s\n",
 		  __func__, sp->dev->name);
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
@@ -3618,10 +3616,9 @@ static int s2io_set_swapper(struct s2io_nic *sp)
 			i++;
 		}
 		if (i == 4) {
-			DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, ",
-				  dev->name);
-			DBG_PRINT(ERR_DBG, "feedback read %llx\n",
-				  (unsigned long long)val64);
+			DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, "
+				  "feedback read %llx\n",
+				  dev->name, (unsigned long long)val64);
 			return FAILURE;
 		}
 		valr = value[i];
@@ -3650,8 +3647,8 @@ static int s2io_set_swapper(struct s2io_nic *sp)
 		}
 		if (i == 4) {
 			unsigned long long x = val64;
-			DBG_PRINT(ERR_DBG, "Write failed, Xmsi_addr ");
-			DBG_PRINT(ERR_DBG, "reads:0x%llx\n", x);
+			DBG_PRINT(ERR_DBG,
+				  "Write failed, Xmsi_addr reads:0x%llx\n", x);
 			return FAILURE;
 		}
 	}
@@ -3711,10 +3708,9 @@ static int s2io_set_swapper(struct s2io_nic *sp)
 	val64 = readq(&bar0->pif_rd_swapper_fb);
 	if (val64 != 0x0123456789ABCDEFULL) {
 		/* Endian settings are incorrect, calls for another dekko. */
-		DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, ",
-			  dev->name);
-		DBG_PRINT(ERR_DBG, "feedback read %llx\n",
-			  (unsigned long long)val64);
+		DBG_PRINT(ERR_DBG,
+			  "%s: Endian settings are wrong, feedback read %llx\n",
+			  dev->name, (unsigned long long)val64);
 		return FAILURE;
 	}
 
@@ -3758,7 +3754,8 @@ static void restore_xmsi_data(struct s2io_nic *nic)
 		val64 = (s2BIT(7) | s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, msix_index)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
+			DBG_PRINT(ERR_DBG, "%s: index: %d failed\n",
+				  __func__, msix_index);
 			continue;
 		}
 	}
@@ -3779,7 +3776,8 @@ static void store_xmsi_data(struct s2io_nic *nic)
 		val64 = (s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, msix_index)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
+			DBG_PRINT(ERR_DBG, "%s: index: %d failed\n",
+				  __func__, msix_index);
 			continue;
 		}
 		addr = readq(&bar0->xmsi_address);
@@ -3851,7 +3849,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	ret = pci_enable_msix(nic->pdev, nic->entries, nic->num_entries);
 	/* We fail init if error or we get less vectors than min required */
 	if (ret) {
-		DBG_PRINT(ERR_DBG, "s2io: Enabling MSI-X failed\n");
+		DBG_PRINT(ERR_DBG, "Enabling MSI-X failed\n");
 		kfree(nic->entries);
 		swstats->mem_freed += nic->num_entries *
 			sizeof(struct msix_entry);
@@ -3915,8 +3913,8 @@ static int s2io_test_msi(struct s2io_nic *sp)
 	if (!sp->msi_detected) {
 		/* MSI(X) test failed, go back to INTx mode */
 		DBG_PRINT(ERR_DBG, "%s: PCI %s: No interrupt was generated "
-			  "using MSI(X) during test\n", sp->dev->name,
-			  pci_name(pdev));
+			  "using MSI(X) during test\n",
+			  sp->dev->name, pci_name(pdev));
 
 		err = -EOPNOTSUPP;
 	}
@@ -4095,7 +4093,7 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	DBG_PRINT(TX_DBG, "%s: In Neterion Tx routine\n", dev->name);
 
 	if (unlikely(skb->len <= 0)) {
-		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
+		DBG_PRINT(TX_DBG, "%s: Buffer has no data..\n", dev->name);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -5052,18 +5050,17 @@ static void s2io_set_multicast(struct net_device *dev)
 
 		val64 = readq(&bar0->mac_cfg);
 		sp->promisc_flg = 0;
-		DBG_PRINT(INFO_DBG, "%s: left promiscuous mode\n",
-			  dev->name);
+		DBG_PRINT(INFO_DBG, "%s: left promiscuous mode\n", dev->name);
 	}
 
 	/*  Update individual M_CAST address list */
 	if ((!sp->m_cast_flg) && dev->mc_count) {
 		if (dev->mc_count >
 		    (config->max_mc_addr - config->max_mac_addr)) {
-			DBG_PRINT(ERR_DBG, "%s: No more Rx filters ",
+			DBG_PRINT(ERR_DBG,
+				  "%s: No more Rx filters can be added - "
+				  "please enable ALL_MULTI instead\n",
 				  dev->name);
-			DBG_PRINT(ERR_DBG, "can be added, please enable ");
-			DBG_PRINT(ERR_DBG, "ALL_MULTI instead\n");
 			return;
 		}
 
@@ -5086,8 +5083,9 @@ static void s2io_set_multicast(struct net_device *dev)
 			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
 						  RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
 						  S2IO_BIT_RESET)) {
-				DBG_PRINT(ERR_DBG, "%s: Adding ", dev->name);
-				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
+				DBG_PRINT(ERR_DBG,
+					  "%s: Adding Multicasts failed\n",
+					  dev->name);
 				return;
 			}
 		}
@@ -5117,8 +5115,9 @@ static void s2io_set_multicast(struct net_device *dev)
 			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
 						  RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
 						  S2IO_BIT_RESET)) {
-				DBG_PRINT(ERR_DBG, "%s: Adding ", dev->name);
-				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
+				DBG_PRINT(ERR_DBG,
+					  "%s: Adding Multicasts failed\n",
+					  dev->name);
 				return;
 			}
 		}
@@ -5552,7 +5551,7 @@ static void s2io_ethtool_gringparam(struct net_device *dev,
 	for (i = 0 ; i < sp->config.tx_fifo_num ; i++)
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
 
-	DBG_PRINT(INFO_DBG, "\nmax txds : %d\n", sp->config.max_txds);
+	DBG_PRINT(INFO_DBG, "max txds: %d\n", sp->config.max_txds);
 	ering->tx_pending = tx_desc_count;
 	rx_desc_count = 0;
 	for (i = 0 ; i < sp->config.rx_ring_num ; i++)
@@ -5886,8 +5885,10 @@ static int s2io_ethtool_seeprom(struct net_device *dev,
 
 	if (eeprom->magic != (sp->pdev->vendor | (sp->pdev->device << 16))) {
 		DBG_PRINT(ERR_DBG,
-			  "ETHTOOL_WRITE_EEPROM Err: Magic value ");
-		DBG_PRINT(ERR_DBG, "is wrong, Its not 0x%x\n", eeprom->magic);
+			  "ETHTOOL_WRITE_EEPROM Err: "
+			  "Magic value is wrong, it is 0x%x should be 0x%x\n",
+			  (sp->pdev->vendor | (sp->pdev->device << 16)),
+			  eeprom->magic);
 		return -EFAULT;
 	}
 
@@ -5900,9 +5901,8 @@ static int s2io_ethtool_seeprom(struct net_device *dev,
 
 		if (write_eeprom(sp, (eeprom->offset + cnt), valid, 0)) {
 			DBG_PRINT(ERR_DBG,
-				  "ETHTOOL_WRITE_EEPROM Err: Cannot ");
-			DBG_PRINT(ERR_DBG,
-				  "write into the specified offset\n");
+				  "ETHTOOL_WRITE_EEPROM Err: "
+				  "Cannot write into the specified offset\n");
 			return -EFAULT;
 		}
 		cnt++;
@@ -5934,13 +5934,13 @@ static int s2io_register_test(struct s2io_nic *sp, uint64_t *data)
 	val64 = readq(&bar0->pif_rd_swapper_fb);
 	if (val64 != 0x123456789abcdefULL) {
 		fail = 1;
-		DBG_PRINT(INFO_DBG, "Read Test level 1 fails\n");
+		DBG_PRINT(INFO_DBG, "Read Test level %d fails\n", 1);
 	}
 
 	val64 = readq(&bar0->rmac_pause_cfg);
 	if (val64 != 0xc000ffff00000000ULL) {
 		fail = 1;
-		DBG_PRINT(INFO_DBG, "Read Test level 2 fails\n");
+		DBG_PRINT(INFO_DBG, "Read Test level %d fails\n", 2);
 	}
 
 	val64 = readq(&bar0->rx_queue_cfg);
@@ -5950,13 +5950,13 @@ static int s2io_register_test(struct s2io_nic *sp, uint64_t *data)
 		exp_val = 0x0808080808080808ULL;
 	if (val64 != exp_val) {
 		fail = 1;
-		DBG_PRINT(INFO_DBG, "Read Test level 3 fails\n");
+		DBG_PRINT(INFO_DBG, "Read Test level %d fails\n", 3);
 	}
 
 	val64 = readq(&bar0->xgxs_efifo_cfg);
 	if (val64 != 0x000000001923141EULL) {
 		fail = 1;
-		DBG_PRINT(INFO_DBG, "Read Test level 4 fails\n");
+		DBG_PRINT(INFO_DBG, "Read Test level %d fails\n", 4);
 	}
 
 	val64 = 0x5A5A5A5A5A5A5A5AULL;
@@ -5964,7 +5964,7 @@ static int s2io_register_test(struct s2io_nic *sp, uint64_t *data)
 	val64 = readq(&bar0->xmsi_data);
 	if (val64 != 0x5A5A5A5A5A5A5A5AULL) {
 		fail = 1;
-		DBG_PRINT(ERR_DBG, "Write Test level 1 fails\n");
+		DBG_PRINT(ERR_DBG, "Write Test level %d fails\n", 1);
 	}
 
 	val64 = 0xA5A5A5A5A5A5A5A5ULL;
@@ -5972,7 +5972,7 @@ static int s2io_register_test(struct s2io_nic *sp, uint64_t *data)
 	val64 = readq(&bar0->xmsi_data);
 	if (val64 != 0xA5A5A5A5A5A5A5A5ULL) {
 		fail = 1;
-		DBG_PRINT(ERR_DBG, "Write Test level 2 fails\n");
+		DBG_PRINT(ERR_DBG, "Write Test level %d fails\n", 2);
 	}
 
 	*data = fail;
@@ -6825,8 +6825,9 @@ static void s2io_set_link(struct work_struct *work)
 				}
 				nic->device_enabled_once = true;
 			} else {
-				DBG_PRINT(ERR_DBG, "%s: Error: ", dev->name);
-				DBG_PRINT(ERR_DBG, "device is not Quiescent\n");
+				DBG_PRINT(ERR_DBG,
+					  "%s: Error: device is not Quiescent\n",
+					  dev->name);
 				s2io_stop_all_tx_queue(nic);
 			}
 		}
@@ -6876,9 +6877,9 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate ");
-				DBG_PRINT(INFO_DBG, "1 buf mode SKBs\n");
+				DBG_PRINT(INFO_DBG,
+					  "%s: Out of memory to allocate %s\n",
+					  dev->name, "1 buf mode SKBs");
 				stats->mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
@@ -6905,9 +6906,10 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate ");
-				DBG_PRINT(INFO_DBG, "2 buf mode SKBs\n");
+				DBG_PRINT(INFO_DBG,
+					  "%s: Out of memory to allocate %s\n",
+					  dev->name,
+					  "2 buf mode SKBs");
 				stats->mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
@@ -7095,8 +7097,8 @@ static int s2io_add_isr(struct s2io_nic *sp)
 		}
 		if (!err) {
 			pr_info("MSI-X-RX %d entries enabled\n", --msix_rx_cnt);
-			DBG_PRINT(INFO_DBG, "MSI-X-TX entries enabled"
-				  " through alarm vector\n");
+			DBG_PRINT(INFO_DBG,
+				  "MSI-X-TX entries enabled through alarm vector\n");
 		}
 	}
 	if (sp->config.intr_type == INTA) {
@@ -7176,8 +7178,8 @@ static void do_s2io_card_down(struct s2io_nic *sp, int do_io)
 		msleep(50);
 		cnt++;
 		if (cnt == 10) {
-			DBG_PRINT(ERR_DBG, "s2io_close:Device not Quiescent ");
-			DBG_PRINT(ERR_DBG, "adaper status reads 0x%llx\n",
+			DBG_PRINT(ERR_DBG, "Device not Quiescent - "
+				  "adapter status reads 0x%llx\n",
 				  (unsigned long long)val64);
 			break;
 		}
@@ -7628,7 +7630,7 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 			    u8 *dev_multiq)
 {
 	if ((tx_fifo_num > MAX_TX_FIFOS) || (tx_fifo_num < 1)) {
-		DBG_PRINT(ERR_DBG, "s2io: Requested number of tx fifos "
+		DBG_PRINT(ERR_DBG, "Requested number of tx fifos "
 			  "(%d) not supported\n", tx_fifo_num);
 
 		if (tx_fifo_num < 1)
@@ -7636,8 +7638,7 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 		else
 			tx_fifo_num = MAX_TX_FIFOS;
 
-		DBG_PRINT(ERR_DBG, "s2io: Default to %d ", tx_fifo_num);
-		DBG_PRINT(ERR_DBG, "tx fifos\n");
+		DBG_PRINT(ERR_DBG, "Default to %d tx fifos\n", tx_fifo_num);
 	}
 
 	if (multiq)
@@ -7646,7 +7647,7 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 	if (tx_steering_type && (1 == tx_fifo_num)) {
 		if (tx_steering_type != TX_DEFAULT_STEERING)
 			DBG_PRINT(ERR_DBG,
-				  "s2io: Tx steering is not supported with "
+				  "Tx steering is not supported with "
 				  "one fifo. Disabling Tx steering.\n");
 		tx_steering_type = NO_STEERING;
 	}
@@ -7654,21 +7655,21 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 	if ((tx_steering_type < NO_STEERING) ||
 	    (tx_steering_type > TX_DEFAULT_STEERING)) {
 		DBG_PRINT(ERR_DBG,
-			  "s2io: Requested transmit steering not supported\n");
-		DBG_PRINT(ERR_DBG, "s2io: Disabling transmit steering\n");
+			  "Requested transmit steering not supported\n");
+		DBG_PRINT(ERR_DBG, "Disabling transmit steering\n");
 		tx_steering_type = NO_STEERING;
 	}
 
 	if (rx_ring_num > MAX_RX_RINGS) {
 		DBG_PRINT(ERR_DBG,
-			  "s2io: Requested number of rx rings not supported\n");
-		DBG_PRINT(ERR_DBG, "s2io: Default to %d rx rings\n",
+			  "Requested number of rx rings not supported\n");
+		DBG_PRINT(ERR_DBG, "Default to %d rx rings\n",
 			  MAX_RX_RINGS);
 		rx_ring_num = MAX_RX_RINGS;
 	}
 
 	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
-		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
+		DBG_PRINT(ERR_DBG, "Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
@@ -7676,14 +7677,14 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 	if ((*dev_intr_type == MSI_X) &&
 	    ((pdev->device != PCI_DEVICE_ID_HERC_WIN) &&
 	     (pdev->device != PCI_DEVICE_ID_HERC_UNI))) {
-		DBG_PRINT(ERR_DBG, "s2io: Xframe I does not support MSI_X. "
+		DBG_PRINT(ERR_DBG, "Xframe I does not support MSI_X. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
 
 	if ((rx_ring_mode != 1) && (rx_ring_mode != 2)) {
-		DBG_PRINT(ERR_DBG, "s2io: Requested ring mode not supported\n");
-		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 1-buffer mode\n");
+		DBG_PRINT(ERR_DBG, "Requested ring mode not supported\n");
+		DBG_PRINT(ERR_DBG, "Defaulting to 1-buffer mode\n");
 		rx_ring_mode = 1;
 	}
 	return SUCCESS;
@@ -7776,12 +7777,12 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	ret = pci_enable_device(pdev);
 	if (ret) {
 		DBG_PRINT(ERR_DBG,
-			  "s2io_init_nic: pci_enable_device failed\n");
+			  "%s: pci_enable_device failed\n", __func__);
 		return ret;
 	}
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");
+		DBG_PRINT(INIT_DBG, "%s: Using 64bit DMA\n", __func__);
 		dma_flag = true;
 		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 			DBG_PRINT(ERR_DBG,
@@ -7791,14 +7792,14 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 			return -ENOMEM;
 		}
 	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 32bit DMA\n");
+		DBG_PRINT(INIT_DBG, "%s: Using 32bit DMA\n", __func__);
 	} else {
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
 	ret = pci_request_regions(pdev, s2io_driver_name);
 	if (ret) {
-		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n",
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x\n",
 			  __func__, ret);
 		pci_disable_device(pdev);
 		return -ENODEV;
@@ -7992,7 +7993,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	/* Setting swapper control on the NIC, for proper reset operation */
 	if (s2io_set_swapper(sp)) {
-		DBG_PRINT(ERR_DBG, "%s:swapper settings are wrong\n",
+		DBG_PRINT(ERR_DBG, "%s: swapper settings are wrong\n",
 			  dev->name);
 		ret = -EAGAIN;
 		goto set_swap_failed;
@@ -8002,8 +8003,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_verify_pci_mode(sp);
 		if (mode < 0) {
-			DBG_PRINT(ERR_DBG, "%s: ", __func__);
-			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode\n");
+			DBG_PRINT(ERR_DBG, "%s: Unsupported PCI bus mode\n",
+				  __func__);
 			ret = -EBADSLT;
 			goto set_swap_failed;
 		}
@@ -8021,7 +8022,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		if (ret) {
 
 			DBG_PRINT(ERR_DBG,
-				  "s2io: MSI-X requested but failed to enable\n");
+				  "MSI-X requested but failed to enable\n");
 			sp->config.intr_type = INTA;
 		}
 	}
@@ -8137,12 +8138,11 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		  sp->product_name, pdev->revision);
 	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
 		  s2io_driver_version);
-	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: %pM\n", dev->name, dev->dev_addr);
-	DBG_PRINT(ERR_DBG, "SERIAL NUMBER: %s\n", sp->serial_num);
+	DBG_PRINT(ERR_DBG, "%s: MAC Address: %pM\n", dev->name, dev->dev_addr);
+	DBG_PRINT(ERR_DBG, "Serial number: %s\n", sp->serial_num);
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_print_pci_mode(sp);
 		if (mode < 0) {
-			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode\n");
 			ret = -EBADSLT;
 			unregister_netdev(dev);
 			goto set_swap_failed;
@@ -8532,8 +8532,9 @@ static int s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer,
 			*lro = l_lro;
 
 			if ((*lro)->tcp_next_seq != ntohl(tcph->seq)) {
-				DBG_PRINT(INFO_DBG, "%s:Out of order. expected "
-					  "0x%x, actual 0x%x\n", __func__,
+				DBG_PRINT(INFO_DBG, "%s: Out of sequence. "
+					  "expected 0x%x, actual 0x%x\n",
+					  __func__,
 					  (*lro)->tcp_next_seq,
 					  ntohl(tcph->seq));
 
@@ -8571,7 +8572,7 @@ static int s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer,
 	}
 
 	if (ret == 0) { /* sessions exceeded */
-		DBG_PRINT(INFO_DBG, "%s:All LRO sessions already in use\n",
+		DBG_PRINT(INFO_DBG, "%s: All LRO sessions already in use\n",
 			  __func__);
 		*lro = NULL;
 		return ret;
@@ -8593,7 +8594,7 @@ static int s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer,
 		}
 		break;
 	default:
-		DBG_PRINT(ERR_DBG, "%s:Dont know, can't say!!\n", __func__);
+		DBG_PRINT(ERR_DBG, "%s: Don't know, can't say!!\n", __func__);
 		break;
 	}
 
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index d5c5be6..47c36e0 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -64,7 +64,10 @@ enum {
 static int debug_level = ERR_DBG;
 
 /* DEBUG message print. */
-#define DBG_PRINT(dbg_level, args...)  if(!(debug_level<dbg_level)) printk(args)
+#define DBG_PRINT(dbg_level, fmt, args...) do {			\
+	if (dbg_level >= debug_level)				\
+		pr_info(fmt, ##args);				\
+	} while (0)
 
 /* Protocol assist features of the NIC */
 #define L3_CKSUM_OK 0xFFFF
