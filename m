From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: sja1000: clear interrupts on start
Date: Mon, 23 Nov 2015 09:46:52 +0100
Message-ID: <1448268414-18583-2-git-send-email-mkl@pengutronix.de>
References: <1448268414-18583-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Mirza Krak <mirza.krak@hostmobility.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:35888 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbbKWIrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 03:47:01 -0500
In-Reply-To: <1448268414-18583-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mirza Krak <mirza.krak@hostmobility.com>

According to SJA1000 data sheet error-warning (EI) interrupt is not
cleared by setting the controller in to reset-mode.

Then if we have the following case:
- system is suspended (echo mem > /sys/power/state) and SJA1000 is left
  in operating state
- A bus error condition occurs which activates EI interrupt, system is
  still suspended which means EI interrupt will be not be handled nor
  cleared.

If the above two events occur, on resume there is no way to return the
SJA1000 to operating state, except to cycle power to it.

By simply reading the IR register on start we will clear any previous
conditions that could be present.

Signed-off-by: Mirza Krak <mirza.krak@hostmobility.com>
Reported-by: Christian Magnusson <Christian.Magnusson@semcon.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 7b92e911a616..f10834be48a5 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -218,6 +218,9 @@ static void sja1000_start(struct net_device *dev)
 	priv->write_reg(priv, SJA1000_RXERR, 0x0);
 	priv->read_reg(priv, SJA1000_ECC);
 
+	/* clear interrupt flags */
+	priv->read_reg(priv, SJA1000_IR);
+
 	/* leave reset mode */
 	set_normal_mode(dev);
 }
-- 
2.6.2
