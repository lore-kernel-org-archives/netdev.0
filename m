From: sfeldma@gmail.com
Subject: [PATCH net-next 07/18] switchdev: add new swdev bridge setlink
Date: Mon, 30 Mar 2015 01:40:25 -0700
Message-ID: <1427704836-8776-8-git-send-email-sfeldma@gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34436 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbbC3Ijw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:39:52 -0400
Received: by pdbni2 with SMTP id ni2so168964152pdb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:39:52 -0700 (PDT)
In-Reply-To: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add new swdev_port_bridge_setlink that can be used by drivers implementing
.ndo_bridge_setlink to set swdev bridge attributes.  Basically turn the raw
rtnl_bridge_setlink netlink into swdev attr sets.  Proper netlink attr policy
checking is done.  Currently, only bridge port attrs BR_LEARNING and
BR_LEARNING_SYNC are parsed and passed to port driver.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    8 +++++
 net/switchdev/switchdev.c |   86 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 94 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 2ac5240..bf66bcd 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -86,6 +86,8 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
+int swdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
+			      u16 flags);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -118,6 +120,12 @@ static inline int swdev_port_attr_set(struct net_device *dev,
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
index 162b011..f3f457e 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -15,6 +15,7 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/if_bridge.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
@@ -197,6 +198,91 @@ int netdev_switch_port_bridge_setlink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
 
+static int swdev_port_bridge_setflag(struct net_device *dev,
+				     struct nlattr *ifla,
+				     unsigned long brport_flag)
+{
+	struct swdev_attr attr = {
+		.attr = SWDEV_ATTR_PORT_BRIDGE_FLAGS,
+	};
+	u8 flag = nla_get_u8(ifla);
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
+	struct nlattr *ifla;
+	int rem;
+	int err;
+
+	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				   IFLA_PROTINFO);
+	if (!protinfo)
+		return 0;
+
+	err = nla_validate_nested(protinfo, IFLA_BRPORT_MAX,
+				  swdev_port_bridge_policy);
+	if (err)
+		return err;
+
+	nla_for_each_nested(ifla, protinfo, rem) {
+		switch (nla_type(ifla)) {
+		case IFLA_BRPORT_LEARNING:
+			err = swdev_port_bridge_setflag(dev, ifla,
+							BR_LEARNING);
+			break;
+		case IFLA_BRPORT_LEARNING_SYNC:
+			err = swdev_port_bridge_setflag(dev, ifla,
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
+EXPORT_SYMBOL_GPL(swdev_port_bridge_setlink);
+
 /**
  *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
  *	port attribute delete
-- 
1.7.10.4
