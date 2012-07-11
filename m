From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 2/3] team: add broadcast mode
Date: Wed, 11 Jul 2012 17:34:03 +0200
Message-ID: <1342020844-3547-3-git-send-email-jpirko@redhat.com>
References: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1585 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758135Ab2GKPeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 11:34:11 -0400
In-Reply-To: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/Kconfig               |   13 ++++-
 drivers/net/team/Makefile              |    1 +
 drivers/net/team/team_mode_broadcast.c |   88 ++++++++++++++++++++++++++++++++
 3 files changed, 101 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/team/team_mode_broadcast.c

diff --git a/drivers/net/team/Kconfig b/drivers/net/team/Kconfig
index 89024d5..6a7260b 100644
--- a/drivers/net/team/Kconfig
+++ b/drivers/net/team/Kconfig
@@ -15,6 +15,17 @@ menuconfig NET_TEAM
 
 if NET_TEAM
 
+config NET_TEAM_MODE_BROADCAST
+	tristate "Broadcast mode support"
+	depends on NET_TEAM
+	---help---
+	  Basic mode where packets are transmitted always by all suitable ports.
+
+	  All added ports are setup to have team's mac address.
+
+	  To compile this team mode as a module, choose M here: the module
+	  will be called team_mode_broadcast.
+
 config NET_TEAM_MODE_ROUNDROBIN
 	tristate "Round-robin mode support"
 	depends on NET_TEAM
@@ -22,7 +33,7 @@ config NET_TEAM_MODE_ROUNDROBIN
 	  Basic mode where port used for transmitting packets is selected in
 	  round-robin fashion using packet counter.
 
-	  All added ports are setup to have bond's mac address.
+	  All added ports are setup to have team's mac address.
 
 	  To compile this team mode as a module, choose M here: the module
 	  will be called team_mode_roundrobin.
diff --git a/drivers/net/team/Makefile b/drivers/net/team/Makefile
index fb9f4c1..9757630 100644
--- a/drivers/net/team/Makefile
+++ b/drivers/net/team/Makefile
@@ -3,6 +3,7 @@
 #
 
 obj-$(CONFIG_NET_TEAM) += team.o
+obj-$(CONFIG_NET_TEAM_MODE_BROADCAST) += team_mode_broadcast.o
 obj-$(CONFIG_NET_TEAM_MODE_ROUNDROBIN) += team_mode_roundrobin.o
 obj-$(CONFIG_NET_TEAM_MODE_ACTIVEBACKUP) += team_mode_activebackup.o
 obj-$(CONFIG_NET_TEAM_MODE_LOADBALANCE) += team_mode_loadbalance.o
diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
new file mode 100644
index 0000000..5562345
--- /dev/null
+++ b/drivers/net/team/team_mode_broadcast.c
@@ -0,0 +1,88 @@
+/*
+ * drivers/net/team/team_mode_broadcast.c - Broadcast mode for team
+ * Copyright (c) 2012 Jiri Pirko <jpirko@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/if_team.h>
+
+static bool bc_transmit(struct team *team, struct sk_buff *skb)
+{
+	struct team_port *cur;
+	struct team_port *last = NULL;
+	struct sk_buff *skb2;
+	bool ret;
+	bool sum_ret = false;
+
+	list_for_each_entry_rcu(cur, &team->port_list, list) {
+		if (team_port_txable(cur)) {
+			if (last) {
+				skb2 = skb_clone(skb, GFP_ATOMIC);
+				if (skb2) {
+					skb2->dev = last->dev;
+					ret = dev_queue_xmit(skb2);
+					if (!sum_ret)
+						sum_ret = ret;
+				}
+			}
+			last = cur;
+		}
+	}
+	if (last) {
+		skb->dev = last->dev;
+		ret = dev_queue_xmit(skb);
+		if (!sum_ret)
+			sum_ret = ret;
+	}
+	return sum_ret;
+}
+
+static int bc_port_enter(struct team *team, struct team_port *port)
+{
+	return team_port_set_team_mac(port);
+}
+
+static void bc_port_change_mac(struct team *team, struct team_port *port)
+{
+	team_port_set_team_mac(port);
+}
+
+static const struct team_mode_ops bc_mode_ops = {
+	.transmit		= bc_transmit,
+	.port_enter		= bc_port_enter,
+	.port_change_mac	= bc_port_change_mac,
+};
+
+static const struct team_mode bc_mode = {
+	.kind		= "broadcast",
+	.owner		= THIS_MODULE,
+	.ops		= &bc_mode_ops,
+};
+
+static int __init bc_init_module(void)
+{
+	return team_mode_register(&bc_mode);
+}
+
+static void __exit bc_cleanup_module(void)
+{
+	team_mode_unregister(&bc_mode);
+}
+
+module_init(bc_init_module);
+module_exit(bc_cleanup_module);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
+MODULE_DESCRIPTION("Broadcast mode for team");
+MODULE_ALIAS("team-mode-broadcast");
-- 
1.7.10.4
