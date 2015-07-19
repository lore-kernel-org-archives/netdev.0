From: sfeldma@gmail.com
Subject: [PATCH net-next v3 3/5] switchdev: add offload_fwd_mark generator helper
Date: Sat, 18 Jul 2015 18:24:50 -0700
Message-ID: <1437269092-17669-4-git-send-email-sfeldma@gmail.com>
References: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com, nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36817 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbbGSBWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 21:22:39 -0400
Received: by pdjr16 with SMTP id r16so83495362pdj.3
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 18:22:38 -0700 (PDT)
In-Reply-To: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

skb->offload_fwd_mark and dev->offload_fwd_mark are 32-bit and should be
unique for device and may even be unique for a sub-set of ports within
device, so add switchdev helper function to generate unique marks based on
port's switch ID and group_ifindex.  group_ifindex would typically be the
container dev's ifindex, such as the bridge's ifindex.

The generator uses a global hash table to store offload_fwd_marks hashed by
{switch ID, group_ifindex} key.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/switchdev.h   |    9 ++++
 net/switchdev/switchdev.c |  103 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 112 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d5671f1..89da893 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -157,6 +157,9 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
 			    struct net_device *filter_dev, int idx);
+void switchdev_port_fwd_mark_set(struct net_device *dev,
+				 struct net_device *group_dev,
+				 bool joining);
 
 #else
 
@@ -271,6 +274,12 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
 	return -EOPNOTSUPP;
 }
 
+static inline void switchdev_port_fwd_mark_set(struct net_device *dev,
+					       struct net_device *group_dev,
+					       bool joining)
+{
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 4e5bba5..33bafa2 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1039,3 +1039,106 @@ void switchdev_fib_ipv4_abort(struct fib_info *fi)
 	fi->fib_net->ipv4.fib_offload_disabled = true;
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
+
+static bool switchdev_port_same_parent_id(struct net_device *a,
+					  struct net_device *b)
+{
+	struct switchdev_attr a_attr = {
+		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+		.flags = SWITCHDEV_F_NO_RECURSE,
+	};
+	struct switchdev_attr b_attr = {
+		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+		.flags = SWITCHDEV_F_NO_RECURSE,
+	};
+
+	if (switchdev_port_attr_get(a, &a_attr) ||
+	    switchdev_port_attr_get(b, &b_attr))
+		return false;
+
+	return netdev_phys_item_id_same(&a_attr.u.ppid, &b_attr.u.ppid);
+}
+
+static u32 switchdev_port_fwd_mark_get(struct net_device *dev,
+				       struct net_device *group_dev)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	netdev_for_each_lower_dev(group_dev, lower_dev, iter) {
+		if (lower_dev == dev)
+			continue;
+		if (switchdev_port_same_parent_id(dev, lower_dev))
+			return lower_dev->offload_fwd_mark;
+		return switchdev_port_fwd_mark_get(dev, lower_dev);
+	}
+
+	return dev->ifindex;
+}
+
+static void switchdev_port_fwd_mark_reset(struct net_device *group_dev,
+					  u32 old_mark, u32 *reset_mark)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	netdev_for_each_lower_dev(group_dev, lower_dev, iter) {
+		if (lower_dev->offload_fwd_mark == old_mark) {
+			if (!*reset_mark)
+				*reset_mark = lower_dev->ifindex;
+			lower_dev->offload_fwd_mark = *reset_mark;
+		}
+		switchdev_port_fwd_mark_reset(lower_dev, old_mark, reset_mark);
+	}
+}
+
+/**
+ *	switchdev_port_fwd_mark_set - Set port offload forwarding mark
+ *
+ *	@dev: port device
+ *	@group_dev: containing device
+ *	@joining: true if dev is joining group; false if leaving group
+ *
+ *	An ungrouped port's offload mark is just its ifindex.  A grouped
+ *	port's (member of a bridge, for example) offload mark is the ifindex
+ *	of one of the ports in the group with the same parent (switch) ID.
+ *	Ports on the same device in the same group will have the same mark.
+ *
+ *	Example:
+ *
+ *		br0		ifindex=9
+ *		  sw1p1		ifindex=2	mark=2
+ *		  sw1p2		ifindex=3	mark=2
+ *		  sw2p1		ifindex=4	mark=5
+ *		  sw2p2		ifindex=5	mark=5
+ *
+ *	If sw2p2 leaves the bridge, we'll have:
+ *
+ *		br0		ifindex=9
+ *		  sw1p1		ifindex=2	mark=2
+ *		  sw1p2		ifindex=3	mark=2
+ *		  sw2p1		ifindex=4	mark=4
+ *		sw2p2		ifindex=5	mark=5
+ */
+void switchdev_port_fwd_mark_set(struct net_device *dev,
+				 struct net_device *group_dev,
+				 bool joining)
+{
+	u32 mark = dev->ifindex;
+	u32 reset_mark = 0;
+
+	if (group_dev && joining) {
+		mark = switchdev_port_fwd_mark_get(dev, group_dev);
+	} else if (group_dev && !joining) {
+		if (dev->offload_fwd_mark == mark)
+			/* Ohoh, this port was the mark reference port,
+			 * but it's leaving the group, so reset the
+			 * mark for the remaining ports in the group.
+			 */
+			switchdev_port_fwd_mark_reset(group_dev, mark,
+						      &reset_mark);
+	}
+
+	dev->offload_fwd_mark = mark;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_fwd_mark_set);
-- 
1.7.10.4
