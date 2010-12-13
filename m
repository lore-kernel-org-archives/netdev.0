From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v9 04/20] pch_can: Improve rx processing
Date: Mon, 13 Dec 2010 15:24:10 +0900
Message-ID: <1292221467-8039-4-git-send-email-tomoya-linux@dsn.okisemi.com>
References: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-2-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-3-git-send-email-tomoya-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org,
	21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TZUIDd8j+nm9g@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1292221467-8039-3-git-send-email-tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace complex "goto" to "do~while".
For easy to read/understand, it divides a rx function into some functions.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |  158 +++++++++++++++++++++++----------------------
 1 files changed, 82 insertions(+), 76 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 210957f..d646fbc 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -698,83 +698,110 @@ static irqreturn_t pch_can_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
+static void pch_fifo_thresh(struct pch_can_priv *priv, int obj_id)
+{
+	if (obj_id < PCH_FIFO_THRESH) {
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
+			  PCH_CMASK_ARB, &priv->regs->ifregs[0].cmask);
+
+		/* Clearing the Dir bit. */
+		pch_can_bit_clear(&priv->regs->ifregs[0].id2, PCH_ID2_DIR);
+
+		/* Clearing NewDat & IntPnd */
+		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
+				  PCH_IF_MCONT_INTPND);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
+	} else if (obj_id > PCH_FIFO_THRESH) {
+		pch_can_int_clr(priv, obj_id);
+	} else if (obj_id == PCH_FIFO_THRESH) {
+		int cnt;
+		for (cnt = 0; cnt < PCH_FIFO_THRESH; cnt++)
+			pch_can_int_clr(priv, cnt + 1);
+	}
+}
+
+static void pch_can_rx_msg_lost(struct net_device *ndev, int obj_id)
+{
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &(priv->ndev->stats);
+	struct sk_buff *skb;
+	struct can_frame *cf;
+
+	netdev_dbg(priv->ndev, "Msg Obj is overwritten.\n");
+	pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
+			  PCH_IF_MCONT_MSGLOST);
+	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
+		  &priv->regs->ifregs[0].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
+
+	skb = alloc_can_err_skb(ndev, &cf);
+	if (!skb)
+		return;
+
+	cf->can_id |= CAN_ERR_CRTL;
+	cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
+	stats->rx_over_errors++;
+	stats->rx_errors++;
+
+	netif_receive_skb(skb);
+}
+
+static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 {
 	u32 reg;
 	canid_t id;
-	u32 ide;
-	u32 rtr;
-	int i, k;
 	int rcv_pkts = 0;
 	struct sk_buff *skb;
 	struct can_frame *cf;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &(priv->ndev->stats);
+	int i;
+	u32 id2;
 	u16 data_reg;
 
-	/* Reading the messsage object from the Message RAM */
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, int_stat);
+	do {
+		/* Reading the messsage object from the Message RAM */
+		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_num);
 
-	/* Reading the MCONT register. */
-	reg = ioread32(&priv->regs->ifregs[0].mcont);
-	reg &= 0xffff;
+		/* Reading the MCONT register. */
+		reg = ioread32(&priv->regs->ifregs[0].mcont);
+
+		if (reg & PCH_IF_MCONT_EOB)
+			break;
 
-	for (k = int_stat; !(reg & PCH_IF_MCONT_EOB); k++) {
 		/* If MsgLost bit set. */
 		if (reg & PCH_IF_MCONT_MSGLOST) {
-			dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
-			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
-					  PCH_IF_MCONT_MSGLOST);
-			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
-				  &priv->regs->ifregs[0].cmask);
-			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
-
-			skb = alloc_can_err_skb(ndev, &cf);
-			if (!skb)
-				return -ENOMEM;
-
-			priv->can.can_stats.error_passive++;
-			priv->can.state = CAN_STATE_ERROR_PASSIVE;
-			cf->can_id |= CAN_ERR_CRTL;
-			cf->data[1] |= CAN_ERR_CRTL_RX_OVERFLOW;
-			cf->data[2] |= CAN_ERR_PROT_OVERLOAD;
-			stats->rx_packets++;
-			stats->rx_bytes += cf->can_dlc;
-
-			netif_receive_skb(skb);
+			pch_can_rx_msg_lost(ndev, obj_num);
 			rcv_pkts++;
