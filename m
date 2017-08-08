From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: systemport: Fix software statistics for SYSTEMPORT Lite
Date: Tue,  8 Aug 2017 14:39:25 -0700
Message-ID: <20170808213925.26126-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33801 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752265AbdHHVjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 17:39:33 -0400
Received: by mail-wm0-f66.google.com with SMTP id x64so4760157wmg.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 14:39:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With SYSTEMPORT Lite we have holes in our statistics layout that make us
skip over the hardware MIB counters, bcm_sysport_get_stats() was not
taking that into account, resulting in reporting 0 for all SW-maintained
statistics, fix this by skipping accordingly.

Fixes: 44a4524c54af ("net: systemport: Add support for SYSTEMPORT Lite")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 5333601f855f..abf175372719 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -449,6 +449,10 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 			p = (char *)&dev->stats;
 		else
 			p = (char *)priv;
+
+		if (priv->is_lite && !bcm_sysport_lite_stat_valid(s->type))
+			continue;
+
 		p += s->stat_offset;
 		data[j] = *(unsigned long *)p;
 		j++;
@@ -608,8 +612,8 @@ static struct sk_buff *bcm_sysport_rx_refill(struct bcm_sysport_priv *priv,
 
 	/* Allocate a new SKB for a new packet */
 	skb = netdev_alloc_skb(priv->netdev, RX_BUF_LENGTH);
+	priv->mib.alloc_rx_buff_failed++;
 	if (!skb) {
-		priv->mib.alloc_rx_buff_failed++;
 		netif_err(priv, rx_err, ndev, "SKB alloc failed\n");
 		return NULL;
 	}
-- 
2.9.3
