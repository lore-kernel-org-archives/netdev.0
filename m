From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v10 5/5] openvswitch: use ipgre tunnel rather than gretap tunnel
Date: Thu,  2 Jun 2016 15:24:46 +0900
Message-ID: <1464848686-7656-6-git-send-email-simon.horman@netronome.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35223 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbcFBGZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 02:25:09 -0400
Received: by mail-pf0-f176.google.com with SMTP id g64so27511765pfb.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 23:25:08 -0700 (PDT)
In-Reply-To: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows GRE tunnels to send and receive both
layer 2 packets (packets with an ethernet header) and
layer 3 packets (packets without an ethernet header).

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v10
* Handle case of l3 only packets on vport-netdev
* Use ARPHRD_NONE for ipgre interfaces as per recent changes in mainline
* Ensure skb->mac_len is set correctly in netdev_port_receive and
  relay on this value to differentiate layer3 packets in
  ovs_flow_key_extract()

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/gre.h              |  4 ++--
 net/ipv4/ip_gre.c              |  9 +++++----
 net/openvswitch/vport-gre.c    |  2 +-
 net/openvswitch/vport-netdev.c | 34 ++++++++++++++++++++++++++++------
 4 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 5dce30a6abe3..aeb748a97e0d 100644
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
 		     bool *csum_err, __be16 proto);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4d2025f7ec57..58d323289872 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1116,8 +1116,8 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.get_link_net	= ip_tunnel_get_link_net,
 };
 
-struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
-					u8 name_assign_type)
+struct net_device *gre_fb_dev_create(struct net *net, const char *name,
+				     u8 name_assign_type)
 {
 	struct nlattr *tb[IFLA_MAX + 1];
 	struct net_device *dev;
@@ -1127,13 +1127,14 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	memset(&tb, 0, sizeof(tb));
 
 	dev = rtnl_create_link(net, name, name_assign_type,
-			       &ipgre_tap_ops, tb);
+			       &ipgre_link_ops, tb);
 	if (IS_ERR(dev))
 		return dev;
 
 	/* Configure flow based GRE device. */
 	t = netdev_priv(dev);
 	t->collect_md = true;
+	dev->type = ARPHRD_NONE;
 
 	err = ipgre_newlink(net, dev, tb, NULL);
 	if (err < 0)
@@ -1151,7 +1152,7 @@ out:
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
-EXPORT_SYMBOL_GPL(gretap_fb_dev_create);
+EXPORT_SYMBOL_GPL(gre_fb_dev_create);
 
 static int __net_init ipgre_tap_init_net(struct net *net)
 {
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index bcbc91b8b077..c1cab9dd392f 100644
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
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 733e7914f6bd..3df36df62ee9 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -60,7 +60,24 @@ static void netdev_port_receive(struct sk_buff *skb)
 	if (vport->dev->type == ARPHRD_ETHER) {
 		skb_push(skb, ETH_HLEN);
 		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
+	} else if (vport->dev->type == ARPHRD_NONE) {
+		if (skb->protocol == htons(ETH_P_TEB)) {
+			__be16 eth_type;
+
+			if (unlikely(skb->len < ETH_HLEN))
+				goto error;
+
+			eth_type = eth_type_trans(skb, skb->dev);
+			skb->mac_len = skb->data - skb_mac_header(skb);
+			__skb_push(skb, skb->mac_len);
+
+			if (eth_type == htons(ETH_P_8021Q))
+				skb->mac_len += VLAN_HLEN;
+		} else {
+			skb->mac_len = 0;
+		}
 	}
+
 	ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
 	return;
 error:
@@ -99,7 +116,8 @@ struct vport *ovs_netdev_link(struct vport *vport, const char *name)
 	}
 
 	if (vport->dev->flags & IFF_LOOPBACK ||
-	    vport->dev->type != ARPHRD_ETHER ||
+	    (vport->dev->type != ARPHRD_ETHER &&
+	     vport->dev->type != ARPHRD_NONE) ||
 	    ovs_is_internal_dev(vport->dev)) {
 		err = -EINVAL;
 		goto error_put;
@@ -198,12 +216,16 @@ EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
 
 int ovs_netdev_send(struct sk_buff *skb)
 {
-	/* Only send L2 packets */
-	if (skb->mac_len)
-		return dev_queue_xmit(skb);
+	struct net_device *dev = skb->dev;
 
-	kfree_skb(skb);
-	return -EINVAL;
+	if (dev->type != ARPHRD_ETHER && skb->mac_len) {
+		skb->protocol = htons(ETH_P_TEB);
+	} else if (dev->type == ARPHRD_ETHER && !skb->mac_len) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	return dev_queue_xmit(skb);
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_send);
 
-- 
2.1.4
