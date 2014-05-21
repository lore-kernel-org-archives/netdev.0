From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] bridge: make br_device_notifier static
Date: Tue, 20 May 2014 17:30:00 -0700
Message-ID: <1400632200-23619-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:49820 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaEUAaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 20:30:08 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so814910pbc.16
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 17:30:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

Merge net/bridge/br_notify.c into net/bridge/br.c,
since it has only br_device_event() and br.c is small.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/bridge/Makefile     |   2 +-
 net/bridge/br.c         |  98 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_notify.c  | 118 ------------------------------------------------
 net/bridge/br_private.h |   2 -
 4 files changed, 99 insertions(+), 121 deletions(-)
 delete mode 100644 net/bridge/br_notify.c

diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index e85498b2f..8c0ee70 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -5,7 +5,7 @@
 obj-$(CONFIG_BRIDGE) += bridge.o
 
 bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
-			br_ioctl.o br_notify.o br_stp.o br_stp_bpdu.o \
+			br_ioctl.o br_stp.o br_stp_bpdu.o \
 			br_stp_if.o br_stp_timer.o br_netlink.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 19311aa..1a755a1 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -22,6 +22,104 @@
 
 #include "br_private.h"
 
+/*
+ * Handle changes in state of network devices enslaved to a bridge.
+ *
+ * Note: don't care about up/down if bridge itself is down, because
+ *     port state is checked when bridge is brought up.
+ */
+static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct net_bridge_port *p;
+	struct net_bridge *br;
+	bool changed_addr;
+	int err;
+
+	/* register of bridge completed, add sysfs entries */
+	if ((dev->priv_flags & IFF_EBRIDGE) && event == NETDEV_REGISTER) {
+		br_sysfs_addbr(dev);
+		return NOTIFY_DONE;
+	}
+
+	/* not a port of a bridge */
+	p = br_port_get_rtnl(dev);
+	if (!p)
+		return NOTIFY_DONE;
+
+	br = p->br;
+
+	switch (event) {
+	case NETDEV_CHANGEMTU:
+		dev_set_mtu(br->dev, br_min_mtu(br));
+		break;
+
+	case NETDEV_CHANGEADDR:
+		spin_lock_bh(&br->lock);
+		br_fdb_changeaddr(p, dev->dev_addr);
+		changed_addr = br_stp_recalculate_bridge_id(br);
+		spin_unlock_bh(&br->lock);
+
+		if (changed_addr)
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
+
+		break;
+
+	case NETDEV_CHANGE:
+		br_port_carrier_check(p);
+		break;
+
+	case NETDEV_FEAT_CHANGE:
+		netdev_update_features(br->dev);
+		break;
+
+	case NETDEV_DOWN:
+		spin_lock_bh(&br->lock);
+		if (br->dev->flags & IFF_UP)
+			br_stp_disable_port(p);
+		spin_unlock_bh(&br->lock);
+		break;
+
+	case NETDEV_UP:
+		if (netif_running(br->dev) && netif_oper_up(dev)) {
+			spin_lock_bh(&br->lock);
+			br_stp_enable_port(p);
+			spin_unlock_bh(&br->lock);
+		}
+		break;
+
+	case NETDEV_UNREGISTER:
+		br_del_if(br, dev);
+		break;
+
+	case NETDEV_CHANGENAME:
+		err = br_sysfs_renameif(p);
+		if (err)
+			return notifier_from_errno(err);
+		break;
+
+	case NETDEV_PRE_TYPE_CHANGE:
+		/* Forbid underlaying device to change its type. */
+		return NOTIFY_BAD;
+
+	case NETDEV_RESEND_IGMP:
+		/* Propagate to master device */
+		call_netdevice_notifiers(event, br->dev);
+		break;
+	}
+
+	/* Events that may cause spanning tree to refresh */
+	if (event == NETDEV_CHANGEADDR || event == NETDEV_UP ||
+	    event == NETDEV_CHANGE || event == NETDEV_DOWN)
+		br_ifinfo_notify(RTM_NEWLINK, p);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block br_device_notifier = {
+	.notifier_call = br_device_event
+};
+
 static void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
