From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCHv2 bridge 4/7] bridge: Add netlink interface to configure vlans on bridge ports
Date: Wed, 19 Sep 2012 08:42:13 -0400
Message-ID: <1348058536-22607-5-git-send-email-vyasevic@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756354Ab2ISMmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 08:42:22 -0400
In-Reply-To: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a netlink interface to add and remove vlan configuration on bridge port.
The interface uses the RTM_SETLINK message and encodes the vlan
configuration inside the IFLA_AF_SPEC.  It is possble to include multiple
vlans to either add or remove in a single message.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_link.h |   22 +++++++++
 net/bridge/br_if.c      |   74 +++++++++++++++++++++++++++++
 net/bridge/br_netlink.c |  117 ++++++++++++++++++++++++++++++++++++++--------
 net/bridge/br_private.h |    2 +
 4 files changed, 194 insertions(+), 21 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index ac173bd..38dbcff 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -398,4 +398,26 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* Bridge Section
+ * [IFLA_AF_SPEC] = {
+ *   [AF_BRIDGE] = {
+ *	[IFLA_BR_VLAN_INFO] = ...
+ *   }
+ * }
+ */
+enum {
+	IFLA_BR_UNSPEC,
+	IFLA_BR_VLAN_INFO,
+	__IFLA_BR_MAX,
+};
+#define IFLA_BR_MAX (__IFLA_BR_MAX - 1)
+
+enum {
+	IFLA_BR_VLAN_UNSPEC,
+	IFLA_BR_VLAN_ADD,
+	IFLA_BR_VLAN_DEL,
+	__IFLA_BR_VLAN_MAX,
+};
+#define IFLA_BR_VLAN_MAX (__IFLA_BR_VLAN_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1c8fdc3..c6a66e2 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -23,6 +23,7 @@
 #include <linux/if_ether.h>
 #include <linux/slab.h>
 #include <net/sock.h>
+#include <linux/if_vlan.h>
 
 #include "br_private.h"
 
@@ -445,6 +446,79 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 }
 
+/* Called with RTNL */
+int br_set_port_vlan(struct net_bridge_port *p, unsigned short vlan)
+{
+	unsigned long table_size = BITS_TO_LONGS(br_vid(VLAN_N_VID));
+	unsigned long *vid_map = NULL;
+	__u16 vid = br_vid(vlan);
+	int ret = 0;
+
+	/* The vlan map is indexed by vid+1.  This way we can store
+	 * vid 0 (untagged) into the map as well.
+	 */
+	if (!p->vlan_map) {
+		vid_map = kzalloc(table_size, GFP_KERNEL);
+		if (!vid_map) {
+			return -ENOMEM;
+		}
+
+		set_bit(vid, vid_map);
+		rcu_assign_pointer(p->vlan_map, vid_map);
+		synchronize_net();
+	} else {
+		/* Map is already allocated */
+		set_bit(vid, rcu_dereference_rtnl(p->vlan_map));
+	}
+
+	return ret;
+}
+
+
+/* Called with RTNL */
+int br_del_port_vlan(struct net_bridge_port *p, unsigned short vlan)
+{
+	unsigned long first_bit;
+	unsigned long next_bit;
+	__u16 vid = br_vid(vlan);
+	unsigned long tbl_len = BITS_TO_LONGS(br_vid(VLAN_N_VID));
+
+	if (!p->vlan_map) {
+		return -EINVAL;
+	}
+
+	if (!test_bit(vlan, p->vlan_map)) {
+		return -EINVAL;
+	}
+
+	/* Check to see if any other vlans are in this table.  If this
+	 * is the last vlan, delete the whole table.  If this is not the
+	 * last vlan, just clear the bit.
+	 */
+	first_bit = find_first_bit(p->vlan_map, tbl_len);
+	next_bit = find_next_bit(p->vlan_map, tbl_len, (tbl_len - vid));
+
+	if (first_bit != vid || next_bit < tbl_len) {
+		/* There are other vlans still configured.  We can simply
+		 * clear our bit and be safe.
+		 */
+		clear_bit(vid, rcu_dereference_rtnl(p->vlan_map));
+	} else {
+		unsigned long *map = NULL;
+
+		/* This is the last vlan we are removing.  Replace the
+		 * map with a NULL pointer and free the old map
+		 */
+		map = rcu_dereference(p->vlan_map);
+
+		rcu_assign_pointer(p->vlan_map, NULL);
+		synchronize_net();
+		kfree(map);
+	}
+
+	return 0;
+}
+
 void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index fe41260..8a97f93 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -16,6 +16,7 @@
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
+#include <linux/if_vlan.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -140,6 +141,71 @@ skip:
 	return skb->len;
 }
 
