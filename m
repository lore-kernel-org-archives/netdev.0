From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv3 net] ipv6: no need to return rt->dst.error if it is
 prohibit entry
Date: Wed, 26 Jul 2017 11:09:39 -0600
Message-ID: <07c66e6f-5b78-3317-18c6-bd2f955d5f90@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <1501060829-11928-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37597 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750921AbdGZRJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 13:09:42 -0400
Received: by mail-pg0-f66.google.com with SMTP id k190so2155805pgk.4
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 10:09:42 -0700 (PDT)
In-Reply-To: <1501060829-11928-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/26/17 3:20 AM, Hangbin Liu wrote:
> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
> result when requested"). When we get a prohibit ertry, we will return
> -EACCES directly.
> 
> Before:

Do you mean "Before commit 18c3a61c4264?"

> + ip netns exec client ip -6 route get 2003::1
> prohibit 2003::1 dev lo table unspec proto kernel src 2001::1 metric
> 4294967295 error -13
> 
> After:

And "After commit 18c3a61c4264?"

> + ip netns exec server ip -6 route get 2002::1
> RTNETLINK answers: Permission denied
> 
> Fix this by add prohibit and blk hole check.
> 
> At the same time, after commit
> 2f460933f58e ("ipv6: initialize route null entry in addrconf_init()") and
> 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
> We will init rt6i_idev correctly. So we could dump ip6_null_entry
> (unreachable route entry) safely now.
> 
> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  net/ipv6/route.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4d30c96..b05da74 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -3637,13 +3637,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>  		dst = ip6_route_lookup(net, &fl6, 0);
>  
>  	rt = container_of(dst, struct rt6_info, dst);
> -	if (rt->dst.error) {
> -		err = rt->dst.error;
> -		ip6_rt_put(rt);
> -		goto errout;
> -	}
> -
> -	if (rt == net->ipv6.ip6_null_entry) {
> +	if (rt->dst.error &&
> +#ifdef CONFIG_IPV6_MULTIPLE_TABLES
> +	    rt != net->ipv6.ip6_prohibit_entry &&
> +	    rt != net->ipv6.ip6_blk_hole_entry &&
> +#endif
> +	    rt != net->ipv6.ip6_null_entry) {
>  		err = rt->dst.error;
>  		ip6_rt_put(rt);
>  		goto errout;
> 

This is what I see with your patch:

# ip -6 ro ls vrf red
2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
prohibit 5000::/120 dev lo metric 1024  error -13 pref medium
fe80::/64 dev eth1 proto kernel metric 256  pref medium
ff00::/8 dev eth1 metric 256  pref medium
unreachable default dev lo metric 8192  error -113 pref medium

ie., I added a prohibit route for 5000:/120

and then running:
# ip -6 ro get vrf red 5000::1
RTNETLINK answers: Permission denied

Which is the behavior without your patch.

Now if I delete just the first bit:

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96a819d..8fc52de40175 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3637,12 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff
*in_skb, struct nlmsghdr *nlh,
                dst = ip6_route_lookup(net, &fl6, 0);

        rt = container_of(dst, struct rt6_info, dst);
-       if (rt->dst.error) {
-               err = rt->dst.error;
-               ip6_rt_put(rt);
-               goto errout;
-       }
-
        if (rt == net->ipv6.ip6_null_entry) {
                err = rt->dst.error;
                ip6_rt_put(rt);

Then I get:

# ip -6 ro get vrf red 5000::1
prohibit 5000::1 from :: dev lo table red src 2001:db8::2 metric 1024
error -13 pref medium

which seems to be your objective.

I don't understand why you are focused on the built-in null and prohibit
route entries. When I add a default unreachable or prohibit route those
are different rt6_info entries. Take a look at ip6_route_info_create.
