From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: [PATCH 2/3] Freescale QE UCC gigabit ethernet driver
Date: Thu, 6 Jul 2006 20:02:35 +0800
Message-ID: <4879B0C6C249214CBE7AB04453F84E4DF209@zch01exm20.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:58514 "EHLO
	de01egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1030215AbWGFMAW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 08:00:22 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id k66DHXjs017489
	for <netdev@vger.kernel.org>; Thu, 6 Jul 2006 07:17:33 -0600 (MDT)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id k66C0Ca2018806
	for <netdev@vger.kernel.org>; Thu, 6 Jul 2006 07:00:13 -0500 (CDT)
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>, <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

continues [PATCH 1/3] Freescale QE UCC gigabit ethernet driver

---
+
+static int
ugeth_82xx_filtering_clear_all_addr_in_hash(ucc_geth_private_t *
+						       ugeth,
+						       enet_addr_type_e
+						       enet_addr_type)
+{
+	ucc_geth_82xx_address_filtering_pram_t *p_82xx_addr_filt;
+	ucc_fast_private_t *uccf;
+	comm_dir_e comm_dir;
+	struct list_head *p_lh;
+	u16 i, num;
+	u32 *addr_h, *addr_l;
+	u8 *p_counter;
+
+	uccf = ugeth->uccf;
+
+	p_82xx_addr_filt =
+	    (ucc_geth_82xx_address_filtering_pram_t *)
ugeth->p_rx_glbl_pram->
+	    addressfiltering;
+
+	if (enet_addr_type == ENET_ADDR_TYPE_GROUP) {
+		addr_h = &(p_82xx_addr_filt->gaddr_h);
+		addr_l = &(p_82xx_addr_filt->gaddr_l);
+		p_lh = &ugeth->group_hash_q;
+		p_counter = &(ugeth->numGroupAddrInHash);
+	} else if (enet_addr_type == ENET_ADDR_TYPE_INDIVIDUAL) {
+		addr_h = &(p_82xx_addr_filt->iaddr_h);
+		addr_l = &(p_82xx_addr_filt->iaddr_l);
+		p_lh = &ugeth->ind_hash_q;
+		p_counter = &(ugeth->numIndAddrInHash);
+	} else
+		return -EINVAL;
+
+	comm_dir = 0;
+	if (uccf->enabled_tx)
+		comm_dir |= COMM_DIR_TX;
+	if (uccf->enabled_rx)
+		comm_dir |= COMM_DIR_RX;
+	if (comm_dir)
+		ugeth_disable(ugeth, comm_dir);
+
+	/* Clear the hash table. */
+	out_be32(addr_h, 0x00000000);
+	out_be32(addr_l, 0x00000000);
+
+	if (!p_lh)
+		return 0;
+
+	num = *p_counter;
+
+	/* Delete all remaining CQ elements */
+	for (i = 0; i < num; i++)
+
put_enet_addr_container(ENET_ADDR_CONT_ENTRY(dequeue(p_lh)));
+
+	*p_counter = 0;
+
+	if (comm_dir)
+		ugeth_enable(ugeth, comm_dir);
+
+	return 0;
+}
+
+#ifdef CONFIG_UGETH_FILTERING
+static int ugeth_82xx_filtering_add_addr_in_paddr(ucc_geth_private_t
*ugeth,
+						  enet_addr_t
*p_enet_addr,
+						  u8 paddr_num)
+{
+	int i;
+
+	if ((*p_enet_addr)[0] & ENET_GROUP_ADDR)
+		ugeth_warn
+		    ("%s: multicast address added to paddr will have no
"
+		     "effect - is this what you wanted?",
+		     __FUNCTION__);
+
+	ugeth->indAddrRegUsed[paddr_num] = 1;	/* mark this paddr as
used */
+	/* store address in our database */
+	for (i = 0; i < ENET_NUM_OCTETS_PER_ADDRESS; i++)
+		ugeth->paddr[paddr_num][i] = (*p_enet_addr)[i];
+	/* put in hardware */
+	return hw_add_addr_in_paddr(ugeth, p_enet_addr, paddr_num);
+}
+#endif /* CONFIG_UGETH_FILTERING */
+
+static int ugeth_82xx_filtering_clear_addr_in_paddr(ucc_geth_private_t
*ugeth,
+						    u8 paddr_num)
+{
+	ugeth->indAddrRegUsed[paddr_num] = 0; /* mark this paddr as not
used */
+	return hw_clear_addr_in_paddr(ugeth, paddr_num);/* clear in
hardware */
+}
+
+static void ucc_geth_memclean(ucc_geth_private_t *ugeth)
+{
+	u16 i, j;
+	u8 *bd;
+
+	if (!ugeth)
+		return;
+
+	if (ugeth->uccf)
+		ucc_fast_free(ugeth->uccf);
+
+	if (ugeth->p_thread_data_tx) {
+		qe_muram_free(ugeth->thread_dat_tx_offset);
+		ugeth->p_thread_data_tx = NULL;
+	}
+	if (ugeth->p_thread_data_rx) {
+		qe_muram_free(ugeth->thread_dat_rx_offset);
+		ugeth->p_thread_data_rx = NULL;
+	}
+	if (ugeth->p_exf_glbl_param) {
+		qe_muram_free(ugeth->exf_glbl_param_offset);
+		ugeth->p_exf_glbl_param = NULL;
+	}
+	if (ugeth->p_rx_glbl_pram) {
+		qe_muram_free(ugeth->rx_glbl_pram_offset);
+		ugeth->p_rx_glbl_pram = NULL;
+	}
+	if (ugeth->p_tx_glbl_pram) {
+		qe_muram_free(ugeth->tx_glbl_pram_offset);
+		ugeth->p_tx_glbl_pram = NULL;
+	}
+	if (ugeth->p_send_q_mem_reg) {
+		qe_muram_free(ugeth->send_q_mem_reg_offset);
+		ugeth->p_send_q_mem_reg = NULL;
+	}
+	if (ugeth->p_scheduler) {
+		qe_muram_free(ugeth->scheduler_offset);
+		ugeth->p_scheduler = NULL;
+	}
+	if (ugeth->p_tx_fw_statistics_pram) {
+		qe_muram_free(ugeth->tx_fw_statistics_pram_offset);
+		ugeth->p_tx_fw_statistics_pram = NULL;
+	}
+	if (ugeth->p_rx_fw_statistics_pram) {
+		qe_muram_free(ugeth->rx_fw_statistics_pram_offset);
+		ugeth->p_rx_fw_statistics_pram = NULL;
+	}
+	if (ugeth->p_rx_irq_coalescing_tbl) {
+		qe_muram_free(ugeth->rx_irq_coalescing_tbl_offset);
+		ugeth->p_rx_irq_coalescing_tbl = NULL;
+	}
+	if (ugeth->p_rx_bd_qs_tbl) {
+		qe_muram_free(ugeth->rx_bd_qs_tbl_offset);
+		ugeth->p_rx_bd_qs_tbl = NULL;
+	}
+	if (ugeth->p_init_enet_param_shadow) {
+		return_init_enet_entries(ugeth,
+
&(ugeth->p_init_enet_param_shadow->
+					   rxthread[0]),
+					 ENET_INIT_PARAM_MAX_ENTRIES_RX,
+					 ugeth->ug_info->riscRx, 1);
+		return_init_enet_entries(ugeth,
+
&(ugeth->p_init_enet_param_shadow->
+					   txthread[0]),
+					 ENET_INIT_PARAM_MAX_ENTRIES_TX,
+					 ugeth->ug_info->riscTx, 0);
+		kfree(ugeth->p_init_enet_param_shadow);
+		ugeth->p_init_enet_param_shadow = NULL;
+	}
+	for (i = 0; i < ugeth->ug_info->numQueuesTx; i++) {
+		bd = ugeth->p_tx_bd_ring[i];
+		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
+			if (ugeth->tx_skbuff[i][j]) {
+				dma_unmap_single(NULL,
+						 BD_BUFFER_ARG(bd),
+
(BD_STATUS_AND_LENGTH(bd) &
+						  BD_LENGTH_MASK),
+						 DMA_TO_DEVICE);
+
dev_kfree_skb_any(ugeth->tx_skbuff[i][j]);
+				ugeth->tx_skbuff[i][j] = NULL;
+			}
+		}
+
+		kfree(ugeth->tx_skbuff[i]);
+
+		if (ugeth->p_tx_bd_ring[i]) {
+			if (ugeth->ug_info->uf_info.bd_mem_part ==
+			    MEM_PART_SYSTEM)
+				kfree((void
*)ugeth->tx_bd_ring_offset[i]);
+			else if (ugeth->ug_info->uf_info.bd_mem_part ==
+				 MEM_PART_MURAM)
+
qe_muram_free(ugeth->tx_bd_ring_offset[i]);
+			ugeth->p_tx_bd_ring[i] = NULL;
+		}
+	}
+	for (i = 0; i < ugeth->ug_info->numQueuesRx; i++) {
+		if (ugeth->p_rx_bd_ring[i]) {
+			/* Return existing data buffers in ring */
+			bd = ugeth->p_rx_bd_ring[i];
+			for (j = 0; j < ugeth->ug_info->bdRingLenRx[i];
j++) {
+				if (ugeth->rx_skbuff[i][j]) {
+					dma_unmap_single(NULL,
BD_BUFFER(bd),
+						 ugeth->ug_info->
+						 uf_info.
+						 max_rx_buf_length +
+
UCC_GETH_RX_DATA_BUF_ALIGNMENT,
+						 DMA_FROM_DEVICE);
+
+					dev_kfree_skb_any(ugeth->
+
rx_skbuff[i][j]);
+					ugeth->rx_skbuff[i][j] = NULL;
+				}
+				bd += UCC_GETH_SIZE_OF_BD;
+			}
+
+			kfree(ugeth->rx_skbuff[i]);
+
+			if (ugeth->ug_info->uf_info.bd_mem_part ==
+			    MEM_PART_SYSTEM)
+				kfree((void
*)ugeth->rx_bd_ring_offset[i]);
+			else if (ugeth->ug_info->uf_info.bd_mem_part ==
+				 MEM_PART_MURAM)
+
qe_muram_free(ugeth->rx_bd_ring_offset[i]);
+			ugeth->p_rx_bd_ring[i] = NULL;
+		}
+	}
+	while (!list_empty(&ugeth->group_hash_q))
+		put_enet_addr_container(ENET_ADDR_CONT_ENTRY
+
(dequeue(&ugeth->group_hash_q)));
+	while (!list_empty(&ugeth->ind_hash_q))
+		put_enet_addr_container(ENET_ADDR_CONT_ENTRY
+					(dequeue(&ugeth->ind_hash_q)));
+
+}
+
+static void ucc_geth_set_multi(struct net_device *dev)
+{
+	ucc_geth_private_t *ugeth;
+	struct dev_mc_list *dmi;
+	ucc_fast_t *uf_regs;
+	ucc_geth_82xx_address_filtering_pram_t *p_82xx_addr_filt;
+	enet_addr_t tempaddr;
+	u8 *mcptr, *tdptr;
+	int i, j;
+
+	ugeth = netdev_priv(dev);
+
+	uf_regs = ugeth->uccf->uf_regs;
+
+	if (dev->flags & IFF_PROMISC) {
+
+		/* Log any net taps. */
+		printk("%s: Promiscuous mode enabled.\n", dev->name);
+		uf_regs->upsmr |= UPSMR_PRO;
+
+	} else {
+
+		uf_regs->upsmr &= ~UPSMR_PRO;
+
+		p_82xx_addr_filt =
+		    (ucc_geth_82xx_address_filtering_pram_t *) ugeth->
+		    p_rx_glbl_pram->addressfiltering;
+
+		if (dev->flags & IFF_ALLMULTI) {
+			/* Catch all multicast addresses, so set the
+			 * filter to all 1's.
+			 */
+			out_be32(&p_82xx_addr_filt->gaddr_h,
0xffffffff);
+			out_be32(&p_82xx_addr_filt->gaddr_l,
0xffffffff);
+		} else {
+			/* Clear filter and add the addresses in the
list.
+			 */
+			out_be32(&p_82xx_addr_filt->gaddr_h, 0x0);
+			out_be32(&p_82xx_addr_filt->gaddr_l, 0x0);
+
+			dmi = dev->mc_list;
+
+			for (i = 0; i < dev->mc_count; i++, dmi =
dmi->next) {
+
+				/* Only support group multicast for now.
+				 */
+				if (!(dmi->dmi_addr[0] & 1))
+					continue;
+
+				/* The address in dmi_addr is LSB first,
+				 * and taddr is MSB first.  We have to
+				 * copy bytes MSB first from dmi_addr.
+				 */
+				mcptr = (u8 *) dmi->dmi_addr + 5;
+				tdptr = (u8 *) & tempaddr;
+				for (j = 0; j < 6; j++)
+					*tdptr++ = *mcptr--;
+
+				/* Ask CPM to run CRC and set bit in
+				 * filter mask.
+				 */
+				hw_add_addr_in_hash(ugeth, &tempaddr);
+
+			}
+		}
+	}
+}
+
+static void ucc_geth_stop(ucc_geth_private_t *ugeth)
+{
+	ucc_geth_t *ug_regs = ugeth->ug_regs;
+	u32 tempval;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	/* Disable the controller */
+	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
+
+	/* Tell the kernel the link is down */
+	ugeth->mii_info->link = 0;
+	adjust_link(ugeth->dev);
+
+	/* Mask all interrupts */
+	out_be32(ugeth->uccf->p_ucce, 0x00000000);
+
+	/* Clear all interrupts */
+	out_be32(ugeth->uccf->p_ucce, 0xffffffff);
+
+	/* Disable Rx and Tx */
+	tempval = in_be32(&ug_regs->maccfg1);
+	tempval &= ~(MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);
+	out_be32(&ug_regs->maccfg1, tempval);
+
+	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR) {
+		/* Clear any pending interrupts */
+		mii_clear_phy_interrupt(ugeth->mii_info);
+
+		/* Disable PHY Interrupts */
+		mii_configure_phy_interrupt(ugeth->mii_info,
+					    MII_INTERRUPT_DISABLED);
+	}
+
+	free_irq(ugeth->ug_info->uf_info.irq, ugeth->dev);
+
+	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR) {
+		free_irq(ugeth->ug_info->phy_interrupt, ugeth->dev);
+	} else {
+		del_timer_sync(&ugeth->phy_info_timer);
+	}
+
+	ucc_geth_memclean(ugeth);
+}
+
+static int ucc_geth_startup(ucc_geth_private_t *ugeth)
+{
+	ucc_geth_82xx_address_filtering_pram_t *p_82xx_addr_filt;
+	ucc_geth_init_pram_t *p_init_enet_pram;
+	ucc_fast_private_t *uccf;
+	ucc_geth_info_t *ug_info;
+	ucc_fast_info_t *uf_info;
+	ucc_fast_t *uf_regs;
+	ucc_geth_t *ug_regs;
+	int ret_val = -EINVAL;
+	u32 remoder = UCC_GETH_REMODER_INIT;
+	u32 init_enet_pram_offset, cecr_subblock, command, maccfg1;
+	u32 ifstat, i, j, size, l2qt, l3qt, length;
+	u16 temoder = UCC_GETH_TEMODER_INIT;
+	u16 test;
+	u8 function_code = 0;
+	u8 *bd, *endOfRing;
+	u8 numThreadsRxNumerical, numThreadsTxNumerical;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	ug_info = ugeth->ug_info;
+	uf_info = &ug_info->uf_info;
+
+	if (!((uf_info->bd_mem_part == MEM_PART_SYSTEM) ||
+	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
+		ugeth_err("%s: Bad memory partition value.",
__FUNCTION__);
+		return -EINVAL;
+	}
+
+	/* Rx BD lengths */
+	for (i = 0; i < ug_info->numQueuesRx; i++) {
+		if ((ug_info->bdRingLenRx[i] <
UCC_GETH_RX_BD_RING_SIZE_MIN) ||
+		    (ug_info->bdRingLenRx[i] %
+		     UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT)) {
+			ugeth_err
+			    ("%s: Rx BD ring length must be multiple of
4,"
+				" no smaller than 8.", __FUNCTION__);
+			return -EINVAL;
+		}
+	}
+
+	/* Tx BD lengths */
+	for (i = 0; i < ug_info->numQueuesTx; i++) {
+		if (ug_info->bdRingLenTx[i] <
UCC_GETH_TX_BD_RING_SIZE_MIN) {
+			ugeth_err
+			    ("%s: Tx BD ring length must be no smaller
than 2.",
+			     __FUNCTION__);
+			return -EINVAL;
+		}
+	}
+
+	/* mrblr */
+	if ((uf_info->max_rx_buf_length == 0) ||
+	    (uf_info->max_rx_buf_length % UCC_GETH_MRBLR_ALIGNMENT)) {
+		ugeth_err
+		    ("%s: max_rx_buf_length must be non-zero multiple of
128.",
+		     __FUNCTION__);
+		return -EINVAL;
+	}
+
+	/* num Tx queues */
+	if (ug_info->numQueuesTx > NUM_TX_QUEUES) {
+		ugeth_err("%s: number of tx queues too large.",
__FUNCTION__);
+		return -EINVAL;
+	}
+
+	/* num Rx queues */
+	if (ug_info->numQueuesRx > NUM_RX_QUEUES) {
+		ugeth_err("%s: number of rx queues too large.",
__FUNCTION__);
+		return -EINVAL;
+	}
+
+	/* l2qt */
+	for (i = 0; i < UCC_GETH_VLAN_PRIORITY_MAX; i++) {
+		if (ug_info->l2qt[i] >= ug_info->numQueuesRx) {
+			ugeth_err
+			    ("%s: VLAN priority table entry must not be"
+				" larger than number of Rx queues.",
+			     __FUNCTION__);
+			return -EINVAL;
+		}
+	}
+
+	/* l3qt */
+	for (i = 0; i < UCC_GETH_IP_PRIORITY_MAX; i++) {
+		if (ug_info->l3qt[i] >= ug_info->numQueuesRx) {
+			ugeth_err
+			    ("%s: IP priority table entry must not be"
+				" larger than number of Rx queues.",
+			     __FUNCTION__);
+			return -EINVAL;
+		}
+	}
+
+	if (ug_info->cam && !ug_info->ecamptr) {
+		ugeth_err("%s: If cam mode is chosen, must supply cam
ptr.",
+			  __FUNCTION__);
+		return -EINVAL;
+	}
+
+	if ((ug_info->numStationAddresses !=
+	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1)
+	    && ug_info->rxExtendedFiltering) {
+		ugeth_err("%s: Number of station addresses greater than
1 "
+			  "not allowed in extended parsing mode.",
+			  __FUNCTION__);
+		return -EINVAL;
+	}
+
+	/* Generate uccm_mask for receive */
+	uf_info->uccm_mask = ug_info->eventRegMask & UCCE_OTHER;/*
Errors */
+	for (i = 0; i < ug_info->numQueuesRx; i++)
+		uf_info->uccm_mask |= (UCCE_RXBF_SINGLE_MASK << i);
+
+	for (i = 0; i < ug_info->numQueuesTx; i++)
+		uf_info->uccm_mask |= (UCCE_TXBF_SINGLE_MASK << i);
+	/* Initialize the general fast UCC block. */
+	if (ucc_fast_init(uf_info, &uccf)) {
+		ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+	ugeth->uccf = uccf;
+
+	switch (ug_info->numThreadsRx) {
+	case UCC_GETH_NUM_OF_THREADS_1:
+		numThreadsRxNumerical = 1;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_2:
+		numThreadsRxNumerical = 2;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_4:
+		numThreadsRxNumerical = 4;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_6:
+		numThreadsRxNumerical = 6;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_8:
+		numThreadsRxNumerical = 8;
+		break;
+	default:
+		ugeth_err("%s: Bad number of Rx threads value.",
__FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -EINVAL;
+		break;
+	}
+
+	switch (ug_info->numThreadsTx) {
+	case UCC_GETH_NUM_OF_THREADS_1:
+		numThreadsTxNumerical = 1;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_2:
+		numThreadsTxNumerical = 2;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_4:
+		numThreadsTxNumerical = 4;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_6:
+		numThreadsTxNumerical = 6;
+		break;
+	case UCC_GETH_NUM_OF_THREADS_8:
+		numThreadsTxNumerical = 8;
+		break;
+	default:
+		ugeth_err("%s: Bad number of Tx threads value.",
__FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -EINVAL;
+		break;
+	}
+
+	/* Calculate rx_extended_features */
+	ugeth->rx_non_dynamic_extended_features =
ug_info->ipCheckSumCheck ||
+	    ug_info->ipAddressAlignment ||
+	    (ug_info->numStationAddresses !=
+	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1);
+
+	ugeth->rx_extended_features =
ugeth->rx_non_dynamic_extended_features ||
+	    (ug_info->vlanOperationTagged !=
UCC_GETH_VLAN_OPERATION_TAGGED_NOP)
+	    || (ug_info->vlanOperationNonTagged !=
+		UCC_GETH_VLAN_OPERATION_NON_TAGGED_NOP);
+
+	uf_regs = uccf->uf_regs;
+	ug_regs = (ucc_geth_t *) (uccf->uf_regs);
+	ugeth->ug_regs = ug_regs;
+
+	init_default_reg_vals(&uf_regs->upsmr,
+			      &ug_regs->maccfg1, &ug_regs->maccfg2);
+
+	/*                    Set UPSMR                      */
+	/* For more details see the hardware spec.           */
+	init_rx_parameters(ug_info->bro,
+			   ug_info->rsh, ug_info->pro, &uf_regs->upsmr);
+
+	/* We're going to ignore other registers for now, */
+	/* except as needed to get up and running         */
+
+	/*                    Set MACCFG1                    */
+	/* For more details see the hardware spec.           */
+	init_flow_control_params(ug_info->aufc,
+				 ug_info->receiveFlowControl,
+				 1,
+				 ug_info->pausePeriod,
+				 ug_info->extensionField,
+				 &uf_regs->upsmr,
+				 &ug_regs->uempr, &ug_regs->maccfg1);
+
+	maccfg1 = in_be32(&ug_regs->maccfg1);
+	maccfg1 |= MACCFG1_ENABLE_RX;
+	maccfg1 |= MACCFG1_ENABLE_TX;
+	out_be32(&ug_regs->maccfg1, maccfg1);
+
+	/*                    Set IPGIFG                     */
+	/* For more details see the hardware spec.           */
+	ret_val =
init_inter_frame_gap_params(ug_info->nonBackToBackIfgPart1,
+
ug_info->nonBackToBackIfgPart2,
+					      ug_info->
+
miminumInterFrameGapEnforcement,
+
ug_info->backToBackInterFrameGap,
+					      &ug_regs->ipgifg);
+	if (ret_val != 0) {
+		ugeth_err("%s: IPGIFG initialization parameter too
large.",
+			  __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return ret_val;
+	}
+
+	/*                    Set HAFDUP                     */
+	/* For more details see the hardware spec.           */
+	ret_val = init_half_duplex_params(ug_info->altBeb,
+
ug_info->backPressureNoBackoff,
+					  ug_info->noBackoff,
+					  ug_info->excessDefer,
+					  ug_info->altBebTruncation,
+					  ug_info->maxRetransmission,
+					  ug_info->collisionWindow,
+					  &ug_regs->hafdup);
+	if (ret_val != 0) {
+		ugeth_err("%s: Half Duplex initialization parameter too
large.",
+			  __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return ret_val;
+	}
+
+	/*                    Set IFSTAT                     */
+	/* For more details see the hardware spec.           */
+	/* Read only - resets upon read                      */
+	ifstat = in_be32(&ug_regs->ifstat);
+
+	/*                    Clear UEMPR                    */
+	/* For more details see the hardware spec.           */
+	out_be32(&ug_regs->uempr, 0);
+
+	/*                    Set UESCR                      */
+	/* For more details see the hardware spec.           */
+	init_hw_statistics_gathering_mode((ug_info->statisticsMode &
+
UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE),
+				0, &uf_regs->upsmr, &ug_regs->uescr);
+
+	/* Allocate Tx bds */
+	for (j = 0; j < ug_info->numQueuesTx; j++) {
+		/* Allocate in multiple of 
+		   UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT,
+		   according to spec */
+		length = ((ug_info->bdRingLenTx[j] *
UCC_GETH_SIZE_OF_BD)
+			  / UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT)
+		    * UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT;
+		if ((ug_info->bdRingLenTx[j] * UCC_GETH_SIZE_OF_BD) %
+		    UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT)
+			length +=
UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT;
+		if (uf_info->bd_mem_part == MEM_PART_SYSTEM) {
+			u32 align = 4;
+			if (UCC_GETH_TX_BD_RING_ALIGNMENT > 4)
+				align = UCC_GETH_TX_BD_RING_ALIGNMENT;
+			ugeth->tx_bd_ring_offset[j] =
+				(u32) (kmalloc((u32) (length + align),
+				GFP_KERNEL));
+			if (ugeth->tx_bd_ring_offset[j] != 0)
+				ugeth->p_tx_bd_ring[j] =
+
(void*)((ugeth->tx_bd_ring_offset[j] +
+					align) & ~(align - 1));
+		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
+			ugeth->tx_bd_ring_offset[j] =
+			    qe_muram_alloc(length,
+
UCC_GETH_TX_BD_RING_ALIGNMENT);
+			if (!IS_MURAM_ERR(ugeth->tx_bd_ring_offset[j]))
+				ugeth->p_tx_bd_ring[j] =
+				    (u8 *) qe_muram_addr(ugeth->
+
tx_bd_ring_offset[j]);
+		}
+		if (!ugeth->p_tx_bd_ring[j]) {
+			ugeth_err
+			    ("%s: Can not allocate memory for Tx bd
rings.",
+			     __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+		/* Zero unused end of bd ring, according to spec */
+		memset(ugeth->p_tx_bd_ring[j] +
+		       ug_info->bdRingLenTx[j] * UCC_GETH_SIZE_OF_BD, 0,
+		       length - ug_info->bdRingLenTx[j] *
UCC_GETH_SIZE_OF_BD);
+	}
+
+	/* Allocate Rx bds */
+	for (j = 0; j < ug_info->numQueuesRx; j++) {
+		length = ug_info->bdRingLenRx[j] * UCC_GETH_SIZE_OF_BD;
+		if (uf_info->bd_mem_part == MEM_PART_SYSTEM) {
+			u32 align = 4;
+			if (UCC_GETH_RX_BD_RING_ALIGNMENT > 4)
+				align = UCC_GETH_RX_BD_RING_ALIGNMENT;
+			ugeth->rx_bd_ring_offset[j] =
+			    (u32) (kmalloc((u32) (length + align),
GFP_KERNEL));
+			if (ugeth->rx_bd_ring_offset[j] != 0)
+				ugeth->p_rx_bd_ring[j] =
+
(void*)((ugeth->rx_bd_ring_offset[j] +
+					align) & ~(align - 1));
+		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
+			ugeth->rx_bd_ring_offset[j] =
+			    qe_muram_alloc(length,
+
UCC_GETH_RX_BD_RING_ALIGNMENT);
+			if (!IS_MURAM_ERR(ugeth->rx_bd_ring_offset[j]))
+				ugeth->p_rx_bd_ring[j] =
+				    (u8 *) qe_muram_addr(ugeth->
+
rx_bd_ring_offset[j]);
+		}
+		if (!ugeth->p_rx_bd_ring[j]) {
+			ugeth_err
+			    ("%s: Can not allocate memory for Rx bd
rings.",
+			     __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+	}
+
+	/* Init Tx bds */
+	for (j = 0; j < ug_info->numQueuesTx; j++) {
+		/* Setup the skbuff rings */
+		ugeth->tx_skbuff[j] =
+		    (struct sk_buff **)kmalloc(sizeof(struct sk_buff *)
*
+
ugeth->ug_info->bdRingLenTx[j],
+					       GFP_KERNEL);
+
+		if (ugeth->tx_skbuff[j] == NULL) {
+			ugeth_err("%s: Could not allocate tx_skbuff",
+				  __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+
+		for (i = 0; i < ugeth->ug_info->bdRingLenTx[j]; i++)
+			ugeth->tx_skbuff[j][i] = NULL;
+
+		ugeth->skb_curtx[j] = ugeth->skb_dirtytx[j] = 0;
+		bd = ugeth->confBd[j] = ugeth->txBd[j] =
ugeth->p_tx_bd_ring[j];
+		for (i = 0; i < ug_info->bdRingLenTx[j]; i++) {
+			BD_BUFFER_CLEAR(bd);
+			BD_STATUS_AND_LENGTH_SET(bd, 0);
+			bd += UCC_GETH_SIZE_OF_BD;
+		}
+		bd -= UCC_GETH_SIZE_OF_BD;
+		BD_STATUS_AND_LENGTH_SET(bd, T_W);/* for last BD set
Wrap bit */
+	}
+
+	/* Init Rx bds */
+	for (j = 0; j < ug_info->numQueuesRx; j++) {
+		/* Setup the skbuff rings */
+		ugeth->rx_skbuff[j] =
+		    (struct sk_buff **)kmalloc(sizeof(struct sk_buff *)
*
+
ugeth->ug_info->bdRingLenRx[j],
+					       GFP_KERNEL);
+
+		if (ugeth->rx_skbuff[j] == NULL) {
+			ugeth_err("%s: Could not allocate rx_skbuff",
+				  __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+
+		for (i = 0; i < ugeth->ug_info->bdRingLenRx[j]; i++)
+			ugeth->rx_skbuff[j][i] = NULL;
+
+		ugeth->skb_currx[j] = 0;
+		bd = ugeth->rxBd[j] = ugeth->p_rx_bd_ring[j];
+		for (i = 0; i < ug_info->bdRingLenRx[j]; i++) {
+			BD_STATUS_AND_LENGTH_SET(bd, R_I);
+			BD_BUFFER_CLEAR(bd);
+			bd += UCC_GETH_SIZE_OF_BD;
+		}
+		bd -= UCC_GETH_SIZE_OF_BD;
+		BD_STATUS_AND_LENGTH_SET(bd, R_W);/* for last BD set
Wrap bit */
+	}
+
+	/*
+	 * Global PRAM
+	 */
+	/* Tx global PRAM */
+	/* Allocate global tx parameter RAM page */
+	ugeth->tx_glbl_pram_offset =
+	    qe_muram_alloc(sizeof(ucc_geth_tx_global_pram_t),
+			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
+	if (IS_MURAM_ERR(ugeth->tx_glbl_pram_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for
p_tx_glbl_pram.",
+		     __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+	ugeth->p_tx_glbl_pram =
+	    (ucc_geth_tx_global_pram_t *) qe_muram_addr(ugeth->
+
tx_glbl_pram_offset);
+	/* Zero out p_tx_glbl_pram */
+	memset(ugeth->p_tx_glbl_pram, 0,
sizeof(ucc_geth_tx_global_pram_t));
+
+	/* Fill global PRAM */
+
+	/* TQPTR */
+	/* Size varies with number of Tx threads */
+	ugeth->thread_dat_tx_offset =
+	    qe_muram_alloc(numThreadsTxNumerical *
+			   sizeof(ucc_geth_thread_data_tx_t) +
+			   32 * (numThreadsTxNumerical == 1),
+			   UCC_GETH_THREAD_DATA_ALIGNMENT);
+	if (IS_MURAM_ERR(ugeth->thread_dat_tx_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for
p_thread_data_tx.",
+		     __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+
+	ugeth->p_thread_data_tx =
+	    (ucc_geth_thread_data_tx_t *) qe_muram_addr(ugeth->
+
thread_dat_tx_offset);
+	out_be32(&ugeth->p_tx_glbl_pram->tqptr,
ugeth->thread_dat_tx_offset);
+
+	/* vtagtable */
+	for (i = 0; i < UCC_GETH_TX_VTAG_TABLE_ENTRY_MAX; i++)
+		out_be32(&ugeth->p_tx_glbl_pram->vtagtable[i],
+			 ug_info->vtagtable[i]);
+
+	/* iphoffset */
+	for (i = 0; i < TX_IP_OFFSET_ENTRY_MAX; i++)
+		ugeth->p_tx_glbl_pram->iphoffset[i] =
ug_info->iphoffset[i];
+
+	/* SQPTR */
+	/* Size varies with number of Tx queues */
+	ugeth->send_q_mem_reg_offset =
+	    qe_muram_alloc(ug_info->numQueuesTx *
+			   sizeof(ucc_geth_send_queue_qd_t),
+
UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
+	if (IS_MURAM_ERR(ugeth->send_q_mem_reg_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for
p_send_q_mem_reg.",
+		     __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+
+	ugeth->p_send_q_mem_reg =
+	    (ucc_geth_send_queue_mem_region_t *) qe_muram_addr(ugeth->
+			send_q_mem_reg_offset);
+	out_be32(&ugeth->p_tx_glbl_pram->sqptr,
ugeth->send_q_mem_reg_offset);
+
+	/* Setup the table */
+	/* Assume BD rings are already established */
+	for (i = 0; i < ug_info->numQueuesTx; i++) {
+		endOfRing =
+		    ugeth->p_tx_bd_ring[i] + (ug_info->bdRingLenTx[i] -
+					      1) * UCC_GETH_SIZE_OF_BD;
+		if (ugeth->ug_info->uf_info.bd_mem_part ==
MEM_PART_SYSTEM) {
+
out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
+				 (u32)
virt_to_phys(ugeth->p_tx_bd_ring[i]));
+			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
+				 last_bd_completed_address,
+				 (u32) virt_to_phys(endOfRing));
+		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
+			   MEM_PART_MURAM) {
+
out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
+				 (u32) immrbar_virt_to_phys(ugeth->
+
p_tx_bd_ring[i]));
+			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
+				 last_bd_completed_address,
+				 (u32) immrbar_virt_to_phys(endOfRing));
+		}
+	}
+
+	/* schedulerbasepointer */
+
+	if (ug_info->numQueuesTx > 1) {	
+	/* scheduler exists only if more than 1 tx queue */
+		ugeth->scheduler_offset =
+		    qe_muram_alloc(sizeof(ucc_geth_scheduler_t),
+				   UCC_GETH_SCHEDULER_ALIGNMENT);
+		if (IS_MURAM_ERR(ugeth->scheduler_offset)) {
+			ugeth_err
+			 ("%s: Can not allocate DPRAM memory for
p_scheduler.",
+			     __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+
+		ugeth->p_scheduler =
+		    (ucc_geth_scheduler_t *) qe_muram_addr(ugeth->
+
scheduler_offset);
+		out_be32(&ugeth->p_tx_glbl_pram->schedulerbasepointer,
+			 ugeth->scheduler_offset);
+		/* Zero out p_scheduler */
+		memset(ugeth->p_scheduler, 0,
sizeof(ucc_geth_scheduler_t));
+
+		/* Set values in scheduler */
+		out_be32(&ugeth->p_scheduler->mblinterval,
+			 ug_info->mblinterval);
+		out_be16(&ugeth->p_scheduler->nortsrbytetime,
+			 ug_info->nortsrbytetime);
+		ugeth->p_scheduler->fracsiz = ug_info->fracsiz;
+		ugeth->p_scheduler->strictpriorityq =
ug_info->strictpriorityq;
+		ugeth->p_scheduler->txasap = ug_info->txasap;
+		ugeth->p_scheduler->extrabw = ug_info->extrabw;
+		for (i = 0; i < NUM_TX_QUEUES; i++)
+			ugeth->p_scheduler->weightfactor[i] =
+			    ug_info->weightfactor[i];
+
+		/* Set pointers to cpucount registers in scheduler */
+		ugeth->p_cpucount[0] = &(ugeth->p_scheduler->cpucount0);
+		ugeth->p_cpucount[1] = &(ugeth->p_scheduler->cpucount1);
+		ugeth->p_cpucount[2] = &(ugeth->p_scheduler->cpucount2);
+		ugeth->p_cpucount[3] = &(ugeth->p_scheduler->cpucount3);
+		ugeth->p_cpucount[4] = &(ugeth->p_scheduler->cpucount4);
+		ugeth->p_cpucount[5] = &(ugeth->p_scheduler->cpucount5);
+		ugeth->p_cpucount[6] = &(ugeth->p_scheduler->cpucount6);
+		ugeth->p_cpucount[7] = &(ugeth->p_scheduler->cpucount7);
+	}
+
+	/* schedulerbasepointer */
+	/* TxRMON_PTR (statistics) */
+	if (ug_info->
+	    statisticsMode &
UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
+		ugeth->tx_fw_statistics_pram_offset =
+		    qe_muram_alloc(sizeof
+
(ucc_geth_tx_firmware_statistics_pram_t),
+				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
+		if (IS_MURAM_ERR(ugeth->tx_fw_statistics_pram_offset)) {
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for"
+				" p_tx_fw_statistics_pram.",
__FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+		ugeth->p_tx_fw_statistics_pram =
+		    (ucc_geth_tx_firmware_statistics_pram_t *)
+		    qe_muram_addr(ugeth->tx_fw_statistics_pram_offset);
+		/* Zero out p_tx_fw_statistics_pram */
+		memset(ugeth->p_tx_fw_statistics_pram,
+		       0,
sizeof(ucc_geth_tx_firmware_statistics_pram_t));
+	}
+
+	/* temoder */
+	/* Already has speed set */
+
+	if (ug_info->numQueuesTx > 1)
+		temoder |= TEMODER_SCHEDULER_ENABLE;
+	if (ug_info->ipCheckSumGenerate)
+		temoder |= TEMODER_IP_CHECKSUM_GENERATE;
+	temoder |= ((ug_info->numQueuesTx - 1) <<
TEMODER_NUM_OF_QUEUES_SHIFT);
+	out_be16(&ugeth->p_tx_glbl_pram->temoder, temoder);
+
+	test = in_be16(&ugeth->p_tx_glbl_pram->temoder);
+
+	/* Function code register value to be used later */
+	function_code = QE_BMR_BYTE_ORDER_BO_MOT |
UCC_FAST_FUNCTION_CODE_GBL;	
+	/* Required for QE */
+
+	/* function code register */
+	out_be32(&ugeth->p_tx_glbl_pram->tstate, ((u32) function_code)
<< 24);
+
+	/* Rx global PRAM */
+	/* Allocate global rx parameter RAM page */
+	ugeth->rx_glbl_pram_offset =
+	    qe_muram_alloc(sizeof(ucc_geth_rx_global_pram_t),
+			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
+	if (IS_MURAM_ERR(ugeth->rx_glbl_pram_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for
p_rx_glbl_pram.",
+		     __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+	ugeth->p_rx_glbl_pram =
+	    (ucc_geth_rx_global_pram_t *) qe_muram_addr(ugeth->
+
rx_glbl_pram_offset);
+	/* Zero out p_rx_glbl_pram */
+	memset(ugeth->p_rx_glbl_pram, 0,
sizeof(ucc_geth_rx_global_pram_t));
+
+	/* Fill global PRAM */
+
+	/* RQPTR */
+	/* Size varies with number of Rx threads */
+	ugeth->thread_dat_rx_offset =
+	    qe_muram_alloc(numThreadsRxNumerical *
+			   sizeof(ucc_geth_thread_data_rx_t),
+			   UCC_GETH_THREAD_DATA_ALIGNMENT);
+	if (IS_MURAM_ERR(ugeth->thread_dat_rx_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for
p_thread_data_rx.",
+		     __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+
+	ugeth->p_thread_data_rx =
+	    (ucc_geth_thread_data_rx_t *) qe_muram_addr(ugeth->
+
thread_dat_rx_offset);
+	out_be32(&ugeth->p_rx_glbl_pram->rqptr,
ugeth->thread_dat_rx_offset);
+
+	/* typeorlen */
+	out_be16(&ugeth->p_rx_glbl_pram->typeorlen, ug_info->typeorlen);
+
+	/* rxrmonbaseptr (statistics) */
+	if (ug_info->
+	    statisticsMode &
UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX) {
+		ugeth->rx_fw_statistics_pram_offset =
+		    qe_muram_alloc(sizeof
+
(ucc_geth_rx_firmware_statistics_pram_t),
+				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
+		if (IS_MURAM_ERR(ugeth->rx_fw_statistics_pram_offset)) {
+			ugeth_err
+				("%s: Can not allocate DPRAM memory for"
+				" p_rx_fw_statistics_pram.",
__FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+		ugeth->p_rx_fw_statistics_pram =
+		    (ucc_geth_rx_firmware_statistics_pram_t *)
+		    qe_muram_addr(ugeth->rx_fw_statistics_pram_offset);
+		/* Zero out p_rx_fw_statistics_pram */
+		memset(ugeth->p_rx_fw_statistics_pram, 0,
+		       sizeof(ucc_geth_rx_firmware_statistics_pram_t));
+	}
+
+	/* intCoalescingPtr */
+
+	/* Size varies with number of Rx queues */
+	ugeth->rx_irq_coalescing_tbl_offset =
+	    qe_muram_alloc(ug_info->numQueuesRx *
+
sizeof(ucc_geth_rx_interrupt_coalescing_entry_t),
+			   UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
+	if (IS_MURAM_ERR(ugeth->rx_irq_coalescing_tbl_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for"
+			" p_rx_irq_coalescing_tbl.", __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+
+	ugeth->p_rx_irq_coalescing_tbl =
+	    (ucc_geth_rx_interrupt_coalescing_table_t *)
+	    qe_muram_addr(ugeth->rx_irq_coalescing_tbl_offset);
+	out_be32(&ugeth->p_rx_glbl_pram->intcoalescingptr,
+		 ugeth->rx_irq_coalescing_tbl_offset);
+
+	/* Fill interrupt coalescing table */
+	for (i = 0; i < ug_info->numQueuesRx; i++) {
+
out_be32(&ugeth->p_rx_irq_coalescing_tbl->coalescingentry[i].
+			 interruptcoalescingmaxvalue,
+			 ug_info->interruptcoalescingmaxvalue[i]);
+
out_be32(&ugeth->p_rx_irq_coalescing_tbl->coalescingentry[i].
+			 interruptcoalescingcounter,
+			 ug_info->interruptcoalescingmaxvalue[i]);
+	}
+
+	/* MRBLR */
+	init_max_rx_buff_len(uf_info->max_rx_buf_length,
+			     &ugeth->p_rx_glbl_pram->mrblr);
+	/* MFLR */
+	out_be16(&ugeth->p_rx_glbl_pram->mflr, ug_info->maxFrameLength);
+	/* MINFLR */
+	init_min_frame_len(ug_info->minFrameLength,
+			   &ugeth->p_rx_glbl_pram->minflr,
+			   &ugeth->p_rx_glbl_pram->mrblr);
+	/* MAXD1 */
+	out_be16(&ugeth->p_rx_glbl_pram->maxd1, ug_info->maxD1Length);
+	/* MAXD2 */
+	out_be16(&ugeth->p_rx_glbl_pram->maxd2, ug_info->maxD2Length);
+
+	/* l2qt */
+	l2qt = 0;
+	for (i = 0; i < UCC_GETH_VLAN_PRIORITY_MAX; i++)
+		l2qt |= (ug_info->l2qt[i] << (28 - 4 * i));
+	out_be32(&ugeth->p_rx_glbl_pram->l2qt, l2qt);
+
+	/* l3qt */
+	for (j = 0; j < UCC_GETH_IP_PRIORITY_MAX; j += 8) {
+		l3qt = 0;
+		for (i = 0; i < 8; i++)
+			l3qt |= (ug_info->l3qt[j + i] << (28 - 4 * i));
+		out_be32(&ugeth->p_rx_glbl_pram->l3qt[j], l3qt);
+	}
+
+	/* vlantype */
+	out_be16(&ugeth->p_rx_glbl_pram->vlantype, ug_info->vlantype);
+
+	/* vlantci */
+	out_be16(&ugeth->p_rx_glbl_pram->vlantci, ug_info->vlantci);
+
+	/* ecamptr */
+	out_be32(&ugeth->p_rx_glbl_pram->ecamptr, ug_info->ecamptr);
+
+	/* RBDQPTR */
+	/* Size varies with number of Rx queues */
+	ugeth->rx_bd_qs_tbl_offset =
+	    qe_muram_alloc(ug_info->numQueuesRx *
+			   (sizeof(ucc_geth_rx_bd_queues_entry_t) +
+			    sizeof(ucc_geth_rx_prefetched_bds_t)),
+			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
+	if (IS_MURAM_ERR(ugeth->rx_bd_qs_tbl_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for
p_rx_bd_qs_tbl.",
+		     __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+
+	ugeth->p_rx_bd_qs_tbl =
+	    (ucc_geth_rx_bd_queues_entry_t *) qe_muram_addr(ugeth->
+				    rx_bd_qs_tbl_offset);
+	out_be32(&ugeth->p_rx_glbl_pram->rbdqptr,
ugeth->rx_bd_qs_tbl_offset);
+	/* Zero out p_rx_bd_qs_tbl */
+	memset(ugeth->p_rx_bd_qs_tbl,
+	       0,
+	       ug_info->numQueuesRx *
(sizeof(ucc_geth_rx_bd_queues_entry_t) +
+
sizeof(ucc_geth_rx_prefetched_bds_t)));
+
+	/* Setup the table */
+	/* Assume BD rings are already established */
+	for (i = 0; i < ug_info->numQueuesRx; i++) {
+		if (ugeth->ug_info->uf_info.bd_mem_part ==
MEM_PART_SYSTEM) {
+
out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
+				 (u32)
virt_to_phys(ugeth->p_rx_bd_ring[i]));
+		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
+			   MEM_PART_MURAM) {
+
out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
+				 (u32) immrbar_virt_to_phys(ugeth->
+
p_rx_bd_ring[i]));
+		}
+		/* rest of fields handled by QE */
+	}
+
+	/* remoder */
+	/* Already has speed set */
+
+	if (ugeth->rx_extended_features)
+		remoder |= REMODER_RX_EXTENDED_FEATURES;
+	if (ug_info->rxExtendedFiltering)
+		remoder |= REMODER_RX_EXTENDED_FILTERING;
+	if (ug_info->dynamicMaxFrameLength)
+		remoder |= REMODER_DYNAMIC_MAX_FRAME_LENGTH;
+	if (ug_info->dynamicMinFrameLength)
+		remoder |= REMODER_DYNAMIC_MIN_FRAME_LENGTH;
+	remoder |=
+	    ug_info->vlanOperationTagged <<
REMODER_VLAN_OPERATION_TAGGED_SHIFT;
+	remoder |=
+	    ug_info->
+	    vlanOperationNonTagged <<
REMODER_VLAN_OPERATION_NON_TAGGED_SHIFT;
+	remoder |= ug_info->rxQoSMode << REMODER_RX_QOS_MODE_SHIFT;
+	remoder |= ((ug_info->numQueuesRx - 1) <<
REMODER_NUM_OF_QUEUES_SHIFT);
+	if (ug_info->ipCheckSumCheck)
+		remoder |= REMODER_IP_CHECKSUM_CHECK;
+	if (ug_info->ipAddressAlignment)
+		remoder |= REMODER_IP_ADDRESS_ALIGNMENT;
+	out_be32(&ugeth->p_rx_glbl_pram->remoder, remoder);
+
+	/* Note that this function must be called */
+	/* ONLY AFTER p_tx_fw_statistics_pram */
+	/* andp_UccGethRxFirmwareStatisticsPram are allocated ! */
+	init_firmware_statistics_gathering_mode((ug_info->
+		statisticsMode & 
+		UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX),
+		(ug_info->statisticsMode &
+		UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX),
+		&ugeth->p_tx_glbl_pram->txrmonbaseptr,
+		ugeth->tx_fw_statistics_pram_offset,
+		&ugeth->p_rx_glbl_pram->rxrmonbaseptr,
+		ugeth->rx_fw_statistics_pram_offset,
+		&ugeth->p_tx_glbl_pram->temoder,
+		&ugeth->p_rx_glbl_pram->remoder);
+
+	/* function code register */
+	ugeth->p_rx_glbl_pram->rstate = function_code;
+
+	/* initialize extended filtering */
+	if (ug_info->rxExtendedFiltering) {
+		if (!ug_info->extendedFilteringChainPointer) {
+			ugeth_err("%s: Null Extended Filtering Chain
Pointer.",
+				  __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -EINVAL;
+		}
+
+		/* Allocate memory for extended filtering Mode Global 
+		Parameters */
+		ugeth->exf_glbl_param_offset =
+		    qe_muram_alloc(sizeof(ucc_geth_exf_global_pram_t),
+
UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
+		if (IS_MURAM_ERR(ugeth->exf_glbl_param_offset)) {
+			ugeth_err
+				("%s: Can not allocate DPRAM memory for"
+				" p_exf_glbl_param.", __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return -ENOMEM;
+		}
+
+		ugeth->p_exf_glbl_param =
+		    (ucc_geth_exf_global_pram_t *) qe_muram_addr(ugeth->
+				 exf_glbl_param_offset);
+		out_be32(&ugeth->p_rx_glbl_pram->exfGlobalParam,
+			 ugeth->exf_glbl_param_offset);
+		out_be32(&ugeth->p_exf_glbl_param->l2pcdptr,
+			 (u32) ug_info->extendedFilteringChainPointer);
+
+	} else {		/* initialize 82xx style address
filtering */
+
+		/* Init individual address recognition registers to
disabled */
+
+		for (j = 0; j < NUM_OF_PADDRS; j++)
+			ugeth_82xx_filtering_clear_addr_in_paddr(ugeth,
(u8) j);
+
+		/* Create CQs for hash tables */
+		if (ug_info->maxGroupAddrInHash > 0) {
+			INIT_LIST_HEAD(&ugeth->group_hash_q);
+		}
+		if (ug_info->maxIndAddrInHash > 0) {
+			INIT_LIST_HEAD(&ugeth->ind_hash_q);
+		}
+		p_82xx_addr_filt =
+		    (ucc_geth_82xx_address_filtering_pram_t *) ugeth->
+		    p_rx_glbl_pram->addressfiltering;
+
+		ugeth_82xx_filtering_clear_all_addr_in_hash(ugeth,
+			ENET_ADDR_TYPE_GROUP);
+		ugeth_82xx_filtering_clear_all_addr_in_hash(ugeth,
+			ENET_ADDR_TYPE_INDIVIDUAL);
+	}
+
+	/*
+	 * Initialize UCC at QE level
+	 */
+
+	command = QE_INIT_TX_RX;
+
+	/* Allocate shadow InitEnet command parameter structure.
+	 * This is needed because after the InitEnet command is
executed,
+	 * the structure in DPRAM is released, because DPRAM is a
premium 
+	 * resource. 
+	 * This shadow structure keeps a copy of what was done so that
the
+	 * allocated resources can be released when the channel is
freed.
+	 */
+	if (!(ugeth->p_init_enet_param_shadow =
+	     (ucc_geth_init_pram_t *)
kmalloc(sizeof(ucc_geth_init_pram_t),
+					      GFP_KERNEL))) {
+		ugeth_err
+		    ("%s: Can not allocate memory for"
+			" p_UccInitEnetParamShadows.", __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+	/* Zero out *p_init_enet_param_shadow */
+	memset((char *)ugeth->p_init_enet_param_shadow,
+	       0, sizeof(ucc_geth_init_pram_t));
+
+	/* Fill shadow InitEnet command parameter structure */
+
+	ugeth->p_init_enet_param_shadow->resinit1 =
+	    ENET_INIT_PARAM_MAGIC_RES_INIT1;
+	ugeth->p_init_enet_param_shadow->resinit2 =
+	    ENET_INIT_PARAM_MAGIC_RES_INIT2;
+	ugeth->p_init_enet_param_shadow->resinit3 =
+	    ENET_INIT_PARAM_MAGIC_RES_INIT3;
+	ugeth->p_init_enet_param_shadow->resinit4 =
+	    ENET_INIT_PARAM_MAGIC_RES_INIT4;
+	ugeth->p_init_enet_param_shadow->resinit5 =
+	    ENET_INIT_PARAM_MAGIC_RES_INIT5;
+	ugeth->p_init_enet_param_shadow->rgftgfrxglobal |=
+	    ((u32) ug_info->numThreadsRx) << ENET_INIT_PARAM_RGF_SHIFT;
+	ugeth->p_init_enet_param_shadow->rgftgfrxglobal |=
+	    ((u32) ug_info->numThreadsTx) << ENET_INIT_PARAM_TGF_SHIFT;
+
+	ugeth->p_init_enet_param_shadow->rgftgfrxglobal |=
+	    ugeth->rx_glbl_pram_offset | ug_info->riscRx;
+	if ((ug_info->largestexternallookupkeysize !=
+	     QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_NONE)
+	    && (ug_info->largestexternallookupkeysize !=
+		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
+	    && (ug_info->largestexternallookupkeysize !=
+
QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
+		ugeth_err("%s: Invalid largest External Lookup Key
Size.",
+			  __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -EINVAL;
+	}
+	ugeth->p_init_enet_param_shadow->largestexternallookupkeysize =
+	    ug_info->largestexternallookupkeysize;
+	size = sizeof(ucc_geth_thread_rx_pram_t);
+	if (ug_info->rxExtendedFiltering) {
+		size +=
THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING;
+		if (ug_info->largestexternallookupkeysize ==
+		    QE_FLTR_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
+			size +=
+
THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_8;
+		if (ug_info->largestexternallookupkeysize ==
+		    QE_FLTR_TABLE_LOOKUP_KEY_SIZE_16_BYTES)
+			size +=
+
THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_16;
+	}
+
+	if ((ret_val = fill_init_enet_entries(ugeth, &(ugeth->
+		p_init_enet_param_shadow->rxthread[0]),
+		(u8) (numThreadsRxNumerical + 1)
+		/* Rx needs one extra for terminator */
+		, size, UCC_GETH_THREAD_RX_PRAM_ALIGNMENT,
+		ug_info->riscRx, 1)) != 0) {
+			ugeth_err("%s: Can not fill
p_init_enet_param_shadow.",
+				__FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return ret_val;
+	}
+
+	ugeth->p_init_enet_param_shadow->txglobal =
+	    ugeth->tx_glbl_pram_offset | ug_info->riscTx;
+	if ((ret_val =
+	     fill_init_enet_entries(ugeth,
+				    &(ugeth->p_init_enet_param_shadow->
+				      txthread[0]),
numThreadsTxNumerical,
+				    sizeof(ucc_geth_thread_tx_pram_t),
+				    UCC_GETH_THREAD_TX_PRAM_ALIGNMENT,
+				    ug_info->riscTx, 0)) != 0) {
+		ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
+			  __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return ret_val;
+	}
+
+	/* Load Rx bds with buffers */
+	for (i = 0; i < ug_info->numQueuesRx; i++) {
+		if ((ret_val = rx_bd_buffer_set(ugeth, (u8) i)) != 0) {
+			ugeth_err("%s: Can not fill Rx bds with
buffers.",
+				  __FUNCTION__);
+			ucc_geth_memclean(ugeth);
+			return ret_val;
+		}
+	}
+
+	/* Allocate InitEnet command parameter structure */
+	init_enet_pram_offset =
qe_muram_alloc(sizeof(ucc_geth_init_pram_t), 4);
+	if (IS_MURAM_ERR(init_enet_pram_offset)) {
+		ugeth_err
+		    ("%s: Can not allocate DPRAM memory for
p_init_enet_pram.",
+		     __FUNCTION__);
+		ucc_geth_memclean(ugeth);
+		return -ENOMEM;
+	}
+	p_init_enet_pram =
+	    (ucc_geth_init_pram_t *)
qe_muram_addr(init_enet_pram_offset);
+
+	/* Copy shadow InitEnet command parameter structure into PRAM */
+	p_init_enet_pram->resinit1 =
ugeth->p_init_enet_param_shadow->resinit1;
+	p_init_enet_pram->resinit2 =
ugeth->p_init_enet_param_shadow->resinit2;
+	p_init_enet_pram->resinit3 =
ugeth->p_init_enet_param_shadow->resinit3;
+	p_init_enet_pram->resinit4 =
ugeth->p_init_enet_param_shadow->resinit4;
+	out_be16(&p_init_enet_pram->resinit5,
+		 ugeth->p_init_enet_param_shadow->resinit5);
+	p_init_enet_pram->largestexternallookupkeysize =
+
ugeth->p_init_enet_param_shadow->largestexternallookupkeysize;
+	out_be32(&p_init_enet_pram->rgftgfrxglobal,
+		 ugeth->p_init_enet_param_shadow->rgftgfrxglobal);
+	for (i = 0; i < ENET_INIT_PARAM_MAX_ENTRIES_RX; i++)
+		out_be32(&p_init_enet_pram->rxthread[i],
+			 ugeth->p_init_enet_param_shadow->rxthread[i]);
+	out_be32(&p_init_enet_pram->txglobal,
+		 ugeth->p_init_enet_param_shadow->txglobal);
+	for (i = 0; i < ENET_INIT_PARAM_MAX_ENTRIES_TX; i++)
+		out_be32(&p_init_enet_pram->txthread[i],
+			 ugeth->p_init_enet_param_shadow->txthread[i]);
+
+	/* Issue QE command */
+	cecr_subblock =
+
ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
+	qe_issue_cmd(command, cecr_subblock, (u8)
QE_CR_PROTOCOL_ETHERNET,
+		     init_enet_pram_offset);
+
+	/* Free InitEnet command parameter */
+	qe_muram_free(init_enet_pram_offset);
+
+	return 0;
+}
+
+/* returns a net_device_stats structure pointer */
+static struct net_device_stats *ucc_geth_get_stats(struct net_device
*dev)
+{
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+
+	return &(ugeth->stats);
+}
+
+/* ucc_geth_timeout gets called when a packet has not been
+ * transmitted after a set amount of time.
+ * For now, assume that clearing out all the structures, and
+ * starting over will fix the problem. */
+static void ucc_geth_timeout(struct net_device *dev)
+{
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	ugeth->stats.tx_errors++;
+
+	ugeth_dump_regs(ugeth);
+
+	if (dev->flags & IFF_UP) {
+		ucc_geth_stop(ugeth);
+		ucc_geth_startup(ugeth);
+	}
+
+	netif_schedule(dev);
+}
+
+/* This is called by the kernel when a frame is ready for transmission.
*/
+/* It is pointed to by the dev->hard_start_xmit function pointer */
+static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device
*dev)
+{
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+	u8 *bd;			/* BD pointer */
+	u32 bd_status;
+	u8 txQ = 0;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	spin_lock_irq(&ugeth->lock);
+
+	ugeth->stats.tx_bytes += skb->len;
+
+	/* Start from the next BD that should be filled */
+	bd = ugeth->txBd[txQ];
+	bd_status = BD_STATUS_AND_LENGTH(bd);
+	/* Save the skb pointer so we can free it later */
+	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
+
+	/* Update the current skb pointer (wrapping if this was the
last) */
+	ugeth->skb_curtx[txQ] =
+	    (ugeth->skb_curtx[txQ] +
+	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
+
+	/* set up the buffer descriptor */
+	BD_BUFFER_SET(bd,
+		      dma_map_single(NULL, skb->data, skb->len,
DMA_TO_DEVICE));
+
+	//printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data);
+
+	bd_status = (bd_status & T_W) | T_R | T_I | T_L | skb->len;
+
+	BD_STATUS_AND_LENGTH_SET(bd, bd_status);
+
+	dev->trans_start = jiffies;
+
+	/* Move to next BD in the ring */
+	if (!(bd_status & T_W))
+		ugeth->txBd[txQ] = bd + UCC_GETH_SIZE_OF_BD;
+	else
+		ugeth->txBd[txQ] = ugeth->p_tx_bd_ring[txQ];
+
+	/* If the next BD still needs to be cleaned up, then the bds
+	   are full.  We need to tell the kernel to stop sending us
stuff. */
+	if (bd == ugeth->confBd[txQ]) {
+		if (!netif_queue_stopped(dev))
+			netif_stop_queue(dev);
+	}
+
+	if (ugeth->p_scheduler) {
+		ugeth->cpucount[txQ]++;
+		/* Indicate to QE that there are more Tx bds ready for 
+		transmission */
+		/* This is done by writing a running counter of the bd 
+		count to the scheduler PRAM. */
+		out_be16(ugeth->p_cpucount[txQ], ugeth->cpucount[txQ]);
+	}
+
+	spin_unlock_irq(&ugeth->lock);
+
+	return 0;
+}
+
+static int ucc_geth_rx(ucc_geth_private_t *ugeth, u8 rxQ, int
rx_work_limit)
+{
+	struct sk_buff *skb;
+	u8 *bd;
+	u16 length, howmany = 0;
+	u32 bd_status;
+	u8 *bdBuffer;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	spin_lock(&ugeth->lock);
+	/* collect received buffers */
+	bd = ugeth->rxBd[rxQ];
+
+	bd_status = BD_STATUS_AND_LENGTH(bd);
+
+	/* while there are received buffers and BD is full (~R_E) */
+	while (!((bd_status & (R_E)) || (--rx_work_limit < 0))) {
+		bdBuffer = (u8 *) BD_BUFFER(bd);
+		length = (u16) ((bd_status & BD_LENGTH_MASK) - 4);
+		skb = ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]];
+
+		/* determine whether buffer is first, last, first and
last 
+		(single buffer frame) or middle (not first and not last)
*/
+		if (!skb ||
+		    (!(bd_status & (R_F | R_L))) ||
+		    (bd_status & R_ERRORS_FATAL)) {
+			ugeth_vdbg("%s, %d: ERROR!!! skb - 0x%08x",
+				   __FUNCTION__, __LINE__, (u32) skb);
+			if (skb)
+				dev_kfree_skb_any(skb);
+
+			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] =
NULL;
+			ugeth->stats.rx_dropped++;
+		} else {
+			ugeth->stats.rx_packets++;
+			howmany++;
+
+			/* Prep the skb for the packet */
+			skb_put(skb, length);
+
+			/* Tell the skb what kind of packet this is */
+			skb->protocol = eth_type_trans(skb, ugeth->dev);
+
+			ugeth->stats.rx_bytes += length;
+			/* Send the packet up the stack */
+#ifdef CONFIG_UGETH_NAPI
+			netif_receive_skb(skb);
+#else
+			netif_rx(skb);
+#endif				/* CONFIG_UGETH_NAPI */
+		}
+
+		ugeth->dev->last_rx = jiffies;
+
+		skb = get_new_skb(ugeth, bd);
+		if (!skb) {
+			ugeth_warn("%s: No Rx Data Buffer",
__FUNCTION__);
+			spin_unlock(&ugeth->lock);
+			ugeth->stats.rx_dropped++;
+			break;
+		}
+
+		ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = skb;
+
+		/* update to point at the next skb */
+		ugeth->skb_currx[rxQ] =
+		    (ugeth->skb_currx[rxQ] +
+		     1) &
RX_RING_MOD_MASK(ugeth->ug_info->bdRingLenRx[rxQ]);
+
+		if (bd_status & R_W)
+			bd = ugeth->p_rx_bd_ring[rxQ];
+		else
+			bd += UCC_GETH_SIZE_OF_BD;
+
+		bd_status = BD_STATUS_AND_LENGTH(bd);
+	}
+
+	ugeth->rxBd[rxQ] = bd;
+	spin_unlock(&ugeth->lock);
+	return howmany;
+}
+
+static int ucc_geth_tx(struct net_device *dev, u8 txQ)
+{
+	/* Start from the next BD that should be filled */
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+	u8 *bd;			/* BD pointer */
+	u32 bd_status;
+
+	bd = ugeth->confBd[txQ];
+	bd_status = BD_STATUS_AND_LENGTH(bd);
+
+	/* Normal processing. */
+	while ((bd_status & T_R) == 0) {
+		/* BD contains already transmitted buffer.   */
+		/* Handle the transmitted buffer and release */
+		/* the BD to be used with the current frame  */
+
+		if ((bd = ugeth->txBd[txQ]) && (netif_queue_stopped(dev)
== 0))
+			break;
+
+		ugeth->stats.tx_packets++;
+
+		/* Free the sk buffer associated with this TxBD */
+		dev_kfree_skb_irq(ugeth->
+
tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
+		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
+		ugeth->skb_dirtytx[txQ] =
+		    (ugeth->skb_dirtytx[txQ] +
+		     1) &
TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
+
+		/* We freed a buffer, so now we can restart transmission
*/
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+
+		/* Advance the confirmation BD pointer */
+		if (!(bd_status & T_W))
+			ugeth->confBd[txQ] += UCC_GETH_SIZE_OF_BD;
+		else
+			ugeth->confBd[txQ] = ugeth->p_tx_bd_ring[txQ];
+	}
+	return 0;
+}
+
+#ifdef CONFIG_UGETH_NAPI
+static int ucc_geth_poll(struct net_device *dev, int *budget)
+{
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+	int howmany;
+	int rx_work_limit = *budget;
+	u8 rxQ = 0;
+
+	if (rx_work_limit > dev->quota)
+		rx_work_limit = dev->quota;
+
+	howmany = ucc_geth_rx(ugeth, rxQ, rx_work_limit);
+
+	dev->quota -= howmany;
+	rx_work_limit -= howmany;
+	*budget -= howmany;
+
+	if (rx_work_limit >= 0)
+		netif_rx_complete(dev);
+
+	return (rx_work_limit < 0) ? 1 : 0;
+}
+#endif				/* CONFIG_UGETH_NAPI */
+
+static irqreturn_t ucc_geth_irq_handler(int irq, void *info,
+					struct pt_regs *regs)
+{
+	struct net_device *dev = (struct net_device *)info;
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+	ucc_fast_private_t *uccf;
+	ucc_geth_info_t *ug_info;
+	register u32 ucce = 0;
+	register u32 bit_mask = UCCE_RXBF_SINGLE_MASK;
+	register u32 tx_mask = UCCE_TXBF_SINGLE_MASK;
+	register u8 i;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	if (!ugeth)
+		return IRQ_NONE;
+
+	uccf = ugeth->uccf;
+	ug_info = ugeth->ug_info;
+
+	do {
+		ucce |= (u32) (in_be32(uccf->p_ucce) &
in_be32(uccf->p_uccm));
+
+		/* clear event bits for next time */
+		/* Side effect here is to mask ucce variable 
+		for future processing below. */
+		out_be32(uccf->p_ucce, ucce);	/* Clear with ones, 
+						but only bits in UCCM */
+
+		/* We ignore Tx interrupts because Tx confirmation is 
+		done inside Tx routine */
+
+		for (i = 0; i < ug_info->numQueuesRx; i++) {
+			if (ucce & bit_mask)
+				ucc_geth_rx(ugeth, i,
+					    (int)ugeth->ug_info->
+					    bdRingLenRx[i]);
+			ucce &= ~bit_mask;
+			bit_mask <<= 1;
+		}
+
+		for (i = 0; i < ug_info->numQueuesTx; i++) {
+			if (ucce & tx_mask)
+				ucc_geth_tx(dev, i);
+			ucce &= ~tx_mask;
+			tx_mask <<= 1;
+		}
+
+		/* Exceptions */
+		if (ucce & UCCE_BSY) {
+			ugeth_vdbg("Got BUSY irq!!!!");
+			ugeth->stats.rx_errors++;
+			ucce &= ~UCCE_BSY;
+		}
+		if (ucce & UCCE_OTHER) {
+			ugeth_vdbg("Got frame with error (ucce -
0x%08x)!!!!",
+				   ucce);
+			ugeth->stats.rx_errors++;
+			ucce &= ~ucce;
+		}
+	}
+	while (ucce);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs
*regs)
+{
+	struct net_device *dev = (struct net_device *)dev_id;
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	/* Clear the interrupt */
+	mii_clear_phy_interrupt(ugeth->mii_info);
+
+	/* Disable PHY interrupts */
+	mii_configure_phy_interrupt(ugeth->mii_info,
MII_INTERRUPT_DISABLED);
+
+	/* Schedule the phy change */
+	schedule_work(&ugeth->tq);
+
+	return IRQ_HANDLED;
+}
+
+/* Scheduled by the phy_interrupt/timer to handle PHY changes */
+static void ugeth_phy_change(void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+	ucc_geth_t *ug_regs;
+	int result = 0;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	ug_regs = ugeth->ug_regs;
+
+	/* Delay to give the PHY a chance to change the
+	 * register state */
+	msleep(1);
+
+	/* Update the link, speed, duplex */
+	result = ugeth->mii_info->phyinfo->read_status(ugeth->mii_info);
+
+	/* Adjust the known status as long as the link
+	 * isn't still coming up */
+	if ((0 == result) || (ugeth->mii_info->link == 0))
+		adjust_link(dev);
+
+	/* Reenable interrupts, if needed */
+	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR)
+		mii_configure_phy_interrupt(ugeth->mii_info,
+					    MII_INTERRUPT_ENABLED);
+}
+
+/* Called every so often on systems that don't interrupt
+ * the core for PHY changes */
+static void ugeth_phy_timer(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+
+	schedule_work(&ugeth->tq);
+
+	mod_timer(&ugeth->phy_info_timer, jiffies + PHY_CHANGE_TIME *
HZ);
+}
+
+/* Keep trying aneg for some time
+ * If, after GFAR_AN_TIMEOUT seconds, it has not
+ * finished, we switch to forced.
+ * Either way, once the process has completed, we either
+ * request the interrupt, or switch the timer over to 
+ * using ugeth_phy_timer to check status */
+static void ugeth_phy_startup_timer(unsigned long data)
+{
+	struct ugeth_mii_info *mii_info = (struct ugeth_mii_info *)data;
+	ucc_geth_private_t *ugeth = netdev_priv(mii_info->dev);
+	static int secondary = UGETH_AN_TIMEOUT;
+	int result;
+
+	/* Configure the Auto-negotiation */
+	result = mii_info->phyinfo->config_aneg(mii_info);
+
+	/* If autonegotiation failed to start, and
+	 * we haven't timed out, reset the timer, and return */
+	if (result && secondary--) {
+		mod_timer(&ugeth->phy_info_timer, jiffies + HZ);
+		return;
+	} else if (result) {
+		/* Couldn't start autonegotiation.
+		 * Try switching to forced */
+		mii_info->autoneg = 0;
+		result = mii_info->phyinfo->config_aneg(mii_info);
+
+		/* Forcing failed!  Give up */
+		if (result) {
+			ugeth_err("%s: Forcing failed!",
mii_info->dev->name);
+			return;
+		}
+	}
+
+	/* Kill the timer so it can be restarted */
+	del_timer_sync(&ugeth->phy_info_timer);
+
+	/* Grab the PHY interrupt, if necessary/possible */
+	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR) {
+		if (request_irq(ugeth->ug_info->phy_interrupt,
+				phy_interrupt,
+				SA_SHIRQ, "phy_interrupt",
mii_info->dev) < 0) {
+			ugeth_err("%s: Can't get IRQ %d (PHY)",
+				  mii_info->dev->name,
+				  ugeth->ug_info->phy_interrupt);
+		} else {
+			mii_configure_phy_interrupt(ugeth->mii_info,
+
MII_INTERRUPT_ENABLED);
+			return;
+		}
+	}
+
+	/* Start the timer again, this time in order to
+	 * handle a change in status */
+	init_timer(&ugeth->phy_info_timer);
+	ugeth->phy_info_timer.function = &ugeth_phy_timer;
+	ugeth->phy_info_timer.data = (unsigned long)mii_info->dev;
+	mod_timer(&ugeth->phy_info_timer, jiffies + PHY_CHANGE_TIME *
HZ);
+}
+
+/* Called when something needs to use the ethernet device */
+/* Returns 0 for success. */
+static int ucc_geth_open(struct net_device *dev)
+{
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+	int err;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	/* Test station address */
+	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
+		ugeth_err("%s: Multicast address used for station
address"
+			  " - is this what you wanted?", __FUNCTION__);
+		return -EINVAL;
+	}
+
+	err = ucc_geth_startup(ugeth);
+	if (err) {
+		ugeth_err("%s: Cannot configure net device, aborting.",
+			  dev->name);
+		return err;
+	}
+
+	err = adjust_enet_interface(ugeth);
+	if (err) {
+		ugeth_err("%s: Cannot configure net device, aborting.",
+			  dev->name);
+		return err;
+	}
+
+	/*       Set MACSTNADDR1, MACSTNADDR2                */
+	/* For more details see the hardware spec.           */
+	init_mac_station_addr_regs(dev->dev_addr[0],
+				   dev->dev_addr[1],
+				   dev->dev_addr[2],
+				   dev->dev_addr[3],
+				   dev->dev_addr[4],
+				   dev->dev_addr[5],
+				   &ugeth->ug_regs->macstnaddr1,
+				   &ugeth->ug_regs->macstnaddr2);
+
+	err = init_phy(dev);
+	if (err) {
+		ugeth_err("%s: Cannot initialzie PHY, aborting.",
dev->name);
+		return err;
+	}
+#ifndef CONFIG_UGETH_NAPI
+	err =
+	    request_irq(ugeth->ug_info->uf_info.irq,
ucc_geth_irq_handler, 0,
+			"UCC Geth", dev);
+	if (err) {
+		ugeth_err("%s: Cannot get IRQ for net device,
aborting.",
+			  dev->name);
+		ucc_geth_stop(ugeth);
+		return err;
+	}
+#endif				/* CONFIG_UGETH_NAPI */
+
+	/* Set up the PHY change work queue */
+	INIT_WORK(&ugeth->tq, ugeth_phy_change, dev);
+
+	init_timer(&ugeth->phy_info_timer);
+	ugeth->phy_info_timer.function = &ugeth_phy_startup_timer;
+	ugeth->phy_info_timer.data = (unsigned long)ugeth->mii_info;
+	mod_timer(&ugeth->phy_info_timer, jiffies + HZ);
+
+	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
+	if (err) {
+		ugeth_err("%s: Cannot enable net device, aborting.",
dev->name);
+		ucc_geth_stop(ugeth);
+		return err;
+	}
+
+	netif_start_queue(dev);
+
+	return err;
+}
+
+/* Stops the kernel queue, and halts the controller */
+static int ucc_geth_close(struct net_device *dev)
+{
+	ucc_geth_private_t *ugeth = netdev_priv(dev);
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	ucc_geth_stop(ugeth);
+
+	/* Shutdown the PHY */
+	if (ugeth->mii_info->phyinfo->close)
+		ugeth->mii_info->phyinfo->close(ugeth->mii_info);
+
+	kfree(ugeth->mii_info);
+
+	netif_stop_queue(dev);
+
+	return 0;
+}
+
+struct ethtool_ops ucc_geth_ethtool_ops = {
+	.get_settings = NULL,
+	.get_drvinfo = NULL,
+	.get_regs_len = NULL,
+	.get_regs = NULL,
+	.get_link = NULL,
+	.get_coalesce = NULL,
+	.set_coalesce = NULL,
+	.get_ringparam = NULL,
+	.set_ringparam = NULL,
+	.get_strings = NULL,
+	.get_stats_count = NULL,
+	.get_ethtool_stats = NULL,
+};
+
+static int ucc_geth_probe(struct device *device)
+{
+	struct platform_device *pdev = to_platform_device(device);
+	struct ucc_geth_platform_data *ugeth_pdata;
+	struct net_device *dev = NULL;
+	struct ucc_geth_private *ugeth = NULL;
+	struct ucc_geth_info *ug_info;
+	int err;
+	static int mii_mng_configured = 0;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+
+	ugeth_pdata = (struct ucc_geth_platform_data
*)pdev->dev.platform_data;
+
+	ug_info = &ugeth_info[pdev->id];
+	ug_info->uf_info.ucc_num = pdev->id;
+	ug_info->uf_info.rx_clock = ugeth_pdata->rx_clock;
+	ug_info->uf_info.tx_clock = ugeth_pdata->tx_clock;
+	ug_info->uf_info.regs = ugeth_pdata->phy_reg_addr;
+	ug_info->uf_info.irq = platform_get_irq(pdev, 0);
+	ug_info->phy_address = ugeth_pdata->phy_id;
+	ug_info->enet_interface = ugeth_pdata->phy_interface;
+	ug_info->board_flags = ugeth_pdata->board_flags;
+	ug_info->phy_interrupt = ugeth_pdata->phy_interrupt;
+	
+	printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n", 
+		ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
+		ug_info->uf_info.irq);
+
+	if (ug_info == NULL) {
+		ugeth_err("%s: [%d] Missing additional data!",
__FUNCTION__,
+			  pdev->id);
+		return -ENODEV;
+	}
+
+	if (!mii_mng_configured) {
+		ucc_set_qe_mux_mii_mng(ug_info->uf_info.ucc_num);
+		mii_mng_configured = 1;
+	}
+
+	/* Create an ethernet device instance */
+	dev = alloc_etherdev(sizeof(*ugeth));
+
+	if (dev == NULL)
+		return -ENOMEM;
+
+	ugeth = netdev_priv(dev);
+	spin_lock_init(&ugeth->lock);
+
+	dev_set_drvdata(device, dev);
+
+	/* Set the dev->base_addr to the gfar reg region */
+	dev->base_addr = (unsigned long)(ug_info->uf_info.regs);
+
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, device);
+
+	/* Fill in the dev structure */
+	dev->open = ucc_geth_open;
+	dev->hard_start_xmit = ucc_geth_start_xmit;
+	dev->tx_timeout = ucc_geth_timeout;
+	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_UGETH_NAPI
+	dev->poll = ucc_geth_poll;
+	dev->weight = UCC_GETH_DEV_WEIGHT;
+#endif				/* CONFIG_UGETH_NAPI */
+	dev->stop = ucc_geth_close;
+	dev->get_stats = ucc_geth_get_stats;
+//    dev->change_mtu = ucc_geth_change_mtu;
+	dev->mtu = 1500;
+	dev->set_multicast_list = ucc_geth_set_multi;
+	dev->ethtool_ops = &ucc_geth_ethtool_ops;
+
+	err = register_netdev(dev);
+	if (err) {
+		ugeth_err("%s: Cannot register net device, aborting.",
+			  dev->name);
+		free_netdev(dev);
+		return err;
+	}
+
+	ugeth->ug_info = ug_info;
+	ugeth->dev = dev;
+	memcpy(dev->dev_addr, ugeth_pdata->mac_addr, 6);
+
+	return 0;
+}
