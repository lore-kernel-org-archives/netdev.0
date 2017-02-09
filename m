From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] devlink: allow to fillup eswitch attrs even if mode_get op does not exist
Date: Thu,  9 Feb 2017 15:54:36 +0100
Message-ID: <1486652076-20756-5-git-send-email-jiri@resnulli.us>
References: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36813 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752357AbdBIO41 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:56:27 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so3253113wmd.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:54:44 -0800 (PST)
In-Reply-To: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Even when mode_get op is not present, other eswitch attrs need to be
filled-up.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/devlink.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index 7f88cc8..e9c1e6a 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1410,12 +1410,14 @@ static int devlink_nl_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 	if (err)
 		goto nla_put_failure;
 
-	err = ops->eswitch_mode_get(devlink, &mode);
-	if (err)
-		goto nla_put_failure;
-	err = nla_put_u16(msg, DEVLINK_ATTR_ESWITCH_MODE, mode);
-	if (err)
-		goto nla_put_failure;
+	if (ops->eswitch_mode_get) {
+		err = ops->eswitch_mode_get(devlink, &mode);
+		if (err)
+			goto nla_put_failure;
+		err = nla_put_u16(msg, DEVLINK_ATTR_ESWITCH_MODE, mode);
+		if (err)
+			goto nla_put_failure;
+	}
 
 	if (ops->eswitch_inline_mode_get) {
 		err = ops->eswitch_inline_mode_get(devlink, &inline_mode);
@@ -1443,7 +1445,7 @@ static int devlink_nl_cmd_eswitch_get_doit(struct sk_buff *skb,
 	struct sk_buff *msg;
 	int err;
 
-	if (!ops || !ops->eswitch_mode_get)
+	if (!ops)
 		return -EOPNOTSUPP;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-- 
2.7.4
