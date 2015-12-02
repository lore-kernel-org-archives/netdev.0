From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 15/28] team: rtnl_lock for options set
Date: Wed,  2 Dec 2015 21:07:38 +0100
Message-ID: <1449086871-19911-16-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34185 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300AbbLBUIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:14 -0500
Received: by wmvv187 with SMTP id v187so272524943wmv.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:13 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
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
