From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH v2 2/3] can: at91_can: don't use mailbox 0
Date: Tue, 11 Jan 2011 14:21:24 +0100
Message-ID: <1294752085-30151-3-git-send-email-mkl@pengutronix.de>
References: <1294752085-30151-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1294752085-30151-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Due to a chip bug (errata 50.2.6.3 & 50.3.5.3 in
"AT91SAM9263 Preliminary 6249H-ATARM-27-Jul-09") the contents of mailbox
0 may be send under certain conditions (even if disabled or in rx mode).

The workaround in the errata suggests not to use the mailbox and load it
with a unused identifier.

This patch implements the first part of the workaround, it updates
AT91_MB_RX_NUM and AT91_MB_RX_FIRST (and the inline documentation)
so that mailbox 0 stays unused.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 892c3d8..16e45a5 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -40,16 +40,16 @@
 
 #include <mach/board.h>
 
-#define AT91_NAPI_WEIGHT	12
+#define AT91_NAPI_WEIGHT	11
 
 /*
  * RX/TX Mailbox split
  * don't dare to touch
  */
-#define AT91_MB_RX_NUM		12
+#define AT91_MB_RX_NUM		11
 #define AT91_MB_TX_SHIFT	2
 
-#define AT91_MB_RX_FIRST	0
+#define AT91_MB_RX_FIRST	1
 #define AT91_MB_RX_LAST		(AT91_MB_RX_FIRST + AT91_MB_RX_NUM - 1)
 
 #define AT91_MB_RX_MASK(i)	((1 << (i)) - 1)
@@ -236,10 +236,14 @@ static void at91_setup_mailboxes(struct net_device *dev)
 	unsigned int i;
 
 	/*
-	 * The first 12 mailboxes are used as a reception FIFO. The
-	 * last mailbox is configured with overwrite option. The
-	 * overwrite flag indicates a FIFO overflow.
+	 * Due to a chip bug (errata 50.2.6.3 & 50.3.5.3) the first
+	 * mailbox is disabled. The next 11 mailboxes are used as a
+	 * reception FIFO. The last mailbox is configured with
+	 * overwrite option. The overwrite flag indicates a FIFO
+	 * overflow.
 	 */
+	for (i = 0; i < AT91_MB_RX_FIRST; i++)
+		set_mb_mode(priv, i, AT91_MB_MODE_DISABLED);
 	for (i = AT91_MB_RX_FIRST; i < AT91_MB_RX_LAST; i++)
 		set_mb_mode(priv, i, AT91_MB_MODE_RX);
 	set_mb_mode(priv, AT91_MB_RX_LAST, AT91_MB_MODE_RX_OVRWR);
@@ -541,27 +545,31 @@ static void at91_read_msg(struct net_device *dev, unsigned int mb)
  *
  * Theory of Operation:
  *
- * 12 of the 16 mailboxes on the chip are reserved for RX. we split
- * them into 2 groups. The lower group holds 8 and upper 4 mailboxes.
+ * 11 of the 16 mailboxes on the chip are reserved for RX. we split
+ * them into 2 groups. The lower group holds 7 and upper 4 mailboxes.
  *
  * Like it or not, but the chip always saves a received CAN message
  * into the first free mailbox it finds (starting with the
  * lowest). This makes it very difficult to read the messages in the
  * right order from the chip. This is how we work around that problem:
  *
- * The first message goes into mb nr. 0 and issues an interrupt. All
+ * The first message goes into mb nr. 1 and issues an interrupt. All
  * rx ints are disabled in the interrupt handler and a napi poll is
  * scheduled. We read the mailbox, but do _not_ reenable the mb (to
  * receive another message).
  *
  *    lower mbxs      upper
- *   ______^______    __^__
- *  /             \  /     \
+ *     ____^______    __^__
+ *    /           \  /     \
  * +-+-+-+-+-+-+-+-++-+-+-+-+
- * |x|x|x|x|x|x|x|x|| | | | |
+ * | |x|x|x|x|x|x|x|| | | | |
  * +-+-+-+-+-+-+-+-++-+-+-+-+
  *  0 0 0 0 0 0  0 0 0 0 1 1  \ mail
  *  0 1 2 3 4 5  6 7 8 9 0 1  / box
+ *  ^
+ *  |
+ *   \
+ *     unused, due to chip bug
  *
  * The variable priv->rx_next points to the next mailbox to read a
  * message from. As long we're in the lower mailboxes we just read the
-- 
1.7.2.3
