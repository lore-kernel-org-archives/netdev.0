From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/18] devlink: implement shared buffer occupancy monitoring interface
Date: Thu, 14 Apr 2016 18:19:14 +0200
Message-ID: <1460650770-19382-3-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37850 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235AbcDNQTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:37 -0400
Received: by mail-wm0-f43.google.com with SMTP id n3so133905731wmn.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:36 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

User needs to monitor shared buffer occupancy. For that, he issues a
snapshot command in order to instruct hardware to catch current and
maximal occupancy values, and clear command in order to clear the
historical maximal values.

Also port-pool and tc-pool-bind command response messages are extended to
carry occupancy values.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 include/net/devlink.h        | 12 ++++++
 include/uapi/linux/devlink.h |  6 +++
 net/core/devlink.c           | 98 +++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 110 insertions(+), 6 deletions(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index e4c2747..be64218 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -78,6 +78,18 @@ struct devlink_ops {
 				   u16 tc_index,
 				   enum devlink_sb_pool_type pool_type,
 				   u16 pool_index, u32 threshold);
+	int (*sb_occ_snapshot)(struct devlink *devlink,
+			       unsigned int sb_index);
+	int (*sb_occ_max_clear)(struct devlink *devlink,
+				unsigned int sb_index);
+	int (*sb_occ_port_pool_get)(struct devlink_port *devlink_port,
+				    unsigned int sb_index, u16 pool_index,
+				    u32 *p_cur, u32 *p_max);
+	int (*sb_occ_tc_port_bind_get)(struct devlink_port *devlink_port,
+				       unsigned int sb_index,
+				       u16 tc_index,
+				       enum devlink_sb_pool_type pool_type,
+				       u32 *p_cur, u32 *p_max);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 9c1aa57..ba0073b 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -53,6 +53,10 @@ enum devlink_command {
 	DEVLINK_CMD_SB_TC_POOL_BIND_NEW,
 	DEVLINK_CMD_SB_TC_POOL_BIND_DEL,
 
+	/* Shared buffer occupancy monitoring commands */
+	DEVLINK_CMD_SB_OCC_SNAPSHOT,
+	DEVLINK_CMD_SB_OCC_MAX_CLEAR,
+
 	/* add new commands above here */
 
 	__DEVLINK_CMD_MAX,
@@ -119,6 +123,8 @@ enum devlink_attr {
 	DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE,	/* u8 */
 	DEVLINK_ATTR_SB_THRESHOLD,		/* u32 */
 	DEVLINK_ATTR_SB_TC_INDEX,		/* u16 */
+	DEVLINK_ATTR_SB_OCC_CUR,		/* u32 */
+	DEVLINK_ATTR_SB_OCC_MAX,		/* u32 */
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index aa0b9e1..933e8d4 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -280,6 +280,10 @@ devlink_sb_tc_index_get_from_info(struct devlink_sb *devlink_sb,
 #define DEVLINK_NL_FLAG_NEED_DEVLINK	BIT(0)
 #define DEVLINK_NL_FLAG_NEED_PORT	BIT(1)
 #define DEVLINK_NL_FLAG_NEED_SB		BIT(2)
+#define DEVLINK_NL_FLAG_LOCK_PORTS	BIT(3)
+	/* port is not needed but we need to ensure they don't
+	 * change in the middle of command
+	 */
 
 static int devlink_nl_pre_doit(const struct genl_ops *ops,
 			       struct sk_buff *skb, struct genl_info *info)
@@ -306,6 +310,9 @@ static int devlink_nl_pre_doit(const struct genl_ops *ops,
 		}
 		info->user_ptr[0] = devlink_port;
 	}
+	if (ops->internal_flags & DEVLINK_NL_FLAG_LOCK_PORTS) {
+		mutex_lock(&devlink_port_mutex);
+	}
 	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_SB) {
 		struct devlink_sb *devlink_sb;
 
@@ -324,7 +331,8 @@ static int devlink_nl_pre_doit(const struct genl_ops *ops,
 static void devlink_nl_post_doit(const struct genl_ops *ops,
 				 struct sk_buff *skb, struct genl_info *info)
 {
-	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_PORT)
+	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_PORT ||
+	    ops->internal_flags & DEVLINK_NL_FLAG_LOCK_PORTS)
 		mutex_unlock(&devlink_port_mutex);
 	mutex_unlock(&devlink_mutex);
 }
@@ -942,12 +950,13 @@ static int devlink_nl_sb_port_pool_fill(struct sk_buff *msg,
 					enum devlink_command cmd,
 					u32 portid, u32 seq, int flags)
 {
+	const struct devlink_ops *ops = devlink->ops;
 	u32 threshold;
 	void *hdr;
 	int err;
 
-	err = devlink->ops->sb_port_pool_get(devlink_port, devlink_sb->index,
-					     pool_index, &threshold);
+	err = ops->sb_port_pool_get(devlink_port, devlink_sb->index,
+				    pool_index, &threshold);
 	if (err)
 		return err;
 
@@ -966,6 +975,22 @@ static int devlink_nl_sb_port_pool_fill(struct sk_buff *msg,
 	if (nla_put_u32(msg, DEVLINK_ATTR_SB_THRESHOLD, threshold))
 		goto nla_put_failure;
 
+	if (ops->sb_occ_port_pool_get) {
+		u32 cur;
+		u32 max;
+
+		err = ops->sb_occ_port_pool_get(devlink_port, devlink_sb->index,
+						pool_index, &cur, &max);
+		if (err && err != -EOPNOTSUPP)
+			return err;
+		if (!err) {
+			if (nla_put_u32(msg, DEVLINK_ATTR_SB_OCC_CUR, cur))
+				goto nla_put_failure;
+			if (nla_put_u32(msg, DEVLINK_ATTR_SB_OCC_MAX, max))
+				goto nla_put_failure;
+		}
+	}
+
 	genlmsg_end(msg, hdr);
 	return 0;
 
@@ -1114,14 +1139,15 @@ devlink_nl_sb_tc_pool_bind_fill(struct sk_buff *msg, struct devlink *devlink,
 				enum devlink_command cmd,
 				u32 portid, u32 seq, int flags)
 {
+	const struct devlink_ops *ops = devlink->ops;
 	u16 pool_index;
 	u32 threshold;
 	void *hdr;
 	int err;
 
-	err = devlink->ops->sb_tc_pool_bind_get(devlink_port, devlink_sb->index,
-						tc_index, pool_type,
-						&pool_index, &threshold);
+	err = ops->sb_tc_pool_bind_get(devlink_port, devlink_sb->index,
+				       tc_index, pool_type,
+				       &pool_index, &threshold);
 	if (err)
 		return err;
 
@@ -1144,6 +1170,24 @@ devlink_nl_sb_tc_pool_bind_fill(struct sk_buff *msg, struct devlink *devlink,
 	if (nla_put_u32(msg, DEVLINK_ATTR_SB_THRESHOLD, threshold))
 		goto nla_put_failure;
 
+	if (ops->sb_occ_tc_port_bind_get) {
+		u32 cur;
+		u32 max;
+
+		err = ops->sb_occ_tc_port_bind_get(devlink_port,
+						   devlink_sb->index,
+						   tc_index, pool_type,
+						   &cur, &max);
+		if (err && err != -EOPNOTSUPP)
+			return err;
+		if (!err) {
+			if (nla_put_u32(msg, DEVLINK_ATTR_SB_OCC_CUR, cur))
+				goto nla_put_failure;
+			if (nla_put_u32(msg, DEVLINK_ATTR_SB_OCC_MAX, max))
+				goto nla_put_failure;
+		}
+	}
+
 	genlmsg_end(msg, hdr);
 	return 0;
 
@@ -1326,6 +1370,30 @@ static int devlink_nl_cmd_sb_tc_pool_bind_set_doit(struct sk_buff *skb,
 					   pool_index, threshold);
 }
 
+static int devlink_nl_cmd_sb_occ_snapshot_doit(struct sk_buff *skb,
+					       struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	const struct devlink_ops *ops = devlink->ops;
+
+	if (ops && ops->sb_occ_snapshot)
+		return ops->sb_occ_snapshot(devlink, devlink_sb->index);
+	return -EOPNOTSUPP;
+}
+
+static int devlink_nl_cmd_sb_occ_max_clear_doit(struct sk_buff *skb,
+						struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	const struct devlink_ops *ops = devlink->ops;
+
+	if (ops && ops->sb_occ_max_clear)
+		return ops->sb_occ_max_clear(devlink, devlink_sb->index);
+	return -EOPNOTSUPP;
+}
+
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_BUS_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DEV_NAME] = { .type = NLA_NUL_STRING },
@@ -1439,6 +1507,24 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.internal_flags = DEVLINK_NL_FLAG_NEED_PORT |
 				  DEVLINK_NL_FLAG_NEED_SB,
 	},
+	{
+		.cmd = DEVLINK_CMD_SB_OCC_SNAPSHOT,
+		.doit = devlink_nl_cmd_sb_occ_snapshot_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK |
+				  DEVLINK_NL_FLAG_NEED_SB |
+				  DEVLINK_NL_FLAG_LOCK_PORTS,
+	},
+	{
+		.cmd = DEVLINK_CMD_SB_OCC_MAX_CLEAR,
+		.doit = devlink_nl_cmd_sb_occ_max_clear_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK |
+				  DEVLINK_NL_FLAG_NEED_SB |
+				  DEVLINK_NL_FLAG_LOCK_PORTS,
+	},
 };
 
 /**
-- 
2.5.5
