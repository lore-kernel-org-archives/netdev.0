From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next v3 01/10] devlink: Add permanent config parameter
 get/set operations
Date: Tue, 24 Oct 2017 21:22:27 +0000
Message-ID: <AM0PR0502MB368378B824556ED230AF10C7BF470@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
 <1508875962-39233-2-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0075.outbound.protection.outlook.com ([104.47.0.75]:59776
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751536AbdJXVWc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 17:22:32 -0400
In-Reply-To: <1508875962-39233-2-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Add support for permanent config parameter get/set commands. Used
> for persistent device configuration parameters.
>=20
...
> +	int (*perm_config_get)(struct devlink *devlink,
> +			       enum devlink_perm_config_param param, u8
> type,
> +			       void *value);
> +	int (*perm_config_set)(struct devlink *devlink,
> +			       enum devlink_perm_config_param param, u8
> type,
> +			       void *value, u8 *restart_reqd);
>  };
> +static int devlink_nl_single_param_get(struct sk_buff *msg,
> +				       struct devlink *devlink,
> +				       u32 param, u8 type)
> +{
> +	const struct devlink_ops *ops =3D devlink->ops;
> +	struct nlattr *param_attr;
> +	void *value;
> +	u32 val;
> +	int err;
> +
> +	/* Allocate buffer for parameter value */
> +	switch (type) {
> +	case NLA_U8:
> +		value =3D kmalloc(sizeof(u8), GFP_KERNEL);
> +		break;
> +	case NLA_U16:
> +		value =3D kmalloc(sizeof(u16), GFP_KERNEL);
> +		break;
> +	case NLA_U32:
> +		value =3D kmalloc(sizeof(u32), GFP_KERNEL);
> +		break;
> +	default:
> +		return -EINVAL; /* Unsupported Type */
> +	}
> +
> +	if (!value)
> +		return -ENOMEM;
> +
> +	err =3D ops->perm_config_get(devlink, param, type, value);
> +	if (err)
> +		return err;

I suspect this logic might be risky - its dependent on the driver to cast t=
he
'value' into the proper type or else, E.g., the following switch might brea=
k
for BE platforms.
Is there any reason to have the devlink <-> driver API be based on void*
and not on some typed data [of sufficient size]?
...
> +	switch (type) {
> +	case NLA_U8:
> +		val =3D *((u8 *)value);
> +		if (nla_put_u8(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE,
> val))
> +			goto nest_err;
> +		break;
> +	case NLA_U16:
> +		val =3D *((u16 *)value);
> +		if (nla_put_u16(msg,
> DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
> +			goto nest_err;
> +		break;
> +	case NLA_U32:
> +		val =3D *((u32 *)value);
> +		if (nla_put_u32(msg,
> DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
> +			goto nest_err;
> +		break;
> +	}

...
> +static int devlink_nl_single_param_set(struct sk_buff *msg,
> +				       struct devlink *devlink,
> +				       u32 param, u8 type, void *value)
> +{
> +	const struct devlink_ops *ops =3D devlink->ops;
> +	struct nlattr *cfgparam_attr;
> +	u8 need_restart;
> +	int err;
> +
> +	/* Now set parameter */
> +	err =3D ops->perm_config_set(devlink, param, type, value,
> &need_restart);
> +	if (err)
> +		return err;

Likewise
