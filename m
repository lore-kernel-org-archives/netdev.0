From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 5/9] vxge: Removed unused functions.
Date: Mon, 5 Oct 2009 05:10:42 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050509400.2346-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39378 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbZJEJ0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:26:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Removed the wrr_rebalance function

- This feature is not supported by the ASIC, hence removing the related code.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch4/drivers/net/vxge/vxge-config.c patch5/drivers/net/vxge/vxge-config.c
--- patch4/drivers/net/vxge/vxge-config.c	2009-09-04 01:21:52.000000000 -0700
+++ patch5/drivers/net/vxge/vxge-config.c	2009-09-04 01:24:25.000000000 -0700
@@ -461,209 +461,6 @@ __vxge_hw_verify_pci_e_info(struct __vxg
 }
 
 /*
- * vxge_hw_wrr_rebalance - Rebalance the RX_WRR and KDFC_WRR calandars.
- * Rebalance the RX_WRR and KDFC_WRR calandars.
- */
-static enum
-vxge_hw_status vxge_hw_wrr_rebalance(struct __vxge_hw_device *hldev)
-{
-	u64 val64;
-	u32 wrr_states[VXGE_HW_WEIGHTED_RR_SERVICE_STATES];
-	u32 i, j, how_often = 1;
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	status = __vxge_hw_device_is_privilaged(hldev->host_type,
-			hldev->func_id);
-	if (status != VXGE_HW_OK)
-		goto exit;
-
-	/* Reset the priorities assigned to the WRR arbitration
-	phases for the receive traffic */
-	for (i = 0; i < VXGE_HW_WRR_RING_COUNT; i++)
-		writeq(0, ((&hldev->mrpcim_reg->rx_w_round_robin_0) + i));
-
-	/* Reset the transmit FIFO servicing calendar for FIFOs */
-	for (i = 0; i < VXGE_HW_WRR_FIFO_COUNT; i++) {
-		writeq(0, ((&hldev->mrpcim_reg->kdfc_w_round_robin_0) + i));
-		writeq(0, ((&hldev->mrpcim_reg->kdfc_w_round_robin_20) + i));
-	}
-
-	/* Assign WRR priority  0 for all FIFOs */
-	for (i = 1; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-		writeq(VXGE_HW_KDFC_FIFO_0_CTRL_WRR_NUMBER(0),
-				((&hldev->mrpcim_reg->kdfc_fifo_0_ctrl)  + i));
-
-		writeq(VXGE_HW_KDFC_FIFO_17_CTRL_WRR_NUMBER(0),
-			((&hldev->mrpcim_reg->kdfc_fifo_17_ctrl) + i));
-	}
-
-	/* Reset to service non-offload doorbells */
-	writeq(0, &hldev->mrpcim_reg->kdfc_entry_type_sel_0);
-	writeq(0, &hldev->mrpcim_reg->kdfc_entry_type_sel_1);
-
-	/* Set priority 0 to all receive queues */
-	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_0);
-	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_1);
-	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_2);
-
-	/* Initialize all the slots as unused */
-	for (i = 0; i < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; i++)
-		wrr_states[i] = -1;
-
-	/* Prepare the Fifo service states */
-	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-
-		if (!hldev->config.vp_config[i].min_bandwidth)
-			continue;
-
-		how_often = VXGE_HW_VPATH_BANDWIDTH_MAX /
-				hldev->config.vp_config[i].min_bandwidth;
-		if (how_often) {
-
-			for (j = 0; j < VXGE_HW_WRR_FIFO_SERVICE_STATES;) {
-				if (wrr_states[j] == -1) {
-					wrr_states[j] = i;
-					/* Make sure each fifo is serviced
-					 * atleast once */
-					if (i == j)
-						j += VXGE_HW_MAX_VIRTUAL_PATHS;
-					else
-						j += how_often;
-				} else
-					j++;
-			}
-		}
-	}
-
-	/* Fill the unused slots with 0 */
-	for (j = 0; j < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; j++) {
-		if (wrr_states[j] == -1)
-			wrr_states[j] = 0;
-	}
-
-	/* Assign WRR priority number for FIFOs */
-	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-		writeq(VXGE_HW_KDFC_FIFO_0_CTRL_WRR_NUMBER(i),
-				((&hldev->mrpcim_reg->kdfc_fifo_0_ctrl) + i));
-
-		writeq(VXGE_HW_KDFC_FIFO_17_CTRL_WRR_NUMBER(i),
-			((&hldev->mrpcim_reg->kdfc_fifo_17_ctrl) + i));
-	}
-
-	/* Modify the servicing algorithm applied to the 3 types of doorbells.
-	i.e, none-offload, message and offload */
-	writeq(VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_0(0) |
-				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_1(0) |
-				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_2(0) |
-				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_3(0) |
-				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_4(1) |
-				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_5(0) |
-				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_6(0) |
-				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_7(0),
-				&hldev->mrpcim_reg->kdfc_entry_type_sel_0);
-
-	writeq(VXGE_HW_KDFC_ENTRY_TYPE_SEL_1_NUMBER_8(1),
-				&hldev->mrpcim_reg->kdfc_entry_type_sel_1);
-
-	for (i = 0, j = 0; i < VXGE_HW_WRR_FIFO_COUNT; i++) {
-
-		val64 = VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_0(wrr_states[j++]);
-		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_1(wrr_states[j++]);
-		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_2(wrr_states[j++]);
-		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_3(wrr_states[j++]);
-		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_4(wrr_states[j++]);
-		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_5(wrr_states[j++]);
-		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_6(wrr_states[j++]);
-		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_7(wrr_states[j++]);
-
-		writeq(val64, (&hldev->mrpcim_reg->kdfc_w_round_robin_0 + i));
-		writeq(val64, (&hldev->mrpcim_reg->kdfc_w_round_robin_20 + i));
-	}
-
-	/* Set up the priorities assigned to receive queues */
-	writeq(VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_0(0) |
-			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_1(1) |
-			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_2(2) |
-			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_3(3) |
-			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_4(4) |
-			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_5(5) |
-			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_6(6) |
-			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_7(7),
-			&hldev->mrpcim_reg->rx_queue_priority_0);
-
-	writeq(VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_8(8) |
-			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_9(9) |
-			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_10(10) |
-			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_11(11) |
-			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_12(12) |
-			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_13(13) |
-			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_14(14) |
-			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_15(15),
-			&hldev->mrpcim_reg->rx_queue_priority_1);
-
-	writeq(VXGE_HW_RX_QUEUE_PRIORITY_2_RX_Q_NUMBER_16(16),
-				&hldev->mrpcim_reg->rx_queue_priority_2);
-
-	/* Initialize all the slots as unused */
-	for (i = 0; i < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; i++)
-		wrr_states[i] = -1;
-
-	/* Prepare the Ring service states */
-	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-
-		if (!hldev->config.vp_config[i].min_bandwidth)
-			continue;
-
-		how_often = VXGE_HW_VPATH_BANDWIDTH_MAX /
-				hldev->config.vp_config[i].min_bandwidth;
-
-		if (how_often) {
-			for (j = 0; j < VXGE_HW_WRR_RING_SERVICE_STATES;) {
-				if (wrr_states[j] == -1) {
-					wrr_states[j] = i;
-					/* Make sure each ring is
-					 * serviced atleast once */
-					if (i == j)
-						j += VXGE_HW_MAX_VIRTUAL_PATHS;
-					else
-						j += how_often;
-				} else
-					j++;
-			}
-		}
-	}
-
-	/* Fill the unused slots with 0 */
-	for (j = 0; j < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; j++) {
-		if (wrr_states[j] == -1)
-			wrr_states[j] = 0;
-	}
-
-	for (i = 0, j = 0; i < VXGE_HW_WRR_RING_COUNT; i++) {
-		val64 =  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_0(
-				wrr_states[j++]);
-		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_1(
-				wrr_states[j++]);
-		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_2(
-				wrr_states[j++]);
-		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_3(
-				wrr_states[j++]);
-		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_4(
-				wrr_states[j++]);
-		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_5(
-				wrr_states[j++]);
-		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_6(
-				wrr_states[j++]);
-		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_7(
-				wrr_states[j++]);
-
-		writeq(val64, ((&hldev->mrpcim_reg->rx_w_round_robin_0) + i));
-	}
-exit:
-	return status;
-}
-
-/*
  * __vxge_hw_device_initialize
  * Initialize Titan-V hardware.
  */
@@ -679,7 +476,6 @@ enum vxge_hw_status __vxge_hw_device_ini
 			goto exit;
 	}
 
-	vxge_hw_wrr_rebalance(hldev);
 exit:
 	return status;
 }

