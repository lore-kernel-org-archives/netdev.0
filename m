From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 06/13] KSZ8851-SNL: Fix MAC address change problem
Date: Fri, 30 Apr 2010 00:16:27 +0100
Message-ID: <20100429231740.114858742@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com,
	Tristram Ha <Tristram.Ha@micrel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932398Ab0D3Vs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:26 -0400
Content-Disposition: inline; filename=thirdparty/micrel/ksz8851-fix-mac.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tristram Ha <Tristram.Ha@micrel.com>

When device is off it is under power saving mode. Changing the MAC address
in that situation will result in the device not communicating as the first
write to the MAC address register is not executed.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
[ben@simtec.co.uk: cleaned up header]
Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
---
 drivers/net/ks8851.c |   30 ++++++++++++++++++++++++++++--
 drivers/net/ks8851.h |    2 +-
 2 files changed, 29 insertions(+), 3 deletions(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-29 01:00:15.519525666 +0900
+++ b/drivers/net/ks8851.c	2010-04-29 01:01:31.118391091 +0900
@@ -345,6 +345,26 @@ static void ks8851_soft_reset(struct ks8
 }
 
 /**
+ * ks8851_set_powermode - set power mode of the device
+ * @ks: The device state
+ * @pwrmode: The power mode value to write to KS_PMECR.
+ *
+ * Change the power mode of the chip.
+ */
+static void ks8851_set_powermode(struct ks8851_net *ks, unsigned pwrmode)
+{
+	unsigned pmecr;
+
+	netif_dbg(ks, hw, ks->netdev, "setting power mode %d\n", pwrmode);
+
+	pmecr = ks8851_rdreg16(ks, KS_PMECR);
+	pmecr &= ~PMECR_PM_MASK;
+	pmecr |= pwrmode;
+
+	ks8851_wrreg16(ks, KS_PMECR, pmecr);
+}
+
+/**
  * ks8851_write_mac_addr - write mac address to device registers
  * @dev: The network device
  *
@@ -360,8 +380,15 @@ static int ks8851_write_mac_addr(struct 
 
 	mutex_lock(&ks->lock);
 
+	/*
+	 * Wake up chip in case it was powered off when stopped; otherwise,
+	 * the first write to the MAC address does not take effect.
+	 */
+	ks8851_set_powermode(ks, PMECR_PM_NORMAL);
 	for (i = 0; i < ETH_ALEN; i++)
 		ks8851_wrreg8(ks, KS_MAR(i), dev->dev_addr[i]);
+	if (!netif_running(dev))
+		ks8851_set_powermode(ks, PMECR_PM_SOFTDOWN);
 
 	mutex_unlock(&ks->lock);
 
@@ -1260,7 +1287,6 @@ static int __devinit ks8851_probe(struct
 
 	ks->netdev = ndev;
 	ks->spidev = spi;
-	ks->tx_space = 6144;
 
 	mutex_init(&ks->lock);
 	spin_lock_init(&ks->statelock);
@@ -1318,10 +1344,10 @@ static int __devinit ks8851_probe(struct
 
   	/* cache the contents of the CCR register for EEPROM, etc. */
   	ks->rc_ccr = ks8851_rdreg16(ks, KS_CCR);
+	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
 
 	ks8851_read_selftest(ks);
 	ks8851_init_mac(ks);
-	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
 
 	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
 			  ndev->name, ks);
Index: b/drivers/net/ks8851.h
===================================================================
--- a/drivers/net/ks8851.h	2010-04-28 23:24:20.647026644 +0900
+++ b/drivers/net/ks8851.h	2010-04-29 01:00:35.029526937 +0900
@@ -16,7 +16,7 @@
 #define CCR_32PIN				(1 << 0)
 
 /* MAC address registers */
-#define KS_MAR(_m)				0x15 - (_m)
+#define KS_MAR(_m)				(0x15 - (_m))
 #define KS_MARL					0x10
 #define KS_MARM					0x12
 #define KS_MARH					0x14

