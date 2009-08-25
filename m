From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/12] tg3: Tune 5785 clock switching
Date: Tue, 25 Aug 2009 13:09:07 -0700
Message-ID: <1251232429.25409@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4225 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109AbZHYUeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tunes the timeouts the CPMU uses to decide when to switch
from the clocks output by the PHY to internal clock sources.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   15 ++++++++++-----
 drivers/net/tg3.h |    4 ++++
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9ae3320..41e0d40 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -917,7 +917,9 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 		tw32(MAC_PHYCFG2, val);
 
 		val = tr32(MAC_PHYCFG1);
-		val &= ~MAC_PHYCFG1_RGMII_INT;
+		val &= ~(MAC_PHYCFG1_RGMII_INT |
+			 MAC_PHYCFG1_RXCLK_TO_MASK | MAC_PHYCFG1_TXCLK_TO_MASK);
+		val |= MAC_PHYCFG1_RXCLK_TIMEOUT | MAC_PHYCFG1_TXCLK_TIMEOUT;
 		tw32(MAC_PHYCFG1, val);
 
 		return;
@@ -933,15 +935,18 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 
 	tw32(MAC_PHYCFG2, val);
 
-	val = tr32(MAC_PHYCFG1) & ~(MAC_PHYCFG1_RGMII_EXT_RX_DEC |
-				    MAC_PHYCFG1_RGMII_SND_STAT_EN);
-	if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE) {
+	val = tr32(MAC_PHYCFG1);
+	val &= ~(MAC_PHYCFG1_RXCLK_TO_MASK | MAC_PHYCFG1_TXCLK_TO_MASK |
+		 MAC_PHYCFG1_RGMII_EXT_RX_DEC | MAC_PHYCFG1_RGMII_SND_STAT_EN);
+	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)) {
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
 			val |= MAC_PHYCFG1_RGMII_EXT_RX_DEC;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
 			val |= MAC_PHYCFG1_RGMII_SND_STAT_EN;
 	}
-	tw32(MAC_PHYCFG1, val | MAC_PHYCFG1_RGMII_INT | MAC_PHYCFG1_TXC_DRV);
+	val |= MAC_PHYCFG1_RXCLK_TIMEOUT | MAC_PHYCFG1_TXCLK_TIMEOUT |
+	       MAC_PHYCFG1_RGMII_INT | MAC_PHYCFG1_TXC_DRV;
+	tw32(MAC_PHYCFG1, val);
 
 	val = tr32(MAC_EXT_RGMII_MODE);
 	val &= ~(MAC_RGMII_MODE_RX_INT_B |
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 636008c..d096e10 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -524,6 +524,10 @@
 /* 0x598 --> 0x5a0 unused */
 #define MAC_PHYCFG1			0x000005a0
 #define  MAC_PHYCFG1_RGMII_INT		 0x00000001
+#define  MAC_PHYCFG1_RXCLK_TO_MASK	 0x00001ff0
+#define  MAC_PHYCFG1_RXCLK_TIMEOUT	 0x00001000
+#define  MAC_PHYCFG1_TXCLK_TO_MASK	 0x01ff0000
+#define  MAC_PHYCFG1_TXCLK_TIMEOUT	 0x01000000
 #define  MAC_PHYCFG1_RGMII_EXT_RX_DEC	 0x02000000
 #define  MAC_PHYCFG1_RGMII_SND_STAT_EN	 0x04000000
 #define  MAC_PHYCFG1_TXC_DRV		 0x20000000
-- 
1.6.3.3


