From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 24/26] can: sja1000_isa: add locking for indirect register access mode
Date: Fri, 25 Apr 2014 00:00:27 +0200
Message-ID: <1398376829-6771-25-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46159 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932582AbaDXWAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:00:45 -0400
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

When accessing the SJA1000 controller registers in the indirect access mode,
writing the register number and reading/writing the data has to be an atomic
attempt.

As the sja1000_isa driver is an old style driver with a fixed number of
instances the locking variable depends on the same index like all the other
configuration elements given on the module command line.

As a positive side effect dev->dev_id is populated by the instance index,
which was missing in 3e66d0138c05d9 ("can: populate netdev::dev_id for udev
discrimination").

Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000_isa.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index df136a2..014695d 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -46,6 +46,7 @@ static int clk[MAXDEV];
 static unsigned char cdr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
 static unsigned char ocr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
 static int indirect[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
+static spinlock_t indirect_lock[MAXDEV];  /* lock for indirect access mode */
 
 module_param_array(port, ulong, NULL, S_IRUGO);
 MODULE_PARM_DESC(port, "I/O port number");
@@ -101,19 +102,26 @@ static void sja1000_isa_port_write_reg(const struct sja1000_priv *priv,
 static u8 sja1000_isa_port_read_reg_indirect(const struct sja1000_priv *priv,
 					     int reg)
 {
-	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags, base = (unsigned long)priv->reg_base;
+	u8 readval;
 
+	spin_lock_irqsave(&indirect_lock[priv->dev->dev_id], flags);
 	outb(reg, base);
-	return inb(base + 1);
+	readval = inb(base + 1);
+	spin_unlock_irqrestore(&indirect_lock[priv->dev->dev_id], flags);
+
+	return readval;
 }
 
 static void sja1000_isa_port_write_reg_indirect(const struct sja1000_priv *priv,
 						int reg, u8 val)
 {
-	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags, base = (unsigned long)priv->reg_base;
 
+	spin_lock_irqsave(&indirect_lock[priv->dev->dev_id], flags);
 	outb(reg, base);
 	outb(val, base + 1);
+	spin_unlock_irqrestore(&indirect_lock[priv->dev->dev_id], flags);
 }
 
 static int sja1000_isa_probe(struct platform_device *pdev)
@@ -169,6 +177,7 @@ static int sja1000_isa_probe(struct platform_device *pdev)
 		if (iosize == SJA1000_IOSIZE_INDIRECT) {
 			priv->read_reg = sja1000_isa_port_read_reg_indirect;
 			priv->write_reg = sja1000_isa_port_write_reg_indirect;
+			spin_lock_init(&indirect_lock[idx]);
 		} else {
 			priv->read_reg = sja1000_isa_port_read_reg;
 			priv->write_reg = sja1000_isa_port_write_reg;
@@ -198,6 +207,7 @@ static int sja1000_isa_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
+	dev->dev_id = idx;
 
 	err = register_sja1000dev(dev);
 	if (err) {
-- 
1.9.0.279.gdc9e3eb
