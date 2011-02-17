From: Jiri Pirko <jpirko@redhat.com>
Subject: [RFC patch net-next-2.6] net: convert bonding to use rx_handler
Date: Thu, 17 Feb 2011 13:52:25 +0100
Message-ID: <20110217125221.GA10436@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756159Ab1BQMwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 07:52:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

This is an attempt to convert bonding to use rx_handler. Result should be
cleaner __netif_receive_skb() with much less exceptions needed. I think I
covered all aspects, not sure though. I gave this quick smoke test on my
testing env. Please comment, test.

Thanks!

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   75 ++++++++++++++++++++-
 include/linux/skbuff.h          |    1 +
 net/core/dev.c                  |  144 +++++++++++---------------------------
 3 files changed, 117 insertions(+), 103 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77e3c6a..7bfb74b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1423,6 +1423,68 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 	bond->setup_by_slave = 1;
 }
 
+/* On bonding slaves other than the currently active slave, suppress
+ * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
+ * ARP on active-backup slaves with arp_validate enabled.
+ */
+static bool bond_should_deliver_exact_match(struct sk_buff *skb,
+					    struct net_device *slave_dev,
+					    struct net_device *bond_dev)
+{
+	if (slave_dev->priv_flags & IFF_SLAVE_INACTIVE) {
+		if (slave_dev->priv_flags & IFF_SLAVE_NEEDARP &&
+		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
+			return false;
+
+		if (bond_dev->priv_flags & IFF_MASTER_ALB &&
+		    skb->pkt_type != PACKET_BROADCAST &&
+		    skb->pkt_type != PACKET_MULTICAST)
+				return false;
+
+		if (bond_dev->priv_flags & IFF_MASTER_8023AD &&
+		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
+			return false;
+
+		return true;
+	}
+	return false;
+}
+
+static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
+{
+	struct net_device *slave_dev;
+	struct net_device *bond_dev;
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		return NULL;
+	slave_dev = skb->dev;
+	bond_dev = slave_dev->master;
+	if (unlikely(!bond_dev))
+		return skb;
+
+	if (bond_dev->priv_flags & IFF_MASTER_ARPMON)
+		slave_dev->last_rx = jiffies;
+
+	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
+		skb->deliver_no_wcard = 1;
+		return skb;
+	}
+
+	skb->dev = bond_dev;
+
+	if (bond_dev->priv_flags & IFF_MASTER_ALB &&
+	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
+	    skb->pkt_type == PACKET_HOST) {
+		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
+
+		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
+	}
+
+	netif_rx(skb);
+	return NULL;
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1599,11 +1661,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		pr_debug("Error %d calling netdev_set_bond_master\n", res);
 		goto err_restore_mac;
 	}
+	res = netdev_rx_handler_register(slave_dev, bond_handle_frame, NULL);
+	if (res) {
+		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
+		goto err_unset_master;
+	}
+
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
 		pr_debug("Opening slave %s failed\n", slave_dev->name);
-		goto err_unset_master;
+		goto err_unreg_rxhandler;
 	}
 
 	new_slave->dev = slave_dev;
@@ -1811,6 +1879,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 err_close:
 	dev_close(slave_dev);
 
+err_unreg_rxhandler:
+	netdev_rx_handler_unregister(slave_dev);
+
 err_unset_master:
 	netdev_set_bond_master(slave_dev, NULL);
 
@@ -1992,6 +2063,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		netif_addr_unlock_bh(bond_dev);
 	}
 
+	netdev_rx_handler_unregister(slave_dev);
 	netdev_set_bond_master(slave_dev, NULL);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2114,6 +2186,7 @@ static int bond_release_all(struct net_device *bond_dev)
 			netif_addr_unlock_bh(bond_dev);
 		}
 
