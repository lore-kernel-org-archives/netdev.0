From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Xen-devel] [PATCH net-next 4/5] xen: convert to 64 bit stats
 interface
Date: Tue, 21 Jun 2011 08:35:31 -0700
Message-ID: <20110621083531.00442d7f@nehalam.ftrdhcpuser.net>
References: <20110620203506.363818794@vyatta.com>
	<20110620203602.929964665@vyatta.com>
	<1308665154.6920.46.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58131 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676Ab1FUPfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 11:35:34 -0400
In-Reply-To: <1308665154.6920.46.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert xen driver to 64 bit statistics interface.
Use stats_sync to ensure that 64 bit update is read atomically on 32 bit platform.
Put hot statistics into per-cpu table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - add stats_sync and per-cpu
v2.1 - keep rx_errors on checksum error

--- a/drivers/net/xen-netfront.c	2011-06-20 14:50:01.271989938 -0700
+++ b/drivers/net/xen-netfront.c	2011-06-21 08:33:12.851953760 -0700
@@ -70,6 +70,14 @@ struct netfront_cb {
 #define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
 #define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
 
+struct netfront_stats {
+	u64			rx_packets;
+	u64			tx_packets;
+	u64			rx_bytes;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+};
+
 struct netfront_info {
 	struct list_head list;
 	struct net_device *netdev;
@@ -122,6 +130,8 @@ struct netfront_info {
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
 
 	/* Statistics */
+	struct netfront_stats __percpu *stats;
+
 	unsigned long rx_gso_checksum_fixup;
 };
 
@@ -468,6 +478,7 @@ static int xennet_start_xmit(struct sk_b
 {
 	unsigned short id;
 	struct netfront_info *np = netdev_priv(dev);
+	struct netfront_stats *stats = this_cpu_ptr(np->stats);
 	struct xen_netif_tx_request *tx;
 	struct xen_netif_extra_info *extra;
 	char *data = skb->data;
@@ -552,8 +563,10 @@ static int xennet_start_xmit(struct sk_b
 	if (notify)
 		notify_remote_via_irq(np->netdev->irq);
 
-	dev->stats.tx_bytes += skb->len;
-	dev->stats.tx_packets++;
+	u64_stats_update_begin(&stats->syncp);
+	stats->tx_bytes += skb->len;
+	stats->tx_packets++;
+	u64_stats_update_end(&stats->syncp);
 
 	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(dev);
@@ -847,6 +860,8 @@ out:
 static int handle_incoming_queue(struct net_device *dev,
 				 struct sk_buff_head *rxq)
 {
+	struct netfront_info *np = netdev_priv(dev);
+	struct netfront_stats *stats = this_cpu_ptr(np->stats);
 	int packets_dropped = 0;
 	struct sk_buff *skb;
 
@@ -871,8 +886,10 @@ static int handle_incoming_queue(struct
 			continue;
 		}
 
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += skb->len;
+		u64_stats_update_begin(&stats->syncp);
+		stats->rx_packets++;
+		stats->rx_bytes += skb->len;
+		u64_stats_update_end(&stats->syncp);
 
 		/* Pass it up. */
 		netif_receive_skb(skb);
@@ -1034,6 +1051,38 @@ static int xennet_change_mtu(struct net_
 	return 0;
 }
 
+static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
+						    struct rtnl_link_stats64 *tot)
+{
+	struct netfront_info *np = netdev_priv(dev);
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct netfront_stats *stats = per_cpu_ptr(np->stats, cpu);
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&stats->syncp);
+
+			rx_packets = stats->rx_packets;
+			tx_packets = stats->tx_packets;
+			rx_bytes = stats->rx_bytes;
+			tx_bytes = stats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+	}
+
+	tot->rx_errors  = dev->stats.rx_errors;
+	tot->tx_dropped = dev->stats.tx_dropped;
+
+	return tot;
+}
+
 static void xennet_release_tx_bufs(struct netfront_info *np)
 {
 	struct sk_buff *skb;
@@ -1182,6 +1231,7 @@ static const struct net_device_ops xenne
 	.ndo_stop            = xennet_close,
 	.ndo_start_xmit      = xennet_start_xmit,
 	.ndo_change_mtu	     = xennet_change_mtu,
+	.ndo_get_stats64     = xennet_get_stats64,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_fix_features    = xennet_fix_features,
@@ -1216,6 +1266,11 @@ static struct net_device * __devinit xen
 	np->rx_refill_timer.data = (unsigned long)netdev;
 	np->rx_refill_timer.function = rx_refill_timeout;
 
+	err = -ENOMEM;
+	np->stats = alloc_percpu(struct netfront_stats);
+	if (np->stats == NULL)
+		goto exit;
+
 	/* Initialise tx_skbs as a free chain containing every entry. */
 	np->tx_skb_freelist = 0;
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
@@ -1234,7 +1289,7 @@ static struct net_device * __devinit xen
 					  &np->gref_tx_head) < 0) {
 		printk(KERN_ALERT "#### netfront can't alloc tx grant refs\n");
 		err = -ENOMEM;
-		goto exit;
+		goto exit_free_stats;
 	}
 	/* A grant for every rx ring slot */
 	if (gnttab_alloc_grant_references(RX_MAX_TARGET,
@@ -1270,6 +1325,8 @@ static struct net_device * __devinit xen
 
  exit_free_tx:
 	gnttab_free_grant_references(np->gref_tx_head);
+ exit_free_stats:
+	free_percpu(np->stats);
  exit:
 	free_netdev(netdev);
 	return ERR_PTR(err);
@@ -1869,6 +1926,8 @@ static int __devexit xennet_remove(struc
 
 	xennet_sysfs_delif(info->netdev);
 
+	free_percpu(info->stats);
+
 	free_netdev(info->netdev);
 
 	return 0;

