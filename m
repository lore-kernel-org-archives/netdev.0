From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] team: ab: set active port option as changed when port is leaving
Date: Fri,  1 Feb 2013 15:28:02 +0100
Message-ID: <1359728882-15333-2-git-send-email-jiri@resnulli.us>
References: <1359728882-15333-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:35963 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473Ab3BAO2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 09:28:11 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so2202572eek.32
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 06:28:09 -0800 (PST)
In-Reply-To: <1359728882-15333-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case port is leaving the team, set the option "activeport" as changed
so the change can be properly propagated to userspace

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team_mode_activebackup.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 6262b4d..40fd338 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -19,6 +19,7 @@
 
 struct ab_priv {
 	struct team_port __rcu *active_port;
+	struct team_option_inst_info *ap_opt_inst_info;
 };
 
 static struct ab_priv *ab_priv(struct team *team)
@@ -54,8 +55,17 @@ drop:
 
 static void ab_port_leave(struct team *team, struct team_port *port)
 {
-	if (ab_priv(team)->active_port == port)
+	if (ab_priv(team)->active_port == port) {
 		RCU_INIT_POINTER(ab_priv(team)->active_port, NULL);
+		team_option_inst_set_change(ab_priv(team)->ap_opt_inst_info);
+	}
+}
+
+static int ab_active_port_init(struct team *team,
+			       struct team_option_inst_info *info)
+{
+	ab_priv(team)->ap_opt_inst_info = info;
+	return 0;
 }
 
 static int ab_active_port_get(struct team *team, struct team_gsetter_ctx *ctx)
@@ -88,6 +98,7 @@ static const struct team_option ab_options[] = {
 	{
 		.name = "activeport",
 		.type = TEAM_OPTION_TYPE_U32,
+		.init = ab_active_port_init,
 		.getter = ab_active_port_get,
 		.setter = ab_active_port_set,
 	},
-- 
1.8.1
