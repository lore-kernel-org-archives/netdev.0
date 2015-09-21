From: Sudeep Holla <sudeep.holla@arm.com>
Subject: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND flag
Date: Mon, 21 Sep 2015 16:47:09 +0100
Message-ID: <1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
Cc: Sudeep Holla <sudeep.holla@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Kevin Hao <haokexin@gmail.com>, netdev@vger.kernel.org
To: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device is set as wakeup capable using proper wakeup API but the
driver misuses IRQF_NO_SUSPEND to set the interrupt as wakeup source
which is incorrect.

This patch removes the use of IRQF_NO_SUSPEND flags replacing it with
enable_irq_wake instead.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Cc: Kevin Hao <haokexin@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4b69d061d90f..803ed4c93503 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1970,8 +1970,7 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive
 		 */
-		err = request_irq(gfar_irq(grp, ER)->irq, gfar_error,
-				  IRQF_NO_SUSPEND,
+		err = request_irq(gfar_irq(grp, ER)->irq, gfar_error, 0,
 				  gfar_irq(grp, ER)->name, grp);
 		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
@@ -1979,6 +1978,8 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 
 			goto err_irq_fail;
 		}
+		enable_irq_wake(gfar_irq(grp, ER)->irq);
+
 		err = request_irq(gfar_irq(grp, TX)->irq, gfar_transmit, 0,
 				  gfar_irq(grp, TX)->name, grp);
 		if (err < 0) {
@@ -1994,14 +1995,14 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 			goto rx_irq_fail;
 		}
 	} else {
-		err = request_irq(gfar_irq(grp, TX)->irq, gfar_interrupt,
-				  IRQF_NO_SUSPEND,
+		err = request_irq(gfar_irq(grp, TX)->irq, gfar_interrupt, 0,
 				  gfar_irq(grp, TX)->name, grp);
 		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  gfar_irq(grp, TX)->irq);
 			goto err_irq_fail;
 		}
+		enable_irq_wake(gfar_irq(grp, TX)->irq);
 	}
 
 	return 0;
-- 
1.9.1
