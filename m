From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [NET] fib_rules: Flush route cache after rule modifications
Date: Tue, 27 Mar 2007 15:30:08 +0200
Message-ID: <20070327133008.GE4557@rhun.ibm.com>
References: <20070327132159.GK521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:41877 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852AbXC0NaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 09:30:11 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l2RDUAhL057248
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 13:30:10 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2RDUAIZ2080958
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 14:30:10 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2RDUAfT004414
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 14:30:10 +0100
Content-Disposition: inline
In-Reply-To: <20070327132159.GK521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 03:21:59PM +0200, Thomas Graf wrote:

> The results of FIB rules lookups are cached in the routing cache
> except for IPv6 as no such cache exists. So far, it was the
> responsibility of the user to flush the cache after modifying any
> rules. This lead to many false bug reports due to misunderstanding
> of this concept.
> 
> This patch automatically flushes the route cache after inserting
> or deleting a rule.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.22/include/net/fib_rules.h
> ===================================================================
> --- net-2.6.22.orig/include/net/fib_rules.h	2007-03-27 13:54:52.000000000 +0200
> +++ net-2.6.22/include/net/fib_rules.h	2007-03-27 14:16:24.000000000 +0200
> @@ -59,6 +59,10 @@ struct fib_rules_ops
>  	u32			(*default_pref)(void);
>  	size_t			(*nlmsg_payload)(struct fib_rule *);
>  
> +	/* Called after modifications to the rules set, must flush
> +	 * the route cache if one exists. */
> +	void			(*flush_cache)(void);
> +
>  	int			nlgroup;
>  	struct nla_policy	*policy;
>  	struct list_head	*rules_list;
> Index: net-2.6.22/net/core/fib_rules.c
> ===================================================================
> --- net-2.6.22.orig/net/core/fib_rules.c	2007-03-27 13:53:29.000000000 +0200
> +++ net-2.6.22/net/core/fib_rules.c	2007-03-27 13:59:20.000000000 +0200
> @@ -44,6 +44,12 @@ static void rules_ops_put(struct fib_rul
>  		module_put(ops->owner);
>  }
>  
> +static void flush_route_cache(struct fib_rules_ops *ops)
> +{
> +	if (ops->flush_cache)
> +		ops->flush_cache();
> +}
> +
>  int fib_rules_register(struct fib_rules_ops *ops)
>  {
>  	int err = -EEXIST;
> @@ -315,6 +321,7 @@ static int fib_nl_newrule(struct sk_buff
>  
>  	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).pid);
>  	rules_ops_put(ops);
> +	flush_route_cache(ops);
>  	return 0;
>  
>  errout_free:
> @@ -405,6 +412,7 @@ static int fib_nl_delrule(struct sk_buff
>  				   NETLINK_CB(skb).pid);
>  		fib_rule_put(rule);
>  		rules_ops_put(ops);
> +		flush_route_cache(ops);
>  		return 0;
>  	}

That looks like a bug - shouldn't we flush the cache first, then do
the rules_ops_put()?

Cheers,
Muli
