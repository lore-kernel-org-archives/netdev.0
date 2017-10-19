From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
 get/set operations
Date: Thu, 19 Oct 2017 20:21:29 +0000
Message-ID: <AM0PR0502MB3683FB1536D1A204E5D1369EBF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10059.outbound.protection.outlook.com ([40.107.1.59]:48688
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753869AbdJSUVf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 16:21:35 -0400
In-Reply-To: <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
> get/set operations
>=20
> Add support for permanent config parameter get/set commands. Used
> for parameters held in NVRAM, persistent device configuration.

Given some of the attributes aren't Boolean, what about an API that
allows the user to learn of supported values per option?
Otherwise only way for configuring some of them would be trial & error.

>=20
> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
> Acked-by: Andy Gospodarek <gospo@broadcom.com>
> ---
>  include/net/devlink.h        |   3 +
>  include/uapi/linux/devlink.h |  11 ++
>  net/core/devlink.c           | 234
> +++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 248 insertions(+)
>=20
> diff --git a/include/net/devlink.h b/include/net/devlink.h
> index b9654e1..bd64623 100644
> --- a/include/net/devlink.h
> +++ b/include/net/devlink.h
> @@ -270,6 +270,9 @@ struct devlink_ops {
>  	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8
> inline_mode);
>  	int (*eswitch_encap_mode_get)(struct devlink *devlink, u8
> *p_encap_mode);
>  	int (*eswitch_encap_mode_set)(struct devlink *devlink, u8
> encap_mode);
> +	int (*perm_config_get)(struct devlink *devlink, u32 param, u32
> *value);
> +	int (*perm_config_set)(struct devlink *devlink, u32 param, u32
> value,
> +			       u8 *restart_reqd);
>  };
>=20
>  static inline void *devlink_priv(struct devlink *devlink)
> diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
> index 0cbca96..47cc584 100644
> --- a/include/uapi/linux/devlink.h
> +++ b/include/uapi/linux/devlink.h
> @@ -70,6 +70,10 @@ enum devlink_command {
>  	DEVLINK_CMD_DPIPE_HEADERS_GET,
>  	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
>=20
> +	/* Permanent (NVRAM) device config get/set */
> +	DEVLINK_CMD_PERM_CONFIG_GET,
> +	DEVLINK_CMD_PERM_CONFIG_SET,
> +
>  	/* add new commands above here */
>  	__DEVLINK_CMD_MAX,
>  	DEVLINK_CMD_MAX =3D __DEVLINK_CMD_MAX - 1
> @@ -202,6 +206,13 @@ enum devlink_attr {
>=20
>  	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
>=20
> +	/* Permanent Configuration Parameters */
> +	DEVLINK_ATTR_PERM_CONFIGS,			/* nested */
> +	DEVLINK_ATTR_PERM_CONFIG,			/* nested */
> +	DEVLINK_ATTR_PERM_CONFIG_PARAMETER,		/* u32 */
> +	DEVLINK_ATTR_PERM_CONFIG_VALUE,			/*
> u32 */
> +	DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED,	/* u8 */
> +
>  	/* add new attributes above here, update the policy in devlink.c */
>=20
>  	__DEVLINK_ATTR_MAX,
> diff --git a/net/core/devlink.c b/net/core/devlink.c
> index 7d430c1..c2cc7c6 100644
> --- a/net/core/devlink.c
> +++ b/net/core/devlink.c
> @@ -1566,6 +1566,224 @@ static int
> devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
>  	return 0;
>  }
>=20
> +static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
> +
> +static int devlink_nl_single_param_get(struct sk_buff *msg,
> +				       struct devlink *devlink,
> +				       uint32_t param)
> +{
> +	u32 value;
> +	int err;
> +	const struct devlink_ops *ops =3D devlink->ops;
> +	struct nlattr *param_attr;
> +
> +	err =3D ops->perm_config_get(devlink, param, &value);
> +	if (err)
> +		return err;
> +
> +	param_attr =3D nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
> +	nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_PARAMETER,
> param);
> +	nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, value);
> +	nla_nest_end(msg, param_attr);
> +
> +	return 0;
> +}
> +
> +static int devlink_nl_config_get_fill(struct sk_buff *msg,
> +				      struct devlink *devlink,
> +				      enum devlink_command cmd,
> +				      struct genl_info *info)
> +{
> +	void *hdr;
> +	int err;
> +	struct nlattr *attr;
> +	int param_count =3D 0;
> +	struct nlattr *cfgparam_attr;
> +	int rem;
> +	struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
> +	u32 param;
> +
> +	hdr =3D genlmsg_put(msg, info->snd_portid, info->snd_seq,
> +			  &devlink_nl_family, 0, cmd);
> +	if (!hdr) {
> +		err =3D -EMSGSIZE;
> +		goto nla_msg_failure;
> +	}
> +
> +	err =3D devlink_nl_put_handle(msg, devlink);
> +	if (err)
> +		goto nla_put_failure;
> +
> +	if (!info->attrs[DEVLINK_ATTR_PERM_CONFIGS]) {
> +		/* No configuration parameters */
> +		goto nla_put_failure;
> +	}
> +
> +	cfgparam_attr =3D nla_nest_start(msg,
> DEVLINK_ATTR_PERM_CONFIGS);
> +
> +	nla_for_each_nested(attr, info-
> >attrs[DEVLINK_ATTR_PERM_CONFIGS],
> +			    rem) {
Isn't it possible that a response for a single request for multiple ATTRs
wouldn't fit in a single message?

> +		err =3D nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
> +				       devlink_nl_policy, NULL);
> +		if (err)
> +			goto nla_nest_failure;
> +		if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER])
> +			continue;
> +
> +		param =3D
> nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);
> +		err =3D devlink_nl_single_param_get(msg, devlink, param);
> +		if (err)
> +			goto nla_nest_failure;
> +		param_count++;

