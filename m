From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 06/16] can: c_can: Fix hardware raminit function
Date: Tue,  1 Apr 2014 23:42:20 +0200
Message-ID: <1396388550-23081-7-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42634 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbaDAVmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 17:42:37 -0400
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

The function is broken in several ways:

    - The function does not wait for the init to complete.
      That can take quite some microseconds.

    - No protection against being called for two chips at the same
      time. SMP is such a new thing, right?

Clear the start and the init done bit unconditionally and wait for both bits to
be clear.

In the enable path set the init bit and wait for the init done bit.

Add proper locking.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can_platform.c | 47 ++++++++++++++++++++++++++--------
 1 file changed, 37 insertions(+), 10 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index d66ac26..806d927 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -37,8 +37,10 @@
 
 #include "c_can.h"
 
-#define CAN_RAMINIT_START_MASK(i)	(1 << (i))
-
+#define CAN_RAMINIT_START_MASK(i)	(0x001 << (i))
+#define CAN_RAMINIT_DONE_MASK(i)	(0x100 << (i))
+#define CAN_RAMINIT_ALL_MASK(i)		(0x101 << (i))
+static DEFINE_SPINLOCK(raminit_lock);
 /*
  * 16-bit c_can registers can be arranged differently in the memory
  * architecture of different implementations. For example: 16-bit
@@ -69,16 +71,41 @@ static void c_can_plat_write_reg_aligned_to_32bit(struct c_can_priv *priv,
 	writew(val, priv->base + 2 * priv->regs[index]);
 }
 
+static void c_can_hw_raminit_wait(const struct c_can_priv *priv, u32 mask,
+				  u32 val)
+{
+	/* We look only at the bits of our instance. */
+	val &= mask;
+	while ((readl(priv->raminit_ctrlreg) & mask) != val)
+		udelay(1);
+}
+
 static void c_can_hw_raminit(const struct c_can_priv *priv, bool enable)
 {
-	u32 val;
-
-	val = readl(priv->raminit_ctrlreg);
-	if (enable)
-		val |= CAN_RAMINIT_START_MASK(priv->instance);
-	else
-		val &= ~CAN_RAMINIT_START_MASK(priv->instance);
-	writel(val, priv->raminit_ctrlreg);
+	u32 mask = CAN_RAMINIT_ALL_MASK(priv->instance);
+	u32 ctrl;
+
+	spin_lock(&raminit_lock);
+
+	ctrl = readl(priv->raminit_ctrlreg);
+	/* We clear the done and start bit first. The start bit is
+	 * looking at the 0 -> transition, but is not self clearing;
+	 * And we clear the init done bit as well.
+	 */
+	ctrl &= ~CAN_RAMINIT_START_MASK(priv->instance);
+	ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
+	writel(ctrl, priv->raminit_ctrlreg);
+	ctrl &= ~CAN_RAMINIT_DONE_MASK(priv->instance);
+	c_can_hw_raminit_wait(priv, ctrl, mask);
+
+	if (enable) {
+		/* Set start bit and wait for the done bit. */
+		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
+		writel(ctrl, priv->raminit_ctrlreg);
+		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
+		c_can_hw_raminit_wait(priv, ctrl, mask);
+	}
+	spin_unlock(&raminit_lock);
 }
 
 static struct platform_device_id c_can_id_table[] = {
-- 
1.9.0.279.gdc9e3eb
