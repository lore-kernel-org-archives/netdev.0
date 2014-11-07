From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 1/8] net: can: c_can: Add timeout to c_can_hw_raminit_ti()
Date: Fri, 7 Nov 2014 16:49:15 +0200
Message-ID: <1415371762-29885-2-git-send-email-rogerq@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TI's RAMINIT DONE mechanism is buggy on AM43xx SoC and may not always
be set after the START bit is set. Although it seems to work fine even
in that case. So add a timeout mechanism to c_can_hw_raminit_wait_ti().
Don't bail out in that failure case but just print an error message.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can_platform.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index fb279d6..b144e71 100644
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
-- 
1.8.3.2

