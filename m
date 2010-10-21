From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 02/10] can: at91_can: fix reception of extended frames
Date: Thu, 21 Oct 2010 13:01:14 +0200
Message-ID: <1287658882-26914-3-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1287658882-26914-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

The AT91_MID_MIDE bit must be set in order to receive extended frames.
The reception of an extended frame sets this bit, while reception of
standard frames resets it. This results in some lost extended frames in
an extended ID only environment. But leads to unpredictable lost
extended ID frames in a mixed environment.

The problem is fixed by setting the AT91_MID_MIDE after reception of a
CAN frame.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index b2a4599..3b66c67 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -243,6 +243,12 @@ static void at91_setup_mailboxes(struct net_device *dev)
 		set_mb_mode(priv, i, AT91_MB_MODE_RX);
 	set_mb_mode(priv, AT91_MB_RX_LAST, AT91_MB_MODE_RX_OVRWR);
 
+	/* reset acceptance mask and id register */
+	for (i = AT91_MB_RX_FIRST; i <= AT91_MB_RX_LAST; i++) {
+		at91_write(priv, AT91_MAM(i), 0x0 );
+		at91_write(priv, AT91_MID(i), AT91_MID_MIDE);
+	}
+
 	/* The last 4 mailboxes are used for transmitting. */
 	for (i = AT91_MB_TX_FIRST; i <= AT91_MB_TX_LAST; i++)
 		set_mb_mode_prio(priv, i, AT91_MB_MODE_TX, 0);
@@ -480,6 +486,9 @@ static void at91_read_mb(struct net_device *dev, unsigned int mb,
 	*(u32 *)(cf->data + 0) = at91_read(priv, AT91_MDL(mb));
 	*(u32 *)(cf->data + 4) = at91_read(priv, AT91_MDH(mb));
 
+	/* allow RX of extended frames */
+	at91_write(priv, AT91_MID(mb), AT91_MID_MIDE);
+
 	if (unlikely(mb == AT91_MB_RX_LAST && reg_msr & AT91_MSR_MMI))
 		at91_rx_overflow_err(dev);
 }
-- 
1.7.0.4
