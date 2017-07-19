From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 07/17] ipv6: fib: Add in-kernel notifications for
 route add / delete
Date: Wed, 19 Jul 2017 09:38:11 -0600
Message-ID: <2db9b613-3978-52f5-db9d-d3e36742db49@gmail.com>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-8-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34974 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933245AbdGSPiO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 11:38:14 -0400
Received: by mail-pg0-f65.google.com with SMTP id d193so342663pgc.2
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 08:38:13 -0700 (PDT)
In-Reply-To: <20170719070232.28457-8-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 1:02 AM, Jiri Pirko wrote:
> @@ -879,6 +891,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
>  		*ins = rt;
>  		rt->rt6i_node = fn;
>  		atomic_inc(&rt->rt6i_ref);
> +		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_ADD,
> +					  rt);
>  		if (!info->skip_notify)
>  			inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
>  		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
> @@ -906,6 +920,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
>  		rt->rt6i_node = fn;
>  		rt->dst.rt6_next = iter->dst.rt6_next;
>  		atomic_inc(&rt->rt6i_ref);
> +		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_REPLACE,
> +					  rt);
>  		if (!info->skip_notify)
>  			inet6_rt_notify(RTM_NEWROUTE, rt, info, NLM_F_REPLACE);
>  		if (!(fn->fn_flags & RTN_RTINFO)) {
> @@ -1459,6 +1475,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
>  
>  	fib6_purge_rt(rt, fn, net);
>  
> +	call_fib6_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, rt);
>  	if (!info->skip_notify)
>  		inet6_rt_notify(RTM_DELROUTE, rt, info, 0);
>  	rt6_release(rt);
> 


Why aren't all of the notifier calls under the skip_notify? That flag is
used to make handling of ipv6 multipath routes on par with ipv4. See
commit 3b1137fe74829
