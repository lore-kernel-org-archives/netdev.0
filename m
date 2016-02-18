From: zopieux <web@zopieux.com>
Subject: [PATCH] mrf24j40: fix security-enabled processing on inbound frames
Date: Thu, 18 Feb 2016 19:34:34 +0100
Message-ID: <56C60EBA.2070707@zopieux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alan Ott <alan@signal11.us>,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from r0.smtpout1.alwaysdata.com ([176.31.58.0]:60173 "EHLO
	r0.smtpout1.alwaysdata.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946703AbcBRSuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 13:50:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the MRF24J40 handling of security-enabled frames so it does not
block upon receiving such frames.

Signed-off-by: Alexander Aring <aar@pengutronix.de>
Reported-by: Alexandre Macabies <web+oss@zopieux.com>
Tested-by: Alexandre Macabies <web+oss@zopieux.com>
---
When receiving a security-enabled IEEE 802.15.4 frame, the MRF24J40
triggers a SECIF interrupt that needs to be handled for RX processing
to keep functioning properly.

This patch enables the SECIF interrupt and makes the MRF ignores all
hardware processing of security-enabled frames, that is handled by the
ieee802154 stack instead.
---
 drivers/net/ieee802154/mrf24j40.c | 11 ++++++++++-
 include/linux/ieee802154.h        | 10 ++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 4cdf516..fdfdcec 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -61,6 +61,7 @@
 #define REG_TXBCON0	0x1A
 #define REG_TXNCON	0x1B  /* Transmit Normal FIFO Control */
 #define BIT_TXNTRIG	BIT(0)
+#define BIT_TXNSECEN	BIT(1)
 #define BIT_TXNACKREQ	BIT(2)
 
 #define REG_TXG1CON	0x1C
@@ -85,10 +86,12 @@
 #define REG_INTSTAT	0x31  /* Interrupt Status */
 #define BIT_TXNIF	BIT(0)
 #define BIT_RXIF	BIT(3)
+#define BIT_SECIF	BIT(4)
 
 #define REG_INTCON	0x32  /* Interrupt Control */
 #define BIT_TXNIE	BIT(0)
 #define BIT_RXIE	BIT(3)
+#define BIT_SECIE	BIT(4)
 
 #define REG_GPIO	0x33  /* GPIO */
 #define REG_TRISGPIO	0x34  /* GPIO direction */
@@ -547,6 +550,9 @@ static void write_tx_buf_complete(void *context)
 	u8 val = BIT_TXNTRIG;
 	int ret;
 
+	if (ieee802154_is_secen(fc))
+		val |= BIT_TXNSECEN;
+
 	if (ieee802154_is_ackreq(fc))
 		val |= BIT_TXNACKREQ;
 
@@ -615,7 +621,7 @@ static int mrf24j40_start(struct ieee802154_hw *hw)
 
 	/* Clear TXNIE and RXIE. Enable interrupts */
 	return regmap_update_bits(devrec->regmap_short, REG_INTCON,
-				  BIT_TXNIE | BIT_RXIE, 0);
+				  BIT_TXNIE | BIT_RXIE | BIT_SECIE, 0);
 }
 
 static void mrf24j40_stop(struct ieee802154_hw *hw)
@@ -1024,6 +1030,9 @@ static void mrf24j40_intstat_complete(void *context)
 
 	enable_irq(devrec->spi->irq);
 
+	if (intstat & BIT_SECIF)
+		regmap_write_async(devrec->regmap_short, REG_SECCON0, 0x80);
+
 	/* Check for TX complete */
 	if (intstat & BIT_TXNIF)
 		ieee802154_xmit_complete(devrec->hw, devrec->tx_skb, false);
diff --git a/include/linux/ieee802154.h b/include/linux/ieee802154.h
index d3e4156..334fb1e 100644
--- a/include/linux/ieee802154.h
+++ b/include/linux/ieee802154.h
@@ -218,6 +218,7 @@ enum {
 /* frame control handling */
 #define IEEE802154_FCTL_FTYPE		0x0003
 #define IEEE802154_FCTL_ACKREQ		0x0020
+#define IEEE802154_FCTL_SECEN		0x0004
 #define IEEE802154_FCTL_INTRA_PAN	0x0040
 
 #define IEEE802154_FTYPE_DATA		0x0001
@@ -233,6 +234,15 @@ static inline int ieee802154_is_data(__le16 fc)
 }
 
 /**
+ * ieee802154_is_secen - check if Security bit is set
+ * @fc: frame control bytes in little-endian byteorder
+ */
+static inline bool ieee802154_is_secen(__le16 fc)
+{
+	return fc & cpu_to_le16(IEEE802154_FCTL_SECEN);
+}
+
+/**
  * ieee802154_is_ackreq - check if acknowledgment request bit is set
  * @fc: frame control bytes in little-endian byteorder
  */
-- 
2.1.4
