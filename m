From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Wed, 31 Dec 2014 12:10:01 -0800
Message-ID: <54A45819.2090206@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194544.31070.30335.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:59768 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaLaUKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 15:10:20 -0500
Received: by mail-ob0-f171.google.com with SMTP id uz6so49327213obc.2
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 12:10:19 -0800 (PST)
In-Reply-To: <20141231194544.31070.30335.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/2014 11:45 AM, John Fastabend wrote:
> Currently, we do not have an interface to query hardware and learn
> the capabilities of the device. This makes it very difficult to use
> hardware flow tables.
>

oops missed a few dev_put calls so at least need a new rev
for this. I'll wait a few days for feedback though.

[...]

> +
> +static int net_flow_cmd_get_actions(struct sk_buff *skb,
> +				    struct genl_info *info)
> +{
> +	struct net_flow_action **a;
> +	struct net_device *dev;
> +	struct sk_buff *msg;
> +
> +	dev = net_flow_get_dev(info);
> +	if (!dev)
> +		return -EINVAL;
> +
> +	if (!dev->netdev_ops->ndo_flow_get_actions) {
> +		dev_put(dev);
> +		return -EOPNOTSUPP;
> +	}
> +
> +	a = dev->netdev_ops->ndo_flow_get_actions(dev);
> +	if (!a)

missing dev_put(dev) here.

> +		return -EBUSY;
> +
> +	msg = net_flow_build_actions_msg(a, dev,
> +					 info->snd_portid,
> +					 info->snd_seq,
> +					 NET_FLOW_TABLE_CMD_GET_ACTIONS);
> +	dev_put(dev);
> +
> +	if (IS_ERR(msg))
> +		return PTR_ERR(msg);
> +
> +	return genlmsg_reply(msg, info);
> +}
> +
> +static int net_flow_put_table(struct net_device *dev,
> +			      struct sk_buff *skb,
> +			      struct net_flow_table *t)
> +{
> +	struct nlattr *matches, *actions;
> +	int i;
> +
> +	if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
> +		return -EMSGSIZE;
> +
> +	matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
> +	if (!matches)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; t->matches[i].instance; i++)
> +		nla_put(skb, NET_FLOW_FIELD_REF,
> +			sizeof(struct net_flow_field_ref),
> +			&t->matches[i]);

need to check the return codes here.

> +	nla_nest_end(skb, matches);
> +
> +	actions = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_ACTIONS);
> +	if (!actions)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; t->actions[i]; i++) {
> +		if (nla_put_u32(skb,
> +				NET_FLOW_ACTION_ATTR_UID,
> +				t->actions[i])) {
> +			nla_nest_cancel(skb, actions);
> +			return -EMSGSIZE;
> +		}

remembered to do the check here though ;)

> +	}
> +	nla_nest_end(skb, actions);
> +
> +	return 0;
> +}
> +

[...]

> +
> +static struct sk_buff *net_flow_build_tables_msg(struct net_flow_table **t,
> +						 struct net_device *dev,
> +						 u32 portid, int seq, u8 cmd)
> +{
> +	struct genlmsghdr *hdr;
> +	struct sk_buff *skb;
> +	int err = -ENOBUFS;
> +
> +	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (!skb)
> +		return ERR_PTR(-ENOBUFS);
> +
> +	hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
> +	if (!hdr)
> +		goto out;
> +
> +	if (nla_put_u32(skb,
> +			NET_FLOW_IDENTIFIER_TYPE,
> +			NET_FLOW_IDENTIFIER_IFINDEX) ||
> +	    nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex)) {
> +		err = -ENOBUFS;
> +		goto out;
> +	}
> +
> +	err = net_flow_put_tables(dev, skb, t);
> +	if (err < 0)
> +		goto out;
> +
> +	err = genlmsg_end(skb, hdr);
> +	if (err < 0)
> +		goto out;
> +
> +	return skb;
> +out:
> +	nlmsg_free(skb);
> +	return ERR_PTR(err);
> +}
> +
> +static int net_flow_cmd_get_tables(struct sk_buff *skb,
> +				   struct genl_info *info)
> +{
> +	struct net_flow_table **tables;
> +	struct net_device *dev;
> +	struct sk_buff *msg;
> +
> +	dev = net_flow_get_dev(info);
> +	if (!dev)
> +		return -EINVAL;
> +
> +	if (!dev->netdev_ops->ndo_flow_get_tables) {
> +		dev_put(dev);
> +		return -EOPNOTSUPP;
> +	}
> +
> +	tables = dev->netdev_ops->ndo_flow_get_tables(dev);
> +	if (!tables) /* transient failure should always have some table */

need dev_put()

> +		return -EBUSY;
> +
> +	msg = net_flow_build_tables_msg(tables, dev,
> +					info->snd_portid,
> +					info->snd_seq,
> +					NET_FLOW_TABLE_CMD_GET_TABLES);
> +	dev_put(dev);
> +
> +	if (IS_ERR(msg))
> +		return PTR_ERR(msg);
> +
> +	return genlmsg_reply(msg, info);
> +}
> +

