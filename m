From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 13/13] S2io: Errors found during review
Date: Wed,  3 Aug 2005 12:41:38 -0700 (PDT)
Message-ID: <20050803194138.C20F898336@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This is a patch to incorporate comments from earlier 12 patches.
It also fixes a few issues we found during this time.
Following is a list of changes in this patch. Item 1 incorporates
earlier comments. Issues addressed in items 2 to 4 were discovered 
recently.


1. wmb() call in s2io_xmit() replaced with mmiowb().
2. The dtx_control register was earlier programmed incorrectly
   for Xframe II adapter.
3. As suggested by hardware team, after a reset, in case of
   Xframe II adapter, we clear certain spurious errors by
   clearing PCI-X ECC status register, "detected parity error"
   bit in PCI_STATUS register and PCI_STATUS bit in txpic_int register.	   
4. On IBM PPC platforms, we found that in the Rx buffer replenish
   function, two memory writes(one to the the descriptor length and 
   another to the ownership) were getting reordered. This was causing
   the adapter to see the ownership transfered to it before the length
   was updated.

   One solution was to add a wmb() but since this would turnout expensive 
   on some platforms if called for every descriptor, we set the ownership
   bit and other fields of '2' to 'N' Rx descriptors followed by a wmb()
   and then set the ownership of first descriptor ('1').

   Here the value 'N' is configurable by making it a module loadable 
   parameter (rxsync_frequency).
   (NOTE: This parameter is a power of 2).