+		netdev_rx_handler_unregister(slave_dev);
 		netdev_set_bond_master(slave_dev, NULL);
 
 		/* close slave before restoring its mac address */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 31f02d0..15b54ea 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -325,6 +325,7 @@ struct sk_buff {
 
 	struct sock		*sk;
 	struct net_device	*dev;
+	struct net_device	*orig_dev;
 
 	/*
 	 * This is the control buffer. It is free to use for every
diff --git a/net/core/dev.c b/net/core/dev.c
index a413276..ae4381a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1530,12 +1530,17 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
+static inline int __deliver_skb(struct sk_buff *skb,
+				struct packet_type *pt_prev)
+{
+	return pt_prev->func(skb, skb->dev, pt_prev, skb->orig_dev);
+}
+
 static inline int deliver_skb(struct sk_buff *skb,
-			      struct packet_type *pt_prev,
-			      struct net_device *orig_dev)
+			      struct packet_type *pt_prev)
 {
 	atomic_inc(&skb->users);
-	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+	return __deliver_skb(skb, pt_prev);
 }
 
 /*
@@ -1558,7 +1563,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		    (ptype->af_packet_priv == NULL ||
 		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
 			if (pt_prev) {
-				deliver_skb(skb2, pt_prev, skb->dev);
+				deliver_skb(skb2, pt_prev);
 				pt_prev = ptype;
 				continue;
 			}
@@ -1591,7 +1596,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 	if (pt_prev)
-		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
+		__deliver_skb(skb2, pt_prev);
 	rcu_read_unlock();
 }
 
@@ -3020,8 +3025,7 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 }
 
 static inline struct sk_buff *handle_ing(struct sk_buff *skb,
-					 struct packet_type **pt_prev,
-					 int *ret, struct net_device *orig_dev)
+					 struct packet_type **pt_prev, int *ret)
 {
 	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
 
@@ -3029,7 +3033,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		goto out;
 
 	if (*pt_prev) {
-		*ret = deliver_skb(skb, *pt_prev, orig_dev);
+		*ret = deliver_skb(skb, *pt_prev);
 		*pt_prev = NULL;
 	}
 
@@ -3091,63 +3095,30 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
-static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
-					      struct net_device *master)
-{
-	if (skb->pkt_type == PACKET_HOST) {
-		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
-
-		memcpy(dest, master->dev_addr, ETH_ALEN);
-	}
-}
-
-/* On bonding slaves other than the currently active slave, suppress
- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
- * ARP on active-backup slaves with arp_validate enabled.
- */
-static int __skb_bond_should_drop(struct sk_buff *skb,
-				  struct net_device *master)
+static void vlan_on_bond_hook(struct sk_buff *skb)
 {
-	struct net_device *dev = skb->dev;
-
-	if (master->priv_flags & IFF_MASTER_ARPMON)
-		dev->last_rx = jiffies;
-
-	if ((master->priv_flags & IFF_MASTER_ALB) &&
-	    (master->priv_flags & IFF_BRIDGE_PORT)) {
-		/* Do address unmangle. The local destination address
-		 * will be always the one master has. Provides the right
-		 * functionality in a bridge.
-		 */
-		skb_bond_set_mac_by_master(skb, master);
-	}
-
-	if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
-		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
-		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
-			return 0;
-
-		if (master->priv_flags & IFF_MASTER_ALB) {
-			if (skb->pkt_type != PACKET_BROADCAST &&
-			    skb->pkt_type != PACKET_MULTICAST)
-				return 0;
-		}
-		if (master->priv_flags & IFF_MASTER_8023AD &&
-		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
-			return 0;
+	/*
+	 * Make sure ARP frames received on VLAN interfaces stacked on
+	 * bonding interfaces still make their way to any base bonding
+	 * device that may have registered for a specific ptype.
+	 */
+	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
+	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
+	    skb->protocol == htons(ETH_P_ARP)) {
+		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
-		return 1;
+		if (!skb2)
+			return;
+		skb2->dev = vlan_dev_real_dev(skb->dev);
+		netif_rx(skb2);
 	}
-	return 0;
 }
 
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
-	struct net_device *orig_dev;
-	struct net_device *null_or_orig;
-	struct net_device *orig_or_bond;
+	struct net_device *null_or_dev;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -3163,29 +3134,8 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
 
-	/*
-	 * bonding note: skbs received on inactive slaves should only
-	 * be delivered to pkt handlers that are exact matches.  Also
-	 * the deliver_no_wcard flag will be set.  If packet handlers
-	 * are sensitive to duplicate packets these skbs will need to
-	 * be dropped at the handler.
-	 */
-	null_or_orig = NULL;
-	orig_dev = skb->dev;
-	if (skb->deliver_no_wcard)
-		null_or_orig = orig_dev;
-	else if (netif_is_bond_slave(orig_dev)) {
-		struct net_device *bond_master = ACCESS_ONCE(orig_dev->master);
-
-		if (likely(bond_master)) {
-			if (__skb_bond_should_drop(skb, bond_master)) {
-				skb->deliver_no_wcard = 1;
-				/* deliver only exact match */
-				null_or_orig = orig_dev;
-			} else
-				skb->dev = bond_master;
-		}
-	}
+	if (!skb->orig_dev)
+		skb->orig_dev = skb->dev;
 
 	__this_cpu_inc(softnet_data.processed);
 	skb_reset_network_header(skb);
@@ -3204,26 +3154,24 @@ static int __netif_receive_skb(struct sk_buff *skb)
 #endif
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
-		    ptype->dev == orig_dev) {
+		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
-				ret = deliver_skb(skb, pt_prev, orig_dev);
+				ret = deliver_skb(skb, pt_prev);
 			pt_prev = ptype;
 		}
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
-	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
+	skb = handle_ing(skb, &pt_prev, &ret);
 	if (!skb)
 		goto out;
 ncls:
 #endif
 
