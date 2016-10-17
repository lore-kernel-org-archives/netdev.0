From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v12 9/9] openvswitch: use ipgre tunnel rather than gretap tunnel
Date: Mon, 17 Oct 2016 15:02:45 +0200
Message-ID: <4e5bfb307ee1e419f973a100e8acc7556311b64a.1476708213.git.jbenc@redhat.com>
References: <cover.1476708212.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45400 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757852AbcJQNDe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 09:03:34 -0400
In-Reply-To: <cover.1476708212.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>

This allows GRE tunnels to send and receive both
layer 2 packets (packets with an ethernet header) and
layer 3 packets (packets without an ethernet header).

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v12: removed the non-gre hunks (now part of previous patches in this
     patchset)
---
 include/net/gre.h           | 4 ++--
 net/ipv4/ip_gre.c           | 9 +++++----
 net/openvswitch/vport-gre.c | 2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index d25d836c129b..1a0bb1cefa60 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -31,8 +31,8 @@ struct gre_protocol {
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
-struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
-				       u8 name_assign_type);
+struct net_device *gre_fb_dev_create(struct net *net, const char *name,
+				     u8 name_assign_type);
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 		     bool *csum_err, __be16 proto, int nhs);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 576f705d8180..18caea5c6d09 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1125,8 +1125,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	.get_link_net	= ip_tunnel_get_link_net,
 };
 
-struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
-					u8 name_assign_type)
+struct net_device *gre_fb_dev_create(struct net *net, const char *name,
+				     u8 name_assign_type)
 {
 	struct nlattr *tb[IFLA_MAX + 1];
 	struct net_device *dev;
@@ -1137,13 +1137,14 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
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
 	if (err < 0) {
@@ -1168,7 +1169,7 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	unregister_netdevice_many(&list_kill);
 	return ERR_PTR(err);
 }
-EXPORT_SYMBOL_GPL(gretap_fb_dev_create);
+EXPORT_SYMBOL_GPL(gre_fb_dev_create);
 
 static int __net_init ipgre_tap_init_net(struct net *net)
 {
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 0e72d95b0e8f..3fc3014bf924 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -61,7 +61,7 @@ static struct vport *gre_tnl_create(const struct vport_parms *parms)
 		return vport;
 
 	rtnl_lock();
-	dev = gretap_fb_dev_create(net, parms->name, NET_NAME_USER);
+	dev = gre_fb_dev_create(net, parms->name, NET_NAME_USER);
 	if (IS_ERR(dev)) {
 		rtnl_unlock();
 		ovs_vport_free(vport);
-- 
1.8.3.1
