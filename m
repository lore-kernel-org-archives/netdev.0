From: jamal <hadi@cyberus.ca>
Subject: Re: net 04/05: fib_rules: allow to delete local rule
Date: Tue, 01 Dec 2009 08:23:41 -0500
Message-ID: <1259673821.3168.35.camel@bigi>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet>
	 <20091130175534.7555.48216.sendpatchset@x2.localnet>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, robert@herjulf.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f197.google.com ([209.85.212.197]:38235 "EHLO
	mail-vw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbZLANXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 08:23:39 -0500
Received: by vws35 with SMTP id 35so1498863vws.4
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 05:23:44 -0800 (PST)
In-Reply-To: <20091130175534.7555.48216.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nice. I recall there was a lot of sentiment against this back
when - in particular from Alexey. I cant remember the details
neither can i think off top of my head why this would be bad
other than allowing people to shoot their big toe without
knowing it.
CCing Robert and Alexey. Mass quoting to provide context for 
both Alexey and Robert.

cheers,
jamal


On Mon, 2009-11-30 at 18:55 +0100, Patrick McHardy wrote:
> commit ca1ba96aaa05cc0a2a7f172990e7787354c8b7b9
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Nov 30 16:05:51 2009 +0100
> 
>     net: fib_rules: allow to delete local rule
>     
>     Allow to delete the local rule and recreate it with a lower priority. This
>     can be used to force packets with a local destination out on the wire instead
>     of routing them to loopback. Additionally this patch allows to recreate rules
>     with a priority of 0.
>     
>     Combined with the previous patch to allow oif classification, a socket can
>     be bound to the desired interface and packets routed to the wire like this:
>     
>     # move local rule to lower priority
>     ip rule add pref 1000 lookup local
>     ip rule del pref 0
>     
>     # route packets of sockets bound to eth0 to the wire independant
>     # of the destination address
>     ip rule add pref 100 oif eth0 lookup 100
>     ip route add default dev eth0 lookup 100
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index d1a70ad..ef0e7d9 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -287,7 +287,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
>  	rule->flags = frh->flags;
>  	rule->table = frh_get_table(frh, tb);
>  
> -	if (!rule->pref && ops->default_pref)
> +	if (!tb[FRA_PRIORITY] && ops->default_pref)
>  		rule->pref = ops->default_pref(ops);
>  
>  	err = -EINVAL;
> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> index 835262c..1239ed2 100644
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
> @@ -284,7 +284,7 @@ static int fib_default_rules_init(struct fib_rules_ops *ops)
>  {
>  	int err;
>  
> -	err = fib_default_rule_add(ops, 0, RT_TABLE_LOCAL, FIB_RULE_PERMANENT);
> +	err = fib_default_rule_add(ops, 0, RT_TABLE_LOCAL, 0);
>  	if (err < 0)
>  		return err;
>  	err = fib_default_rule_add(ops, 0x7FFE, RT_TABLE_MAIN, 0);
> diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
> index 00a7a5e..3b38f49 100644
> --- a/net/ipv6/fib6_rules.c
> +++ b/net/ipv6/fib6_rules.c
> @@ -276,7 +276,7 @@ static int fib6_rules_net_init(struct net *net)
>  	INIT_LIST_HEAD(&net->ipv6.fib6_rules_ops->rules_list);
>  
>  	err = fib_default_rule_add(net->ipv6.fib6_rules_ops, 0,
> -				   RT6_TABLE_LOCAL, FIB_RULE_PERMANENT);
> +				   RT6_TABLE_LOCAL, 0);
>  	if (err)
>  		goto out_fib6_rules_ops;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

