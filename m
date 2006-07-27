From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Fri, 28 Jul 2006 01:30:42 +0200
Message-ID: <44C94CA2.4090900@trash.net>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch> <Pine.LNX.4.64.0607270158001.4779@d.namei> <20060726.230230.111423566.davem@davemloft.net> <20060727223931.GZ14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26248 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751513AbWG0XcX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 19:32:23 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060727223931.GZ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> --- /dev/null
> +++ net-2.6.git/net/core/fib_rules.c
> +int fib_rules_register(struct fib_rules_ops *ops)
> +{
> +	int err = -EEXIST;
> +	struct fib_rules_ops *o;
> +
> +	if (ops->rule_size < sizeof(struct fib_rule))
> +		return -EINVAL;
> +
> +	if (ops->match == NULL || ops->configure == NULL ||
> +	    ops->compare == NULL || ops->fill == NULL ||
> +	    ops->action == NULL)
> +		return -EINVAL;
> +
> +	spin_lock_bh(&rules_mod_lock);

This doesn't look like it needs bh protection.

> +	list_for_each_entry(o, &rules_ops, list)
> +		if (ops->family == o->family)
> +			goto errout;
> +
> +	list_add_tail_rcu(&ops->list, &rules_ops);
> +	err = 0;
> +errout:
> +	spin_unlock_bh(&rules_mod_lock);
> +
> +	return err;
> +}
> +
> +EXPORT_SYMBOL_GPL(fib_rules_register);
> +
> +static void cleanup_ops(struct fib_rules_ops *ops)
> +{
> +	struct fib_rule *rule, *tmp;
> +
> +	list_for_each_entry_safe(rule, tmp, ops->rules_list, list) {
> +		list_del_rcu(&rule->list);
> +		fib_rule_put(rule);
> +	}
> +}
> +
> +int fib_rules_unregister(struct fib_rules_ops *ops)
> +{
> +	int err = 0;
> +	struct fib_rules_ops *o;
> +
> +	spin_lock_bh(&rules_mod_lock);
> +	list_for_each_entry(o, &rules_ops, list) {
> +		if (o == ops) {
> +			list_del_rcu(&o->list);
> +			cleanup_ops(ops);
> +			goto out;
> +		}
> +	}
> +
> +	err = -ENOENT;
> +out:
> +	spin_unlock_bh(&rules_mod_lock);
> +
> +	synchronize_net();
> +
> +	return err;
> +}
> +
> +EXPORT_SYMBOL_GPL(fib_rules_unregister);
> +
> +int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
> +		     int flags, struct fib_lookup_arg *arg)
> +{
> +	struct fib_rule *rule;
> +	int err;
> +
> +	rcu_read_lock();
> +
> +	list_for_each_entry(rule, ops->rules_list, list) {
> +		if (rule->ifname[0] && (rule->ifindex != fl->iif))
> +			continue;

ifindex may be unset even if ifname is set (in case the interface
does not exist yet). In that case it will match falsely on
locally generated packets.

> +
> +		if (!ops->match(rule, fl, flags))
> +			continue;
> +
> +		rcu_read_unlock();
> +
> +		err = ops->action(rule, fl, flags, arg);
> +		if (err != -EAGAIN) {
> +			fib_rule_get(rule);
> +			arg->rule = rule;
> +			goto out;
> +		}

This seems to race with fib_nl_delrule:

CPU1			CPU2
			list_for_each_entry -> find matching entry
list_del_rcu
fib_rule_put
call_rcu(fib_rule_put_rcu)
			fib_rule_get

Moving fib_rule_get inside the rcu protected section and
calling synchronize_rcu before fib_rule_put in fib_nl_delrule
looks like the easiest fix.

> +	}
> +
> +	err = -ENETUNREACH;
> +out:
> +	rcu_read_unlock();
> +
> +	return err;
> +}
> +
> +EXPORT_SYMBOL_GPL(fib_rules_lookup);
> +
> +int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
> +{
> +	struct fib_rule_hdr *frh = nlmsg_data(nlh);
> +	struct fib_rules_ops *ops = NULL;
> +	struct fib_rule *rule, *r, *last = NULL;
> +	struct nlattr *tb[FRA_MAX+1];
> +	int err = -EINVAL;
> +
> +	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
> +		goto errout;
> +
> +	ops = lookup_rules_ops(frh->family);
> +	if (ops == NULL) {
> +		err = EAFNOSUPPORT;
> +		goto errout;
> +	}
> +
> +	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy);
> +	if (err < 0)
> +		goto errout;
> +
> +	if (tb[FRA_IFNAME] && nla_len(tb[FRA_IFNAME]) > IFNAMSIZ)
> +		goto errout;
> +
> +	rule = kzalloc(ops->rule_size, GFP_KERNEL);
> +	if (rule == NULL) {
> +		err = -ENOMEM;
> +		goto errout;
> +	}
> +
> +	if (tb[FRA_PRIORITY])
> +		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
> +
> +	if (tb[FRA_IFNAME]) {
> +		struct net_device *dev;
> +
> +		rule->ifindex = -1;
> +		if (nla_strlcpy(rule->ifname, tb[FRA_IFNAME],
> +				IFNAMSIZ) >= IFNAMSIZ)
> +			goto errout_free;
> +
> +		dev = __dev_get_by_name(rule->ifname);
> +		if (dev)
> +			rule->ifindex = dev->ifindex;
> +	}
> +
> +	rule->action = frh->action;
> +	rule->flags = frh->flags;
> +	rule->table = frh->table;
> +
> +	if (!rule->pref && ops->default_pref)
> +		rule->pref = ops->default_pref();
> +
> +	err = ops->configure(rule, skb, nlh, frh, tb);
> +	if (err < 0)
> +		goto errout_free;
> +
> +	list_for_each_entry(r, ops->rules_list, list) {
> +		if (r->pref > rule->pref)
> +			break;
> +		last = r;
> +	}
> +
> +	fib_rule_get(rule);
> +
> +	if (last)
> +		list_add_rcu(&rule->list, &last->list);
> +	else
> +		list_add_rcu(&rule->list, ops->rules_list);
> +
> +	notify_rule_change(RTM_NEWRULE, rule, ops);
> +	rules_ops_put(ops);
> +	return 0;
> +
> +errout_free:
> +	kfree(rule);
> +errout:
> +	rules_ops_put(ops);
> +	return err;
> +}
> +
> +int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
> +{
> +	struct fib_rule_hdr *frh = nlmsg_data(nlh);
> +	struct fib_rules_ops *ops = NULL;
> +	struct fib_rule *rule;
> +	struct nlattr *tb[FRA_MAX+1];
> +	int err = -EINVAL;
> +
> +	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
> +		goto errout;
> +
> +	ops = lookup_rules_ops(frh->family);
> +	if (ops == NULL) {
> +		err = EAFNOSUPPORT;
> +		goto errout;
> +	}
> +
> +	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy);
> +	if (err < 0)
> +		goto errout;
> +
> +	list_for_each_entry(rule, ops->rules_list, list) {
> +		if (frh->action && (frh->action != rule->action))
> +			continue;
> +
> +		if (frh->table && (frh->table != rule->table))
> +			continue;
> +
> +		if (tb[FRA_PRIORITY] &&
> +		    (rule->pref != nla_get_u32(tb[FRA_PRIORITY])))
> +			continue;
> +
> +		if (tb[FRA_IFNAME] &&
> +		    nla_strcmp(tb[FRA_IFNAME], rule->ifname))
> +			continue;
> +
> +		if (!ops->compare(rule, frh, tb))
> +			continue;
> +
> +		if (rule->flags & FIB_RULE_PERMANENT) {
> +			err = -EPERM;
> +			goto errout;
> +		}
> +
> +		list_del_rcu(&rule->list);
> +		notify_rule_change(RTM_DELRULE, rule, ops);
> +		fib_rule_put(rule);
> +		rules_ops_put(ops);
> +		return 0;
> +	}
> +
> +	err = -ENOENT;
> +errout:
> +	rules_ops_put(ops);
> +	return err;
> +}
> +
> +static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
> +			    u32 pid, u32 seq, int type, int flags,
> +			    struct fib_rules_ops *ops)
> +{
> +	struct nlmsghdr *nlh;
> +	struct fib_rule_hdr *frh;
> +
> +	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*frh), flags);
> +	if (nlh == NULL)
> +		return -1;
> +
> +	frh = nlmsg_data(nlh);
> +	frh->table = rule->table;
> +	frh->res1 = 0;
> +	frh->res2 = 0;
> +	frh->action = rule->action;
> +	frh->flags = rule->flags;
> +
> +	if (rule->ifname[0])
> +		NLA_PUT_STRING(skb, FRA_IFNAME, rule->ifname);
> +
> +	if (rule->pref)
> +		NLA_PUT_U32(skb, FRA_PRIORITY, rule->pref);
> +
> +	if (ops->fill(rule, skb, nlh, frh) < 0)
> +		goto nla_put_failure;
> +
> +	return nlmsg_end(skb, nlh);
> +
> +nla_put_failure:
> +	return nlmsg_cancel(skb, nlh);
> +}
> +
> +int fib_rules_dump(struct sk_buff *skb, struct netlink_callback *cb, int family)
> +{
> +	int idx = 0;
> +	struct fib_rule *rule;
> +	struct fib_rules_ops *ops;
> +
> +	ops = lookup_rules_ops(family);
> +	if (ops == NULL)
> +		return -EAFNOSUPPORT;
> +
> +	rcu_read_lock();
> +	list_for_each_entry(rule, ops->rules_list, list) {
> +		if (idx < cb->args[0])
> +			goto skip;
> +
> +		if (fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).pid,
> +				     cb->nlh->nlmsg_seq, RTM_NEWRULE,
> +				     NLM_F_MULTI, ops) < 0)
> +			break;
> +skip:
> +		idx++;
> +	}
> +	rcu_read_unlock();
> +	cb->args[0] = idx;
> +	rules_ops_put(ops);
> +
> +	return skb->len;
> +}
> +
> +EXPORT_SYMBOL_GPL(fib_rules_dump);
> +
> +static void notify_rule_change(int event, struct fib_rule *rule,
> +			       struct fib_rules_ops *ops)
> +{
> +	int size = nlmsg_total_size(sizeof(struct fib_rule_hdr) + 128);
> +	struct sk_buff *skb = alloc_skb(size, GFP_KERNEL);
> +
> +	if (skb == NULL)
> +		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, ENOBUFS);
> +	else if (fib_nl_fill_rule(skb, rule, 0, 0, event, 0, ops) < 0) {
> +		kfree_skb(skb);
> +		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, EINVAL);
> +	} else
> +		netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_RULE, GFP_KERNEL);
> +}

