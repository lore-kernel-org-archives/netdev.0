From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] team: introduce two default team_modeop functions and use them in modes
Date: Fri,  1 Mar 2013 11:26:05 +0100
Message-ID: <1362133566-1382-2-git-send-email-jiri@resnulli.us>
References: <1362133566-1382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:55276 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab3CAK0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 05:26:15 -0500
Received: by mail-ee0-f53.google.com with SMTP id e53so2284061eek.40
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 02:26:13 -0800 (PST)
In-Reply-To: <1362133566-1382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to duplicate code for this.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c                 | 19 ++++++++++++++++---
 drivers/net/team/team_mode_broadcast.c  | 14 ++------------
 drivers/net/team/team_mode_roundrobin.c | 14 ++------------
 include/linux/if_team.h                 |  5 ++++-
 4 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 05c5efe..ece70a4 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -73,11 +73,24 @@ static int team_port_set_orig_dev_addr(struct team_port *port)
 	return __set_port_dev_addr(port->dev, port->orig.dev_addr);
 }
 
-int team_port_set_team_dev_addr(struct team_port *port)
+static int team_port_set_team_dev_addr(struct team *team,
+				       struct team_port *port)
+{
+	return __set_port_dev_addr(port->dev, team->dev->dev_addr);
+}
+
+int team_modeop_port_enter(struct team *team, struct team_port *port)
+{
+	return team_port_set_team_dev_addr(team, port);
+}
+EXPORT_SYMBOL(team_modeop_port_enter);
+
+void team_modeop_port_change_dev_addr(struct team *team,
+				      struct team_port *port)
 {
-	return __set_port_dev_addr(port->dev, port->team->dev->dev_addr);
+	team_port_set_team_dev_addr(team, port);
 }
-EXPORT_SYMBOL(team_port_set_team_dev_addr);
+EXPORT_SYMBOL(team_modeop_port_change_dev_addr);
 
 static void team_refresh_port_linkup(struct team_port *port)
 {
diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
index c5db428..c366cd2 100644
--- a/drivers/net/team/team_mode_broadcast.c
+++ b/drivers/net/team/team_mode_broadcast.c
@@ -46,20 +46,10 @@ static bool bc_transmit(struct team *team, struct sk_buff *skb)
 	return sum_ret;
 }
 
-static int bc_port_enter(struct team *team, struct team_port *port)
-{
-	return team_port_set_team_dev_addr(port);
-}
-
-static void bc_port_change_dev_addr(struct team *team, struct team_port *port)
-{
-	team_port_set_team_dev_addr(port);
-}
-
 static const struct team_mode_ops bc_mode_ops = {
 	.transmit		= bc_transmit,
-	.port_enter		= bc_port_enter,
-	.port_change_dev_addr	= bc_port_change_dev_addr,
+	.port_enter		= team_modeop_port_enter,
+	.port_change_dev_addr	= team_modeop_port_change_dev_addr,
 };
 
 static const struct team_mode bc_mode = {
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 105135a..ed63a6b 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -64,20 +64,10 @@ drop:
 	return false;
 }
 
-static int rr_port_enter(struct team *team, struct team_port *port)
-{
-	return team_port_set_team_dev_addr(port);
-}
-
-static void rr_port_change_dev_addr(struct team *team, struct team_port *port)
-{
-	team_port_set_team_dev_addr(port);
-}
-
 static const struct team_mode_ops rr_mode_ops = {
 	.transmit		= rr_transmit,
-	.port_enter		= rr_port_enter,
-	.port_change_dev_addr	= rr_port_change_dev_addr,
+	.port_enter		= team_modeop_port_enter,
+	.port_change_dev_addr	= team_modeop_port_change_dev_addr,
 };
 
 static const struct team_mode rr_mode = {
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 4648d80..622fe43 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -112,6 +112,10 @@ struct team_mode_ops {
 	void (*port_disabled)(struct team *team, struct team_port *port);
 };
 
+extern int team_modeop_port_enter(struct team *team, struct team_port *port);
+extern void team_modeop_port_change_dev_addr(struct team *team,
+					     struct team_port *port);
+
 enum team_option_type {
 	TEAM_OPTION_TYPE_U32,
 	TEAM_OPTION_TYPE_STRING,
@@ -238,7 +242,6 @@ static inline struct team_port *team_get_port_by_index_rcu(struct team *team,
 	return NULL;
 }
 
-extern int team_port_set_team_dev_addr(struct team_port *port);
 extern int team_options_register(struct team *team,
 				 const struct team_option *option,
 				 size_t option_count);
-- 
1.8.1.2
