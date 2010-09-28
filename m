From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] dummy: percpu stats and lockless xmit
Date: Tue, 28 Sep 2010 08:50:33 +0200
Message-ID: <1285656633.10438.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57403 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab0I1Guj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 02:50:39 -0400
Received: by fxm3 with SMTP id 3so2400513fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 23:50:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converts dummy network device driver to :

- percpu stats

- 64bit stats

- lockless xmit (NETIF_F_LLTX)

- performance features added (NETIF_F_SG | NETIF_F_FRAGLIST |
NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/dummy.c       |   58 ++++++++++++++++++++++++++++++++++--
 include/linux/netdevice.h |    1 
 2 files changed, 56 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 37dcfdc..ff2d29b 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -36,6 +36,7 @@
 #include <linux/moduleparam.h>
 #include <linux/rtnetlink.h>
 #include <net/rtnetlink.h>
+#include <linux/u64_stats_sync.h>
 
 static int numdummies = 1;
 
@@ -55,21 +56,69 @@ static void set_multicast_list(struct net_device *dev)
 {
 }
 
+struct pcpu_dstats {
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+};
+
+static struct rtnl_link_stats64 *dummy_get_stats64(struct net_device *dev,
+						   struct rtnl_link_stats64 *stats)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_dstats *dstats;
+		u64 tbytes, tpackets;
+		unsigned int start;
+
+		dstats = per_cpu_ptr(dev->dstats, i);
+		do {
+			start = u64_stats_fetch_begin(&dstats->syncp);
+			tbytes = dstats->tx_bytes;
+			tpackets = dstats->tx_packets;
+		} while (u64_stats_fetch_retry(&dstats->syncp, start));
+		stats->tx_bytes += tbytes;
+		stats->tx_packets += tpackets;
+	}
+	return stats;
+}
 
 static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
+	struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
+
+	u64_stats_update_begin(&dstats->syncp);
+	dstats->tx_packets++;
+	dstats->tx_bytes += skb->len;
+	u64_stats_update_end(&dstats->syncp);
 
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
+static int dummy_dev_init(struct net_device *dev)
+{
+	dev->dstats = alloc_percpu(struct pcpu_dstats);
+	if (!dev->dstats)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void dummy_dev_free(struct net_device *dev)
+{
+	free_percpu(dev->dstats);
+	free_netdev(dev);
+}
+
 static const struct net_device_ops dummy_netdev_ops = {
+	.ndo_init		= dummy_dev_init,
 	.ndo_start_xmit		= dummy_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list = set_multicast_list,
 	.ndo_set_mac_address	= dummy_set_address,
+	.ndo_get_stats64	= dummy_get_stats64,
 };
 
 static void dummy_setup(struct net_device *dev)
@@ -78,14 +127,17 @@ static void dummy_setup(struct net_device *dev)
 
 	/* Initialize the device structure. */
 	dev->netdev_ops = &dummy_netdev_ops;
-	dev->destructor = free_netdev;
+	dev->destructor = dummy_dev_free;
 
 	/* Fill in device structure with ethernet-generic values. */
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
+	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
+	dev->features	|= NETIF_F_NO_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
 	random_ether_addr(dev->dev_addr);
 }
+
 static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 83de0eb..6cff445 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1054,6 +1054,7 @@ struct net_device {
 		void				*ml_priv;
 		struct pcpu_lstats __percpu	*lstats; /* loopback stats */
 		struct pcpu_tstats __percpu	*tstats; /* tunnel stats */
+		struct pcpu_dstats __percpu	*dstats; /* dummy stats */
 	};
 	/* GARP */
 	struct garp_port	*garp_port;


