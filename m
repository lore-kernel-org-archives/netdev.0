From: roy.qing.li@gmail.com
Subject: [PATCH net-next] net: unify the pcpu_tstats and br_cpu_netstats
Date: Thu,  2 Jan 2014 16:57:34 +0800
Message-ID: <1388653054-4341-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39281 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbaABI5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:57:43 -0500
Received: by mail-pa0-f45.google.com with SMTP id fb1so14301205pad.4
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 00:57:43 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id de1sm100239277pbc.7.2014.01.02.00.57.40
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 00:57:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

They are same, so unify them as one, pcpu_tstats.
and move pcpu_tstat into netdevice.h

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/linux/if_tunnel.h |    9 ---------
 include/linux/netdevice.h |    9 +++++++++
 net/bridge/br_device.c    |   10 +++++-----
 net/bridge/br_input.c     |    2 +-
 net/bridge/br_private.h   |   10 +---------
 5 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index f4e56ec..712710b 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -13,13 +13,4 @@
 #define for_each_ip_tunnel_rcu(pos, start) \
 	for (pos = rcu_dereference(start); pos; pos = rcu_dereference(pos->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 #endif /* _IF_TUNNEL_H_ */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88afa80..e58dbc2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1685,6 +1685,15 @@ struct packet_offload {
 	struct list_head	 list;
 };
 
+/* often modified stats are per cpu, other are shared (netdev->stats) */
+struct pcpu_tstats {
+	u64     rx_packets;
+	u64     rx_bytes;
+	u64     tx_packets;
+	u64     tx_bytes;
+	struct u64_stats_sync   syncp;
+};
+
 #include <linux/notifier.h>
 
 /* netdevice notifier chain. Please remember to update the rtnetlink
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f00cfd2..9be9812 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -32,7 +32,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
-	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	struct pcpu_tstats *brstats = this_cpu_ptr(br->stats);
 	u16 vid = 0;
 
 	rcu_read_lock();
@@ -90,12 +90,12 @@ static int br_dev_init(struct net_device *dev)
 	struct net_bridge *br = netdev_priv(dev);
 	int i;
 
-	br->stats = alloc_percpu(struct br_cpu_netstats);
+	br->stats = alloc_percpu(struct pcpu_tstats);
 	if (!br->stats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct br_cpu_netstats *br_dev_stats;
+		struct pcpu_tstats *br_dev_stats;
 		br_dev_stats = per_cpu_ptr(br->stats, i);
 		u64_stats_init(&br_dev_stats->syncp);
 	}
@@ -135,12 +135,12 @@ static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
 						struct rtnl_link_stats64 *stats)
 {
 	struct net_bridge *br = netdev_priv(dev);
-	struct br_cpu_netstats tmp, sum = { 0 };
+	struct pcpu_tstats tmp, sum = { 0 };
 	unsigned int cpu;
 
 	for_each_possible_cpu(cpu) {
 		unsigned int start;
-		const struct br_cpu_netstats *bstats
+		const struct pcpu_tstats *bstats
 			= per_cpu_ptr(br->stats, cpu);
 		do {
 			start = u64_stats_fetch_begin_bh(&bstats->syncp);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7e73c32..8aab0b0 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -28,7 +28,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 {
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
 	struct net_bridge *br = netdev_priv(brdev);
-	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	struct pcpu_tstats *brstats = this_cpu_ptr(br->stats);
 
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->rx_packets++;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2e77d92..03910e8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -210,21 +210,13 @@ static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *
 		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
-struct br_cpu_netstats {
-	u64			rx_packets;
-	u64			rx_bytes;
-	u64			tx_packets;
-	u64			tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 struct net_bridge
 {
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
 
-	struct br_cpu_netstats __percpu *stats;
+	struct pcpu_tstats		__percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 #ifdef CONFIG_BRIDGE_NETFILTER
-- 
1.7.10.4
