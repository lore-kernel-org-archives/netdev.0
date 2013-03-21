From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 3/3] gianfar: Remove superfluous kernel_dropped local counter
Date: Thu, 21 Mar 2013 15:12:15 +0200
Message-ID: <1363871535-29612-3-git-send-email-claudiu.manoil@freescale.com>
References: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:40467
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755823Ab3CUNMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 09:12:25 -0400
In-Reply-To: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GRO_DROP return code is handled by the core network layer.
The current kernel approach is to factorize this kind of statistics into
the upper layers, instead of having all the drivers maintaining them.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c         | 6 +-----
 drivers/net/ethernet/freescale/gianfar.h         | 1 -
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 1 -
 3 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 434b31b..96fbe35 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2695,8 +2695,6 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	struct gfar_private *priv = netdev_priv(dev);
 	struct rxfcb *fcb = NULL;
 
-	gro_result_t ret;
-
 	/* fcb is at the beginning if exists */
 	fcb = (struct rxfcb *)skb->data;
 
@@ -2735,10 +2733,8 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 		__vlan_hwaccel_put_tag(skb, fcb->vlctl);
 
 	/* Send the packet up the stack */
-	ret = napi_gro_receive(napi, skb);
+	napi_gro_receive(napi, skb);
 
-	if (unlikely(GRO_DROP == ret))
-		atomic64_inc(&priv->extra_stats.kernel_dropped);
 }
 
 /* gfar_clean_rx_ring() -- Processes each frame in the rx ring
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index eec87ea..04b552c 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -629,7 +629,6 @@ struct rmon_mib
 };
 
 struct gfar_extra_stats {
-	atomic64_t kernel_dropped;
 	atomic64_t rx_large;
 	atomic64_t rx_short;
 	atomic64_t rx_nonoctet;
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 8248df7..4e7118f 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -66,7 +66,6 @@ static void gfar_gdrvinfo(struct net_device *dev,
 			  struct ethtool_drvinfo *drvinfo);
 
 static const char stat_gstrings[][ETH_GSTRING_LEN] = {
-	"rx-dropped-by-kernel",
 	"rx-large-frame-errors",
 	"rx-short-frame-errors",
 	"rx-non-octet-errors",
-- 
1.7.11.3
