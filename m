From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/2] team: fix memory leak
Date: Sun, 23 Apr 2017 15:29:24 +0800
Message-ID: <1492932564-722-1-git-send-email-bianpan2016@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-138.163.com ([123.125.50.138]:51182 "EHLO m50-138.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1044270AbdDWH3e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 03:29:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function team_nl_send_port_list_get(), pointer skb keeps the return
value of nlmsg_new(). When the call to genlmsg_put() fails, the memory
is not freed. This will result in a memory leak bug. This patch fixes
it.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/team/team.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f8c81f1..dd3a2e9 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2634,8 +2634,10 @@ static int team_nl_send_port_list_get(struct team *team, u32 portid, u32 seq,
 
 	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags | NLM_F_MULTI,
 			  TEAM_CMD_PORT_LIST_GET);
-	if (!hdr)
+	if (!hdr) {
+		nlmsg_free(skb);
 		return -EMSGSIZE;
+	}
 
 	if (nla_put_u32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex))
 		goto nla_put_failure;
-- 
1.9.1
