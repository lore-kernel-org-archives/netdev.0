From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 11/19 v5] can: EG20T PCH: Delete unnecessary/redundant
 code
Date: Fri, 26 Nov 2010 11:18:45 +0900
Message-ID: <4CEF1905.6050803__33825.3214526505$1290737981$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:46617 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753029Ab0KZCTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 21:19:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete unnecessary/redundant code

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   89 +++++++++++++++++++--------------------------
 1 files changed, 37 insertions(+), 52 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index b803fed..33c6bc0 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -447,11 +447,6 @@ static void pch_can_release(struct pch_can_priv *priv)
 /* This function clears interrupt(s) from the CAN device. */
 static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 {
-	if (mask == PCH_STATUS_INT) {
-		ioread32(&priv->regs->stat);
-		return;
-	}
-
 	/* Clear interrupt for transmit object */
 	if ((mask >= PCH_RX_OBJ_START) && (mask <= PCH_RX_OBJ_END)) {
 		/* Setting CMASK for clearing the reception interrupts. */
@@ -518,8 +513,6 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		state = CAN_STATE_BUS_OFF;
 		cf->can_id |= CAN_ERR_BUSOFF;
 		can_bus_off(ndev);
-		pch_can_set_run_mode(priv, PCH_CAN_RUN);
-		dev_err(&ndev->dev, "%s -> Bus Off occurres.\n", __func__);
 	}
 
 	errc = ioread32(&priv->regs->errc);
@@ -655,7 +648,6 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 	canid_t id;
 	int rcv_pkts = 0;
 	int rtn;
-	int next_flag = 0;
 	struct sk_buff *skb;
 	struct can_frame *cf;
 	struct pch_can_priv *priv = netdev_priv(ndev);
@@ -682,50 +674,48 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 				netdev_err(ndev, "Can't get memory\n");
 			rcv_pkts++;
 			quota--;
-			next_flag = 1;
-		} else if (!(reg & PCH_IF_MCONT_NEWDAT))
-			next_flag = 1;
-
-		if (!next_flag) {
-			skb = alloc_can_skb(priv->ndev, &cf);
-			if (!skb)
-				return -ENOMEM;
-
-			/* Get Received data */
-			id2 = ioread32(&priv->regs->ifregs[0].id2);
-			if (id2 & PCH_ID2_XTD) {
-				id = (ioread32(&priv->regs->ifregs[0].id1) &
-					       0xffff);
-				id |= (((id2) & 0x1fff) << 16);
-				cf->can_id = id | CAN_EFF_FLAG;
-			} else {
-				id = ((id2 & (CAN_SFF_MASK << 2)) >> 2);
-				cf->can_id = id;
-			}
+			obj_num++;
+			continue;
+		} else if (!(reg & PCH_IF_MCONT_NEWDAT)) {
+			obj_num++;
+			continue;
+		}
 
-			if (id2 & PCH_ID2_DIR)
-				cf->can_id |= CAN_RTR_FLAG;
+		skb = alloc_can_skb(priv->ndev, &cf);
+		if (!skb)
+			return -ENOMEM;
+
+		/* Get Received data */
+		id2 = ioread32(&priv->regs->ifregs[0].id2);
+		if (id2 & PCH_ID2_XTD) {
+			id = (ioread32(&priv->regs->ifregs[0].id1) & 0xffff);
+			id |= (((id2) & 0x1fff) << 16);
+			cf->can_id = id | CAN_EFF_FLAG;
+		} else {
+			id = ((id2 & (CAN_SFF_MASK << 2)) >> 2);
+			cf->can_id = id;
+		}
 
-			cf->can_dlc = get_can_dlc((ioread32(&priv->regs->
-						   ifregs[0].mcont)) & 0xF);
+		if (id2 & PCH_ID2_DIR)
+			cf->can_id |= CAN_RTR_FLAG;
 
-			for (i = 0; i < cf->can_dlc; i += 2) {
-				data_reg = ioread16(&priv->regs->ifregs[0].
-						    data[i / 2]);
-				cf->data[i] = data_reg & 0xff;
-				cf->data[i + 1] = data_reg >> 8;
-			}
+		cf->can_dlc = get_can_dlc((ioread32(&priv->regs->
+						    ifregs[0].mcont)) & 0xF);
 
-			netif_receive_skb(skb);
-			rcv_pkts++;
-			stats->rx_packets++;
-			quota--;
-			stats->rx_bytes += cf->can_dlc;
-
-			pch_fifo_thresh(priv, obj_num);
+		for (i = 0; i < cf->can_dlc; i += 2) {
+			data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
+			cf->data[i] = data_reg & 0xff;
+			cf->data[i + 1] = data_reg >> 8;
 		}
+
+		netif_receive_skb(skb);
+		rcv_pkts++;
+		stats->rx_packets++;
+		quota--;
+		stats->rx_bytes += cf->can_dlc;
+
+		pch_fifo_thresh(priv, obj_num);
 		obj_num++;
-		next_flag = 0;
 	} while (quota > 0);
 
 	return rcv_pkts;
@@ -761,7 +751,7 @@ static int pch_can_poll(struct napi_struct *napi, int quota)
 	if (!int_stat)
 		goto end;
 
-	if ((int_stat == PCH_STATUS_INT) && (quota > 0)) {
+	if (int_stat == PCH_STATUS_INT) {
 		reg_stat = ioread32(&priv->regs->stat);
 		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
 			if (reg_stat & PCH_BUS_OFF ||
@@ -947,10 +937,6 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 		priv->tx_obj++;
 	}
 
-	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
-	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
-
 	/* Setting the CMASK register. */
 	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);
 
@@ -1080,7 +1066,6 @@ static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 buffer_num)
 	return link;
 }
 
-
 static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	int i;			/* Counter variable. */
-- 
1.6.0.6
