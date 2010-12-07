From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v8 07/20] CAN : Change functions type
Date: Tue, 07 Dec 2010 20:06:42 +0900
Message-ID: <4CFE1542.1050809@dsn.okisemi.com>
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

Currently, these two functions spec(returned value) is unnatural.
Thus, change the return value's spec

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index dd9ce16..c6c0842 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1025,10 +1025,10 @@ static void pch_can_set_int_custom(struct pch_can_priv *priv)
 }
 
 /* This function retrieves interrupt enabled for the CAN device. */
-static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *enables)
+static u32 pch_can_get_int_enables(struct pch_can_priv *priv)
 {
 	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
-	*enables = ((ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1);
+	return (ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1;
 }
 
 static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num,
@@ -1069,16 +1069,18 @@ static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
 	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
 }
 
-static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
-				       u32 buffer_num, u32 *link)
+static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 buffer_num)
 {
+	u32 link;
+
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
 	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
 
 	if (ioread32(&priv->regs->ifregs[0].mcont) & PCH_IF_MCONT_EOB)
-		*link = 0;
+		link = 0;
 	else
-		*link = 1;
+		link = 1;
+	return link;
 }
 
 static int pch_can_get_buffer_status(struct pch_can_priv *priv)
@@ -1115,7 +1117,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 		dev_err(&pdev->dev, "%s -> Transmission time out.\n", __func__);
 
 	/* Save interrupt configuration and then disable them */
-	pch_can_get_int_enables(priv, &(priv->int_enables));
+	priv->int_enables = pch_can_get_int_enables(priv);
 	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
 
 	/* Save Tx buffer enable state */
@@ -1128,7 +1130,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 	/* Save Rx buffer enable state */
 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
 		priv->rx_enable[i] = pch_can_get_rxtx_ir(priv, i, PCH_RX_IFREG);
-		pch_can_get_rx_buffer_link(priv, i, &priv->rx_link[i]);
+		priv->rx_link[i] = pch_can_get_rx_buffer_link(priv, i);
 	}
 
 	/* Disable all Receive buffers */
-- 
1.6.0.6
