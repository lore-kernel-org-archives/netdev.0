From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v3 01/10] devlink: Add permanent config parameter get/set operations
Date: Tue, 24 Oct 2017 16:12:33 -0400
Message-ID: <1508875962-39233-2-git-send-email-steven.lin1@broadcom.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com, yuvalm@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:58354 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751576AbdJXUNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:13:46 -0400
In-Reply-To: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for permanent config parameter get/set commands. Used
for persistent device configuration parameters.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/net/devlink.h        |   6 +
 include/uapi/linux/devlink.h |  18 +++
 net/core/devlink.c           | 295 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 319 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index b9654e1..eb86031 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -270,6 +270,12 @@ struct devlink_ops {
 	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
 	int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
 	int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
+	int (*perm_config_get)(struct devlink *devlink,
+			       enum devlink_perm_config_param param, u8 type,
+			       void *value);
+	int (*perm_config_set)(struct devlink *devlink,
+			       enum devlink_perm_config_param param, u8 type,
+			       void *value, u8 *restart_reqd);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 0cbca96..28ea961 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -70,6 +70,10 @@ enum devlink_command {
 	DEVLINK_CMD_DPIPE_HEADERS_GET,
 	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
 
+	/* Permanent device config get/set */
+	DEVLINK_CMD_PERM_CONFIG_GET,
+	DEVLINK_CMD_PERM_CONFIG_SET,
+
 	/* add new commands above here */
 	__DEVLINK_CMD_MAX,
 	DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
@@ -202,6 +206,14 @@ enum devlink_attr {
 
 	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
 
+	/* Permanent Configuration Parameters */
+	DEVLINK_ATTR_PERM_CONFIGS,			/* nested */
+	DEVLINK_ATTR_PERM_CONFIG,			/* nested */
+	DEVLINK_ATTR_PERM_CONFIG_PARAMETER,		/* u32 */
+	DEVLINK_ATTR_PERM_CONFIG_TYPE,			/* u8 */
+	DEVLINK_ATTR_PERM_CONFIG_VALUE,			/* dynamic */
+	DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED,	/* u8 */
+
 	/* add new attributes above here, update the policy in devlink.c */
 
 	__DEVLINK_ATTR_MAX,
@@ -244,4 +256,10 @@ enum devlink_dpipe_header_id {
 	DEVLINK_DPIPE_HEADER_IPV6,
 };
 
+/* Permanent config parameters */
+enum devlink_perm_config_param {
+	__DEVLINK_PERM_CONFIG_MAX,
+	DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
+};
+
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 7d430c1..4deb4da 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1566,6 +1566,285 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 	return 0;
 }
 
+static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
+
+static const u8 devlink_perm_cfg_param_types[DEVLINK_PERM_CONFIG_MAX + 1] = {
+};
+
+static int devlink_nl_single_param_get(struct sk_buff *msg,
+				       struct devlink *devlink,
+				       u32 param, u8 type)
+{
+	const struct devlink_ops *ops = devlink->ops;
+	struct nlattr *param_attr;
+	void *value;
+	u32 val;
+	int err;
+
+	/* Allocate buffer for parameter value */
+	switch (type) {
+	case NLA_U8:
+		value = kmalloc(sizeof(u8), GFP_KERNEL);
+		break;
+	case NLA_U16:
+		value = kmalloc(sizeof(u16), GFP_KERNEL);
+		break;
+	case NLA_U32:
+		value = kmalloc(sizeof(u32), GFP_KERNEL);
+		break;
+	default:
+		return -EINVAL; /* Unsupported Type */
+	}
+
+	if (!value)
+		return -ENOMEM;
+
+	err = ops->perm_config_get(devlink, param, type, value);
+	if (err)
+		return err;
+
+	param_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
+	if (!param_attr)
+		goto nonest_err;
+
+	if (nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_PARAMETER, param) ||
+	    nla_put_u8(msg, DEVLINK_ATTR_PERM_CONFIG_TYPE, type))
+		goto nest_err;
+
+	switch (type) {
+	case NLA_U8:
+		val = *((u8 *)value);
+		if (nla_put_u8(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
+			goto nest_err;
+		break;
+	case NLA_U16:
+		val = *((u16 *)value);
+		if (nla_put_u16(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
+			goto nest_err;
+		break;
+	case NLA_U32:
+		val = *((u32 *)value);
+		if (nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
+			goto nest_err;
+		break;
+	}
+	nla_nest_end(msg, param_attr);
+
+	kfree(value);
+
+	return err;
+
+nest_err:
+	nla_nest_cancel(msg, param_attr);
+nonest_err:
+	kfree(value);
+
+	return -EMSGSIZE;
+}
+
+static int devlink_nl_config_get_fill(struct sk_buff *msg,
+				      struct devlink *devlink,
+				      enum devlink_command cmd,
+				      struct genl_info *info)
+{
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
+	struct nlattr *cfgparam_attr;
+	struct nlattr *attr;
+	void *hdr;
+	u32 param;
+	int err;
+	int rem;
+	u8 type;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &devlink_nl_family, 0, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	err = devlink_nl_put_handle(msg, devlink);
+	if (err)
+		goto nla_put_failure;
+
+	if (!info->attrs[DEVLINK_ATTR_PERM_CONFIGS]) {
+		err = -EINVAL;
+		goto nla_put_failure;
+	}
+
+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIGS);
+
+	nla_for_each_nested(attr, info->attrs[DEVLINK_ATTR_PERM_CONFIGS],
+			    rem) {
+		err = nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
+				       devlink_nl_policy, NULL);
+		if (err)
+			goto nla_nest_failure;
+		if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] ||
+		    !tb[DEVLINK_ATTR_PERM_CONFIG_TYPE])
+			continue;
+
+		param = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);
+		type = nla_get_u8(tb[DEVLINK_ATTR_PERM_CONFIG_TYPE]);
+		if (param > DEVLINK_PERM_CONFIG_MAX ||
+		    type > NLA_TYPE_MAX) {
+			continue;
+		}
+		/* Note if single_param_get fails, that param won't be in
+		 * response msg, so caller will know which param(s) failed to
+		 * get.
+		 */
+		devlink_nl_single_param_get(msg, devlink, param, type);
+	}
+
+	nla_nest_end(msg, cfgparam_attr);
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_nest_failure:
+	nla_nest_cancel(msg, cfgparam_attr);
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return err;
+}
+
+static int devlink_nl_cmd_perm_config_get_doit(struct sk_buff *skb,
+					       struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct sk_buff *msg;
+	int err;
+
+	if (!devlink->ops || !devlink->ops->perm_config_get)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_config_get_fill(msg, devlink,
+					 DEVLINK_CMD_PERM_CONFIG_GET, info);
+
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int devlink_nl_single_param_set(struct sk_buff *msg,
+				       struct devlink *devlink,
+				       u32 param, u8 type, void *value)
+{
+	const struct devlink_ops *ops = devlink->ops;
+	struct nlattr *cfgparam_attr;
+	u8 need_restart;
+	int err;
+
+	/* Now set parameter */
+	err = ops->perm_config_set(devlink, param, type, value, &need_restart);
+	if (err)
+		return err;
+
+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
+	/* Update restart reqd - if any param needs restart, should be set */
+	if (need_restart) {
+		err = nla_put_u8(msg,
+				 DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED, 1);
+		if (err)
+			goto nest_fail;
+	}
+
+	/* Since set was successful, write attr back to msg */
+	err = nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_PARAMETER, param);
+	if (err)
+		goto nest_fail;
+
+	nla_nest_end(msg, cfgparam_attr);
+
+	return 0;
+
+nest_fail:
+	nla_nest_cancel(msg, cfgparam_attr);
+	return err;
+}
+
+static int devlink_nl_cmd_perm_config_set_doit(struct sk_buff *skb,
+					       struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
+	struct nlattr *cfgparam_attr;
+	struct sk_buff *msg;
+	struct nlattr *attr;
+	void *value;
+	void *hdr;
+	u32 param;
+	u8 type;
+	int rem;
+	int err;
+
+	if (!devlink->ops || !devlink->ops->perm_config_get ||
+	    !devlink->ops->perm_config_set)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &devlink_nl_family, 0, DEVLINK_CMD_PERM_CONFIG_SET);
+	if (!hdr) {
+		err = -EMSGSIZE;
+		goto nla_msg_failure;
+	}
+
+	err = devlink_nl_put_handle(msg, devlink);
+	if (err)
+		goto nla_put_failure;
+
+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIGS);
+
+	nla_for_each_nested(attr, info->attrs[DEVLINK_ATTR_PERM_CONFIGS], rem) {
+		err = nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
+				       devlink_nl_policy, NULL);
+		if (err)
+			goto nla_nest_failure;
+
+		if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] ||
+		    !tb[DEVLINK_ATTR_PERM_CONFIG_TYPE] ||
+		    !tb[DEVLINK_ATTR_PERM_CONFIG_VALUE])
+			continue;
+
+		param = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);
+		type = nla_get_u8(tb[DEVLINK_ATTR_PERM_CONFIG_TYPE]);
+		if (param > DEVLINK_PERM_CONFIG_MAX ||
+		    type > NLA_TYPE_MAX) {
+			continue;
+		}
+
+		value = nla_data(tb[DEVLINK_ATTR_PERM_CONFIG_VALUE]);
+
+		/* Note if single_param_set fails, that param won't be in
+		 * response msg, so caller will know which param(s) failed to
+		 * set.
+		 */
+		devlink_nl_single_param_set(msg, devlink, param, type, value);
+	}
+
+	nla_nest_end(msg, cfgparam_attr);
+
+	genlmsg_end(msg, hdr);
+	return genlmsg_reply(msg, info);
+
+nla_nest_failure:
+	nla_nest_cancel(msg, cfgparam_attr);
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+nla_msg_failure:
+	return err;
+}
+
 int devlink_dpipe_match_put(struct sk_buff *skb,
 			    struct devlink_dpipe_match *match)
 {
@@ -2291,6 +2570,8 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CONFIG_TYPE] = { .type = NLA_U8 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
@@ -2451,6 +2732,20 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
+	{
+		.cmd = DEVLINK_CMD_PERM_CONFIG_GET,
+		.doit = devlink_nl_cmd_perm_config_get_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
+	{
+		.cmd = DEVLINK_CMD_PERM_CONFIG_SET,
+		.doit = devlink_nl_cmd_perm_config_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
 };
 
 static struct genl_family devlink_nl_family __ro_after_init = {
-- 
2.7.4
