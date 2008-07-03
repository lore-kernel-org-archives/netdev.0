From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 28/39]: pktgen: Fix multiqueue handling.
Date: Thu, 03 Jul 2008 00:04:59 -0700 (PDT)
Message-ID: <20080703.000459.256709613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


We make sure we operate on whatever queue gets mapped
to the pkt_dev->skb.

This is currently functional, but it could be largely
improved.  The initial check in pktgen_xmit() will
sometimes check the wrong queue, which is mostly
harmless.  The thing to do is probably to invoke
fill_packet() earlier.

Also, dev_pick_tx() has no external references, so we
can mark it static and kill the module export.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |    3 --
 net/core/dev.c            |    5 +--
 net/core/pktgen.c         |   55 +++++++++++++++++++++++++++++++--------------
 3 files changed, 40 insertions(+), 23 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 510a420..f119532 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -757,9 +757,6 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
-extern struct netdev_queue *dev_pick_tx(struct net_device *dev,
-					struct sk_buff *skb);
-
 static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 int index)
diff --git a/net/core/dev.c b/net/core/dev.c
index 6bf4930..cfda430 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1666,12 +1666,11 @@ out_kfree_skb:
  *          --BLG
  */
 
-struct netdev_queue *dev_pick_tx(struct net_device *dev,
-				 struct sk_buff *skb)
+static struct netdev_queue *dev_pick_tx(struct net_device *dev,
+					struct sk_buff *skb)
 {
 	return netdev_get_tx_queue(dev, 0);
 }
-EXPORT_SYMBOL(dev_pick_tx);
 
 int dev_queue_xmit(struct sk_buff *skb)
 {
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6aeff58..3b08df4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2123,6 +2123,24 @@ static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 	}
 }
 #endif
+static void set_cur_queue_map(struct pktgen_dev *pkt_dev)
+{
+	if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
+		__u16 t;
+		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
+			t = random32() %
+				(pkt_dev->queue_map_max -
+				 pkt_dev->queue_map_min + 1)
+				+ pkt_dev->queue_map_min;
+		} else {
+			t = pkt_dev->cur_queue_map + 1;
+			if (t > pkt_dev->queue_map_max)
+				t = pkt_dev->queue_map_min;
+		}
+		pkt_dev->cur_queue_map = t;
+	}
+}
+
 /* Increment/randomize headers according to flags and current values
  * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
  */
@@ -2325,19 +2343,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		pkt_dev->cur_pkt_size = t;
 	}
 
-	if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
-		__u16 t;
-		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
-			t = random32() %
-				(pkt_dev->queue_map_max - pkt_dev->queue_map_min + 1)
-				+ pkt_dev->queue_map_min;
-		} else {
-			t = pkt_dev->cur_queue_map + 1;
-			if (t > pkt_dev->queue_map_max)
-				t = pkt_dev->queue_map_min;
-		}
-		pkt_dev->cur_queue_map = t;
-	}
+	set_cur_queue_map(pkt_dev);
 
 	pkt_dev->flows[flow].count++;
 }
@@ -2458,7 +2464,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
-
+	u16 queue_map;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2469,6 +2475,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
+	queue_map = pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
@@ -2507,7 +2514,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct iphdr);
 	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
-	skb_set_queue_mapping(skb, pkt_dev->cur_queue_map);
+	skb_set_queue_mapping(skb, queue_map);
 	iph = ip_hdr(skb);
 	udph = udp_hdr(skb);
 
@@ -2797,6 +2804,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
+	u16 queue_map;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2807,6 +2815,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
+	queue_map = pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
 
 	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + 16 +
@@ -2844,7 +2853,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
 	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
-	skb_set_queue_mapping(skb, pkt_dev->cur_queue_map);
+	skb_set_queue_mapping(skb, queue_map);
 	iph = ipv6_hdr(skb);
 	udph = udp_hdr(skb);
 
@@ -3265,6 +3274,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	struct netdev_queue *odev_queue;
 	struct net_device *odev = NULL;
 	__u64 idle_start = 0;
+	u16 queue_map;
 	int ret;
 
 	odev = pkt_dev->odev;
@@ -3286,7 +3296,14 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		}
 	}
 
-	odev_queue = dev_pick_tx(odev, pkt_dev->skb);
+	if (!pkt_dev->skb) {
+		set_cur_queue_map(pkt_dev);
+		queue_map = pkt_dev->cur_queue_map;
+	} else {
+		queue_map = skb_get_queue_mapping(pkt_dev->skb);
+	}
+
+	odev_queue = netdev_get_tx_queue(odev, queue_map);
 	if (netif_tx_queue_stopped(odev_queue) ||
 	    need_resched()) {
 		idle_start = getCurUs();
@@ -3330,6 +3347,10 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		}
 	}
 
+	/* fill_packet() might have changed the queue */
+	queue_map = skb_get_queue_mapping(pkt_dev->skb);
+	odev_queue = netdev_get_tx_queue(odev, queue_map);
+
 	__netif_tx_lock_bh(odev_queue);
 	if (!netif_tx_queue_stopped(odev_queue)) {
 
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
