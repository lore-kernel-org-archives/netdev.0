From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] team: introduce random mode
Date: Fri,  1 Mar 2013 11:26:06 +0100
Message-ID: <1362133566-1382-3-git-send-email-jiri@resnulli.us>
References: <1362133566-1382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:59144 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab3CAK0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 05:26:17 -0500
Received: by mail-ee0-f41.google.com with SMTP id c13so2295968eek.28
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 02:26:16 -0800 (PST)
In-Reply-To: <1362133566-1382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Eric Dumazet, allow user to select mode which chooses
TX port randomly. Functionality should be more of less similar to
round-robin mode with even lower overhead.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/Kconfig                | 12 ++++++
 drivers/net/team/Makefile               |  1 +
 drivers/net/team/team_mode_random.c     | 71 +++++++++++++++++++++++++++++++++
 drivers/net/team/team_mode_roundrobin.c | 22 +---------
 include/linux/if_team.h                 | 20 ++++++++++
 5 files changed, 105 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/team/team_mode_random.c

diff --git a/drivers/net/team/Kconfig b/drivers/net/team/Kconfig
index c3011af..c853d84 100644
--- a/drivers/net/team/Kconfig
+++ b/drivers/net/team/Kconfig
@@ -37,6 +37,18 @@ config NET_TEAM_MODE_ROUNDROBIN
 	  To compile this team mode as a module, choose M here: the module
 	  will be called team_mode_roundrobin.
 
+config NET_TEAM_MODE_RANDOM
+	tristate "Random mode support"
+	depends on NET_TEAM
+	---help---
+	  Basic mode where port used for transmitting packets is selected
+	  randomly.
+
+	  All added ports are setup to have team's device address.
+
+	  To compile this team mode as a module, choose M here: the module
+	  will be called team_mode_random.
+
 config NET_TEAM_MODE_ACTIVEBACKUP
 	tristate "Active-backup mode support"
 	depends on NET_TEAM
diff --git a/drivers/net/team/Makefile b/drivers/net/team/Makefile
index 9757630..c57e858 100644
--- a/drivers/net/team/Makefile
+++ b/drivers/net/team/Makefile
@@ -5,5 +5,6 @@
 obj-$(CONFIG_NET_TEAM) += team.o
 obj-$(CONFIG_NET_TEAM_MODE_BROADCAST) += team_mode_broadcast.o
 obj-$(CONFIG_NET_TEAM_MODE_ROUNDROBIN) += team_mode_roundrobin.o
+obj-$(CONFIG_NET_TEAM_MODE_RANDOM) += team_mode_random.o
 obj-$(CONFIG_NET_TEAM_MODE_ACTIVEBACKUP) += team_mode_activebackup.o
 obj-$(CONFIG_NET_TEAM_MODE_LOADBALANCE) += team_mode_loadbalance.o
diff --git a/drivers/net/team/team_mode_random.c b/drivers/net/team/team_mode_random.c
new file mode 100644
index 0000000..9eabfaa
--- /dev/null
+++ b/drivers/net/team/team_mode_random.c
@@ -0,0 +1,71 @@
+/*
+ * drivers/net/team/team_mode_random.c - Random mode for team
+ * Copyright (c) 2013 Jiri Pirko <jiri@resnulli.us>
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
+#include <linux/skbuff.h>
+#include <linux/reciprocal_div.h>
+#include <linux/if_team.h>
+
+static u32 random_N(unsigned int N)
+{
+	return reciprocal_divide(random32(), N);
+}
+
+static bool rnd_transmit(struct team *team, struct sk_buff *skb)
+{
+	struct team_port *port;
+	int port_index;
+
+	port_index = random_N(team->en_port_count);
+	port = team_get_port_by_index_rcu(team, port_index);
+	port = team_get_first_port_txable_rcu(team, port);
+	if (unlikely(!port))
+		goto drop;
+	if (team_dev_queue_xmit(team, port, skb))
+		return false;
+	return true;
+
+drop:
+	dev_kfree_skb_any(skb);
+	return false;
+}
+
+static const struct team_mode_ops rnd_mode_ops = {
+	.transmit		= rnd_transmit,
+	.port_enter		= team_modeop_port_enter,
+	.port_change_dev_addr	= team_modeop_port_change_dev_addr,
+};
+
+static const struct team_mode rnd_mode = {
+	.kind		= "random",
+	.owner		= THIS_MODULE,
+	.ops		= &rnd_mode_ops,
+};
+
+static int __init rnd_init_module(void)
+{
+	return team_mode_register(&rnd_mode);
+}
+
+static void __exit rnd_cleanup_module(void)
+{
+	team_mode_unregister(&rnd_mode);
+}
+
+module_init(rnd_init_module);
+module_exit(rnd_cleanup_module);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("Random mode for team");
+MODULE_ALIAS("team-mode-random");
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index ed63a6b..d268e4d 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -25,26 +25,6 @@ static struct rr_priv *rr_priv(struct team *team)
 	return (struct rr_priv *) &team->mode_priv;
 }
 
-static struct team_port *__get_first_port_up(struct team *team,
-					     struct team_port *port)
-{
-	struct team_port *cur;
-
-	if (team_port_txable(port))
-		return port;
-	cur = port;
-	list_for_each_entry_continue_rcu(cur, &team->port_list, list)
-		if (team_port_txable(port))
-			return cur;
-	list_for_each_entry_rcu(cur, &team->port_list, list) {
-		if (cur == port)
-			break;
-		if (team_port_txable(port))
-			return cur;
-	}
-	return NULL;
-}
-
 static bool rr_transmit(struct team *team, struct sk_buff *skb)
 {
 	struct team_port *port;
@@ -52,7 +32,7 @@ static bool rr_transmit(struct team *team, struct sk_buff *skb)
 
 	port_index = rr_priv(team)->sent_packets++ % team->en_port_count;
 	port = team_get_port_by_index_rcu(team, port_index);
-	port = __get_first_port_up(team, port);
+	port = team_get_first_port_txable_rcu(team, port);
 	if (unlikely(!port))
 		goto drop;
 	if (team_dev_queue_xmit(team, port, skb))
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 622fe43..90fc919 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -242,6 +242,26 @@ static inline struct team_port *team_get_port_by_index_rcu(struct team *team,
 	return NULL;
 }
 
+static inline struct team_port *
+team_get_first_port_txable_rcu(struct team *team, struct team_port *port)
+{
+	struct team_port *cur;
+
+	if (likely(team_port_txable(port)))
+		return port;
+	cur = port;
+	list_for_each_entry_continue_rcu(cur, &team->port_list, list)
+		if (team_port_txable(port))
+			return cur;
+	list_for_each_entry_rcu(cur, &team->port_list, list) {
+		if (cur == port)
+			break;
+		if (team_port_txable(port))
+			return cur;
+	}
+	return NULL;
+}
+
 extern int team_options_register(struct team *team,
 				 const struct team_option *option,
 				 size_t option_count);
-- 
1.8.1.2
