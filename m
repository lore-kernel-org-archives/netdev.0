From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net v2] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 13:52:34 -0800
Message-ID: <1488232354.9415.209.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488231268-6583-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com,
        David Ahern <dsa@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33627 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751813AbdB0Vwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 16:52:36 -0500
Received: by mail-pg0-f67.google.com with SMTP id x17so2237423pgi.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 13:52:35 -0800 (PST)
In-Reply-To: <1488231268-6583-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 13:34 -0800, Cong Wang wrote:
> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
> because ip6_null_entry is returned in this path since ip6_null_entry
> is kinda default for a ipv6 route table root node. Quote from
> David Ahern:
> 
>  ip6_null_entry is the root of all ipv6 fib tables making it integrated
>  into the table ...
> 
> We should ignore any attempt of trying to delete it, like we do in
> __ip6_del_rt() path and several others.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Fixes: 0ae8133586ad ("net: ipv6: Allow shorthand delete of all nexthops in multipath route")
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/route.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f54f426..78be2cb 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2169,10 +2169,13 @@ int ip6_del_rt(struct rt6_info *rt)
>  static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
>  {
>  	struct nl_info *info = &cfg->fc_nlinfo;
> +	struct net *net = info->nl_net;
>  	struct sk_buff *skb = NULL;
>  	struct fib6_table *table;
>  	int err;
>  
> +	if (rt == net->ipv6.ip6_null_entry)
> +		goto out_put;

err is not initialized at this point.


>  	table = rt->rt6i_table;
>  	write_lock_bh(&table->tb6_lock);
>  
> @@ -2184,7 +2187,7 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
>  		if (skb) {
>  			u32 seq = info->nlh ? info->nlh->nlmsg_seq : 0;
>  
> -			if (rt6_fill_node(info->nl_net, skb, rt,
> +			if (rt6_fill_node(net, skb, rt,
>  					  NULL, NULL, 0, RTM_DELROUTE,
>  					  info->portid, seq, 0) < 0) {
>  				kfree_skb(skb);
> @@ -2205,10 +2208,11 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
>  	err = fib6_del(rt, info);
>  out:
>  	write_unlock_bh(&table->tb6_lock);
> +out_put:
>  	ip6_rt_put(rt);
>  
>  	if (skb) {
> -		rtnl_notify(skb, info->nl_net, info->portid, RTNLGRP_IPV6_ROUTE,
> +		rtnl_notify(skb, net, info->portid, RTNLGRP_IPV6_ROUTE,
>  			    info->nlh, gfp_any());
>  	}
>  	return err;

This returns garbage here.
