From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next-2.6 V2] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 15:06:11 -0800
Message-ID: <21593.1298070371@death>
References: <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com> <20110218.120656.104048936.davem@davemloft.net> <20110218205832.GE2602@psychotron.redhat.com>
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:36647 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520Ab1BRXGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 18:06:20 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1IMre6f013276
	for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 15:53:40 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1IN6E8K072092
	for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 16:06:15 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1IN6DCA006195
	for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 16:06:14 -0700
In-reply-to: <20110218205832.GE2602@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>This patch converts bonding to use rx_handler. Results in cleaner
>__netif_receive_skb() with much less exceptions needed. Also bond-specific
>work is moved into bond code.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>v1->v2:
>	using skb_iif instead of new input_dev to remember original device
>
>---
> drivers/net/bonding/bond_main.c |   75 ++++++++++++++++++++++++++-
> net/core/dev.c                  |  111 ++++++++-------------------------------
> 2 files changed, 97 insertions(+), 89 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 77e3c6a..a856a11 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1423,6 +1423,68 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
> 	bond->setup_by_slave = 1;
> }
>
>+/* On bonding slaves other than the currently active slave, suppress
>+ * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
>+ * ARP on active-backup slaves with arp_validate enabled.
>+ */
>+static bool bond_should_deliver_exact_match(struct sk_buff *skb,
>+					    struct net_device *slave_dev,
>+					    struct net_device *bond_dev)
>+{
>+	if (slave_dev->priv_flags & IFF_SLAVE_INACTIVE) {
>+		if (slave_dev->priv_flags & IFF_SLAVE_NEEDARP &&
>+		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
>+			return false;
>+
>+		if (bond_dev->priv_flags & IFF_MASTER_ALB &&
>+		    skb->pkt_type != PACKET_BROADCAST &&
>+		    skb->pkt_type != PACKET_MULTICAST)
>+				return false;
>+
>+		if (bond_dev->priv_flags & IFF_MASTER_8023AD &&
>+		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
>+			return false;

	Since this is all in the bonding code now, it should be possible
to do away with using priv_flags for all (or at least most) of this.
Perhaps in a follow-on patch.

>+
>+		return true;
>+	}
>+	return false;
>+}
>+
>+static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
>+{
>+	struct net_device *slave_dev;
>+	struct net_device *bond_dev;
>+
>+	skb = skb_share_check(skb, GFP_ATOMIC);
>+	if (unlikely(!skb))
>+		return NULL;
>+	slave_dev = skb->dev;
>+	bond_dev = ACCESS_ONCE(slave_dev->master);
>+	if (unlikely(!bond_dev))
>+		return skb;
>+
>+	if (bond_dev->priv_flags & IFF_MASTER_ARPMON)
>+		slave_dev->last_rx = jiffies;

	The last_rx field could probably move into bonding as well,
although it looks like there are a couple of drivers using last_rx for
something (more than just setting it).

>+	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
>+		skb->deliver_no_wcard = 1;
>+		return skb;
>+	}
>+
>+	skb->dev = bond_dev;
>+
>+	if (bond_dev->priv_flags & IFF_MASTER_ALB &&
>+	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
>+	    skb->pkt_type == PACKET_HOST) {
>+		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
>+
>+		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
>+	}
>+
>+	netif_rx(skb);
>+	return NULL;
>+}
>+
> /* enslave device <slave> to bond device <master> */
> int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> {
>@@ -1599,11 +1661,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		pr_debug("Error %d calling netdev_set_bond_master\n", res);
> 		goto err_restore_mac;
> 	}
>+	res = netdev_rx_handler_register(slave_dev, bond_handle_frame, NULL);
>+	if (res) {
>+		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
>+		goto err_unset_master;
>+	}
>+
> 	/* open the slave since the application closed it */
> 	res = dev_open(slave_dev);
> 	if (res) {
> 		pr_debug("Opening slave %s failed\n", slave_dev->name);
>-		goto err_unset_master;
>+		goto err_unreg_rxhandler;
> 	}
>
> 	new_slave->dev = slave_dev;
>@@ -1811,6 +1879,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> err_close:
> 	dev_close(slave_dev);
>
>+err_unreg_rxhandler:
>+	netdev_rx_handler_unregister(slave_dev);
>+
> err_unset_master:
> 	netdev_set_bond_master(slave_dev, NULL);
>
>@@ -1992,6 +2063,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 		netif_addr_unlock_bh(bond_dev);
> 	}
>
>+	netdev_rx_handler_unregister(slave_dev);
> 	netdev_set_bond_master(slave_dev, NULL);
>
> #ifdef CONFIG_NET_POLL_CONTROLLER
>@@ -2114,6 +2186,7 @@ static int bond_release_all(struct net_device *bond_dev)
> 			netif_addr_unlock_bh(bond_dev);
> 		}
>
>+		netdev_rx_handler_unregister(slave_dev);
> 		netdev_set_bond_master(slave_dev, NULL);
>
> 		/* close slave before restoring its mac address */
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 4f69439..580cff1 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3092,63 +3092,31 @@ void netdev_rx_handler_unregister(struct net_device *dev)
> }
> EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
>
>-static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
>-					      struct net_device *master)
>+static void vlan_on_bond_hook(struct sk_buff *skb)
> {
>-	if (skb->pkt_type == PACKET_HOST) {
>-		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
>-
>-		memcpy(dest, master->dev_addr, ETH_ALEN);
>-	}
>-}
>-
>-/* On bonding slaves other than the currently active slave, suppress
>- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
>- * ARP on active-backup slaves with arp_validate enabled.
>- */
>-static int __skb_bond_should_drop(struct sk_buff *skb,
>-				  struct net_device *master)
>-{
>-	struct net_device *dev = skb->dev;
>-
>-	if (master->priv_flags & IFF_MASTER_ARPMON)
>-		dev->last_rx = jiffies;
>-
>-	if ((master->priv_flags & IFF_MASTER_ALB) &&
>-	    (master->priv_flags & IFF_BRIDGE_PORT)) {
>-		/* Do address unmangle. The local destination address
>-		 * will be always the one master has. Provides the right
>-		 * functionality in a bridge.
>-		 */
>-		skb_bond_set_mac_by_master(skb, master);
>-	}
>-
>-	if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
>-		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
>-		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
>-			return 0;
>-
>-		if (master->priv_flags & IFF_MASTER_ALB) {
>-			if (skb->pkt_type != PACKET_BROADCAST &&
>-			    skb->pkt_type != PACKET_MULTICAST)
>-				return 0;
>-		}
>-		if (master->priv_flags & IFF_MASTER_8023AD &&
>-		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
>-			return 0;
>+	/*
>+	 * Make sure ARP frames received on VLAN interfaces stacked on
>+	 * bonding interfaces still make their way to any base bonding
>+	 * device that may have registered for a specific ptype.
>+	 */
>+	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
>+	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
>+	    skb->protocol == htons(ETH_P_ARP)) {
>+		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
>
>-		return 1;
>+		if (!skb2)
>+			return;
>+		skb2->dev = vlan_dev_real_dev(skb->dev);
>+		netif_rx(skb2);
> 	}
>-	return 0;
> }
>
> static int __netif_receive_skb(struct sk_buff *skb)
> {
> 	struct packet_type *ptype, *pt_prev;
> 	rx_handler_func_t *rx_handler;
>+	struct net_device *null_or_dev;
> 	struct net_device *orig_dev;
>-	struct net_device *null_or_orig;
>-	struct net_device *orig_or_bond;
> 	int ret = NET_RX_DROP;
> 	__be16 type;
>
>@@ -3164,30 +3132,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 	if (!skb->skb_iif)
> 		skb->skb_iif = skb->dev->ifindex;
>
>-	/*
>-	 * bonding note: skbs received on inactive slaves should only
>-	 * be delivered to pkt handlers that are exact matches.  Also
>-	 * the deliver_no_wcard flag will be set.  If packet handlers
>-	 * are sensitive to duplicate packets these skbs will need to
>-	 * be dropped at the handler.
>-	 */
>-	null_or_orig = NULL;
>-	orig_dev = skb->dev;
>-	if (skb->deliver_no_wcard)
>-		null_or_orig = orig_dev;
>-	else if (netif_is_bond_slave(orig_dev)) {
>-		struct net_device *bond_master = ACCESS_ONCE(orig_dev->master);
>-
>-		if (likely(bond_master)) {
>-			if (__skb_bond_should_drop(skb, bond_master)) {
>-				skb->deliver_no_wcard = 1;
>-				/* deliver only exact match */
>-				null_or_orig = orig_dev;
>-			} else
>-				skb->dev = bond_master;
>-		}
>-	}
>-
> 	__this_cpu_inc(softnet_data.processed);
> 	skb_reset_network_header(skb);
> 	skb_reset_transport_header(skb);
>@@ -3196,6 +3140,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 	pt_prev = NULL;
>
> 	rcu_read_lock();
>+	orig_dev = dev_get_by_index_rcu(dev_net(skb->dev), skb->skb_iif);

	Aren't most packets going to have orig_dev == skb->dev at this
point?  Can this be combined with the skb_iif test a few lines above
this in __netif_receive_skb, looking something like:

	if (!skb->skb_iif) {
		skb->skb_iif = skb->dev->ifindex;
		orig_dev = skb->dev;
	else {
		orig_dev = dev_get_by_index_rcu(...);
	}

	Presumably moving the whole thing down inside the rcu_read_lock.

	VLAN packets should come through here twice, but the first time
through is before the call to vlan_hwaccel_do_receive, so skb->dev
hasn't been set to the VLAN's dev yet.

	Unless, of course, you find a place to store the orig_dev.

	-J

> #ifdef CONFIG_NET_CLS_ACT
> 	if (skb->tc_verd & TC_NCLS) {
>@@ -3205,8 +3150,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
> #endif
>
> 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
>-		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
>-		    ptype->dev == orig_dev) {
>+		if (!ptype->dev || ptype->dev == skb->dev) {
> 			if (pt_prev)
> 				ret = deliver_skb(skb, pt_prev, orig_dev);
> 			pt_prev = ptype;
>@@ -3220,7 +3164,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
> ncls:
> #endif
>
>-	/* Handle special case of bridge or macvlan */
> 	rx_handler = rcu_dereference(skb->dev->rx_handler);
> 	if (rx_handler) {
> 		if (pt_prev) {
>@@ -3244,24 +3187,16 @@ ncls:
> 			goto out;
> 	}
>
>-	/*
>-	 * Make sure frames received on VLAN interfaces stacked on
>-	 * bonding interfaces still make their way to any base bonding
>-	 * device that may have registered for a specific ptype.  The
>-	 * handler may have to adjust skb->dev and orig_dev.
>-	 */
>-	orig_or_bond = orig_dev;
>-	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
>-	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
>-		orig_or_bond = vlan_dev_real_dev(skb->dev);
>-	}
>+	vlan_on_bond_hook(skb);
>+
>+	/* deliver only exact match when indicated */
>+	null_or_dev = skb->deliver_no_wcard ? skb->dev : NULL;
>
> 	type = skb->protocol;
> 	list_for_each_entry_rcu(ptype,
> 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>-		if (ptype->type == type && (ptype->dev == null_or_orig ||
>-		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
>-		     ptype->dev == orig_or_bond)) {
>+		if (ptype->type == type &&
>+		    (ptype->dev == null_or_dev || ptype->dev == skb->dev)) {
> 			if (pt_prev)
> 				ret = deliver_skb(skb, pt_prev, orig_dev);
> 			pt_prev = ptype;
>-- 
>1.7.3.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
