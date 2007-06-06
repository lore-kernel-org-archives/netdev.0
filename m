From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC RTNETLINK 04/09]: Link creation API
Date: Wed, 06 Jun 2007 10:37:56 -0600
Message-ID: <m1zm3dt4wr.fsf@ebiederm.dsl.xmission.com>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141256.15650.37514.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:59941 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894AbXFFQkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 12:40:09 -0400
In-Reply-To: <20070605141256.15650.37514.sendpatchset@localhost.localdomain>
	(Patrick McHardy's message of "Tue, 5 Jun 2007 16:12:57 +0200 (MEST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> +{
> +	struct rtnl_link_ops *ops;
> +	struct net_device *dev;
> +	struct ifinfomsg *ifm;
> +	char name[MODULE_NAME_LEN];
> +	char ifname[IFNAMSIZ];
> +	struct nlattr *tb[IFLA_MAX+1];
> +	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
> +	int err;
> +
> +	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
> +	if (err < 0)
> +		return err;
> +
> +	if (tb[IFLA_IFNAME])
> +		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
> +	else
> +		ifname[0] = '\0';
> +
> +	ifm = nlmsg_data(nlh);
> +	if (ifm->ifi_index > 0)
> +		dev = __dev_get_by_index(ifm->ifi_index);
> +	else if (ifname[0])
> +		dev = __dev_get_by_name(ifname);
> +	else
> +		dev = NULL;
> +
> +	if (tb[IFLA_LINKINFO]) {
> +		err = nla_parse_nested(linkinfo, IFLA_INFO_MAX,
> +				       tb[IFLA_LINKINFO], ifla_info_policy);
> +		if (err < 0)
> +			return err;
> +	} else
> +		memset(linkinfo, 0, sizeof(linkinfo));
> +
> +	if (linkinfo[IFLA_INFO_NAME]) {
> +		nla_strlcpy(name, linkinfo[IFLA_INFO_NAME], sizeof(name));
> +		ops = rtnl_link_ops_get(name);

Ugh.  Shouldn't we have the request_module logic here?
Otherwise it looks like we can skip the validate method and 
have other weird interactions.


> +	} else {
> +		name[0] = '\0';
> +		ops = NULL;
> +	}
> +
> +	if (1) {
> +		struct nlattr *attr[ops ? ops->maxtype + 1 : 0], **data = NULL;
> +
> +		if (ops) {
> +			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
> +				err = nla_parse_nested(attr, ops->maxtype,
> + linkinfo[IFLA_INFO_DATA],
> +						       ops->policy);
> +				if (err < 0)
> +					return err;
> +				data = attr;
> +			}
> +			if (ops->validate) {
> +				err = ops->validate(tb, data);
> +				if (err < 0)
> +					return err;
> +			}
> +		}
> +
> +		if (dev) {
> +			int modified = 0;
> +
> +			if (nlh->nlmsg_flags & NLM_F_EXCL)
> +				return -EEXIST;
> +			if (nlh->nlmsg_flags & NLM_F_REPLACE)
> +				return -EOPNOTSUPP;
> +
> +			if (linkinfo[IFLA_INFO_DATA]) {
> +				if (!ops || ops != dev->rtnl_link_ops ||
> +				    !ops->changelink)
> +					return -EOPNOTSUPP;
> +
> +				err = ops->changelink(dev, tb, data);
> +				if (err < 0)
> +					return err;
> +				modified = 1;
> +			}
> +
> +			return do_setlink(dev, ifm, tb, ifname, modified);
> +		}
> +
> +		if (!(nlh->nlmsg_flags & NLM_F_CREATE))
> +			return -ENODEV;
> +
> +		if (ifm->ifi_index)
> +			return -EINVAL;
> +		if (tb[IFLA_ADDRESS] || tb[IFLA_BROADCAST] || tb[IFLA_MAP])
> +			return -EOPNOTSUPP;
> +
> +#ifdef CONFIG_KMOD
> +		if (!ops && name[0]) {
> +			/* race condition: device may be created while rtnl is
> +			 * unlocked, final register_netdevice will catch it.
> +			 */
> +			__rtnl_unlock();
> +			request_module("rtnl-link-%s", name);
> +			rtnl_lock();
> +			ops = rtnl_link_ops_get(name);
> +		}
> +#endif
> +		if (!ops)
> +			return -EOPNOTSUPP;

> +
> +		if (!ifname[0])
> +			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->name);
> +		dev = alloc_netdev(ops->priv_size, ifname, ops->setup);
> +		if (!dev)
> +			return -ENOMEM;
> +
> +		if (strchr(dev->name, '%')) {
> +			err = dev_alloc_name(dev, dev->name);
> +			if (err < 0)
> +				goto err_free;
> +		}
> +		dev->rtnl_link_ops = ops;
> +
> +		if (tb[IFLA_MTU])
> +			dev->mtu = nla_get_u32(tb[IFLA_MTU]);
> +		if (tb[IFLA_TXQLEN])
> +			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
> +		if (tb[IFLA_WEIGHT])
> +			dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
> +		if (tb[IFLA_OPERSTATE])
> +			set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
> +		if (tb[IFLA_LINKMODE])
> +			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
> +
> +		err = ops->newlink(dev, tb, data);
> +err_free:
> +		if (err < 0)
> +			free_netdev(dev);
> +		return err;
> +	}
> +}
> +

Eric
