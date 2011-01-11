From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 1/3] can: at91_can: clean up usage of AT91_MB_RX_FIRST and
	AT91_MB_RX_NUM
Date: Tue, 11 Jan 2011 11:28:06 +0100
Message-ID: <1294741688-22699-2-git-send-email-mkl@pengutronix.de>
References: <1294741688-22699-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1294741688-22699-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

This patch cleans up the usage of two macros which specify the mailbox
usage. AT91_MB_RX_FIRST and AT91_MB_RX_NUM define the first and the
number of RX mailboxes. The current driver uses these variables in an
unclean way; assuming that AT91_MB_RX_FIRST is 0;

This patch cleans up the usage of these macros, no longer assuming
AT91_MB_RX_FIRST == 0.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 7ef83d0..892c3d8 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -2,7 +2,7 @@
  * at91_can.c - CAN network driver for AT91 SoC CAN controller
  *
  * (C) 2007 by Hans J. Koch <hjk-vqZO0P4V72/QD6PfKP4TzA@public.gmane.org>
- * (C) 2008, 2009, 2010 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+ * (C) 2008, 2009, 2010, 2011 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
  *
  * This software may be distributed under the terms of the GNU General
  * Public License ("GPL") version 2 as distributed in the 'COPYING'
@@ -55,7 +55,8 @@
 #define AT91_MB_RX_MASK(i)	((1 << (i)) - 1)
 #define AT91_MB_RX_SPLIT	8
 #define AT91_MB_RX_LOW_LAST	(AT91_MB_RX_SPLIT - 1)
-#define AT91_MB_RX_LOW_MASK	(AT91_MB_RX_MASK(AT91_MB_RX_SPLIT))
+#define AT91_MB_RX_LOW_MASK	(AT91_MB_RX_MASK(AT91_MB_RX_SPLIT) & \
+				 ~AT91_MB_RX_MASK(AT91_MB_RX_FIRST))
 
 #define AT91_MB_TX_NUM		(1 << AT91_MB_TX_SHIFT)
 #define AT91_MB_TX_FIRST	(AT91_MB_RX_LAST + 1)
@@ -254,7 +255,8 @@ static void at91_setup_mailboxes(struct net_device *dev)
 		set_mb_mode_prio(priv, i, AT91_MB_MODE_TX, 0);
 
 	/* Reset tx and rx helper pointers */
-	priv->tx_next = priv->tx_echo = priv->rx_next = 0;
+	priv->tx_next = priv->tx_echo = 0;
+	priv->rx_next = AT91_MB_RX_FIRST;
 }
 
 static int at91_set_bittiming(struct net_device *dev)
@@ -590,10 +592,10 @@ static int at91_poll_rx(struct net_device *dev, int quota)
 			"order of incoming frames cannot be guaranteed\n");
 
  again:
-	for (mb = find_next_bit(addr, AT91_MB_RX_NUM, priv->rx_next);
-	     mb < AT91_MB_RX_NUM && quota > 0;
+	for (mb = find_next_bit(addr, AT91_MB_RX_LAST + 1, priv->rx_next);
+	     mb < AT91_MB_RX_LAST + 1 && quota > 0;
 	     reg_sr = at91_read(priv, AT91_SR),
-	     mb = find_next_bit(addr, AT91_MB_RX_NUM, ++priv->rx_next)) {
+	     mb = find_next_bit(addr, AT91_MB_RX_LAST + 1, ++priv->rx_next)) {
 		at91_read_msg(dev, mb);
 
 		/* reactivate mailboxes */
@@ -610,8 +612,8 @@ static int at91_poll_rx(struct net_device *dev, int quota)
 
 	/* upper group completed, look again in lower */
 	if (priv->rx_next > AT91_MB_RX_LOW_LAST &&
-	    quota > 0 && mb >= AT91_MB_RX_NUM) {
-		priv->rx_next = 0;
+	    quota > 0 && mb > AT91_MB_RX_LAST) {
+		priv->rx_next = AT91_MB_RX_FIRST;
 		goto again;
 	}
 
-- 
1.7.2.3
