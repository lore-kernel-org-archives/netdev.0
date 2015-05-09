From: sfeldma@gmail.com
Subject: [PATCH net-next v6 11/23] switchdev: add new switchdev bridge setlink
Date: Sat,  9 May 2015 10:40:13 -0700
Message-ID: <1431193225-807-12-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34090 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbbEIRn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:28 -0400
Received: by pacyx8 with SMTP id yx8so75718203pac.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:28 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add new switchdev_port_bridge_setlink that can be used by drivers
implementing .ndo_bridge_setlink to set switchdev bridge attributes.
Basically turn the raw rtnl_bridge_setlink netlink into switchdev attr
sets.  Proper netlink attr policy checking is done on the protinfo part of
the netlink msg.

Currently, for protinfo, only bridge port attrs BR_LEARNING and
BR_LEARNING_SYNC are parsed and passed to port driver.

For afspec, VLAN objs are passed so switchdev driver can set VLANs assigned
to SELF.  To illustrate with iproute2 cmd, we have:

	bridge vlan add vid 10 dev sw1p1 self master

To add VLAN 10 to port sw1p1 for both the bridge (master) and the device
(self).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |  151 +++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 140 insertions(+), 11 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 3d4d99a..b01791a 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -15,6 +15,7 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/if_bridge.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
@@ -357,28 +358,156 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
+static int switchdev_port_br_setflag(struct net_device *dev,
+				     struct nlattr *nlattr,
+				     unsigned long brport_flag)
+{
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
+	};
+	u8 flag = nla_get_u8(nlattr);
+	int err;
+
+	err = switchdev_port_attr_get(dev, &attr);
+	if (err)
+		return err;
+
+	if (flag)
+		attr.brport_flags |= brport_flag;
+	else
+		attr.brport_flags &= ~brport_flag;
+
+	return switchdev_port_attr_set(dev, &attr);
+}
+
+static const struct nla_policy
+switchdev_port_bridge_policy[IFLA_BRPORT_MAX + 1] = {
+	[IFLA_BRPORT_STATE]		= { .type = NLA_U8 },
+	[IFLA_BRPORT_COST]		= { .type = NLA_U32 },
+	[IFLA_BRPORT_PRIORITY]		= { .type = NLA_U16 },
+	[IFLA_BRPORT_MODE]		= { .type = NLA_U8 },
+	[IFLA_BRPORT_GUARD]		= { .type = NLA_U8 },
+	[IFLA_BRPORT_PROTECT]		= { .type = NLA_U8 },
+	[IFLA_BRPORT_FAST_LEAVE]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_LEARNING]		= { .type = NLA_U8 },
+	[IFLA_BRPORT_LEARNING_SYNC]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_UNICAST_FLOOD]	= { .type = NLA_U8 },
+};
+
+static int switchdev_port_br_setlink_protinfo(struct net_device *dev,
+					      struct nlattr *protinfo)
+{
+	struct nlattr *attr;
+	int rem;
+	int err;
+
+	err = nla_validate_nested(protinfo, IFLA_BRPORT_MAX,
+				  switchdev_port_bridge_policy);
+	if (err)
+		return err;
+
+	nla_for_each_nested(attr, protinfo, rem) {
+		switch (nla_type(attr)) {
+		case IFLA_BRPORT_LEARNING:
+			err = switchdev_port_br_setflag(dev, attr,
+							BR_LEARNING);
+			break;
+		case IFLA_BRPORT_LEARNING_SYNC:
+			err = switchdev_port_br_setflag(dev, attr,
+							BR_LEARNING_SYNC);
+			break;
+		default:
+			err = -EOPNOTSUPP;
+			break;
+		}
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int switchdev_port_br_afspec(struct net_device *dev,
+				    struct nlattr *afspec,
+				    int (*f)(struct net_device *dev,
+					     struct switchdev_obj *obj))
+{
+	struct nlattr *attr;
+	struct bridge_vlan_info *vinfo;
+	struct switchdev_obj obj = {
+		.id = SWITCHDEV_OBJ_PORT_VLAN,
+	};
+	int rem;
+	int err;
+
+	nla_for_each_nested(attr, afspec, rem) {
+		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
+			continue;
+		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
+			return -EINVAL;
+		vinfo = nla_data(attr);
+		obj.vlan.flags = vinfo->flags;
+		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
+			if (obj.vlan.vid_start)
+				return -EINVAL;
+			obj.vlan.vid_start = vinfo->vid;
+		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
+			if (!obj.vlan.vid_start)
+				return -EINVAL;
+			obj.vlan.vid_end = vinfo->vid;
+			if (obj.vlan.vid_end <= obj.vlan.vid_start)
+				return -EINVAL;
+			err = f(dev, &obj);
+			if (err)
+				return err;
+			memset(&obj.vlan, 0, sizeof(obj.vlan));
+		} else {
+			if (obj.vlan.vid_start)
+				return -EINVAL;
+			obj.vlan.vid_start = vinfo->vid;
+			obj.vlan.vid_end = vinfo->vid;
+			err = f(dev, &obj);
+			if (err)
+				return err;
+			memset(&obj.vlan, 0, sizeof(obj.vlan));
+		}
+	}
+
+	return 0;
+}
+
 /**
- *	switchdev_port_bridge_setlink - Notify switch device port of bridge
- *	port attributes
+ *	switchdev_port_bridge_setlink - Set bridge port attributes
  *
  *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge setlink flags
+ *	@nlh: netlink header
+ *	@flags: netlink flags
  *
- *	Notify switch device port of bridge port attributes
+ *	Called for SELF on rtnl_bridge_setlink to set bridge port
+ *	attributes.
  */
 int switchdev_port_bridge_setlink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
+	struct nlattr *protinfo;
+	struct nlattr *afspec;
+	int err = 0;
 
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return 0;
+	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				   IFLA_PROTINFO);
+	if (protinfo) {
+		err = switchdev_port_br_setlink_protinfo(dev, protinfo);
+		if (err)
+			return err;
+	}
 
-	if (!ops->ndo_bridge_setlink)
-		return -EOPNOTSUPP;
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				 IFLA_AF_SPEC);
+	if (afspec)
+		err = switchdev_port_br_afspec(dev, afspec,
+					       switchdev_port_obj_add);
 
-	return ops->ndo_bridge_setlink(dev, nlh, flags);
+	return err;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_setlink);
 
-- 
1.7.10.4
