From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/4] net: systemport: Set correct RSB endian bits based on host
Date: Tue, 29 Aug 2017 13:35:17 -0700
Message-ID: <1504038918-49254-4-git-send-email-f.fainelli@gmail.com>
References: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:38882 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdH2UlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:41:22 -0400
Received: by mail-qt0-f194.google.com with SMTP id d15so3751822qta.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:41:21 -0700 (PDT)
In-Reply-To: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RSB_SWAP0 needs to match the host CPU endian, and it needs to be set
for LE and clear for BE. RSB_SWAP1 must always be cleared for SYSTEMPORT
Lite.

With these settings, we have the Receive Status Block always match the
host endian and we do not need to perform any conversion. Since there is
not necessarily a CONFIG_CPU_LITTLE_ENDIAN option defined, we test for
!CONFIG_CPU_BIG_ENDIAN which is guaranteed to be set.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index a7e84292af50..931751e4f369 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1762,10 +1762,14 @@ static void rbuf_init(struct bcm_sysport_priv *priv)
 	reg = rbuf_readl(priv, RBUF_CONTROL);
 	reg |= RBUF_4B_ALGN | RBUF_RSB_EN;
 	/* Set a correct RSB format on SYSTEMPORT Lite */
-	if (priv->is_lite) {
+	if (priv->is_lite)
 		reg &= ~RBUF_RSB_SWAP1;
+
+	/* Set a correct RSB format based on host endian */
+	if (!IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
 		reg |= RBUF_RSB_SWAP0;
-	}
+	else
+		reg &= ~RBUF_RSB_SWAP0;
 	rbuf_writel(priv, reg, RBUF_CONTROL);
 }
 
-- 
1.9.1
