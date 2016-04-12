From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next WIP] ethtool: generic netlink policy
Date: Tue, 12 Apr 2016 12:01:14 +0200
Message-ID: <1460455274.6369.24.camel@sipsolutions.net>
References: <1460344545-45501-1-git-send-email-roopa@cumulusnetworks.com>
	 (sfid-20160411_051557_806073_B637D217)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jiri@resnulli.us, eladr@mellanox.com,
	idosch@mellanox.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55580 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753719AbcDLKB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 06:01:26 -0400
In-Reply-To: <1460344545-45501-1-git-send-email-roopa@cumulusnetworks.com> (sfid-20160411_051557_806073_B637D217)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> +	[ETHTOOL_ATTR_FLAGS]		=3D { .type =3D NLA_U32 },

I suppose this comes from the current API, but perhaps it'd be
worthwhile to make provision for more flags? Perhaps even using
NLA_BINARY and have "infinitely extensible" flags.

> +	[ETHTOOL_ATTR_SSET_COUNT]		=3D { .type =3D NLA_U32

What do you need that for? Wouldn't it be sufficient to count the SSET
values returned? I can see how this would be useful for ioctl, but not
really for netlink messages?

> +static struct genl_ops ethtool_ops[] =3D {
> +	{
> +		.cmd =3D ETHTOOL_CMD_GET_SETTINGS,
> +		.policy =3D ethtool_policy,
> +		.doit =3D ethtool_get_settings,
> +	},
[...]
> +	{
> +		.cmd =3D ETHTOOL_CMD_SET_MODULE_INFO,
> +		.policy =3D ethtool_policy,
> +		.doit =3D ethtool_set_module_info,
> +	},
> +};

Shouldn't the ops have GENL_ADMIN_PERM as flags?

> +int ethtool_get_settings(struct net_device *dev, struct ethtool_cmd
> *cmd)
> +{
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(ethtool_get_settings);

I don't understand what kind of placeholder this was meant to be - but
why would it be exported? This part is called by the genl ops, so
doesn't really make sense?

It seems that instead these functions should be static, declared above
the ops, and call into the existing ethtool driver ops, based on
IFINDEX demultiplexing.

> +void ethtool_get_ethtool_stats(struct net_device *dev,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_stats *s=
tats,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u64 *data)
> +{
> +
> +	/* example the driver handler would do the below
> +	=C2=A0*
> +	err =3D nla_put_u32(msg, PORT_ATTR_IFINDEX, ifindex);
> +	if (err < 0)
> +		goto err_out;
> +
> +	err =3D nla_put_u32(msg, PORT_ATTR_FLAGS, flags);
> +	if (err < 0)
> +		goto err_out;
> +
> +	err =3D nla_put_u32(msg, PORT_ATTR_SSET_COUNT,
> +			=C2=A0=C2=A0count);
> +	if (err < 0)
> +		goto err_out;
> +
> +	nest =3D nla_nest_start(msg, PORT_ATTR_STATS);
> +	for (i =3D 0; i < count; i++)
> +		nla_put_u64(msg, PORT_ATTR_STAT, data[i]);
> +			=C2=A0=C2=A0=C2=A0=C2=A0nla_nest_end(msg, nest);
> +
> +	=C2=A0*/
> +}
> +EXPORT_SYMBOL_GPL(ethtool_get_ethtool_stats);

It seems possible that you could have a lot of ports, or a lot of
strings, or similar, so I think this should be a dumpit instead of a
doit handler.

Similar, perhaps, for the EEPROM thing, unless you provide API to query
the size first so the application can size it's recvmsg() buffer
appropriately - however doing so also requires a big message allocation
and more code in userspace, so I think having an "offset/length" type
of API combined with a dumpit rather than doit would be good for all of
the things that could get bigger or that might be extended in the
future.

johannes
