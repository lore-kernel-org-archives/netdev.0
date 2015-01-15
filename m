From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 1/6] net: davinci_emac: Fix hangs with interrupts
Date: Thu, 15 Jan 2015 14:45:09 -0800
Message-ID: <1421361914-4612-2-git-send-email-tony@atomide.com>
References: <1421361914-4612-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1421361914-4612-1-git-send-email-tony@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On davinci_emac, we have pulse interrupts. This means that we need to
clear the EOI bits when disabling interrupts as otherwise the interrupts
keep happening. And we also need to not clear the EOI bits again when
enabling the interrupts as otherwise we will get tons of:

unexpected IRQ trap at vector 00

These errors almost certainly mean that the omap-intc.c is signaling
a spurious interrupt with the reserved irq 127 as we've seen earlier
on omap3.

Let's fix the issue by clearing the EOI bits when disabling the
interrupts. Let's also keep the comment for "Rx Threshold and Misc
interrupts are not enabled" for both enable and disable so people
are aware of this when potentially adding more support.

Note that eventually we should handle the RX and TX interrupts
separately like cpsw is now doing. However, so far I have not seen
any issues with this based on my testing, so it seems to behave a
little different compared to the cpsw that had a similar issue.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index ea71251..383ed52 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -922,6 +922,16 @@ static void emac_int_disable(struct emac_priv *priv)
 		if (priv->int_disable)
 			priv->int_disable();
 
+		/* NOTE: Rx Threshold and Misc interrupts are not enabled */
+
+		/* ack rxen only then a new pulse will be generated */
+		emac_write(EMAC_DM646X_MACEOIVECTOR,
+			EMAC_DM646X_MAC_EOI_C0_RXEN);
+
+		/* ack txen- only then a new pulse will be generated */
+		emac_write(EMAC_DM646X_MACEOIVECTOR,
+			EMAC_DM646X_MAC_EOI_C0_TXEN);
+
 		local_irq_restore(flags);
 
 	} else {
@@ -951,15 +961,6 @@ static void emac_int_enable(struct emac_priv *priv)
 		 * register */
 
 		/* NOTE: Rx Threshold and Misc interrupts are not enabled */
-
-		/* ack rxen only then a new pulse will be generated */
-		emac_write(EMAC_DM646X_MACEOIVECTOR,
-			EMAC_DM646X_MAC_EOI_C0_RXEN);
-
-		/* ack txen- only then a new pulse will be generated */
-		emac_write(EMAC_DM646X_MACEOIVECTOR,
-			EMAC_DM646X_MAC_EOI_C0_TXEN);
-
 	} else {
 		/* Set DM644x control registers for interrupt control */
 		emac_ctrl_write(EMAC_CTRL_EWCTL, 0x1);
-- 
2.1.4

