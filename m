From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next RFC v2 5/6] openvswitch: Introduce
	support for switchdev based datapath
Date: Wed, 26 Mar 2014 17:31:11 +0100
Message-ID: <1395851472-10524-6-git-send-email-jiri@resnulli.us>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395851472-10524-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/uapi/linux/openvswitch.h           |   4 +
 net/openvswitch/Makefile                   |   4 +
 net/openvswitch/datapath.c                 |  45 ++++++-
 net/openvswitch/datapath.h                 |   8 ++
 net/openvswitch/dp_notify.c                |   3 +-
 net/openvswitch/vport-internal_switchdev.c | 179 +++++++++++++++++++++++++
 net/openvswitch/vport-internal_switchdev.h |  28 ++++
 net/openvswitch/vport-netdev.c             |   4 +-
 net/openvswitch/vport-switchportdev.c      | 205 +++++++++++++++++++++++++++++
 net/openvswitch/vport-switchportdev.h      |  24 ++++
 net/openvswitch/vport.c                    |   4 +
 net/openvswitch/vport.h                    |   2 +
 12 files changed, 504 insertions(+), 6 deletions(-)
 create mode 100644 net/openvswitch/vport-internal_switchdev.c
 create mode 100644 net/openvswitch/vport-internal_switchdev.h
 create mode 100644 net/openvswitch/vport-switchportdev.c
 create mode 100644 net/openvswitch/vport-switchportdev.h

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 970553c..8df1a49 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -189,6 +189,10 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_INTERNAL, /* network device implemented by datapath */
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
 	OVS_VPORT_TYPE_VXLAN,	 /* VXLAN tunnel. */
+	OVS_VPORT_TYPE_INTERNAL_SWITCHDEV, /* network device which represents
+					      a hardware switch */
+	OVS_VPORT_TYPE_SWITCHPORTDEV, /* network device which represents
+					 a port of a hardware switch */
 	__OVS_VPORT_TYPE_MAX
 };
 
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 3591cb5..6e9fb2a 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -22,3 +22,7 @@ endif
 ifneq ($(CONFIG_OPENVSWITCH_GRE),)
 openvswitch-y += vport-gre.o
 endif
+
+ifneq ($(CONFIG_NET_SWITCHDEV),)
+openvswitch-y += vport-internal_switchdev.o vport-switchportdev.o
+endif
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f229ab6..6056325 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -58,7 +58,9 @@
 #include "flow_table.h"
 #include "flow_netlink.h"
 #include "vport-internal_dev.h"
+#include "vport-internal_switchdev.h"
 #include "vport-netdev.h"
+#include "vport-switchportdev.h"
 
 int ovs_net_id __read_mostly;
 
@@ -124,6 +126,9 @@ static struct datapath *get_dp(struct net *net, int dp_ifindex)
 	dev = dev_get_by_index_rcu(net, dp_ifindex);
 	if (dev) {
 		struct vport *vport = ovs_internal_dev_get_vport(dev);
+
+		if (!vport)
+			vport = ovs_internal_swdev_get_vport(dev);
 		if (vport)
 			dp = vport->dp;
 	}
@@ -768,6 +773,19 @@ static struct sk_buff *ovs_flow_cmd_build_info(struct ovs_flow *flow,
 	return skb;
 }
 
+static int ovs_dp_flow_insert(struct datapath *dp, struct sw_flow *flow)
+{
+	if (dp->ops && dp->ops->flow_insert)
+		return dp->ops->flow_insert(dp, flow);
+	return 0;
+}
+
+static void ovs_dp_flow_remove(struct datapath *dp, struct sw_flow *flow)
+{
+	if (dp->ops && dp->ops->flow_remove)
+		dp->ops->flow_remove(dp, flow);
+}
+
 static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -836,13 +854,15 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		flow->flow.key = masked_key;
 		flow->flow.unmasked_key = key;
 		rcu_assign_pointer(flow->sf_acts, acts);
+		acts = NULL;
 
 		/* Put flow in bucket. */
 		error = ovs_flow_tbl_insert(&dp->table, flow, &mask);
-		if (error) {
-			acts = NULL;
+		if (error)
 			goto err_flow_free;
-		}
+		error = ovs_dp_flow_insert(dp, &flow->flow);
+		if (error)
+			goto err_flow_tbl_remove;
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 	} else {
@@ -884,6 +904,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			     0, PTR_ERR(reply));
 	return 0;
 
