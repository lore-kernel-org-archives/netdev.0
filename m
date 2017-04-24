From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/2] net: team: fix memory leak in team_nl_send_port_list_get
Date: Mon, 24 Apr 2017 15:04:36 +0800
Message-ID: <1493017476-3535-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function team_nl_send_port_list_get(), pointer skb keeps the return
value of nlmsg_new(). When the call to genlmsg_put() fails, the memory
is not freed. This will result in a memory leak bug. This patch fixes
it.

Fixes: fbd69cda90e7 ("team: fix memory leak")

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
