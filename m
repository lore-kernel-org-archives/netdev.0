From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/7] qla3xxx: bugfix: Jumbo frame handling.
Date: Mon, 26 Mar 2007 13:43:00 -0700
Message-ID: <11749417841489-git-send-email-ron.mercer@qlogic.com>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:9929 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbXCZUnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 16:43:08 -0400
In-Reply-To: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed rx checksum bits. Turn on TCP processing for rx checksum.
Fixed max frame length register write.  It wasn't getting set
in multi-port system. Set rx buffer queue length properly
for jumbo frames.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   29 +++++++++++++++--------------
 drivers/net/qla3xxx.h |    3 +--
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 24c485e..9947a8d 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1933,17 +1933,18 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 		u16 checksum = le16_to_cpu(ib_ip_rsp_ptr->checksum);
 		if (checksum & 
 			(IB_IP_IOCB_RSP_3032_ICE | 
-			 IB_IP_IOCB_RSP_3032_CE | 
-			 IB_IP_IOCB_RSP_3032_NUC)) {
+			 IB_IP_IOCB_RSP_3032_CE)) { 
 			printk(KERN_ERR
 			       "%s: Bad checksum for this %s packet, checksum = %x.\n",
 			       __func__,
 			       ((checksum & 
 				IB_IP_IOCB_RSP_3032_TCP) ? "TCP" :
 				"UDP"),checksum);
-		} else if (checksum & IB_IP_IOCB_RSP_3032_TCP) {
+		} else if ((checksum & IB_IP_IOCB_RSP_3032_TCP) ||
+				(checksum & IB_IP_IOCB_RSP_3032_UDP &&
+				!(checksum & IB_IP_IOCB_RSP_3032_NUC))) {
 			skb2->ip_summed = CHECKSUM_UNNECESSARY;
-		} 
+		}
 	}
 	skb2->dev = qdev->ndev;
 	skb2->protocol = eth_type_trans(skb2, qdev->ndev);
@@ -3039,15 +3040,6 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 			goto out;
 		}
 
-		if (qdev->mac_index)
-			ql_write_page0_reg(qdev,
-					   &port_regs->mac1MaxFrameLengthReg,
-					   qdev->max_frame_size);
-		else
-			ql_write_page0_reg(qdev,
-					   &port_regs->mac0MaxFrameLengthReg,
-					   qdev->max_frame_size);
-
 		value = qdev->nvram_data.tcpMaxWindowSize;
 		ql_write_page0_reg(qdev, &port_regs->tcpMaxWindow, value);
 
@@ -3067,6 +3059,14 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 		ql_sem_unlock(qdev, QL_FLASH_SEM_MASK);
 	}
 
+	if (qdev->mac_index)
+		ql_write_page0_reg(qdev,
+				   &port_regs->mac1MaxFrameLengthReg,
+				   qdev->max_frame_size);
+	else
+		ql_write_page0_reg(qdev,
+					   &port_regs->mac0MaxFrameLengthReg,
+					   qdev->max_frame_size);
 
 	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
@@ -3137,7 +3137,8 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 	if (qdev->device_id == QL3032_DEVICE_ID) {
 		value =
 		    (QL3032_PORT_CONTROL_EF | QL3032_PORT_CONTROL_KIE |
-		     QL3032_PORT_CONTROL_EIv6 | QL3032_PORT_CONTROL_EIv4);
+		     QL3032_PORT_CONTROL_EIv6 | QL3032_PORT_CONTROL_EIv4 |
+			QL3032_PORT_CONTROL_ET);
 		ql_write_page0_reg(qdev, &port_regs->functionControl,
 				   ((value << 16) | value));
 	} else {
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 34cd658..0203f88 100755
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1014,8 +1014,7 @@ struct eeprom_data {
 
 /* Transmit and Receive Buffers */
 #define NUM_LBUFQ_ENTRIES   	128
-#define JUMBO_NUM_LBUFQ_ENTRIES   	\
-(NUM_LBUFQ_ENTRIES/(JUMBO_MTU_SIZE/NORMAL_MTU_SIZE))
+#define JUMBO_NUM_LBUFQ_ENTRIES 32
 #define NUM_SBUFQ_ENTRIES   	64
 #define QL_SMALL_BUFFER_SIZE    32
 #define QL_ADDR_ELE_PER_BUFQ_ENTRY \
-- 
1.5.0.rc4.16.g9e258

