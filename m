From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 3/6] pch_gbe: Validate hwtstamp_config completely before
 applying it
Date: Thu, 14 Nov 2013 00:42:50 +0000
Message-ID: <1384389770.29151.9.camel@bwh-desktop.uk.level5networks.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53513 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3KNAmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 19:42:54 -0500
In-Reply-To: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hwtstamp_ioctl() should validate all fields of hwtstamp_config
before making any changes.  Currently it sets the TX configuration
before validating the rx_filter field.

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 5a0f04c2c813..27ffe0ebf0a6 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -245,16 +245,8 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	/* Get ieee1588's dev information */
 	pdev = adapter->ptp_pdev;
 
-	switch (cfg.tx_type) {
-	case HWTSTAMP_TX_OFF:
-		adapter->hwts_tx_en = 0;
-		break;
-	case HWTSTAMP_TX_ON:
-		adapter->hwts_tx_en = 1;
-		break;
-	default:
+	if (cfg.tx_type != HWTSTAMP_TX_OFF && cfg.tx_type != HWTSTAMP_TX_ON)
 		return -ERANGE;
-	}
 
 	switch (cfg.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
@@ -284,6 +276,8 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 		return -ERANGE;
 	}
 
+	adapter->hwts_tx_en = cfg.tx_type == HWTSTAMP_TX_ON;
+
 	/* Clear out any old time stamps. */
 	pch_ch_event_write(pdev, TX_SNAPSHOT_LOCKED | RX_SNAPSHOT_LOCKED);
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
