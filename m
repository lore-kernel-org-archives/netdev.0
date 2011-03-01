From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 6/8] sfc: Expose TX push and TSO counters
 through ethtool statistics
Date: Tue, 01 Mar 2011 01:23:24 +0000
Message-ID: <1298942604.3069.185.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12108 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1CABX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:23:27 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 52fa661..158d5b5 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -28,7 +28,8 @@ struct efx_ethtool_stat {
 	enum {
 		EFX_ETHTOOL_STAT_SOURCE_mac_stats,
 		EFX_ETHTOOL_STAT_SOURCE_nic,
-		EFX_ETHTOOL_STAT_SOURCE_channel
+		EFX_ETHTOOL_STAT_SOURCE_channel,
+		EFX_ETHTOOL_STAT_SOURCE_tx_queue
 	} source;
 	unsigned offset;
 	u64(*get_stat) (void *field); /* Reader function */
@@ -86,6 +87,10 @@ static u64 efx_get_atomic_stat(void *field)
 	EFX_ETHTOOL_STAT(field, channel, n_##field,		\
 			 unsigned int, efx_get_uint_stat)
 
+#define EFX_ETHTOOL_UINT_TXQ_STAT(field)			\
+	EFX_ETHTOOL_STAT(tx_##field, tx_queue, field,		\
+			 unsigned int, efx_get_uint_stat)
+
 static struct efx_ethtool_stat efx_ethtool_stats[] = {
 	EFX_ETHTOOL_U64_MAC_STAT(tx_bytes),
 	EFX_ETHTOOL_U64_MAC_STAT(tx_good_bytes),
@@ -116,6 +121,10 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
 	EFX_ETHTOOL_ULONG_MAC_STAT(tx_non_tcpudp),
 	EFX_ETHTOOL_ULONG_MAC_STAT(tx_mac_src_error),
 	EFX_ETHTOOL_ULONG_MAC_STAT(tx_ip_src_error),
+	EFX_ETHTOOL_UINT_TXQ_STAT(tso_bursts),
+	EFX_ETHTOOL_UINT_TXQ_STAT(tso_long_headers),
+	EFX_ETHTOOL_UINT_TXQ_STAT(tso_packets),
+	EFX_ETHTOOL_UINT_TXQ_STAT(pushes),
 	EFX_ETHTOOL_U64_MAC_STAT(rx_bytes),
 	EFX_ETHTOOL_U64_MAC_STAT(rx_good_bytes),
 	EFX_ETHTOOL_U64_MAC_STAT(rx_bad_bytes),
@@ -470,6 +479,7 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	struct efx_mac_stats *mac_stats = &efx->mac_stats;
 	struct efx_ethtool_stat *stat;
 	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
 	struct rtnl_link_stats64 temp;
 	int i;
 
@@ -495,6 +505,15 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 				data[i] += stat->get_stat((void *)channel +
 							  stat->offset);
 			break;
+		case EFX_ETHTOOL_STAT_SOURCE_tx_queue:
+			data[i] = 0;
+			efx_for_each_channel(channel, efx) {
+				efx_for_each_channel_tx_queue(tx_queue, channel)
+					data[i] +=
+						stat->get_stat((void *)tx_queue
+							       + stat->offset);
+			}
+			break;
 		}
 	}
 }
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

