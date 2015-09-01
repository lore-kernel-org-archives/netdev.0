From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 06/21] net: rbridge: enable/disable TRILL capability
Date: Tue,  1 Sep 2015 17:43:01 +0200
Message-ID: <1441122196-11662-7-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56783 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752713AbbIAPxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:41 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enable switching TRILL capability state via sysfs command

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
---
 net/bridge/Makefile     |  2 ++
 net/bridge/br_private.h |  5 ++++
 net/bridge/rbr.c        | 71 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 78 insertions(+)
 create mode 100644 net/bridge/rbr.c

diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index a1cda5d..27da487 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -21,3 +21,5 @@ bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
 
 obj-$(CONFIG_NETFILTER) += netfilter/
+
+bridge-$(CONFIG_TRILL) += rbr.o
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index ff757da..67da2ae 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -834,6 +834,11 @@ int br_stp_set_port_priority(struct net_bridge_port *p, unsigned long newprio);
 int br_stp_set_path_cost(struct net_bridge_port *p, unsigned long path_cost);
 ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
 
+/* rbr.c */
+#ifdef CONFIG_TRILL
+void br_trill_set_enabled(struct net_bridge *br, unsigned long val);
+#endif
+
 /* br_stp_bpdu.c */
 struct stp_proto;
 void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
new file mode 100644
index 0000000..c554743
--- /dev/null
+++ b/net/bridge/rbr.c
@@ -0,0 +1,71 @@
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
+	if (br->rbr)
+		br->trill_enabled = BR_TRILL;
+	else
+		pr_warn("RBridge allocation for bridge '%s' failed\n",
+			br->dev->name);
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
+	if (likely(old))
+		kfree(old);
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
2.1.4
