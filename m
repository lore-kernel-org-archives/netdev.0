From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sat, 12 Jan 2013 22:50:13 -0500
Message-ID: <20130113035013.GJ5259@kvack.org>
References: <50F1699E.1000200@hartkopp.net> <20130112.132316.2121287993605534669.davem@davemloft.net> <20130112.133630.257139657732337147.davem@davemloft.net> <1358046374.20249.1789.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:47246 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754457Ab3AMDuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2013 22:50:14 -0500
Content-Disposition: inline
In-Reply-To: <1358046374.20249.1789.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 12, 2013 at 07:06:14PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> act_mirred needs to find the current net_ns, and struct net
> pointer is not provided in the call chain. We run in process
> context and current->nsproxy->net_ns is the needed pointer.
...

I don't think this is correct.  Going by the call chain, tcf_action_add can 
be called because of a netlink message, and that netlink message may not be 
in the same "struct net" as the current process.  It looks like the ->init 
operation is going to need to have the namespace passed in for this to work 
correctly.

		-ben

> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index 9c0fd0c..f5a7e18 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -88,7 +88,7 @@ static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
>  		return -EINVAL;
>  	}
>  	if (parm->ifindex) {
> -		dev = __dev_get_by_index(&init_net, parm->ifindex);
> +		dev = __dev_get_by_index(current->nsproxy->net_ns, parm->ifindex);
>  		if (dev == NULL)
>  			return -ENODEV;
>  		switch (dev->type) {
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
"Thought is the essence of where you are now."
