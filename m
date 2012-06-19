From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 09/19] team: allow async option changes
Date: Tue, 19 Jun 2012 17:54:11 +0200
Message-ID: <1340121261-2966-10-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab2FSPyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:39 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two exported functions. One allows to mark option
instance as changed and the second processes change check and does
transfer of changed options to userspace.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   18 ++++++++++++++++++
 include/linux/if_team.h |    3 +++
 2 files changed, 21 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index cff8e25..7988ba0 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -82,6 +82,7 @@ static void team_refresh_port_linkup(struct team_port *port)
 						   port->state.linkup;
 }
 
+
 /*******************
  * Options handling
  *******************/
@@ -387,6 +388,22 @@ static int team_option_set(struct team *team,
 	return err;
 }
 
+void team_option_inst_set_change(struct team_option_inst_info *opt_inst_info)
+{
+	struct team_option_inst *opt_inst;
+
+	opt_inst = container_of(opt_inst_info, struct team_option_inst, info);
+	opt_inst->changed = true;
+}
+EXPORT_SYMBOL(team_option_inst_set_change);
+
+void team_options_change_check(struct team *team)
+{
+	__team_options_change_check(team);
+}
+EXPORT_SYMBOL(team_options_change_check);
+
+
 /****************
  * Mode handling
  ****************/
@@ -2051,6 +2068,7 @@ static void team_port_change_check(struct team_port *port, bool linkup)
 	mutex_unlock(&team->lock);
 }
 
+
 /************************************
  * Net device notifier event handler
  ************************************/
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 30854cb..2f29725 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -112,6 +112,9 @@ struct team_option {
 	int (*setter)(struct team *team, struct team_gsetter_ctx *ctx);
 };
 
+extern void team_option_inst_set_change(struct team_option_inst_info *opt_inst_info);
+extern void team_options_change_check(struct team *team);
+
 struct team_mode {
 	const char *kind;
 	struct module *owner;
-- 
1.7.10.2
