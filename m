From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Wed, 23 Feb 2011 20:05:42 +0100
Message-ID: <20110223190541.GB2783@psychotron.redhat.com>
References: <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <20110218.120656.104048936.davem@davemloft.net>
 <20110218205832.GE2602@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932122Ab1BWTHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 14:07:55 -0500
Content-Disposition: inline
In-Reply-To: <20110218205832.GE2602@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts bonding to use rx_handler. Results in cleaner
__netif_receive_skb() with much less exceptions needed. Also
bond-specific work is moved into bond code.

Did performance test using pktgen and counting incoming packets by
iptables. No regression noted.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

v1->v2:
        using skb_iif instead of new input_dev to remember original
	device

v2->v3:
	do another loop in case skb->dev is changed. That way orig_dev
	core can be left untouched.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   74 ++++++++++++++++++++++++-
 net/core/dev.c                  |  119 ++++++++++-----------------------------
 2 files changed, 104 insertions(+), 89 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77e3c6a..3772b61 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1423,6 +1423,67 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
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
+	bond_dev = ACCESS_ONCE(slave_dev->master);
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
+	return skb;
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1599,11 +1660,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1811,6 +1878,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 err_close:
 	dev_close(slave_dev);
 
+err_unreg_rxhandler:
+	netdev_rx_handler_unregister(slave_dev);
+
 err_unset_master:
 	netdev_set_bond_master(slave_dev, NULL);
 
@@ -1992,6 +2062,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		netif_addr_unlock_bh(bond_dev);
 	}
 
+	netdev_rx_handler_unregister(slave_dev);
 	netdev_set_bond_master(slave_dev, NULL);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2114,6 +2185,7 @@ static int bond_release_all(struct net_device *bond_dev)
 			netif_addr_unlock_bh(bond_dev);
 		}
 
+		netdev_rx_handler_unregister(slave_dev);
 		netdev_set_bond_master(slave_dev, NULL);
 
 		/* close slave before restoring its mac address */
diff --git a/net/core/dev.c b/net/core/dev.c
index 578415c..e06a834 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3096,63 +3096,31 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
-static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
-					      struct net_device *master)
+static void vlan_on_bond_hook(struct sk_buff *skb)
 {
-	if (skb->pkt_type == PACKET_HOST) {
-		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
+	/*
+	 * Make sure ARP frames received on VLAN interfaces stacked on
+	 * bonding interfaces still make their way to any base bonding
+	 * device that may have registered for a specific ptype.
+	 */
+	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
+	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
+	    skb->protocol == htons(ETH_P_ARP)) {
+		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
-		memcpy(dest, master->dev_addr, ETH_ALEN);
+		if (!skb2)
+			return;
+		skb2->dev = vlan_dev_real_dev(skb->dev);
+		netif_rx(skb2);
 	}
 }
 
-/* On bonding slaves other than the currently active slave, suppress
- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
- * ARP on active-backup slaves with arp_validate enabled.
- */
-static int __skb_bond_should_drop(struct sk_buff *skb,
-				  struct net_device *master)
-{
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
-
-		return 1;
-	}
-	return 0;
-}
-
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
 	struct net_device *orig_dev;
-	struct net_device *null_or_orig;
-	struct net_device *orig_or_bond;
+	struct net_device *null_or_dev;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -3167,32 +3135,8 @@ static int __netif_receive_skb(struct sk_buff *skb)
 
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
-
-	/*
-	 * bonding note: skbs received on inactive slaves should only
-	 * be delivered to pkt handlers that are exact matches.  Also
-	 * the deliver_no_wcard flag will be set.  If packet handlers
-	 * are sensitive to duplicate packets these skbs will need to
-	 * be dropped at the handler.
-	 */
-	null_or_orig = NULL;
 	orig_dev = skb->dev;
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
 
-	__this_cpu_inc(softnet_data.processed);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
@@ -3201,6 +3145,10 @@ static int __netif_receive_skb(struct sk_buff *skb)
 
 	rcu_read_lock();
 
+another_round:
+
+	__this_cpu_inc(softnet_data.processed);
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
@@ -3209,8 +3157,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 #endif
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
-		    ptype->dev == orig_dev) {
+		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
@@ -3224,16 +3171,20 @@ static int __netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
 
-	/* Handle special case of bridge or macvlan */
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
+		struct net_device *prev_dev;
+
 		if (pt_prev) {
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
+		prev_dev = skb->dev;
 		skb = rx_handler(skb);
 		if (!skb)
 			goto out;
+		if (skb->dev != prev_dev)
+			goto another_round;
 	}
 
 	if (vlan_tx_tag_present(skb)) {
@@ -3248,24 +3199,16 @@ ncls:
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
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
-- 
1.7.3.4

