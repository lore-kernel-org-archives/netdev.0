From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 6/9] can: ti_hecc: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 15:40:31 +0100
Message-ID: <1293288034-22428-7-git-send-email-mkl@pengutronix.de>
References: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1293288034-22428-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

While there, remove clearing of data if the dlc isn't longer as 4.
can frames have data initializes to zero.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc:Anant Gole <anantgole-l0cyMroinI0@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 drivers/net/can/ti_hecc.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 4d07f1e..b33581b 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -560,18 +560,20 @@ static int ti_hecc_rx_pkt(struct ti_hecc_priv *priv, int mbxno)
 		cf->can_id = (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
 	else
 		cf->can_id = (data >> 18) & CAN_SFF_MASK;
+
 	data = hecc_read_mbx(priv, mbxno, HECC_CANMCF);
+	cf->can_dlc = get_can_dlc(data & 0xF);
 	if (data & HECC_CANMCF_RTR)
 		cf->can_id |= CAN_RTR_FLAG;
-	cf->can_dlc = get_can_dlc(data & 0xF);
-	data = hecc_read_mbx(priv, mbxno, HECC_CANMDL);
-	*(u32 *)(cf->data) = cpu_to_be32(data);
-	if (cf->can_dlc > 4) {
-		data = hecc_read_mbx(priv, mbxno, HECC_CANMDH);
-		*(u32 *)(cf->data + 4) = cpu_to_be32(data);
-	} else {
-		*(u32 *)(cf->data + 4) = 0;
+	else {
+		data = hecc_read_mbx(priv, mbxno, HECC_CANMDL);
+		*(u32 *)(cf->data) = cpu_to_be32(data);
+		if (cf->can_dlc > 4) {
+			data = hecc_read_mbx(priv, mbxno, HECC_CANMDH);
+			*(u32 *)(cf->data + 4) = cpu_to_be32(data);
+		}
 	}
+
 	spin_lock_irqsave(&priv->mbx_lock, flags);
 	hecc_clear_bit(priv, HECC_CANME, mbx_mask);
 	hecc_write(priv, HECC_CANRMP, mbx_mask);
-- 
1.7.2.3
