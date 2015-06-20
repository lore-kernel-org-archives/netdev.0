From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/3] rcar_can: fix IRQ check
Date: Sat, 20 Jun 2015 03:32:46 +0300
Message-ID: <1788456.ArSzxG6No3@wasted.cogentembedded.com>
References: <2010452.WyFito6egU@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <2010452.WyFito6egU@wasted.cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

---
 drivers/net/can/rcar_can.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-can/drivers/net/can/rcar_can.c
===================================================================
--- linux-can.orig/drivers/net/can/rcar_can.c
+++ linux-can/drivers/net/can/rcar_can.c
@@ -758,8 +758,9 @@ static int rcar_can_probe(struct platfor
 	}
 
 	irq = platform_get_irq(pdev, 0);
-	if (!irq) {
+	if (irq < 0) {
 		dev_err(&pdev->dev, "No IRQ resource\n");
+		err = irq;
 		goto fail;
 	}
 

--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
