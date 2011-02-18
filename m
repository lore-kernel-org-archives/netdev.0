From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH net-next-2.6 1/2] net: XPS: Allow driver to provide a
 default mapping of CPUs to TX queues
Date: Fri, 18 Feb 2011 16:15:02 +0000
Message-ID: <1298045702.2570.18.camel@bwh-desktop>
References: <1298045607.2570.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40044 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757214Ab1BRQPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:15:05 -0500
In-Reply-To: <1298045607.2570.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As with RFS acceleration, drivers may use the irq_cpu_rmap facility to
provide a mapping from each CPU to the 'nearest' TX queue.

Define CONFIG_PACKET_STEERING and CONFIG_NET_IRQ_CPU_RMAP so that
drivers can make all cpu_rmap initialisation conditional on the
latter.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |   10 +++++++---
 net/Kconfig               |   17 ++++++++++++-----
 net/core/dev.c            |   41 +++++++++++++++++++++++------------------
 3 files changed, 42 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c7d7074..c5cba16 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1080,14 +1080,13 @@ struct net_device {
 
 	/* Number of RX queues currently active in device */
 	unsigned int		real_num_rx_queues;
-
-#ifdef CONFIG_RFS_ACCEL
+#endif
+#ifdef CONFIG_NET_IRQ_CPU_RMAP
 	/* CPU reverse-mapping for RX completion interrupts, indexed
 	 * by RX queue number.  Assigned by driver.  This must only be
 	 * set if the ndo_rx_flow_steer operation is defined. */
 	struct cpu_rmap		*rx_cpu_rmap;
 #endif
-#endif
 
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
@@ -1114,6 +1113,11 @@ struct net_device {
 #ifdef CONFIG_XPS
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
+#ifdef CONFIG_NET_IRQ_CPU_RMAP
+	/* CPU reverse-mapping for TX completion interrupts.  Assigned
+	 * by driver. */
+	struct cpu_rmap		*tx_cpu_rmap;
+#endif
 
 	/* These may be needed for future network-power-down code. */
 
diff --git a/net/Kconfig b/net/Kconfig
index 79cabf1..fa0a093 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -216,21 +216,28 @@ source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
 
-config RPS
+config PACKET_STEERING
 	boolean
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
+	select RPS
+	select XPS
 	default y
 
-config RFS_ACCEL
+config NET_IRQ_CPU_RMAP
 	boolean
-	depends on RPS && GENERIC_HARDIRQS
+	depends on PACKET_STEERING && GENERIC_HARDIRQS
 	select CPU_RMAP
+	select RFS_ACCEL
 	default y
 
+config RPS
+	boolean
+
+config RFS_ACCEL
+	boolean
+
 config XPS
 	boolean
-	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
-	default y
 
 menu "Network testing"
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 54aaca6..dd38b88 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2257,27 +2257,32 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 
 	rcu_read_lock();
 	dev_maps = rcu_dereference(dev->xps_maps);
-	if (dev_maps) {
+	if (dev_maps)
 		map = rcu_dereference(
-		    dev_maps->cpu_map[raw_smp_processor_id()]);
-		if (map) {
-			if (map->len == 1)
-				queue_index = map->queues[0];
-			else {
-				u32 hash;
-				if (skb->sk && skb->sk->sk_hash)
-					hash = skb->sk->sk_hash;
-				else
-					hash = (__force u16) skb->protocol ^
-					    skb->rxhash;
-				hash = jhash_1word(hash, hashrnd);
-				queue_index = map->queues[
-				    ((u64)hash * map->len) >> 32];
-			}
-			if (unlikely(queue_index >= dev->real_num_tx_queues))
-				queue_index = -1;
+			dev_maps->cpu_map[raw_smp_processor_id()]);
+	if (map) {
+		if (map->len == 1)
+			queue_index = map->queues[0];
+		else {
+			u32 hash;
+			if (skb->sk && skb->sk->sk_hash)
+				hash = skb->sk->sk_hash;
+			else
+				hash = (__force u16) skb->protocol ^
+					skb->rxhash;
+			hash = jhash_1word(hash, hashrnd);
+			queue_index = map->queues[
+				((u64)hash * map->len) >> 32];
 		}
+		if (unlikely(queue_index >= dev->real_num_tx_queues))
+			queue_index = -1;
+	}
+#ifdef CONFIG_PACKET_STEERING_CPU_RMAP
+	else if (dev->tx_cpu_rmap) {
+		queue_index = cpu_rmap_lookup_index(dev->tx_cpu_rmap,
+						    raw_smp_processor_id());
 	}
+#endif
 	rcu_read_unlock();
 
 	return queue_index;
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

