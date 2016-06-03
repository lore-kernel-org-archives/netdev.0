From: Dan Streetman <dan.streetman@canonical.com>
Subject: [PATCH 4.4-stable 3/3] vxlan, gre, geneve: Set a large MTU on ovs-created tunnel devices
Date: Fri,  3 Jun 2016 18:58:15 -0400
Message-ID: <1464994695-25178-4-git-send-email-dan.streetman@canonical.com>
References: <1464994695-25178-1-git-send-email-dan.streetman@canonical.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56153 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbcFCXDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:03:46 -0400
In-Reply-To: <1464994695-25178-1-git-send-email-dan.streetman@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wragg <david@weave.works>

Prior to 4.3, openvswitch tunnel vports (vxlan, gre and geneve) could
transmit vxlan packets of any size, constrained only by the ability to
send out the resulting packets.  4.3 introduced netdevs corresponding
to tunnel vports.  These netdevs have an MTU, which limits the size of
a packet that can be successfully encapsulated.  The default MTU
values are low (1500 or less), which is awkwardly small in the context
of physical networks supporting jumbo frames, and leads to a
conspicuous change in behaviour for userspace.

Instead, set the MTU on openvswitch-created netdevs to be the relevant
maximum (i.e. the maximum IP packet size minus any relevant overhead),
effectively restoring the behaviour prior to 4.3.

Signed-off-by: David Wragg <david@weave.works>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/geneve.c          | 18 ++++++++++++++----
 drivers/net/vxlan.c           | 11 ++++++++---
 include/net/ip_tunnels.h      |  1 +
 net/ipv4/ip_gre.c             |  8 ++++++++
 net/ipv4/ip_tunnel.c          | 20 +++++++++++++++++---
 net/openvswitch/vport-vxlan.c |  2 ++
 6 files changed, 50 insertions(+), 10 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 0fb2ced..d675f09 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1360,11 +1360,21 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 
 	err = geneve_configure(net, dev, &geneve_remote_unspec,
 			       0, 0, 0, htons(dst_port), true);
-	if (err) {
-		free_netdev(dev);
-		return ERR_PTR(err);
-	}
+	if (err)
+		goto err;
+
+	/* openvswitch users expect packet sizes to be unrestricted,
+	 * so set the largest MTU we can.
+	 */
+	err = geneve_change_mtu(dev, IP_MAX_MTU);
+	if (err)
+		goto err;
+
 	return dev;
+
+ err:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(geneve_dev_create_fb);
 
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9a1a4ec..ca3dbaa 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2782,6 +2782,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	int err;
 	bool use_ipv6 = false;
 	__be16 default_port = vxlan->cfg.dst_port;
+	struct net_device *lowerdev = NULL;
 
 	vxlan->net = src_net;
 
@@ -2802,9 +2803,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	}
 
 	if (conf->remote_ifindex) {
-		struct net_device *lowerdev
-			 = __dev_get_by_index(src_net, conf->remote_ifindex);
-
+		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
 		dst->remote_ifindex = conf->remote_ifindex;
 
 		if (!lowerdev) {
@@ -2828,6 +2827,12 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		needed_headroom = lowerdev->hard_header_len;
 	}
 
+	if (conf->mtu) {
+		err = __vxlan_change_mtu(dev, lowerdev, dst, conf->mtu, false);
+		if (err)
+			return err;
+	}
+
 	if (use_ipv6 || conf->flags & VXLAN_F_COLLECT_METADATA)
 		needed_headroom += VXLAN6_HEADROOM;
 	else
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 62a750a..af40bc5 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -230,6 +230,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
 int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 		    u8 *protocol, struct flowi4 *fl4);
+int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
 struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7dc962b..3e41840 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1247,6 +1247,14 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	err = ipgre_newlink(net, dev, tb, NULL);
 	if (err < 0)
 		goto out;
+
+	/* openvswitch users expect packet sizes to be unrestricted,
+	 * so set the largest MTU we can.
+	 */
+	err = __ip_tunnel_change_mtu(dev, IP_MAX_MTU, false);
+	if (err)
+		goto out;
+
 	return dev;
 out:
 	free_netdev(dev);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index ce30c8b..3310ac7 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -948,17 +948,31 @@ done:
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_ioctl);
 
-int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
+int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
+	int max_mtu = 0xFFF8 - dev->hard_header_len - t_hlen;
 
-	if (new_mtu < 68 ||
-	    new_mtu > 0xFFF8 - dev->hard_header_len - t_hlen)
+	if (new_mtu < 68)
 		return -EINVAL;
+
+	if (new_mtu > max_mtu) {
+		if (strict)
+			return -EINVAL;
+
+		new_mtu = max_mtu;
+	}
+
 	dev->mtu = new_mtu;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__ip_tunnel_change_mtu);
+
+int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
+{
+	return __ip_tunnel_change_mtu(dev, new_mtu, true);
+}
 EXPORT_SYMBOL_GPL(ip_tunnel_change_mtu);
 
 static void ip_tunnel_dev_free(struct net_device *dev)
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d933cb8..5eb7694 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -91,6 +91,8 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	struct vxlan_config conf = {
 		.no_share = true,
 		.flags = VXLAN_F_COLLECT_METADATA | VXLAN_F_UDP_ZERO_CSUM6_RX,
+		/* Don't restrict the packets that can be sent by MTU */
+		.mtu = IP_MAX_MTU,
 	};
 
 	if (!options) {
-- 
2.7.4
