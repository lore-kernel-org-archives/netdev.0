From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/3] team: use function team_port_txable() for determing enabled and up port
Date: Wed, 11 Jul 2012 17:34:02 +0200
Message-ID: <1342020844-3547-2-git-send-email-jpirko@redhat.com>
References: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41227 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758133Ab2GKPeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 11:34:09 -0400
In-Reply-To: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c                 |    6 ++++++
 drivers/net/team/team_mode_roundrobin.c |    6 +++---
 include/linux/if_team.h                 |    1 +
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9b94f53..bc7afa5 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -677,6 +677,12 @@ bool team_port_enabled(struct team_port *port)
 }
 EXPORT_SYMBOL(team_port_enabled);
 
+bool team_port_txable(struct team_port *port)
+{
+	return port->linkup && team_port_enabled(port);
+}
+EXPORT_SYMBOL(team_port_txable);
+
 /*
  * Enable/disable port by adding to enabled port hashlist and setting
  * port->index (Might be racy so reader could see incorrect ifindex when
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 52dd0ec..0cf38e9 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -30,16 +30,16 @@ static struct team_port *__get_first_port_up(struct team *team,
 {
 	struct team_port *cur;
 
-	if (port->linkup)
+	if (team_port_txable(port))
 		return port;
 	cur = port;
 	list_for_each_entry_continue_rcu(cur, &team->port_list, list)
-		if (cur->linkup)
+		if (team_port_txable(port))
 			return cur;
 	list_for_each_entry_rcu(cur, &team->port_list, list) {
 		if (cur == port)
 			break;
-		if (cur->linkup)
+		if (team_port_txable(port))
 			return cur;
 	}
 	return NULL;
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 99efd60..dca426c 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -64,6 +64,7 @@ struct team_port {
 };
 
 extern bool team_port_enabled(struct team_port *port);
+extern bool team_port_txable(struct team_port *port);
 
 struct team_mode_ops {
 	int (*init)(struct team *team);
-- 
1.7.10.4
