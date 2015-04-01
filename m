From: sfeldma@gmail.com
Subject: [PATCH net-next v2 19/26] switchdev: add new swdev_port_bridge_getlink
Date: Wed,  1 Apr 2015 03:07:55 -0700
Message-ID: <1427882882-2533-20-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36198 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133AbbDAKGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:49 -0400
Received: by pdmh5 with SMTP id h5so37931731pdm.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:48 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Like bridge_setlink, add swdev wrapper to handle bridge_getlink and call into
port driver to get port attrs.  For now, only BR_LEARNING and BR_LEARNING_SYNC
are returned.  To add more, we'll probably want to break away from
ndo_dflt_bridge_getlink() and build the netlink skb directly in the swdev code.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    9 +++++++++
 net/switchdev/switchdev.c |   27 +++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 9147a35..d46809b 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -113,6 +113,8 @@ int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj);
 int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj);
+int swdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+			      struct net_device *dev, u32 filter_mask);
 int swdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 			      u16 flags);
 int swdev_port_bridge_dellink(struct net_device *dev, struct nlmsghdr *nlh,
@@ -153,6 +155,13 @@ static inline int swdev_port_obj_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int swdev_port_bridge_getlink(struct sk_buff *skb, u32 pid,
+					    u32 seq, struct net_device *dev,
+					    u32 filter_mask)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int swdev_port_bridge_setlink(struct net_device *dev,
 					    struct nlmsghdr *nlh, u16 flags)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 96cdee0..bcf7ccb 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -258,6 +258,33 @@ int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(call_netdev_switch_notifiers);
 
+/**
+ *	swdev_port_bridge_getlink - Get bridge port attributes
+ *
+ *	@dev: port device
+ *
+ *	Called for SELF on rtnl_bridge_getlink to get bridge port
+ *	attributes.
+ */
+int swdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+			      struct net_device *dev, u32 filter_mask)
+{
+	struct swdev_attr attr = {
+		.id = SWDEV_ATTR_PORT_BRIDGE_FLAGS,
+	};
+	u16 mode = BRIDGE_MODE_UNDEF;
+	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
+	int err;
+
+	err = swdev_port_attr_get(dev, &attr);
+	if (err)
+		return err;
+
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
+				       attr.brport_flags, mask);
+}
+EXPORT_SYMBOL_GPL(swdev_port_bridge_getlink);
+
 static int swdev_port_br_setflag(struct net_device *dev, struct nlattr *nlattr,
 				 unsigned long brport_flag)
 {
-- 
1.7.10.4
