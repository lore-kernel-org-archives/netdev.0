From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 02/19] team: for nomode use dummy struct team_mode
Date: Tue, 19 Jun 2012 17:54:04 +0200
Message-ID: <1340121261-2966-3-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:28 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That leaves team->mode and all its values valid so no checks would be
needed (for example in team_mode_option_get()).

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index bdf87a9..343f4ff 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -479,6 +479,20 @@ rx_handler_result_t team_dummy_receive(struct team *team,
 	return RX_HANDLER_ANOTHER;
 }
 
+static const struct team_mode __team_no_mode = {
+	.kind		= "*NOMODE*",
+};
+
+static bool team_is_mode_set(struct team *team)
+{
+	return team->mode != &__team_no_mode;
+}
+
+static void team_set_no_mode(struct team *team)
+{
+	team->mode = &__team_no_mode;
+}
+
 static void team_adjust_ops(struct team *team)
 {
 	/*
@@ -487,13 +501,13 @@ static void team_adjust_ops(struct team *team)
 	 */
 
 	if (list_empty(&team->port_list) ||
-	    !team->mode || !team->mode->ops->transmit)
+	    !team_is_mode_set(team) || !team->mode->ops->transmit)
 		team->ops.transmit = team_dummy_transmit;
 	else
 		team->ops.transmit = team->mode->ops->transmit;
 
 	if (list_empty(&team->port_list) ||
-	    !team->mode || !team->mode->ops->receive)
+	    !team_is_mode_set(team) || !team->mode->ops->receive)
 		team->ops.receive = team_dummy_receive;
 	else
 		team->ops.receive = team->mode->ops->receive;
@@ -508,7 +522,7 @@ static int __team_change_mode(struct team *team,
 			      const struct team_mode *new_mode)
 {
 	/* Check if mode was previously set and do cleanup if so */
-	if (team->mode) {
+	if (team_is_mode_set(team)) {
 		void (*exit_op)(struct team *team) = team->ops.exit;
 
 		/* Clear ops area so no callback is called any longer */
@@ -518,7 +532,7 @@ static int __team_change_mode(struct team *team,
 		if (exit_op)
 			exit_op(team);
 		team_mode_put(team->mode);
-		team->mode = NULL;
+		team_set_no_mode(team);
 		/* zero private data area */
 		memset(&team->mode_priv, 0,
 		       sizeof(struct team) - offsetof(struct team, mode_priv));
@@ -553,7 +567,7 @@ static int team_change_mode(struct team *team, const char *kind)
 		return -EBUSY;
 	}
 
-	if (team->mode && strcmp(team->mode->kind, kind) == 0) {
+	if (team_is_mode_set(team) && strcmp(team->mode->kind, kind) == 0) {
 		netdev_err(dev, "Unable to change to the same mode the team is in\n");
 		return -EINVAL;
 	}
@@ -912,11 +926,9 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
  * Net device ops
  *****************/
 
-static const char team_no_mode_kind[] = "*NOMODE*";
-
 static int team_mode_option_get(struct team *team, struct team_gsetter_ctx *ctx)
 {
-	ctx->data.str_val = team->mode ? team->mode->kind : team_no_mode_kind;
+	ctx->data.str_val = team->mode->kind;
 	return 0;
 }
 
@@ -1014,6 +1026,7 @@ static int team_init(struct net_device *dev)
 
 	team->dev = dev;
 	mutex_init(&team->lock);
+	team_set_no_mode(team);
 
 	team->pcpu_stats = alloc_percpu(struct team_pcpu_stats);
 	if (!team->pcpu_stats)
-- 
1.7.10.2