+err_flow_tbl_remove:
+	ovs_flow_tbl_remove(&dp->table, flow);
 err_flow_free:
 	ovs_flow_free(flow, false);
 err_unlock_ovs:
@@ -981,6 +1003,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
+	ovs_dp_flow_remove(dp, &flow->flow);
 	ovs_flow_tbl_remove(&dp->table, flow);
 
 	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_portid,
@@ -1234,7 +1257,10 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	/* Set up our datapath device. */
 	parms.name = nla_data(a[OVS_DP_ATTR_NAME]);
-	parms.type = OVS_VPORT_TYPE_INTERNAL;
+	if (ovs_is_suitable_for_internal_swdev(sock_net(skb->sk), parms.name))
+		parms.type = OVS_VPORT_TYPE_INTERNAL_SWITCHDEV;
+	else
+		parms.type = OVS_VPORT_TYPE_INTERNAL;
 	parms.options = NULL;
 	parms.dp = dp;
 	parms.port_no = OVSP_LOCAL;
@@ -1572,6 +1598,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct vport *vport;
 	struct datapath *dp;
+	struct vport *local_vport;
 	u32 port_no;
 	int err;
 
@@ -1611,6 +1638,16 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	parms.name = nla_data(a[OVS_VPORT_ATTR_NAME]);
 	parms.type = nla_get_u32(a[OVS_VPORT_ATTR_TYPE]);
+
+	if (parms.type == OVS_VPORT_TYPE_NETDEV &&
+	    ovs_is_suitable_for_switchportdev(sock_net(skb->sk), parms.name))
+		parms.type = OVS_VPORT_TYPE_SWITCHPORTDEV;
+
+	local_vport = ovs_vport_ovsl(dp, OVSP_LOCAL);
+	if (local_vport->ops->type == OVS_VPORT_TYPE_INTERNAL_SWITCHDEV &&
+	    parms.type != OVS_VPORT_TYPE_SWITCHPORTDEV)
+		return -EOPNOTSUPP;
+
 	parms.options = a[OVS_VPORT_ATTR_OPTIONS];
 	parms.dp = dp;
 	parms.port_no = port_no;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 5388cac..584999b 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -58,6 +58,8 @@ struct dp_stats_percpu {
 	struct u64_stats_sync syncp;
 };
 