5. Bumped up the driver version no. to 2.0.2.1

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 07:47:21.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 08:47:16.000000000 -0700
@@ -67,7 +67,7 @@
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
-static char s2io_driver_version[] = "Version 2.0.2.0";
+static char s2io_driver_version[] = "Version 2.0.2.1";
 
 static inline int RXD_IS_UP2DT(RxD_t *rxdp)
 {
@@ -301,6 +301,8 @@ static unsigned int bimodal = 0;
 #ifndef CONFIG_S2IO_NAPI
 static unsigned int indicate_max_pkts;
 #endif
+/* Frequency of Rx desc syncs expressed as power of 2 */
+static unsigned int rxsync_frequency = 3;
 
 /*
  * S2IO device table.
@@ -837,7 +839,7 @@ static int init_nic(struct s2io_nic *nic
 	 */
 	if (nic->device_type & XFRAME_II_DEVICE) {
 		while (herc_act_dtx_cfg[dtx_cnt] != END_SIGN) {
-			SPECIAL_REG_WRITE(xena_dtx_cfg[dtx_cnt],
+			SPECIAL_REG_WRITE(herc_act_dtx_cfg[dtx_cnt],
 					  &bar0->dtx_control, UF);
 			if (dtx_cnt & 0x1)
 				msleep(1); /* Necessary!! */
@@ -2083,6 +2085,7 @@ int fill_rx_buffers(struct s2io_nic *nic
 #ifndef CONFIG_S2IO_NAPI
 	unsigned long flags;
 #endif
+	RxD_t *first_rxdp = NULL;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -2202,6 +2205,10 @@ int fill_rx_buffers(struct s2io_nic *nic
 		if (!skb) {
 			DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
 			DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
+			if (first_rxdp) {
+				wmb();
+				first_rxdp->Control_1 |= RXD_OWN_XENA;
+			}
 			return -ENOMEM;
 		}
 #ifndef	CONFIG_2BUFF_MODE
@@ -2212,7 +2219,8 @@ int fill_rx_buffers(struct s2io_nic *nic
 		rxdp->Control_2 &= (~MASK_BUFFER0_SIZE);
 		rxdp->Control_2 |= SET_BUFFER0_SIZE(size);
 		rxdp->Host_Control = (unsigned long) (skb);
-		rxdp->Control_1 |= RXD_OWN_XENA;
+		if (alloc_tab & ((1 << rxsync_frequency) - 1))
+			rxdp->Control_1 |= RXD_OWN_XENA;
 		off++;
 		off %= (MAX_RXDS_PER_BLOCK + 1);
 		mac_control->rings[ring_no].rx_curr_put_info.offset = off;
@@ -2239,17 +2247,34 @@ int fill_rx_buffers(struct s2io_nic *nic
 		rxdp->Control_2 |= SET_BUFFER1_SIZE(1);	/* dummy. */
 		rxdp->Control_2 |= BIT(0);	/* Set Buffer_Empty bit. */
 		rxdp->Host_Control = (u64) ((unsigned long) (skb));
-		rxdp->Control_1 |= RXD_OWN_XENA;
+		if (alloc_tab & ((1 << rxsync_frequency) - 1))
+			rxdp->Control_1 |= RXD_OWN_XENA;
 		off++;
 		mac_control->rings[ring_no].rx_curr_put_info.offset = off;
 #endif
 		rxdp->Control_2 |= SET_RXD_MARKER;
 
+		if (!(alloc_tab & ((1 << rxsync_frequency) - 1))) {
+			if (first_rxdp) {
+				wmb();
+				first_rxdp->Control_1 |= RXD_OWN_XENA;
+			}
+			first_rxdp = rxdp;
+		}
 		atomic_inc(&nic->rx_bufs_left[ring_no]);
 		alloc_tab++;
 	}
 
       end:
+	/* Transfer ownership of first descriptor to adapter just before
+	 * exiting. Before that, use memory barrier so that ownership
+	 * and other fields are seen by adapter correctly.
+	 */
+	if (first_rxdp) {
+		wmb();
+		first_rxdp->Control_1 |= RXD_OWN_XENA;
+	}
+
 	return SUCCESS;
 }
 
@@ -2783,16 +2808,16 @@ void s2io_reset(nic_t * sp)
 	s2io_set_swapper(sp);
 
 	/* Clear certain PCI/PCI-X fields after reset */
-	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
-	pci_cmd &= 0x7FFF; /* Clear parity err detect bit */
-	pci_write_config_word(sp->pdev, PCI_COMMAND, pci_cmd);
+	if (sp->device_type == XFRAME_II_DEVICE) {
+		/* Clear parity err detect bit */
+		pci_write_config_word(sp->pdev, PCI_STATUS, 0x8000);
 
-	val64 = readq(&bar0->txpic_int_reg);
-	val64 &= ~BIT(62); /* Clearing PCI_STATUS error reflected here */
-	writeq(val64, &bar0->txpic_int_reg);
+		/* Clearing PCIX Ecc status register */
+		pci_write_config_dword(sp->pdev, 0x68, 0x7C);
 
-	/* Clearing PCIX Ecc status register */
-	pci_write_config_dword(sp->pdev, 0x68, 0);
+		/* Clearing PCI_STATUS error reflected here */
+		writeq(BIT(62), &bar0->txpic_int_reg);
+	}
 
 	/* Reset device statistics maintained by OS */
 	memset(&sp->stats, 0, sizeof (struct net_device_stats));
@@ -3168,8 +3193,6 @@ int s2io_xmit(struct sk_buff *skb, struc
 	val64 = mac_control->fifos[queue].list_info[put_off].list_phy_addr;
 	writeq(val64, &tx_fifo->TxDL_Pointer);
 
-	wmb();
-
 	val64 = (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
 		 TX_FIFO_LAST_LIST);
 
@@ -3179,6 +3202,8 @@ int s2io_xmit(struct sk_buff *skb, struc
 #endif
 	writeq(val64, &tx_fifo->List_Control);
 
+	mmiowb();
+
 	put_off++;
 	put_off %= mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
 	mac_control->fifos[queue].tx_curr_put_info.offset = put_off;
@@ -5172,6 +5197,7 @@ module_param(bimodal, bool, 0);
 #ifndef CONFIG_S2IO_NAPI
 module_param(indicate_max_pkts, int, 0);
 #endif
+module_param(rxsync_frequency, int, 0);
 
 /**
  *  s2io_init_nic - Initialization of the adapter .
diff -uprN vanilla_linux/drivers/net/s2io.h linux-2.6.13-rc4/drivers/net/s2io.h
--- vanilla_linux/drivers/net/s2io.h	2005-08-02 07:47:21.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.h	2005-08-02 07:45:38.000000000 -0700
@@ -13,11 +13,6 @@
 #ifndef _S2IO_H
 #define _S2IO_H
 
-/* Enable 2 buffer mode by default for SGI system */
-#ifdef CONFIG_IA64_SGI_SN2
-#define CONFIG_2BUFF_MODE
-#endif
-
 #define TBD 0
 #define BIT(loc)		(0x8000000000000000ULL >> (loc))
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
