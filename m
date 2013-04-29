From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2] openvswitch: Remove unneeded ovs_netdev_get_ifindex()
Date: Tue, 30 Apr 2013 01:06:41 +0200
Message-ID: <ccb6cc7843629082ac121043a00947a15561f26f.1367276702.git.tgraf@suug.ch>
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:51320
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757559Ab3D2XGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 19:06:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only user is get_dpifindex(), no need to redirect via the port
operations.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
V2 - Fix stylistic issue

 net/openvswitch/datapath.c           | 3 ++-
 net/openvswitch/vport-internal_dev.c | 1 -
 net/openvswitch/vport-netdev.c       | 7 -------
 net/openvswitch/vport-netdev.h       | 1 -
 net/openvswitch/vport.h              | 2 --
 5 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 74a5fe6..d12d6b8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -56,6 +56,7 @@
 #include "datapath.h"
 #include "flow.h"
 #include "vport-internal_dev.h"
+#include "vport-netdev.h"
 
 
 #define REHASH_FLOW_INTERVAL (10 * 60 * HZ)
@@ -151,7 +152,7 @@ static int get_dpifindex(struct datapath *dp)
 
 	local = ovs_vport_rcu(dp, OVSP_LOCAL);
 	if (local)
-		ifindex = local->ops->get_ifindex(local);
+		ifindex = netdev_vport_priv(local)->dev->ifindex;
 	else
 		ifindex = 0;
 
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 73682de..84e0a03 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -232,7 +232,6 @@ const struct vport_ops ovs_internal_vport_ops = {
 	.create		= internal_dev_create,
 	.destroy	= internal_dev_destroy,
 	.get_name	= ovs_netdev_get_name,
-	.get_ifindex	= ovs_netdev_get_ifindex,
 	.send		= internal_dev_recv,
 };
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 40a89ae..4f01c6d 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -150,12 +150,6 @@ const char *ovs_netdev_get_name(const struct vport *vport)
 	return netdev_vport->dev->name;
 }
 
-int ovs_netdev_get_ifindex(const struct vport *vport)
-{
-	const struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
-	return netdev_vport->dev->ifindex;
-}
-
 static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
@@ -206,6 +200,5 @@ const struct vport_ops ovs_netdev_vport_ops = {
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
 	.get_name	= ovs_netdev_get_name,
-	.get_ifindex	= ovs_netdev_get_ifindex,
 	.send		= netdev_send,
 };
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 6478079..a3cb3a3 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -40,6 +40,5 @@ netdev_vport_priv(const struct vport *vport)
 
 const char *ovs_netdev_get_name(const struct vport *);
 const char *ovs_netdev_get_config(const struct vport *);
-int ovs_netdev_get_ifindex(const struct vport *);
 
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 7ba08c3..68a377b 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -124,7 +124,6 @@ struct vport_parms {
  * have any configuration.
  * @get_name: Get the device's name.
  * @get_config: Get the device's configuration.
- * @get_ifindex: Get the system interface index associated with the device.
  * May be null if the device does not have an ifindex.
  * @send: Send a packet on the device.  Returns the length of the packet sent.
  */
@@ -141,7 +140,6 @@ struct vport_ops {
 	/* Called with rcu_read_lock or ovs_mutex. */
 	const char *(*get_name)(const struct vport *);
 	void (*get_config)(const struct vport *, void *);
-	int (*get_ifindex)(const struct vport *);
 
 	int (*send)(struct vport *, struct sk_buff *);
 };
-- 
1.7.11.7
