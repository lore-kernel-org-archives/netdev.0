From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] devlink: share user_ptr pointer for both devlink and devlink_port
Date: Fri,  8 Apr 2016 17:47:17 +0200
Message-ID: <1460130437-15015-2-git-send-email-jiri@resnulli.us>
References: <1460130437-15015-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36672 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756456AbcDHPrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:47:22 -0400
Received: by mail-wm0-f68.google.com with SMTP id l6so5284154wml.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 08:47:21 -0700 (PDT)
In-Reply-To: <1460130437-15015-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ptr to devlink structure can be easily obtained from
devlink_port->devlink. So share user_ptr[0] pointer for both and leave
user_ptr[1] free for other users.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 net/core/devlink.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index 44f880d..b84cf0d 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -119,7 +119,8 @@ static struct devlink_port *devlink_port_get_from_info(struct devlink *devlink,
 	return devlink_port_get_from_attrs(devlink, info->attrs);
 }
 
-#define DEVLINK_NL_FLAG_NEED_PORT	BIT(0)
+#define DEVLINK_NL_FLAG_NEED_DEVLINK	BIT(0)
+#define DEVLINK_NL_FLAG_NEED_PORT	BIT(1)
 
 static int devlink_nl_pre_doit(const struct genl_ops *ops,
 			       struct sk_buff *skb, struct genl_info *info)
@@ -132,8 +133,9 @@ static int devlink_nl_pre_doit(const struct genl_ops *ops,
 		mutex_unlock(&devlink_mutex);
 		return PTR_ERR(devlink);
 	}
-	info->user_ptr[0] = devlink;
-	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_PORT) {
+	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_DEVLINK) {
+		info->user_ptr[0] = devlink;
+	} else if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_PORT) {
 		struct devlink_port *devlink_port;
 
 		mutex_lock(&devlink_port_mutex);
@@ -143,7 +145,7 @@ static int devlink_nl_pre_doit(const struct genl_ops *ops,
 			mutex_unlock(&devlink_mutex);
 			return PTR_ERR(devlink_port);
 		}
-		info->user_ptr[1] = devlink_port;
+		info->user_ptr[0] = devlink_port;
 	}
 	return 0;
 }
@@ -356,8 +358,8 @@ out:
 static int devlink_nl_cmd_port_get_doit(struct sk_buff *skb,
 					struct genl_info *info)
 {
-	struct devlink *devlink = info->user_ptr[0];
-	struct devlink_port *devlink_port = info->user_ptr[1];
+	struct devlink_port *devlink_port = info->user_ptr[0];
+	struct devlink *devlink = devlink_port->devlink;
 	struct sk_buff *msg;
 	int err;
 
@@ -436,8 +438,8 @@ static int devlink_port_type_set(struct devlink *devlink,
 static int devlink_nl_cmd_port_set_doit(struct sk_buff *skb,
 					struct genl_info *info)
 {
-	struct devlink *devlink = info->user_ptr[0];
-	struct devlink_port *devlink_port = info->user_ptr[1];
+	struct devlink_port *devlink_port = info->user_ptr[0];
+	struct devlink *devlink = devlink_port->devlink;
 	int err;
 
 	if (info->attrs[DEVLINK_ATTR_PORT_TYPE]) {
@@ -511,6 +513,7 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.doit = devlink_nl_cmd_get_doit,
 		.dumpit = devlink_nl_cmd_get_dumpit,
 		.policy = devlink_nl_policy,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 		/* can be retrieved by unprivileged users */
 	},
 	{
@@ -533,12 +536,14 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.doit = devlink_nl_cmd_port_split_doit,
 		.policy = devlink_nl_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
 	{
 		.cmd = DEVLINK_CMD_PORT_UNSPLIT,
 		.doit = devlink_nl_cmd_port_unsplit_doit,
 		.policy = devlink_nl_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
 };
 
-- 
2.5.5
