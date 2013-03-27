From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: sja1000: fix define conflict on SH
Date: Wed, 27 Mar 2013 15:05:27 +0100
Message-ID: <1364393128-19701-2-git-send-email-mkl@pengutronix.de>
References: <1364393128-19701-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48900 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605Ab3C0OFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 10:05:31 -0400
In-Reply-To: <1364393128-19701-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thias patch fixes a define conflict between the SH architecture and the sja1000
driver:

    drivers/net/can/sja1000/sja1000.h:59:0: warning:
        "REG_SR" redefined [enabled by default]
    arch/sh/include/asm/ptrace_32.h:25:0: note:
         this is the location of the previous definition

A SJA1000_ prefix is added to the offending sja1000 define only, to make a
minimal patch suited for stable. A later patch will add a SJA1000_ prefix to
all defines in sja1000.h.

Cc: linux-stable <stable@vger.kernel.org>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/plx_pci.c | 4 ++--
 drivers/net/can/sja1000/sja1000.c | 6 +++---
 drivers/net/can/sja1000/sja1000.h | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index a042cdc..3c18d7d 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -348,7 +348,7 @@ static inline int plx_pci_check_sja1000(const struct sja1000_priv *priv)
 	 */
 	if ((priv->read_reg(priv, REG_CR) & REG_CR_BASICCAN_INITIAL_MASK) ==
 	    REG_CR_BASICCAN_INITIAL &&
-	    (priv->read_reg(priv, REG_SR) == REG_SR_BASICCAN_INITIAL) &&
+	    (priv->read_reg(priv, SJA1000_REG_SR) == REG_SR_BASICCAN_INITIAL) &&
 	    (priv->read_reg(priv, REG_IR) == REG_IR_BASICCAN_INITIAL))
 		flag = 1;
 
@@ -360,7 +360,7 @@ static inline int plx_pci_check_sja1000(const struct sja1000_priv *priv)
 	 * See states on p. 23 of the Datasheet.
 	 */
 	if (priv->read_reg(priv, REG_MOD) == REG_MOD_PELICAN_INITIAL &&
-	    priv->read_reg(priv, REG_SR) == REG_SR_PELICAN_INITIAL &&
+	    priv->read_reg(priv, SJA1000_REG_SR) == REG_SR_PELICAN_INITIAL &&
 	    priv->read_reg(priv, REG_IR) == REG_IR_PELICAN_INITIAL)
 		return flag;
 
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index daf4013..e4df307 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -92,7 +92,7 @@ static void sja1000_write_cmdreg(struct sja1000_priv *priv, u8 val)
 	 */
 	spin_lock_irqsave(&priv->cmdreg_lock, flags);
 	priv->write_reg(priv, REG_CMR, val);
-	priv->read_reg(priv, REG_SR);
+	priv->read_reg(priv, SJA1000_REG_SR);
 	spin_unlock_irqrestore(&priv->cmdreg_lock, flags);
 }
 
@@ -502,7 +502,7 @@ irqreturn_t sja1000_interrupt(int irq, void *dev_id)
 
 	while ((isrc = priv->read_reg(priv, REG_IR)) && (n < SJA1000_MAX_IRQ)) {
 		n++;
-		status = priv->read_reg(priv, REG_SR);
+		status = priv->read_reg(priv, SJA1000_REG_SR);
 		/* check for absent controller due to hw unplug */
 		if (status == 0xFF && sja1000_is_absent(priv))
 			return IRQ_NONE;
@@ -530,7 +530,7 @@ irqreturn_t sja1000_interrupt(int irq, void *dev_id)
 			/* receive interrupt */
 			while (status & SR_RBS) {
 				sja1000_rx(dev);
-				status = priv->read_reg(priv, REG_SR);
+				status = priv->read_reg(priv, SJA1000_REG_SR);
 				/* check for absent controller */
 				if (status == 0xFF && sja1000_is_absent(priv))
 					return IRQ_NONE;
diff --git a/drivers/net/can/sja1000/sja1000.h b/drivers/net/can/sja1000/sja1000.h
index afa9984..aa48e05 100644
--- a/drivers/net/can/sja1000/sja1000.h
+++ b/drivers/net/can/sja1000/sja1000.h
@@ -56,7 +56,7 @@
 /* SJA1000 registers - manual section 6.4 (Pelican Mode) */
 #define REG_MOD		0x00
 #define REG_CMR		0x01
-#define REG_SR		0x02
+#define SJA1000_REG_SR		0x02
 #define REG_IR		0x03
 #define REG_IER		0x04
 #define REG_ALC		0x0B
-- 
1.8.2.rc2
