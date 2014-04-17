From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v3 09/10] openvswitch: introduce vport_op get_netdev
Date: Thu, 17 Apr 2014 14:14:36 +0200
Message-ID: <1397736876-11771-10-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:58299 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945905AbaDQMPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 08:15:16 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so603466eei.14
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 05:15:15 -0700 (PDT)
In-Reply-To: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow to query easily if the vport has netdev. Also it allows
to unexpose netdev_vport_priv and struct netdev_vport.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/openvswitch/datapath.c           |  2 +-
 net/openvswitch/dp_notify.c          |  7 ++---
 net/openvswitch/vport-internal_dev.c | 53 ++++++++++++++++++++++++------------
 net/openvswitch/vport-netdev.c       | 16 +++++++++++
 net/openvswitch/vport-netdev.h       | 12 --------
 net/openvswitch/vport.h              |  2 ++
 6 files changed, 57 insertions(+), 35 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index fcbdb52..10ffb0a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -148,7 +148,7 @@ static int get_dpifindex(struct datapath *dp)
 
 	local = ovs_vport_rcu(dp, OVSP_LOCAL);
 	if (local)
-		ifindex = netdev_vport_priv(local)->dev->ifindex;
+		ifindex = local->ops->get_netdev(local)->ifindex;
 	else
 		ifindex = 0;
 
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 2c631fe..d2cc24b 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -58,13 +58,12 @@ void ovs_dp_notify_wq(struct work_struct *work)
 			struct hlist_node *n;
 
 			hlist_for_each_entry_safe(vport, n, &dp->ports[i], dp_hash_node) {
-				struct netdev_vport *netdev_vport;
+				struct net_device *dev;
 
 				if (vport->ops->type != OVS_VPORT_TYPE_NETDEV)
 					continue;
-
-				netdev_vport = netdev_vport_priv(vport);
-				if (!(netdev_vport->dev->priv_flags & IFF_OVS_DATAPATH))
+				dev = vport->ops->get_netdev(vport);
+				if (!(dev->priv_flags & IFF_OVS_DATAPATH))
 					dp_detach_port_notify(vport);
 			}
 		}
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 729c687..86ba186 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -31,6 +31,16 @@
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
+struct internal_dev_vport {
+	struct rcu_head rcu;
+	struct net_device *dev;
+};
+
+static struct internal_dev_vport *internal_dev_vport_priv(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
 struct internal_dev {
 	struct vport *vport;
 };
@@ -145,48 +155,49 @@ static void do_setup(struct net_device *netdev)
 static struct vport *internal_dev_create(const struct vport_parms *parms)
 {
 	struct vport *vport;
-	struct netdev_vport *netdev_vport;
+	struct internal_dev_vport *int_vport;
 	struct internal_dev *internal_dev;
+	struct net_device *dev;
 	int err;
 
-	vport = ovs_vport_alloc(sizeof(struct netdev_vport),
+	vport = ovs_vport_alloc(sizeof(struct internal_dev_vport),
 				&ovs_internal_vport_ops, parms);
 	if (IS_ERR(vport)) {
 		err = PTR_ERR(vport);
 		goto error;
 	}
 
-	netdev_vport = netdev_vport_priv(vport);
+	int_vport = internal_dev_vport_priv(vport);
 
-	netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
-					 parms->name, do_setup);
-	if (!netdev_vport->dev) {
+	dev = alloc_netdev(sizeof(struct internal_dev), parms->name, do_setup);
+	if (!dev) {
 		err = -ENOMEM;
 		goto error_free_vport;
 	}
+	int_vport->dev = dev;
 
-	dev_net_set(netdev_vport->dev, ovs_dp_get_net(vport->dp));
-	internal_dev = internal_dev_priv(netdev_vport->dev);
+	dev_net_set(dev, ovs_dp_get_net(vport->dp));
+	internal_dev = internal_dev_priv(dev);
 	internal_dev->vport = vport;
 
 	/* Restrict bridge port to current netns. */
 	if (vport->port_no == OVSP_LOCAL)
-		netdev_vport->dev->features |= NETIF_F_NETNS_LOCAL;
+		dev->features |= NETIF_F_NETNS_LOCAL;
 
 	rtnl_lock();
-	err = register_netdevice(netdev_vport->dev);
+	err = register_netdevice(dev);
 	if (err)
 		goto error_free_netdev;
 
-	dev_set_promiscuity(netdev_vport->dev, 1);
+	dev_set_promiscuity(dev, 1);
 	rtnl_unlock();
-	netif_start_queue(netdev_vport->dev);
+	netif_start_queue(dev);
 
 	return vport;
 
 error_free_netdev:
 	rtnl_unlock();
-	free_netdev(netdev_vport->dev);
+	free_netdev(dev);
 error_free_vport:
 	ovs_vport_free(vport);
 error:
@@ -195,21 +206,21 @@ error:
 
 static void internal_dev_destroy(struct vport *vport)
 {
-	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+	struct internal_dev_vport *int_vport = internal_dev_vport_priv(vport);
 
-	netif_stop_queue(netdev_vport->dev);
+	netif_stop_queue(int_vport->dev);
 	rtnl_lock();
-	dev_set_promiscuity(netdev_vport->dev, -1);
+	dev_set_promiscuity(int_vport->dev, -1);
 
 	/* unregister_netdevice() waits for an RCU grace period. */
-	unregister_netdevice(netdev_vport->dev);
+	unregister_netdevice(int_vport->dev);
 
 	rtnl_unlock();
 }
 
 static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 {
-	struct net_device *netdev = netdev_vport_priv(vport)->dev;
+	struct net_device *netdev = internal_dev_vport_priv(vport)->dev;
 	int len;
 
 	len = skb->len;
@@ -228,12 +239,18 @@ static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	return len;
 }
 
+static struct net_device *internal_dev_get_netdev(struct vport *vport)
+{
+	return internal_dev_vport_priv(vport)->dev;
+}
+
 const struct vport_ops ovs_internal_vport_ops = {
 	.type		= OVS_VPORT_TYPE_INTERNAL,
 	.create		= internal_dev_create,
 	.destroy	= internal_dev_destroy,
 	.get_name	= ovs_netdev_get_name,
 	.send		= internal_dev_recv,
+	.get_netdev	= internal_dev_get_netdev,
 };
 
 int ovs_is_internal_dev(const struct net_device *netdev)
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index d21f77d..aaf3d14 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -33,6 +33,16 @@
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
+struct netdev_vport {
+	struct rcu_head rcu;
+	struct net_device *dev;
+};
+
+static struct netdev_vport *netdev_vport_priv(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
 /* Must be called with rcu_read_lock. */
 static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 {
@@ -224,10 +234,16 @@ struct vport *ovs_netdev_get_vport(struct net_device *dev)
 		return NULL;
 }
 
+static struct net_device *netdev_get_netdev(struct vport *vport)
+{
+	return netdev_vport_priv(vport)->dev;
+}
+
 const struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
 	.get_name	= ovs_netdev_get_name,
 	.send		= netdev_send,
+	.get_netdev	= netdev_get_netdev,
 };
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 8df01c11..f03d41d 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -26,18 +26,6 @@
 
 struct vport *ovs_netdev_get_vport(struct net_device *dev);
 
-struct netdev_vport {
-	struct rcu_head rcu;
-
-	struct net_device *dev;
-};
-
-static inline struct netdev_vport *
-netdev_vport_priv(const struct vport *vport)
-{
-	return vport_priv(vport);
-}
-
 const char *ovs_netdev_get_name(const struct vport *);
 void ovs_netdev_detach_dev(struct vport *);
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 0979304..d7d3af9 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -145,6 +145,8 @@ struct vport_ops {
 	const char *(*get_name)(const struct vport *);
 
 	int (*send)(struct vport *, struct sk_buff *);
+
+	struct net_device *(*get_netdev)(struct vport *);
 };
 
 enum vport_err_type {
-- 
1.9.0
