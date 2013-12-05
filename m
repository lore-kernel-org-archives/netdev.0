From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/16] gianfar: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:53:22 +0000
Message-ID: <1386287602.1516.136.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6665 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab3LEXx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:53:26 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is untested.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index b14d7904a075..365342d293e8 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -795,8 +795,7 @@ err_grp_init:
 	return err;
 }
 
-static int gfar_hwtstamp_ioctl(struct net_device *netdev,
-			       struct ifreq *ifr, int cmd)
+static int gfar_hwtstamp_set(struct net_device *netdev, struct ifreq *ifr)
 {
 	struct hwtstamp_config config;
 	struct gfar_private *priv = netdev_priv(netdev);
@@ -845,7 +844,20 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
 		-EFAULT : 0;
 }
 
-/* Ioctl MII Interface */
+static int gfar_hwtstamp_get(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct hwtstamp_config config;
+	struct gfar_private *priv = netdev_priv(netdev);
+
+	config.flags = 0;
+	config.tx_type = priv->hwts_tx_en ? HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	config.rx_filter = (priv->hwts_rx_en ?
+			    HWTSTAMP_FILTER_ALL : HWTSTAMP_FILTER_NONE);
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -854,7 +866,9 @@ static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		return -EINVAL;
 
 	if (cmd == SIOCSHWTSTAMP)
-		return gfar_hwtstamp_ioctl(dev, rq, cmd);
+		return gfar_hwtstamp_set(dev, rq);
+	if (cmd == SIOCGHWTSTAMP)
+		return gfar_hwtstamp_get(dev, rq);
 
 	if (!priv->phydev)
 		return -ENODEV;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
