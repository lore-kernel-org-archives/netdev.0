From: sfeldma@gmail.com
Subject: [PATCH net-next v6 18/23] switchdev: add new switchdev_port_bridge_getlink
Date: Sat,  9 May 2015 10:40:20 -0700
Message-ID: <1431193225-807-19-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35598 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbEIRng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:36 -0400
Received: by pdbqd1 with SMTP id qd1so113064728pdb.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:36 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Like bridge_setlink, add switchdev wrapper to handle bridge_getlink and
call into port driver to get port attrs.  For now, only BR_LEARNING and
BR_LEARNING_SYNC are returned.  To add more, we'll probably want to break
away from ndo_dflt_bridge_getlink() and build the netlink skb directly in
the switchdev code.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/switchdev.h   |   10 ++++++++++
 net/switchdev/switchdev.c |   28 ++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 397b1e6..e081d67 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -126,6 +126,9 @@ int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 			     struct switchdev_notifier_info *info);
+int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				  struct net_device *dev, u32 filter_mask,
+				  int nlflags);
 int switchdev_port_bridge_setlink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
 int switchdev_port_bridge_dellink(struct net_device *dev,
@@ -179,6 +182,13 @@ static inline int call_switchdev_notifiers(unsigned long val,
 	return NOTIFY_DONE;
 }
 
+static inline int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid,
+					    u32 seq, struct net_device *dev,
+					    u32 filter_mask, int nlflags)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int switchdev_port_bridge_setlink(struct net_device *dev,
 						struct nlmsghdr *nlh,
 						u16 flags)
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 0e15b6f..9210355 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -358,6 +358,34 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
+/**
+ *	switchdev_port_bridge_getlink - Get bridge port attributes
+ *
+ *	@dev: port device
+ *
+ *	Called for SELF on rtnl_bridge_getlink to get bridge port
+ *	attributes.
+ */
+int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				  struct net_device *dev, u32 filter_mask,
+				  int nlflags)
+{
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
+	};
+	u16 mode = BRIDGE_MODE_UNDEF;
+	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
+	int err;
+
+	err = switchdev_port_attr_get(dev, &attr);
+	if (err)
+		return err;
+
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
+				       attr.brport_flags, mask, nlflags);
+}
+EXPORT_SYMBOL_GPL(switchdev_port_bridge_getlink);
+
 static int switchdev_port_br_setflag(struct net_device *dev,
 				     struct nlattr *nlattr,
 				     unsigned long brport_flag)
-- 
1.7.10.4
