From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 V2] tg3: 64 bit stats on all arches
Date: Thu, 08 Jul 2010 08:44:24 +0200
Message-ID: <1278571464.2543.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34044 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab0GHGo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 02:44:29 -0400
Received: by wwb24 with SMTP id 24so3524819wwb.1
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 23:44:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now core network is able to handle 64 bit netdevice stats on 32 bit
arches, we can provide them for tg3, since hardware maintains 64 bit
counters.

I'll provide bnx2 and bnx2x patches as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/tg3.c |   35 ++++++++++++-----------------------
 drivers/net/tg3.h |    4 ++--
 2 files changed, 14 insertions(+), 25 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 289cdc5..7c75f1e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9021,7 +9021,8 @@ err_out1:
 	return err;
 }
 
-static struct net_device_stats *tg3_get_stats(struct net_device *);
+static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *,
+						 struct rtnl_link_stats64 *);
 static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *);
 
 static int tg3_close(struct net_device *dev)
@@ -9055,8 +9056,8 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_ints_fini(tp);
 
-	memcpy(&tp->net_stats_prev, tg3_get_stats(tp->dev),
-	       sizeof(tp->net_stats_prev));
+	tg3_get_stats64(tp->dev, &tp->net_stats_prev);
+
 	memcpy(&tp->estats_prev, tg3_get_estats(tp),
 	       sizeof(tp->estats_prev));
 
@@ -9069,24 +9070,12 @@ static int tg3_close(struct net_device *dev)
 	return 0;
 }
 
-static inline unsigned long get_stat64(tg3_stat64_t *val)
-{
-	unsigned long ret;
-
-#if (BITS_PER_LONG == 32)
-	ret = val->low;
-#else
-	ret = ((u64)val->high << 32) | ((u64)val->low);
-#endif
-	return ret;
-}
-
-static inline u64 get_estat64(tg3_stat64_t *val)
+static inline u64 get_stat64(tg3_stat64_t *val)
 {
        return ((u64)val->high << 32) | ((u64)val->low);
 }
 
-static unsigned long calc_crc_errors(struct tg3 *tp)
+static u64 calc_crc_errors(struct tg3 *tp)
 {
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
@@ -9114,7 +9103,7 @@ static unsigned long calc_crc_errors(struct tg3 *tp)
 
 #define ESTAT_ADD(member) \
 	estats->member =	old_estats->member + \
-				get_estat64(&hw_stats->member)
+				get_stat64(&hw_stats->member)
 
 static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp)
 {
@@ -9204,11 +9193,11 @@ static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp)
 	return estats;
 }
 
-static struct net_device_stats *tg3_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
+						 struct rtnl_link_stats64 *stats)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	struct net_device_stats *stats = &tp->net_stats;
-	struct net_device_stats *old_stats = &tp->net_stats_prev;
+	struct rtnl_link_stats64 *old_stats = &tp->net_stats_prev;
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
 	if (!hw_stats)
@@ -14317,7 +14306,7 @@ static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_open		= tg3_open,
 	.ndo_stop		= tg3_close,
 	.ndo_start_xmit		= tg3_start_xmit,
-	.ndo_get_stats		= tg3_get_stats,
+	.ndo_get_stats64	= tg3_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= tg3_set_rx_mode,
 	.ndo_set_mac_address	= tg3_set_mac_addr,
@@ -14336,7 +14325,7 @@ static const struct net_device_ops tg3_netdev_ops_dma_bug = {
 	.ndo_open		= tg3_open,
 	.ndo_stop		= tg3_close,
 	.ndo_start_xmit		= tg3_start_xmit_dma_bug,
-	.ndo_get_stats		= tg3_get_stats,
+	.ndo_get_stats64	= tg3_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= tg3_set_rx_mode,
 	.ndo_set_mac_address	= tg3_set_mac_addr,
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6b6af76..b72ac52 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2772,8 +2772,8 @@ struct tg3 {
 
 
 	/* begin "everything else" cacheline(s) section */
-	struct net_device_stats		net_stats;
-	struct net_device_stats		net_stats_prev;
+	struct rtnl_link_stats64	net_stats;
+	struct rtnl_link_stats64	net_stats_prev;
 	struct tg3_ethtool_stats	estats;
 	struct tg3_ethtool_stats	estats_prev;
 


