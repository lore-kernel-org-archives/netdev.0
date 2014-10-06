From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Sun, 05 Oct 2014 18:38:35 -0700
Message-ID: <1412559515.11091.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35466 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbaJFBii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:38:38 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so4444559pab.18
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 18:38:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Testing xmit_more support with netperf and connected UDP sockets,
I found strange dst refcount false sharing.

Current handling of IFF_XMIT_DST_RELEASE is not optimal.

Dropping dst in validate_xmit_skb() is certainly too late in case
packet was queued by cpu X but dequeued by cpu Y

The logical point to take care of drop/force is in __dev_queue_xmit()
before even taking qdisc lock.

As Julian Anastasov pointed out, need for skb_dst() might come from some
packet schedulers or classifiers.

This patch adds new helper to cleanly express needs of various drivers
or qdiscs/classifiers.

Drivers that need skb_dst() in their ndo_start_xmit() should call
following helper in their setup instead of the prior :

	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
->
	netif_keep_dst(dev);

Instead of using a single bit, we use two bits, one being
eventually rebuilt in bonding/team drivers.

The other one, is permanent and blocks IFF_XMIT_DST_RELEASE being
rebuilt in bonding/team. Eventually, we could add something
smarter later.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    2 +-
 drivers/net/appletalk/ipddp.c             |    2 +-
 drivers/net/bonding/bond_main.c           |    9 ++++++---
 drivers/net/eql.c                         |    2 +-
 drivers/net/ifb.c                         |    3 ++-
 drivers/net/loopback.c                    |    2 +-
 drivers/net/macvlan.c                     |    3 ++-
 drivers/net/ppp/ppp_generic.c             |    2 +-
 drivers/net/team/team.c                   |    8 +++++---
 drivers/net/vxlan.c                       |    2 +-
 drivers/net/wan/hdlc_fr.c                 |    2 +-
 drivers/s390/net/qeth_l3_main.c           |    2 +-
 include/linux/netdevice.h                 |    8 ++++++++
 net/8021q/vlan_dev.c                      |    3 ++-
 net/atm/clip.c                            |    2 +-
 net/core/dev.c                            |   19 +++++++++----------
 net/ipv4/ip_gre.c                         |    2 +-
 net/ipv4/ip_vti.c                         |    2 +-
 net/ipv4/ipip.c                           |    2 +-
 net/ipv6/ip6_gre.c                        |    2 +-
 net/ipv6/ip6_tunnel.c                     |    2 +-
 net/ipv6/ip6_vti.c                        |    2 +-
 net/ipv6/sit.c                            |    2 +-
 net/sched/cls_flow.c                      |    2 ++
 net/sched/cls_route.c                     |    1 +
 net/sched/sch_generic.c                   |    3 ---
 net/sched/sch_teql.c                      |    2 +-
 27 files changed, 54 insertions(+), 39 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 13e6e0431592..58b5aa3b6f2d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1364,7 +1364,7 @@ void ipoib_setup(struct net_device *dev)
 	dev->tx_queue_len	 = ipoib_sendq_size * 2;
 	dev->features		 = (NETIF_F_VLAN_CHALLENGED	|
 				    NETIF_F_HIGHDMA);
-	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 
 	memcpy(dev->broadcast, ipv4_bcast_addr, INFINIBAND_ALEN);
 
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 10d0dba572c2..e90c6a7333d7 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -74,7 +74,7 @@ static struct net_device * __init ipddp_init(void)
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 	strcpy(dev->name, "ipddp%d");
 
 	if (version_printed++ == 0)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c2adc2755ff6..ff6df7b0c056 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1001,7 +1001,8 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 
 static void bond_compute_features(struct bonding *bond)
 {
-	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
+	unsigned int dst_release_flag = IFF_XMIT_DST_RELEASE |
+					IFF_XMIT_DST_RELEASE_PERM;
 	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
 	netdev_features_t enc_features  = BOND_ENC_FEATURES;
 	struct net_device *bond_dev = bond->dev;
@@ -1037,8 +1038,10 @@ done:
 	bond_dev->gso_max_segs = gso_max_segs;
 	netif_set_gso_max_size(bond_dev, gso_max_size);
 
-	flags = bond_dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
-	bond_dev->priv_flags = flags | dst_release_flag;
+	bond_dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	if ((bond_dev->priv_flags & IFF_XMIT_DST_RELEASE_PERM) &&
+	    dst_release_flag == (IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM))
+		bond_dev->priv_flags |= IFF_XMIT_DST_RELEASE;
 
 	netdev_change_features(bond_dev);
 }
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 957e5c0cede3..a10ad74cc8d2 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -199,7 +199,7 @@ static void __init eql_setup(struct net_device *dev)
 
 	dev->type       	= ARPHRD_SLIP;
 	dev->tx_queue_len 	= 5;		/* Hands them off fast */
