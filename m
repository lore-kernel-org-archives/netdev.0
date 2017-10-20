From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
 get/set operations
Date: Fri, 20 Oct 2017 16:39:48 +0200
Message-ID: <20171020143948.GC1994@nanopsycho.orion>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:46367 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752084AbdJTOju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 10:39:50 -0400
Received: by mail-wr0-f196.google.com with SMTP id l1so11556919wrc.3
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 07:39:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 19, 2017 at 09:17:05PM CEST, steven.lin1@broadcom.com wrote:
>Add support for permanent config parameter get/set commands. Used
>for parameters held in NVRAM, persistent device configuration.
>
>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>---
> include/net/devlink.h        |   3 +
> include/uapi/linux/devlink.h |  11 ++
> net/core/devlink.c           | 234 +++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 248 insertions(+)
>
>diff --git a/include/net/devlink.h b/include/net/devlink.h
>index b9654e1..bd64623 100644
>--- a/include/net/devlink.h
>+++ b/include/net/devlink.h
>@@ -270,6 +270,9 @@ struct devlink_ops {
> 	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
> 	int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
> 	int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
>+	int (*perm_config_get)(struct devlink *devlink, u32 param, u32 *value);
>+	int (*perm_config_set)(struct devlink *devlink, u32 param, u32 value,

Please use enum instead of "u32 param". Also, what would happen if the
value is >u32, like string for example? I believe we need to take it into
the consideration for the UAPI sake.


[...]


>+
>+static int devlink_nl_single_param_set(struct sk_buff *msg,
>+				       struct devlink *devlink,
>+				       u32 param, u32 value)
>+{
>+	u32 orig_value;
>+	u8 need_restart;
>+	int err;
>+	const struct devlink_ops *ops = devlink->ops;
>+	struct nlattr *cfgparam_attr;

Reverse christmas tree please (this applies to all functions)


>+
>+	/* First get current value of parameter */
>+	err = ops->perm_config_get(devlink, param, &orig_value);

I'm missing why this is needed.


>+	if (err)
>+		return err;
>+
>+	/* Now set parameter */
>+	err = ops->perm_config_set(devlink, param, value, &need_restart);
>+	if (err)
>+		return err;
>+
>+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
>+	/* Update restart reqd - if any param needs restart, should be set */
>+	if (need_restart)
>+		err = nla_put_u8(msg,
>+				 DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED, 1);
>+
>+	/* Since set was successful, write attr back to msg with orig val */
>+	err = nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_PARAMETER, param);
>+	err = nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, orig_value);

Why to write it back?


>+
>+	nla_nest_end(msg, cfgparam_attr);
>+
>+	return 0;
>+}
>+
>+static int devlink_nl_cmd_perm_config_set_doit(struct sk_buff *skb,
>+					       struct genl_info *info)
>+{
>+	struct devlink *devlink = info->user_ptr[0];
>+	struct sk_buff *msg;
>+	void *hdr;
>+	struct nlattr *attr;
>+	int rem;
>+	int err;
>+	u8 restart_reqd = 0;
>+	struct nlattr *cfgparam_attr;
>+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
>+	u32 param;
>+	u32 value;
>+
>+	if (!devlink->ops || !devlink->ops->perm_config_get ||
>+	    !devlink->ops->perm_config_set)
>+		return -EOPNOTSUPP;
>+
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>+	if (!msg)
>+		return -ENOMEM;
>+
>+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
>+			  &devlink_nl_family, 0, DEVLINK_CMD_PERM_CONFIG_SET);
>+	if (!hdr) {
>+		err = -EMSGSIZE;
>+		goto nla_msg_failure;
>+	}
>+
>+	err = devlink_nl_put_handle(msg, devlink);
>+	if (err)
>+		goto nla_put_failure;
>+
>+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIGS);
>+
>+	nla_for_each_nested(attr, info->attrs[DEVLINK_ATTR_PERM_CONFIGS], rem) {
>+		err = nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
>+				       devlink_nl_policy, NULL);
>+		if (err)
>+			goto nla_nest_failure;
>+
>+		if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] ||
>+		    !tb[DEVLINK_ATTR_PERM_CONFIG_VALUE])
>+			continue;
>+
>+		param = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);

You should check it the "param" value is withing the enum boundary.


>+		value = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_VALUE]);
>+		err = devlink_nl_single_param_set(msg, devlink, param,
>+						  value);
>+		if (err)
>+			goto nla_nest_failure;

Wouldn't it make sense to rollback to old values if any of the config
parameters set would fail?


>+	}
>+
>+	nla_nest_end(msg, cfgparam_attr);
>+
>+	if (restart_reqd) {
>+		err = nla_put_u8(msg, DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED,
>+				 restart_reqd);
>+		if (err)
>+			goto nla_put_failure;
>+	}
>+
>+	genlmsg_end(msg, hdr);
>+	return genlmsg_reply(msg, info);
>+
>+nla_nest_failure:
>+	nla_nest_cancel(msg, cfgparam_attr);
>+nla_put_failure:
>+	genlmsg_cancel(msg, hdr);
>+nla_msg_failure:
>+	return err;
>+}
>+
> int devlink_dpipe_match_put(struct sk_buff *skb,
> 			    struct devlink_dpipe_match *match)
> {
>@@ -2291,6 +2509,8 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
> 	[DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = { .type = NLA_U8 },
> 	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
> 	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_PERM_CONFIG_VALUE] = { .type = NLA_U32 },
> };
> 
> static const struct genl_ops devlink_nl_ops[] = {
>@@ -2451,6 +2671,20 @@ static const struct genl_ops devlink_nl_ops[] = {
> 		.flags = GENL_ADMIN_PERM,
> 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
> 	},
>+	{
>+		.cmd = DEVLINK_CMD_PERM_CONFIG_GET,
>+		.doit = devlink_nl_cmd_perm_config_get_doit,
>+		.policy = devlink_nl_policy,
>+		.flags = GENL_ADMIN_PERM,
>+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>+	},
>+	{
>+		.cmd = DEVLINK_CMD_PERM_CONFIG_SET,
>+		.doit = devlink_nl_cmd_perm_config_set_doit,
>+		.policy = devlink_nl_policy,
>+		.flags = GENL_ADMIN_PERM,
>+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>+	},
> };
> 
> static struct genl_family devlink_nl_family __ro_after_init = {
>-- 
>2.7.4
>
