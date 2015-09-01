From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 08/21] net: rbridge: get Rbridge nickname from daemon
Date: Tue,  1 Sep 2015 17:43:03 +0200
Message-ID: <1441122196-11662-9-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:50752 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752885AbbIAPxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:42 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
---
 include/uapi/linux/if_link.h |  6 ++++++
 net/bridge/Makefile          |  2 +-
 net/bridge/br_netlink.c      | 10 +++++++++-
 net/bridge/br_private.h      |  6 ++++++
 net/bridge/rbr_rtnetlink.c   | 44 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 66 insertions(+), 2 deletions(-)
 create mode 100644 net/bridge/rbr_rtnetlink.c

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 2c7e8e3..07a3f01 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -229,6 +229,12 @@ enum {
 	IFLA_BR_AGEING_TIME,
 	IFLA_BR_STP_STATE,
 	IFLA_BR_PRIORITY,
+#ifdef CONFIG_TRILL
+/* TRILL section */
+	IFLA_TRILL_NICKNAME,
+	IFLA_TRILL_ROOT,
+	IFLA_TRILL_INFO,
+#endif
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 27da487..472dc24 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -22,4 +22,4 @@ bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
 
 obj-$(CONFIG_NETFILTER) += netfilter/
 
-bridge-$(CONFIG_TRILL) += rbr.o
+bridge-$(CONFIG_TRILL) += rbr.o rbr_rtnetlink.o
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 4d74a06..def0ea3 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -730,6 +730,11 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_AGEING_TIME] = { .type = NLA_U32 },
 	[IFLA_BR_STP_STATE] = { .type = NLA_U32 },
 	[IFLA_BR_PRIORITY] = { .type = NLA_U16 },
+#ifdef CONFIG_TRILL
+	[IFLA_TRILL_NICKNAME]   = { .type = NLA_U16 },
+	[IFLA_TRILL_ROOT]       = { .type = NLA_U16 },
+	[IFLA_TRILL_INFO]       = { .type = NLA_BINARY },
+#endif
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -776,8 +781,11 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 
 		br_stp_set_bridge_priority(br, priority);
 	}
+#ifdef CONFIG_TRILL
+	err = rbr_set_data(brdev, tb, data);
+#endif
 
-	return 0;
+	return err;
 }
 
 static size_t br_get_size(const struct net_device *brdev)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 67da2ae..ceaf5a9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -864,6 +864,12 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlmsg, u16 flags);
 int br_getlink(struct sk_buff *skb, u32 pid, u32 seq, struct net_device *dev,
 	       u32 filter_mask, int nlflags);
 
+#ifdef CONFIG_TRILL
+/* rbr_netlink.c */
+int rbr_set_data(struct net_device *dev, struct nlattr *tb[],
+		 struct nlattr *data[]);
+#endif
+
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
 extern const struct sysfs_ops brport_sysfs_ops;
diff --git a/net/bridge/rbr_rtnetlink.c b/net/bridge/rbr_rtnetlink.c
new file mode 100644
index 0000000..d75d45c
--- /dev/null
+++ b/net/bridge/rbr_rtnetlink.c
@@ -0,0 +1,44 @@
+/*
+ *	Generic parts
+ *	Linux ethernet Rbridge
+ *
+ *	Authors:
+ *	Ahmed AMAMOU	<ahmed@gandi.net>
+ *	William Dauchy	<william@gandi.net>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <net/rtnetlink.h>
+#include "br_private.h"
+#include "rbr_private.h"
+
+int rbr_set_data(struct net_device *dev, struct nlattr *tb[],
+		 struct nlattr *data[])
+{
+	struct net_bridge *br = netdev_priv(dev);
+	u16 nick;
+	int err = -ENOMEM;
+
+	if (!br)
+		return -EINVAL;
+
+	if (data[IFLA_TRILL_NICKNAME]) {
+		nick =  nla_get_u16(data[IFLA_TRILL_NICKNAME]);
+		if (br->trill_enabled == BR_NO_TRILL)
+			br_trill_set_enabled(br, 1);
+
+		spin_lock_bh(&br->lock);
+		if (VALID_NICK(nick))
+			br->rbr->nick = htons(nick);
+		spin_unlock_bh(&br->lock);
+	}
+
+	return 0;
+fail:
+	pr_warn("rbr_set_data FAILED\n");
+	return err;
+}
-- 
2.1.4
