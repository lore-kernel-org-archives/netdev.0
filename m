From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 10/13] S2io: Support for bimodal interrupts
Date: Wed,  3 Aug 2005 12:38:01 -0700 (PDT)
Message-ID: <20050803193801.1649298336@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This is a patch to provide bimodal interrupt moderation support for
Xframe II adapter. Basically, in this moderation scheme, the adapter
raises a traffic interrupt if the no. of packets transmitted and/or
received reaches a programmable threshold.


Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 06:50:49.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 06:54:23.000000000 -0700
@@ -297,6 +297,7 @@ static unsigned int mc_pause_threshold_q
 static unsigned int shared_splits;
 static unsigned int tmac_util_period = 5;
 static unsigned int rmac_util_period = 5;
+static unsigned int bimodal = 0;
 #ifndef CONFIG_S2IO_NAPI
 static unsigned int indicate_max_pkts;
 #endif
@@ -1306,52 +1307,86 @@ static int init_nic(struct s2io_nic *nic
 		time++;
 	}
 
+	if (nic->config.bimodal) {
+		int k = 0;
+		for (k = 0; k < config->rx_ring_num; k++) {
+			val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
+			val64 |= TTI_CMD_MEM_OFFSET(0x38+k);
+			writeq(val64, &bar0->tti_command_mem);
 
-	/* RTI Initialization */
-	if (nic->device_type == XFRAME_II_DEVICE) {
 		/*
-		 * Programmed to generate Apprx 500 Intrs per
-		 * second
-		 */
-		int count = (nic->config.bus_speed * 125)/4;
-		val64 = RTI_DATA1_MEM_RX_TIMER_VAL(count);
+		 * Once the operation completes, the Strobe bit of the command
+		 * register will be reset. We poll for this particular condition
+		 * We wait for a maximum of 500ms for the operation to complete,
+		 * if it's not complete by then we return error.
+		*/
+			time = 0;
+			while (TRUE) {
+				val64 = readq(&bar0->tti_command_mem);
+				if (!(val64 & TTI_CMD_MEM_STROBE_NEW_CMD)) {
+					break;
+				}
+				if (time > 10) {
+					DBG_PRINT(ERR_DBG,
+						"%s: TTI init Failed\n",
+					dev->name);
+					return -1;
+				}
+				time++;
+				msleep(50);
+			}
+		}
 	} else {
-		val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF);
-	}
-	val64 |= RTI_DATA1_MEM_RX_URNG_A(0xA) |
-	    RTI_DATA1_MEM_RX_URNG_B(0x10) |
-	    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
-
-	writeq(val64, &bar0->rti_data1_mem);
 
-	val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
-	    RTI_DATA2_MEM_RX_UFC_B(0x2) |
-	    RTI_DATA2_MEM_RX_UFC_C(0x40) | RTI_DATA2_MEM_RX_UFC_D(0x80);
-	writeq(val64, &bar0->rti_data2_mem);
+		/* RTI Initialization */
+		if (nic->device_type == XFRAME_II_DEVICE) {
+			/*
+			 * Programmed to generate Apprx 500 Intrs per
+			 * second
+			 */
+			int count = (nic->config.bus_speed * 125)/4;
+			val64 = RTI_DATA1_MEM_RX_TIMER_VAL(count);
+		} else {
+			val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF);
+		}
+		val64 |= RTI_DATA1_MEM_RX_URNG_A(0xA) |
+		    RTI_DATA1_MEM_RX_URNG_B(0x10) |
+		    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
+
+		writeq(val64, &bar0->rti_data1_mem);
+
+		val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
+		    RTI_DATA2_MEM_RX_UFC_B(0x2) |
+		    RTI_DATA2_MEM_RX_UFC_C(0x40) | RTI_DATA2_MEM_RX_UFC_D(0x80);
+		writeq(val64, &bar0->rti_data2_mem);
 
