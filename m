From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v9 08/20] pch_can: Reduce register access
Date: Mon, 13 Dec 2010 15:24:14 +0900
Message-ID: <1292221467-8039-8-git-send-email-tomoya-linux@dsn.okisemi.com>
References: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-2-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-3-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-4-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-5-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-6-git-send-email-tomoya-linux@dsn.okisemi.com>
	<1292221467-8039-7-git-send-email-tomoya-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org,
	21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TZUIDd8j+nm9g@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1292221467-8039-7-git-send-email-tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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

For improve tx/rx speed, reduce register access.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |   55 +++++++++++++++++---------------------------
 1 files changed, 21 insertions(+), 34 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index c6c0842..0acc877 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -372,9 +372,6 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 		pch_can_bit_set(&priv->regs->ifregs[0].mcont,
 				PCH_IF_MCONT_UMASK);
 
-		/* Set FIFO mode set to 0 except last Rx Obj*/
-		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
-				  PCH_IF_MCONT_EOB);
 		/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
 		if (i == PCH_RX_OBJ_END)
 			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
@@ -402,14 +399,11 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 
 		/* Resetting DIR bit for reception */
 		iowrite32(0x0, &priv->regs->ifregs[1].id1);
-		iowrite32(0x0, &priv->regs->ifregs[1].id2);
-		pch_can_bit_set(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
+		iowrite32(PCH_ID2_DIR, &priv->regs->ifregs[1].id2);
 
 		/* Setting EOB bit for transmitter */
-		iowrite32(PCH_IF_MCONT_EOB, &priv->regs->ifregs[1].mcont);
-
-		pch_can_bit_set(&priv->regs->ifregs[1].mcont,
-				PCH_IF_MCONT_UMASK);
+		iowrite32(PCH_IF_MCONT_EOB | PCH_IF_MCONT_UMASK,
+			  &priv->regs->ifregs[1].mcont);
 
 		iowrite32(0, &priv->regs->ifregs[1].mask1);
 		pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
@@ -524,12 +518,12 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		dev_err(&ndev->dev, "%s -> Bus Off occurres.\n", __func__);
 	}
 
+	errc = ioread32(&priv->regs->errc);
 	/* Warning interrupt. */
 	if (status & PCH_EWARN) {
 		state = CAN_STATE_ERROR_WARNING;
 		priv->can.can_stats.error_warning++;
 		cf->can_id |= CAN_ERR_CRTL;
-		errc = ioread32(&priv->regs->errc);
 		if (((errc & PCH_REC) >> 8) > 96)
 			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
 		if ((errc & PCH_TEC) > 96)
@@ -542,7 +536,6 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		priv->can.can_stats.error_passive++;
 		state = CAN_STATE_ERROR_PASSIVE;
 		cf->can_id |= CAN_ERR_CRTL;
-		errc = ioread32(&priv->regs->errc);
 		if (((errc & PCH_REC) >> 8) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
 		if ((errc & PCH_TEC) > 127)
@@ -927,6 +920,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	int tx_obj_no;
 	int i;
+	u32 id2;
 
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;
@@ -950,22 +944,23 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);
 
 	/* If ID extended is set. */
-	pch_can_bit_clear(&priv->regs->ifregs[1].id1, 0xffff);
-	pch_can_bit_clear(&priv->regs->ifregs[1].id2, 0x1fff | PCH_ID2_XTD);
 	if (cf->can_id & CAN_EFF_FLAG) {
-		pch_can_bit_set(&priv->regs->ifregs[1].id1,
-				cf->can_id & 0xffff);
-		pch_can_bit_set(&priv->regs->ifregs[1].id2,
-				((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD);
+		iowrite32(cf->can_id & 0xffff, &priv->regs->ifregs[1].id1);
+		id2 = ((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD;
 	} else {
-		pch_can_bit_set(&priv->regs->ifregs[1].id1, 0);
-		pch_can_bit_set(&priv->regs->ifregs[1].id2,
-				(cf->can_id & CAN_SFF_MASK) << 2);
+		iowrite32(0, &priv->regs->ifregs[1].id1);
+		id2 = (cf->can_id & CAN_SFF_MASK) << 2;
 	}
 
+	id2 |= PCH_ID_MSGVAL;
+
 	/* If remote frame has to be transmitted.. */
 	if (cf->can_id & CAN_RTR_FLAG)
-		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
+		id2 &= ~PCH_ID2_DIR;
+	else
+		id2 |= PCH_ID2_DIR;
+
+	iowrite32(id2, &priv->regs->ifregs[1].id2);
 
 	/* Copy data to register */
 	for (i = 0; i < cf->can_dlc; i += 2) {
@@ -976,17 +971,8 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);
 
 	/* Updating the size of the data. */
-	pch_can_bit_clear(&priv->regs->ifregs[1].mcont, 0x0f);
-	pch_can_bit_set(&priv->regs->ifregs[1].mcont, cf->can_dlc);
-
-	/* Clearing IntPend, NewDat & TxRqst */
-	pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
-			  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
-			  PCH_IF_MCONT_TXRQXT);
-
-	/* Setting NewDat, TxRqst bits */
-	pch_can_bit_set(&priv->regs->ifregs[1].mcont,
-			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);
+	iowrite32(cf->can_dlc | PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT |
+		  PCH_IF_MCONT_TXIE, &priv->regs->ifregs[1].mcont);
 
 	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
 
@@ -1211,9 +1197,10 @@ static int pch_can_get_berr_counter(const struct net_device *dev,
 				    struct can_berr_counter *bec)
 {
 	struct pch_can_priv *priv = netdev_priv(dev);
+	u32 errc = ioread32(&priv->regs->errc);
 
-	bec->txerr = ioread32(&priv->regs->errc) & PCH_TEC;
-	bec->rxerr = (ioread32(&priv->regs->errc) & PCH_REC) >> 8;
+	bec->txerr = errc & PCH_TEC;
+	bec->rxerr = (errc & PCH_REC) >> 8;
 
 	return 0;
 }
-- 
1.6.0.6
