From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 05/13] KSZ8851-SNL: Add support for EEPROM MAC address
Date: Fri, 30 Apr 2010 00:16:26 +0100
Message-ID: <20100429231739.992421136@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932353Ab0D3VsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:24 -0400
Content-Disposition: inline; filename=ks8851-mac-from-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading the MAC address from the system registers if there
is an EEPROM present. This involves caching the KS_CCR register for later
use (will also be useful for ETHTOOL support) and adding a print to say
that there is an EEPROM present.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---

---
 drivers/net/ks8851.c |   46 +++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 39 insertions(+), 7 deletions(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-29 00:51:12.489525834 +0900
+++ b/drivers/net/ks8851.c	2010-04-29 00:52:02.377026762 +0900
@@ -76,6 +76,7 @@ union ks8851_tx_hdr {
  * @msg_enable: The message flags controlling driver output (see ethtool).
  * @fid: Incrementing frame id tag.
  * @rc_ier: Cached copy of KS_IER.
+ * @rc_ccr: Cached copy of KS_CCR.
  * @rc_rxqcr: Cached copy of KS_RXQCR.
  *
  * The @lock ensures that the chip is protected when certain operations are
@@ -107,6 +108,7 @@ struct ks8851_net {
 
 	u16			rc_ier;
 	u16			rc_rxqcr;
+	u16			rc_ccr;
 
 	struct mii_if_info	mii;
 	struct ks8851_rxctrl	rxctrl;
@@ -367,21 +369,47 @@ static int ks8851_write_mac_addr(struct 
 }
 
 /**
+ * ks8851_read_mac_addr - read mac address from device registers
+ * @dev: The network device
+ *
+ * Update our copy of the KS8851 MAC address from the registers of @dev.
+*/
+static void ks8851_read_mac_addr(struct net_device *dev)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	int i;
+
+	mutex_lock(&ks->lock);
+
+	for (i = 0; i < ETH_ALEN; i++)
+		dev->dev_addr[i] = ks8851_rdreg8(ks, KS_MAR(i));
+
+	mutex_unlock(&ks->lock);
+}
+
+/**
  * ks8851_init_mac - initialise the mac address
  * @ks: The device structure
  *
  * Get or create the initial mac address for the device and then set that
- * into the station address register. Currently we assume that the device
- * does not have a valid mac address in it, and so we use random_ether_addr()
+ * into the station address register. If there is an EEPROM present, then
+ * we try that. If no valid mac address is found we use random_ether_addr()
  * to create a new one.
- *
- * In future, the driver should check to see if the device has an EEPROM
- * attached and whether that has a valid ethernet address in it.
  */
 static void ks8851_init_mac(struct ks8851_net *ks)
 {
 	struct net_device *dev = ks->netdev;
 
+	/* first, try reading what we've got already */
+	if (ks->rc_ccr & CCR_EEPROM) {
+		ks8851_read_mac_addr(dev);
+		if (is_valid_ether_addr(dev->dev_addr))
+			return;
+
+		ks_err(ks, "invalid mac address read %pM\n",
+			dev->dev_addr);
+	}
+
 	random_ether_addr(dev->dev_addr);
 	ks8851_write_mac_addr(dev);
 }
@@ -1288,6 +1316,9 @@ static int __devinit ks8851_probe(struct
 		goto err_id;
 	}
 
+  	/* cache the contents of the CCR register for EEPROM, etc. */
+  	ks->rc_ccr = ks8851_rdreg16(ks, KS_CCR);
+
 	ks8851_read_selftest(ks);
 	ks8851_init_mac(ks);
 	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
@@ -1305,9 +1336,10 @@ static int __devinit ks8851_probe(struct
 		goto err_netdev;
 	}
 
-	dev_info(&spi->dev, "revision %d, MAC %pM, IRQ %d\n",
+	dev_info(&spi->dev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
 		 CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
-		 ndev->dev_addr, ndev->irq);
+		 ndev->dev_addr, ndev->irq,
+		 ks->rc_ccr & CCR_EEPROM ? "has" : "no");
 
 	return 0;
 