-	/* Handle special case of bridge or macvlan */
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
 		if (pt_prev) {
-			ret = deliver_skb(skb, pt_prev, orig_dev);
+			ret = deliver_skb(skb, pt_prev);
 			pt_prev = NULL;
 		}
 		skb = rx_handler(skb);
@@ -3233,7 +3181,7 @@ ncls:
 
 	if (vlan_tx_tag_present(skb)) {
 		if (pt_prev) {
-			ret = deliver_skb(skb, pt_prev, orig_dev);
+			ret = deliver_skb(skb, pt_prev);
 			pt_prev = NULL;
 		}
 		if (vlan_hwaccel_do_receive(&skb)) {
@@ -3243,32 +3191,24 @@ ncls:
 			goto out;
 	}
 
-	/*
-	 * Make sure frames received on VLAN interfaces stacked on
-	 * bonding interfaces still make their way to any base bonding
-	 * device that may have registered for a specific ptype.  The
-	 * handler may have to adjust skb->dev and orig_dev.
-	 */
-	orig_or_bond = orig_dev;
-	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
-	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
-		orig_or_bond = vlan_dev_real_dev(skb->dev);
-	}
+	vlan_on_bond_hook(skb);
+
+	/* deliver only exact match when indicated */
+	null_or_dev = skb->deliver_no_wcard ? skb->dev : NULL;
 
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
-		if (ptype->type == type && (ptype->dev == null_or_orig ||
-		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
-		     ptype->dev == orig_or_bond)) {
+		if (ptype->type == type &&
+		    (ptype->dev == null_or_dev || ptype->dev == skb->dev)) {
 			if (pt_prev)
-				ret = deliver_skb(skb, pt_prev, orig_dev);
+				ret = deliver_skb(skb, pt_prev);
 			pt_prev = ptype;
 		}
 	}
 
 	if (pt_prev) {
-		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+		ret = __deliver_skb(skb, pt_prev);
 	} else {
 		atomic_long_inc(&skb->dev->rx_dropped);
 		kfree_skb(skb);
-- 
1.7.3.4

