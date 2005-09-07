From: ravinandan.arakali@neterion.com
Subject: [PATCH 2.6.13] S2io: Hardware and miscellaneous fixes
Date: Tue, 6 Sep 2005 21:36:56 -0700
Message-ID: <200509070436.j874au8m004304@localhost.localdomain>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com,
        ananda.raju@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This patch contains the following hardware related fixes and other
miscellaneous bug fixes.

1. Updated the definition of single and double-bit ECC errors
2. Earlier we were allocating Transmit descriptors equal to
   MAX_SKB_FRAGS. This was causing a boundary condition failure.
   Need to allocate MAX_SKB_FRAGS+1 descriptors.
3. On some platforms(like PPC), pci_alloc_consistent() can return
   a zero DMA address. Since the NIC cannot handle zero-addresses,
   a workaround has been provided. Basically, we don't use such
   that page. We reallocate.
4. If list_info allocation failed during driver load, check for
   it during driver exit and return instead of trying to dereference 
   NULL pointer.
5. Increase the debug level of few non-critical debug messages.
6. Reset the card on critical ECC double errors only in case of
   XframeI since XframeII can recover from such errors.
7. Print copyright message on driver load.
8. Bumped up the driver version no. to 2.0.8.1

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -urpN old/drivers/net/s2io-regs.h new/drivers/net/s2io-regs.h
--- old/drivers/net/s2io-regs.h	2005-09-06 04:51:44.000000000 -0700
+++ new/drivers/net/s2io-regs.h	2005-09-06 04:52:08.000000000 -0700
@@ -1,5 +1,5 @@
 /************************************************************************
- * regs.h: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC
+ * regs.h: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
  * Copyright(c) 2002-2005 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
@@ -713,13 +713,16 @@ typedef struct _XENA_dev_config {
 	u64 mc_err_reg;
 #define MC_ERR_REG_ECC_DB_ERR_L            BIT(14)
 #define MC_ERR_REG_ECC_DB_ERR_U            BIT(15)
+#define MC_ERR_REG_MIRI_ECC_DB_ERR_0       BIT(18)
+#define MC_ERR_REG_MIRI_ECC_DB_ERR_1       BIT(20)
 #define MC_ERR_REG_MIRI_CRI_ERR_0          BIT(22)
 #define MC_ERR_REG_MIRI_CRI_ERR_1          BIT(23)
 #define MC_ERR_REG_SM_ERR                  BIT(31)
-#define MC_ERR_REG_ECC_ALL_SNG		   (BIT(6) | \
-					BIT(7) | BIT(17) | BIT(19))
-#define MC_ERR_REG_ECC_ALL_DBL		   (BIT(14) | \
-					BIT(15) | BIT(18) | BIT(20))
+#define MC_ERR_REG_ECC_ALL_SNG		   (BIT(2) | BIT(3) | BIT(4) | BIT(5) |\
+					    BIT(6) | BIT(7) | BIT(17) | BIT(19))
+#define MC_ERR_REG_ECC_ALL_DBL		   (BIT(10) | BIT(11) | BIT(12) |\
+					    BIT(13) | BIT(14) | BIT(15) |\
+					    BIT(18) | BIT(20))
 	u64 mc_err_mask;
 	u64 mc_err_alarm;
 
diff -urpN old/drivers/net/s2io.c new/drivers/net/s2io.c
--- old/drivers/net/s2io.c	2005-09-06 04:51:44.000000000 -0700
+++ new/drivers/net/s2io.c	2005-09-06 04:52:08.000000000 -0700
@@ -1,5 +1,5 @@
 /************************************************************************
- * s2io.c: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC
+ * s2io.c: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
  * Copyright(c) 2002-2005 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
@@ -28,7 +28,7 @@
  * explaination of all the variables.
  * rx_ring_num : This can be used to program the number of receive rings used
  * in the driver.
- * rx_ring_len: This defines the number of descriptors each ring can have. This
+ * rx_ring_sz: This defines the number of descriptors each ring can have. This
  * is also an array of size 8.
  * tx_fifo_num: This defines the number of Tx FIFOs thats used int the driver.
  * tx_fifo_len: This too is an array of 8. Each element defines the number of
@@ -67,7 +67,7 @@
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
-static char s2io_driver_version[] = "Version 2.0.3.1";
+static char s2io_driver_version[] = "Version 2.0.8.1";
 
 static inline int RXD_IS_UP2DT(RxD_t *rxdp)
 {
@@ -404,7 +404,7 @@ static int init_shared_mem(struct s2io_n
 		    config->tx_cfg[i].fifo_len - 1;
 		mac_control->fifos[i].fifo_no = i;
 		mac_control->fifos[i].nic = nic;
-		mac_control->fifos[i].max_txds = MAX_SKB_FRAGS;
+		mac_control->fifos[i].max_txds = MAX_SKB_FRAGS + 1;
 
 		for (j = 0; j < page_num; j++) {
 			int k = 0;
@@ -418,6 +418,26 @@ static int init_shared_mem(struct s2io_n
 				DBG_PRINT(ERR_DBG, "failed for TxDL\n");
 				return -ENOMEM;
 			}
+			/* If we got a zero DMA address(can happen on
+			 * certain platforms like PPC), reallocate.
+			 * Store virtual address of page we don't want,
+			 * to be freed later.
+			 */
+			if (!tmp_p) {
+				mac_control->zerodma_virt_addr = tmp_v;
+				DBG_PRINT(INIT_DBG, 
+				"%s: Zero DMA address for TxDL. ", dev->name);
+				DBG_PRINT(INIT_DBG, 
+				"Virtual address %llx\n", (u64)tmp_v);
+				tmp_v = pci_alloc_consistent(nic->pdev,
+						     PAGE_SIZE, &tmp_p);
+				if (!tmp_v) {
+					DBG_PRINT(ERR_DBG,
+					  "pci_alloc_consistent ");
+					DBG_PRINT(ERR_DBG, "failed for TxDL\n");
+					return -ENOMEM;
+				}
+			}
 			while (k < lst_per_page) {
 				int l = (j * lst_per_page) + k;
 				if (l == config->tx_cfg[i].fifo_len)
@@ -600,7 +620,7 @@ static void free_shared_mem(struct s2io_
 	mac_info_t *mac_control;
 	struct config_param *config;
 	int lst_size, lst_per_page;
-
+	struct net_device *dev = nic->dev;
 
 	if (!nic)
 		return;
@@ -616,9 +636,10 @@ static void free_shared_mem(struct s2io_
 						lst_per_page);
 		for (j = 0; j < page_num; j++) {
 			int mem_blks = (j * lst_per_page);
-			if ((!mac_control->fifos[i].list_info) ||
-				(!mac_control->fifos[i].list_info[mem_blks].
-				 list_virt_addr))
+			if (!mac_control->fifos[i].list_info)
+				return;	
+			if (!mac_control->fifos[i].list_info[mem_blks].
+				 list_virt_addr)
 				break;
 			pci_free_consistent(nic->pdev, PAGE_SIZE,
 					    mac_control->fifos[i].
@@ -628,6 +649,18 @@ static void free_shared_mem(struct s2io_
 					    list_info[mem_blks].
 					    list_phy_addr);
 		}
+		/* If we got a zero DMA address during allocation,
+		 * free the page now
+		 */
+		if (mac_control->zerodma_virt_addr) {
+			pci_free_consistent(nic->pdev, PAGE_SIZE,
+					    mac_control->zerodma_virt_addr,
+					    (dma_addr_t)0);
+			DBG_PRINT(INIT_DBG, 
+			"%s: Freeing TxDL with zero DMA addr. ", dev->name);
+			DBG_PRINT(INIT_DBG, "Virtual address %llx\n",
+			(u64)(mac_control->zerodma_virt_addr));
+		}
 		kfree(mac_control->fifos[i].list_info);
 	}
 
@@ -2479,9 +2512,10 @@ static void rx_intr_handler(ring_info_t 
 #endif
 	spin_lock(&nic->rx_lock);
 	if (atomic_read(&nic->card_state) == CARD_DOWN) {
-		DBG_PRINT(ERR_DBG, "%s: %s going down for reset\n",
+		DBG_PRINT(INTR_DBG, "%s: %s going down for reset\n",
 			  __FUNCTION__, dev->name);
 		spin_unlock(&nic->rx_lock);
+		return;
 	}
 
 	get_info = ring_data->rx_curr_get_info;
@@ -2596,8 +2630,14 @@ static void tx_intr_handler(fifo_info_t 
 		if (txdlp->Control_1 & TXD_T_CODE) {
 			unsigned long long err;
 			err = txdlp->Control_1 & TXD_T_CODE;
-			DBG_PRINT(ERR_DBG, "***TxD error %llx\n",
-				  err);
+			if ((err >> 48) == 0xA) {
+				DBG_PRINT(TX_DBG, "TxD returned due \
+						to loss of link\n");
+			}
+			else {
+				DBG_PRINT(ERR_DBG, "***TxD error \
+						%llx\n", err);
+			}
 		}
 
 		skb = (struct sk_buff *) ((unsigned long)
@@ -2689,12 +2729,16 @@ static void alarm_intr_handler(struct s2
 		if (val64 & MC_ERR_REG_ECC_ALL_DBL) {
 			nic->mac_control.stats_info->sw_stat.
 				double_ecc_errs++;
-			DBG_PRINT(ERR_DBG, "%s: Device indicates ",
+			DBG_PRINT(INIT_DBG, "%s: Device indicates ",
 				  dev->name);
-			DBG_PRINT(ERR_DBG, "double ECC error!!\n");
+			DBG_PRINT(INIT_DBG, "double ECC error!!\n");
 			if (nic->device_type != XFRAME_II_DEVICE) {
-				netif_stop_queue(dev);
-				schedule_work(&nic->rst_timer_task);
+				/* Reset XframeI only if critical error */
+				if (val64 & (MC_ERR_REG_MIRI_ECC_DB_ERR_0 |
+					     MC_ERR_REG_MIRI_ECC_DB_ERR_1)) {
+					netif_stop_queue(dev);
+					schedule_work(&nic->rst_timer_task);
+				}
 			}
 		} else {
 			nic->mac_control.stats_info->sw_stat.
@@ -2706,7 +2750,8 @@ static void alarm_intr_handler(struct s2
 	val64 = readq(&bar0->serr_source);
 	if (val64 & SERR_SOURCE_ANY) {
 		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);
-		DBG_PRINT(ERR_DBG, "serious error!!\n");
+		DBG_PRINT(ERR_DBG, "serious error %llx!!\n", 
+			  (unsigned long long)val64);
 		netif_stop_queue(dev);
 		schedule_work(&nic->rst_timer_task);
 	}
@@ -3130,7 +3175,7 @@ int s2io_xmit(struct sk_buff *skb, struc
 	queue_len = mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (txdp->Host_Control || (((put_off + 1) % queue_len) == get_off)) {
-		DBG_PRINT(ERR_DBG, "Error in xmit, No free TXDs.\n");
+		DBG_PRINT(TX_DBG, "Error in xmit, No free TXDs.\n");
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
 		spin_unlock_irqrestore(&sp->tx_lock, flags);
@@ -3528,7 +3573,7 @@ static void s2io_set_multicast(struct ne
 
 		val64 = readq(&bar0->mac_cfg);
 		sp->promisc_flg = 1;
-		DBG_PRINT(ERR_DBG, "%s: entered promiscuous mode\n",
+		DBG_PRINT(INFO_DBG, "%s: entered promiscuous mode\n",
 			  dev->name);
 	} else if (!(dev->flags & IFF_PROMISC) && (sp->promisc_flg)) {
 		/*  Remove the NIC from promiscuous mode */
@@ -3543,7 +3588,7 @@ static void s2io_set_multicast(struct ne
 
 		val64 = readq(&bar0->mac_cfg);
 		sp->promisc_flg = 0;
-		DBG_PRINT(ERR_DBG, "%s: left promiscuous mode\n",
+		DBG_PRINT(INFO_DBG, "%s: left promiscuous mode\n",
 			  dev->name);
 	}
 
@@ -5325,7 +5370,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 			break;
 		}
 	}
-	config->max_txds = MAX_SKB_FRAGS;
+	config->max_txds = MAX_SKB_FRAGS + 1;
 
 	/* Rx side parameters. */
 	if (rx_ring_sz[0] == 0)
@@ -5525,9 +5570,14 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		DBG_PRINT(ERR_DBG, "%s: Neterion Xframe II 10GbE adapter ",
 			  dev->name);
-		DBG_PRINT(ERR_DBG, "(rev %d), Driver %s\n",
+		DBG_PRINT(ERR_DBG, "(rev %d), %s",
 				get_xena_rev_id(sp->pdev),
 				s2io_driver_version);
+#ifdef CONFIG_2BUFF_MODE
+		DBG_PRINT(ERR_DBG, ", Buffer mode %d",2);
+#endif
+
+		DBG_PRINT(ERR_DBG, "\nCopyright(c) 2002-2005 Neterion Inc.\n");
 		DBG_PRINT(ERR_DBG, "MAC ADDR: %02x:%02x:%02x:%02x:%02x:%02x\n",
 			  sp->def_mac_addr[0].mac_addr[0],
 			  sp->def_mac_addr[0].mac_addr[1],
@@ -5544,9 +5594,13 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	} else {
 		DBG_PRINT(ERR_DBG, "%s: Neterion Xframe I 10GbE adapter ",
 			  dev->name);
-		DBG_PRINT(ERR_DBG, "(rev %d), Driver %s\n",
+		DBG_PRINT(ERR_DBG, "(rev %d), %s",
 					get_xena_rev_id(sp->pdev),
 					s2io_driver_version);
+#ifdef CONFIG_2BUFF_MODE
+		DBG_PRINT(ERR_DBG, ", Buffer mode %d",2);
+#endif
+		DBG_PRINT(ERR_DBG, "\nCopyright(c) 2002-2005 Neterion Inc.\n");
 		DBG_PRINT(ERR_DBG, "MAC ADDR: %02x:%02x:%02x:%02x:%02x:%02x\n",
 			  sp->def_mac_addr[0].mac_addr[0],
 			  sp->def_mac_addr[0].mac_addr[1],
diff -urpN old/drivers/net/s2io.h new/drivers/net/s2io.h
--- old/drivers/net/s2io.h	2005-09-06 04:51:44.000000000 -0700
+++ new/drivers/net/s2io.h	2005-09-06 04:52:08.000000000 -0700
@@ -1,5 +1,5 @@
 /************************************************************************
- * s2io.h: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC
+ * s2io.h: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
  * Copyright(c) 2002-2005 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
@@ -622,6 +622,9 @@ typedef struct mac_info {
 	/* Fifo specific structure */
 	fifo_info_t fifos[MAX_TX_FIFOS];
 
+	/* Save virtual address of TxD page with zero DMA addr(if any) */
+	void *zerodma_virt_addr;
+
 /* rx side stuff */
 	/* Ring specific structure */
 	ring_info_t rings[MAX_RX_RINGS];
