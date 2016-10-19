From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 4/6] net: use core MTU range checking in core net infra
Date: Tue, 18 Oct 2016 22:33:31 -0400
Message-ID: <20161019023333.15760-5-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Paolo Abeni <pabeni@redhat.com>, Jiri Benc <jbenc@redhat.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Pravin Shelar <pshelar@nicira.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753233AbcJSCdw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 22:33:52 -0400
In-Reply-To: <20161019023333.15760-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

geneve:
- Merge __geneve_change_mtu back into geneve_change_mtu, set max_mtu
- This one isn't quite as straight-forward as others, could use some
  closer inspection and testing

macvlan:
- set min/max_mtu

tun:
- set min/max_mtu, remove tun_net_change_mtu

vxlan:
- Merge __vxlan_change_mtu back into vxlan_change_mtu, set min/max_mtu
- This one is also not as straight-forward and could use closer inspection
  and testing from vxlan folks

bridge:
- set max_mtu via br_min_mtu()

openvswitch:
- set min/max_mtu, remove internal_dev_change_mtu
- note: max_mtu wasn't checked previously, it's been set to 65535, which
  is the largest possible size supported

sch_teql:
- set min/max_mtu (note: max_mtu previously unchecked, used max of 65535)

CC: netdev@vger.kernel.org
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
CC: Tom Herbert <tom@herbertland.com>
CC: Daniel Borkmann <daniel@iogearbox.net>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Paolo Abeni <pabeni@redhat.com>
CC: Jiri Benc <jbenc@redhat.com>
CC: WANG Cong <xiyou.wangcong@gmail.com>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
CC: Pravin B Shelar <pshelar@ovn.org>
CC: Sabrina Dubroca <sd@queasysnail.net>
CC: Patrick McHardy <kaber@trash.net>
CC: Stephen Hemminger <stephen@networkplumber.org>
CC: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/geneve.c                 | 48 +++++++++++-----------------
 drivers/net/macvlan.c                |  6 +++-
 drivers/net/tun.c                    | 20 ++++--------
 drivers/net/vxlan.c                  | 62 ++++++++++++++++++------------------
 net/bridge/br_device.c               |  9 +++---
 net/openvswitch/vport-internal_dev.c | 10 ------
 net/sched/sch_teql.c                 |  5 ++-
 7 files changed, 67 insertions(+), 93 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 3c20e87..752bcaa 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1034,39 +1034,18 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	return geneve_xmit_skb(skb, dev, info);
 }
 
-static int __geneve_change_mtu(struct net_device *dev, int new_mtu, bool strict)
+static int geneve_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct geneve_dev *geneve = netdev_priv(dev);
-	/* The max_mtu calculation does not take account of GENEVE
-	 * options, to avoid excluding potentially valid
-	 * configurations.
+	/* Only possible if called internally, ndo_change_mtu path's new_mtu
+	 * is guaranteed to be between dev->min_mtu and dev->max_mtu.
 	 */
-	int max_mtu = IP_MAX_MTU - GENEVE_BASE_HLEN - dev->hard_header_len;
-
-	if (geneve->remote.sa.sa_family == AF_INET6)
-		max_mtu -= sizeof(struct ipv6hdr);
-	else
-		max_mtu -= sizeof(struct iphdr);
-
-	if (new_mtu < 68)
-		return -EINVAL;
-
-	if (new_mtu > max_mtu) {
-		if (strict)
-			return -EINVAL;
-
-		new_mtu = max_mtu;
-	}
+	if (new_mtu > dev->max_mtu)
+		new_mtu = dev->max_mtu;
 
 	dev->mtu = new_mtu;
 	return 0;
 }
 
-static int geneve_change_mtu(struct net_device *dev, int new_mtu)
-{
-	return __geneve_change_mtu(dev, new_mtu, true);
-}
-
 static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ip_tunnel_info *info = skb_tunnel_info(skb);
@@ -1170,6 +1149,14 @@ static void geneve_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 
+	/* MTU range: 68 - (something less than 65535) */
+	dev->min_mtu = ETH_MIN_MTU;
+	/* The max_mtu calculation does not take account of GENEVE
+	 * options, to avoid excluding potentially valid
+	 * configurations. This will be further reduced by IPvX hdr size.
+	 */
+	dev->max_mtu = IP_MAX_MTU - GENEVE_BASE_HLEN - dev->hard_header_len;
+
 	netif_keep_dst(dev);
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
@@ -1285,10 +1272,13 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 
 	/* make enough headroom for basic scenario */
 	encap_len = GENEVE_BASE_HLEN + ETH_HLEN;