+struct dp_ops;
+
 /**
  * struct datapath - datapath for flow-based packet switching
  * @rcu: RCU callback head for deferred destruction.
@@ -90,6 +92,12 @@ struct datapath {
 #endif
 
 	u32 user_features;
+	const struct dp_ops *ops;
+};
+
+struct dp_ops {
+	int (*flow_insert)(struct datapath *dp, struct sw_flow *flow);
+	void (*flow_remove)(struct datapath *dp, struct sw_flow *flow);
 };
 
 /**
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 2c631fe..7f9b6ae 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -22,6 +22,7 @@
 
 #include "datapath.h"
 #include "vport-internal_dev.h"
+#include "vport-internal_switchdev.h"
 #include "vport-netdev.h"
 
 static void dp_detach_port_notify(struct vport *vport)
@@ -79,7 +80,7 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct vport *vport = NULL;
 
-	if (!ovs_is_internal_dev(dev))
+	if (!ovs_is_internal_dev(dev) && !ovs_is_internal_swdev(dev))
 		vport = ovs_netdev_get_vport(dev);
 
 	if (!vport)
diff --git a/net/openvswitch/vport-internal_switchdev.c b/net/openvswitch/vport-internal_switchdev.c
new file mode 100644
index 0000000..e11547f
--- /dev/null
+++ b/net/openvswitch/vport-internal_switchdev.c
@@ -0,0 +1,179 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/rcupdate.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/switchdev.h>
+
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
+#include "datapath.h"
+#include "vport-netdev.h"
+#include "vport-internal_switchdev.h"
+
+static int internal_swdev_flow_insert(struct datapath *dp, struct sw_flow *flow)
+{
+	struct vport *vport;
+	struct netdev_vport *netdev_vport;
+
+	vport = ovs_vport_ovsl(dp, OVSP_LOCAL);
+	netdev_vport = netdev_vport_priv(vport);
+	return swdev_flow_insert(netdev_vport->dev, flow);
+}
+
+static void internal_swdev_flow_remove(struct datapath *dp, struct sw_flow *flow)
+{
+	struct vport *vport;
+	struct netdev_vport *netdev_vport;
+
+	vport = ovs_vport_ovsl(dp, OVSP_LOCAL);
+	netdev_vport = netdev_vport_priv(vport);
+	swdev_flow_remove(netdev_vport->dev, flow);
+}
+
+static const struct dp_ops internal_swdev_dp_ops = {
+	.flow_insert = internal_swdev_flow_insert,
+	.flow_remove = internal_swdev_flow_remove,
+};
+
+static struct vport *internal_swdev_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+	struct netdev_vport *netdev_vport;
+	struct net_device *dev;
+	int err;
+
+	vport = ovs_vport_alloc(sizeof(struct netdev_vport),
+				&ovs_internal_swdev_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	netdev_vport = netdev_vport_priv(vport);
+
+	rtnl_lock();
+	dev = __dev_get_by_name(ovs_dp_get_net(vport->dp), parms->name);
+	if (!dev) {
+		err = -ENODEV;
+		goto error_free_vport;
+	}
+	if (!swdev_dev_check(dev)) {
+		err = -EINVAL;
+		goto error_free_vport;
+	}
+	netdev_vport->dev = dev;
+	vport->dp->ops = &internal_swdev_dp_ops;
+	dev_hold(dev);
+	rtnl_unlock();
+
+	return vport;
+
+error_free_vport:
+	rtnl_unlock();
+	ovs_vport_free(vport);
+	return ERR_PTR(err);
+}
+
+static void internal_swdev_free_rcu(struct rcu_head *rcu)
+{
+	struct netdev_vport *netdev_vport;
+
+	netdev_vport = container_of(rcu, struct netdev_vport, rcu);
+	ovs_vport_free(vport_from_priv(netdev_vport));
+}
+
+static void internal_swdev_destroy(struct vport *vport)
+{
+	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+
+	dev_put(netdev_vport->dev);
+	call_rcu(&netdev_vport->rcu, internal_swdev_free_rcu);
+}
+
+static int internal_swdev_send(struct vport *vport, struct sk_buff *skb)
+{
+	int len;
+
+	len = skb->len;
+	consume_skb(skb);
+	return len;
+}
+
+const struct vport_ops ovs_internal_swdev_vport_ops = {
+	.type		= OVS_VPORT_TYPE_INTERNAL_SWITCHDEV,
+	.create		= internal_swdev_create,
+	.destroy	= internal_swdev_destroy,
+	.get_name	= ovs_netdev_get_name,
+	.send		= internal_swdev_send,
+};
+
+bool ovs_is_suitable_for_internal_swdev(struct net *net, const char *name)
+{
+	struct net_device *dev;
+	bool ret;
+
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(net, name);
+	ret = dev ? swdev_dev_check(dev) : false;
+	rcu_read_unlock();
+	return ret;
+}
+
+struct vport *ovs_internal_swdev_get_vport_by_dp(const struct datapath *dp)
+{
+	struct vport *vport;
+
+	vport = ovs_vport_rcu(dp, OVSP_LOCAL);
+	if (vport->ops->type != OVS_VPORT_TYPE_INTERNAL_SWITCHDEV)
+		return NULL;
+	return vport;
+}
+
+struct vport *ovs_internal_swdev_get_vport(const struct net_device *dev)
+{
+	struct ovs_net *ovs_net = net_generic(dev_net(dev), ovs_net_id);
+	struct datapath *dp;
+	struct vport *vport = NULL;
+
+	if (!swdev_dev_check(dev))
+		return NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(dp, &ovs_net->dps, list_node) {
+		vport = ovs_internal_swdev_get_vport_by_dp(dp);
+		if (vport && netdev_vport_priv(vport)->dev == dev)
+			break;
+		vport = NULL;
+	}
+	rcu_read_unlock();
+	return vport;
+}
+
+bool ovs_is_internal_swdev(const struct net_device *dev)
+{
+	return ovs_internal_swdev_get_vport(dev) ? true : false;
+}
+
+struct net_device *ovs_internal_swdev_get_netdev(struct vport *vport)
+{
+	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+
+	return netdev_vport->dev;
+}
diff --git a/net/openvswitch/vport-internal_switchdev.h b/net/openvswitch/vport-internal_switchdev.h
new file mode 100644
index 0000000..7f320ff
--- /dev/null
+++ b/net/openvswitch/vport-internal_switchdev.h
@@ -0,0 +1,28 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef VPORT_INTERNAL_SWITCHDEV_H
+#define VPORT_INTERNAL_SWITCHDEV_H 1
+
+bool ovs_is_suitable_for_internal_swdev(struct net *net, const char *name);
+struct vport *ovs_internal_swdev_get_vport_by_dp(const struct datapath *dp);
+struct vport *ovs_internal_swdev_get_vport(const struct net_device *dev);
+bool ovs_is_internal_swdev(const struct net_device *dev);
+struct net_device *ovs_internal_swdev_get_netdev(struct vport *vport);
+
+#endif /* vport-internal_switchdev.h */
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index d21f77d..3121b59 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -31,6 +31,7 @@
 
 #include "datapath.h"
 #include "vport-internal_dev.h"
