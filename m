From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 1/2] net: Use device model to get driver name in
 skb_gso_segment()
Date: Mon, 16 Jan 2012 22:38:59 +0000
Message-ID: <1326753539.3065.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6746 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750834Ab2APWjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 17:39:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool operations generally require the caller to hold RTNL and are
not safe to call in atomic context.  The device model provides this
information for most devices; we'll only lose it for some old ISA
drivers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f494675..7e6b7dc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1962,13 +1962,13 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 
 	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
 		struct net_device *dev = skb->dev;
-		struct ethtool_drvinfo info = {};
+		const char *driver = "";
 
-		if (dev && dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
-			dev->ethtool_ops->get_drvinfo(dev, &info);
+		if (dev && dev->dev.parent)
+			driver = dev_driver_string(dev->dev.parent);
 
 		WARN(1, "%s: caps=(%pNF, %pNF) len=%d data_len=%d ip_summed=%d\n",
-		     info.driver, dev ? &dev->features : NULL,
+		     driver, dev ? &dev->features : NULL,
 		     skb->sk ? &skb->sk->sk_route_caps : NULL,
 		     skb->len, skb->data_len, skb->ip_summed);
 
-- 
1.7.7.5
