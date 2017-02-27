From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 12:34:20 -0800
Message-ID: <1488227660.9415.207.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488222425-1256-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34110 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751473AbdB0UmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 15:42:03 -0500
Received: by mail-pg0-f65.google.com with SMTP id s67so2074588pgb.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:41:01 -0800 (PST)
In-Reply-To: <1488222425-1256-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 11:07 -0800, Cong Wang wrote:
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
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/route.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f54f426..9da77e9 100644
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
> +		return -ENOENT;

It looks the caller did a dst_hold(&rt->dst);

So this new error path would leave a refcount leak.

Note that I was not able to trigger the crash on old kernels, so it
would be nice to get a precise idea of bug origin.

Thanks.
