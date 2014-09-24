From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 06/24] net: rbridge: Enable/disable TRILL capability
Date: Wed, 24 Sep 2014 17:52:02 +0200
Message-ID: <1411573940-14079-7-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:39921 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792AbaIXP6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:09 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enable switching TRILL capability state via sysfs command

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
---
 net/bridge/Makefile      |  2 ++
 net/bridge/br_private.h  |  5 ++++
 net/bridge/br_sysfs_br.c | 38 +++++++++++++++++++++++
 net/bridge/rbridge/rbr.c | 78 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 123 insertions(+)
 create mode 100644 net/bridge/rbridge/rbr.c

diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 8590b94..314783c 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -17,3 +17,5 @@ bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
 
 obj-$(CONFIG_NETFILTER) += netfilter/
+
+bridge-$(CONFIG_TRILL) += rbridge/rbr.o
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 430c556..844c87b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -811,6 +811,11 @@ int br_stp_set_port_priority(struct net_bridge_port *p, unsigned long newprio);
 int br_stp_set_path_cost(struct net_bridge_port *p, unsigned long path_cost);
 ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
 
+/* rbridge/rbr.c */
+#ifdef CONFIG_TRILL
+void br_trill_set_enabled(struct net_bridge *br, unsigned long val);
+#endif
+
 /* br_stp_bpdu.c */
 struct stp_proto;
 void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c9e2572..787ab84 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -146,6 +146,41 @@ static ssize_t stp_state_store(struct device *d,
 }
 static DEVICE_ATTR_RW(stp_state);
 
+#ifdef CONFIG_TRILL
+static ssize_t trill_state_show(struct device *d,
+				struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->trill_enabled);
+}
+
+static ssize_t trill_state_store(struct device *d,
+				 struct device_attribute *attr, const char *buf,
+				 size_t len)
+{
+	struct net_bridge *br = to_bridge(d);
+	char *endp;
+	unsigned long val;
+
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
+		return -EPERM;
+
+	val = simple_strtoul(buf, &endp, 0);
+	if (endp == buf)
+		return -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+	br_trill_set_enabled(br, val);
+	rtnl_unlock();
+
+	return len;
+}
+
+static DEVICE_ATTR_RW(trill_state);
+#endif
+
+
 static ssize_t group_fwd_mask_show(struct device *d,
 				   struct device_attribute *attr,
 				   char *buf)
@@ -733,6 +768,9 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_max_age.attr,
 	&dev_attr_ageing_time.attr,
 	&dev_attr_stp_state.attr,
+#ifdef CONFIG_TRILL
+	&dev_attr_trill_state.attr,
+#endif
 	&dev_attr_group_fwd_mask.attr,
 	&dev_attr_priority.attr,
 	&dev_attr_bridge_id.attr,
diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
new file mode 100644
index 0000000..41d47db
--- /dev/null
+++ b/net/bridge/rbridge/rbr.c
@@ -0,0 +1,78 @@
+/*
+ *	Generic parts
+ *	Linux ethernet Rbridge
+ *
+ *	Authors:
+ *	Ahmed AMAMOU	<ahmed@gandi.net>
+ *	Kamel Haddadou	<kamel@gandi.net>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+#include "br_private.h"
+#include "rbr_private.h"
+
+static struct rbr *add_rbr(struct net_bridge *br)
+{
+	struct rbr *rbr;
+
+	if (!br->rbr) {
+		rbr = kzalloc(sizeof(*rbr), GFP_KERNEL);
+		if (!rbr)
+			return NULL;
+
+		rbr->br = br;
+		rbr->nick = RBRIDGE_NICKNAME_NONE;
+		rbr->treeroot = RBRIDGE_NICKNAME_NONE;
+		return rbr;
+	}
+
+	return br->rbr;
+}
+
+static void br_trill_start(struct net_bridge *br)
+{
+	/* Disable STP if it is already enabled */
+
+	if (br->stp_enabled != BR_NO_STP)
+		br_stp_set_enabled(br, false);
+	br->rbr = add_rbr(br);
+	if (br->rbr) {
+		spin_lock_bh(&br->lock);
+		br->trill_enabled = BR_TRILL;
+		spin_unlock_bh(&br->lock);
+	} else {
+		printk(KERN_WARNING
+		       "RBridge allocation for bridge '%s' failed\n",
+		       br->dev->name);
+	}
+}
+
+static void br_trill_stop(struct net_bridge *br)
+{
+	struct rbr *old;
+
+	spin_lock_bh(&br->lock);
+	br->trill_enabled = BR_NO_TRILL;
+	spin_unlock_bh(&br->lock);
+	old = br->rbr;
+	br->rbr = NULL;
+	if (likely(old)) {
+		spin_lock_bh(&br->lock);
+		kfree(old);
+		spin_unlock_bh(&br->lock);
+	}
+}
+
+void br_trill_set_enabled(struct net_bridge *br, unsigned long val)
+{
+	if (val) {
+		if (br->trill_enabled == BR_NO_TRILL)
+			br_trill_start(br);
+	} else {
+		if (br->trill_enabled != BR_NO_TRILL)
+			br_trill_stop(br);
+	}
+}
-- 
1.9.1
