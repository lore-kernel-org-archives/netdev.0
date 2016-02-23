From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/5] ovs: propagate per dp max headroom to all vports
Date: Tue, 23 Feb 2016 13:53:48 +0100
Message-ID: <4d34406afd196957f32adb69eae3489a05c34086.1456163137.git.pabeni@redhat.com>
References: <cover.1456163137.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660AbcBWMyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 07:54:19 -0500
In-Reply-To: <cover.1456163137.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements bookkeeping support to compute the maximum
headroom for all the devices in each datapath. When said value
changes, the underlying devs are notified via the
ndo_set_rx_headroom method.

This also increases the internal vports xmit performance.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/openvswitch/datapath.c           | 48 ++++++++++++++++++++++++++++++++++++
 net/openvswitch/datapath.h           |  4 +++
 net/openvswitch/vport-internal_dev.c | 10 +++++++-
 3 files changed, 61 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index c4e8455..7b37288 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1908,6 +1908,34 @@ static struct vport *lookup_vport(struct net *net,
 		return ERR_PTR(-EINVAL);
 }
 
+/* Called with ovs_mutex */
+static void update_headroom(struct datapath *dp)
+{
+	int i;
+	struct vport *vport;
+	struct net_device *dev;
+	unsigned dev_headroom, max_headroom = 0;
+
+	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+		hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node) {
+			dev = vport->dev;
+			dev_headroom = netdev_get_fwd_headroom(dev);
+			if (dev_headroom > max_headroom)
+				max_headroom = dev_headroom;
+		}
+	}
+
+	dp->max_headroom = max_headroom;
+	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+		hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node) {
+			dev = vport->dev;
+			if (dev->netdev_ops->ndo_set_rx_headroom)
+				dev->netdev_ops->ndo_set_rx_headroom(dev,
+								  max_headroom);
+		}
+	}
+}
+
 static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -1973,6 +2001,13 @@ restart:
 
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
+
+	if (netdev_get_fwd_headroom(vport->dev) > dp->max_headroom)
+		update_headroom(dp);
+	else if (vport->dev->netdev_ops->ndo_set_rx_headroom)
+		vport->dev->netdev_ops->ndo_set_rx_headroom(vport->dev,
+							    dp->max_headroom);
+
 	BUG_ON(err < 0);
 	ovs_unlock();
 
@@ -2043,6 +2078,8 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct vport *vport;
 	int err;
+	struct datapath *dp;
+	bool must_update_headroom = false;
 
 	reply = ovs_vport_cmd_alloc_info();
 	if (!reply)
@@ -2062,7 +2099,18 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_DEL);
 	BUG_ON(err < 0);
+
+	/* check if the deletion of this port may change the dp max_headroom
+	 * before deleting the vport
+	 */
+	dp = vport->dp;
+	if (!(vport->dev->priv_flags & IFF_PHONY_HEADROOM) &&
+	    vport->dev->needed_headroom == dp->max_headroom)
+		must_update_headroom = true;
 	ovs_dp_detach_port(vport);
+
+	if (must_update_headroom)
+		update_headroom(dp);
 	ovs_unlock();
 
 	ovs_notify(&dp_vport_genl_family, reply, info);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 67bdecd..427e39a 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -68,6 +68,8 @@ struct dp_stats_percpu {
  * ovs_mutex and RCU.
  * @stats_percpu: Per-CPU datapath statistics.
  * @net: Reference to net namespace.
+ * @max_headroom: the maximum headroom of all vports in this datapath; it will
+ * be used by all the internal vports in this dp.
  *
  * Context: See the comment on locking at the top of datapath.c for additional
  * locking information.
@@ -89,6 +91,8 @@ struct datapath {
 	possible_net_t net;
 
 	u32 user_features;
+
+	u32 max_headroom;
 };
 
 /**
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index ec76398..83a5534 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -138,6 +138,11 @@ internal_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	return stats;
 }
 
+void internal_set_rx_headroom(struct net_device *dev, int new_hr)
+{
+	dev->needed_headroom = new_hr;
+}
+
 static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_open = internal_dev_open,
 	.ndo_stop = internal_dev_stop,
@@ -145,6 +150,7 @@ static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_change_mtu = internal_dev_change_mtu,
 	.ndo_get_stats64 = internal_get_stats,
+	.ndo_set_rx_headroom = internal_set_rx_headroom,
 };
 
 static struct rtnl_link_ops internal_dev_link_ops __read_mostly = {
@@ -158,7 +164,8 @@ static void do_setup(struct net_device *netdev)
 	netdev->netdev_ops = &internal_dev_netdev_ops;
 
 	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
-	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_OPENVSWITCH;
+	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_OPENVSWITCH |
+			      IFF_PHONY_HEADROOM;
 	netdev->destructor = internal_dev_destructor;
 	netdev->ethtool_ops = &internal_dev_ethtool_ops;
 	netdev->rtnl_link_ops = &internal_dev_link_ops;
@@ -199,6 +206,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 		err = -ENOMEM;
 		goto error_free_netdev;
 	}
+	vport->dev->needed_headroom = vport->dp->max_headroom;
 
 	dev_net_set(vport->dev, ovs_dp_get_net(vport->dp));
 	internal_dev = internal_dev_priv(vport->dev);
-- 
1.8.3.1
