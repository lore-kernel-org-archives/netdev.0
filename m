From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] hv: use network device stats
Date: Tue, 9 Mar 2010 17:42:33 -0800
Message-ID: <20100309174233.2d7522df@nehalam>
References: <AD02C96F1FB40A4B896D24F974E9B9D42AA4787A@TK5EX14MBXC139.redmond.corp.microsoft.com>
 <20100308154549.1c62a33b@nehalam>
 <8AFC7968D54FB448A30D8F38F259C5621AF725A9@TK5EX14MBXC116.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hank Janssen <hjanssen@microsoft.com>, Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52839 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753551Ab0CJBmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 20:42:55 -0500
In-Reply-To: <8AFC7968D54FB448A30D8F38F259C5621AF725A9@TK5EX14MBXC116.redmond.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network device structure has space already reserved for statistics.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/staging/hv/TODO         |    1 -
 drivers/staging/hv/netvsc_drv.c |   31 +++++++++----------------------
 2 files changed, 9 insertions(+), 23 deletions(-)

--- a/drivers/staging/hv/TODO	2010-03-09 17:07:51.483312299 -0800
+++ b/drivers/staging/hv/TODO	2010-03-09 17:08:05.812720241 -0800
@@ -9,7 +9,6 @@ TODO:
 	- see if the vmbus can be merged with the other virtual busses
 	  in the kernel
 	- audit the network driver
-	  - use existing net_device_stats struct in network device
 	  - checking for carrier inside open is wrong, network device API
             confusion??
 	- audit the block driver
--- a/drivers/staging/hv/netvsc_drv.c	2010-03-09 17:04:48.453624589 -0800
+++ b/drivers/staging/hv/netvsc_drv.c	2010-03-09 17:25:21.196552131 -0800
@@ -42,7 +42,6 @@
 struct net_device_context {
 	/* point back to our device context */
 	struct vm_device *device_ctx;
-	struct net_device_stats stats;
 };
 
 struct netvsc_driver_context {
@@ -57,13 +56,6 @@ static int netvsc_ringbuffer_size = NETV
 /* The one and only one */
 static struct netvsc_driver_context g_netvsc_drv;
 
-static struct net_device_stats *netvsc_get_stats(struct net_device *net)
-{
-	struct net_device_context *net_device_ctx = netdev_priv(net);
-
-	return &net_device_ctx->stats;
-}
-
 static void netvsc_set_multicast_list(struct net_device *net)
 {
 }
@@ -77,9 +69,6 @@ static int netvsc_open(struct net_device
 	DPRINT_ENTER(NETVSC_DRV);
 
 	if (netif_carrier_ok(net)) {
-		memset(&net_device_ctx->stats, 0,
-		       sizeof(struct net_device_stats));
-
 		/* Open up the device */
 		ret = RndisFilterOnOpen(device_obj);
 		if (ret != 0) {
@@ -223,8 +212,8 @@ retry_send:
 
 	if (ret == 0) {
 		ret = NETDEV_TX_OK;
-		net_device_ctx->stats.tx_bytes += skb->len;
-		net_device_ctx->stats.tx_packets++;
+		net->stats.tx_bytes += skb->len;
+		net->stats.tx_packets++;
 	} else {
 		retries++;
 		if (retries < 4) {
@@ -240,7 +229,7 @@ retry_send:
 		DPRINT_INFO(NETVSC_DRV, "net device (%p) stopping", net);
 
 		ret = NETDEV_TX_BUSY;
-		net_device_ctx->stats.tx_dropped++;
+		net->stats.tx_dropped++;
 
 		netif_stop_queue(net);
 
@@ -258,8 +247,8 @@ retry_send:
 	}
 
 	DPRINT_DBG(NETVSC_DRV, "# of xmits %lu total size %lu",
-		   net_device_ctx->stats.tx_packets,
-		   net_device_ctx->stats.tx_bytes);
+		   net->stats.tx_packets,
+		   net->stats.tx_bytes);
 
 	DPRINT_EXIT(NETVSC_DRV);
 	return ret;
@@ -358,17 +347,16 @@ static int netvsc_recv_callback(struct h
 
 	switch (ret) {
 	case NET_RX_DROP:
-		net_device_ctx->stats.rx_dropped++;
+		net->stats.rx_dropped++;
 		break;
 	default:
-		net_device_ctx->stats.rx_packets++;
-		net_device_ctx->stats.rx_bytes += skb->len;
+		net->stats.rx_packets++;
+		net->stats.rx_bytes += skb->len;
 		break;
 
 	}
 	DPRINT_DBG(NETVSC_DRV, "# of recvs %lu total size %lu",
-		   net_device_ctx->stats.rx_packets,
-		   net_device_ctx->stats.rx_bytes);
+		   net->stats.rx_packets, net->stats.rx_bytes);
 
 	DPRINT_EXIT(NETVSC_DRV);
 
@@ -379,7 +367,6 @@ static const struct net_device_ops devic
 	.ndo_open =			netvsc_open,
 	.ndo_stop =			netvsc_close,
 	.ndo_start_xmit =		netvsc_start_xmit,
-	.ndo_get_stats =		netvsc_get_stats,
 	.ndo_set_multicast_list =	netvsc_set_multicast_list,
 };
 
