From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 01/13] can: c_can_platform: Fix c_can_hw_raminit_ti() and add timeout
Date: Mon, 8 Sep 2014 17:10:30 +0300
Message-ID: <1410185442-907-2-git-send-email-rogerq@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>, Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:58818 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500AbaIHOLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 10:11:15 -0400
In-Reply-To: <1410185442-907-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the correct 'mask' and 'value' bits to c_can_hw_raminit_wait_ti().
They seem to have been swapped in the usage instances.

TI's RAMINIT DONE mechanism is buggy and may not always be
set after the START bit is set. So add a timeout mechanism to
c_can_hw_raminit_wait_ti().

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can_platform.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 109cb44..b144e71 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -75,10 +75,18 @@ static void c_can_plat_write_reg_aligned_to_32bit(const struct c_can_priv *priv,
 static void c_can_hw_raminit_wait_ti(const struct c_can_priv *priv, u32 mask,
 				  u32 val)
 {
+	int timeout = 0;
 	/* We look only at the bits of our instance. */
 	val &= mask;
-	while ((readl(priv->raminit_ctrlreg) & mask) != val)
+	while ((readl(priv->raminit_ctrlreg) & mask) != val) {
 		udelay(1);
+		timeout++;
+
+		if (timeout == 1000) {
+			dev_err(&priv->dev->dev, "%s: time out\n", __func__);
+			break;
+		}
+	}
 }
 
 static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool enable)
@@ -97,14 +105,14 @@ static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool enable)
 	ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
 	writel(ctrl, priv->raminit_ctrlreg);
 	ctrl &= ~CAN_RAMINIT_DONE_MASK(priv->instance);
-	c_can_hw_raminit_wait_ti(priv, ctrl, mask);
+	c_can_hw_raminit_wait_ti(priv, mask, ctrl);
 
 	if (enable) {
 		/* Set start bit and wait for the done bit. */
 		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
 		writel(ctrl, priv->raminit_ctrlreg);
 		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
-		c_can_hw_raminit_wait_ti(priv, ctrl, mask);
+		c_can_hw_raminit_wait_ti(priv, mask, ctrl);
 	}
 	spin_unlock(&raminit_lock);
 }
-- 
1.8.3.2
