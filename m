From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 5/8] net: can: c_can: Add support for START pulse in RAMINIT sequence
Date: Fri, 7 Nov 2014 16:49:19 +0200
Message-ID: <1415371762-29885-6-git-send-email-rogerq@ti.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:52494 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987AbaKGOuW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 09:50:22 -0500
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some SoCs e.g. (TI DRA7xx) need a START pulse to start the
RAMINIT sequence i.e. START bit must be set and cleared before
checking for the DONE bit status.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can.h          | 1 +
 drivers/net/can/c_can/c_can_platform.c | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 0e17c7b..c6715ca 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -185,6 +185,7 @@ struct c_can_raminit {
 	unsigned int reg;	/* register index within syscon */
 	u8 start_bit;
 	u8 done_bit;
+	bool needs_pulse;
 };
 
 /* c_can private data structure */
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 3776483..b838c6b 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -124,6 +124,12 @@ static void c_can_hw_raminit_syscon(const struct c_can_priv *priv, bool enable)
 		ctrl |= 1 << start_bit;
 		regmap_write(raminit->syscon, raminit->reg, ctrl);
 
+		/* clear START bit if start pulse is needed */
+		if (raminit->needs_pulse) {
+			ctrl &= ~(1 << start_bit);
+			regmap_write(raminit->syscon, raminit->reg, ctrl);
+		}
+
 		ctrl |= 1 << done_bit;
 		c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
 	}
@@ -330,6 +336,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 
 			raminit->start_bit = drvdata->raminit_start_bits[id];
 			raminit->done_bit = drvdata->raminit_done_bits[id];
+			raminit->needs_pulse = drvdata->raminit_pulse;
 
 			priv->raminit = c_can_hw_raminit_syscon;
 		} else {
-- 
1.8.3.2
