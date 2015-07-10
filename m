From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 20/22] openvswitch: Abstract vport name through ovs_vport_name()
Date: Fri, 10 Jul 2015 16:19:22 +0200
Message-ID: <7f3dcd10bdc36c6bc0b63dde2e4cf6b83bd133f4.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40765 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932700AbbGJOTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:52 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to get rid of the get_name() vport ops later on.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c           | 4 ++--
 net/openvswitch/vport-internal_dev.c | 1 -
 net/openvswitch/vport-netdev.c       | 6 ------
 net/openvswitch/vport-netdev.h       | 1 -
 net/openvswitch/vport.c              | 4 ++--
 net/openvswitch/vport.h              | 5 +++++
 6 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 19df28e..ffe984f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -176,7 +176,7 @@ static inline struct datapath *get_dp(struct net *net, int dp_ifindex)
 const char *ovs_dp_name(const struct datapath *dp)
 {
 	struct vport *vport = ovs_vport_ovsl_rcu(dp, OVSP_LOCAL);
-	return vport->ops->get_name(vport);
+	return ovs_vport_name(vport);
 }
 
 static int get_dpifindex(const struct datapath *dp)
@@ -1800,7 +1800,7 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 	if (nla_put_u32(skb, OVS_VPORT_ATTR_PORT_NO, vport->port_no) ||
 	    nla_put_u32(skb, OVS_VPORT_ATTR_TYPE, vport->ops->type) ||
 	    nla_put_string(skb, OVS_VPORT_ATTR_NAME,
-			   vport->ops->get_name(vport)))
+			   ovs_vport_name(vport)))
 		goto nla_put_failure;
 
 	ovs_vport_get_stats(vport, &vport_stats);
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index a2c205d..c058bbf 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -242,7 +242,6 @@ static struct vport_ops ovs_internal_vport_ops = {
 	.type		= OVS_VPORT_TYPE_INTERNAL,
 	.create		= internal_dev_create,
 	.destroy	= internal_dev_destroy,
-	.get_name	= ovs_netdev_get_name,
 	.send		= internal_dev_recv,
 };
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 1c96966..e682bdc 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -171,11 +171,6 @@ static void netdev_destroy(struct vport *vport)
 	call_rcu(&vport->rcu, free_port_rcu);
 }
 
-const char *ovs_netdev_get_name(const struct vport *vport)
-{
-	return vport->dev->name;
-}
-
 static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
@@ -223,7 +218,6 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
-	.get_name	= ovs_netdev_get_name,
 	.send		= netdev_send,
 };
 
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 1c52aed..684fb88 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -26,7 +26,6 @@
 
 struct vport *ovs_netdev_get_vport(struct net_device *dev);
 
-const char *ovs_netdev_get_name(const struct vport *);
 void ovs_netdev_detach_dev(struct vport *);
 
 int __init ovs_netdev_init(void);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index af23ba0..d14f594 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -113,7 +113,7 @@ struct vport *ovs_vport_locate(const struct net *net, const char *name)
 	struct vport *vport;
 
 	hlist_for_each_entry_rcu(vport, bucket, hash_node)
-		if (!strcmp(name, vport->ops->get_name(vport)) &&
+		if (!strcmp(name, ovs_vport_name(vport)) &&
 		    net_eq(ovs_dp_get_net(vport->dp), net))
 			return vport;
 
@@ -226,7 +226,7 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 		}
 
 		bucket = hash_bucket(ovs_dp_get_net(vport->dp),
-				     vport->ops->get_name(vport));
+				     ovs_vport_name(vport));
 		hlist_add_head_rcu(&vport->hash_node, bucket);
 		return vport;
 	}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index e05ec68..1a689c2 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -237,6 +237,11 @@ static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 		skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
 }
 
+static inline const char *ovs_vport_name(struct vport *vport)
+{
+	return vport->dev ? vport->dev->name : vport->ops->get_name(vport);
+}
+
 int ovs_vport_ops_register(struct vport_ops *ops);
 void ovs_vport_ops_unregister(struct vport_ops *ops);
 
-- 
2.4.3
