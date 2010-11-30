From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v6 06/20] can: EG20T PCH: Fix endianness issue
Date: Tue, 30 Nov 2010 13:20:58 +0900
Message-ID: <4CF47BAA.2090209__27444.5214229219$1291090918$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:41589 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753397Ab0K3EVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:21:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

there is endianness issue both Tx and Rx.
Currently, data is set like below.
Register:
MSB--LSB
x x D0 D1
x x D2 D3
x x D4 D5
x x D6 D7

But Data to be sent must be set like below.
Register:
MSB--LSB
x x D1 D0
x x D3 D2
x x D5 D4
x x D7 D6  (x means reserved area.)

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |  118 +++++++++++++++++++++------------------------
 1 files changed, 55 insertions(+), 63 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 6437e60..98e7e9f 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -134,10 +134,7 @@ struct pch_can_if_regs {
 	u32 id1;
 	u32 id2;
 	u32 mcont;
-	u32 dataa1;
-	u32 dataa2;
-	u32 datab1;
-	u32 datab2;
+	u32 data[4];
 	u32 rsv[13];
 };
 
@@ -420,10 +417,10 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(0x0, &priv->regs->ifregs[0].id1);
 		iowrite32(0x0, &priv->regs->ifregs[0].id2);
 		iowrite32(0x0, &priv->regs->ifregs[0].mcont);
-		iowrite32(0x0, &priv->regs->ifregs[0].dataa1);
-		iowrite32(0x0, &priv->regs->ifregs[0].dataa2);
-		iowrite32(0x0, &priv->regs->ifregs[0].datab1);
-		iowrite32(0x0, &priv->regs->ifregs[0].datab2);
+		iowrite32(0x0, &priv->regs->ifregs[0].data[0]);
+		iowrite32(0x0, &priv->regs->ifregs[0].data[1]);
+		iowrite32(0x0, &priv->regs->ifregs[0].data[2]);
+		iowrite32(0x0, &priv->regs->ifregs[0].data[3]);
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[0].cmask);
@@ -437,10 +434,10 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(0x0, &priv->regs->ifregs[1].id1);
 		iowrite32(0x0, &priv->regs->ifregs[1].id2);
 		iowrite32(0x0, &priv->regs->ifregs[1].mcont);
-		iowrite32(0x0, &priv->regs->ifregs[1].dataa1);
-		iowrite32(0x0, &priv->regs->ifregs[1].dataa2);
-		iowrite32(0x0, &priv->regs->ifregs[1].datab1);
-		iowrite32(0x0, &priv->regs->ifregs[1].datab2);
+		iowrite32(0x0, &priv->regs->ifregs[1].data[0]);
+		iowrite32(0x0, &priv->regs->ifregs[1].data[1]);
+		iowrite32(0x0, &priv->regs->ifregs[1].data[2]);
+		iowrite32(0x0, &priv->regs->ifregs[1].data[3]);
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[1].cmask);
@@ -703,12 +700,13 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 	canid_t id;
 	u32 ide;
 	u32 rtr;
-	int i, j, k;
+	int i, k;
 	int rcv_pkts = 0;
 	struct sk_buff *skb;
 	struct can_frame *cf;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &(priv->ndev->stats);
+	u16 data_reg;
 
 	/* Reading the messsage object from the Message RAM */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
@@ -774,12 +772,10 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 			      ((ioread32(&priv->regs->ifregs[0].mcont)) & 0x0f);
 		}
 
-		for (i = 0, j = 0; i < cf->can_dlc; j++) {
-			reg = ioread32(&priv->regs->ifregs[0].dataa1 + j*4);
-			cf->data[i++] = cpu_to_le32(reg & 0xff);
-			if (i == cf->can_dlc)
-				break;
-			cf->data[i++] = cpu_to_le32((reg >> 8) & 0xff);
+		for (i = 0; i < cf->can_dlc; i += 2) {
+			data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
+			cf->data[i] = data_reg & 0xff;
+			cf->data[i + 1] = data_reg >> 8;
 		}
 
 		netif_receive_skb(skb);
@@ -815,72 +811,71 @@ RX_NEXT:
 
 	return rcv_pkts;
 }
