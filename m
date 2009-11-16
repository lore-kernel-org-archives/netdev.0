From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 09/11] net/can/mscan: replace hardcoded values with defines
Date: Mon, 16 Nov 2009 23:57:52 +0100
Message-ID: <1258412274-14686-10-git-send-email-w.sang@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Not all hardcoded values have been replaced as this made the code quite
unreadable. IMHO this compromise serves the purpose of readability.

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mscan/mscan.c |   15 ++++++++++-----
 drivers/net/can/mscan/mscan.h |    5 +++++
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 20d1991..263d1a9 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -211,18 +211,23 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	rtr = frame->can_id & CAN_RTR_FLAG;
 
+	/* RTR is always the lowest bit of interest, then IDs follow */
 	if (frame->can_id & CAN_EFF_FLAG) {
-		can_id = (frame->can_id & CAN_EFF_MASK) << 1;
+		can_id = (frame->can_id & CAN_EFF_MASK)
+			 << (MSCAN_EFF_RTR_SHIFT + 1);
 		if (rtr)
-			can_id |= 1;
+			can_id |= 1 << MSCAN_EFF_RTR_SHIFT;
 		out_be16(&regs->tx.idr3_2, can_id);
 
 		can_id >>= 16;
-		can_id = (can_id & 0x7) | ((can_id << 2) & 0xffe0) | (3 << 3);
+		/* EFF_FLAGS are inbetween the IDs :( */
+		can_id = (can_id & 0x7) | ((can_id << 2) & 0xffe0)
+			 | MSCAN_EFF_FLAGS;
 	} else {
-		can_id = (frame->can_id & CAN_SFF_MASK) << 5;
+		can_id = (frame->can_id & CAN_SFF_MASK)
+			 << (MSCAN_SFF_RTR_SHIFT + 1);
 		if (rtr)
-			can_id |= 1 << 4;
+			can_id |= 1 << MSCAN_SFF_RTR_SHIFT;
 	}
 	out_be16(&regs->tx.idr1_0, can_id);
 
diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
index 2018000..00fc4aa 100644
--- a/drivers/net/can/mscan/mscan.h
+++ b/drivers/net/can/mscan/mscan.h
@@ -131,6 +131,11 @@
 /* MSCAN Miscellaneous Register (CANMISC) bits */
 #define MSCAN_BOHOLD		0x01
 
+/* MSCAN Identifier Register (IDR) bits */
+#define MSCAN_SFF_RTR_SHIFT	4
+#define MSCAN_EFF_RTR_SHIFT	0
+#define MSCAN_EFF_FLAGS		0x18	/* IDE + SRR */
+
 #ifdef MSCAN_FOR_MPC5200
 #define _MSCAN_RESERVED_(n, num) u8 _res##n[num]
 #define _MSCAN_RESERVED_DSR_SIZE	2
-- 
1.6.3.3
