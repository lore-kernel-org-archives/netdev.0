From: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Subject: Re: [PATCH net-next 5/8] ipv6: new function fib6_flush_trees and
 use it instead of bumping removed rt6_genid
Date: Sun, 21 Sep 2014 11:21:52 +0900
Message-ID: <541E3640.6020907@yoshifuji.org>
References: <cover.1411249633.git.hannes@stressinduktion.org> <c0a1543fe7608640f2dd1f37f8fe5978f30536d1.1411249633.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48821 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751446AbaIUCVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 22:21:54 -0400
In-Reply-To: <c0a1543fe7608640f2dd1f37f8fe5978f30536d1.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> fib6_flush_trees is still a very costly operation but now is only called
> by xfrm code when a policy changes or ipv6 addresses are added/removed.
> 
> fib6_flush_tree must walk all ipv6 routing tables and modify fn_sernum,
> so all sockets relookup their dst_entries. Use a NULL callback, so we
> only walk the nodes without looking at the rt6_infos.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Martin Lau <kafai@fb.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/net_namespace.h | 14 +++-----------
>  include/net/netns/ipv6.h    |  1 -
>  net/ipv6/addrconf_core.c    |  6 ++++++
>  net/ipv6/af_inet6.c         |  1 -
>  net/ipv6/ip6_fib.c          | 21 +++++++++++++++++----
>  net/ipv6/route.c            |  4 ----
>  6 files changed, 26 insertions(+), 21 deletions(-)
> 
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index 361d260..61aad36 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -353,21 +353,13 @@ static inline void rt_genid_bump_ipv4(struct net *net)
>  }
>  
>  #if IS_ENABLED(CONFIG_IPV6)
> -static inline int rt_genid_ipv6(struct net *net)
> -{
> -	return atomic_read(&net->ipv6.rt_genid);
> -}
> -
> +extern void (*__fib6_flush_trees)(struct net *);
>  static inline void rt_genid_bump_ipv6(struct net *net)
>  {
> -	atomic_inc(&net->ipv6.rt_genid);
> +	if (__fib6_flush_trees)
> +		__fib6_flush_trees(net);
>  }
>  #else

Now it does not "bump" the genid anymore.  Why not to change the
function name to reflect the fact?

--yoshfuji
