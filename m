From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 10:53:02 -0800
Message-ID: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Frank Li <Frank.Li@freescale.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:49814 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3LSSxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 13:53:05 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so1508503pbc.6
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 10:53:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_tx_timestamp(skb) should be called _before_ TX completion
has a chance to trigger, otherwise it is too late and we access
freed memory.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: de5fb0a05348 ("net: fec: put tx to napi poll function to fix dead lock")
Cc: Frank Li <Frank.Li@freescale.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e7c8b749c5a5..50bb71c663e2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -428,6 +428,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	/* If this was the last BD in the ring, start at the beginning again. */
 	bdp = fec_enet_get_nextdesc(bdp, fep);
 
+	skb_tx_timestamp(skb);
+
 	fep->cur_tx = bdp;
 
 	if (fep->cur_tx == fep->dirty_tx)
@@ -436,8 +438,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	/* Trigger transmission start */
 	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
-	skb_tx_timestamp(skb);
-
 	return NETDEV_TX_OK;
 }
 