-static int pch_can_rx_poll(struct napi_struct *napi, int quota)
+
+static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)
 {
-	struct net_device *ndev = napi->dev;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &(priv->ndev->stats);
 	u32 dlc;
+
+	can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
+	iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
+		  &priv->regs->ifregs[1].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
+	dlc = get_can_dlc(ioread32(&priv->regs->ifregs[1].mcont) &
+			  PCH_IF_MCONT_DLC);
+	stats->tx_bytes += dlc;
+	stats->tx_packets++;
+	if (int_stat == PCH_TX_OBJ_END)
+		netif_wake_queue(ndev);
+}
+
+static int pch_can_rx_poll(struct napi_struct *napi, int quota)
+{
+	struct net_device *ndev = napi->dev;
+	struct pch_can_priv *priv = netdev_priv(ndev);
 	u32 int_stat;
 	int rcv_pkts = 0;
 	u32 reg_stat;
 
 	int_stat = pch_can_int_pending(priv);
 	if (!int_stat)
-		return 0;
+		goto end;
 
-INT_STAT:
-	if (int_stat == PCH_STATUS_INT) {
+	if ((int_stat == PCH_STATUS_INT) && (quota > 0)) {
 		reg_stat = ioread32(&priv->regs->stat);
 		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
-			if ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL)
+			if (reg_stat & PCH_BUS_OFF ||
+			   (reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL) {
 				pch_can_error(ndev, reg_stat);
+				quota--;
+			}
 		}
 
-		if (reg_stat & PCH_TX_OK) {
-			iowrite32(PCH_CMASK_RX_TX_GET,
-				  &priv->regs->ifregs[1].cmask);
-			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
-					       ioread32(&priv->regs->intr));
+		if (reg_stat & PCH_TX_OK)
 			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
-		}
 
 		if (reg_stat & PCH_RX_OK)
 			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
 
 		int_stat = pch_can_int_pending(priv);
-		if (int_stat == PCH_STATUS_INT)
-			goto INT_STAT;
 	}
 
-MSG_OBJ:
+	if (quota == 0)
+		goto end;
+
 	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
-		rcv_pkts = pch_can_rx_normal(ndev, int_stat);
-		if (rcv_pkts < 0)
-			return 0;
+		rcv_pkts += pch_can_rx_normal(ndev, int_stat);
+		quota -= rcv_pkts;
+		if (quota < 0)
+			goto end;
 	} else if ((int_stat >= PCH_TX_OBJ_START) &&
 		   (int_stat <= PCH_TX_OBJ_END)) {
 		/* Handle transmission interrupt */
-		can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
-		iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
-			  &priv->regs->ifregs[1].cmask);
-		dlc = ioread32(&priv->regs->ifregs[1].mcont) &
-			       PCH_IF_MCONT_DLC;
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
-		if (dlc > 8)
-			dlc = 8;
-		stats->tx_bytes += dlc;
-		stats->tx_packets++;
-		if (int_stat == PCH_TX_OBJ_END)
-			netif_wake_queue(ndev);
+		pch_can_tx_complete(ndev, int_stat);
 	}
 
-	int_stat = pch_can_int_pending(priv);
-	if (int_stat == PCH_STATUS_INT)
-		goto INT_STAT;
-	else if (int_stat >= 1 && int_stat <= 32)
-		goto MSG_OBJ;
-
+end:
 	napi_complete(napi);
 	pch_can_set_int_enables(priv, PCH_CAN_ALL);
 
@@ -1013,10 +1008,10 @@ static int pch_close(struct net_device *ndev)
 
 static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	int i, j;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	int tx_buffer_avail = 0;
+	int i;
 
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;
@@ -1057,13 +1052,10 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (cf->can_id & CAN_RTR_FLAG)
 		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
 
-	for (i = 0, j = 0; i < cf->can_dlc; j++) {
-		iowrite32(le32_to_cpu(cf->data[i++]),
-			 (&priv->regs->ifregs[1].dataa1) + j*4);
-		if (i == cf->can_dlc)
-			break;
-		iowrite32(le32_to_cpu(cf->data[i++] << 8),
-			 (&priv->regs->ifregs[1].dataa1) + j*4);
+	/* Copy data to register */
+	for (i = 0; i < cf->can_dlc; i += 2) {
+		iowrite16(cf->data[i] | (cf->data[i + 1] << 8),
+			  &priv->regs->ifregs[1].data[i / 2]);
 	}
 
 	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_END - 1);
-- 
1.6.0.6