-	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 }
 
 static int eql_open(struct net_device *dev)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index d2d4a3d2237f..34f846b4bd05 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -185,7 +185,8 @@ static void ifb_setup(struct net_device *dev)
 
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
-	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	netif_keep_dst(dev);
 	eth_hw_addr_random(dev);
 }
 
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 8f2262540561..c76283c2f84a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -169,7 +169,7 @@ static void loopback_setup(struct net_device *dev)
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
 	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
-	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
 		| NETIF_F_ALL_TSO
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index e8a453f1b458..38b4fae61f04 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1025,7 +1025,8 @@ void macvlan_common_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
-	dev->priv_flags	       &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags	       &= ~IFF_TX_SKB_SHARING;
+	netif_keep_dst(dev);
 	dev->priv_flags	       |= IFF_UNICAST_FLT;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index fa0d71727894..80e6f3430f65 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1103,7 +1103,7 @@ static void ppp_setup(struct net_device *dev)
 	dev->type = ARPHRD_PPP;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
 	dev->features |= NETIF_F_NETNS_LOCAL;
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 }
 
 /*
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2277c3679a51..a94a9df3e6bd 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -970,7 +970,8 @@ static void __team_compute_features(struct team *team)
 	struct team_port *port;
 	u32 vlan_features = TEAM_VLAN_FEATURES & NETIF_F_ALL_FOR_ALL;
 	unsigned short max_hard_header_len = ETH_HLEN;
-	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
+	unsigned int dst_release_flag = IFF_XMIT_DST_RELEASE |
+					IFF_XMIT_DST_RELEASE_PERM;
 
 	list_for_each_entry(port, &team->port_list, list) {
 		vlan_features = netdev_increment_features(vlan_features,
@@ -985,8 +986,9 @@ static void __team_compute_features(struct team *team)
 	team->dev->vlan_features = vlan_features;
 	team->dev->hard_header_len = max_hard_header_len;
 
-	flags = team->dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
-	team->dev->priv_flags = flags | dst_release_flag;
+	team->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	if (dst_release_flag == (IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM))
+		team->dev->priv_flags |= IFF_XMIT_DST_RELEASE;
 
 	netdev_change_features(team->dev);
 }
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2af795d6ba05..2a51e6e48e1e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2193,7 +2193,7 @@ static void vxlan_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
-	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
 	INIT_LIST_HEAD(&vxlan->next);
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index e5c7e6165a4b..3ebed1c40abb 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1047,7 +1047,7 @@ static void pvc_setup(struct net_device *dev)
 	dev->flags = IFF_POINTOPOINT;
 	dev->hard_header_len = 10;
 	dev->addr_len = 2;
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 }
 
 static const struct net_device_ops pvc_ops = {
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index f8427a2c4840..afebb9709763 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3306,7 +3306,7 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 	card->dev->features |=	NETIF_F_HW_VLAN_CTAG_TX |
 				NETIF_F_HW_VLAN_CTAG_RX |
 				NETIF_F_HW_VLAN_CTAG_FILTER;
-	card->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(card->dev);
 	card->dev->gso_max_size = 15 * PAGE_SIZE;
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 22d54b9b700d..d5680f6278d2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1206,6 +1206,7 @@ enum netdev_priv_flags {
 	IFF_SUPP_NOFCS			= 1<<19,
 	IFF_LIVE_ADDR_CHANGE		= 1<<20,
 	IFF_MACVLAN			= 1<<21,
+	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1230,6 +1231,7 @@ enum netdev_priv_flags {
 #define IFF_SUPP_NOFCS			IFF_SUPP_NOFCS
 #define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
 #define IFF_MACVLAN			IFF_MACVLAN
+#define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -3586,6 +3588,12 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
+/* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
+static inline void netif_keep_dst(struct net_device *dev)
+{
+	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM);
+}
+
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 35a6b6b15e8a..0d441ec8763e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -799,7 +799,8 @@ void vlan_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags		|= IFF_802_1Q_VLAN;
-	dev->priv_flags		&= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags		&= ~IFF_TX_SKB_SHARING;
+	netif_keep_dst(dev);
 	dev->tx_queue_len	= 0;
 
 	dev->netdev_ops		= &vlan_netdev_ops;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 1d9eaa4f041a..17e55dfecbe2 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -501,7 +501,7 @@ static void clip_setup(struct net_device *dev)
 	/* without any more elaborate queuing. 100 is a reasonable */
 	/* compromise between decent burst-tolerance and protection */
 	/* against memory hogs. */
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 }
 
 static int clip_create(int number)
diff --git a/net/core/dev.c b/net/core/dev.c
index 1a90530f83ff..3da8bac5cab9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2662,12 +2662,6 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 	if (skb->next)
 		return skb;
 
-	/* If device doesn't need skb->dst, release it right now while
-	 * its hot in this cpu cache
-	 */
-	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
-		skb_dst_drop(skb);
-
 	features = netif_skb_features(skb);
 	skb = validate_xmit_vlan(skb, features);
 	if (unlikely(!skb))
