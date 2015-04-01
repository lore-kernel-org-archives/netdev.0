From: sfeldma@gmail.com
Subject: [PATCH net-next v2 09/26] switchdev: add new swdev bridge setlink
Date: Wed,  1 Apr 2015 03:07:45 -0700
Message-ID: <1427882882-2533-10-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32786 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbbDAKGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:38 -0400
Received: by pacgg7 with SMTP id gg7so47926197pac.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:38 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add new swdev_port_bridge_setlink that can be used by drivers implementing
.ndo_bridge_setlink to set swdev bridge attributes.  Basically turn the raw
rtnl_bridge_setlink netlink into swdev attr sets.  Proper netlink attr policy
checking is done on the protinfo part of the netlink msg.

Currently, for protinfo, only bridge port attrs BR_LEARNING and
BR_LEARNING_SYNC are parsed and passed to port driver.

For afspec, VLAN objs are passed so swdev driver can set VLANs assigned to
SELF.  To illustrate with iproute2 cmd, we have:

	bridge vlan add vid 10 dev sw1p1 self master

To add VLAN 10 to port sw1p1 for both the bridge (master) and the device
(self).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    8 +++
 net/switchdev/switchdev.c |  150 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 158 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index f1fa5fc..96489d7 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -113,6 +113,8 @@ int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj);
 int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj);
+int swdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
+			      u16 flags);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -157,6 +159,12 @@ static inline int swdev_port_obj_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int swdev_port_bridge_setlink(struct net_device *dev,
+					    struct nlmsghdr *nlh, u16 flags)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_netdev_switch_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 6a527f5..5426a36 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -15,6 +15,7 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/if_bridge.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
@@ -282,6 +283,155 @@ int netdev_switch_port_bridge_setlink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
 
+static int swdev_port_br_setflag(struct net_device *dev, struct nlattr *nlattr,
+				 unsigned long brport_flag)
+{
+	struct swdev_attr attr = {
+		.id = SWDEV_ATTR_PORT_BRIDGE_FLAGS,
+	};
+	u8 flag = nla_get_u8(nlattr);
+	int err;
+
+	err = swdev_port_attr_get(dev, &attr);
+	if (err)
+		return err;
+
+	if (flag)
+		attr.brport_flags |= brport_flag;
+	else
+		attr.brport_flags &= ~brport_flag;
+
+	return swdev_port_attr_set(dev, &attr);
+}
+
+static const struct nla_policy swdev_port_bridge_policy[IFLA_BRPORT_MAX + 1] = {
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
+static int swdev_port_br_protinfo(struct net_device *dev,
+				  struct nlattr *protinfo)
+{
+	struct nlattr *attr;
+	int rem;
+	int err;
+
+	err = nla_validate_nested(protinfo, IFLA_BRPORT_MAX,
+				  swdev_port_bridge_policy);
+	if (err)
+		return err;
+
+	nla_for_each_nested(attr, protinfo, rem) {
+		switch (nla_type(attr)) {
+		case IFLA_BRPORT_LEARNING:
+			err = swdev_port_br_setflag(dev, attr,
+						    BR_LEARNING);
+			break;
+		case IFLA_BRPORT_LEARNING_SYNC:
+			err = swdev_port_br_setflag(dev, attr,
+						    BR_LEARNING_SYNC);
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
+static int swdev_port_br_afspec(struct net_device *dev, struct nlattr *afspec,
+				int (*f)(struct net_device *dev,
+					 struct swdev_obj *obj))
+{
+	struct nlattr *attr;
+	struct bridge_vlan_info *vinfo;
+	struct swdev_obj obj = {
+		.id = SWDEV_OBJ_PORT_VLAN,
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
+/**
+ *	swdev_port_bridge_setlink - Set bridge port attributes
+ *
+ *	@dev: port device
+ *	@nlh: netlink header
+ *	@flags: netlink flags
+ *
+ *	Called for SELF on rtnl_bridge_setlink to set bridge port
+ *	attributes.
+ */
+int swdev_port_bridge_setlink(struct net_device *dev,
+			      struct nlmsghdr *nlh, u16 flags)
+{
+	struct nlattr *protinfo;
+	struct nlattr *afspec;
+	int err = 0;
+
+	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				   IFLA_PROTINFO);
+	if (protinfo) {
+		err = swdev_port_br_protinfo(dev, protinfo);
+		if (err)
+			return err;
+	}
+
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				 IFLA_AF_SPEC);
+	if (afspec)
+		err = swdev_port_br_afspec(dev, afspec, swdev_port_obj_add);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(swdev_port_bridge_setlink);
+
 /**
  *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
  *	port attribute delete
-- 
1.7.10.4