-	val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;
-	writeq(val64, &bar0->rti_command_mem);
+		for (i = 0; i < config->rx_ring_num; i++) {
+			val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD
+					| RTI_CMD_MEM_OFFSET(i);
+			writeq(val64, &bar0->rti_command_mem);
 
-	/*
-	 * Once the operation completes, the Strobe bit of the
-	 * command register will be reset. We poll for this
-	 * particular condition. We wait for a maximum of 500ms
-	 * for the operation to complete, if it's not complete
-	 * by then we return error.
-	 */
-	time = 0;
-	while (TRUE) {
-		val64 = readq(&bar0->rti_command_mem);
-		if (!(val64 & RTI_CMD_MEM_STROBE_NEW_CMD)) {
-			break;
-		}
-		if (time > 10) {
-			DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
-				  dev->name);
-			return -1;
+			/*
+			 * Once the operation completes, the Strobe bit of the
+			 * command register will be reset. We poll for this
+			 * particular condition. We wait for a maximum of 500ms
+			 * for the operation to complete, if it's not complete
+			 * by then we return error.
+			 */
+			time = 0;
+			while (TRUE) {
+				val64 = readq(&bar0->rti_command_mem);
+				if (!(val64 & RTI_CMD_MEM_STROBE_NEW_CMD)) {
+					break;
+				}
+				if (time > 10) {
+					DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
+						  dev->name);
+					return -1;
+				}
+				time++;
+				msleep(50);
+			}
 		}
-		time++;
-		msleep(50);
 	}
 
 	/*
@@ -1789,6 +1824,8 @@ static int start_nic(struct s2io_nic *ni
 		       &bar0->prc_rxd0_n[i]);
 
 		val64 = readq(&bar0->prc_ctrl_n[i]);
+		if (nic->config.bimodal)
+			val64 |= PRC_CTRL_BIMODAL_INTERRUPT;
 #ifndef CONFIG_2BUFF_MODE
 		val64 |= PRC_CTRL_RC_ENABLED;
 #else
@@ -5030,6 +5067,7 @@ module_param(mc_pause_threshold_q4q7, in
 module_param(shared_splits, int, 0);
 module_param(tmac_util_period, int, 0);
 module_param(rmac_util_period, int, 0);
+module_param(bimodal, bool, 0);
 #ifndef CONFIG_S2IO_NAPI
 module_param(indicate_max_pkts, int, 0);
 #endif
@@ -5397,6 +5435,14 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	else
 		strcat(sp->name, ": Neterion Xframe I 10GbE adapter");
 
+	/* Initialize bimodal Interrupts */
+	sp->config.bimodal = bimodal;
+	if (!(sp->device_type & XFRAME_II_DEVICE) && bimodal) {
+		sp->config.bimodal = 0;
+		DBG_PRINT(ERR_DBG,"%s:Bimodal intr not supported by Xframe I\n",
+			dev->name);
+	}
+
 	/*
 	 * Make Link state as off at this point, when the Link change
 	 * interrupt comes the state will be automatically changed to
diff -uprN vanilla_linux/drivers/net/s2io.h linux-2.6.13-rc4/drivers/net/s2io.h
--- vanilla_linux/drivers/net/s2io.h	2005-08-02 06:50:49.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.h	2005-08-02 06:54:23.000000000 -0700
@@ -261,8 +261,6 @@ typedef struct stat_block {
 	u32 rmac_accepted_ip_oflow;
 	u32 reserved_14;
 	u32 link_fault_cnt;
-
-/* Software statistics maintained by driver */
 	swStat_t sw_stat;
 } StatInfo_t;
 
@@ -349,6 +347,7 @@ struct config_param {
 #define MAX_RX_BLOCKS_PER_RING  150
 
 	rx_ring_config_t rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring config */
+	u8 bimodal;		/*Flag for setting bimodal interrupts*/
 
 #define HEADER_ETHERNET_II_802_3_SIZE 14
 #define HEADER_802_2_SIZE              3
