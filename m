From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/16] ixp4xx_eth: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:57:51 +0000
Message-ID: <1386287871.1516.142.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6814 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab3LEX5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:57:55 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is untested.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c | 36 +++++++++++++++++++++++++++++---
 1 file changed, 33 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index bcc224a83734..25283f17d82f 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -373,7 +373,7 @@ static void ixp_tx_timestamp(struct port *port, struct sk_buff *skb)
 	__raw_writel(TX_SNAPSHOT_LOCKED, &regs->channel[ch].ch_event);
 }
 
-static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+static int hwtstamp_set(struct net_device *netdev, struct ifreq *ifr)
 {
 	struct hwtstamp_config cfg;
 	struct ixp46x_ts_regs *regs;
@@ -417,6 +417,32 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
 }
 
+static int hwtstamp_get(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct hwtstamp_config cfg;
+	struct port *port = netdev_priv(netdev);
+
+	cfg.flags = 0;
+	cfg.tx_type = port->hwts_tx_en ? HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+
+	switch (port->hwts_rx_en) {
+	case 0:
+		cfg.rx_filter = HWTSTAMP_FILTER_NONE;
+		break;
+	case PTP_SLAVE_MODE:
+		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_SYNC;
+		break;
+	case PTP_MASTER_MODE:
+		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ;
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		return -ERANGE;
+	}
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
+
 static int ixp4xx_mdio_cmd(struct mii_bus *bus, int phy_id, int location,
 			   int write, u16 cmd)
 {
@@ -959,8 +985,12 @@ static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (cpu_is_ixp46x() && cmd == SIOCSHWTSTAMP)
-		return hwtstamp_ioctl(dev, req, cmd);
+	if (cpu_is_ixp46x()) {
+		if (cmd == SIOCSHWTSTAMP)
+			return hwtstamp_set(dev, req);
+		if (cmd == SIOCGHWTSTAMP)
+			return hwtstamp_get(dev, req);
+	}
 
 	return phy_mii_ioctl(port->phydev, req, cmd);
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
