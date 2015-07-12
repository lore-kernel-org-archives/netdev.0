From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/8] can: rcar_can: fix IRQ check
Date: Sun, 12 Jul 2015 21:18:04 +0200
Message-ID: <1436728691-1145-2-git-send-email-mkl@pengutronix.de>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

rcar_can_probe() regards 0 as a wrong IRQ #, despite platform_get_irq() that it
calls returns negative error code in that case. This leads to the following
being printed to the console when attempting to open the device:

error requesting interrupt fffffffa

because  rcar_can_open() calls request_irq() with a negative IRQ #, and that
function naturally fails with -EINVAL.

Check for the negative error codes instead and propagate them upstream instead
of just returning -ENODEV.

Fixes: fd1159318e55 ("can: add Renesas R-Car CAN driver")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/rcar_can.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index 7deb80dcbe8c..93017c09cfc3 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -758,8 +758,9 @@ static int rcar_can_probe(struct platform_device *pdev)
 	}
 
 	irq = platform_get_irq(pdev, 0);
-	if (!irq) {
+	if (irq < 0) {
 		dev_err(&pdev->dev, "No IRQ resource\n");
+		err = irq;
 		goto fail;
 	}
 
-- 
2.1.4

