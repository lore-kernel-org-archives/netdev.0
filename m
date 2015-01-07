From: Daniele Di Proietto <daniele.di.proietto@gmail.com>
Subject: [PATCH net-next] openvswitch: Add ovs_vport_get_index() to hide vport implementation
Date: Thu,  8 Jan 2015 00:48:45 +0100
Message-ID: <1420674525-18253-1-git-send-email-daniele.di.proietto@gmail.com>
Cc: Daniele Di Proietto <daniele.di.proietto@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:45237 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbbAGXtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 18:49:06 -0500
Received: by mail-we0-f171.google.com with SMTP id u56so2137894wes.16
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 15:49:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

datapath.c should not access private vport data. This commit adds
'ovs_vport_get_index()' to vport.c and '.get_index()' to vport_ops
to hide vport implementation details.

Signed-off-by: Daniele Di Proietto <daniele.di.proietto@gmail.com>
---
 net/openvswitch/datapath.c           | 5 +----
 net/openvswitch/vport-internal_dev.c | 1 +
 net/openvswitch/vport-netdev.c       | 8 ++++++++
 net/openvswitch/vport-netdev.h       | 1 +
 net/openvswitch/vport.c              | 9 +++++++++
 net/openvswitch/vport.h              | 2 ++
 6 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4e9a5f0..a1b113f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -185,10 +185,7 @@ static int get_dpifindex(const struct datapath *dp)
 	rcu_read_lock();
 
 	local = ovs_vport_rcu(dp, OVSP_LOCAL);
-	if (local)
-		ifindex = netdev_vport_priv(local)->dev->ifindex;
-	else
-		ifindex = 0;
+	ifindex = ovs_vport_get_index(local);
 
 	rcu_read_unlock();
 
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 6a55f71..d0090b0 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -250,6 +250,7 @@ static struct vport_ops ovs_internal_vport_ops = {
 	.create		= internal_dev_create,
 	.destroy	= internal_dev_destroy,
 	.get_name	= ovs_netdev_get_name,
+	.get_index	= ovs_netdev_get_index,
 	.send		= internal_dev_recv,
 };
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4776282..06a4824 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -182,6 +182,13 @@ const char *ovs_netdev_get_name(const struct vport *vport)
 	return netdev_vport->dev->name;
 }
 
+int ovs_netdev_get_index(const struct vport *vport)
+{
+	const struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+
+	return netdev_vport->dev->ifindex;
+}
+
 static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
@@ -231,6 +238,7 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
 	.get_name	= ovs_netdev_get_name,
+	.get_index	= ovs_netdev_get_index,
 	.send		= netdev_send,
 };
 
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 6f7038e..892520a 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -39,6 +39,7 @@ netdev_vport_priv(const struct vport *vport)
 }
 
 const char *ovs_netdev_get_name(const struct vport *);
+int ovs_netdev_get_index(const struct vport *);
 void ovs_netdev_detach_dev(struct vport *);
 
 int __init ovs_netdev_init(void);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 53f3ebb..884bba5 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -633,3 +633,12 @@ int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 
 	return vport->ops->get_egress_tun_info(vport, skb, info);
 }
+
+int ovs_vport_get_index(const struct vport *vport)
+{
+	/* return 0 if get_index is not implemented */
+	if (!vport || !vport->ops->get_index)
+		return 0;
+
+	return vport->ops->get_index(vport);
+}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 99c8e71..8645dab 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -57,6 +57,7 @@ int ovs_vport_get_upcall_portids(const struct vport *, struct sk_buff *);
 u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
 int ovs_vport_send(struct vport *, struct sk_buff *);
+int ovs_vport_get_index(const struct vport *);
 
 int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
 			       struct net *net,
@@ -171,6 +172,7 @@ struct vport_ops {
 
 	/* Called with rcu_read_lock or ovs_mutex. */
 	const char *(*get_name)(const struct vport *);
+	int (*get_index)(const struct vport *);
 
 	int (*send)(struct vport *, struct sk_buff *);
 	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
-- 
2.1.4
