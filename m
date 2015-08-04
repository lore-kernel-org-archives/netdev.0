From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 1/3] openvswitch: Move tunnel destroy function to oppenvswitch module.
Date: Tue,  4 Aug 2015 16:22:14 -0700
Message-ID: <1438730534-3111-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33431 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbbHDXWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 19:22:23 -0400
Received: by pdbnt7 with SMTP id nt7so10120074pdb.0
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 16:22:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function will be used in gre and geneve vport implementations.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-netdev.c | 16 ++++++++++++++++
 net/openvswitch/vport-netdev.h |  1 +
 net/openvswitch/vport-vxlan.c  | 17 +----------------
 3 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index cddb706..5e2335b 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -178,6 +178,22 @@ static void netdev_destroy(struct vport *vport)
 	call_rcu(&vport->rcu, ovs_vport_free_rcu);
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
+	call_rcu(&vport->rcu, ovs_vport_free_rcu);
+}
+EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
+
 static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 8044126..b342916 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -34,4 +34,5 @@ void ovs_vport_free_rcu(struct rcu_head *);
 int __init ovs_netdev_init(void);
 void ovs_netdev_exit(void);
 
+void ovs_netdev_tunnel_destroy(struct vport *vport);
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 5471733..d8d0384 100644
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
