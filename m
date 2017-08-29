From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: systemport: Set correct RSB endian bits based on host
Date: Tue, 29 Aug 2017 11:39:44 -0700
Message-ID: <1504031985-52808-4-git-send-email-f.fainelli@gmail.com>
References: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34949 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbdH2SqH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 14:46:07 -0400
Received: by mail-wm0-f68.google.com with SMTP id e204so1904589wma.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 11:46:06 -0700 (PDT)
In-Reply-To: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LE CPU:
* set RSB_SWAP0 (both SYSTEMPORT and SYSTEMPORT Lite)
* clear RSB_SWAP1 (SYSTEMPORT Lite only)

BE CPU:
* clear RSB_SWAP0 (both SYSTEMPORT and SYSTEMPORTE lite)
* set RSB_SWAP1 (SYSTEMPORT Lite only)

With these settings, we have the Receive Status Block always match the
host endian and we do not need to perform any conversion.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index a7e84292af50..7c7558a6b720 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1762,9 +1762,14 @@ static void rbuf_init(struct bcm_sysport_priv *priv)
 	reg = rbuf_readl(priv, RBUF_CONTROL);
 	reg |= RBUF_4B_ALGN | RBUF_RSB_EN;
 	/* Set a correct RSB format on SYSTEMPORT Lite */
-	if (priv->is_lite) {
-		reg &= ~RBUF_RSB_SWAP1;
+	if (!IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)) {
+		if (priv->is_lite)
+			reg &= ~RBUF_RSB_SWAP1;
 		reg |= RBUF_RSB_SWAP0;
+	} else {
+		if (priv->is_lite)
+			reg |= RBUF_RSB_SWAP1;
+		reg &= ~RBUF_RSB_SWAP0;
 	}
 	rbuf_writel(priv, reg, RBUF_CONTROL);
 }
-- 
1.9.1
