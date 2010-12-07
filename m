From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v8 17/20] CAN : Fix incorrect return processing
Date: Tue, 07 Dec 2010 20:11:13 +0900
Message-ID: <4CFE1651.9040405@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Fix incorrect return processing.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index ace1fe7..8efbe35 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -580,9 +580,11 @@ static irqreturn_t pch_can_interrupt(int irq, void *dev_id)
 	struct net_device *ndev = (struct net_device *)dev_id;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 
+	if (!pch_can_int_pending(priv))
+		return IRQ_NONE;
+
 	pch_can_set_int_enables(priv, PCH_CAN_NONE);
 	napi_schedule(&priv->napi);
-
 	return IRQ_HANDLED;
 }
 
@@ -671,8 +673,10 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 		}
 
 		skb = alloc_can_skb(priv->ndev, &cf);
-		if (!skb)
-			return -ENOMEM;
+		if (!skb) {
+			netdev_err(ndev, "alloc_can_skb Failed\n");
+			return rcv_pkts;
+		}
 
 		/* Get Received data */
 		id2 = ioread32(&priv->regs->ifregs[0].id2);
@@ -733,8 +737,8 @@ static int pch_can_poll(struct napi_struct *napi, int quota)
 	struct net_device *ndev = napi->dev;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	u32 int_stat;
-	int rcv_pkts = 0;
 	u32 reg_stat;
+	int quota_save = quota;
 
 	int_stat = pch_can_int_pending(priv);
 	if (!int_stat)
@@ -763,10 +767,7 @@ static int pch_can_poll(struct napi_struct *napi, int quota)
 		goto end;
 
 	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
-		rcv_pkts += pch_can_rx_normal(ndev, int_stat, quota);
-		quota -= rcv_pkts;
-		if (quota < 0)
-			goto end;
+		quota -= pch_can_rx_normal(ndev, int_stat, quota);
 	} else if ((int_stat >= PCH_TX_OBJ_START) &&
 		   (int_stat <= PCH_TX_OBJ_END)) {
 		/* Handle transmission interrupt */
@@ -777,7 +778,7 @@ end:
 	napi_complete(napi);
 	pch_can_set_int_enables(priv, PCH_CAN_ALL);
 
-	return rcv_pkts;
+	return quota_save - quota;
 }
 
 static int pch_set_bittiming(struct net_device *ndev)
-- 
1.6.0.6
