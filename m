From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2/6] S2IO: Optimized the delay to wait for command completion
Date: Sat, 24 Feb 2007 01:57:32 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10702240152130.3434-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, sreenivasa.honnur@neterion.com,
	ramkrishna.vepa@neterion.com, santosh.rastapur@neterion.com,
	alicia.pena@neterion.com, sriram.rapuru@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:45745 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933396AbXBXG5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 01:57:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Optimized delay to wait for command completion so as to reduce the
  initialization wait time.
- Disable differentiated services steering. By default RMAC is configured to
  steer traffic with certain DS codes to other queues. Driver must initialize
  the DS memory to 0 to make sure that DS steering will not be used by default.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch1/drivers/net/s2io.c patch2/drivers/net/s2io.c
--- patch1/drivers/net/s2io.c	2007-02-21 12:28:59.000000000 +0530
+++ patch2/drivers/net/s2io.c	2007-02-21 15:21:14.000000000 +0530
@@ -1372,6 +1372,16 @@ static int init_nic(struct s2io_nic *nic
 		}
 	}
 
+	/* Disable differentiated services steering logic */
+	for (i = 0; i < 64; i++) {
+		if (rts_ds_steer(nic, i, 0) == FAILURE) {
+			DBG_PRINT(ERR_DBG, "%s: failed rts ds steering",
+				dev->name);
+			DBG_PRINT(ERR_DBG, "set on codepoint %d\n", i);
+			return FAILURE;
+		}
+	}
+
 	/* Program statistics memory */
 	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);
 