Looks like an unused parameter

> +	}
> +
> +	nla_nest_end(msg, cfgparam_attr);
> +
> +	genlmsg_end(msg, hdr);
> +	return 0;
> +
> +nla_nest_failure:
> +	nla_nest_cancel(msg, cfgparam_attr);
> +nla_put_failure:
> +	genlmsg_cancel(msg, hdr);
> +nla_msg_failure:
> +	return err;
> +}
> +
> +static int devlink_nl_cmd_perm_config_get_doit(struct sk_buff *skb,
> +					       struct genl_info *info)
> +{
> +	struct devlink *devlink =3D info->user_ptr[0];
> +	struct sk_buff *msg;
> +	int err;
> +
> +	if (!devlink->ops || !devlink->ops->perm_config_get)
> +		return -EOPNOTSUPP;
> +
> +	msg =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (!msg)
> +		return -ENOMEM;
> +
> +	err =3D devlink_nl_config_get_fill(msg, devlink,
> +
> DEVLINK_CMD_PERM_CONFIG_GET, info);
> +
> +	if (err) {
> +		nlmsg_free(msg);
> +		return err;
> +	}
> +
> +	return genlmsg_reply(msg, info);
> +}
> +
> +static int devlink_nl_single_param_set(struct sk_buff *msg,
> +				       struct devlink *devlink,
> +				       u32 param, u32 value)
> +{
> +	u32 orig_value;
> +	u8 need_restart;
> +	int err;
> +	const struct devlink_ops *ops =3D devlink->ops;
> +	struct nlattr *cfgparam_attr;
> +
> +	/* First get current value of parameter */
> +	err =3D ops->perm_config_get(devlink, param, &orig_value);
> +	if (err)
> +		return err;
> +
> +	/* Now set parameter */
> +	err =3D ops->perm_config_set(devlink, param, value, &need_restart);
> +	if (err)
> +		return err;
> +
> +	cfgparam_attr =3D nla_nest_start(msg,
> DEVLINK_ATTR_PERM_CONFIG);
> +	/* Update restart reqd - if any param needs restart, should be set */
> +	if (need_restart)
> +		err =3D nla_put_u8(msg,
> +
> DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED, 1);
> +
> +	/* Since set was successful, write attr back to msg with orig val */
> +	err =3D nla_put_u32(msg,
> DEVLINK_ATTR_PERM_CONFIG_PARAMETER, param);
> +	err =3D nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE,
> orig_value);
> +
> +	nla_nest_end(msg, cfgparam_attr);
> +
> +	return 0;
> +}
> +
> +static int devlink_nl_cmd_perm_config_set_doit(struct sk_buff *skb,
> +					       struct genl_info *info)
> +{
> +	struct devlink *devlink =3D info->user_ptr[0];
> +	struct sk_buff *msg;
> +	void *hdr;
> +	struct nlattr *attr;
> +	int rem;
> +	int err;
> +	u8 restart_reqd =3D 0;
> +	struct nlattr *cfgparam_attr;
> +	struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
> +	u32 param;
> +	u32 value;
> +
> +	if (!devlink->ops || !devlink->ops->perm_config_get ||
> +	    !devlink->ops->perm_config_set)
> +		return -EOPNOTSUPP;
> +
> +	msg =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (!msg)
> +		return -ENOMEM;
> +
> +	hdr =3D genlmsg_put(msg, info->snd_portid, info->snd_seq,
> +			  &devlink_nl_family, 0,
> DEVLINK_CMD_PERM_CONFIG_SET);
> +	if (!hdr) {
> +		err =3D -EMSGSIZE;
> +		goto nla_msg_failure;
> +	}
> +
> +	err =3D devlink_nl_put_handle(msg, devlink);
> +	if (err)
> +		goto nla_put_failure;
> +
> +	cfgparam_attr =3D nla_nest_start(msg,
> DEVLINK_ATTR_PERM_CONFIGS);
> +
> +	nla_for_each_nested(attr, info-
> >attrs[DEVLINK_ATTR_PERM_CONFIGS], rem) {
> +		err =3D nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
> +				       devlink_nl_policy, NULL);
> +		if (err)
> +			goto nla_nest_failure;
> +
> +		if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] ||
> +		    !tb[DEVLINK_ATTR_PERM_CONFIG_VALUE])
> +			continue;
> +
> +		param =3D
> nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);
> +		value =3D
> nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_VALUE]);
> +		err =3D devlink_nl_single_param_set(msg, devlink, param,
> +						  value);
> +		if (err)
> +			goto nla_nest_failure;
> +	}
> +
> +	nla_nest_end(msg, cfgparam_attr);
> +
> +	if (restart_reqd) {

Doesn't seem like you're ever setting it.
A leftover from when this was an attribute of the configs instead
of per-config perhaps?

> +		err =3D nla_put_u8(msg,
> DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED,
> +				 restart_reqd);
> +		if (err)
> +			goto nla_put_failure;
> +	}
> +
> +	genlmsg_end(msg, hdr);
> +	return genlmsg_reply(msg, info);
> +
> +nla_nest_failure:
> +	nla_nest_cancel(msg, cfgparam_attr);
> +nla_put_failure:
> +	genlmsg_cancel(msg, hdr);
> +nla_msg_failure:
> +	return err;
> +}
> +
>  int devlink_dpipe_match_put(struct sk_buff *skb,
>  			    struct devlink_dpipe_match *match)
>  {
> @@ -2291,6 +2509,8 @@ static const struct nla_policy
> devlink_nl_policy[DEVLINK_ATTR_MAX + 1] =3D {
>  	[DEVLINK_ATTR_ESWITCH_ENCAP_MODE] =3D { .type =3D NLA_U8 },
>  	[DEVLINK_ATTR_DPIPE_TABLE_NAME] =3D { .type =3D NLA_NUL_STRING
> },
>  	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] =3D { .type =3D
> NLA_U8 },
> +	[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] =3D { .type =3D NLA_U32
> },
> +	[DEVLINK_ATTR_PERM_CONFIG_VALUE] =3D { .type =3D NLA_U32 },
>  };
>=20
>  static const struct genl_ops devlink_nl_ops[] =3D {
> @@ -2451,6 +2671,20 @@ static const struct genl_ops devlink_nl_ops[] =3D =
{
>  		.flags =3D GENL_ADMIN_PERM,
>  		.internal_flags =3D DEVLINK_NL_FLAG_NEED_DEVLINK,
>  	},
> +	{
> +		.cmd =3D DEVLINK_CMD_PERM_CONFIG_GET,
> +		.doit =3D devlink_nl_cmd_perm_config_get_doit,
> +		.policy =3D devlink_nl_policy,
> +		.flags =3D GENL_ADMIN_PERM,
> +		.internal_flags =3D DEVLINK_NL_FLAG_NEED_DEVLINK,
> +	},
> +	{
> +		.cmd =3D DEVLINK_CMD_PERM_CONFIG_SET,
> +		.doit =3D devlink_nl_cmd_perm_config_set_doit,
> +		.policy =3D devlink_nl_policy,
> +		.flags =3D GENL_ADMIN_PERM,
> +		.internal_flags =3D DEVLINK_NL_FLAG_NEED_DEVLINK,
> +	},
>  };
>=20
>  static struct genl_family devlink_nl_family __ro_after_init =3D {
> --
> 2.7.4
