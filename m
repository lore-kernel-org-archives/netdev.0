From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.12.1 12/12] S2io: Miscellaneous fixes
Date: Thu,  7 Jul 2005 15:42:23 -0700 (PDT)
Message-ID: <20050707224223.DA22889828@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
The last patch in this series fixes the following issues found during
testing.
1. Ensure we don't pass zero sized buffers to the card(which can lockup) 
2. Restore the PCI-X parameters(in case of Xframe I adapter) after a reset.
3. Make sure total size of all FIFOs does not exceed 8192.

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_kernel/drivers/net/s2io.c linux-2.6.12-rc6/drivers/net/s2io.c
--- vanilla_kernel/drivers/net/s2io.c	2005-06-30 02:26:26.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io.c	2005-06-30 03:39:18.000000000 -0700
@@ -364,10 +364,9 @@ static int init_shared_mem(struct s2io_n
 		size += config->tx_cfg[i].fifo_len;
 	}
 	if (size > MAX_AVAILABLE_TXDS) {
-		DBG_PRINT(ERR_DBG, "%s: Total number of Tx FIFOs ",
-			  dev->name);
-		DBG_PRINT(ERR_DBG, "exceeds the maximum value ");
-		DBG_PRINT(ERR_DBG, "that can be used\n");
+		DBG_PRINT(ERR_DBG, "%s: Requested TxDs too high, ",
+			  __FUNCTION__);
+		DBG_PRINT(ERR_DBG, "Requested: %d, max supported: 8192\n", size);
 		return FAILURE;
 	}
 
@@ -610,8 +609,9 @@ static void free_shared_mem(struct s2io_
 						lst_per_page);
 		for (j = 0; j < page_num; j++) {
 			int mem_blks = (j * lst_per_page);
-			if (!mac_control->fifos[i].list_info[mem_blks].
-			    list_virt_addr)
+			if ((!mac_control->fifos[i].list_info) ||
+				(!mac_control->fifos[i].list_info[mem_blks].
+				 list_virt_addr))
 				break;
 			pci_free_consistent(nic->pdev, PAGE_SIZE,
 					    mac_control->fifos[i].
@@ -2595,6 +2595,8 @@ static void tx_intr_handler(fifo_info_t 
 			for (j = 0; j < frg_cnt; j++, txdlp++) {
 				skb_frag_t *frag =
 				    &skb_shinfo(skb)->frags[j];
+				if (!txdlp->Buffer_Pointer)
+					break;
 				pci_unmap_page(nic->pdev,
 					       (dma_addr_t)
 					       txdlp->
@@ -2745,6 +2747,10 @@ void s2io_reset(nic_t * sp)
 	u64 val64;
 	u16 subid, pci_cmd;
 
+	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
+	if (sp->device_type == XFRAME_I_DEVICE)
+		pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
+
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
 
@@ -2763,8 +2769,10 @@ void s2io_reset(nic_t * sp)
 	msleep(250);
 
 	if (!(sp->device_type & XFRAME_II_DEVICE)) {
-	/* Restore the PCI state saved during initializarion. */
+		/* Restore the PCI state saved during initializarion. */
 		pci_restore_state(sp->pdev);
+		pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
+				     pci_cmd);
 	} else {
 		pci_set_master(sp->pdev);
 	}
@@ -2975,7 +2983,7 @@ int s2io_open(struct net_device *dev)
 	 * Nic is initialized
 	 */
 	netif_carrier_off(dev);
-	sp->last_link_state = LINK_DOWN;
+	sp->last_link_state = 0;
 
 	/* Initialize H/W and enable interrupts */
 	if (s2io_card_up(sp)) {
@@ -3103,6 +3111,15 @@ int s2io_xmit(struct sk_buff *skb, struc
 		spin_unlock_irqrestore(&sp->tx_lock, flags);
 		return 0;
 	}
+
+	/* A buffer with no data will be dropped */
+	if (!skb->len) {
+		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
+		dev_kfree_skb(skb);
+		spin_unlock_irqrestore(&sp->tx_lock, flags);
+		return 0;
+	}
+
 #ifdef NETIF_F_TSO
 	mss = skb_shinfo(skb)->tso_size;
 	if (mss) {
@@ -3137,6 +3154,9 @@ int s2io_xmit(struct sk_buff *skb, struc
 	/* For fragmented SKB. */
 	for (i = 0; i < frg_cnt; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		/* A '0' length fragment will be ignored */
+		if (!frag->size)
+			continue;
 		txdp++;
 		txdp->Buffer_Pointer = (u64) pci_map_page
 		    (sp->pdev, frag->page, frag->page_offset,
@@ -5258,7 +5278,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	config = &sp->config;
 
 	/* Tx side parameters. */
-	tx_fifo_len[0] = DEFAULT_FIFO_LEN;	/* Default value. */
+	if (tx_fifo_len[0] == 0)
+		tx_fifo_len[0] = DEFAULT_FIFO_LEN; /* Default value. */
 	config->tx_fifo_num = tx_fifo_num;
 	for (i = 0; i < MAX_TX_FIFOS; i++) {
 		config->tx_cfg[i].fifo_len = tx_fifo_len[i];
@@ -5281,7 +5302,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	config->max_txds = MAX_SKB_FRAGS;
 
 	/* Rx side parameters. */
-	rx_ring_sz[0] = SMALL_BLK_CNT;	/* Default value. */
+	if (rx_ring_sz[0] == 0)
+		rx_ring_sz[0] = SMALL_BLK_CNT; /* Default value. */
 	config->rx_ring_num = rx_ring_num;
 	for (i = 0; i < MAX_RX_RINGS; i++) {
 		config->rx_cfg[i].num_rxd = rx_ring_sz[i] *
@@ -5311,7 +5333,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	/*  initialize the shared memory used by the NIC and the host */
 	if (init_shared_mem(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
-			  dev->name);
+			  __FUNCTION__);
 		ret = -ENOMEM;
 		goto mem_alloc_failed;
 	}
@@ -5489,7 +5511,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 			  sp->def_mac_addr[0].mac_addr[3],
 			  sp->def_mac_addr[0].mac_addr[4],
 			  sp->def_mac_addr[0].mac_addr[5]);
-		int mode = s2io_print_pci_mode(sp);
+		mode = s2io_print_pci_mode(sp);
 		if (mode < 0) {
 			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode ");
 			ret = -EBADSLT;
