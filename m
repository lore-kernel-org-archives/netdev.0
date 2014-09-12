From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] ipv4: Do not cache routing failures due to disabled
 forwarding.
Date: Sat, 13 Sep 2014 01:13:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409130004360.8785@ja.home.ssi.bg>
References: <1410531260-13794-1-git-send-email-nicolas.cavallari@green-communications.fr> <1410531260-13794-2-git-send-email-nicolas.cavallari@green-communications.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44459 "EHLO localhost.localdomain"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752273AbaILWOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 18:14:06 -0400
In-Reply-To: <1410531260-13794-2-git-send-email-nicolas.cavallari@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 12 Sep 2014, Nicolas Cavallari wrote:

> If we cache them, the kernel will reuse them, independently of
> whether forwarding is enabled or not.  Which means that if forwarding is
> disabled on the input interface where the first routing request comes
> from, then that unreachable result will be cached and reused for
> other interfaces, even if forwarding is enabled on them.
> 
> This can be verified with two interfaces A and B and an output interface
> C, where B has forwarding enabled, but not A and trying
> ip route get $dst iif A from $src && ip route get $dst iif B from $src

	Correct. While failed fib_lookup() does not set
res.fi in net/ipv4/fib_trie.c:check_leaf(), on fib_lookup()
success we have res.fi != NULL and it remains for the
!IN_DEV_FORWARD case (the 2nd 'goto no_route').

> Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
> ---
> based on net-next, but not really tested on top of it.
> 
>  net/ipv4/route.c | 21 ++++++++++-----------
>  1 file changed, 10 insertions(+), 11 deletions(-)
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 234a43e..b537997 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1655,7 +1655,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  	struct rtable	*rth;
>  	int		err = -EINVAL;
>  	struct net    *net = dev_net(dev);
> -	bool do_cache;
> +	bool do_cache = true;
>  
>  	/* IP on this device is disabled. */
>  
> @@ -1723,6 +1723,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  
>  	if (!IN_DEV_FORWARD(in_dev)) {
>  		err = -EHOSTUNREACH;
> +		do_cache = false;
>  		goto no_route;
>  	}
>  	if (res.type != RTN_UNICAST)
> @@ -1746,16 +1747,14 @@ brd_input:
>  	RT_CACHE_STAT_INC(in_brd);
>  
>  local_input:
> -	do_cache = false;
> -	if (res.fi) {
> -		if (!itag) {
> -			rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
> -			if (rt_cache_valid(rth)) {
> -				skb_dst_set_noref(skb, &rth->dst);
> -				err = 0;
> -				goto out;
> -			}
> -			do_cache = true;
> +	if (!res.fi || itag) {
> +		do_cache = false;
> +	} else if (do_cache) {
> +		rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
> +		if (rt_cache_valid(rth)) {
> +			skb_dst_set_noref(skb, &rth->dst);
> +			err = 0;
> +			goto out;
>  		}
>  	}
>  
> -- 
> 2.1.0

	Two alternatives are possible:

1. set res.fi = NULL after 'no_route:' label

or better

2. set do_cache = false after 'no_route:' label,
then instead of 'goto local_input;' jump to a new
label 'create_rt:' just before rt_dst_alloc.

	Not sure, they may generate less code in the fast path.

Regards

--
Julian Anastasov <ja@ssi.bg>
