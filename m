From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Thu, 20 Jul 2017 23:06:15 +0800
Message-ID: <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35750 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935186AbdGTPGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 11:06:17 -0400
Received: by mail-io0-f195.google.com with SMTP id f1so1989035ioj.2
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 08:06:16 -0700 (PDT)
In-Reply-To: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa, Cong,

2017-07-20 22:51 GMT+08:00 Hangbin Liu <liuhangbin@gmail.com>:
> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
> result when requested"). When we get a prohibit ertry, we will return
> -EACCES directly.
>
> Before:
> + ip netns exec client ip -6 route get 2003::1
> prohibit 2003::1 dev lo table unspec proto kernel src 2001::1 metric
> 4294967295 error -13
>
> After:
> + ip netns exec server ip -6 route get 2002::1
> RTNETLINK answers: Network is unreachable
>
> Since we will check the ip6_null_entry later. There is not sense
> to check the dst.error after get rt.
>
> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  net/ipv6/route.c | 6 ------
>  1 file changed, 6 deletions(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4d30c96..8fc52de 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -3637,12 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>                 dst = ip6_route_lookup(net, &fl6, 0);
>
>         rt = container_of(dst, struct rt6_info, dst);
> -       if (rt->dst.error) {
> -               err = rt->dst.error;
> -               ip6_rt_put(rt);
> -               goto errout;
> -       }

hmm... or instead of remove this check, should we check all the entry? Like
if ((rt->dst.error && rt != net->ipv6.ip6_null_entry && rt !=
net->ipv6.ip6_blk_hole_entry) ||
     rt == net->ipv6.ip6_null_entry )

What do you think?

Thanks
Hangbin
