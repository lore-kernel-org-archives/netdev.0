From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [patch 2/5] s2io driver updates
Date: Fri, 21 Apr 2006 19:05:41 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10604211903180.15266-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, alicia.pena@neterion.com,
	ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:57802 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750725AbWDUXFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 19:05:44 -0400
To: jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi, 
	This patch contains the modification and bug fixes with respect to 
	input parameters and outupt dmesages. following is brief description 
	of the changes.

	1. Set default values for rx_ring_sz[0..7] and tx_fifo_len[0..7]
	2. verify few basic load parameters
	3. read product description from VPD
	4. clean up of dmesg  when driver is loaded

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr perf_fixes/drivers/net/s2io.c dmesg_param_fixes/drivers/net/s2io.c
--- perf_fixes/drivers/net/s2io.c	2006-04-13 08:02:56.000000000 -0700
+++ dmesg_param_fixes/drivers/net/s2io.c	2006-04-13 09:08:22.000000000 -0700
@@ -26,15 +26,22 @@
  *
  * The module loadable parameters that are supported by the driver and a brief
  * explaination of all the variables.
+ *
  * rx_ring_num : This can be used to program the number of receive rings used
  * in the driver.
- * rx_ring_sz: This defines the number of descriptors each ring can have. This
- * is also an array of size 8.
+ * rx_ring_sz: This defines the number of receive blocks each ring can have.
+ *     This is also an array of size 8.
  * rx_ring_mode: This defines the operation mode of all 8 rings. The valid
  *		values are 1, 2 and 3.
  * tx_fifo_num: This defines the number of Tx FIFOs thats used int the driver.
  * tx_fifo_len: This too is an array of 8. Each element defines the number of
  * Tx descriptors that can be associated with each corresponding FIFO.
+ * intr_type: This defines the type of interrupt. The values can be 0(INTA),
+ *     1(MSI), 2(MSI_X). Default value is '0(INTA)'
+ * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
+ *     Possible values '1' for enable '0' for disable. Default is '0'
+ * lro_max_pkts: This parameter defines maximum number of packets can be
+ *     aggregated as a single large packet
  ************************************************************************/
 
 #include <linux/config.h>
