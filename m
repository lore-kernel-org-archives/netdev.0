From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH] mscan: too much data copied to CAN frame due to 16 bit
	accesses
Date: Fri, 07 Oct 2011 21:28:14 +0200
Message-ID: <4E8F52CE.1000204@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, Andre Naujoks <nautsch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Due to the 16 bit access to mscan registers there's too much data copied to
the zero initialized CAN frame when having an odd number of bytes to copy.
This patch ensures that only the requested bytes are copied by using an
8 bit access for the remaining byte.

Reported-by: Andre Naujoks <nautsch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 drivers/net/can/mscan/mscan.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index ac42f5d..ec4a311 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -261,11 +261,13 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		void __iomem *data = &regs->tx.dsr1_0;
 		u16 *payload = (u16 *)frame->data;
 
-		/* It is safe to write into dsr[dlc+1] */
-		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
+		for (i = 0; i < frame->can_dlc / 2; i++) {
 			out_be16(data, *payload++);
 			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
 		}
+		/* write remaining byte if necessary */
+		if (frame->can_dlc & 1)
+			out_8(data, frame->data[frame->can_dlc - 1]);
 	}
 
 	out_8(&regs->tx.dlr, frame->can_dlc);
@@ -330,10 +332,13 @@ static void mscan_get_rx_frame(struct net_device *dev, struct can_frame *frame)
 		void __iomem *data = &regs->rx.dsr1_0;
 		u16 *payload = (u16 *)frame->data;
 
-		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
+		for (i = 0; i < frame->can_dlc / 2; i++) {
 			*payload++ = in_be16(data);
 			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
 		}
+		/* read remaining byte if necessary */
+		if (frame->can_dlc & 1)
+			frame->data[frame->can_dlc - 1] = in_8(data);
 	}
 
 	out_8(&regs->canrflg, MSCAN_RXF);
-- 
1.7.4.1
