From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.25 2/2]S2io: Fixes to enable multiple transmit fifos
Date: 17 Dec 2007 11:40:15 -0800
Message-ID: <1197920414.7518.45.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: support@neterion.com
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:54021 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbXLQSJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 13:09:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiple transmit fifo initialization -
  - Assigned equal scheduling priority for all configured FIFO's.
  - Modularized transmit traffic interrupt initialization since it is executed in
    s2io_card_up and s2io_link. Enable continuous tx interrupt when link is UP 
    and vice verse.
  - Enable transmit interrupts for all configured transmit fifos.
  - Fixed typo errors.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-15-1/drivers/net/s2io.c 2-0-26-15-2/drivers/net/s2io.c
--- 2-0-26-15-1/drivers/net/s2io.c	2007-12-17 22:10:50.000000000 +0530
+++ 2-0-26-15-2/drivers/net/s2io.c	2007-12-17 22:52:13.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.15-1"
+#define DRV_VERSION "2.0.26.15-2"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -1079,8 +1079,67 @@ static int s2io_print_pci_mode(struct s2
 }
 
 /**
+ *  init_tti - Initialization transmit traffic interrupt scheme
+ *  @nic: device private variable
+ *  @link: link status (UP/DOWN) used to enable/disable continuous
+ *  transmit interrupts
+ *  Description: The function configures transmit traffic interrupts
+ *  Return Value:  SUCCESS on success and
+ *  '-1' on failure
+ */
+
+int init_tti(struct s2io_nic *nic, int link)
+{
+	struct XENA_dev_config __iomem *bar0 = nic->bar0;
+	register u64 val64 = 0;
+	int i;
+	struct config_param *config;
+
+	config = &nic->config;
+
+	for (i = 0; i < config->tx_fifo_num; i++) {
+		/*
+		 * TTI Initialization. Default Tx timer gets us about
+		 * 250 interrupts per sec. Continuous interrupts are enabled
+		 * by default.
+		 */
+		if (nic->device_type == XFRAME_II_DEVICE) {
+			int count = (nic->config.bus_speed * 125)/2;
+			val64 = TTI_DATA1_MEM_TX_TIMER_VAL(count);
+		} else
+			val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0x2078);
+
+		val64 |= TTI_DATA1_MEM_TX_URNG_A(0xA) |
+				TTI_DATA1_MEM_TX_URNG_B(0x10) |
+				TTI_DATA1_MEM_TX_URNG_C(0x30) |
+				TTI_DATA1_MEM_TX_TIMER_AC_EN;
+
+		if (use_continuous_tx_intrs && (link == LINK_UP))
+			val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
+		writeq(val64, &bar0->tti_data1_mem);
+
+		val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
+				TTI_DATA2_MEM_TX_UFC_B(0x20) |
+				TTI_DATA2_MEM_TX_UFC_C(0x40) |
+				TTI_DATA2_MEM_TX_UFC_D(0x80);
+
+		writeq(val64, &bar0->tti_data2_mem);
+
+		val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD |
+				TTI_CMD_MEM_OFFSET(i);
+		writeq(val64, &bar0->tti_command_mem);
+
+		if (wait_for_cmd_complete(&bar0->tti_command_mem,
+			TTI_CMD_MEM_STROBE_NEW_CMD, S2IO_BIT_RESET) != SUCCESS)
+			return FAILURE;
+	}
+
+	return SUCCESS;
+}
+
+/**
  *  init_nic - Initialization of hardware
- *  @nic: device peivate variable
+ *  @nic: device private variable
  *  Description: The function sequentially configures every block
  *  of the H/W from their reset values.
  *  Return Value:  SUCCESS on success and
@@ -1185,9 +1244,9 @@ static int init_nic(struct s2io_nic *nic
 
 	for (i = 0, j = 0; i < config->tx_fifo_num; i++) {
 		val64 |=
-		    vBIT(config->tx_cfg[i].fifo_len - 1, ((i * 32) + 19),
+		    vBIT(config->tx_cfg[i].fifo_len - 1, ((j * 32) + 19),
 			 13) | vBIT(config->tx_cfg[i].fifo_priority,
-				    ((i * 32) + 5), 3);
+				    ((j * 32) + 5), 3);
 
 		if (i == (config->tx_fifo_num - 1)) {
 			if (i % 2 == 0)
@@ -1198,17 +1257,25 @@ static int init_nic(struct s2io_nic *nic
 		case 1:
 			writeq(val64, &bar0->tx_fifo_partition_0);
 			val64 = 0;
+			j = 0;
 			break;
 		case 3:
 			writeq(val64, &bar0->tx_fifo_partition_1);
 			val64 = 0;
+			j = 0;
 			break;
 		case 5:
 			writeq(val64, &bar0->tx_fifo_partition_2);
 			val64 = 0;
+			j = 0;
 			break;
 		case 7:
 			writeq(val64, &bar0->tx_fifo_partition_3);
+			val64 = 0;
+			j = 0;
+			break;
+		default:
+			j++;
 			break;
 		}
 	}
@@ -1294,11 +1361,11 @@ static int init_nic(struct s2io_nic *nic
 
 	/*
 	 * Filling Tx round robin registers
-	 * as per the number of FIFOs
+	 * as per the number of FIFOs for equal scheduling priority
 	 */
 	switch (config->tx_fifo_num) {
 	case 1:
-		val64 = 0x0000000000000000ULL;
+		val64 = 0x0;
 		writeq(val64, &bar0->tx_w_round_robin_0);
 		writeq(val64, &bar0->tx_w_round_robin_1);
 		writeq(val64, &bar0->tx_w_round_robin_2);
@@ -1306,87 +1373,78 @@ static int init_nic(struct s2io_nic *nic
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	case 2:
-		val64 = 0x0000010000010000ULL;
+		val64 = 0x0001000100010001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_0);
-		val64 = 0x0100000100000100ULL;
 		writeq(val64, &bar0->tx_w_round_robin_1);
-		val64 = 0x0001000001000001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_2);
-		val64 = 0x0000010000010000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_3);
-		val64 = 0x0100000000000000ULL;
+		val64 = 0x0001000100000000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	case 3:
-		val64 = 0x0001000102000001ULL;
+		val64 = 0x0001020001020001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_0);
-		val64 = 0x0001020000010001ULL;
+		val64 = 0x0200010200010200ULL;
 		writeq(val64, &bar0->tx_w_round_robin_1);
