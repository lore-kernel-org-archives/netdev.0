From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules Framework
Date: Fri, 28 Jul 2006 12:23:39 +0200
Message-ID: <20060728102339.GC14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch> <Pine.LNX.4.64.0607270158001.4779@d.namei> <20060726.230230.111423566.davem@davemloft.net> <20060727223931.GZ14627@postel.suug.ch> <44C94CA2.4090900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:3811 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932620AbWG1KXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 06:23:19 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44C94CA2.4090900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-07-28 01:30
> > +int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
> > +		     int flags, struct fib_lookup_arg *arg)
> > +{
> > +	struct fib_rule *rule;
> > +	int err;
> > +
> > +	rcu_read_lock();
> > +
> > +	list_for_each_entry(rule, ops->rules_list, list) {
> > +		if (rule->ifname[0] && (rule->ifindex != fl->iif))
> > +			continue;
> 
> ifindex may be unset even if ifname is set (in case the interface
> does not exist yet). In that case it will match falsely on
> locally generated packets.

Then rule->ifindex would be -1 and it shouldn't match but I
changed it, it makes more sense.

> > +static void notify_rule_change(int event, struct fib_rule *rule,
> > +			       struct fib_rules_ops *ops)
> > +{
> > +	int size = nlmsg_total_size(sizeof(struct fib_rule_hdr) + 128);
> > +	struct sk_buff *skb = alloc_skb(size, GFP_KERNEL);
> > +
> > +	if (skb == NULL)
> > +		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, ENOBUFS);
> > +	else if (fib_nl_fill_rule(skb, rule, 0, 0, event, 0, ops) < 0) {
> > +		kfree_skb(skb);
> > +		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, EINVAL);
> > +	} else
> > +		netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_RULE, GFP_KERNEL);
> > +}
> 
> Shouldn't different families use different groups? Userspace
> might (rightfully, I think) expect not to see anything but
> IPv4 rules on RTNLGRP_IPV4_RULE.

Right, I've added ops->nlgroup to fix this. Naturally I also
fixed all the other issues you brought up, I have the feeling
that there are more bugs, will look at the code again with
some distance in a few days.
