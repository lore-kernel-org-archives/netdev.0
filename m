From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 2/3] KS8851: Fix MAC address write order
Date: Tue, 20 Oct 2009 10:49:04 +0100
Message-ID: <20091020094954.442531232@fluff.org.uk>
References: <20091020094902.274646871@fluff.org.uk>
Cc: Ping.Doong@Micrel.Com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:50631 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751797AbZJTJtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 05:49:55 -0400
Content-Disposition: inline; filename=ks8851-fix-mac-order.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC address register was being written in the wrong order, so add
a new address macro to convert mac-address byte to register address and
a ks8851_wrreg8() function to write each byte without having to worry
about any difficult byte swapping.

Fixes a bug reported by Doong, Ping of Micrel.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
 drivers/net/ks8851.c |   39 ++++++++++++++++++++++++++++++++++-----
 drivers/net/ks8851.h |    1 +
 2 files changed, 35 insertions(+), 5 deletions(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2009-10-06 14:25:53.000000000 +0100
+++ b/drivers/net/ks8851.c	2009-10-06 14:42:39.000000000 +0100
@@ -171,6 +171,36 @@ static void ks8851_wrreg16(struct ks8851
 }
 
 /**
+ * ks8851_wrreg8 - write 8bit register value to chip
+ * @ks: The chip state
+ * @reg: The register address
+ * @val: The value to write
+ *
+ * Issue a write to put the value @val into the register specified in @reg.
+ */
+static void ks8851_wrreg8(struct ks8851_net *ks, unsigned reg, unsigned val)
+{
+	struct spi_transfer *xfer = &ks->spi_xfer1;
+	struct spi_message *msg = &ks->spi_msg1;
+	__le16 txb[2];
+	int ret;
+	int bit;
+
+	bit = 1 << (reg & 3);
+
+	txb[0] = cpu_to_le16(MK_OP(bit, reg) | KS_SPIOP_WR);
+	txb[1] = val;
+
+	xfer->tx_buf = txb;
+	xfer->rx_buf = NULL;
+	xfer->len = 3;
+
+	ret = spi_sync(ks->spidev, msg);
+	if (ret < 0)
+		ks_err(ks, "spi_sync() failed\n");
+}
+
+/**
  * ks8851_rx_1msg - select whether to use one or two messages for spi read
  * @ks: The device structure
  *
@@ -322,13 +352,12 @@ static void ks8851_soft_reset(struct ks8
 static int ks8851_write_mac_addr(struct net_device *dev)
 {
 	struct ks8851_net *ks = netdev_priv(dev);
-	u16 *mcp = (u16 *)dev->dev_addr;
+	int i;
 
 	mutex_lock(&ks->lock);
 
-	ks8851_wrreg16(ks, KS_MARL, mcp[0]);
-	ks8851_wrreg16(ks, KS_MARM, mcp[1]);
-	ks8851_wrreg16(ks, KS_MARH, mcp[2]);
+	for (i = 0; i < ETH_ALEN; i++)
+		ks8851_wrreg8(ks, KS_MAR(i), dev->dev_addr[i]);
 
 	mutex_unlock(&ks->lock);
 
Index: b/drivers/net/ks8851.h
===================================================================
--- a/drivers/net/ks8851.h	2009-10-06 14:34:32.000000000 +0100
+++ b/drivers/net/ks8851.h	2009-10-06 14:35:08.000000000 +0100
@@ -16,6 +16,7 @@
 #define CCR_32PIN				(1 << 0)
 
 /* MAC address registers */
+#define KS_MAR(_m)				0x15 - (_m)
 #define KS_MARL					0x10
 #define KS_MARM					0x12
 #define KS_MARH					0x14

