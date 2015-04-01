From: sfeldma@gmail.com
Subject: [PATCH net-next v2 14/26] switchdev: add new swdev_port_bridge_dellink
Date: Wed,  1 Apr 2015 03:07:50 -0700
Message-ID: <1427882882-2533-15-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34521 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbbDAKGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:44 -0400
Received: by pactp5 with SMTP id tp5so47804845pac.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:43 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Same change as setlink.  Provide the wrapper op for SELF ndo_bridge_dellink
and call into the swdev driver to delete afspec VLANs.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    8 ++++++++
 net/switchdev/switchdev.c |   24 ++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8e62528..60b83b0 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -115,6 +115,8 @@ int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj);
 int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj);
 int swdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 			      u16 flags);
+int swdev_port_bridge_dellink(struct net_device *dev, struct nlmsghdr *nlh,
+			      u16 flags);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -161,6 +163,12 @@ static inline int swdev_port_bridge_setlink(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int swdev_port_bridge_dellink(struct net_device *dev,
+					    struct nlmsghdr *nlh, u16 flags)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_netdev_switch_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8786f91..a720a3c 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -408,6 +408,30 @@ int swdev_port_bridge_setlink(struct net_device *dev,
 EXPORT_SYMBOL_GPL(swdev_port_bridge_setlink);
 
 /**
+ *	swdev_port_bridge_dellink - Set bridge port attributes
+ *
+ *	@dev: port device
+ *	@nlh: netlink header
+ *	@flags: netlink flags
+ *
+ *	Called for SELF on rtnl_bridge_dellink to set bridge port
+ *	attributes.
+ */
+int swdev_port_bridge_dellink(struct net_device *dev,
+			      struct nlmsghdr *nlh, u16 flags)
+{
+	struct nlattr *afspec;
+
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				 IFLA_AF_SPEC);
+	if (afspec)
+		return swdev_port_br_afspec(dev, afspec, swdev_port_obj_del);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(swdev_port_bridge_dellink);
+
+/**
  *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
  *	port attribute delete
  *
-- 
1.7.10.4
