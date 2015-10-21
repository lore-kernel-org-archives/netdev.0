From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Use dev_queue_xmit for vport send.
Date: Tue, 20 Oct 2015 23:00:10 -0700
Message-ID: <1445407210-3898-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34265 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbJUGAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 02:00:16 -0400
Received: by padhk11 with SMTP id hk11so44596368pad.1
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 23:00:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With use of lwtunnel, we can directly call dev_queue_xmit()
rather than calling netdev vport send operation.
Following change make tunnel vport code bit cleaner.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-geneve.c       |    2 +-
 net/openvswitch/vport-gre.c          |    2 +-
 net/openvswitch/vport-internal_dev.c |    8 ++++----
 net/openvswitch/vport-netdev.c       |   33 +--------------------------------
 net/openvswitch/vport-netdev.h       |    1 -
 net/openvswitch/vport-vxlan.c        |    2 +-
 net/openvswitch/vport.c              |   30 ++++++++++++++++++++++++++++++
 net/openvswitch/vport.h              |    7 ++-----
 8 files changed, 40 insertions(+), 45 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 2735e9c..7a568ca 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -128,7 +128,7 @@ static struct vport_ops ovs_geneve_vport_ops = {
 	.create		= geneve_create,
 	.destroy	= ovs_netdev_tunnel_destroy,
 	.get_options	= geneve_get_options,
-	.send		= ovs_netdev_send,
+	.send		= dev_queue_xmit,
 	.owner          = THIS_MODULE,
 	.get_egress_tun_info	= geneve_get_egress_tun_info,
 };
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 4d24481..cdb758a 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -94,7 +94,7 @@ static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
-	.send		= ovs_netdev_send,
+	.send		= dev_queue_xmit,
 	.get_egress_tun_info	= gre_get_egress_tun_info,
 	.destroy	= ovs_netdev_tunnel_destroy,
 	.owner		= THIS_MODULE,
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 388b8a6..7f0a8bd 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -202,22 +202,21 @@ static void internal_dev_destroy(struct vport *vport)
 	rtnl_unlock();
 }
 
-static void internal_dev_recv(struct vport *vport, struct sk_buff *skb)
+static netdev_tx_t internal_dev_recv(struct sk_buff *skb)
 {
-	struct net_device *netdev = vport->dev;
+	struct net_device *netdev = skb->dev;
 	struct pcpu_sw_netstats *stats;
 
 	if (unlikely(!(netdev->flags & IFF_UP))) {
 		kfree_skb(skb);
 		netdev->stats.rx_dropped++;
-		return;
+		return NETDEV_TX_OK;
 	}
 
 	skb_dst_drop(skb);
 	nf_reset(skb);
 	secpath_reset(skb);
 
-	skb->dev = netdev;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, netdev);
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
@@ -229,6 +228,7 @@ static void internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	u64_stats_update_end(&stats->syncp);
 
 	netif_rx(skb);
+	return NETDEV_TX_OK;
 }
 
 static struct vport_ops ovs_internal_vport_ops = {
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index f7e8dcc..b327368 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -190,37 +190,6 @@ void ovs_netdev_tunnel_destroy(struct vport *vport)
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
 
-static unsigned int packet_length(const struct sk_buff *skb)
-{
-	unsigned int length = skb->len - ETH_HLEN;
-
-	if (skb->protocol == htons(ETH_P_8021Q))
-		length -= VLAN_HLEN;
-
-	return length;
-}
-
-void ovs_netdev_send(struct vport *vport, struct sk_buff *skb)
-{
-	int mtu = vport->dev->mtu;
-
-	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
-		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
-				     vport->dev->name,
-				     packet_length(skb), mtu);
-		vport->dev->stats.tx_errors++;
-		goto drop;
-	}
-
-	skb->dev = vport->dev;
-	dev_queue_xmit(skb);
-	return;
-
-drop:
-	kfree_skb(skb);
-}
-EXPORT_SYMBOL_GPL(ovs_netdev_send);
-
 /* Returns null if this device is not attached to a datapath. */
 struct vport *ovs_netdev_get_vport(struct net_device *dev)
 {
@@ -235,7 +204,7 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
-	.send		= ovs_netdev_send,
+	.send		= dev_queue_xmit,
 };
 
 int __init ovs_netdev_init(void)
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index bf22fce..19e29c1 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -27,7 +27,6 @@
 struct vport *ovs_netdev_get_vport(struct net_device *dev);
 
 struct vport *ovs_netdev_link(struct vport *vport, const char *name);
-void ovs_netdev_send(struct vport *vport, struct sk_buff *skb);
 void ovs_netdev_detach_dev(struct vport *);
 
 int __init ovs_netdev_init(void);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index fb3cdb8..6f70071 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -170,7 +170,7 @@ static struct vport_ops ovs_vxlan_netdev_vport_ops = {
 	.create			= vxlan_create,
 	.destroy		= ovs_netdev_tunnel_destroy,
 	.get_options		= vxlan_get_options,
-	.send			= ovs_netdev_send,
+	.send			= dev_queue_xmit,
 	.get_egress_tun_info	= vxlan_get_egress_tun_info,
 };
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 12a36ac..ef19d0b 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -537,3 +537,33 @@ int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 
 	return vport->ops->get_egress_tun_info(vport, skb, upcall);
 }
+
+static unsigned int packet_length(const struct sk_buff *skb)
+{
+	unsigned int length = skb->len - ETH_HLEN;
+
+	if (skb->protocol == htons(ETH_P_8021Q))
+		length -= VLAN_HLEN;
+
+	return length;
+}
+
+void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
+{
+	int mtu = vport->dev->mtu;
+
+	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
+		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
+				     vport->dev->name,
+				     packet_length(skb), mtu);
+		vport->dev->stats.tx_errors++;
+		goto drop;
+	}
+
+	skb->dev = vport->dev;
+	vport->ops->send(skb);
+	return;
+
+drop:
+	kfree_skb(skb);
+}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index a413f3a..885607f 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -153,7 +153,7 @@ struct vport_ops {
 	int (*set_options)(struct vport *, struct nlattr *);
 	int (*get_options)(const struct vport *, struct sk_buff *);
 
-	void (*send)(struct vport *, struct sk_buff *);
+	netdev_tx_t (*send) (struct sk_buff *skb);
 	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
 				   struct dp_upcall_info *upcall);
 
@@ -234,9 +234,6 @@ static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
 	return rt;
 }
 
-static inline void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
-{
-	vport->ops->send(vport, skb);
-}
+void ovs_vport_send(struct vport *vport, struct sk_buff *skb);
 
 #endif /* vport.h */
-- 
1.7.1