-	if (remote->sa.sa_family == AF_INET)
+	if (remote->sa.sa_family == AF_INET) {
 		encap_len += sizeof(struct iphdr);
-	else
+		dev->max_mtu -= sizeof(struct iphdr);
+	} else {
 		encap_len += sizeof(struct ipv6hdr);
+		dev->max_mtu -= sizeof(struct ipv6hdr);
+	}
 	dev->needed_headroom = encap_len + ETH_HLEN;
 
 	if (metadata) {
@@ -1488,7 +1478,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	/* openvswitch users expect packet sizes to be unrestricted,
 	 * so set the largest MTU we can.
 	 */
-	err = __geneve_change_mtu(dev, IP_MAX_MTU, false);
+	err = geneve_change_mtu(dev, IP_MAX_MTU);
 	if (err)
 		goto err;
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3234fcd..0e0cb2d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -777,7 +777,7 @@ static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	if (new_mtu < 68 || vlan->lowerdev->mtu < new_mtu)
+	if (vlan->lowerdev->mtu < new_mtu)
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
@@ -1297,6 +1297,10 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	else if (dev->mtu > lowerdev->mtu)
 		return -EINVAL;
 
+	/* MTU range: 68 - lowerdev->max_mtu */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = lowerdev->max_mtu;
+
 	if (!tb[IFLA_ADDRESS])
 		eth_hw_addr_random(dev);
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8093e39..9328568 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -925,18 +925,6 @@ static void tun_net_mclist(struct net_device *dev)
 	 */
 }
 
-#define MIN_MTU 68
-#define MAX_MTU 65535
-
-static int
-tun_net_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < MIN_MTU || new_mtu + dev->hard_header_len > MAX_MTU)
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static netdev_features_t tun_net_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
@@ -1014,7 +1002,6 @@ static const struct net_device_ops tun_netdev_ops = {
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
-	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
 	.ndo_select_queue	= tun_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1029,7 +1016,6 @@ static const struct net_device_ops tap_netdev_ops = {
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
-	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
 	.ndo_set_rx_mode	= tun_net_mclist,
 	.ndo_set_mac_address	= eth_mac_addr,
@@ -1062,6 +1048,9 @@ static void tun_flow_uninit(struct tun_struct *tun)
 	tun_flow_flush(tun);
 }
 
+#define MIN_MTU 68
+#define MAX_MTU 65535
+
 /* Initialize net device. */
 static void tun_net_init(struct net_device *dev)
 {
@@ -1092,6 +1081,9 @@ static void tun_net_init(struct net_device *dev)
 
 		break;
 	}
+
+	dev->min_mtu = MIN_MTU;
+	dev->max_mtu = MAX_MTU - dev->hard_header_len;
 }
 
 /* Character device part */
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e7d1668..98207ae 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2367,43 +2367,31 @@ static void vxlan_set_multicast_list(struct net_device *dev)
 {
 }
 
-static int __vxlan_change_mtu(struct net_device *dev,
-			      struct net_device *lowerdev,
-			      struct vxlan_rdst *dst, int new_mtu, bool strict)
+static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
 {
-	int max_mtu = IP_MAX_MTU;
-
-	if (lowerdev)
-		max_mtu = lowerdev->mtu;
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_rdst *dst = &vxlan->default_dst;
+	struct net_device *lowerdev = __dev_get_by_index(vxlan->net,
+							 dst->remote_ifindex);
+	bool use_ipv6 = false;
 
 	if (dst->remote_ip.sa.sa_family == AF_INET6)
-		max_mtu -= VXLAN6_HEADROOM;
-	else
-		max_mtu -= VXLAN_HEADROOM;
-
-	if (new_mtu < 68)
-		return -EINVAL;
+		use_ipv6 = true;
 
-	if (new_mtu > max_mtu) {
-		if (strict)
+	/* We re-check this, because users *could* alter the mtu of the
+	 * lower device after we've initialized dev->max_mtu.
+	 */
+	if (lowerdev) {
+		dev->max_mtu = lowerdev->mtu -
+			       (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
+		if (new_mtu > dev->max_mtu)
 			return -EINVAL;
-
-		new_mtu = max_mtu;
 	}
 
 	dev->mtu = new_mtu;
 	return 0;
 }
 
-static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
-{
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_rdst *dst = &vxlan->default_dst;
-	struct net_device *lowerdev = __dev_get_by_index(vxlan->net,
-							 dst->remote_ifindex);
-	return __vxlan_change_mtu(dev, lowerdev, dst, new_mtu, true);
-}
-
 static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
@@ -2795,6 +2783,10 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		vxlan_ether_setup(dev);
 	}
 
+	/* MTU range: 68 - 65535 */
+	dev->min_mtu = 68;
+	dev->max_mtu = IP_MAX_MTU;
+
 	vxlan->net = src_net;
 
 	dst->remote_vni = conf->vni;
@@ -2837,8 +2829,11 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		}
 #endif
 
