From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V4 08/13] bridge: Add netlink interface to configure vlans on bridge ports
Date: Wed, 19 Dec 2012 12:48:19 -0500
Message-ID: <1355939304-21804-9-git-send-email-vyasevic@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab2LSSRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 13:17:30 -0500
In-Reply-To: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a netlink interface to add and remove vlan configuration on bridge port.
The interface uses the RTM_SETLINK message and encodes the vlan
configuration inside the IFLA_AF_SPEC.  It is possble to include multiple
vlans to either add or remove in a single message.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |   17 ++++++
 net/bridge/br_if.c             |    1 +
 net/bridge/br_netlink.c        |  107 +++++++++++++++++++++++++++++++++-------
 3 files changed, 107 insertions(+), 18 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 52aa738..d0b4f5c 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -108,15 +108,32 @@ struct __fdb_entry {
  * [IFLA_AF_SPEC] = {
  *     [IFLA_BRIDGE_FLAGS]
  *     [IFLA_BRIDGE_MODE]
+ *     [IFLA_BRIDGE_VLAN_INFO]
  * }
  */
 enum {
 	IFLA_BRIDGE_FLAGS,
 	IFLA_BRIDGE_MODE,
+	IFLA_BRIDGE_VLAN_INFO,
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
 
+/* Bridge VLAN info
+ * [IFLA_BRIDGE_VLAN_INFO]
+ */
+enum {
+	BR_VLAN_ADD,
+	BR_VLAN_DEL,
+};
+
+struct bridge_vlan_info {
+	u16 op_code;
+	u16 flags;
+	u16 vid;
+	u16 unused;
+};
+
 /* Bridge multicast database attributes
  * [MDBA_MDB] = {
  *     [MDBA_MDB_ENTRY] = {
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c30fe29..33bc740 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -23,6 +23,7 @@
 #include <linux/if_ether.h>
 #include <linux/slab.h>
 #include <net/sock.h>
+#include <linux/if_vlan.h>
 
 #include "br_private.h"
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dead9df..84c6f04 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -16,6 +16,7 @@
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
+#include <uapi/linux/if_bridge.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -119,10 +120,14 @@ nla_put_failure:
  */
 void br_ifinfo_notify(int event, struct net_bridge_port *port)
 {
-	struct net *net = dev_net(port->dev);
+	struct net *net;
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
+	if (!port)
+		return;
+
+	net = dev_net(port->dev);
 	br_debug(port->br, "port %u(%s) event %d\n",
 		 (unsigned int)port->port_no, port->dev->name, event);
 
@@ -162,6 +167,57 @@ out:
 	return err;
 }
 
+const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
+	[IFLA_BRIDGE_FLAGS]	= { .type = NLA_U16 },
+	[IFLA_BRIDGE_MODE]	= { .type = NLA_U16 },
+	[IFLA_BRIDGE_VLAN_INFO]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct bridge_vlan_info), },
+};
+
+static int br_afspec(struct net_bridge *br, struct net_bridge_port *p,
+		     struct nlattr *af_spec)
+{
+	struct nlattr *tb[IFLA_BRIDGE_MAX+1];
+	int err = 0;
+
+	err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec, ifla_br_policy);
+	if (err)
+		return err;
+
+	if (tb[IFLA_BRIDGE_VLAN_INFO]) {
+		struct bridge_vlan_info *vinfo;
+
+		vinfo = nla_data(tb[IFLA_BRIDGE_VLAN_INFO]);
+
+		if (vinfo->vid > VLAN_N_VID)
+			return -EINVAL;
+
+		switch (vinfo->op_code) {
+		case BR_VLAN_ADD:
+			if (p)
+				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
+			else {
+				u16 flags = vinfo->flags | BRIDGE_FLAGS_SELF;
+				if (!br_vlan_add(br, vinfo->vid, flags))
+					err = -ENOMEM;
+			}
+			break;
+
+		case BR_VLAN_DEL:
+			if (p)
+				err = nbp_vlan_delete(p, vinfo->vid,
+						      vinfo->flags);
+			else {
+				u16 flags = vinfo->flags | BRIDGE_FLAGS_SELF;
+				err = br_vlan_delete(br, vinfo->vid, flags);
+			}
+			break;
+		}
+	}
+
+	return err;
+}
+
 static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_STATE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_COST]	= { .type = NLA_U32 },
@@ -238,6 +294,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 {
 	struct ifinfomsg *ifm;
 	struct nlattr *protinfo;
+	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
 	int err;
@@ -245,35 +302,49 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 	ifm = nlmsg_data(nlh);
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
-	if (!protinfo)
+	afspec = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_AF_SPEC);
+	if (!protinfo && !afspec)
 		return 0;
 
 	p = br_port_get_rtnl(dev);
-	if (!p)
+	/* We want to accept dev as bridge itself if the AF_SPEC
+	 * is set to see if someone is setting vlan info on the brigde.
+	 */
+	if (!p && ((dev->priv_flags & IFF_EBRIDGE) && !afspec))
 		return -EINVAL;
 
-	if (protinfo->nla_type & NLA_F_NESTED) {
-		err = nla_parse_nested(tb, IFLA_BRPORT_MAX,
-				       protinfo, ifla_brport_policy);
+	if (p && protinfo) {
+		if (protinfo->nla_type & NLA_F_NESTED) {
+			err = nla_parse_nested(tb, IFLA_BRPORT_MAX,
+					       protinfo, ifla_brport_policy);
+			if (err)
+				return err;
+
+			spin_lock_bh(&p->br->lock);
+			err = br_setport(p, tb);
+			spin_unlock_bh(&p->br->lock);
+		} else {
+			/* Binary compatability with old RSTP */
+			if (nla_len(protinfo) < sizeof(u8))
+				return -EINVAL;
+
+			spin_lock_bh(&p->br->lock);
+			err = br_set_port_state(p, nla_get_u8(protinfo));
+			spin_unlock_bh(&p->br->lock);
+		}
 		if (err)
-			return err;
-
-		spin_lock_bh(&p->br->lock);
-		err = br_setport(p, tb);
-		spin_unlock_bh(&p->br->lock);
-	} else {
-		/* Binary compatability with old RSTP */
-		if (nla_len(protinfo) < sizeof(u8))
-			return -EINVAL;
+			goto out;
+	}
 
-		spin_lock_bh(&p->br->lock);
-		err = br_set_port_state(p, nla_get_u8(protinfo));
-		spin_unlock_bh(&p->br->lock);
+	if (afspec) {
+		err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
+				afspec);
 	}
 
 	if (err == 0)
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
+out:
 	return err;
 }
 
-- 
1.7.7.6
