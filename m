From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 2/2] net: team: fix memory leak in team_nl_send_options_get
Date: Mon, 24 Apr 2017 15:04:55 +0800
Message-ID: <1493017495-3578-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:44072 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165702AbdDXHFt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 03:05:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function team_nl_send_options_get(), pointer skb keeps the return
value of function nlmsg_new(). When the call to genlmsg_put() fails, the
control flow directly returns and does not free skb. This will result in
a memory leak bug. This patch fixes it.

Fixes: 8ea7fd0d8792 ("team: fix memory leak")

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/team/team.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index dd3a2e9..85c0124 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2361,8 +2361,10 @@ static int team_nl_send_options_get(struct team *team, u32 portid, u32 seq,
 
 	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags | NLM_F_MULTI,
 			  TEAM_CMD_OPTIONS_GET);
-	if (!hdr)
+	if (!hdr) {
+		nlmsg_free(skb);
 		return -EMSGSIZE;
+	}
 
 	if (nla_put_u32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex))
 		goto nla_put_failure;
-- 
1.9.1
