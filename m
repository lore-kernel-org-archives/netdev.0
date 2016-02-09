From: David Wragg <david@weave.works>
Subject: [PATCH net v2 3/3] vxlan, gre, geneve: Set a large MTU on ovs-created tunnel devices
Date: Tue,  9 Feb 2016 16:47:04 +0000
Message-ID: <1455036424-6403-4-git-send-email-david@weave.works>
References: <1455036424-6403-1-git-send-email-david@weave.works>
Cc: Jesse Gross <jesse@kernel.org>, David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	David Wragg <david@weave.works>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33861 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951AbcBIQrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 11:47:11 -0500
Received: by mail-wm0-f54.google.com with SMTP id 128so204350906wmz.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 08:47:11 -0800 (PST)
In-Reply-To: <1455036424-6403-1-git-send-email-david@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to 4.3, tunnel vports (vxlan, gre and geneve) could transmit
vxlan packets of any size, constrained only by the ability to send out
the resulting packets.  4.3 introduced netdevs corresponding to tunnel
vports.  These netdevs have an MTU, which limits the size of a packet
that can be successfully encapsulated.  The default value for the MTUs
are low (1500 or less), which is awkwardly small in the context of
physical networks supporting jumbo frames, and leads to a conspicuous
change in behaviour for userspace.

Instead, set the MTU on openvswitch-created netdevs to be the relevant
maximum (i.e. the maximum IP packet size minus any relevant overhead),
effectively restoring the behaviour prior to 4.3.

Signed-off-by: David Wragg <david@weave.works>
---
 drivers/net/geneve.c          | 17 +++++++++++++----
 drivers/net/vxlan.c           | 11 ++++++++---
 include/net/ip_tunnels.h      |  1 +
 net/ipv4/ip_gre.c             |  7 +++++++
 net/ipv4/ip_tunnel.c          | 21 ++++++++++++++++++---
 net/openvswitch/vport-vxlan.c |  2 ++
 6 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 05cef11..9965714 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1452,11 +1452,20 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 
 	err = geneve_configure(net, dev, &geneve_remote_unspec,
 			       0, 0, 0, htons(dst_port), true, 0);
-	if (err) {
-		free_netdev(dev);
-		return ERR_PTR(err);
-	}
+	if (err)
+		goto err;
+
+	/* openvswitch users expect packet sizes to be unrestricted,
+	   so set the largest MTU we can. */
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
index e992c6a..a31cd95 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2779,6 +2779,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	int err;
 	bool use_ipv6 = false;
 	__be16 default_port = vxlan->cfg.dst_port;
+	struct net_device *lowerdev = NULL;
 
 	vxlan->net = src_net;
 
@@ -2799,9 +2800,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	}
 
 	if (conf->remote_ifindex) {
-		struct net_device *lowerdev
-			 = __dev_get_by_index(src_net, conf->remote_ifindex);
-
+		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
 		dst->remote_ifindex = conf->remote_ifindex;
 
 		if (!lowerdev) {
@@ -2825,6 +2824,12 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
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
index 6db96ea..dda9abf 100644
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
index 7c51c4e..057806d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1240,6 +1240,13 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	err = ipgre_newlink(net, dev, tb, NULL);
 	if (err < 0)
 		goto out;
+
+	/* openvswitch users expect packet sizes to be unrestricted,
+	   so set the largest MTU we can. */
+	err = __ip_tunnel_change_mtu(dev, IP_MAX_MTU, false);
+	if (err)
+		goto out;
+
 	return dev;
 out:
 	free_netdev(dev);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index c7bd72e..49504ed 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -943,17 +943,32 @@ done:
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
+	printk("XXX %d %d\n", new_mtu, max_mtu);
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
index 1605691..de9cb19 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -91,6 +91,8 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	struct vxlan_config conf = {
 		.no_share = true,
 		.flags = VXLAN_F_COLLECT_METADATA,
+		/* Don't restrict the packets that can be sent by MTU */
+		.mtu = IP_MAX_MTU,
 	};
 
 	if (!options) {
-- 
2.5.0
