From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next FIX] RDMA/cma: Fix build breakage when
 infiniband is built-in
Date: Mon, 11 Nov 2013 00:43:19 -0500 (EST)
Message-ID: <20131111.004319.58572524940129607.davem@davemloft.net>
References: <1384090080-1862-1-git-send-email-ogerlitz@mellanox.com>
	<20131110.210355.1669362951389274888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, eyalpe@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3KKFnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:43:21 -0500
In-Reply-To: <20131110.210355.1669362951389274888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 10 Nov 2013 21:03:55 -0500 (EST)

> Please just move vlan_dev_get_egress_qos_mask into include/linux/if_vlan.h
> and make it an inline function.
> 
> These Kconfig restrictions are just beyond silly and unnecessary.
> 
> I bet the IPV6 one already there can be killed by moving some things
> into net/ipv6/*_core.c files as well.

I really want to merge the net-next tree as soon as possible so I
committed the following:

====================
[PATCH] vlan: Implement vlan_dev_get_egress_qos_mask as an inline.

This is to avoid very silly Kconfig dependencies for modules
using this routine.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/if_vlan.h | 98 ++++++++++++++++++++++++++++++++++++++++++++++++-
 net/8021q/vlan.h        | 77 --------------------------------------
 net/8021q/vlan_dev.c    | 31 ++--------------
 3 files changed, 99 insertions(+), 107 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index f3088a0..f252deb 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -88,8 +88,102 @@ extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 					       __be16 vlan_proto, u16 vlan_id);
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
-extern u16 vlan_dev_get_egress_qos_mask(struct net_device *dev,
-					u32 skprio);
+
+/**
+ *	struct vlan_priority_tci_mapping - vlan egress priority mappings
+ *	@priority: skb priority
+ *	@vlan_qos: vlan priority: (skb->priority << 13) & 0xE000
+ *	@next: pointer to next struct
+ */
+struct vlan_priority_tci_mapping {
+	u32					priority;
+	u16					vlan_qos;
+	struct vlan_priority_tci_mapping	*next;
+};
+
+/**
+ *	struct vlan_pcpu_stats - VLAN percpu rx/tx stats
+ *	@rx_packets: number of received packets
+ *	@rx_bytes: number of received bytes
+ *	@rx_multicast: number of received multicast packets
+ *	@tx_packets: number of transmitted packets
+ *	@tx_bytes: number of transmitted bytes
+ *	@syncp: synchronization point for 64bit counters
+ *	@rx_errors: number of rx errors
+ *	@tx_dropped: number of tx drops
+ */
+struct vlan_pcpu_stats {
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			rx_multicast;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+	u32			rx_errors;
+	u32			tx_dropped;
+};
+
+struct proc_dir_entry;
+struct netpoll;
+
+/**
+ *	struct vlan_dev_priv - VLAN private device data
+ *	@nr_ingress_mappings: number of ingress priority mappings
+ *	@ingress_priority_map: ingress priority mappings
+ *	@nr_egress_mappings: number of egress priority mappings
+ *	@egress_priority_map: hash of egress priority mappings
+ *	@vlan_proto: VLAN encapsulation protocol
+ *	@vlan_id: VLAN identifier
+ *	@flags: device flags
+ *	@real_dev: underlying netdevice
+ *	@real_dev_addr: address of underlying netdevice
+ *	@dent: proc dir entry
+ *	@vlan_pcpu_stats: ptr to percpu rx stats
+ */
+struct vlan_dev_priv {
+	unsigned int				nr_ingress_mappings;
+	u32					ingress_priority_map[8];
+	unsigned int				nr_egress_mappings;
+	struct vlan_priority_tci_mapping	*egress_priority_map[16];
+
+	__be16					vlan_proto;
+	u16					vlan_id;
+	u16					flags;
+
+	struct net_device			*real_dev;
+	unsigned char				real_dev_addr[ETH_ALEN];
+
+	struct proc_dir_entry			*dent;
+	struct vlan_pcpu_stats __percpu		*vlan_pcpu_stats;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll				*netpoll;
+#endif
+};
+
+static inline struct vlan_dev_priv *vlan_dev_priv(const struct net_device *dev)
+{
+	return netdev_priv(dev);
+}
+
+static inline u16
+vlan_dev_get_egress_qos_mask(struct net_device *dev, u32 skprio)
+{
+	struct vlan_priority_tci_mapping *mp;
+
+	smp_rmb(); /* coupled with smp_wmb() in vlan_dev_set_egress_priority() */
+
+	mp = vlan_dev_priv(dev)->egress_priority_map[(skprio & 0xF)];
+	while (mp) {
+		if (mp->priority == skprio) {
+			return mp->vlan_qos; /* This should already be shifted
+					      * to mask correctly with the
+					      * VLAN's TCI */
+		}
+		mp = mp->next;
+	}
+	return 0;
+}
+
 extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index a2caf00..5704ed9 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -5,83 +5,6 @@
 #include <linux/u64_stats_sync.h>
 #include <linux/list.h>
 