+static int br_validate_vlan_info(struct nlattr *attr)
+{
+	struct nlattr *vinfo;
+	int rem;
+
+	nla_for_each_nested(vinfo, attr, rem) {
+		int type = nla_type(vinfo);
+		unsigned short vid = nla_get_u16(vinfo);
+
+		if (vid > VLAN_N_VID)
+			return -EINVAL;
+		
+		if (type < IFLA_BR_VLAN_ADD || type > IFLA_BR_VLAN_DEL)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+const struct nla_policy ifla_br_policy[IFLA_BR_MAX + 1] = {
+	[IFLA_BR_VLAN_INFO] = { .type = NLA_NESTED },
+};
+
+static int br_afspec(struct net_bridge_port *p, struct nlattr *af_spec)
+{
+	struct nlattr *vinfo;
+	struct nlattr *tb[IFLA_BR_MAX+1];
+	int err;
+	int rem;
+	
+	if (nla_type(af_spec) != AF_BRIDGE)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, IFLA_BR_MAX, af_spec, ifla_br_policy);
+	if (err)
+		return err;
+
+	if (tb[IFLA_BR_VLAN_INFO]) {
+		err = br_validate_vlan_info(tb[IFLA_BR_VLAN_INFO]);
+		if (err)
+			return err;
+		
+		nla_for_each_nested(vinfo, tb[IFLA_BR_VLAN_INFO], rem) {
+			int type = nla_type(vinfo);
+			unsigned short vid = nla_get_u16(vinfo);
+
+			switch (type) {
+				case IFLA_BR_VLAN_ADD:
+					br_set_port_vlan(p, vid);
+					break;
+				case IFLA_BR_VLAN_DEL:
+					br_del_port_vlan(p, vid);
+					break;
+			}
+		}
+	}
+
+	return 0;
+}
+
+const struct nla_policy ifla_policy[IFLA_MAX+1] = {
+	[IFLA_PROTINFO]	= { .type = NLA_U8 },
+	[IFLA_AF_SPEC]	= { .type = NLA_NESTED },
+};
+
 /*
  * Change state of port (ie from forwarding to blocking etc)
  * Used by spanning tree in user space.
@@ -148,26 +214,23 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
-	struct nlattr *protinfo;
+	struct nlattr *tb[IFLA_MAX+1];
 	struct net_device *dev;
 	struct net_bridge_port *p;
+	int err = 0;
 	u8 new_state;
 
 	if (nlmsg_len(nlh) < sizeof(*ifm))
 		return -EINVAL;
 
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err)
+		return err;
+	
 	ifm = nlmsg_data(nlh);
 	if (ifm->ifi_family != AF_BRIDGE)
 		return -EPFNOSUPPORT;
 
-	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
-	if (!protinfo || nla_len(protinfo) < sizeof(u8))
-		return -EINVAL;
-
-	new_state = nla_get_u8(protinfo);
-	if (new_state > BR_STATE_BLOCKING)
-		return -EINVAL;
-
 	dev = __dev_get_by_index(net, ifm->ifi_index);
 	if (!dev)
 		return -ENODEV;
@@ -176,23 +239,35 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	if (!p)
 		return -EINVAL;
 
-	/* if kernel STP is running, don't allow changes */
-	if (p->br->stp_enabled == BR_KERNEL_STP)
-		return -EBUSY;
+	if (tb[IFLA_PROTINFO]) {
+		new_state = nla_get_u8(tb[IFLA_PROTINFO]);
+		if (new_state > BR_STATE_BLOCKING)
+			return -EINVAL;
 
-	if (!netif_running(dev) ||
-	    (!netif_carrier_ok(dev) && new_state != BR_STATE_DISABLED))
-		return -ENETDOWN;
+		/* if kernel STP is running, don't allow changes */
+		if (p->br->stp_enabled == BR_KERNEL_STP)
+			return -EBUSY;
 
-	p->state = new_state;
-	br_log_state(p);
+		if (!netif_running(dev) ||
+		    (!netif_carrier_ok(dev) && new_state != BR_STATE_DISABLED))
+			return -ENETDOWN;
 
-	spin_lock_bh(&p->br->lock);
-	br_port_state_selection(p->br);
-	spin_unlock_bh(&p->br->lock);
+		p->state = new_state;
+		br_log_state(p);
 
-	br_ifinfo_notify(RTM_NEWLINK, p);
+		spin_lock_bh(&p->br->lock);
+		br_port_state_selection(p->br);
+		spin_unlock_bh(&p->br->lock);
 
+	}
+
+	if (tb[IFLA_AF_SPEC]) {
+		err = br_afspec(p, tb[IFLA_AF_SPEC]);
+		if (err)
+			return err;
+	}
+			
+	br_ifinfo_notify(RTM_NEWLINK, p);
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 166dcf4..8eb3ffc 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -417,6 +417,8 @@ extern int br_del_if(struct net_bridge *br,
 extern int br_min_mtu(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
+extern int br_set_port_vlan(struct net_bridge_port *p, unsigned short vid);
+extern int br_del_port_vlan(struct net_bridge_port *p, unsigned short vid);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-- 
1.7.7.6
