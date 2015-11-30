From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2] openvswitch: properly refcount vport-vxlan module
Date: Mon, 30 Nov 2015 12:31:43 +0100
Message-ID: <2658801f06f24c242c40f223b1164e61be44974a.1448882748.git.pabeni@redhat.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbbK3LcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 06:32:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 614732eaa12d, no refcount is maintained for the vport-vxlan module.
This allows the userspace to remove such module while vport-vxlan
devices still exist, which leads to later oops.

v1 -> v2:
 - move vport 'owner' initialization in ovs_vport_ops_register()
   and make such function a macro

Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/openvswitch/vport-geneve.c | 1 -
 net/openvswitch/vport-gre.c    | 1 -
 net/openvswitch/vport.c        | 4 ++--
 net/openvswitch/vport.h        | 8 +++++++-
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index efb736b..e41cd12 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -117,7 +117,6 @@ static struct vport_ops ovs_geneve_vport_ops = {
 	.destroy	= ovs_netdev_tunnel_destroy,
 	.get_options	= geneve_get_options,
 	.send		= dev_queue_xmit,
-	.owner          = THIS_MODULE,
 };
 
 static int __init ovs_geneve_tnl_init(void)
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index c3257d7..7f8897f 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -89,7 +89,6 @@ static struct vport_ops ovs_gre_vport_ops = {
 	.create		= gre_create,
 	.send		= dev_queue_xmit,
 	.destroy	= ovs_netdev_tunnel_destroy,
-	.owner		= THIS_MODULE,
 };
 
 static int __init ovs_gre_tnl_init(void)
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index e194c10a..31cbc8c 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -71,7 +71,7 @@ static struct hlist_head *hash_bucket(const struct net *net, const char *name)
 	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
 }
 
-int ovs_vport_ops_register(struct vport_ops *ops)
+int __ovs_vport_ops_register(struct vport_ops *ops)
 {
 	int err = -EEXIST;
 	struct vport_ops *o;
@@ -87,7 +87,7 @@ errout:
 	ovs_unlock();
 	return err;
 }
-EXPORT_SYMBOL_GPL(ovs_vport_ops_register);
+EXPORT_SYMBOL_GPL(__ovs_vport_ops_register);
 
 void ovs_vport_ops_unregister(struct vport_ops *ops)
 {
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index bdfd82a..8ea3a96 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -196,7 +196,13 @@ static inline const char *ovs_vport_name(struct vport *vport)
 	return vport->dev->name;
 }
 
-int ovs_vport_ops_register(struct vport_ops *ops);
+int __ovs_vport_ops_register(struct vport_ops *ops);
+#define ovs_vport_ops_register(ops)		\
+	({					\
+		(ops)->owner = THIS_MODULE;	\
+		__ovs_vport_ops_register(ops);	\
+	})
+
 void ovs_vport_ops_unregister(struct vport_ops *ops);
 
 static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
-- 
1.8.3.1