[...]

> +
> +static int net_flow_put_headers(struct sk_buff *skb,
> +				struct net_flow_header **headers)
> +{
> +	struct nlattr *nest, *hdr, *fields;
> +	struct net_flow_header *h;
> +	int i, err;
> +
> +	nest = nla_nest_start(skb, NET_FLOW_HEADERS);
> +	if (!nest)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; headers[i]->uid; i++) {
> +		err = -EMSGSIZE;
> +		h = headers[i];
> +
> +		hdr = nla_nest_start(skb, NET_FLOW_HEADER);
> +		if (!hdr)
> +			goto hdr_put_failure;
> +
> +		if (nla_put_string(skb, NET_FLOW_HEADER_ATTR_NAME, h->name) ||
> +		    nla_put_u32(skb, NET_FLOW_HEADER_ATTR_UID, h->uid))
> +			goto attr_put_failure;
> +
> +		fields = nla_nest_start(skb, NET_FLOW_HEADER_ATTR_FIELDS);
> +		if (!fields)
> +			goto attr_put_failure;
> +
> +		err = net_flow_put_fields(skb, h);
> +		if (err)
> +			goto fields_put_failure;
> +
> +		nla_nest_end(skb, fields);
> +

can remove this new line I think it doesn't add much.

> +		nla_nest_end(skb, hdr);
> +	}
> +	nla_nest_end(skb, nest);
> +
> +	return 0;
> +fields_put_failure:
> +	nla_nest_cancel(skb, fields);
> +attr_put_failure:
> +	nla_nest_cancel(skb, hdr);
> +hdr_put_failure:
> +	nla_nest_cancel(skb, nest);
> +	return err;
> +}
> +

[...]

> +
> +static int net_flow_cmd_get_headers(struct sk_buff *skb,
> +				    struct genl_info *info)
> +{
> +	struct net_flow_header **h;
> +	struct net_device *dev;
> +	struct sk_buff *msg;
> +
> +	dev = net_flow_get_dev(info);
> +	if (!dev)
> +		return -EINVAL;
> +
> +	if (!dev->netdev_ops->ndo_flow_get_headers) {
> +		dev_put(dev);
> +		return -EOPNOTSUPP;
> +	}
> +
> +	h = dev->netdev_ops->ndo_flow_get_headers(dev);
> +	if (!h)

dev_put again

> +		return -EBUSY;
> +
> +	msg = net_flow_build_headers_msg(h, dev,
> +					 info->snd_portid,
> +					 info->snd_seq,
> +					 NET_FLOW_TABLE_CMD_GET_HEADERS);
> +	dev_put(dev);
> +
> +	if (IS_ERR(msg))
> +		return PTR_ERR(msg);
> +
> +	return genlmsg_reply(msg, info);
> +}
> +

[...]

> +
> +static int net_flow_cmd_get_header_graph(struct sk_buff *skb,
> +					 struct genl_info *info)
> +{
> +	struct net_flow_hdr_node **h;
> +	struct net_device *dev;
> +	struct sk_buff *msg;
> +
> +	dev = net_flow_get_dev(info);
> +	if (!dev)
> +		return -EINVAL;
> +
> +	if (!dev->netdev_ops->ndo_flow_get_hdr_graph) {
> +		dev_put(dev);
> +		return -EOPNOTSUPP;
> +	}
> +
> +	h = dev->netdev_ops->ndo_flow_get_hdr_graph(dev);
> +	if (!h)

dev_put() seems I copy/pasted the same template for each cmd.

> +		return -EBUSY;
> +
> +	msg = net_flow_build_header_graph_msg(h, dev,
> +					      info->snd_portid,
> +					      info->snd_seq,
> +					      NET_FLOW_TABLE_CMD_GET_HDR_GRAPH);
> +	dev_put(dev);
> +
> +	if (IS_ERR(msg))
> +		return PTR_ERR(msg);
> +
> +	return genlmsg_reply(msg, info);
> +}
> +

[...]

> +
> +static int net_flow_cmd_get_table_graph(struct sk_buff *skb,
> +					struct genl_info *info)
> +{
> +	struct net_flow_tbl_node **g;
> +	struct net_device *dev;
> +	struct sk_buff *msg;
> +
> +	dev = net_flow_get_dev(info);
> +	if (!dev)
> +		return -EINVAL;
> +
> +	if (!dev->netdev_ops->ndo_flow_get_tbl_graph) {
> +		dev_put(dev);
> +		return -EOPNOTSUPP;
> +	}
> +
> +	g = dev->netdev_ops->ndo_flow_get_tbl_graph(dev);
> +	if (!g)

dev_put

> +		return -EBUSY;
> +

[...]


-- 
John Fastabend         Intel Corporation
