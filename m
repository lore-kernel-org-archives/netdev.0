From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/32] sfc: Hold efx_nic::stats_lock while reading
 efx_nic::mac_stats
Date: Fri, 27 Jan 2012 20:45:38 +0000
Message-ID: <1327697138.2503.19.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63608 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752631Ab2A0Upl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:45:41 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_nic::stats_lock is used to serialise stats updates, but each
reader was dropping it before it finished reading efx_nic::mac_stats.

If there were concurrent stats reads using procfs, or one using procfs
and one using ethtool, an update could race with a read.  On a 32-bit
system, the reader could see word-tearing of 64-bit stats (32 bits of
the old value and 32 bits of the new).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    4 +++-
 drivers/net/ethernet/sfc/ethtool.c    |    7 +++++--
 drivers/net/ethernet/sfc/net_driver.h |    1 +
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index eff5d30..8f4cbb6 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1743,8 +1743,8 @@ static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_dev, struc
 	struct efx_mac_stats *mac_stats = &efx->mac_stats;
 
 	spin_lock_bh(&efx->stats_lock);
+
 	efx->type->update_stats(efx);
-	spin_unlock_bh(&efx->stats_lock);
 
 	stats->rx_packets = mac_stats->rx_packets;
 	stats->tx_packets = mac_stats->tx_packets;
@@ -1768,6 +1768,8 @@ static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_dev, struc
 	stats->tx_errors = (stats->tx_window_errors +
 			    mac_stats->tx_bad);
 
+	spin_unlock_bh(&efx->stats_lock);
+
 	return stats;
 }
 
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 52c9ee4..55a25b1 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -489,13 +489,14 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	const struct efx_ethtool_stat *stat;
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
-	struct rtnl_link_stats64 temp;
 	int i;
 
 	EFX_BUG_ON_PARANOID(stats->n_stats != EFX_ETHTOOL_NUM_STATS);
 
+	spin_lock_bh(&efx->stats_lock);
+
 	/* Update MAC and NIC statistics */
-	dev_get_stats(net_dev, &temp);
+	efx->type->update_stats(efx);
 
 	/* Fill detailed statistics buffer */
 	for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++) {
@@ -525,6 +526,8 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 			break;
 		}
 	}
+
+	spin_unlock_bh(&efx->stats_lock);
 }
 
 static void efx_ethtool_self_test(struct net_device *net_dev,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9353ce8..b604014 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -704,6 +704,7 @@ struct efx_filter_state;
  *	can provide.  Generic code converts these into a standard
  *	&struct net_device_stats.
  * @stats_lock: Statistics update lock. Serialises statistics fetches
+ *	and access to @mac_stats.
  *
  * This is stored in the private area of the &struct net_device.
  */
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
