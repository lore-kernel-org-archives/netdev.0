From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH 1/7] devlink: Add permanent config parameter get/set operations
Date: Tue, 17 Oct 2017 16:44:23 -0400
Message-ID: <1508273069-40461-2-git-send-email-steven.lin1@broadcom.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:49918 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754553AbdJQUop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:44:45 -0400
In-Reply-To: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for permanent config parameter get/set commands. Used
for parameters held in NVRAM, persistent device configuration.
The config_get() and config_set() operations operate as expected, but
note that the driver implementation of the config_set() operation can
indicate whether a restart is necessary for the setting to take
effect.  This indication of a necessary restart is passed via the
DEVLINK_ATTR_PERM_CFG_RESTART_REQUIRED attribute.

First set of parameters defined are PCI SR-IOV and per-VF
configuration:

DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED: Enable SR-IOV capability.
DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF: Maximum number of VFs per PF, in
SR-IOV mode.
DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT: Maximum number of
MSI-X vectors assigned per PF.
DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF: Number of MSI-X vectors
allocated per VF.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/net/devlink.h        |   4 +
 include/uapi/linux/devlink.h |  20 ++++
 net/core/devlink.c           | 266 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 290 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index b9654e1..952966c 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -270,6 +270,10 @@ struct devlink_ops {
 	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
 	int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
 	int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
+	int (*config_get)(struct devlink *devlink, enum devlink_attr attr,
+			  u32 *value);
+	int (*config_set)(struct devlink *devlink, enum devlink_attr attr,
+			  u32 value, u8 *restart_reqd);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 0cbca96..34de44d 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -70,6 +70,9 @@ enum devlink_command {
 	DEVLINK_CMD_DPIPE_HEADERS_GET,
 	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
 
+	DEVLINK_CMD_CONFIG_GET,
+	DEVLINK_CMD_CONFIG_SET,
+
 	/* add new commands above here */
 	__DEVLINK_CMD_MAX,
 	DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
@@ -202,6 +205,23 @@ enum devlink_attr {
 
 	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
 
+	/* Permanent Configuration Parameters */
+	DEVLINK_ATTR_PERM_CFG,				/* nested */
+
+	/* When config doesn't take effect until next reboot (config
+	 * just changed NVM which isn't read until boot, for example),
+	 * this attribute should be set by the driver.
+	 */
+	DEVLINK_ATTR_PERM_CFG_RESTART_REQUIRED,		/* u8 */
+	DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED,		/* u8 */
+	DEVLINK_ATTR_PERM_CFG_FIRST = DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED,
+	DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF,		/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF,	/* u32 */
+
+	/* Add new permanent config parameters above here */
+	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF,
+
 	/* add new attributes above here, update the policy in devlink.c */
 
 	__DEVLINK_ATTR_MAX,
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 7d430c1..427a65e 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1566,6 +1566,254 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 	return 0;
 }
 
+static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
+
+static int devlink_nl_sing_param_get(struct sk_buff *msg,
+				     struct devlink *devlink,
+				     enum devlink_attr attr)
+{
+	struct nla_policy policy;
+	u32 value;
+	int err;
+	const struct devlink_ops *ops = devlink->ops;
+
+	policy = devlink_nl_policy[attr];
+	err = ops->config_get(devlink, attr, &value);
+	if (err)
+		return err;
+
+	switch (policy.type) {
+	case NLA_U8:
+		err = nla_put_u8(msg, attr, value);
+		break;
+	case NLA_U16:
+		err = nla_put_u16(msg, attr, value);
+		break;
+	case NLA_U32:
+		err = nla_put_u32(msg, attr, value);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int devlink_nl_config_get_fill(struct sk_buff *msg,
+				      struct devlink *devlink,
+				      enum devlink_command cmd,
+				      struct genl_info *info)
+{
+	const struct devlink_ops *ops = devlink->ops;
+	void *hdr;
+	int err;
+	enum devlink_attr attr;
+	int param_count = 0;
+	struct nlattr *cfgparam_attr;
+
+	if (!ops->config_get)
+		return -EOPNOTSUPP;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &devlink_nl_family, 0, cmd);
+	if (!hdr) {
+		err = -EMSGSIZE;
+		goto nla_msg_failure;
+	}
+
+	err = devlink_nl_put_handle(msg, devlink);
+	if (err)
+		goto nla_put_failure;
+
+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CFG);
+
+	/* Were specific parameter(s) requested? */
+	for (attr = DEVLINK_ATTR_PERM_CFG_FIRST;
+	     attr <= DEVLINK_ATTR_PERM_CFG_LAST; attr++) {
+		if (info->attrs[attr]) {
+			err = devlink_nl_sing_param_get(msg, devlink, attr);
+			if (err)
+				goto nla_nest_failure;
+			param_count++;
+			break;
+		}
+	}
+
+	if (param_count == 0) {
+		/* return all parameter values */
+		for (attr = DEVLINK_ATTR_PERM_CFG_FIRST;
+		     attr <= DEVLINK_ATTR_PERM_CFG_LAST; attr++) {
+			err = devlink_nl_sing_param_get(msg, devlink, attr);
+			if (err)
+				goto nla_nest_failure;
+		}
+	}
+	nla_nest_end(msg, cfgparam_attr);
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_nest_failure:
+	nla_nest_cancel(msg, cfgparam_attr);
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+nla_msg_failure:
+	return err;
+}
+
+static int devlink_nl_cmd_config_get_doit(struct sk_buff *skb,
+					  struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct sk_buff *msg;
+	int err;
+
+	if (!devlink->ops)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_config_get_fill(msg, devlink, DEVLINK_CMD_CONFIG_GET,
+					 info);
+
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int devlink_nl_sing_param_set(struct sk_buff *msg,
+				     struct devlink *devlink,
+				     struct genl_info *info,
+				     enum devlink_attr attr,
+				     u8 *restart_reqd)
+{
+	struct nla_policy policy;
+	u32 orig_value;
+	u32 new_value;
+	u8 need_restart;
+	u8 *val8;
+	u16 *val16;
+	u32 *val32;
+	int err;
+	const struct devlink_ops *ops = devlink->ops;
+
+	policy = devlink_nl_policy[attr];
+
+	/* First get current value of parameter */
+	err = ops->config_get(devlink, attr, &orig_value);
+	if (err)
+		return err;
+
+	/* Now set parameter */
+	switch (policy.type) {
+	case NLA_U8:
+		val8 = nla_data(info->attrs[attr]);
+		new_value = *val8;
+		break;
+	case NLA_U16:
+		val16 = nla_data(info->attrs[attr]);
+		new_value = *val16;
+		break;
+	case NLA_U32:
+		val32 = nla_data(info->attrs[attr]);
+		new_value = *val32;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	err = ops->config_set(devlink, attr, new_value, &need_restart);
+	if (err)
+		return err;
+
+	/* Update restart reqd - if any param needs restart, should be set */
+	*restart_reqd |= need_restart;
+
+	/* Since set was successful, write attr back to msg with orig val */
+	switch (policy.type) {
+	case NLA_U8:
+		err = nla_put_u8(msg, attr, orig_value);
+		break;
+	case NLA_U16:
+		err = nla_put_u16(msg, attr, orig_value);
+		break;
+	case NLA_U32:
+		err = nla_put_u32(msg, attr, orig_value);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int devlink_nl_cmd_config_set_doit(struct sk_buff *skb,
+					  struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct sk_buff *msg;
+	void *hdr;
+	enum devlink_attr attr;
+	int err;
+	u8 restart_reqd = 0;
+	struct nlattr *cfgparam_attr;
+
+	if (!devlink->ops || !devlink->ops->config_set)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &devlink_nl_family, 0, DEVLINK_CMD_CONFIG_SET);
+	if (!hdr) {
+		err = -EMSGSIZE;
+		goto nla_msg_failure;
+	}
+
+	err = devlink_nl_put_handle(msg, devlink);
+	if (err)
+		goto nla_put_failure;
+
+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CFG);
+
+	/* Find attribute(s) being set */
+	for (attr = DEVLINK_ATTR_PERM_CFG_FIRST;
+	     attr <= DEVLINK_ATTR_PERM_CFG_LAST; attr++) {
+		if (info->attrs[attr]) {
+			err = devlink_nl_sing_param_set(msg, devlink, info,
+							attr, &restart_reqd);
+			if (err)
+				goto nla_nest_failure;
+		}
+	}
+
+	nla_nest_end(msg, cfgparam_attr);
+
+	if (restart_reqd) {
+		err = nla_put_u8(msg, DEVLINK_ATTR_PERM_CFG_RESTART_REQUIRED,
+				 restart_reqd);
+		if (err)
+			goto nla_put_failure;
+	}
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
@@ -2291,6 +2539,10 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF] = { .type = NLA_U32 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
@@ -2451,6 +2703,20 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
+	{
+		.cmd = DEVLINK_CMD_CONFIG_GET,
+		.doit = devlink_nl_cmd_config_get_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
+	{
+		.cmd = DEVLINK_CMD_CONFIG_SET,
+		.doit = devlink_nl_cmd_config_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
 };
 
 static struct genl_family devlink_nl_family __ro_after_init = {
-- 
2.7.4
