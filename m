From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 2/3] team: do not allow to map disabled ports
Date: Tue, 26 Jun 2012 18:52:46 +0200
Message-ID: <1340729567-3164-3-git-send-email-jpirko@redhat.com>
References: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14798 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758685Ab2FZRHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 13:07:30 -0400
In-Reply-To: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c                  |    5 ++---
 drivers/net/team/team_mode_loadbalance.c |    3 ++-
 include/linux/if_team.h                  |    2 ++
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6b4cf6e..5350eea 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -614,8 +614,6 @@ static int team_change_mode(struct team *team, const char *kind)
  * Rx path frame handler
  ************************/
 
-static bool team_port_enabled(struct team_port *port);
-
 /* note: already called with rcu_read_lock */
 static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
 {
@@ -673,10 +671,11 @@ static bool team_port_find(const struct team *team,
 	return false;
 }
 
-static bool team_port_enabled(struct team_port *port)
+bool team_port_enabled(struct team_port *port)
 {
 	return port->index != -1;
 }
+EXPORT_SYMBOL(team_port_enabled);
 
 /*
  * Enable/disable port by adding to enabled port hashlist and setting
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index c92fa02..51a4b19 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -359,7 +359,8 @@ static int lb_tx_hash_to_port_mapping_set(struct team *team,
 	unsigned char hash = ctx->info->array_index;
 
 	list_for_each_entry(port, &team->port_list, list) {
-		if (ctx->data.u32_val == port->dev->ifindex) {
+		if (ctx->data.u32_val == port->dev->ifindex &&
+		    team_port_enabled(port)) {
 			rcu_assign_pointer(LB_HTPM_PORT_BY_HASH(lb_priv, hash),
 					   port);
 			return 0;
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index c193886..e636a54 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -64,6 +64,8 @@ struct team_port {
 	long mode_priv[0];
 };
 
+extern bool team_port_enabled(struct team_port *port);
+
 struct team_mode_ops {
 	int (*init)(struct team *team);
 	void (*exit)(struct team *team);
-- 
1.7.10.4