Shouldn't different families use different groups? Userspace
might (rightfully, I think) expect not to see anything but
IPv4 rules on RTNLGRP_IPV4_RULE.

> +static void attach_rules(struct list_head *rules, struct net_device *dev)
> +{
> +	struct fib_rule *rule;
> +
> +	list_for_each_entry(rule, rules, list) {
> +		if (rule->ifindex == -1 &&
> +		    strcmp(dev->name, rule->ifname) == 0)
> +			rule->ifindex = dev->ifindex;
> +	}
> +}
> +
> +static void detach_rules(struct list_head *rules, struct net_device *dev)
> +{
> +	struct fib_rule *rule;
> +
> +	list_for_each_entry(rule, rules, list)
> +		if (rule->ifindex == dev->ifindex)
> +			rule->ifindex = -1;
> +}
> +
> +
> +static int fib_rules_event(struct notifier_block *this, unsigned long event,
> +			    void *ptr)
> +{
> +	struct net_device *dev = ptr;
> +	struct fib_rules_ops *ops;
> +
> +	ASSERT_RTNL();
> +	rcu_read_lock();
> +
> +	switch (event) {
> +	case NETDEV_REGISTER:
> +		list_for_each_entry(ops, &rules_ops, list)
> +			attach_rules(ops->rules_list, dev);
> +		break;
> +
> +	case NETDEV_UNREGISTER:
> +		list_for_each_entry(ops, &rules_ops, list)
> +			detach_rules(ops->rules_list, dev);
> +		break;
> +	}
> +
> +	rcu_read_unlock();
> +
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block fib_rules_notifier = {
> +	.notifier_call = fib_rules_event,
> +};
> +
> +static int __init fib_rules_init(void)
> +{
> +	return register_netdevice_notifier(&fib_rules_notifier);
> +}
> +
> +subsys_initcall(fib_rules_init);
