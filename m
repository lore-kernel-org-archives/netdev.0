From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 13 May 2010 22:40:59 +0200
Message-ID: <4BEC63DB.2090306@trash.net>
References: <20100513201714.25579.53530.stgit@savbu-pc100.cisco.com> <20100513201720.25579.51230.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	arnd@arndb.de
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62157 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab0EMUlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 16:41:01 -0400
In-Reply-To: <20100513201720.25579.51230.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman wrote:
> +struct ifla_vf_port_vsi {
> +	__u8 vsi_mgr_id;
> +	__u8 vsi_type_id[3];
> +	__u8 vsi_type_version;
> +	__u8 pad[3];
> +};

Where is this actually used? The only use I could find is in the
size calculation.

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 23a71cb..de14d36 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> +static int rtnl_vf_port_fill_nest(struct sk_buff *skb, struct net_device *dev,
> +	int vf)

Please keep the style used in that file consistent and align arguments
to the beginning of the opening '('.

> +{
> +	struct nlattr *data;
> +	int err;
> +
> +	data = nla_nest_start(skb, IFLA_VF_PORT);
> +	if (!data)
> +		return -EMSGSIZE;
> +
> +	if (vf >= 0)
> +		nla_put_u32(skb, IFLA_VF_PORT_VF, vf);
> +
> +	err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
> +	if (err == -EMSGSIZE) {
> +		nla_nest_cancel(skb, data);
> +		return -EMSGSIZE;
> +	} else if (err) {
> +		nla_nest_cancel(skb, data);
> +		return 0;

Why is the error not returned in this case?

> +	}
> +
> +	nla_nest_end(skb, data);
> +
> +	return 0;
> +}
> +
> +static int rtnl_vf_port_fill(struct sk_buff *skb, struct net_device *dev)
> +{
> +	int num_vf;
> +	int err;
> +
> +	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
> +		return 0;
> +
> +	num_vf = dev_num_vf(dev->dev.parent);
> +
> +	if (num_vf) {
> +		int i;
> +
> +		for (i = 0; i < num_vf; i++) {
> +			err = rtnl_vf_port_fill_nest(skb, dev, i);
> +			if (err)
> +				goto nla_put_failure;
> +		}
> +	} else  {
> +		err = rtnl_vf_port_fill_nest(skb, dev, -1);

What does -1 mean?

> +		if (err)
> +			goto nla_put_failure;
> +	}
> +
> +	return 0;
> +
> +nla_put_failure:
> +	return -EMSGSIZE;
> +}
> +
>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			    int type, u32 pid, u32 seq, u32 change,
>  			    unsigned int flags)
> @@ -747,17 +825,23 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  		goto nla_put_failure;
>  	copy_rtnl_link_stats64(nla_data(attr), stats);
>  
> +	if (dev->dev.parent)
> +		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));

Should this attribute really be included even if the number is zero?

> +
>  	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
>  		int i;
>  		struct ifla_vf_info ivi;
>  
> -		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
>  		for (i = 0; i < dev_num_vf(dev->dev.parent); i++) {
>  			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
>  				break;
>  			NLA_PUT(skb, IFLA_VFINFO, sizeof(ivi), &ivi);
>  		}
>  	}
> +
> +	if (rtnl_vf_port_fill(skb, dev))
> +		goto nla_put_failure;
> +
>  	if (dev->rtnl_link_ops) {
>  		if (rtnl_link_fill(skb, dev) < 0)
>  			goto nla_put_failure;
> @@ -824,6 +908,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>  				    .len = sizeof(struct ifla_vf_vlan) },
>  	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
>  				    .len = sizeof(struct ifla_vf_tx_rate) },
> +	[IFLA_VF_PORT]		= { .type = NLA_NESTED },
>  };
>  EXPORT_SYMBOL(ifla_policy);
>  
> @@ -832,6 +917,20 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
>  	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
>  };
>  
> +static const struct nla_policy ifla_vf_port_policy[IFLA_VF_PORT_MAX+1] = {
> +	[IFLA_VF_PORT_VF]		= { .type = NLA_U32 },
> +	[IFLA_VF_PORT_PROFILE]		= { .type = NLA_STRING,
> +				.len = VF_PORT_PROFILE_MAX },

This is oddly indented, please align .len to .type as in the
existing attributes.

> +	[IFLA_VF_PORT_VSI_TYPE]		= { .type = NLA_BINARY,
> +				.len = sizeof(struct ifla_vf_port_vsi)},
> +	[IFLA_VF_PORT_INSTANCE_UUID]	= { .type = NLA_BINARY,
> +				.len = VF_PORT_UUID_MAX },
> +	[IFLA_VF_PORT_HOST_UUID]	= { .type = NLA_STRING,
> +				.len = VF_PORT_UUID_MAX },
> +	[IFLA_VF_PORT_REQUEST]		= { .type = NLA_U8, },
> +	[IFLA_VF_PORT_RESPONSE]		= { .type = NLA_U16, },
> +};
> +
>  struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
>  {
>  	struct net *net;
> @@ -1028,6 +1127,27 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  	}
>  	err = 0;
>  
> +	if (tb[IFLA_VF_PORT]) {
> +		struct nlattr *vf_port[IFLA_VF_PORT_MAX+1];
> +		int vf = -1;
> +
> +		err = nla_parse_nested(vf_port, IFLA_VF_PORT_MAX,
> +			tb[IFLA_VF_PORT], ifla_vf_port_policy);
> +		if (err < 0)
> +			goto errout;
> +
> +		if (vf_port[IFLA_VF_PORT_VF])
> +			vf = nla_get_u32(vf_port[IFLA_VF_PORT_VF]);
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_set_vf_port)
> +			err = ops->ndo_set_vf_port(dev, vf, vf_port);

This appears to be addressing a single VF to issue commands.
I already explained this during the last set of VF patches,
messages are supposed to by symetrical, since you're dumping
state for all existing VFs, you also need to accept configuration
for multiple VFs. Basically, the kernel must be able to receive
a message it created during a dump and fully recreate the state.