@@ -3195,26 +3205,37 @@ static void alarm_intr_handler(struct s2
  *   SUCCESS on success and FAILURE on failure.
  */
 
-static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit)
+static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
+				int bit_state)
 {
-	int ret = FAILURE, cnt = 0;
+	int ret = FAILURE, cnt = 0, delay = 1;
 	u64 val64;
 
-	while (TRUE) {
+	if ((bit_state != S2IO_BIT_RESET) && (bit_state != S2IO_BIT_SET))
+		return FAILURE;
+
+	do {
 		val64 = readq(addr);
-		if (!(val64 & busy_bit)) {
-			ret = SUCCESS;
-			break;
+		if (bit_state == S2IO_BIT_RESET) {
+			if (!(val64 & busy_bit)) {
+				ret = SUCCESS;
+				break;
+			}
+		} else {
+			if (!(val64 & busy_bit)) {
+				ret = SUCCESS;
+				break;
+			}
 		}
 
 		if(in_interrupt())
-			mdelay(50);
+			mdelay(delay);
 		else
-			msleep(50);
+			msleep(delay);
 
-		if (cnt++ > 10)
-			break;
-	}
+		if (++cnt >= 10)
+			delay = 50;
+	} while (cnt < 20);
 	return ret;
 }
 /*
@@ -4296,7 +4317,8 @@ static void s2io_set_multicast(struct ne
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
 		wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING);
+					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+					S2IO_BIT_RESET);
 
 		sp->m_cast_flg = 1;
 		sp->all_multi_pos = MAC_MC_ALL_MC_ADDR_OFFSET;
@@ -4312,7 +4334,8 @@ static void s2io_set_multicast(struct ne
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
 		wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING);
+					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+					S2IO_BIT_RESET);
 
 		sp->m_cast_flg = 0;
 		sp->all_multi_pos = 0;
@@ -4378,7 +4401,8 @@ static void s2io_set_multicast(struct ne
 
 			/* Wait for command completes */
 			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
+					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+					S2IO_BIT_RESET)) {
 				DBG_PRINT(ERR_DBG, "%s: Adding ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
@@ -4409,7 +4433,8 @@ static void s2io_set_multicast(struct ne
 
 			/* Wait for command completes */
 			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
+					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+					S2IO_BIT_RESET)) {
 				DBG_PRINT(ERR_DBG, "%s: Adding ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
@@ -4455,7 +4480,7 @@ static int s2io_set_mac_addr(struct net_
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 	/* Wait till command completes */
 	if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
+		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING, S2IO_BIT_RESET)) {
 		DBG_PRINT(ERR_DBG, "%s: set_mac_addr failed\n", dev->name);
 		return FAILURE;
 	}
@@ -6736,6 +6761,37 @@ static int s2io_verify_parm(struct pci_d
 }
 
 /**
+ * rts_ds_steer - Receive traffic steering based on IPv4 or IPv6 TOS
+ * or Traffic class respectively.
+ * @nic: device peivate variable
+ * Description: The function configures the receive steering to
+ * desired receive ring.
+ * Return Value:  SUCCESS on success and
+ * '-1' on failure (endian settings incorrect).
+ */
+static int rts_ds_steer(struct s2io_nic *nic, u8 ds_codepoint, u8 ring)
+{
+	struct XENA_dev_config __iomem *bar0 = nic->bar0;
+	register u64 val64 = 0;
+
+	if (ds_codepoint > 63)
+		return FAILURE;
+
+	val64 = RTS_DS_MEM_DATA(ring);
+	writeq(val64, &bar0->rts_ds_mem_data);
+
+	val64 = RTS_DS_MEM_CTRL_WE |
+		RTS_DS_MEM_CTRL_STROBE_NEW_CMD |
+		RTS_DS_MEM_CTRL_OFFSET(ds_codepoint);
+
+	writeq(val64, &bar0->rts_ds_mem_ctrl);
+
+	return wait_for_cmd_complete(&bar0->rts_ds_mem_ctrl,
+				RTS_DS_MEM_CTRL_STROBE_CMD_BEING_EXECUTED,
+				S2IO_BIT_RESET);
+}
+
+/**
  *  s2io_init_nic - Initialization of the adapter .
  *  @pdev : structure containing the PCI related information of the device.
  *  @pre: List of PCI devices supported by the driver listed in s2io_tbl.
@@ -7029,7 +7085,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 	wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING);
+		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING, S2IO_BIT_RESET);
 	tmp64 = readq(&bar0->rmac_addr_data0_mem);
 	mac_down = (u32) tmp64;
 	mac_up = (u32) (tmp64 >> 32);
diff -urpN patch1/drivers/net/s2io.h patch2/drivers/net/s2io.h
--- patch1/drivers/net/s2io.h	2007-02-20 14:47:12.000000000 +0530
+++ patch2/drivers/net/s2io.h	2007-02-20 14:47:46.000000000 +0530
@@ -32,7 +32,8 @@
 #define FAILURE -1
 #define S2IO_MINUS_ONE 0xFFFFFFFFFFFFFFFFULL
 #define S2IO_MAX_PCI_CONFIG_SPACE_REINIT 100
-
+#define S2IO_BIT_RESET 1
+#define S2IO_BIT_SET 2
 #define CHECKBIT(value, nbit) (value & (1 << nbit))
 
 /* Maximum time to flicker LED when asked to identify NIC using ethtool */
@@ -1005,7 +1006,8 @@ static int s2io_set_swapper(struct s2io_
 static void s2io_card_down(struct s2io_nic *nic);
 static int s2io_card_up(struct s2io_nic *nic);
 static int get_xena_rev_id(struct pci_dev *pdev);
-static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit);
+static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
+					int bit_state);
 static int s2io_add_isr(struct s2io_nic * sp);
 static void s2io_rem_isr(struct s2io_nic * sp);
 
@@ -1019,6 +1021,7 @@ static void queue_rx_frame(struct sk_buf
 static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro);
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 			   struct sk_buff *skb, u32 tcp_len);
+static int rts_ds_steer(struct s2io_nic *nic, u8 ds_codepoint, u8 ring);
 
 #define s2io_tcp_mss(skb) skb_shinfo(skb)->gso_size
 #define s2io_udp_mss(skb) skb_shinfo(skb)->gso_size