-			goto RX_NEXT;
+			quota--;
+			obj_num++;
+			continue;
+		} else if (!(reg & PCH_IF_MCONT_NEWDAT)) {
+			obj_num++;
+			continue;
 		}
-		if (!(reg & PCH_IF_MCONT_NEWDAT))
-			goto RX_NEXT;
 
 		skb = alloc_can_skb(priv->ndev, &cf);
 		if (!skb)
 			return -ENOMEM;
 
 		/* Get Received data */
-		ide = ((ioread32(&priv->regs->ifregs[0].id2)) & PCH_ID2_XTD) >>
-									     14;
-		if (ide) {
+		id2 = ioread32(&priv->regs->ifregs[0].id2);
+		if (id2 & PCH_ID2_XTD) {
 			id = (ioread32(&priv->regs->ifregs[0].id1) & 0xffff);
-			id |= (((ioread32(&priv->regs->ifregs[0].id2)) &
-					    0x1fff) << 16);
-			cf->can_id = (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
+			id |= (((id2) & 0x1fff) << 16);
+			cf->can_id = id | CAN_EFF_FLAG;
 		} else {
-			id = (((ioread32(&priv->regs->ifregs[0].id2)) &
-						     (CAN_SFF_MASK << 2)) >> 2);
-			cf->can_id = (id & CAN_SFF_MASK);
+			id = (id2 >> 2) & CAN_SFF_MASK;
+			cf->can_id = id;
 		}
 
-		rtr = (ioread32(&priv->regs->ifregs[0].id2) &  PCH_ID2_DIR);
-		if (rtr) {
-			cf->can_dlc = 0;
+		if (id2 & PCH_ID2_DIR)
 			cf->can_id |= CAN_RTR_FLAG;
-		} else {
-			cf->can_dlc =
-			      ((ioread32(&priv->regs->ifregs[0].mcont)) & 0x0f);
-		}
+
+		cf->can_dlc = get_can_dlc((ioread32(&priv->regs->
+						    ifregs[0].mcont)) & 0xF);
 
 		for (i = 0; i < cf->can_dlc; i += 2) {
 			data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
@@ -785,33 +812,12 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 		netif_receive_skb(skb);
 		rcv_pkts++;
 		stats->rx_packets++;
+		quota--;
 		stats->rx_bytes += cf->can_dlc;
 
-		if (k < PCH_FIFO_THRESH) {
-			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
-				  PCH_CMASK_ARB, &priv->regs->ifregs[0].cmask);
-
-			/* Clearing the Dir bit. */
-			pch_can_bit_clear(&priv->regs->ifregs[0].id2,
-					  PCH_ID2_DIR);
-
-			/* Clearing NewDat & IntPnd */
-			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
-					  PCH_IF_MCONT_INTPND);
-			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
-		} else if (k > PCH_FIFO_THRESH) {
-			pch_can_int_clr(priv, k);
-		} else if (k == PCH_FIFO_THRESH) {
-			int cnt;
-			for (cnt = 0; cnt < PCH_FIFO_THRESH; cnt++)
-				pch_can_int_clr(priv, cnt+1);
-		}
-RX_NEXT:
-		/* Reading the messsage object from the Message RAM */
-		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
-		reg = ioread32(&priv->regs->ifregs[0].mcont);
-	}
+		pch_fifo_thresh(priv, obj_num);
+		obj_num++;
+	} while (quota > 0);
 
 	return rcv_pkts;
 }
@@ -869,7 +875,7 @@ static int pch_can_rx_poll(struct napi_struct *napi, int quota)
 		goto end;
 
 	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
-		rcv_pkts += pch_can_rx_normal(ndev, int_stat);
+		rcv_pkts += pch_can_rx_normal(ndev, int_stat, quota);
 		quota -= rcv_pkts;
 		if (quota < 0)
 			goto end;
-- 
1.6.0.6
