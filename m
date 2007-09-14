From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 2/2]S2io: Removed unused feature - bimodal interrupts
Date: Fri, 14 Sep 2007 07:32:57 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10709140729040.474-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:52921 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbXINLc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 07:32:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Removed bimodal interrupt support - unused feature

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -pNur prior/drivers/net/s2io.c patch_dir/drivers/net/s2io.c
--- prior/drivers/net/s2io.c	2007-09-06 11:31:04.000000000 -0700
+++ patch_dir/drivers/net/s2io.c	2007-09-06 11:37:10.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.2"
+#define DRV_VERSION "2.0.26.4"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -452,7 +452,6 @@ S2IO_PARM_INT(mc_pause_threshold_q4q7, 1
 S2IO_PARM_INT(shared_splits, 0);
 S2IO_PARM_INT(tmac_util_period, 5);
 S2IO_PARM_INT(rmac_util_period, 5);
-S2IO_PARM_INT(bimodal, 0);
 S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
@@ -1565,90 +1564,57 @@ static int init_nic(struct s2io_nic *nic
 		time++;
 	}
 
-	if (nic->config.bimodal) {
-		int k = 0;
-		for (k = 0; k < config->rx_ring_num; k++) {
-			val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
-			val64 |= TTI_CMD_MEM_OFFSET(0x38+k);
-			writeq(val64, &bar0->tti_command_mem);
-
+	/* RTI Initialization */
+	if (nic->device_type == XFRAME_II_DEVICE) {
 		/*
-		 * Once the operation completes, the Strobe bit of the command
-		 * register will be reset. We poll for this particular condition
-		 * We wait for a maximum of 500ms for the operation to complete,
-		 * if it's not complete by then we return error.
-		*/
-			time = 0;
-			while (TRUE) {
-				val64 = readq(&bar0->tti_command_mem);
-				if (!(val64 & TTI_CMD_MEM_STROBE_NEW_CMD)) {
-					break;
-				}
-				if (time > 10) {
-					DBG_PRINT(ERR_DBG,
-						"%s: TTI init Failed\n",
-					dev->name);
-					return -1;
-				}
-				time++;
-				msleep(50);
-			}
-		}
-	} else {
+		 * Programmed to generate Apprx 500 Intrs per
+		 * second
+		 */
+		int count = (nic->config.bus_speed * 125)/4;
+		val64 = RTI_DATA1_MEM_RX_TIMER_VAL(count);
+	} else
+		val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF);
+	val64 |= RTI_DATA1_MEM_RX_URNG_A(0xA) |
+	    	RTI_DATA1_MEM_RX_URNG_B(0x10) |
+	    	RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
+
+	writeq(val64, &bar0->rti_data1_mem);
+
+	val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
+	    	RTI_DATA2_MEM_RX_UFC_B(0x2) ;
+	if (nic->config.intr_type == MSI_X)
+	    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x20) | \
+			RTI_DATA2_MEM_RX_UFC_D(0x40));
+	else
+	    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x40) | \
+			RTI_DATA2_MEM_RX_UFC_D(0x80));
+	writeq(val64, &bar0->rti_data2_mem);
 
-		/* RTI Initialization */
-		if (nic->device_type == XFRAME_II_DEVICE) {
-			/*
-			 * Programmed to generate Apprx 500 Intrs per
-			 * second
-			 */
-			int count = (nic->config.bus_speed * 125)/4;
-			val64 = RTI_DATA1_MEM_RX_TIMER_VAL(count);
-		} else {
-			val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF);
-		}
-		val64 |= RTI_DATA1_MEM_RX_URNG_A(0xA) |
-		    RTI_DATA1_MEM_RX_URNG_B(0x10) |
-		    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
-
-		writeq(val64, &bar0->rti_data1_mem);
-
-		val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
-		    RTI_DATA2_MEM_RX_UFC_B(0x2) ;
-		if (nic->config.intr_type == MSI_X)
-		    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x20) | \
-				RTI_DATA2_MEM_RX_UFC_D(0x40));
-		else
-		    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x40) | \
-				RTI_DATA2_MEM_RX_UFC_D(0x80));
-		writeq(val64, &bar0->rti_data2_mem);
+	for (i = 0; i < config->rx_ring_num; i++) {
+		val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD
+				| RTI_CMD_MEM_OFFSET(i);
+		writeq(val64, &bar0->rti_command_mem);
 
-		for (i = 0; i < config->rx_ring_num; i++) {
-			val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD
-					| RTI_CMD_MEM_OFFSET(i);
-			writeq(val64, &bar0->rti_command_mem);
+		/*
+		 * Once the operation completes, the Strobe bit of the
+		 * command register will be reset. We poll for this
+		 * particular condition. We wait for a maximum of 500ms
+		 * for the operation to complete, if it's not complete
+		 * by then we return error.
+		 */
+		time = 0;
+		while (TRUE) {
+			val64 = readq(&bar0->rti_command_mem);
+			if (!(val64 & RTI_CMD_MEM_STROBE_NEW_CMD))
+				break;
 
-			/*
-			 * Once the operation completes, the Strobe bit of the
-			 * command register will be reset. We poll for this
-			 * particular condition. We wait for a maximum of 500ms
-			 * for the operation to complete, if it's not complete
-			 * by then we return error.
-			 */
-			time = 0;
-			while (TRUE) {
-				val64 = readq(&bar0->rti_command_mem);
-				if (!(val64 & RTI_CMD_MEM_STROBE_NEW_CMD)) {
-					break;
-				}
-				if (time > 10) {
-					DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
-						  dev->name);
-					return -1;
-				}
-				time++;
-				msleep(50);
+			if (time > 10) {
+				DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
+					  dev->name);
+				return -1;
 			}
+			time++;
+			msleep(50);
 		}
 	}
 
