From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 9/9] KS8851: Add platform data to specific IRQ trigger type.
Date: Mon, 07 Dec 2009 12:17:36 +0000
Message-ID: <20091207121828.749915806@fluff.org.uk>
References: <20091207121727.016092171@fluff.org.uk>
Cc: linux@simtec.co.uk, doong.ping@micrel.com, tristram.ha@micrel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:48546 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755881AbZLGMSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 07:18:22 -0500
Content-Disposition: inline; filename=ks8851-add-platform-data.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add platform data to allow the board registering the SPI device to
pass what IRQ trigger type it needs to the driver. The default of
low-level trigger is used if no data is specified, or the field is
zero.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
 drivers/net/ks8851.c   |   27 +++++++++++++++++++++++----
 include/linux/ks8851.h |   23 +++++++++++++++++++++++
 2 files changed, 46 insertions(+), 4 deletions(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2009-12-07 11:47:13.000000000 +0000
+++ b/drivers/net/ks8851.c	2009-12-07 11:58:01.000000000 +0000
@@ -20,6 +20,7 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/eeprom_93cx6.h>
+#include <linux/ks8851.h>
 
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
@@ -70,6 +71,7 @@ struct ks8851_rxctrl {
  * @rc_ccr: Cached copy of KS_CCR.
  * @rc_rxqcr: Cached copy of KS_RXQCR.
  * @eeprom: 93CX6 EEPROM state for accessing on-board EEPROM.
+ * @irq_flags: The IRQ flags passed to request_irq().
  *
  * The @lock ensures that the chip is protected when certain operations are
  * in progress. When the read or write packet transfer is in progress, most
@@ -412,6 +414,15 @@ static void ks8851_init_mac(struct ks885
 }
 
 /**
+ * is_level_irq() - return if the given IRQ flags are level triggered
+ * @flags: The flags passed to request_irq().
+*/
+static bool is_level_irq(unsigned flags)
+{
+	return flags & (IRQF_TIRGGER_LOW | IRQF_TRIGGER_HIGH);
+}
+
+/**
  * ks8851_irq - device interrupt handler
  * @irq: Interrupt number passed from the IRQ hnalder.
  * @pw: The private word passed to register_irq(), our struct ks8851_net.
@@ -423,7 +434,9 @@ static irqreturn_t ks8851_irq(int irq, v
 {
 	struct ks8851_net *ks = pw;
 
-	disable_irq_nosync(irq);
+	if (is_level_irq(ks->irq_flags))
+		disable_irq_nosync(irq);
+
 	schedule_work(&ks->irq_work);
 	return IRQ_HANDLED;
 }
@@ -637,7 +650,8 @@ static void ks8851_irq_work(struct work_
 
 	mutex_unlock(&ks->lock);
 
-	enable_irq(ks->netdev->irq);
+	if (is_level_irq(ks->irq_flags))
+		enable_irq(ks->netdev->irq);
 }
 
 /**
@@ -1456,6 +1470,7 @@ static void __devexit ks8851_delete_debu
 
 static int __devinit ks8851_probe(struct spi_device *spi)
 {
+	struct ks8851_pdata *pd = spi->dev.platform_data;
 	struct net_device *ndev;
 	struct ks8851_net *ks;
 	int ret;
@@ -1542,8 +1557,12 @@ static int __devinit ks8851_probe(struct
 	ks8851_init_mac(ks);
 	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
 
-	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
-			  ndev->name, ks);
+	if (pd && pd->irq_flags)
+		ks->irq_flags = pd->irq_flags;
+	else
+		ks->irq_flags = IRQF_TRIGGER_LOW;
+
+	ret = request_irq(spi->irq, ks8851_irq, ks->irq_flags, ndev->name, ks);
 	if (ret < 0) {
 		dev_err(&spi->dev, "failed to get irq\n");
 		goto err_irq;
Index: b/include/linux/ks8851.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/include/linux/ks8851.h	2009-12-07 11:53:54.000000000 +0000
@@ -0,0 +1,23 @@
+/* include/linux/ks8851.h
+ *
+ * Platform specific configuration data for KS8851 driver.
+ *
+ * Copyright 2009 Simtec Electronics
+ *	http://www.simtec.co.uk/
+ *	Ben Dooks <ben@simtec.co.uk>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/**
+ * struct ks8851_pdata - platform specific configuration data
+ * @irq_flags: The IRQ trigger flags to pass to request_irq().
+ *
+ * Platform specific configuration to be passed from board support
+ * registering the spi device to the driver.
+ */
+struct ks8851_pdata {
+	unsigned	irq_flags;
+};

