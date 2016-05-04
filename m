From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v9 net-next 7/7] openvswitch: use ipgre tunnel rather than gretap tunnel
Date: Wed,  4 May 2016 16:36:33 +0900
Message-ID: <1462347393-22354-8-git-send-email-simon.horman@netronome.com>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36075 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756702AbcEDHhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 03:37:09 -0400
Received: by mail-pf0-f171.google.com with SMTP id c189so22906715pfb.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 00:37:09 -0700 (PDT)
In-Reply-To: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows GRE tunnels to send and receive both
layer 2 packets (packets with an ethernet header) and
layer 3 packets (packets without an ethernet header).

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v9
New Patch
---
 include/net/gre.h              |  4 ++--
 net/ipv4/ip_gre.c              |  8 ++++----
 net/openvswitch/vport-gre.c    |  4 ++--
 net/openvswitch/vport-netdev.c | 12 +++++++++++-
 net/openvswitch/vport-netdev.h |  1 +
 5 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 29e37322c06e..181357d124b1 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -23,8 +23,8 @@ struct gre_protocol {
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
-struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
-				       u8 name_assign_type);
+struct net_device *gre_fb_dev_create(struct net *net, const char *name,
+				     u8 name_assign_type);
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 		     bool *csum_err, int *hdr_len);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 52011f78e3c7..d542812217d7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1114,8 +1114,8 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.get_link_net	= ip_tunnel_get_link_net,
 };
 
-struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
-					u8 name_assign_type)
+struct net_device *gre_fb_dev_create(struct net *net, const char *name,
+				     u8 name_assign_type)
 {
 	struct nlattr *tb[IFLA_MAX + 1];
 	struct net_device *dev;
@@ -1125,7 +1125,7 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	memset(&tb, 0, sizeof(tb));
 
 	dev = rtnl_create_link(net, name, name_assign_type,
-			       &ipgre_tap_ops, tb);
+			       &ipgre_link_ops, tb);
 	if (IS_ERR(dev))
 		return dev;
 
@@ -1149,7 +1149,7 @@ out:
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
-EXPORT_SYMBOL_GPL(gretap_fb_dev_create);
+EXPORT_SYMBOL_GPL(gre_fb_dev_create);
 
 static int __net_init ipgre_tap_init_net(struct net *net)
 {
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index f003225de994..b1aa02904ae4 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -60,7 +60,7 @@ static struct vport *gre_tnl_create(const struct vport_parms *parms)
 		return vport;
 
 	rtnl_lock();
-	dev = gretap_fb_dev_create(net, parms->name, NET_NAME_USER);
+	dev = gre_fb_dev_create(net, parms->name, NET_NAME_USER);
 	if (IS_ERR(dev)) {
 		rtnl_unlock();
 		ovs_vport_free(vport);
@@ -87,7 +87,7 @@ static struct vport *gre_create(const struct vport_parms *parms)
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
-	.send		= ovs_netdev_send_tap,
+	.send		= ovs_netdev_send_raw_tun,
 	.destroy	= ovs_netdev_tunnel_destroy,
 };
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 0e0b9286dd11..e6a2718204a8 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -99,7 +99,8 @@ struct vport *ovs_netdev_link(struct vport *vport, const char *name)
 	}
 
 	if (vport->dev->flags & IFF_LOOPBACK ||
-	    vport->dev->type != ARPHRD_ETHER ||
+	    (vport->dev->type != ARPHRD_ETHER &&
+	     vport->dev->type != ARPHRD_IPGRE) ||
 	    ovs_is_internal_dev(vport->dev)) {
 		err = -EINVAL;
 		goto error_put;
@@ -207,6 +208,15 @@ int ovs_netdev_send_tap(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_send_tap);
 
+int ovs_netdev_send_raw_tun(struct sk_buff *skb)
+{
+	if (skb->mac_len)
+		skb->protocol = ntohs(ETH_P_TEB);
+
+	return dev_queue_xmit(skb);
+}
+EXPORT_SYMBOL_GPL(ovs_netdev_send_raw_tun);
+
 /* Returns null if this device is not attached to a datapath. */
 struct vport *ovs_netdev_get_vport(struct net_device *dev)
 {
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 02f38a822334..ae59c02ba6a9 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -35,4 +35,5 @@ void ovs_netdev_exit(void);
 void ovs_netdev_tunnel_destroy(struct vport *vport);
 
 int ovs_netdev_send_tap(struct sk_buff *skb);
+int ovs_netdev_send_raw_tun(struct sk_buff *skb);
 #endif /* vport_netdev.h */
-- 
2.7.0.rc3.207.g0ac5344