@@ -299,10 +306,10 @@ static const u64 fix_mac[] = {
 /* Module Loadable parameters. */
 static unsigned int tx_fifo_num = 1;
 static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
-    {[0 ...(MAX_TX_FIFOS - 1)] = 0 };
+    {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
 static unsigned int rx_ring_num = 1;
 static unsigned int rx_ring_sz[MAX_RX_RINGS] =
-    {[0 ...(MAX_RX_RINGS - 1)] = 0 };
+    {[0 ...(MAX_RX_RINGS - 1)] = SMALL_BLK_CNT};
 static unsigned int rts_frm_len[MAX_RX_RINGS] =
     {[0 ...(MAX_RX_RINGS - 1)] = 0 };
 static unsigned int rx_ring_mode = 1;
@@ -4626,6 +4633,45 @@ static int write_eeprom(nic_t * sp, int 
 	return ret;
 }
 
+static void s2io_vpd_read(nic_t *nic)
+{
+	u8 vpd_data[256],data;
+	int i=0, cnt, fail = 0;
+	int vpd_addr = 0x80;
+
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		strcpy(nic->product_name, "Xframe II 10GbE network adapter");
+		vpd_addr = 0x80;
+	}
+	else {
+		strcpy(nic->product_name, "Xframe I 10GbE network adapter");
+		vpd_addr = 0x50;
+	}
+
+	for (i = 0; i < 256; i +=4 ) {
+		pci_write_config_byte(nic->pdev, (vpd_addr + 2), i);
+		pci_read_config_byte(nic->pdev,  (vpd_addr + 2), &data);
+		pci_write_config_byte(nic->pdev, (vpd_addr + 3), 0);
+		for (cnt = 0; cnt <5; cnt++) {
+			msleep(2);
+			pci_read_config_byte(nic->pdev, (vpd_addr + 3), &data);
+			if (data == 0x80)
+				break;
+		}
+		if (cnt >= 5) {
+			DBG_PRINT(ERR_DBG, "Read of VPD data failed\n");
+			fail = 1;
+			break;
+		}
+		pci_read_config_dword(nic->pdev,  (vpd_addr + 4),
+				      (u32 *)&vpd_data[i]);
+	}
+	if ((!fail) && (vpd_data[1] < VPD_PRODUCT_NAME_LEN)) {
+		memset(nic->product_name, 0, vpd_data[1]);
+		memcpy(nic->product_name, &vpd_data[3], vpd_data[1]);
+	}
+}
+
 /**
  *  s2io_ethtool_geeprom  - reads the value stored in the Eeprom.
  *  @sp : private member of the device structure, which is a pointer to the *       s2io_nic structure.
@@ -5962,6 +6008,55 @@ module_param(intr_type, int, 0);
 module_param(lro, int, 0);
 module_param(lro_max_pkts, int, 0);
 
+static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type)
+{
+	if ( tx_fifo_num > 8) {
+		DBG_PRINT(ERR_DBG, "s2io: Requested number of Tx fifos not "
+			 "supported\n");
+		DBG_PRINT(ERR_DBG, "s2io: Default to 8 Tx fifos\n");
+		tx_fifo_num = 8;
+	}
+	if ( rx_ring_num > 8) {
+		DBG_PRINT(ERR_DBG, "s2io: Requested number of Rx rings not "
+			 "supported\n");
+		DBG_PRINT(ERR_DBG, "s2io: Default to 8 Rx rings\n");
+		rx_ring_num = 8;
+	}
+#ifdef CONFIG_S2IO_NAPI
+	if (*dev_intr_type != INTA) {
+		DBG_PRINT(ERR_DBG, "s2io: NAPI cannot be enabled when "
+			  "MSI/MSI-X is enabled. Defaulting to INTA\n");
+		*dev_intr_type = INTA;
+	}
+#endif
+#ifndef CONFIG_PCI_MSI
+	if (*dev_intr_type != INTA) {
+		DBG_PRINT(ERR_DBG, "s2io: This kernel does not support"
+			  "MSI/MSI-X. Defaulting to INTA\n");
+		*dev_intr_type = INTA;
+	}
+#else
+	if (*dev_intr_type > MSI_X) {
+		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
+			  "Defaulting to INTA\n");
+		*dev_intr_type = INTA;
+	}
+#endif
+	if ((*dev_intr_type == MSI_X) &&
+			((pdev->device != PCI_DEVICE_ID_HERC_WIN) &&
+			(pdev->device != PCI_DEVICE_ID_HERC_UNI))) {
+		DBG_PRINT(ERR_DBG, "s2io: Xframe I does not support MSI_X. " 
+					"Defaulting to INTA\n");
+		*dev_intr_type = INTA;
+	}
+	if (rx_ring_mode > 3) {
+		DBG_PRINT(ERR_DBG, "s2io: Requested ring mode not supported\n");
+		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 3-buffer mode\n");
+		rx_ring_mode = 3;
+	}
+	return SUCCESS;
+}
+
 /**
  *  s2io_init_nic - Initialization of the adapter .
  *  @pdev : structure containing the PCI related information of the device.
@@ -5992,15 +6087,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	int mode;
 	u8 dev_intr_type = intr_type;
 
-#ifdef CONFIG_S2IO_NAPI
-	if (dev_intr_type != INTA) {
-		DBG_PRINT(ERR_DBG, "NAPI cannot be enabled when MSI/MSI-X \
-is enabled. Defaulting to INTA\n");
-		dev_intr_type = INTA;
-	}
-	else
-		DBG_PRINT(ERR_DBG, "NAPI support has been enabled\n");
-#endif
+	if ((ret = s2io_verify_parm(pdev, &dev_intr_type)))
+		return ret;
 
 	if ((ret = pci_enable_device(pdev))) {
 		DBG_PRINT(ERR_DBG,
@@ -6025,14 +6113,6 @@ is enabled. Defaulting to INTA\n");
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
-
-	if ((dev_intr_type == MSI_X) && 
-			((pdev->device != PCI_DEVICE_ID_HERC_WIN) &&
-			(pdev->device != PCI_DEVICE_ID_HERC_UNI))) {
-		DBG_PRINT(ERR_DBG, "Xframe I does not support MSI_X. \
-Defaulting to INTA\n");
-		dev_intr_type = INTA;
-	}
 	if (dev_intr_type != MSI_X) {
 		if (pci_request_regions(pdev, s2io_driver_name)) {
 			DBG_PRINT(ERR_DBG, "Request Regions failed\n"),
@@ -6108,8 +6188,6 @@ Defaulting to INTA\n");
 	config = &sp->config;
 
 	/* Tx side parameters. */
-	if (tx_fifo_len[0] == 0)
-		tx_fifo_len[0] = DEFAULT_FIFO_LEN; /* Default value. */
 	config->tx_fifo_num = tx_fifo_num;
 	for (i = 0; i < MAX_TX_FIFOS; i++) {
 		config->tx_cfg[i].fifo_len = tx_fifo_len[i];
@@ -6133,8 +6211,6 @@ Defaulting to INTA\n");
 	config->max_txds = MAX_SKB_FRAGS + 2;
 
 	/* Rx side parameters. */
-	if (rx_ring_sz[0] == 0)
-		rx_ring_sz[0] = SMALL_BLK_CNT; /* Default value. */
 	config->rx_ring_num = rx_ring_num;
 	for (i = 0; i < MAX_RX_RINGS; i++) {
 		config->rx_cfg[i].num_rxd = rx_ring_sz[i] *
@@ -6330,82 +6406,63 @@ Defaulting to INTA\n");
 		ret = -ENODEV;
 		goto register_failed;
 	}
-
-	if (sp->device_type & XFRAME_II_DEVICE) {
-		DBG_PRINT(ERR_DBG, "%s: Neterion Xframe II 10GbE adapter ",
-			  dev->name);
-		DBG_PRINT(ERR_DBG, "(rev %d), Version %s",
+	s2io_vpd_read(sp);
+	DBG_PRINT(ERR_DBG, "%s: Neterion %s",dev->name, sp->product_name);
+	DBG_PRINT(ERR_DBG, "(rev %d), Driver version %s\n",
 				get_xena_rev_id(sp->pdev),
 				s2io_driver_version);
-		switch(sp->intr_type) {
-			case INTA:
-				DBG_PRINT(ERR_DBG, ", Intr type INTA");
-				break;
-			case MSI:
-				DBG_PRINT(ERR_DBG, ", Intr type MSI");
-				break;
-			case MSI_X:
-				DBG_PRINT(ERR_DBG, ", Intr type MSI-X");
-				break;
-		}
-
-		DBG_PRINT(ERR_DBG, "\nCopyright(c) 2002-2005 Neterion Inc.\n");
-		DBG_PRINT(ERR_DBG, "MAC ADDR: %02x:%02x:%02x:%02x:%02x:%02x\n",
+	DBG_PRINT(ERR_DBG, "Copyright(c) 2002-2005 Neterion Inc.\n");
+	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: "
+			  "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name,
 			  sp->def_mac_addr[0].mac_addr[0],
 			  sp->def_mac_addr[0].mac_addr[1],
 			  sp->def_mac_addr[0].mac_addr[2],
 			  sp->def_mac_addr[0].mac_addr[3],
 			  sp->def_mac_addr[0].mac_addr[4],
 			  sp->def_mac_addr[0].mac_addr[5]);
+	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_print_pci_mode(sp);
 		if (mode < 0) {
-			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode ");
+			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode\n");
 			ret = -EBADSLT;
+			unregister_netdev(dev);
 			goto set_swap_failed;
 		}
-	} else {
-		DBG_PRINT(ERR_DBG, "%s: Neterion Xframe I 10GbE adapter ",
-			  dev->name);
-		DBG_PRINT(ERR_DBG, "(rev %d), Version %s",
-					get_xena_rev_id(sp->pdev),
-					s2io_driver_version);
-		switch(sp->intr_type) {
-			case INTA:
-				DBG_PRINT(ERR_DBG, ", Intr type INTA");
-				break;
-			case MSI:
-				DBG_PRINT(ERR_DBG, ", Intr type MSI");
-				break;
-			case MSI_X:
-				DBG_PRINT(ERR_DBG, ", Intr type MSI-X");
-				break;
-		}
-		DBG_PRINT(ERR_DBG, "\nCopyright(c) 2002-2005 Neterion Inc.\n");
-		DBG_PRINT(ERR_DBG, "MAC ADDR: %02x:%02x:%02x:%02x:%02x:%02x\n",
-			  sp->def_mac_addr[0].mac_addr[0],
-			  sp->def_mac_addr[0].mac_addr[1],
-			  sp->def_mac_addr[0].mac_addr[2],
-			  sp->def_mac_addr[0].mac_addr[3],
-			  sp->def_mac_addr[0].mac_addr[4],
-			  sp->def_mac_addr[0].mac_addr[5]);
 	}
-	if (sp->rxd_mode == RXD_MODE_3B)
-		DBG_PRINT(ERR_DBG, "%s: 2-Buffer mode support has been "
-			  "enabled\n",dev->name);
-	if (sp->rxd_mode == RXD_MODE_3A)
-		DBG_PRINT(ERR_DBG, "%s: 3-Buffer mode support has been "
-			  "enabled\n",dev->name);
-
+	switch(sp->rxd_mode) {
+		case RXD_MODE_1:
+		    DBG_PRINT(ERR_DBG, "%s: 1-Buffer receive mode enabled\n",
+						dev->name);
+		    break;
+		case RXD_MODE_3B:
+		    DBG_PRINT(ERR_DBG, "%s: 2-Buffer receive mode enabled\n",
+						dev->name);
+		    break;
+		case RXD_MODE_3A:
+		    DBG_PRINT(ERR_DBG, "%s: 3-Buffer receive mode enabled\n",
+						dev->name);
+		    break;
+	}
+#ifdef CONFIG_S2IO_NAPI
+	DBG_PRINT(ERR_DBG, "%s: NAPI enabled\n", dev->name);
+#endif
+	switch(sp->intr_type) {
+		case INTA:
+		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
+		    break;
+		case MSI:
+		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI\n", dev->name);
+		    break;
+		case MSI_X:
+		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI-X\n", dev->name);
+		    break;
+	}
 	if (sp->lro)
 		DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
-			dev->name);
+			  dev->name);
 
 	/* Initialize device name */
-	strcpy(sp->name, dev->name);
-	if (sp->device_type & XFRAME_II_DEVICE)
-		strcat(sp->name, ": Neterion Xframe II 10GbE adapter");
-	else
-		strcat(sp->name, ": Neterion Xframe I 10GbE adapter");
+	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
 
 	/* Initialize bimodal Interrupts */
 	sp->config.bimodal = bimodal;
diff -upNr perf_fixes/drivers/net/s2io.h dmesg_param_fixes/drivers/net/s2io.h
--- perf_fixes/drivers/net/s2io.h	2006-04-13 06:48:13.000000000 -0700
+++ dmesg_param_fixes/drivers/net/s2io.h	2006-04-13 09:08:26.000000000 -0700
@@ -659,9 +659,10 @@ typedef struct {
 } usr_addr_t;
 
 /* Default Tunable parameters of the NIC. */
-#define DEFAULT_FIFO_LEN 4096
-#define SMALL_BLK_CNT	30
-#define LARGE_BLK_CNT	100
+#define DEFAULT_FIFO_0_LEN 4096
+#define DEFAULT_FIFO_1_7_LEN 512
+#define SMALL_BLK_CNT   30
+#define LARGE_BLK_CNT   100
 
 /*
  * Structure to keep track of the MSI-X vectors and the corresponding
@@ -824,6 +825,8 @@ struct s2io_nic {
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
 	u64 *ufo_in_band_v;
+#define VPD_PRODUCT_NAME_LEN 50
+	u8  product_name[VPD_PRODUCT_NAME_LEN];
 };
 
 #define RESET_ERROR 1;

