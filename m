From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Thu, 05 Jun 2008 15:17:17 +0200
Message-ID: <4847E75D.9080609@trash.net>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080527141346.12851.2280.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42673 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbYFENRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 09:17:21 -0400
In-Reply-To: <20080527141346.12851.2280.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PJ Waskiewicz wrote:
> +/**
> + * enum dcbnl_perm_hwaddr_attrs - DCB Permanent HW Address nested attributes
> + *
> + * @DCB_PERM_HW_ATTR_UNDEFINED: unspecified attribute to catch errors
> + * @DCB_PERM_HW_ATTR_0: MAC address from receive address 0 (NLA_U8)
> + * @DCB_PERM_HW_ATTR_1: MAC address from receive address 1 (NLA_U8)
> + * @DCB_PERM_HW_ATTR_2: MAC address from receive address 2 (NLA_U8)
> + * @DCB_PERM_HW_ATTR_3: MAC address from receive address 3 (NLA_U8)
> + * @DCB_PERM_HW_ATTR_4: MAC address from receive address 4 (NLA_U8)
> + * @DCB_PERM_HW_ATTR_5: MAC address from receive address 5 (NLA_U8)
> + * @DCB_PERM_HW_ATTR_ALL: apply to all MAC addresses (NLA_FLAG)
> + *
> + * These attributes are used when bonding DCB interfaces together.
> + *
> + */

For these and the other numbered attributes: is the maximum number
fixed and/or defined somewhere? If not, I'd suggest to use lists
of attributes.

> +/**
> + * enum dcbnl_pg_attrs - DCB Priority Group attributes
> + *
> + * @DCB_PG_ATTR_UNDEFINED: unspecified attribute to catch errors
> + * @DCB_PG_ATTR_TC_0: Priority Group Traffic Class 0 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_1: Priority Group Traffic Class 1 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_2: Priority Group Traffic Class 2 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_3: Priority Group Traffic Class 3 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_4: Priority Group Traffic Class 4 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_5: Priority Group Traffic Class 5 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_6: Priority Group Traffic Class 6 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_7: Priority Group Traffic Class 7 configuration (NLA_NESTED)
> + * @DCB_PG_ATTR_TC_MAX: highest attribute number currently defined
> + * @DCB_PG_ATTR_TC_ALL: apply to all traffic classes (NLA_NESTED)
> + * @DCB_PG_ATTR_BWG_0: Bandwidth group 0 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_1: Bandwidth group 1 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_2: Bandwidth group 2 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_3: Bandwidth group 3 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_4: Bandwidth group 4 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_5: Bandwidth group 5 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_6: Bandwidth group 6 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_7: Bandwidth group 7 configuration (NLA_U8)
> + * @DCB_PG_ATTR_BWG_MAX: highest attribute number currently defined
> + * @DCB_PG_ATTR_BWG_ALL: apply to all bandwidth groups (NLA_FLAG)

And in this case lists of nested attributes consisting of
Priority and Bandwidth, since they seem to belong together.

> +struct dcbnl_genl_ops {
> +	u8   (*getstate)(struct net_device *);
> +	void (*setstate)(struct net_device *, u8);
> +	void (*getpermhwaddr)(struct net_device *, u8 *);

"getpermhwaddr" doesn't seem to belong in this interface but
in rtnetlink and/or ethtool instead.

> +static int dcbnl_getperm_hwaddr(struct sk_buff *skb, struct genl_info *info)
> +{
> ...
> +	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (!dcbnl_skb)
> +		goto err_out;
> ...
> +err:
> +	kfree(dcbnl_skb);

^^^ kfree_skb

The same error is present multiple times

> +static int __dcbnl_pg_setcfg(struct genl_info *info, int dir)
> +{
> +	struct net_device *netdev = NULL;
> +	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
> +	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
> +	int ret = -EINVAL;
> +	int i;
> +	u8 prio = 0, bwg_id = 0, bw_pct = 0, up_map = 0;
> +
> +	if (!info->attrs[DCB_ATTR_IFNAME] || !info->attrs[DCB_ATTR_PG_CFG])
> +		return ret;
> +
> +	netdev = dev_get_by_name(&init_net,
> +				 nla_data(info->attrs[DCB_ATTR_IFNAME]));


The fact that you do this in every handler makes me wonder whether
rtnetlink wouldn't be the better choice, if only because it uses
the rtnl_mutex and configuration changes are thus serialized with
other networking configuration changes.

For example I don't see anything preventing concurrent changes
to the DCB configuration while it is copied between the temporary
configuration and the real one. In one cases its done in a
path holding the rtnl_mutex, in another case its done with
holding the genl_mutex in a genetlink callback.

