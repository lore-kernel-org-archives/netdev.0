From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/2] team: use rcu_access_pointer to access RCU pointer by writer
Date: Wed, 20 Jun 2012 17:32:00 +0200
Message-ID: <1340206321-5986-2-git-send-email-jpirko@redhat.com>
References: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50796 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755680Ab2FTPdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 11:33:09 -0400
In-Reply-To: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team_mode_activebackup.c |    7 +++++--
 drivers/net/team/team_mode_loadbalance.c  |    8 +++++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 2fe02a8..c9e7621 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -61,8 +61,11 @@ static void ab_port_leave(struct team *team, struct team_port *port)
 
 static int ab_active_port_get(struct team *team, struct team_gsetter_ctx *ctx)
 {
-	if (ab_priv(team)->active_port)
-		ctx->data.u32_val = ab_priv(team)->active_port->dev->ifindex;
+	struct team_port *active_port;
+
+	active_port = rcu_access_pointer(ab_priv(team)->active_port);
+	if (active_port)
+		ctx->data.u32_val = active_port->dev->ifindex;
 	else
 		ctx->data.u32_val = 0;
 	return 0;
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 45cc095..b4475a5 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -96,7 +96,7 @@ static void lb_tx_hash_to_port_mapping_null_port(struct team *team,
 		struct lb_port_mapping *pm;
 
 		pm = &lb_priv->ex->tx_hash_to_port_mapping[i];
-		if (pm->port == port) {
+		if (rcu_access_pointer(pm->port) == port) {
 			rcu_assign_pointer(pm->port, NULL);
 			team_option_inst_set_change(pm->opt_inst_info);
 			changed = true;
@@ -292,7 +292,7 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 	if (lb_priv->ex->orig_fprog) {
 		/* Clear old filter data */
 		__fprog_destroy(lb_priv->ex->orig_fprog);
-		sk_unattached_filter_destroy(lb_priv->fp);
+		sk_unattached_filter_destroy(rcu_access_pointer(lb_priv->fp));
 	}
 
 	rcu_assign_pointer(lb_priv->fp, fp);
@@ -303,9 +303,11 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 static int lb_tx_method_get(struct team *team, struct team_gsetter_ctx *ctx)
 {
 	struct lb_priv *lb_priv = get_lb_priv(team);
+	lb_select_tx_port_func_t *func;
 	char *name;
 
-	name = lb_select_tx_port_get_name(lb_priv->select_tx_port_func);
+	func = rcu_access_pointer(lb_priv->select_tx_port_func);
+	name = lb_select_tx_port_get_name(func);
 	BUG_ON(!name);
 	ctx->data.str_val = name;
 	return 0;
-- 
1.7.10.4