-		val64 = 0x0200000100010200ULL;
+		val64 = 0x0102000102000102ULL;
 		writeq(val64, &bar0->tx_w_round_robin_2);
-		val64 = 0x0001000102000001ULL;
+		val64 = 0x0001020001020001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_3);
-		val64 = 0x0001020000000000ULL;
+		val64 = 0x0200010200000000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	case 4:
-		val64 = 0x0001020300010200ULL;
+		val64 = 0x0001020300010203ULL;
 		writeq(val64, &bar0->tx_w_round_robin_0);
-		val64 = 0x0100000102030001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_1);
-		val64 = 0x0200010000010203ULL;
 		writeq(val64, &bar0->tx_w_round_robin_2);
-		val64 = 0x0001020001000001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_3);
-		val64 = 0x0203000100000000ULL;
+		val64 = 0x0001020300000000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	case 5:
-		val64 = 0x0001000203000102ULL;
+		val64 = 0x0001020304000102ULL;
 		writeq(val64, &bar0->tx_w_round_robin_0);
-		val64 = 0x0001020001030004ULL;
+		val64 = 0x0304000102030400ULL;
 		writeq(val64, &bar0->tx_w_round_robin_1);
-		val64 = 0x0001000203000102ULL;
+		val64 = 0x0102030400010203ULL;
 		writeq(val64, &bar0->tx_w_round_robin_2);
-		val64 = 0x0001020001030004ULL;
+		val64 = 0x0400010203040001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_3);
-		val64 = 0x0001000000000000ULL;
+		val64 = 0x0203040000000000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	case 6:
-		val64 = 0x0001020304000102ULL;
+		val64 = 0x0001020304050001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_0);
-		val64 = 0x0304050001020001ULL;
+		val64 = 0x0203040500010203ULL;
 		writeq(val64, &bar0->tx_w_round_robin_1);
-		val64 = 0x0203000100000102ULL;
+		val64 = 0x0405000102030405ULL;
 		writeq(val64, &bar0->tx_w_round_robin_2);
-		val64 = 0x0304000102030405ULL;
+		val64 = 0x0001020304050001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_3);
-		val64 = 0x0001000200000000ULL;
+		val64 = 0x0203040500000000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	case 7:
-		val64 = 0x0001020001020300ULL;
+		val64 = 0x0001020304050600ULL;
 		writeq(val64, &bar0->tx_w_round_robin_0);
