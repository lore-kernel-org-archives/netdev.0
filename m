From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: convert bonding to use rx_handler - second
 part
Date: Mon, 28 Feb 2011 10:55:25 +0100
Message-ID: <20110228095524.GA4043@psychotron.brq.redhat.com>
References: <20110227125816.GB2814@psychotron.redhat.com>
 <20110227.152208.102543719.davem@davemloft.net>
 <20110228070732.GA2793@psychotron.redhat.com>
 <20110227.233013.226766890.davem@davemloft.net>
 <20110228092222.GA2831@psychotron.brq.redhat.com>
 <1298885725.2941.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab1B1Jz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 04:55:28 -0500
Content-Disposition: inline
In-Reply-To: <1298885725.2941.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts bonding to use rx_handler. Results in cleaner
__netif_receive_skb() with much less exceptions needed.

Did performance test using pktgen and counting incoming packets by
iptables. No regression noted.

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/core/dev.c |  119 ++++++++++++++----------------------------------=
-------
 1 files changed, 31 insertions(+), 88 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 69a3c08..30440e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3096,63 +3096,31 @@ void netdev_rx_handler_unregister(struct net_de=
vice *dev)
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
=20
-static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
-					      struct net_device *master)
+static void vlan_on_bond_hook(struct sk_buff *skb)
 {
-	if (skb->pkt_type =3D=3D PACKET_HOST) {
-		u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;
+	/*
+	 * Make sure ARP frames received on VLAN interfaces stacked on
+	 * bonding interfaces still make their way to any base bonding
+	 * device that may have registered for a specific ptype.
+	 */
+	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
+	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
+	    skb->protocol =3D=3D htons(ETH_P_ARP)) {
+		struct sk_buff *skb2 =3D skb_clone(skb, GFP_ATOMIC);
=20
-		memcpy(dest, master->dev_addr, ETH_ALEN);
+		if (!skb2)
+			return;
+		skb2->dev =3D vlan_dev_real_dev(skb->dev);
+		netif_rx(skb2);
 	}
 }
=20
-/* On bonding slaves other than the currently active slave, suppress
- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
- * ARP on active-backup slaves with arp_validate enabled.
- */
-static int __skb_bond_should_drop(struct sk_buff *skb,
-				  struct net_device *master)
-{
-	struct net_device *dev =3D skb->dev;
-
-	if (master->priv_flags & IFF_MASTER_ARPMON)
-		dev->last_rx =3D jiffies;
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
-		    skb->protocol =3D=3D __cpu_to_be16(ETH_P_ARP))
-			return 0;
-
-		if (master->priv_flags & IFF_MASTER_ALB) {
-			if (skb->pkt_type !=3D PACKET_BROADCAST &&
-			    skb->pkt_type !=3D PACKET_MULTICAST)
-				return 0;
-		}
-		if (master->priv_flags & IFF_MASTER_8023AD &&
-		    skb->protocol =3D=3D __cpu_to_be16(ETH_P_SLOW))
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
 	int ret =3D NET_RX_DROP;
 	__be16 type;
=20
@@ -3167,32 +3135,8 @@ static int __netif_receive_skb(struct sk_buff *s=
kb)
=20
 	if (!skb->skb_iif)
 		skb->skb_iif =3D skb->dev->ifindex;
-
-	/*
-	 * bonding note: skbs received on inactive slaves should only
-	 * be delivered to pkt handlers that are exact matches.  Also
-	 * the deliver_no_wcard flag will be set.  If packet handlers
-	 * are sensitive to duplicate packets these skbs will need to
-	 * be dropped at the handler.
-	 */
-	null_or_orig =3D NULL;
 	orig_dev =3D skb->dev;
-	if (skb->deliver_no_wcard)
-		null_or_orig =3D orig_dev;
-	else if (netif_is_bond_slave(orig_dev)) {
-		struct net_device *bond_master =3D ACCESS_ONCE(orig_dev->master);
-
-		if (likely(bond_master)) {
-			if (__skb_bond_should_drop(skb, bond_master)) {
-				skb->deliver_no_wcard =3D 1;
-				/* deliver only exact match */
-				null_or_orig =3D orig_dev;
-			} else
-				skb->dev =3D bond_master;
-		}
-	}
=20
-	__this_cpu_inc(softnet_data.processed);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len =3D skb->network_header - skb->mac_header;
@@ -3201,6 +3145,10 @@ static int __netif_receive_skb(struct sk_buff *s=
kb)
=20
 	rcu_read_lock();
=20
+another_round:
+
+	__this_cpu_inc(softnet_data.processed);
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd =3D CLR_TC_NCLS(skb->tc_verd);
@@ -3209,8 +3157,7 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 #endif
=20
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (ptype->dev =3D=3D null_or_orig || ptype->dev =3D=3D skb->dev ||
-		    ptype->dev =3D=3D orig_dev) {
+		if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
 			if (pt_prev)
 				ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D ptype;
@@ -3224,16 +3171,20 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
 ncls:
 #endif
=20
-	/* Handle special case of bridge or macvlan */
 	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
+		struct net_device *prev_dev;
+
 		if (pt_prev) {
 			ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D NULL;
 		}
+		prev_dev =3D skb->dev;
 		skb =3D rx_handler(skb);
 		if (!skb)
 			goto out;
+		if (skb->dev !=3D prev_dev)
+			goto another_round;
 	}
=20
 	if (vlan_tx_tag_present(skb)) {
@@ -3248,24 +3199,16 @@ ncls:
 			goto out;
 	}
=20
-	/*
-	 * Make sure frames received on VLAN interfaces stacked on
-	 * bonding interfaces still make their way to any base bonding
-	 * device that may have registered for a specific ptype.  The
-	 * handler may have to adjust skb->dev and orig_dev.
-	 */
-	orig_or_bond =3D orig_dev;
-	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
-	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
-		orig_or_bond =3D vlan_dev_real_dev(skb->dev);
-	}
+	vlan_on_bond_hook(skb);
+
+	/* deliver only exact match when indicated */
+	null_or_dev =3D skb->deliver_no_wcard ? skb->dev : NULL;
=20
 	type =3D skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
-		if (ptype->type =3D=3D type && (ptype->dev =3D=3D null_or_orig ||
-		     ptype->dev =3D=3D skb->dev || ptype->dev =3D=3D orig_dev ||
-		     ptype->dev =3D=3D orig_or_bond)) {
+		if (ptype->type =3D=3D type &&
+		    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D skb->dev)) {
 			if (pt_prev)
 				ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D ptype;
--=20
1.7.3.4

