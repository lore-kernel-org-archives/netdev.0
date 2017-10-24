From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/7] devlink: Add support for reload
Date: Tue, 24 Oct 2017 11:22:41 +0200
Message-ID: <20171024092245.1386-4-jiri@resnulli.us>
References: <20171024092245.1386-1-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:56049 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdJXJWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:50 -0400
Received: by mail-wr0-f193.google.com with SMTP id l8so7090121wre.12
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:49 -0700 (PDT)
In-Reply-To: <20171024092245.1386-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for performing driver hot reload.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h        |  1 +
 include/uapi/linux/devlink.h |  1 +
 net/core/devlink.c           | 18 ++++++++++++++++++
 3 files changed, 20 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index 789e606..ff6e384 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -263,6 +263,7 @@ struct devlink_resource {
 #define DEVLINK_RESOURCE_ID_PARENT_TOP 0
 
 struct devlink_ops {
+	int (*reload)(struct devlink *devlink);
 	int (*port_type_set)(struct devlink_port *devlink_port,
 			     enum devlink_port_type port_type);
 	int (*port_split)(struct devlink *devlink, unsigned int port_index,
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 9db1d70..86a329a 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -71,6 +71,7 @@ enum devlink_command {
 	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
 	DEVLINK_CMD_RESOURCE_SET,
 	DEVLINK_CMD_RESOURCE_DUMP,
+	DEVLINK_CMD_RELOAD,
 
 	/* add new commands above here */
 	__DEVLINK_CMD_MAX,
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 86dfec9..3a9fcda 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -2484,6 +2484,16 @@ static int devlink_nl_cmd_resource_dump(struct sk_buff *skb,
 	return devlink_resource_fill(info, DEVLINK_CMD_RESOURCE_DUMP, 0);
 }
 
+static int devlink_nl_cmd_reload(struct sk_buff *skb, struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+
+	if (!devlink->ops->reload)
+		return -EOPNOTSUPP;
+
+	return devlink->ops->reload(devlink);
+}
+
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_BUS_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DEV_NAME] = { .type = NLA_NUL_STRING },
@@ -2676,6 +2686,14 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
+	{
+		.cmd = DEVLINK_CMD_RELOAD,
+		.doit = devlink_nl_cmd_reload,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK |
+				  DEVLINK_NL_FLAG_NO_LOCK,
+	},
 };
 
 static struct genl_family devlink_nl_family __ro_after_init = {
-- 
2.9.5