deleted file mode 100644
index 2998dd1..0000000
--- a/net/bridge/br_notify.c
+++ /dev/null
@@ -1,118 +0,0 @@
-/*
- *	Device event handling
- *	Linux ethernet bridge
- *
- *	Authors:
- *	Lennert Buytenhek		<buytenh@gnu.org>
- *
- *	This program is free software; you can redistribute it and/or
- *	modify it under the terms of the GNU General Public License
- *	as published by the Free Software Foundation; either version
- *	2 of the License, or (at your option) any later version.
- */
-
-#include <linux/kernel.h>
-#include <linux/rtnetlink.h>
-#include <net/net_namespace.h>
-
-#include "br_private.h"
-
-static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr);
-
-struct notifier_block br_device_notifier = {
-	.notifier_call = br_device_event
-};
-
-/*
- * Handle changes in state of network devices enslaved to a bridge.
- *
- * Note: don't care about up/down if bridge itself is down, because
- *     port state is checked when bridge is brought up.
- */
-static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct net_bridge_port *p;
-	struct net_bridge *br;
-	bool changed_addr;
-	int err;
-
-	/* register of bridge completed, add sysfs entries */
-	if ((dev->priv_flags & IFF_EBRIDGE) && event == NETDEV_REGISTER) {
-		br_sysfs_addbr(dev);
-		return NOTIFY_DONE;
-	}
-
-	/* not a port of a bridge */
-	p = br_port_get_rtnl(dev);
-	if (!p)
-		return NOTIFY_DONE;
-
-	br = p->br;
-
-	switch (event) {
-	case NETDEV_CHANGEMTU:
-		dev_set_mtu(br->dev, br_min_mtu(br));
-		break;
-
-	case NETDEV_CHANGEADDR:
-		spin_lock_bh(&br->lock);
-		br_fdb_changeaddr(p, dev->dev_addr);
-		changed_addr = br_stp_recalculate_bridge_id(br);
-		spin_unlock_bh(&br->lock);
-
-		if (changed_addr)
-			call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
-
-		break;
-
-	case NETDEV_CHANGE:
-		br_port_carrier_check(p);
-		break;
-
-	case NETDEV_FEAT_CHANGE:
-		netdev_update_features(br->dev);
-		break;
-
-	case NETDEV_DOWN:
-		spin_lock_bh(&br->lock);
-		if (br->dev->flags & IFF_UP)
-			br_stp_disable_port(p);
-		spin_unlock_bh(&br->lock);
-		break;
-
-	case NETDEV_UP:
-		if (netif_running(br->dev) && netif_oper_up(dev)) {
-			spin_lock_bh(&br->lock);
-			br_stp_enable_port(p);
-			spin_unlock_bh(&br->lock);
-		}
-		break;
-
-	case NETDEV_UNREGISTER:
-		br_del_if(br, dev);
-		break;
-
-	case NETDEV_CHANGENAME:
-		err = br_sysfs_renameif(p);
-		if (err)
-			return notifier_from_errno(err);
-		break;
-
-	case NETDEV_PRE_TYPE_CHANGE:
-		/* Forbid underlaying device to change its type. */
-		return NOTIFY_BAD;
-
-	case NETDEV_RESEND_IGMP:
-		/* Propagate to master device */
-		call_netdevice_notifiers(event, br->dev);
-		break;
-	}
-
-	/* Events that may cause spanning tree to refresh */
-	if (event == NETDEV_CHANGEADDR || event == NETDEV_UP ||
-	    event == NETDEV_CHANGE || event == NETDEV_DOWN)
-		br_ifinfo_notify(RTM_NEWLINK, p);
-
-	return NOTIFY_DONE;
-}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index af067711..53d6e32 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -333,8 +333,6 @@ struct br_input_skb_cb {
 #define br_debug(br, format, args...)			\
 	pr_debug("%s: " format,  (br)->dev->name, ##args)
 
-extern struct notifier_block br_device_notifier;
-
 /* called under bridge lock */
 static inline int br_is_root_bridge(const struct net_bridge *br)
 {
-- 
1.8.3.1
