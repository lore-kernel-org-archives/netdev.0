From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 2/2]S2io: Removed unused feature - bimodal interrupts
Date: 15 Aug 2007 17:13:47 -0700
Message-ID: <1187223226.23940.346.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:49078 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761144AbXHOWWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 18:22:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Removed bimodal interrupt support - unused feature

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch1/drivers/net/s2io.c patch2/drivers/net/s2io.c
--- patch1/drivers/net/s2io.c	2007-08-10 11:53:46.000000000 +0530
+++ patch2/drivers/net/s2io.c	2007-08-10 11:54:21.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.3"
+#define DRV_VERSION "2.0.26.4"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -447,7 +447,6 @@ S2IO_PARM_INT(mc_pause_threshold_q4q7, 1
 S2IO_PARM_INT(shared_splits, 0);
 S2IO_PARM_INT(tmac_util_period, 5);
 S2IO_PARM_INT(rmac_util_period, 5);
-S2IO_PARM_INT(bimodal, 0);
 S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
@@ -1559,90 +1558,57 @@ static int init_nic(struct s2io_nic *nic
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
+	val64 |= RTI_DATA1_MEM_RX_URNG_A(0xA) |
+		RTI_DATA1_MEM_RX_URNG_B(0x10) |
+		RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
+
+	writeq(val64, &bar0->rti_data1_mem);
+
+	val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
+		RTI_DATA2_MEM_RX_UFC_B(0x2) ;
+	if (nic->config.intr_type == MSI_X)
+		val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x20) | \
 				RTI_DATA2_MEM_RX_UFC_D(0x40));
-		else
-		    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x40) | \
+	else
+		val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x40) | \
 				RTI_DATA2_MEM_RX_UFC_D(0x80));
-		writeq(val64, &bar0->rti_data2_mem);
+	writeq(val64, &bar0->rti_data2_mem);
 
-		for (i = 0; i < config->rx_ring_num; i++) {
-			val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD
-					| RTI_CMD_MEM_OFFSET(i);
-			writeq(val64, &bar0->rti_command_mem);
+	for (i = 0; i < config->rx_ring_num; i++) {
+		val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD
+			| RTI_CMD_MEM_OFFSET(i);
+		writeq(val64, &bar0->rti_command_mem);
 
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
+			if (time > 10) {
+				DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
+					  dev->name);
+				return -1;
 			}
+			time++;
+			msleep(50);
 		}
 	}
 
@@ -2358,8 +2324,6 @@ static int start_nic(struct s2io_nic *ni
 		       &bar0->prc_rxd0_n[i]);
 
 		val64 = readq(&bar0->prc_ctrl_n[i]);
-		if (nic->config.bimodal)
-			val64 |= PRC_CTRL_BIMODAL_INTERRUPT;
 		if (nic->rxd_mode == RXD_MODE_1)
 			val64 |= PRC_CTRL_RC_ENABLED;
 		else
@@ -3924,27 +3888,14 @@ static int s2io_enable_msi_x(struct s2io
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
+		nic->s2io_entries[msix_indx].arg = &nic->mac_control.rings[j];
+		nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
+		nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
 	}
+	writeq(rx_mat, &bar0->rx_mat);
 
 	nic->avail_msix_vectors = 0;
 	ret = pci_enable_msix(nic->pdev, nic->entries, MAX_REQUESTED_MSI_X);
@@ -8118,14 +8069,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
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
diff -urpN patch1/drivers/net/s2io.h patch2/drivers/net/s2io.h
--- patch1/drivers/net/s2io.h	2007-08-09 17:28:36.000000000 +0530
+++ patch2/drivers/net/s2io.h	2007-08-10 11:33:56.000000000 +0530
@@ -444,7 +444,6 @@ struct config_param {
 #define MAX_RX_BLOCKS_PER_RING  150
 
 	struct rx_ring_config rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring config */
-	u8 bimodal;		/*Flag for setting bimodal interrupts*/
 
 #define HEADER_ETHERNET_II_802_3_SIZE 14
 #define HEADER_802_2_SIZE              3



