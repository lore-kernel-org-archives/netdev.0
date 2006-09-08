From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] loopback: minor statistics optimization
Date: Fri, 8 Sep 2006 11:20:56 -0700
Message-ID: <20060908112056.7ef03bac@localhost.localdomain>
References: <20060908111613.12c1f9b8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2203 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750756AbWIHSVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 14:21:19 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060908111613.12c1f9b8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor loopback enhancements for 2.6.19

The loopback device status structure is a singleton and doesn't
need to be allocated. Add ethtool_ops hooks to show checksum always on,
and make ethtool_ops const.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.orig/drivers/net/loopback.c
+++ linux-2.6/drivers/net/loopback.c
@@ -161,15 +161,13 @@ static int loopback_xmit(struct sk_buff 
 	return(0);
 }
 
+static struct net_device_stats loopback_stats;
+
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	struct net_device_stats *stats = dev->priv;
+	struct net_device_stats *stats = &loopback_stats;
 	int i;
 
-	if (!stats) {
-		return NULL;
-	}
-
 	memset(stats, 0, sizeof(struct net_device_stats));
 
 	for_each_possible_cpu(i) {
@@ -185,19 +183,28 @@ static struct net_device_stats *get_stat
 	return stats;
 }
 
-static u32 loopback_get_link(struct net_device *dev)
+static u32 always_on(struct net_device *dev)
 {
 	return 1;
 }
 
-static struct ethtool_ops loopback_ethtool_ops = {
-	.get_link		= loopback_get_link,
+static const struct ethtool_ops loopback_ethtool_ops = {
+	.get_link		= always_on,
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= ethtool_op_set_tso,
+	.get_tx_csum		= always_on,
+	.get_sg			= always_on,
+	.get_rx_csum		= always_on,
 };
 
+/*
+ * The loopback device is special. There is only one instance and
+ * it is statically allocated. Don't do this for other devices.
+ */
 struct net_device loopback_dev = {
 	.name	 		= "lo",
+	.get_stats		= &get_stats,
+	.priv			= &loopback_stats,
 	.mtu			= (16 * 1024) + 20 + 20 + 12,
 	.hard_start_xmit	= loopback_xmit,
 	.hard_header		= eth_header,
@@ -221,16 +228,6 @@ struct net_device loopback_dev = {
 /* Setup and register the loopback device. */
 int __init loopback_init(void)
 {
-	struct net_device_stats *stats;
-
-	/* Can survive without statistics */
-	stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
-	if (stats) {
-		memset(stats, 0, sizeof(struct net_device_stats));
-		loopback_dev.priv = stats;
-		loopback_dev.get_stats = &get_stats;
-	}
-	
 	return register_netdev(&loopback_dev);
 };
 