-
-/**
- *	struct vlan_priority_tci_mapping - vlan egress priority mappings
- *	@priority: skb priority
- *	@vlan_qos: vlan priority: (skb->priority << 13) & 0xE000
- *	@next: pointer to next struct
- */
-struct vlan_priority_tci_mapping {
-	u32					priority;
-	u16					vlan_qos;
-	struct vlan_priority_tci_mapping	*next;
-};
-
-
-/**
- *	struct vlan_pcpu_stats - VLAN percpu rx/tx stats
- *	@rx_packets: number of received packets
- *	@rx_bytes: number of received bytes
- *	@rx_multicast: number of received multicast packets
- *	@tx_packets: number of transmitted packets
- *	@tx_bytes: number of transmitted bytes
- *	@syncp: synchronization point for 64bit counters
- *	@rx_errors: number of rx errors
- *	@tx_dropped: number of tx drops
- */
-struct vlan_pcpu_stats {
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
-struct netpoll;
-
-/**
- *	struct vlan_dev_priv - VLAN private device data
- *	@nr_ingress_mappings: number of ingress priority mappings
- *	@ingress_priority_map: ingress priority mappings
- *	@nr_egress_mappings: number of egress priority mappings
- *	@egress_priority_map: hash of egress priority mappings
- *	@vlan_proto: VLAN encapsulation protocol
- *	@vlan_id: VLAN identifier
- *	@flags: device flags
- *	@real_dev: underlying netdevice
- *	@real_dev_addr: address of underlying netdevice
- *	@dent: proc dir entry
- *	@vlan_pcpu_stats: ptr to percpu rx stats
- */
-struct vlan_dev_priv {
-	unsigned int				nr_ingress_mappings;
-	u32					ingress_priority_map[8];
-	unsigned int				nr_egress_mappings;
-	struct vlan_priority_tci_mapping	*egress_priority_map[16];
-
-	__be16					vlan_proto;
-	u16					vlan_id;
-	u16					flags;
-
-	struct net_device			*real_dev;
-	unsigned char				real_dev_addr[ETH_ALEN];
-
-	struct proc_dir_entry			*dent;
-	struct vlan_pcpu_stats __percpu		*vlan_pcpu_stats;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	struct netpoll				*netpoll;
-#endif
-};
-
-static inline struct vlan_dev_priv *vlan_dev_priv(const struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
-
 /* if this changes, algorithm will have to be reworked because this
  * depends on completely exhausting the VLAN identifier space.  Thus
  * it gives constant time look-up, but in many cases it wastes memory.
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 13904a4..8db1b98 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -68,31 +68,6 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 	return 0;
 }
 
-static inline u16
-__vlan_dev_get_egress_qos_mask(struct net_device *dev, u32 skprio)
-{
-	struct vlan_priority_tci_mapping *mp;
-
-	smp_rmb(); /* coupled with smp_wmb() in vlan_dev_set_egress_priority() */
-
-	mp = vlan_dev_priv(dev)->egress_priority_map[(skprio & 0xF)];
-	while (mp) {
-		if (mp->priority == skprio) {
-			return mp->vlan_qos; /* This should already be shifted
-					      * to mask correctly with the
-					      * VLAN's TCI */
-		}
-		mp = mp->next;
-	}
-	return 0;
-}
-
-u16 vlan_dev_get_egress_qos_mask(struct net_device *dev, u32 skprio)
-{
-	return __vlan_dev_get_egress_qos_mask(dev, skprio);
-}
-EXPORT_SYMBOL(vlan_dev_get_egress_qos_mask);
-
 /*
  *	Create the VLAN header for an arbitrary protocol layer
  *
@@ -117,7 +92,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
 
 		vlan_tci = vlan->vlan_id;
-		vlan_tci |= __vlan_dev_get_egress_qos_mask(dev, skb->priority);
+		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb->priority);
 		vhdr->h_vlan_TCI = htons(vlan_tci);
 
 		/*
@@ -174,7 +149,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	    vlan->flags & VLAN_FLAG_REORDER_HDR) {
 		u16 vlan_tci;
 		vlan_tci = vlan->vlan_id;
-		vlan_tci |= __vlan_dev_get_egress_qos_mask(dev, skb->priority);
+		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb->priority);
 		skb = __vlan_hwaccel_put_tag(skb, vlan->vlan_proto, vlan_tci);
 	}
 
@@ -259,7 +234,7 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 	np->vlan_qos = vlan_qos;
 	/* Before inserting this element in hash table, make sure all its fields
 	 * are committed to memory.
-	 * coupled with smp_rmb() in __vlan_dev_get_egress_qos_mask()
+	 * coupled with smp_rmb() in vlan_dev_get_egress_qos_mask()
 	 */
 	smp_wmb();
 	vlan->egress_priority_map[skb_prio & 0xF] = np;
-- 
1.7.11.7
