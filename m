From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 15/28] team: rtnl_lock for options set
Date: Thu,  3 Dec 2015 12:12:17 +0100
Message-ID: <1449141150-8172-16-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34186 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759947AbbLCLM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:56 -0500
Received: by wmvv187 with SMTP id v187so21659708wmv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:55 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

During options set, there will be needed to hold rtnl_mutex in order to
safely call netdev notifiers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/team/team.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index dd1504b..9814133 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2422,9 +2422,13 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 	struct nlattr *nl_option;
 	LIST_HEAD(opt_inst_list);
 
+	rtnl_lock();
+
 	team = team_nl_team_get(info);
-	if (!team)
-		return -EINVAL;
+	if (!team) {
+		err = -EINVAL;
+		goto rtnl_unlock;
+	}
 
 	err = -EINVAL;
 	if (!info->attrs[TEAM_ATTR_LIST_OPTION]) {
@@ -2551,7 +2555,8 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 
 team_put:
 	team_nl_team_put(team);
-
+rtnl_unlock:
+	rtnl_unlock();
 	return err;
 }
 
-- 
1.9.3
