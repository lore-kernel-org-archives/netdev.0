From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] openvswitch: compute needed headroom for internal vports
Date: Fri,  8 Jan 2016 22:50:06 +0100
Message-ID: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932634AbcAHVu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 16:50:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the ovs internal vports always use a default needed_headroom.
This leads to a skb head copy while xmitting on ovs swith via vport
that add some kind of encapsulation (gre, geneve, etc.).

This patch add book-keeping for the maximum needed_headroom used by
the non internal vports in any dp, updating it on vport creation and
deletion.

Said value is than used as needed_headroom for internal vports,
avoiding the above copy.

With ~1000 bytes long frames, this give about a 6% xmit performance
improvement in case of vxlan tunnels and about 8% when using geneve
tunnels.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Flavio Leitner <fbl@sysclose.org>
---
 net/openvswitch/datapath.c           | 39 ++++++++++++++++++++++++++++++++++++
 net/openvswitch/datapath.h           |  4 ++++
 net/openvswitch/vport-internal_dev.c |  1 +
 3 files changed, 44 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 91a8b00..c2c48b5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1915,6 +1915,28 @@ static struct vport *lookup_vport(struct net *net,
 		return ERR_PTR(-EINVAL);
 }
 
+/* Called with ovs_mutex */
+static void update_headroom(struct datapath *dp)
+{
+	int i;
+	struct vport *vport;
+	unsigned max_headroom = 0;
+
+	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+		hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node)
+			if (vport->ops->type != OVS_VPORT_TYPE_INTERNAL &&
+			    vport->dev->needed_headroom > max_headroom)
+				max_headroom = vport->dev->needed_headroom;
+	}
+
+	dp->max_headroom = max_headroom;
+	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+		hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node)
+			if (vport->ops->type == OVS_VPORT_TYPE_INTERNAL)
+				vport->dev->needed_headroom = max_headroom;
+	}
+}
+
 static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -1980,6 +2002,10 @@ restart:
 
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
+
+	if (vport->ops->type != OVS_VPORT_TYPE_INTERNAL &&
+	    vport->dev->needed_headroom > dp->max_headroom)
+		update_headroom(dp);
 	BUG_ON(err < 0);
 	ovs_unlock();
 
@@ -2050,6 +2076,8 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct vport *vport;
 	int err;
+	struct datapath *dp;
+	bool must_update_headroom = false;
 
 	reply = ovs_vport_cmd_alloc_info();
 	if (!reply)
@@ -2069,7 +2097,18 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_DEL);
 	BUG_ON(err < 0);
+
+	/* check if the deletion of this port may change the dp max_headroom
+	 * before deleting the vport
+	 */
+	dp = vport->dp;
+	if (vport->ops->type != OVS_VPORT_TYPE_INTERNAL &&
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
index ec76398..3d0a55a 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -199,6 +199,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 		err = -ENOMEM;
 		goto error_free_netdev;
 	}
+	vport->dev->needed_headroom = vport->dp->max_headroom;
 
 	dev_net_set(vport->dev, ovs_dp_get_net(vport->dp));
 	internal_dev = internal_dev_priv(vport->dev);
-- 
1.8.3.1
