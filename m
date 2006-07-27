From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Fri, 28 Jul 2006 00:58:49 +0200
Message-ID: <44C94529.5080605@trash.net>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch> <Pine.LNX.4.64.0607270158001.4779@d.namei> <20060726.230230.111423566.davem@davemloft.net> <20060727223931.GZ14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:31110 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751422AbWG0XAb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 19:00:31 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060727223931.GZ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Derived from net/ipv6/fib_rules.c

This clashes with my routing table patch, guess we have to figure
out who should go first :)

> +int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
> +		     int flags, struct fib_lookup_arg *arg)
> +{
> +	struct fib_rule *rule;
> +	int err;
> +
> +	rcu_read_lock();
> +
> +	list_for_each_entry(rule, ops->rules_list, list) {

Shouldn't that be list_for_each_entry_rcu?

> +		if (rule->ifname[0] && (rule->ifindex != fl->iif))
> +			continue;
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
> +	}
> +
> +	err = -ENETUNREACH;
> +out:
> +	rcu_read_unlock();

rcu_read_unlock might get called multiple times in the list iteration
and once again here.
