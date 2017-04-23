From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 2/2] team: fix memory leak
Date: Sun, 23 Apr 2017 15:29:43 +0800
Message-ID: <1492932583-770-1-git-send-email-bianpan2016@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:58631 "EHLO m50-133.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1427807AbdDWH34 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 03:29:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function team_nl_send_options_get(), pointer skb keeps the return
value of function nlmsg_new(). When the call to genlmsg_put() fails, the
control flow directly returns and does not free skb. This will result in
a memory leak bug. This patch fixes it.

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