+#include "vport-internal_switchdev.h"
 #include "vport-netdev.h"
 
 /* Must be called with rcu_read_lock. */
@@ -107,7 +108,8 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 
 	if (netdev_vport->dev->flags & IFF_LOOPBACK ||
 	    netdev_vport->dev->type != ARPHRD_ETHER ||
-	    ovs_is_internal_dev(netdev_vport->dev)) {
+	    ovs_is_internal_dev(netdev_vport->dev) ||
+	    ovs_is_internal_swdev(netdev_vport->dev)) {
 		err = -EINVAL;
 		goto error_put;
 	}
diff --git a/net/openvswitch/vport-switchportdev.c b/net/openvswitch/vport-switchportdev.c
new file mode 100644
index 0000000..8657065
--- /dev/null
+++ b/net/openvswitch/vport-switchportdev.c
@@ -0,0 +1,205 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/rcupdate.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/if_vlan.h>
+#include <linux/switchdev.h>
+
+#include <net/net_namespace.h>
+
+#include "datapath.h"
+#include "vport-internal_switchdev.h"
+
+struct swportdev_vport {
+	struct rcu_head rcu;
+	struct net_device *dev;
+	struct packet_type pt;
+};
+
+static inline struct swportdev_vport *swportdev_vport_priv(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+static int vport_swportdev_rcv(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt,
+			       struct net_device *orig_dev)
+{
+	struct vport *vport = pt->priv;
+	struct dp_upcall_info upcall;
+	struct sw_flow_key key;
+	int err;
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		return NET_RX_DROP;
+
+	if (!skb->missed_flow || skb->pkt_type == PACKET_OUTGOING)
+		goto drop;
+
+	/* Extract flow from 'skb' into 'key'. */
+	err = ovs_flow_extract(skb, vport->port_no, &key);
+	if (unlikely(err))
+		goto drop;
+
+	upcall.cmd = OVS_PACKET_CMD_MISS;
+	upcall.key = &key;
+	upcall.userdata = NULL;
+	upcall.portid = vport->upcall_portid;
+	ovs_dp_upcall(vport->dp, skb, &upcall);
+	consume_skb(skb);
+	return NET_RX_SUCCESS;
+
+drop:
+	consume_skb(skb);
+	return NET_RX_DROP;
+}
+
+static struct vport *vport_swportdev_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+	struct vport *swdev_vport;
+	struct swportdev_vport *swportdev_vport;
+	struct net_device *dev;
+	int err;
+
+	swdev_vport = ovs_internal_swdev_get_vport_by_dp(parms->dp);
+	if (!swdev_vport)
+		return ERR_PTR(-EOPNOTSUPP);
+
+	vport = ovs_vport_alloc(sizeof(struct swportdev_vport),
+				&ovs_swportdev_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	swportdev_vport = swportdev_vport_priv(vport);
+
+	rtnl_lock();
+	dev = __dev_get_by_name(ovs_dp_get_net(vport->dp), parms->name);
+	if (!dev) {
+		err = -ENODEV;
+		goto error_free_vport;
+	}
+	if (!swportdev_dev_check(dev)) {
+		err = -EINVAL;
+		goto error_free_vport;
+	}
+	if (netdev_master_upper_dev_get(dev) !=
+	    ovs_internal_swdev_get_netdev(swdev_vport)) {
+		err = -EINVAL;
+		goto error_free_vport;
+	}
+
+	dev_hold(dev);
+	rtnl_unlock();
+	swportdev_vport->dev = dev;
+	swportdev_vport->pt.type = cpu_to_be16(ETH_P_ALL),
+	swportdev_vport->pt.dev = dev;
+	swportdev_vport->pt.func = vport_swportdev_rcv;
+	swportdev_vport->pt.priv = vport;
+	dev_add_pack(&swportdev_vport->pt);
+
+	return vport;
+
+error_free_vport:
+	rtnl_unlock();
+	ovs_vport_free(vport);
+	return ERR_PTR(err);
+}
+
+static void vport_swportdev_free_rcu(struct rcu_head *rcu)
+{
+	struct swportdev_vport *swportdev_vport;
+
+	swportdev_vport = container_of(rcu, struct swportdev_vport, rcu);
+	ovs_vport_free(vport_from_priv(swportdev_vport));
+}
+
+static void vport_swportdev_destroy(struct vport *vport)
+{
+	struct swportdev_vport *swportdev_vport = swportdev_vport_priv(vport);
+
+	__dev_remove_pack(&swportdev_vport->pt);
+	dev_put(swportdev_vport->dev);
+	call_rcu(&swportdev_vport->rcu, vport_swportdev_free_rcu);
+}
+
+static unsigned int packet_length(const struct sk_buff *skb)
+{
+	unsigned int length = skb->len - ETH_HLEN;
+
+	if (skb->protocol == htons(ETH_P_8021Q))
+		length -= VLAN_HLEN;
+
+	return length;
+}
+
+static int vport_swportdev_send(struct vport *vport, struct sk_buff *skb)
+{
+	struct swportdev_vport *swportdev_vport = swportdev_vport_priv(vport);
+	struct net_device *dev = swportdev_vport->dev;
+	int mtu = dev->mtu;
+	int len;
+
+	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
+		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
+				     dev->name, packet_length(skb), mtu);
+		goto drop;
+	}
+
+	skb->dev = dev;
+	len = skb->len;
+	dev_queue_xmit(skb);
+
+	return len;
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
+static const char *vport_swportdev_get_name(const struct vport *vport)
+{
+	struct swportdev_vport *swportdev_vport = swportdev_vport_priv(vport);
+
+	return swportdev_vport->dev->name;
+}
+
+const struct vport_ops ovs_swportdev_vport_ops = {
+	.type		= OVS_VPORT_TYPE_SWITCHPORTDEV,
+	.create		= vport_swportdev_create,
+	.destroy	= vport_swportdev_destroy,
+	.get_name	= vport_swportdev_get_name,
+	.send		= vport_swportdev_send,
+};
+
+bool ovs_is_suitable_for_switchportdev(struct net *net, const char *name)
+{
+	struct net_device *dev;
+	bool ret;
+
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(net, name);
+	ret = dev ? swportdev_dev_check(dev) : false;
+	rcu_read_unlock();
+	return ret;
+}
+
diff --git a/net/openvswitch/vport-switchportdev.h b/net/openvswitch/vport-switchportdev.h
new file mode 100644
index 0000000..b578794
--- /dev/null
+++ b/net/openvswitch/vport-switchportdev.h
@@ -0,0 +1,24 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef VPORT_SWITCHPORTDEV_H
+#define VPORT_SWITCHPORTDEV_H 1
+
+bool ovs_is_suitable_for_switchportdev(struct net *net, const char *name);
+
+#endif /* vport-switchportdev.h */
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 81b083c..39aa836 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -48,6 +48,10 @@ static const struct vport_ops *vport_ops_list[] = {
 #ifdef CONFIG_OPENVSWITCH_VXLAN
 	&ovs_vxlan_vport_ops,
 #endif
+#if IS_ENABLED(CONFIG_NET_SWITCHDEV)
+	&ovs_internal_swdev_vport_ops,
+	&ovs_swportdev_vport_ops,
+#endif
 };
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 0979304..100277f 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -199,6 +199,8 @@ extern const struct vport_ops ovs_netdev_vport_ops;
 extern const struct vport_ops ovs_internal_vport_ops;
 extern const struct vport_ops ovs_gre_vport_ops;
 extern const struct vport_ops ovs_vxlan_vport_ops;
+extern const struct vport_ops ovs_internal_swdev_vport_ops;
+extern const struct vport_ops ovs_swportdev_vport_ops;
 
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
-- 
1.8.5.3
