From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 09/14] openvswitch: Move dev pointer into vport itself
Date: Mon,  1 Jun 2015 16:27:33 +0200
Message-ID: <4568958567a1f1d0e23ff00d1b74ce97cd9a46ab.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51021 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbbFAO1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:52 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first step in representing all OVS vports as regular
struct net_devices. Move the net_device pointer into the vport
structure itself to get rid of struct vport_netdev.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c           |  7 +--
 net/openvswitch/dp_notify.c          |  5 +--
 net/openvswitch/vport-internal_dev.c | 37 +++++++---------
 net/openvswitch/vport-netdev.c       | 84 ++++++++++++++++--------------------
 net/openvswitch/vport-netdev.h       | 12 ------
 net/openvswitch/vport.h              |  3 +-
 6 files changed, 58 insertions(+), 90 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 3315e3a..c3ecfd4 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -188,7 +188,7 @@ static int get_dpifindex(const struct datapath *dp)
 
 	local = ovs_vport_rcu(dp, OVSP_LOCAL);
 	if (local)
-		ifindex = netdev_vport_priv(local)->dev->ifindex;
+		ifindex = local->dev->ifindex;
 	else
 		ifindex = 0;
 
@@ -2205,13 +2205,10 @@ static void __net_exit list_vports_from_net(struct net *net, struct net *dnet,
 			struct vport *vport;
 
 			hlist_for_each_entry(vport, &dp->ports[i], dp_hash_node) {
-				struct netdev_vport *netdev_vport;
-
 				if (vport->ops->type != OVS_VPORT_TYPE_INTERNAL)
 					continue;
 
-				netdev_vport = netdev_vport_priv(vport);
-				if (dev_net(netdev_vport->dev) == dnet)
+				if (dev_net(vport->dev) == dnet)
 					list_add(&vport->detach_list, head);
 			}
 		}
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 2c631fe..a7a80a6 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -58,13 +58,10 @@ void ovs_dp_notify_wq(struct work_struct *work)
 			struct hlist_node *n;
 
 			hlist_for_each_entry_safe(vport, n, &dp->ports[i], dp_hash_node) {
-				struct netdev_vport *netdev_vport;
-
 				if (vport->ops->type != OVS_VPORT_TYPE_NETDEV)
 					continue;
 
-				netdev_vport = netdev_vport_priv(vport);
-				if (!(netdev_vport->dev->priv_flags & IFF_OVS_DATAPATH))
+				if (!(vport->dev->priv_flags & IFF_OVS_DATAPATH))
 					dp_detach_port_notify(vport);
 			}
 		}
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 6a55f71..a2c205d 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -156,49 +156,44 @@ static void do_setup(struct net_device *netdev)
 static struct vport *internal_dev_create(const struct vport_parms *parms)
 {
 	struct vport *vport;
-	struct netdev_vport *netdev_vport;
 	struct internal_dev *internal_dev;
 	int err;
 
-	vport = ovs_vport_alloc(sizeof(struct netdev_vport),
-				&ovs_internal_vport_ops, parms);
+	vport = ovs_vport_alloc(0, &ovs_internal_vport_ops, parms);
 	if (IS_ERR(vport)) {
 		err = PTR_ERR(vport);
 		goto error;
 	}
 
-	netdev_vport = netdev_vport_priv(vport);
-
-	netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
-					 parms->name, NET_NAME_UNKNOWN,
-					 do_setup);
-	if (!netdev_vport->dev) {
+	vport->dev = alloc_netdev(sizeof(struct internal_dev),
+				  parms->name, NET_NAME_UNKNOWN, do_setup);
+	if (!vport->dev) {
 		err = -ENOMEM;
 		goto error_free_vport;
 	}
 
-	dev_net_set(netdev_vport->dev, ovs_dp_get_net(vport->dp));
-	internal_dev = internal_dev_priv(netdev_vport->dev);
+	dev_net_set(vport->dev, ovs_dp_get_net(vport->dp));
+	internal_dev = internal_dev_priv(vport->dev);
 	internal_dev->vport = vport;
 
 	/* Restrict bridge port to current netns. */
 	if (vport->port_no == OVSP_LOCAL)
-		netdev_vport->dev->features |= NETIF_F_NETNS_LOCAL;
+		vport->dev->features |= NETIF_F_NETNS_LOCAL;
 
 	rtnl_lock();
-	err = register_netdevice(netdev_vport->dev);
+	err = register_netdevice(vport->dev);
 	if (err)
 		goto error_free_netdev;
 
-	dev_set_promiscuity(netdev_vport->dev, 1);
+	dev_set_promiscuity(vport->dev, 1);
 	rtnl_unlock();
-	netif_start_queue(netdev_vport->dev);
+	netif_start_queue(vport->dev);
 
 	return vport;
 
 error_free_netdev:
 	rtnl_unlock();
-	free_netdev(netdev_vport->dev);
+	free_netdev(vport->dev);
 error_free_vport:
 	ovs_vport_free(vport);
 error:
@@ -207,21 +202,19 @@ error:
 
 static void internal_dev_destroy(struct vport *vport)
 {
-	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
-
-	netif_stop_queue(netdev_vport->dev);
+	netif_stop_queue(vport->dev);
 	rtnl_lock();
-	dev_set_promiscuity(netdev_vport->dev, -1);
+	dev_set_promiscuity(vport->dev, -1);
 
 	/* unregister_netdevice() waits for an RCU grace period. */
-	unregister_netdevice(netdev_vport->dev);
+	unregister_netdevice(vport->dev);
 
 	rtnl_unlock();
 }
 
 static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 {
-	struct net_device *netdev = netdev_vport_priv(vport)->dev;
+	struct net_device *netdev = vport->dev;
 	int len;
 
 	if (unlikely(!(netdev->flags & IFF_UP))) {
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4776282..cb22051 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -83,103 +83,96 @@ static struct net_device *get_dpdev(const struct datapath *dp)
 
 	local = ovs_vport_ovsl(dp, OVSP_LOCAL);
 	BUG_ON(!local);
-	return netdev_vport_priv(local)->dev;
+	return local->dev;
 }
 
-static struct vport *netdev_create(const struct vport_parms *parms)
+static struct vport *netdev_link(struct vport *vport, const char *name)
 {
-	struct vport *vport;
-	struct netdev_vport *netdev_vport;
 	int err;
 
-	vport = ovs_vport_alloc(sizeof(struct netdev_vport),
-				&ovs_netdev_vport_ops, parms);
-	if (IS_ERR(vport)) {
-		err = PTR_ERR(vport);
-		goto error;
-	}
-
-	netdev_vport = netdev_vport_priv(vport);
-
-	netdev_vport->dev = dev_get_by_name(ovs_dp_get_net(vport->dp), parms->name);
-	if (!netdev_vport->dev) {
+	vport->dev = dev_get_by_name(ovs_dp_get_net(vport->dp), name);
+	if (!vport->dev) {
 		err = -ENODEV;
 		goto error_free_vport;
 	}
 
-	if (netdev_vport->dev->flags & IFF_LOOPBACK ||
-	    netdev_vport->dev->type != ARPHRD_ETHER ||
-	    ovs_is_internal_dev(netdev_vport->dev)) {
+	if (vport->dev->flags & IFF_LOOPBACK ||
+	    vport->dev->type != ARPHRD_ETHER ||
+	    ovs_is_internal_dev(vport->dev)) {
 		err = -EINVAL;
 		goto error_put;
 	}
 
 	rtnl_lock();
-	err = netdev_master_upper_dev_link(netdev_vport->dev,
+	err = netdev_master_upper_dev_link(vport->dev,
 					   get_dpdev(vport->dp));
 	if (err)
 		goto error_unlock;
 
-	err = netdev_rx_handler_register(netdev_vport->dev, netdev_frame_hook,
+	err = netdev_rx_handler_register(vport->dev, netdev_frame_hook,
 					 vport);
 	if (err)
 		goto error_master_upper_dev_unlink;
 
-	dev_set_promiscuity(netdev_vport->dev, 1);
-	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
+	dev_set_promiscuity(vport->dev, 1);
+	vport->dev->priv_flags |= IFF_OVS_DATAPATH;
 	rtnl_unlock();
 
 	return vport;
 
 error_master_upper_dev_unlink:
-	netdev_upper_dev_unlink(netdev_vport->dev, get_dpdev(vport->dp));
+	netdev_upper_dev_unlink(vport->dev, get_dpdev(vport->dp));
 error_unlock:
 	rtnl_unlock();
 error_put:
-	dev_put(netdev_vport->dev);
+	dev_put(vport->dev);
 error_free_vport:
 	ovs_vport_free(vport);
-error:
 	return ERR_PTR(err);
 }
 
+static struct vport *netdev_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+
+	vport = ovs_vport_alloc(0, &ovs_netdev_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	return netdev_link(vport, parms->name);
+}
+
 static void free_port_rcu(struct rcu_head *rcu)
 {
-	struct netdev_vport *netdev_vport = container_of(rcu,
-					struct netdev_vport, rcu);
+	struct vport *vport = container_of(rcu, struct vport, rcu);
 
-	dev_put(netdev_vport->dev);
-	ovs_vport_free(vport_from_priv(netdev_vport));
+	dev_put(vport->dev);
+	ovs_vport_free(vport);
 }
 
 void ovs_netdev_detach_dev(struct vport *vport)
 {
-	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
-
 	ASSERT_RTNL();
-	netdev_vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
-	netdev_rx_handler_unregister(netdev_vport->dev);
-	netdev_upper_dev_unlink(netdev_vport->dev,
-				netdev_master_upper_dev_get(netdev_vport->dev));
-	dev_set_promiscuity(netdev_vport->dev, -1);
+	vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
+	netdev_rx_handler_unregister(vport->dev);
+	netdev_upper_dev_unlink(vport->dev,
+				netdev_master_upper_dev_get(vport->dev));
+	dev_set_promiscuity(vport->dev, -1);
 }
 
 static void netdev_destroy(struct vport *vport)
 {
-	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
-
 	rtnl_lock();
-	if (netdev_vport->dev->priv_flags & IFF_OVS_DATAPATH)
+	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
 		ovs_netdev_detach_dev(vport);
 	rtnl_unlock();
 
-	call_rcu(&netdev_vport->rcu, free_port_rcu);
+	call_rcu(&vport->rcu, free_port_rcu);
 }
 
 const char *ovs_netdev_get_name(const struct vport *vport)
 {
-	const struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
-	return netdev_vport->dev->name;
+	return vport->dev->name;
 }
 
 static unsigned int packet_length(const struct sk_buff *skb)
@@ -194,18 +187,17 @@ static unsigned int packet_length(const struct sk_buff *skb)
 
 static int netdev_send(struct vport *vport, struct sk_buff *skb)
 {
-	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
-	int mtu = netdev_vport->dev->mtu;
+	int mtu = vport->dev->mtu;
 	int len;
 
 	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
 		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
-				     netdev_vport->dev->name,
+				     vport->dev->name,
 				     packet_length(skb), mtu);
 		goto drop;
 	}
 
-	skb->dev = netdev_vport->dev;
+	skb->dev = vport->dev;
 	len = skb->len;
 	dev_queue_xmit(skb);
 
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 6f7038e..1c52aed 100644
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
index 75d6824..e05ec68 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -107,7 +107,7 @@ struct vport_portids {
  * @detach_list: list used for detaching vport in net-exit call.
  */
 struct vport {
-	struct rcu_head rcu;
+	struct net_device *dev;
 	struct datapath	*dp;
 	struct vport_portids __rcu *upcall_portids;
 	u16 port_no;
@@ -120,6 +120,7 @@ struct vport {
 
 	struct vport_err_stats err_stats;
 	struct list_head detach_list;
+	struct rcu_head rcu;
 };
 
 /**
-- 
2.3.5