-		if (!conf->mtu)
-			dev->mtu = lowerdev->mtu - (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
+		if (!conf->mtu) {
+			dev->mtu = lowerdev->mtu -
+				   (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
+			dev->max_mtu = dev->mtu;
+		}
 
 		needed_headroom = lowerdev->hard_header_len;
 	} else if (vxlan_addr_multicast(&dst->remote_ip)) {
@@ -2847,9 +2842,14 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	}
 
 	if (conf->mtu) {
-		err = __vxlan_change_mtu(dev, lowerdev, dst, conf->mtu, false);
-		if (err)
-			return err;
+		if (lowerdev)
+			dev->max_mtu = lowerdev->mtu;
+		dev->max_mtu -= (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
+
+		dev->mtu = conf->mtu;
+
+		if (conf->mtu > dev->max_mtu)
+			dev->mtu = dev->max_mtu;
 	}
 
 	if (use_ipv6 || conf->flags & VXLAN_F_COLLECT_METADATA)
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 89a687f..81fc79a 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -184,17 +184,15 @@ static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
 
 static int br_change_mtu(struct net_device *dev, int new_mtu)
 {
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	struct net_bridge *br = netdev_priv(dev);
-	if (new_mtu < 68 || new_mtu > br_min_mtu(br))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
 
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	/* remember the MTU in the rtable for PMTU */
 	dst_metric_set(&br->fake_rtable.dst, RTAX_MTU, new_mtu);
 #endif
 
+	dev->mtu = new_mtu;
+
 	return 0;
 }
 
@@ -390,6 +388,7 @@ void br_dev_setup(struct net_device *dev)
 	dev->hw_features = COMMON_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_STAG_TX;
 	dev->vlan_features = COMMON_FEATURES;
+	dev->max_mtu = br_min_mtu(br);
 
 	br->dev = dev;
 	spin_lock_init(&br->lock);
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index e7da290..d5d6cae 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -89,15 +89,6 @@ static const struct ethtool_ops internal_dev_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
 
-static int internal_dev_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	if (new_mtu < 68)
-		return -EINVAL;
-
-	netdev->mtu = new_mtu;
-	return 0;
-}
-
 static void internal_dev_destructor(struct net_device *dev)
 {
 	struct vport *vport = ovs_internal_dev_get_vport(dev);
@@ -148,7 +139,6 @@ static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_stop = internal_dev_stop,
 	.ndo_start_xmit = internal_dev_xmit,
 	.ndo_set_mac_address = eth_mac_addr,
-	.ndo_change_mtu = internal_dev_change_mtu,
 	.ndo_get_stats64 = internal_get_stats,
 	.ndo_set_rx_headroom = internal_set_rx_headroom,
 };
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 2cd9b44..b019636 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -418,9 +418,6 @@ static int teql_master_mtu(struct net_device *dev, int new_mtu)
 	struct teql_master *m = netdev_priv(dev);
 	struct Qdisc *q;
 
-	if (new_mtu < 68)
-		return -EINVAL;
-
 	q = m->slaves;
 	if (q) {
 		do {
@@ -460,6 +457,8 @@ static __init void teql_master_setup(struct net_device *dev)
 	dev->netdev_ops =       &teql_netdev_ops;
 	dev->type		= ARPHRD_VOID;
 	dev->mtu		= 1500;
+	dev->min_mtu		= 68;
+	dev->max_mtu		= 65535;
 	dev->tx_queue_len	= 100;
 	dev->flags		= IFF_NOARP;
 	dev->hard_header_len	= LL_MAX_HEADER;
-- 
2.10.0