@@ -2151,8 +2117,6 @@ static int start_nic(struct s2io_nic *ni
 		       &bar0->prc_rxd0_n[i]);
 
 		val64 = readq(&bar0->prc_ctrl_n[i]);
-		if (nic->config.bimodal)
-			val64 |= PRC_CTRL_BIMODAL_INTERRUPT;
 		if (nic->rxd_mode == RXD_MODE_1)
 			val64 |= PRC_CTRL_RC_ENABLED;
 		else
@@ -3710,27 +3674,15 @@ static int s2io_enable_msi_x(struct s2io
 	}
 	writeq(tx_mat, &bar0->tx_mat0_n[0]);
 
-	if (!nic->config.bimodal) {
-		rx_mat = readq(&bar0->rx_mat);
-		for (j=0; j<nic->config.rx_ring_num; j++, msix_indx++) {
-			rx_mat |= RX_MAT_SET(j, msix_indx);
-			nic->s2io_entries[msix_indx].arg 
-				= &nic->mac_control.rings[j];
-			nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
-			nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
-		}
-		writeq(rx_mat, &bar0->rx_mat);
-	} else {
-		tx_mat = readq(&bar0->tx_mat0_n[7]);
-		for (j=0; j<nic->config.rx_ring_num; j++, msix_indx++) {
-			tx_mat |= TX_MAT_SET(i, msix_indx);
-			nic->s2io_entries[msix_indx].arg 
-				= &nic->mac_control.rings[j];
-			nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
-			nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
-		}
-		writeq(tx_mat, &bar0->tx_mat0_n[7]);
+	rx_mat = readq(&bar0->rx_mat);
+	for (j=0; j<nic->config.rx_ring_num; j++, msix_indx++) {
+		rx_mat |= RX_MAT_SET(j, msix_indx);
+		nic->s2io_entries[msix_indx].arg 
+			= &nic->mac_control.rings[j];
+		nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
+		nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
 	}
+	writeq(rx_mat, &bar0->rx_mat);
 
 	nic->avail_msix_vectors = 0;
 	ret = pci_enable_msix(nic->pdev, nic->entries, MAX_REQUESTED_MSI_X);
@@ -7771,14 +7723,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	/* Initialize device name */
 	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
 
-	/* Initialize bimodal Interrupts */
-	sp->config.bimodal = bimodal;
-	if (!(sp->device_type & XFRAME_II_DEVICE) && bimodal) {
-		sp->config.bimodal = 0;
-		DBG_PRINT(ERR_DBG,"%s:Bimodal intr not supported by Xframe I\n",
-			dev->name);
-	}
-
 	/*
 	 * Make Link state as off at this point, when the Link change
 	 * interrupt comes the state will be automatically changed to
diff -pNur prior/drivers/net/s2io.h patch_dir/drivers/net/s2io.h
--- prior/drivers/net/s2io.h	2007-09-06 11:30:57.000000000 -0700
+++ patch_dir/drivers/net/s2io.h	2007-09-06 11:25:22.000000000 -0700
@@ -444,7 +444,6 @@ struct config_param {
 #define MAX_RX_BLOCKS_PER_RING  150
 
 	struct rx_ring_config rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring config */
-	u8 bimodal;		/*Flag for setting bimodal interrupts*/
 
 #define HEADER_ETHERNET_II_802_3_SIZE 14
 #define HEADER_802_2_SIZE              3

