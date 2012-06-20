From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next] team: do RCU update path fixups
Date: Wed, 20 Jun 2012 20:39:39 +0200
Message-ID: <1340217579-1478-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932328Ab2FTSj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 14:39:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use rcu_access_pointer and rcu_dereference_protected
to access RCU pointer by updater.
Use RCU_INIT_POINTER for NULL assignment of RCU pointer.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team_mode_activebackup.c |    8 ++++++--
 drivers/net/team/team_mode_loadbalance.c  |   14 ++++++++++----
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 2fe02a8..253b8a5 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -61,8 +61,12 @@ static void ab_port_leave(struct team *team, struct team_port *port)
 
 static int ab_active_port_get(struct team *team, struct team_gsetter_ctx *ctx)
 {
-	if (ab_priv(team)->active_port)
-		ctx->data.u32_val = ab_priv(team)->active_port->dev->ifindex;
+	struct team_port *active_port;
+
+	active_port = rcu_dereference_protected(ab_priv(team)->active_port,
+						lockdep_is_held(&team->lock));
+	if (active_port)
+		ctx->data.u32_val = active_port->dev->ifindex;
 	else
 		ctx->data.u32_val = 0;
 	return 0;
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 45cc095..c92fa02 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -96,8 +96,8 @@ static void lb_tx_hash_to_port_mapping_null_port(struct team *team,
 		struct lb_port_mapping *pm;
 
 		pm = &lb_priv->ex->tx_hash_to_port_mapping[i];
-		if (pm->port == port) {
-			rcu_assign_pointer(pm->port, NULL);
+		if (rcu_access_pointer(pm->port) == port) {
+			RCU_INIT_POINTER(pm->port, NULL);
 			team_option_inst_set_change(pm->opt_inst_info);
 			changed = true;
 		}
@@ -274,6 +274,7 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 {
 	struct lb_priv *lb_priv = get_lb_priv(team);
 	struct sk_filter *fp = NULL;
+	struct sk_filter *orig_fp;
 	struct sock_fprog *fprog = NULL;
 	int err;
 
@@ -292,7 +293,9 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 	if (lb_priv->ex->orig_fprog) {
 		/* Clear old filter data */
 		__fprog_destroy(lb_priv->ex->orig_fprog);
-		sk_unattached_filter_destroy(lb_priv->fp);
+		orig_fp = rcu_dereference_protected(lb_priv->fp,
+						lockdep_is_held(&team->lock));
+		sk_unattached_filter_destroy(orig_fp);
 	}
 
 	rcu_assign_pointer(lb_priv->fp, fp);
@@ -303,9 +306,12 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 static int lb_tx_method_get(struct team *team, struct team_gsetter_ctx *ctx)
 {
 	struct lb_priv *lb_priv = get_lb_priv(team);
+	lb_select_tx_port_func_t *func;
 	char *name;
 
-	name = lb_select_tx_port_get_name(lb_priv->select_tx_port_func);
+	func = rcu_dereference_protected(lb_priv->select_tx_port_func,
+					 lockdep_is_held(&team->lock));
+	name = lb_select_tx_port_get_name(func);
 	BUG_ON(!name);
 	ctx->data.str_val = name;
 	return 0;
-- 
1.7.10.4
