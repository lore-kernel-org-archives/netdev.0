From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/16] tile_net: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:57:14 +0000
Message-ID: <1386287834.1516.141.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Chris Metcalf <cmetcalf@tilera.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6790 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242Ab3LEX5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:57:18 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only (thanks to the kbuild test robot).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/tile/tilegx.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 628b736e5ae7..858f9a786b8c 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -481,8 +481,7 @@ static void tile_tx_timestamp(struct sk_buff *skb, int instance)
 }
 
 /* Use ioctl() to enable or disable TX or RX timestamping. */
-static int tile_hwtstamp_ioctl(struct net_device *dev, struct ifreq *rq,
-			       int cmd)
+static int tile_hwtstamp_set(struct net_device *dev, struct ifreq *rq)
 {
 #ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	struct hwtstamp_config config;
@@ -535,6 +534,21 @@ static int tile_hwtstamp_ioctl(struct net_device *dev, struct ifreq *rq,
 #endif
 }
 
+static int tile_hwtstamp_get(struct net_device *dev, struct ifreq *rq)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	if (copy_to_user(rq->ifr_data, &priv->stamp_cfg,
+			 sizeof(priv->stamp_cfg)))
+		return -EFAULT;
+
+	return 0;
+#else
+	return -EOPNOTSUPP;
+#endif
+}
+
 static inline bool filter_packet(struct net_device *dev, void *buf)
 {
 	/* Filter packets received before we're up. */
@@ -2098,7 +2112,9 @@ static void tile_net_tx_timeout(struct net_device *dev)
 static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	if (cmd == SIOCSHWTSTAMP)
-		return tile_hwtstamp_ioctl(dev, rq, cmd);
+		return tile_hwtstamp_set(dev, rq);
+	if (cmd == SIOCGHWTSTAMP)
+		return tile_hwtstamp_get(dev, rq);
 
 	return -EOPNOTSUPP;
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
