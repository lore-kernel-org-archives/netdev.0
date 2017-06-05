From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2] devlink: fix potential memort leak
Date: Mon,  5 Jun 2017 08:57:21 +0800
Message-ID: <1496624241-25794-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:58983 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751163AbdFEA51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 20:57:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must free allocated skb when genlmsg_put() return fails.

Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Changes in v2:
  - Fix same issue in headers_fill.
---
 net/core/devlink.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index b0b87a2..a0adfc3 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1680,8 +1680,10 @@ static int devlink_dpipe_tables_fill(struct genl_info *info,
 
 	hdr = genlmsg_put(skb, info->snd_portid, info->snd_seq,
 			  &devlink_nl_family, NLM_F_MULTI, cmd);
-	if (!hdr)
+	if (!hdr) {
+		nlmsg_free(skb);
 		return -EMSGSIZE;
+	}
 
 	if (devlink_nl_put_handle(skb, devlink))
 		goto nla_put_failure;
@@ -2098,8 +2100,10 @@ static int devlink_dpipe_headers_fill(struct genl_info *info,
 
 	hdr = genlmsg_put(skb, info->snd_portid, info->snd_seq,
 			  &devlink_nl_family, NLM_F_MULTI, cmd);
-	if (!hdr)
+	if (!hdr) {
+		nlmsg_free(skb);
 		return -EMSGSIZE;
+	}
 
 	if (devlink_nl_put_handle(skb, devlink))
 		goto nla_put_failure;
-- 
1.8.3.1
