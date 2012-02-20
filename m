From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: sja1000: fix isr hang when hw is unplugged under load
Date: Mon, 20 Feb 2012 11:58:32 +0100
Message-ID: <1329735512-29402-2-git-send-email-mkl@pengutronix.de>
References: <1329735512-29402-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56443 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255Ab2BTK6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 05:58:40 -0500
In-Reply-To: <1329735512-29402-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

In the case of hotplug enabled devices (PCMCIA/PCIeC) the removal of the
hardware can cause an infinite loop in the common sja1000 isr.

Use the already retrieved status register to indicate a possible hardware
removal and double check by reading the mode register in sja1000_is_absent.

Cc: stable@kernel.org [3.2+]
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 04a3f1b..192b0d1 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -95,11 +95,16 @@ static void sja1000_write_cmdreg(struct sja1000_priv *priv, u8 val)
 	spin_unlock_irqrestore(&priv->cmdreg_lock, flags);
 }
 
+static int sja1000_is_absent(struct sja1000_priv *priv)
+{
+	return (priv->read_reg(priv, REG_MOD) == 0xFF);
+}
+
 static int sja1000_probe_chip(struct net_device *dev)
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
 
-	if (priv->reg_base && (priv->read_reg(priv, 0) == 0xFF)) {
+	if (priv->reg_base && sja1000_is_absent(priv)) {
 		printk(KERN_INFO "%s: probing @0x%lX failed\n",
 		       DRV_NAME, dev->base_addr);
 		return 0;
@@ -493,6 +498,9 @@ irqreturn_t sja1000_interrupt(int irq, void *dev_id)
 	while ((isrc = priv->read_reg(priv, REG_IR)) && (n < SJA1000_MAX_IRQ)) {
 		n++;
 		status = priv->read_reg(priv, REG_SR);
+		/* check for absent controller due to hw unplug */
+		if (status == 0xFF && sja1000_is_absent(priv))
+			return IRQ_NONE;
 
 		if (isrc & IRQ_WUI)
 			dev_warn(dev->dev.parent, "wakeup interrupt\n");
@@ -509,6 +517,9 @@ irqreturn_t sja1000_interrupt(int irq, void *dev_id)
 			while (status & SR_RBS) {
 				sja1000_rx(dev);
 				status = priv->read_reg(priv, REG_SR);
+				/* check for absent controller */
+				if (status == 0xFF && sja1000_is_absent(priv))
+					return IRQ_NONE;
 			}
 		}
 		if (isrc & (IRQ_DOI | IRQ_EI | IRQ_BEI | IRQ_EPI | IRQ_ALI)) {
-- 
1.7.4.1
