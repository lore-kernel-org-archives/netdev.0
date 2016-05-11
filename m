From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next 2/4] net: w5100: fix MAC filtering for W5500
Date: Wed, 11 May 2016 15:30:25 +0900
Message-ID: <1462948227-21276-3-git-send-email-akinobu.mita@gmail.com>
References: <1462948227-21276-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35331 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbcEKGan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 02:30:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id r187so3592413pfr.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 23:30:42 -0700 (PDT)
In-Reply-To: <1462948227-21276-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W5500 has different bit position for MAC filter in Socket n mode
register from W5100 and W5200.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/wiznet/w5100.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 56ceed9..c80438c 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -63,8 +63,9 @@ MODULE_LICENSE("GPL");
 #define S0_REGS(priv)		((priv)->s0_regs)
 
 #define W5100_S0_MR(priv)	(S0_REGS(priv) + W5100_Sn_MR)
-#define   S0_MR_MACRAW		  0x04 /* MAC RAW mode (promiscuous) */
-#define   S0_MR_MACRAW_MF	  0x44 /* MAC RAW mode (filtered) */
+#define   S0_MR_MACRAW		  0x04 /* MAC RAW mode */
+#define   S0_MR_MF		  0x40 /* MAC Filter for W5100 and W5200 */
+#define   W5500_S0_MR_MF	  0x80 /* MAC Filter for W5500 */
 #define W5100_S0_CR(priv)	(S0_REGS(priv) + W5100_Sn_CR)
 #define   S0_CR_OPEN		  0x01 /* OPEN command */
 #define   S0_CR_CLOSE		  0x10 /* CLOSE command */
@@ -702,8 +703,16 @@ static int w5100_hw_reset(struct w5100_priv *priv)
 
 static void w5100_hw_start(struct w5100_priv *priv)
 {
-	w5100_write(priv, W5100_S0_MR(priv), priv->promisc ?
-			  S0_MR_MACRAW : S0_MR_MACRAW_MF);
+	u8 mode = S0_MR_MACRAW;
+
+	if (!priv->promisc) {
+		if (priv->ops->chip_id == W5500)
+			mode |= W5500_S0_MR_MF;
+		else
+			mode |= S0_MR_MF;
+	}
+
+	w5100_write(priv, W5100_S0_MR(priv), mode);
 	w5100_command(priv, S0_CR_OPEN);
 	w5100_enable_intr(priv);
 }
-- 
2.7.4
