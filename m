From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH v2 2/9] can: bfin_can: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:55:10 +0100
Message-ID: <1293296117-27624-3-git-send-email-mkl@pengutronix.de>
References: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1293296117-27624-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 drivers/net/can/bfin_can.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index b6e890d..07222ca 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -306,18 +306,19 @@ static void bfin_can_rx(struct net_device *dev, u16 isrc)
 			     & 0x1ffc) >> 2;
 		obj = RECEIVE_STD_CHL;
 	}
-	if (bfin_read16(&reg->chl[obj].id1) & RTR)
-		cf->can_id |= CAN_RTR_FLAG;
 
 	/* get data length code */
 	cf->can_dlc = get_can_dlc(bfin_read16(&reg->chl[obj].dlc) & 0xF);
 
-	/* get payload */
-	for (i = 0; i < 8; i += 2) {
-		val = bfin_read16(&reg->chl[obj].data[i]);
-		cf->data[7 - i] = (7 - i) < cf->can_dlc ? val : 0;
-		cf->data[6 - i] = (6 - i) < cf->can_dlc ? (val >> 8) : 0;
-	}
+	if (bfin_read16(&reg->chl[obj].id1) & RTR)
+		cf->can_id |= CAN_RTR_FLAG;
+	else	/* get payload */
+		for (i = 0; i < 8; i += 2) {
+			val = bfin_read16(&reg->chl[obj].data[i]);
+			cf->data[7 - i] = (7 - i) < cf->can_dlc ? val : 0;
+			cf->data[6 - i] = (6 - i) < cf->can_dlc ?
+				(val >> 8) : 0;
+		}
 
 	netif_rx(skb);
 
-- 
1.7.2.3
