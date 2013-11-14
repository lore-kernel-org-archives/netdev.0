From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 6/6] ixp4xx_eth: Validate hwtstamp_config completely
 before applying it
Date: Thu, 14 Nov 2013 00:48:56 +0000
Message-ID: <1384390136.29151.14.camel@bwh-desktop.uk.level5networks.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15195 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab3KNAs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 19:48:59 -0500
In-Reply-To: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hwtstamp_ioctl() should validate all fields of hwtstamp_config
before making any changes.  Currently it sets the TX configuration
before validating the rx_filter field.

Untested as I don't have a cross-compiler to hand.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index e78802e75ea6..bcc224a83734 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -389,16 +389,8 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	ch = PORT2CHANNEL(port);
 	regs = (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_BASE_VIRT;
 
-	switch (cfg.tx_type) {
-	case HWTSTAMP_TX_OFF:
-		port->hwts_tx_en = 0;
-		break;
-	case HWTSTAMP_TX_ON:
-		port->hwts_tx_en = 1;
-		break;
-	default:
+	if (cfg.tx_type != HWTSTAMP_TX_OFF && cfg.tx_type != HWTSTAMP_TX_ON)
 		return -ERANGE;
-	}
 
 	switch (cfg.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
@@ -416,6 +408,8 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 		return -ERANGE;
 	}
 
+	port->hwts_tx_en = cfg.tx_type == HWTSTAMP_TX_ON;
+
 	/* Clear out any old time stamps. */
 	__raw_writel(TX_SNAPSHOT_LOCKED | RX_SNAPSHOT_LOCKED,
 		     &regs->channel[ch].ch_event);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
