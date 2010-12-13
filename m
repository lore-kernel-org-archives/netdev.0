From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v9 01/20] pch_can: Add flow control processing
Date: Mon, 13 Dec 2010 15:24:07 +0900
Message-ID: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org,
	21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TZUIDd8j+nm9g@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

Currently, there is no flow control processing.
Thus, Add flow control processing as
when there is no empty of tx buffer,
netif_stop_queue is called.
When there is empty buffer, netif_wake_queue is called.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |   31 ++++++++++++-------------------
 1 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index a9b6a65..f0f1404 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -102,6 +102,10 @@
 
 #define PCH_FIFO_THRESH		16
 
+/* TxRqst2 show status of MsgObjNo.17~32 */
+#define PCH_TREQ2_TX_MASK	(((1 << PCH_TX_OBJ_NUM) - 1) <<\
+							(PCH_RX_OBJ_END - 16))
+
 enum pch_ifreg {
 	PCH_RX_IFREG,
 	PCH_TX_IFREG,
@@ -871,6 +875,8 @@ MSG_OBJ:
 			dlc = 8;
 		stats->tx_bytes += dlc;
 		stats->tx_packets++;
+		if (int_stat == PCH_TX_OBJ_END)
+			netif_wake_queue(ndev);
 	}
 
 	int_stat = pch_can_int_pending(priv);
@@ -1009,18 +1015,6 @@ static int pch_close(struct net_device *ndev)
 	return 0;
 }
 
-static int pch_get_msg_obj_sts(struct net_device *ndev, u32 obj_id)
-{
-	u32 buffer_status = 0;
-	struct pch_can_priv *priv = netdev_priv(ndev);
-
-	/* Getting the message object status. */
-	buffer_status = (u32) pch_can_get_buffer_status(priv);
-
-	return buffer_status & obj_id;
-}
-
-
 static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	int i, j;
@@ -1031,17 +1025,16 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;
 
-	if (priv->tx_obj == PCH_TX_OBJ_END) { /* Point tail Obj */
-		while (pch_get_msg_obj_sts(ndev, (((1 << PCH_TX_OBJ_NUM)-1) <<
-					   PCH_RX_OBJ_NUM)))
-			udelay(500);
+	if (priv->tx_obj == PCH_TX_OBJ_END) {
+		if (ioread32(&priv->regs->treq2) & PCH_TREQ2_TX_MASK)
+			netif_stop_queue(ndev);
 
-		priv->tx_obj = PCH_TX_OBJ_START; /* Point head of Tx Obj ID */
-		tx_buffer_avail = priv->tx_obj; /* Point Tail of Tx Obj */
+		tx_buffer_avail = priv->tx_obj;
+		priv->tx_obj = PCH_TX_OBJ_START;
 	} else {
 		tx_buffer_avail = priv->tx_obj;
+		priv->tx_obj++;
 	}
-	priv->tx_obj++;
 
 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
-- 
1.6.0.6
