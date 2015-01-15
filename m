From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/8] can: c_can: use regmap_update_bits() to modify RAMINIT register
Date: Thu, 15 Jan 2015 17:11:19 +0100
Message-ID: <1421338283-12417-5-git-send-email-mkl@pengutronix.de>
References: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Roger Quadros <rogerq@ti.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56606 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbAOQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 11:11:33 -0500
In-Reply-To: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roger Quadros <rogerq@ti.com>

use of regmap_read() and regmap_write() in c_can_hw_raminit_syscon()
is not safe as the RAMINIT register can be shared between different drivers
at least for TI SoCs.

To make the modification atomic we switch to using regmap_update_bits().

regmap_update_bits() skips writing to the register if it's read content is the
same as what is going to be written. This causes an issue for us when we
need to clear the DONE bit with the initial condition START:0, DONE:1 as
DONE bit must be written with 1 to clear it.

So we defer the clearing of DONE bit to later when we set the START bit.
There we are sure that START bit is changed from 0 to 1 so the write of
1 to already set DONE bit will happen.

Signed-off-by: Roger Quadros <rogerq@ti.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can_platform.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index f363972cd77d..e36d10520e24 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -103,27 +103,34 @@ static void c_can_hw_raminit_syscon(const struct c_can_priv *priv, bool enable)
 	mask = 1 << raminit->bits.start | 1 << raminit->bits.done;
 	regmap_read(raminit->syscon, raminit->reg, &ctrl);
 
-	/* We clear the done and start bit first. The start bit is
+	/* We clear the start bit first. The start bit is
 	 * looking at the 0 -> transition, but is not self clearing;
-	 * And we clear the init done bit as well.
 	 * NOTE: DONE must be written with 1 to clear it.
+	 * We can't clear the DONE bit here using regmap_update_bits()
+	 * as it will bypass the write if initial condition is START:0 DONE:1
+	 * e.g. on DRA7 which needs START pulse.
 	 */
-	ctrl &= ~(1 << raminit->bits.start);
-	ctrl |= 1 << raminit->bits.done;
-	regmap_write(raminit->syscon, raminit->reg, ctrl);
+	ctrl &= ~mask;	/* START = 0, DONE = 0 */
+	regmap_update_bits(raminit->syscon, raminit->reg, mask, ctrl);
 
-	ctrl &= ~(1 << raminit->bits.done);
-	c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
+	/* check if START bit is 0. Ignore DONE bit for now
+	 * as it can be either 0 or 1.
+	 */
+	c_can_hw_raminit_wait_syscon(priv, 1 << raminit->bits.start, ctrl);
 
 	if (enable) {
-		/* Set start bit and wait for the done bit. */
+		/* Clear DONE bit & set START bit. */
 		ctrl |= 1 << raminit->bits.start;
-		regmap_write(raminit->syscon, raminit->reg, ctrl);
-
+		/* DONE must be written with 1 to clear it */
+		ctrl |= 1 << raminit->bits.done;
+		regmap_update_bits(raminit->syscon, raminit->reg, mask, ctrl);
+		/* prevent further clearing of DONE bit */
+		ctrl &= ~(1 << raminit->bits.done);
 		/* clear START bit if start pulse is needed */
 		if (raminit->needs_pulse) {
 			ctrl &= ~(1 << raminit->bits.start);
-			regmap_write(raminit->syscon, raminit->reg, ctrl);
+			regmap_update_bits(raminit->syscon, raminit->reg,
+					   mask, ctrl);
 		}
 
 		ctrl |= 1 << raminit->bits.done;
-- 
2.1.4
