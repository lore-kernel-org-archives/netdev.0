From: roy.qing.li@gmail.com
Subject: [PATCH net-next] macvlan: unify macvlan_pcpu_stats and vlan_pcpu_stats
Date: Sat,  4 Jan 2014 14:22:34 +0800
Message-ID: <1388816554-17366-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:54100 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaADGWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 01:22:39 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so16668374pab.29
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 22:22:39 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id iu7sm113084992pbc.45.2014.01.03.22.22.36
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 22:22:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

They are same, so unify them as one; since macvlan is a kind of vlan,
vlan_pcpu_stats should be a proper name for vlan and macvlan.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/macvlan.c      |    8 ++++----
 include/linux/if_macvlan.h |   27 +++------------------------
 2 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 10406db..9419836 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -305,7 +305,7 @@ static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		struct macvlan_pcpu_stats *pcpu_stats;
+		struct vlan_pcpu_stats *pcpu_stats;
 
 		pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
 		u64_stats_update_begin(&pcpu_stats->syncp);
@@ -545,12 +545,12 @@ static int macvlan_init(struct net_device *dev)
 
 	macvlan_set_lockdep_class(dev);
 
-	vlan->pcpu_stats = alloc_percpu(struct macvlan_pcpu_stats);
+	vlan->pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
 	if (!vlan->pcpu_stats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct macvlan_pcpu_stats *mvlstats;
+		struct vlan_pcpu_stats *mvlstats;
 		mvlstats = per_cpu_ptr(vlan->pcpu_stats, i);
 		u64_stats_init(&mvlstats->syncp);
 	}
@@ -576,7 +576,7 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
 	if (vlan->pcpu_stats) {
-		struct macvlan_pcpu_stats *p;
+		struct vlan_pcpu_stats *p;
 		u64 rx_packets, rx_bytes, rx_multicast, tx_packets, tx_bytes;
 		u32 rx_errors = 0, tx_dropped = 0;
 		unsigned int start;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 551bdd3..7c8b20b 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -2,6 +2,7 @@
 #define _LINUX_IF_MACVLAN_H
 
 #include <linux/if_link.h>
+#include <linux/if_vlan.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/netlink.h>
@@ -24,28 +25,6 @@ static inline struct socket *macvtap_get_socket(struct file *f)
 struct macvlan_port;
 struct macvtap_queue;
 
-/**
- *	struct macvlan_pcpu_stats - MACVLAN percpu stats
- *	@rx_packets: number of received packets
- *	@rx_bytes: number of received bytes
- *	@rx_multicast: number of received multicast packets
- *	@tx_packets: number of transmitted packets
- *	@tx_bytes: number of transmitted bytes
- *	@syncp: synchronization point for 64bit counters
- *	@rx_errors: number of rx errors
- *	@tx_dropped: number of tx dropped packets
- */
-struct macvlan_pcpu_stats {
-	u64			rx_packets;
-	u64			rx_bytes;
-	u64			rx_multicast;
-	u64			tx_packets;
-	u64			tx_bytes;
-	struct u64_stats_sync	syncp;
-	u32			rx_errors;
-	u32			tx_dropped;
-};
-
 /*
  * Maximum times a macvtap device can be opened. This can be used to
  * configure the number of receive queue, e.g. for multiqueue virtio.
@@ -62,7 +41,7 @@ struct macvlan_dev {
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
 	void			*fwd_priv;
-	struct macvlan_pcpu_stats __percpu *pcpu_stats;
+	struct vlan_pcpu_stats __percpu *pcpu_stats;
 
 	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
 
@@ -84,7 +63,7 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 				    bool multicast)
 {
 	if (likely(success)) {
-		struct macvlan_pcpu_stats *pcpu_stats;
+		struct vlan_pcpu_stats *pcpu_stats;
 
 		pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
 		u64_stats_update_begin(&pcpu_stats->syncp);
-- 
1.7.10.4
