From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v5 1/4] openvswitch: Move tunnel destroy function to oppenvswitch module.
Date: Fri,  7 Aug 2015 23:51:33 -0700
Message-ID: <1439016693-15524-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35501 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbHJDsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 23:48:07 -0400
Received: by pacgr6 with SMTP id gr6so17045955pac.2
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 20:48:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function will be used in gre and geneve vport implementations.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/vport-netdev.c | 21 ++++++++++++++++++---
 net/openvswitch/vport-netdev.h |  2 +-
 net/openvswitch/vport-vxlan.c  | 17 +----------------
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index cddb706..4b70aaa 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -147,7 +147,7 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	return ovs_netdev_link(vport, parms->name);
 }
 
-void ovs_vport_free_rcu(struct rcu_head *rcu)
+static void vport_netdev_free(struct rcu_head *rcu)
 {
 	struct vport *vport = container_of(rcu, struct vport, rcu);
 
@@ -155,7 +155,6 @@ void ovs_vport_free_rcu(struct rcu_head *rcu)
 		dev_put(vport->dev);
 	ovs_vport_free(vport);
 }
-EXPORT_SYMBOL_GPL(ovs_vport_free_rcu);
 
 void ovs_netdev_detach_dev(struct vport *vport)
 {
@@ -175,9 +174,25 @@ static void netdev_destroy(struct vport *vport)
 		ovs_netdev_detach_dev(vport);
 	rtnl_unlock();
 
-	call_rcu(&vport->rcu, ovs_vport_free_rcu);
+	call_rcu(&vport->rcu, vport_netdev_free);
 }
 
+void ovs_netdev_tunnel_destroy(struct vport *vport)
+{
+	rtnl_lock();
+	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
+		ovs_netdev_detach_dev(vport);
+
+	/* Early release so we can unregister the device */
+	dev_put(vport->dev);
+	rtnl_delete_link(vport->dev);
+	vport->dev = NULL;
+	rtnl_unlock();
+
+	call_rcu(&vport->rcu, vport_netdev_free);
+}
+EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
+
 static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 8044126..497cc81 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -29,9 +29,9 @@ struct vport *ovs_netdev_get_vport(struct net_device *dev);
 struct vport *ovs_netdev_link(struct vport *vport, const char *name);
 int ovs_netdev_send(struct vport *vport, struct sk_buff *skb);
 void ovs_netdev_detach_dev(struct vport *);
-void ovs_vport_free_rcu(struct rcu_head *);
 
 int __init ovs_netdev_init(void);
 void ovs_netdev_exit(void);
 
+void ovs_netdev_tunnel_destroy(struct vport *vport);
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index c6e937e..1e8b00a2 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -146,21 +146,6 @@ static struct vport *vxlan_create(const struct vport_parms *parms)
 	return ovs_netdev_link(vport, parms->name);
 }
 
-static void vxlan_destroy(struct vport *vport)
-{
-	rtnl_lock();
-	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
-		ovs_netdev_detach_dev(vport);
-
-	/* Early release so we can unregister the device */
-	dev_put(vport->dev);
-	rtnl_delete_link(vport->dev);
-	vport->dev = NULL;
-	rtnl_unlock();
-
-	call_rcu(&vport->rcu, ovs_vport_free_rcu);
-}
-
 static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 				     struct ip_tunnel_info *egress_tun_info)
 {
@@ -183,7 +168,7 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 static struct vport_ops ovs_vxlan_netdev_vport_ops = {
 	.type			= OVS_VPORT_TYPE_VXLAN,
 	.create			= vxlan_create,
-	.destroy		= vxlan_destroy,
+	.destroy		= ovs_netdev_tunnel_destroy,
 	.get_options		= vxlan_get_options,
 	.send			= ovs_netdev_send,
 	.get_egress_tun_info	= vxlan_get_egress_tun_info,
-- 
1.8.3.1