@@ -2805,8 +2799,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		 * waiting to be sent out; and the qdisc is not running -
 		 * xmit the skb directly.
 		 */
-		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
-			skb_dst_force(skb);
 
 		qdisc_bstats_update(q, skb);
 
@@ -2821,7 +2813,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		rc = NET_XMIT_SUCCESS;
 	} else {
-		skb_dst_force(skb);
 		rc = q->enqueue(skb, q) & NET_XMIT_MASK;
 		if (qdisc_run_begin(q)) {
 			if (unlikely(contended)) {
@@ -2918,6 +2909,14 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	skb_update_prio(skb);
 
+	/* If device/qdisc don't need skb->dst, release it right now while
+	 * its hot in this cpu cache.
+	 */
+	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+		skb_dst_drop(skb);
+	else
+		skb_dst_force(skb);
+
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
@@ -6667,7 +6666,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->adj_list.lower);
 	INIT_LIST_HEAD(&dev->all_adj_list.upper);
 	INIT_LIST_HEAD(&dev->all_adj_list.lower);
-	dev->priv_flags = IFF_XMIT_DST_RELEASE;
+	dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM;
 	setup(dev);
 
 	dev->num_tx_queues = txqs;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0485ef18d254..12055fdbe716 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -510,7 +510,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	memcpy(dev->broadcast, &iph->daddr, 4);
 
 	dev->flags		= IFF_NOARP;
-	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 	dev->addr_len		= 4;
 
 	if (iph->daddr) {
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index e453cb724a95..3e861011e4a3 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -364,7 +364,7 @@ static int vti_tunnel_init(struct net_device *dev)
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_LLTX;
-	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 
 	return ip_tunnel_init(dev);
 }
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index ea88ab3102a8..37096d64730e 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -289,7 +289,7 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_LLTX;
-	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 
 	dev->features		|= IPIP_FEATURES;
 	dev->hw_features	|= IPIP_FEATURES;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 74b677916a70..de3b1c86b8d3 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1242,7 +1242,7 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->iflink = 0;
 	dev->addr_len = sizeof(struct in6_addr);
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 }
 
 static int ip6gre_tunnel_init(struct net_device *dev)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index d3e8888ad611..9409887fb664 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1493,7 +1493,7 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 		dev->mtu -= 8;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 	/* This perm addr will be used as interface identifier by IPv6 */
 	dev->addr_assign_type = NET_ADDR_RANDOM;
 	eth_random_addr(dev->perm_addr);
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 5833a2244467..d440bb585524 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -807,7 +807,7 @@ static void vti6_dev_setup(struct net_device *dev)
 	dev->mtu = ETH_DATA_LEN;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 }
 
 /**
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0d4e27466f82..6eab37cf5345 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1364,7 +1364,7 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->hard_header_len	= LL_MAX_HEADER + t_hlen;
 	dev->mtu		= ETH_DATA_LEN - t_hlen;
 	dev->flags		= IFF_NOARP;
-	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_LLTX;
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index f18d27f7b5f2..5f79e1174b55 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -493,6 +493,8 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	tcf_exts_change(tp, &fnew->exts, &e);
 	tcf_em_tree_change(tp, &fnew->ematches, &t);
 
+	netif_keep_dst(qdisc_dev(tp->q));
+
 	if (tb[TCA_FLOW_KEYS]) {
 		fnew->keymask = keymask;
 		fnew->nkeys   = nkeys;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index b665aee661f7..ea4aa1a4d8fd 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -524,6 +524,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 		if (f->handle < f1->handle)
 			break;
 
+	netif_keep_dst(qdisc_dev(tp->q));
 	rcu_assign_pointer(f->next, f1);
 	rcu_assign_pointer(*fp, f);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2b349a4de3c8..38d58e6cef07 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -47,7 +47,6 @@ EXPORT_SYMBOL(default_qdisc_ops);
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	skb_dst_force(skb);
 	q->gso_skb = skb;
 	q->qstats.requeues++;
 	q->q.qlen++;	/* it's still part of the queue */
@@ -218,8 +217,6 @@ static inline int qdisc_restart(struct Qdisc *q)
 	if (unlikely(!skb))
 		return 0;
 
-	WARN_ON_ONCE(skb_dst_is_noref(skb));
-
 	root_lock = qdisc_lock(q);
 	dev = qdisc_dev(q);
 	txq = skb_get_tx_queue(dev, skb);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 5cd291bd00e4..6ada42396a24 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -470,7 +470,7 @@ static __init void teql_master_setup(struct net_device *dev)
 	dev->tx_queue_len	= 100;
 	dev->flags		= IFF_NOARP;
 	dev->hard_header_len	= LL_MAX_HEADER;
-	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
+	netif_keep_dst(dev);
 }
 
 static LIST_HEAD(master_dev_list);
