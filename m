From: Pan Bian <bianpan2016@163.com>
Subject: [net 1/1] team: fix memory leaks
Date: Mon, 24 Apr 2017 17:36:52 +0800
Message-ID: <1493026612-12383-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:48831 "EHLO m12-18.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1168035AbdDXJhc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 05:37:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In functions team_nl_send_port_list_get() and
team_nl_send_options_get(), pointer skb keeps the return value of
nlmsg_new(). When the call to genlmsg_put() fails, the memory is not
freed(). This will result in memory leak bugs.

Fixes: 9b00cf2d1024 ("team: implement multipart netlink messages for
options transfers")
Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/team/team.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f8c81f1..85c0124 100644
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
@@ -2634,8 +2636,10 @@ static int team_nl_send_port_list_get(struct team *team, u32 portid, u32 seq,
 
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
