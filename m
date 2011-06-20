From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/5] netxen: make 64 bit stats safe on 32 bit platform
Date: Mon, 20 Jun 2011 13:35:09 -0700
Message-ID: <20110620203602.836836605@vyatta.com>
References: <20110620203506.363818794@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40990 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956Ab1FTUpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 16:45:31 -0400
Content-Disposition: inline; filename=netxen-stats-sync.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use stats_update wrapper to avoid problems where 64 bit statistic update
is not atomic on 32 bit platform.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_init.c |    2 ++
 drivers/net/netxen/netxen_nic_main.c |   16 ++++++++++++----
 3 files changed, 15 insertions(+), 4 deletions(-)

--- a/drivers/net/netxen/netxen_nic.h	2011-06-20 12:42:05.035994241 -0700
+++ b/drivers/net/netxen/netxen_nic.h	2011-06-20 12:51:27.727993925 -0700
@@ -607,6 +607,7 @@ struct netxen_hardware_context {
 #define ETHERNET_FCS_SIZE		4
 
 struct netxen_adapter_stats {
+	struct u64_stats_sync syncp;
 	u64  xmitcalled;
 	u64  xmitfinished;
 	u64  rxdropped;
--- a/drivers/net/netxen/netxen_nic_init.c	2011-06-20 12:48:02.963994039 -0700
+++ b/drivers/net/netxen/netxen_nic_init.c	2011-06-20 12:50:27.887993959 -0700
@@ -1616,8 +1616,10 @@ netxen_process_lro(struct netxen_adapter
 
 	netif_receive_skb(skb);
 
+	u64_stats_update_begin(&adapter->stats.syncp);
 	adapter->stats.lro_pkts++;
 	adapter->stats.rxbytes += length;
+	u64_stats_update_end(&adapter->stats.syncp);
 
 	return buffer;
 }
--- a/drivers/net/netxen/netxen_nic_main.c	2011-06-20 12:41:47.739994250 -0700
+++ b/drivers/net/netxen/netxen_nic_main.c	2011-06-20 12:52:49.255993879 -0700
@@ -1968,8 +1968,10 @@ netxen_nic_xmit_frame(struct sk_buff *sk
 
 	netxen_nic_update_cmd_producer(adapter, tx_ring);
 
+	u64_stats_update_begin(&adapter->stats.syncp);
 	adapter->stats.txbytes += skb->len;
 	adapter->stats.xmitcalled++;
+	u64_stats_update_end(&adapter->stats.syncp);
 
 	return NETDEV_TX_OK;
 
@@ -2115,11 +2117,17 @@ static struct rtnl_link_stats64 *netxen_
 						      struct rtnl_link_stats64 *stats)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
+	unsigned int start;
+
+	do {
+		start = u64_stats_fetch_begin(&adapter->stats.syncp);
+
+		stats->rx_packets = adapter->stats.rx_pkts + adapter->stats.lro_pkts;
+		stats->tx_packets = adapter->stats.xmitfinished;
+		stats->rx_bytes = adapter->stats.rxbytes;
+		stats->tx_bytes = adapter->stats.txbytes;
+	} while (u64_stats_fetch_retry(&adapter->stats.syncp, start));
 
-	stats->rx_packets = adapter->stats.rx_pkts + adapter->stats.lro_pkts;
-	stats->tx_packets = adapter->stats.xmitfinished;
-	stats->rx_bytes = adapter->stats.rxbytes;
-	stats->tx_bytes = adapter->stats.txbytes;
 	stats->rx_dropped = adapter->stats.rxdropped;
 	stats->tx_dropped = adapter->stats.txdropped;
 