-		val64 = 0x0102030400010203ULL;
+		val64 = 0x0102030405060001ULL;
 		writeq(val64, &bar0->tx_w_round_robin_1);
-		val64 = 0x0405060001020001ULL;
+		val64 = 0x0203040506000102ULL;
 		writeq(val64, &bar0->tx_w_round_robin_2);
-		val64 = 0x0304050000010200ULL;
+		val64 = 0x0304050600010203ULL;
 		writeq(val64, &bar0->tx_w_round_robin_3);
-		val64 = 0x0102030000000000ULL;
+		val64 = 0x0405060000000000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	case 8:
-		val64 = 0x0001020300040105ULL;
+		val64 = 0x0001020304050607ULL;
 		writeq(val64, &bar0->tx_w_round_robin_0);
-		val64 = 0x0200030106000204ULL;
 		writeq(val64, &bar0->tx_w_round_robin_1);
-		val64 = 0x0103000502010007ULL;
 		writeq(val64, &bar0->tx_w_round_robin_2);
-		val64 = 0x0304010002060500ULL;
 		writeq(val64, &bar0->tx_w_round_robin_3);
-		val64 = 0x0103020400000000ULL;
+		val64 = 0x0001020300000000ULL;
 		writeq(val64, &bar0->tx_w_round_robin_4);
 		break;
 	}
@@ -1563,58 +1621,14 @@ static int init_nic(struct s2io_nic *nic
 	    MAC_RX_LINK_UTIL_VAL(rmac_util_period);
 	writeq(val64, &bar0->mac_link_util);
 
-
 	/*
 	 * Initializing the Transmit and Receive Traffic Interrupt
 	 * Scheme.
 	 */
-	/*
-	 * TTI Initialization. Default Tx timer gets us about
-	 * 250 interrupts per sec. Continuous interrupts are enabled
-	 * by default.
-	 */
-	if (nic->device_type == XFRAME_II_DEVICE) {
-		int count = (nic->config.bus_speed * 125)/2;
-		val64 = TTI_DATA1_MEM_TX_TIMER_VAL(count);
-	} else {
-
-		val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0x2078);
-	}
-	val64 |= TTI_DATA1_MEM_TX_URNG_A(0xA) |
-	    TTI_DATA1_MEM_TX_URNG_B(0x10) |
-	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;
-		if (use_continuous_tx_intrs)
-			val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
-	writeq(val64, &bar0->tti_data1_mem);
-
-	val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
-	    TTI_DATA2_MEM_TX_UFC_B(0x20) |
-	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);
-	writeq(val64, &bar0->tti_data2_mem);
 
-	val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
-	writeq(val64, &bar0->tti_command_mem);
-
-	/*
-	 * Once the operation completes, the Strobe bit of the command
-	 * register will be reset. We poll for this particular condition
-	 * We wait for a maximum of 500ms for the operation to complete,
-	 * if it's not complete by then we return error.
-	 */
-	time = 0;
-	while (TRUE) {
-		val64 = readq(&bar0->tti_command_mem);
-		if (!(val64 & TTI_CMD_MEM_STROBE_NEW_CMD)) {
-			break;
-		}
-		if (time > 10) {
-			DBG_PRINT(ERR_DBG, "%s: TTI init Failed\n",
-				  dev->name);
-			return -ENODEV;
-		}
-		msleep(50);
-		time++;
-	}
+	/* Initialize TTI */
+	if (SUCCESS != init_tti(nic, nic->last_link_state))
+		return -ENODEV;
 
 	/* RTI Initialization */
 	if (nic->device_type == XFRAME_II_DEVICE) {
@@ -7439,6 +7453,7 @@ static void s2io_link(struct s2io_nic * 
 	struct net_device *dev = (struct net_device *) sp->dev;
 
 	if (link != sp->last_link_state) {
+		init_tti(sp, link);
 		if (link == LINK_DOWN) {
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
 			netif_carrier_off(dev);
@@ -7537,7 +7552,7 @@ static int s2io_verify_parm(struct pci_d
 /**
  * rts_ds_steer - Receive traffic steering based on IPv4 or IPv6 TOS
  * or Traffic class respectively.
- * @nic: device peivate variable
+ * @nic: device private variable
  * Description: The function configures the receive steering to
  * desired receive ring.
  * Return Value:  SUCCESS on success and



